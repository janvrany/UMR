Class {
	#name : #UMRSourceInfo,
	#superclass : #Object,
	#instVars : [
		'file',
		'position',
		'length',
		'lines'
	],
	#category : #'UMR-ProgramDefinition-Utils-Source'
}

{ #category : #'instance creation' }
UMRSourceInfo class >> file: file position: position length: length lines: lines [
	^ self basicNew initializeWithFile: file position: position length: length lines: lines

]

{ #category : #'instance creation' }
UMRSourceInfo >> initializeWithFile: fileArg position: positionArg length: lengthArg lines: linesArg [
	file := fileArg.
	position := positionArg.
	length := lengthArg.
	lines := linesArg.

]

{ #category : #queries }
UMRSourceInfo >> offsetToLine: offset [
	"Convert (relative) offset to (absolute) line"
	^ self positionToLine: position + offset - 1

]

{ #category : #private }
UMRSourceInfo >> positionToLine: pos [
	"Translate position in stream to line number"

	"We can do better using binary search..."
	lines withIndexDo: [:lineEndPos :lineNo |
		pos < lineEndPos ifTrue: [
			^ lineNo
		].
	].
	^ lines size + 1
]

{ #category : #accessing }
UMRSourceInfo >> sourceLocationForContext: context [
	Smalltalk isSmalltalkX ifTrue:[
		^self sourceLocationForLine: context lineNumber
	] ifFalse:[
		| node |

		node := context method sourceNodeForPC: context pc.
		^self sourceLocationForNode: node.
	]
]

{ #category : #accessing }
UMRSourceInfo >> sourceLocationForLine: line [
	file isNil ifTrue:[ ^nil ].

	^ TRSourceLocation
		file: file pathName
		line: (self positionToLine: position) + line - 1
		column: 0.
]

{ #category : #accessing }
UMRSourceInfo >> sourceLocationForNode: anRBProgramNode [
	file isNil ifTrue:[ ^nil ].

	^ TRSourceLocation
		file: file pathString
		line:(self positionToLine: position + anRBProgramNode start)
		column: 0.
]
