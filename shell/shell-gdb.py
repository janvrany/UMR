import gdb
import vdb

from vdb.cli import pr, do, im

from functools import lru_cache

def cache(user_function):
    """
    Simple lightweight unbounded function cache. Sometimes called “memoize”.
    """
    return lru_cache(maxsize=None, typed=False)(user_function)


def add_code_object(name, addr, size, file = "<unknown>", linetable = []):
    objfile = gdb.current_progspace().objfile_for_address(addr)
    if objfile is None:
        objfile = gdb.Objfile("nzone@{hex(addr)}")

    symtab = gdb.Symtab(objfile, file)
    symtab.add_block(name, addr, addr + size)
    symtab.set_linetable([gdb.LineTableEntry(*e) for e in linetable])


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
