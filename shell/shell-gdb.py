import gdb

try:
    from vdb.cli import pr, do, im
except ImportError:
    pass

from functools import lru_cache

def cache(user_function):
    """
    Simple lightweight unbounded function cache. Sometimes called “memoize”.
    """
    return lru_cache(maxsize=None, typed=False)(user_function)

class SymtabBuilder:
    def __init__(self, compunit, filename):
        self.compunit = compunit
        self.filename = filename
        self.linetable = []

    def build(self):
        """
        Build the symbol table. Returns gdb.Symtab
        """
        self.symtab = gdb.Symtab(self.filename, self.compunit)

        #
        # Build line table if needed
        #
        if len(self.linetable) > 0:
            self.linetable.sort(key = lambda e : e[1])

            # Collect addresses to properly mark line starts,
            # prologues and epilogues.
            line_start_addrs = {}
            prologue_end_addr = -1
            for pc, line, prologue in self.linetable:
                line_start_addrs.setdefault(line, pc)
                if prologue:
                    prologue_end_addr = max(prologue_end_addr, pc)

            # Create 'real' gdb.LinetableEntry objects based on
            # entries and collected information
            entries = []
            for pc, line, _, in self.linetable:
                is_stmt = pc == line_start_addrs[line]
                prologue_end = pc == prologue_end_addr
                entry = gdb.LineTableEntry(line, pc, is_stmt, prologue_end)
                entries.append(entry)

            # And finally, create gdb.Linetable:
            gdb.LineTable(self.symtab, entries)

        return self.symtab



def add_code_object(name, addr, size, filetable = [], linetable = []):
    #
    # First, check if this GDB has all required patches, if not
    # do nothing.
    #
    if not hasattr(gdb, "Compunit"):
        return
    #
    # Create objfile if needed.
    #
    objfile = gdb.current_progspace().objfile_for_address(addr)
    if objfile is None:
        objfile = gdb.Objfile("nzone@{hex(addr)}")
    #
    # Create compunit for this code object.
    #
    compunit = gdb.Compunit(name, objfile, addr, addr+size, 3)

    #
    # Build symbol tables.
    #
    if len(filetable) == 0:
        filetable = ['<unknown source>']

    symtabs = [ SymtabBuilder(compunit, file) for file in filetable]
    for pc, fileNo, line, prologue in linetable:
        #
        # Each entry is a tuple of (pc, fileNo, line, prologue?)
        #
        assert addr <= pc and pc <= addr + size, "linetable entry out of range"
        symtabs[fileNo].linetable.append((pc, line, prologue))

    symtabs = [ stb.build() for stb in symtabs]
    symtab = symtabs[0]
    #
    # Finally, create the block and symbol for the function/method
    #
    fblk = gdb.Block(compunit.static_block(), addr, addr + size)
    ftyp = gdb.selected_inferior().architecture().void_type().function(varargs=True)
    fsym = gdb.Symbol(name, symtab, ftyp,
                     gdb.SYMBOL_FUNCTION_DOMAIN, gdb.SYMBOL_LOC_BLOCK,
                     fblk)
    compunit.static_block().add_symbol(fsym)
    #
    # Done!
    #

# Define some type and constants from debug info. Hopefully in a future,
# this debug info would be somehow generated from Smalltalk code...
class Types:
    char = gdb.selected_inferior().architecture().integer_type(8, False)
    void = gdb.selected_inferior().architecture().integer_type(0, False)
    uintptr_t = gdb.selected_inferior().architecture().integer_type(void.pointer().sizeof * 8, False)
    intptr_t = gdb.selected_inferior().architecture().integer_type(void.pointer().sizeof * 8, True)

    obj = uintptr_t
    oop = obj.pointer()

assert Types.uintptr_t.sizeof == 8

if hasattr(gdb.selected_inferior().architecture(), "void_type"):
    void = gdb.selected_inferior().architecture().void_type()

def _as_gdb_value(valueish, typ):
    if isinstance(valueish, gdb.Value):
        assert valueish.type.code == typ.code
        return valueish.cast(typ)
    elif isinstance(valueish, int):
        return gdb.Value(valueish).cast(typ)
    elif isinstance(valueish, str):
        val = gdb.parse_and_eval(valueish)
        if val.type.code == gdb.TYPE_CODE_INT and typ.code == gdb.TYPE_CODE_PTR:
            val = val.cast(typ)
        assert val.type.code == typ.code, "%s evaluated to a gdb.Value of a different type"
        return val
    else:
        raise ValueError("Invalid argument type (valueish")

def _as_oop_value(valueish):
    return _as_gdb_value(valueish, Types.oop)


class __ObjectABC(object):
    """
    Base abstract superclass for both a full object
    and (immediate) small integers.
    """

    def __init__(self, val):
        assert isinstance(val, gdb.Value)
        self._oop = val

    def __hash__(self):
        return hash(int(self._oop))

    def __eq__(self, other):
        return (
            self.__class__ == other.__class__
            and self._oop == other._oop
        )

class SmallInteger(__ObjectABC):
    def __init__(self, val):
        assert val.type == Types.oop
        assert (int(val) & 1) == 1
        super().__init__(val)

    def __int__(self):
        return int(self._oop) >> 1

    def isNil(self):
        return False

    def isSmallInteger(self):
        return True

    def bits(self, bits):
        if isinstance(bits, int):
            return 1 if (int(self) & (1 << bits-1)) > 0 else 0
        elif isinstance(bits, range):
            mask = (-1 << bits.stop) ^ (-1 << (bits.start - 1))
            shift = bits.start - 1
            return (int(self) & mask) >> shift
        else:
            raise ArgumentError("Invalid bits specifier - must be either int or range")


class Object(__ObjectABC):
    def __init__(self, val):
        super().__init__(val)

    def isNil(self):
        try:
            if self.clazzName() == 'UndefinedObject':
                return True
        except:
            pass
        return False

    def isSmallInteger(self):
        return False

    def __int__(self):
        return int(self._oop)

    def sizeInBytes(self):
        """
        Return size of an object in bytes, *excluding* header
        and excluding eventual alignment (for byte objects)
        """
        return (self._oop[1]).cast(Types.intptr_t)

    def sizeInBytesAligned(self):
        return align(self.sizeInBytes(), Types.oop.sizeof);

    @property
    @cache
    def clazz(self):
        return self.__class__(self._oop[0].cast(Types.oop))

    def numSlots(self):
        return (self.sizeInBytes() / Types.oop.sizeof)

    @cache
    def slotAt(self, index):
        """
        Return object given index as an instance of `Object`. Indexing
        starts at 1 as in Smalltalk.

        Assumes this is a pointer-indexed object.
        """
        assert index >= 1
        assert index <= self.numSlots()
        return obj(self._oop[1+index].cast(Types.oop))

    def slots(self):
        """
        Return a list of slot values (references to other objects)
        """
        return [ self.slotAt(i) for i in range(1, self.numSlots() + 1) ]


    def value(self):
        """
        Return gdb.Value representing self.
        """
        return self._oop

def obj(oopish):
    """
    Convenience function to create a representation
    of an object for given oopish.
    """
    if isinstance(oopish, __ObjectABC):
        return oopish
    else:
        oop_val = _as_oop_value(oopish)
        if (int(oop_val) & 1) == 1:
            return SmallInteger(oop_val)
        else:
            return Object(oop_val)
