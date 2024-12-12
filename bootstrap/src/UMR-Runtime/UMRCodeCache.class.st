Class {
	#name : #UMRCodeCache,
	#superclass : #TRCodeCache,
	#category : #'UMR-Runtime'
}

{ #category : #'adding & removing' }
UMRCodeCache >> add: codeObj [
	super add: codeObj.

	(memory isKindOf: GDBThreadGroupMemory) ifTrue: [
		| func addr fileTable lineTable cmd |

		func := codeObj exports keys detect: [:sym | sym isTRFunctionSymbol ] ifNone: [ ^ self ].
		addr := symbols at: func.
		lineTable := OrderedCollection new.
		fileTable := OrderedCollection new.

		codeObj instructions do: [:insn |
			| insnPC insnNode |

			insnPC := addr.
			insn isPseudoInstruction ifFalse: [
				insnNode := insn node.
				(insnNode notNil and: [ insnNode location notNil ]) ifTrue: [
					| fileNo |

					"Files are indexed from zero!"
					fileNo := (fileTable indexOf: insnNode location file) - 1.
					fileNo == -1 ifTrue: [
						fileTable add: insnNode location file.
						fileNo := fileTable size - 1.
					].
					lineTable add: { insnPC.  fileNo. insnNode location line . insn isPartOfPrologue }.
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
			s nextPutAll: ','.
			(fileTable "copyTo: 1") pythonOn: s.
			s nextPutAll: ','.
			(lineTable "copyTo: 1") pythonOn: s.
			s nextPutAll: ')'
		].
		"
		memory debugger cli
		"
		memory debugger send: cmd.

	].
]
