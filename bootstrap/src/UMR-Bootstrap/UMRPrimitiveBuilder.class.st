Class {
	#name : #UMRPrimitiveBuilder,
	#superclass : #TRILFunctionBuilder,
	#instVars : [
		'LastMethod',
		'LastMethodSourceInfo'
	],
	#category : #'UMR-Bootstrap-Primitives'
}

{ #category : #compilation }
UMRPrimitiveBuilder >> build [
	self subclassResponsibility
]

{ #category : #'building-private' }
UMRPrimitiveBuilder >> build: opcode arguments: arguments [
	| buildMethod buildContext sourceInfo |

	buildContext := thisContext sender sender.
	buildMethod := buildContext method.

	buildContext notNil ifTrue: [
		"Cache last used source info."
		LastMethod ~~ buildMethod ifTrue: [
			LastMethod := buildMethod.
			LastMethodSourceInfo := LastMethod sourceInfo
		].
		sourceInfo := LastMethodSourceInfo.
		"Source info may be nil if method is currently in the image only"
		sourceInfo notNil ifTrue: [
			self location: (sourceInfo sourceLocationForContext: buildContext).
		].
	] ifFalse: [
		self location: nil.
	].
	^ super build: opcode arguments: arguments.
]

{ #category : #initialization }
UMRPrimitiveBuilder >> initializeWithCompilation: aTRCompilation block: aTRILBlock [
	| buildMethod sourceInfo |

	super initializeWithCompilation: aTRCompilation block: aTRILBlock.

	buildMethod := self class >> #build.
	"Cache last used source info."
	LastMethod ~~ buildMethod ifTrue: [
		LastMethod := buildMethod.
		LastMethodSourceInfo := LastMethod sourceInfo
	].
	sourceInfo := LastMethodSourceInfo.

	self location: (sourceInfo sourceLocationForLine: 1).
]

{ #category : #accessing }
UMRPrimitiveBuilder >> name [
	^ self subclassResponsibility
]

{ #category : #'building-blocks' }
UMRPrimitiveBuilder >> orphanClass [
	"Return the builder class for orphan builder -
	 method #orphan will return an instance of this class.

	 See #orphan."

	^ self class
]
