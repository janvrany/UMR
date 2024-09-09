Class {
	#name : #UMRLineTrackingReadStream,
	#superclass : #Object,
	#instVars : [
		'stream',
		'lineEnds'
	],
	#classVars : [
		'LineEndChars'
	],
	#category : #'UMR-ProgramDefinition-Utils-Source'
}

{ #category : #initialization }
UMRLineTrackingReadStream class >> initialize [

	LineEndChars := String
						with: (Character codePoint: 16rA)
						with: (Character codePoint: 16rD).
]

{ #category : #'instance creation' }
UMRLineTrackingReadStream class >> new [
	self shouldNotImplement "Use `on:` instead"
]

{ #category : #'instance creation' }
UMRLineTrackingReadStream class >> on: aStream [
	^ self basicNew initializeWithStream: aStream.
]

{ #category : #streaming }
UMRLineTrackingReadStream >> atEnd [
	^ stream atEnd
]

{ #category : #accessing }
UMRLineTrackingReadStream >> fileName [
	^ stream fileName
]

{ #category : #initialization }
UMRLineTrackingReadStream >> initializeWithStream: aStream [
	self assert: aStream isReadable.
	self assert: aStream isWritable not.
	self assert: aStream position == 0.

	stream := aStream.
	lineEnds := OrderedCollection new.
]

{ #category : #accessing }
UMRLineTrackingReadStream >> lineEnds [
	^ lineEnds
]

{ #category : #streaming }
UMRLineTrackingReadStream >> nextChunk [
	| pos chunk crlfPos |

	pos := stream position.
	chunk := stream nextChunk.
	crlfPos := 1.

	[
		crlfPos := chunk indexOfAnyOf: LineEndChars startingAt: crlfPos.
		crlfPos ~~ 0
	] whileTrue: [
		| c |

		c := chunk at: crlfPos.
		(c codePoint == 13"CR") ifTrue: [
			crlfPos < chunk size ifTrue:[c := chunk at: crlfPos + 1].
			(c codePoint == 10"LF") ifTrue: [
				crlfPos := crlfPos + 1.
			].
			lineEnds add: pos + crlfPos - 1.
		] ifFalse: [
			(c codePoint == 10"LF") ifTrue: [
				lineEnds add: pos + crlfPos - 1.
			].
		].
		crlfPos := crlfPos + 1.
	].
	^ chunk
]

{ #category : #accessing }
UMRLineTrackingReadStream >> position [
	^ stream position
]

{ #category : #accessing }
UMRLineTrackingReadStream >> positionToLine: position [
	"Translate position in stream to line number"

	"We can do better using binary search..."
	lineEnds withIndexDo: [:lineEndPos :lineNo |
		position < lineEndPos ifTrue: [
			^ lineNo
		].
	].
	^ lineEnds size + 1
]

{ #category : #streaming }
UMRLineTrackingReadStream >> skipSeparators [
	| c |

	[
		c := stream peek.
		c notNil and: [ c isSeparator ]
	] whileTrue: [
		stream next.
		(c codePoint == 13"CR") ifTrue: [
			c := stream peek.
			(c codePoint == 10"LF") ifTrue: [
				stream next.
			].
			lineEnds add: stream position - 1.
		] ifFalse: [
			(c codePoint == 10"LF") ifTrue: [
				lineEnds add: stream position - 1.
			].
		].
	].
]
