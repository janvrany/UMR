Extension { #name : #TRRV64GLinux }

{ #category : #'*UMR-Runtime' }
TRRV64GLinux >> handleTRAPfor: shell in: frame [
	"
	Called when running `shell` (an instance of `UMRShell`) receives a
	trap. The `frame` argument is the frame execution the code that caused
	the trap.
	"
	"
	Implementation note: this design is BOGUS. Really. it is the
	semihosting linkage that should make the decision and extract
	parameters since it is the linkage that knows how to do
	all that...
	"
	| isa insn1Mask insn2Mask insn3Mask insn1 insn2 insn3 mem |

	"On RISC-V, standard semihosting call sequence is

		slli zero, zero, 0x1f
		ebreak
		srai zero, zero, <call no>
	"
	isa := AcProcessorDescriptions riscv64.
	insn1Mask := ((isa instructionAt: 'slli')   inEnvironment: (SmallDictionary newFromPairs:#('rs1' 0 'rd' 0 'shamt' 31)))
												binaryEncoding unsignedValue.
	insn2Mask := ((isa instructionAt: 'ebreak') inEnvironment: (SmallDictionary new))
												binaryEncoding unsignedValue.
	insn3Mask := ((isa instructionAt: 'srai')   inEnvironment: (SmallDictionary newFromPairs:#('rs1' 0 'rd' 0 'shamt' 0)))
												binaryEncoding unsignedValue.
	mem :=frame thread group memory.
	insn1 := mem unsignedLongAt: frame pc - 4 bigEndian: false.
	insn2 := mem unsignedLongAt: frame pc     bigEndian: false.
	insn3 := mem unsignedLongAt: frame pc + 4 bigEndian: false.

	(insn1 == insn1Mask and:[insn2 == insn2Mask and:[(insn3 bitAnd:insn3Mask) == insn3Mask]]) ifTrue: [
		"This is a semihosting call - process it."
		| callNo callParams retval |

		callNo := (isa decode: insn3) externalBindings at: 'shamt'.
		callParams := (0 to: 7) collect: [ :i | frame getRegister:'a', i printString ].

		retval := shell handlePrim: callNo parameters: callParams.

		frame setRegister: 'a0' to: retval.
		frame setRegister: 'pc' to: (frame pc + 4).
	] ifFalse: [
		self assert: false description: 'Unexpected SIGTRAP'
	].
]
