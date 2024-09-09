Class {
	#name : #UMRLineTrackingWriteStream,
	#superclass : #Object,
	#instVars : [
		'stream',
		'lineEnds'
	],
	#classVars : [
		'LineEndChars'
	],
	#category : #'UMR-Bootstrap-Utils-Source'
}

{ #category : #initialization }
UMRLineTrackingWriteStream class >> initialize [

	LineEndChars := String
						with: (Character codePoint: 16rA)
						with: (Character codePoint: 16rD).
]

{ #category : #'instance creation' }
UMRLineTrackingWriteStream class >> new [
	self shouldNotImplement "Use `on:` instead"
]

{ #category : #'instance creation' }
UMRLineTrackingWriteStream class >> on: aStream [
	^ self basicNew initializeWithStream: aStream.
]

{ #category : #writing }
UMRLineTrackingWriteStream >> << aCollection [
	self nextPutAll: aCollection.
]

{ #category : #initialization }
UMRLineTrackingWriteStream >> initializeWithStream: aStream [
	self assert: aStream isWritable.
	self assert: aStream isReadable not.
	self assert: aStream position == 0.

	stream := aStream.
	lineEnds := OrderedCollection new.
]

{ #category : #accessing }
UMRLineTrackingWriteStream >> lineEnds [
	^ lineEnds
]

{ #category : #writing }
UMRLineTrackingWriteStream >> nextPutAll: aString [
	| pos crlfPos |

	pos := stream position.
	crlfPos := 1.

	[
		crlfPos := aString indexOfAnyOf: LineEndChars startingAt: crlfPos.
		crlfPos ~~ 0
	] whileTrue: [
		| c |

		c := aString at: crlfPos.
		(c codePoint == 13"CR") ifTrue: [
			crlfPos < aString size ifTrue:[c := aString at: crlfPos + 1].
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
	^ stream nextPutAll: aString
]

{ #category : #accessing }
UMRLineTrackingWriteStream >> position [
	^ stream position
]

{ #category : #accessing }
UMRLineTrackingWriteStream >> positionToLine: position [
	"Translate position in stream to line number"

	"We can do better using binary search..."
	lineEnds withIndexDo: [:lineEndPos :lineNo |
		position < lineEndPos ifTrue: [
			^ lineNo
		].
	].
	^ lineEnds size + 1
]
