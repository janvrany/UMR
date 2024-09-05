Class {
	#name : #UMRCodeCache,
	#superclass : #TRCodeCache,
	#category : #'UMR-Runtime'
}

{ #category : #'adding & removing' }
UMRCodeCache >> add: codeObj [
	super add: codeObj.

	(memory isKindOf: GDBThreadGroupMemory) ifTrue: [
		| func addr file lineTable cmd |

		func := codeObj exports keys detect: [:sym | sym isTRFunctionSymbol ] ifNone: [ ^ self ].
		addr := symbols at: func.
		file := '<unknown>'.
		lineTable := OrderedCollection new.

		codeObj instructions do: [:insn |
			| insnPC insnNode |

			insnPC := addr.
			insn isPseudoInstruction ifFalse: [
				insnNode := insn node.
				(insnNode notNil and: [ insnNode location notNil ]) ifTrue: [
					file := insnNode location file.
					lineTable add: { insnNode location line . insnPC . insnNode opcode isTreeTop }.
				]
			].

			addr := insnPC + (insn bitWidth // 8).
		].
		cmd := String streamContents: [ :s|
			s nextPutAll: 'python add_code_object('.
			func name pythonOn: s.
			s nextPutAll: ', '.
			(symbols at: func) pythonOn: s.
			s nextPutAll: ', '.
			codeObj size pythonOn: s.
			s nextPutAll: ', '.
			file pythonOn: s.
			s nextPutAll: ', '.
			lineTable pythonOn: s.
			s nextPutAll: ')'
		].
		"
		memory debugger cli
		"
		"
		Disabled for now, need special GDB
		"
		"
		memory debugger send: cmd.
		"
	].
]
