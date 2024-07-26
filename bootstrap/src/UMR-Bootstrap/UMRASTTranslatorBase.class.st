"
Base superclass for `UMRASTTranslator`.

This class exists to ""fix"" a design issue with original `OCASTTranslator`:
it has two subclasses that specialize translation depending whether a value
is needed (`OCASTTranslatorForValue`) or not (`OCASTTranslatorForEffect`).

While this may seem as a good idea, IMO it isn't. It makes customization
of translators much harder as now once has to customize three classes
and duplicate quite a bit of a code.

This classes ""fixes"" this issue by having only one translator class and
- when needed - conditionally compile some code (see senders `#isForEffect`
and `#isForValue`)

"
Class {
	#name : #UMRASTTranslatorBase,
	#superclass : #OCASTTranslator,
	#category : #'UMR-Bootstrap-Compiler'
}

{ #category : #queries }
UMRASTTranslatorBase class >> isAbstract [
	"Return if this class is an abstract class.
	 True is returned here for myself only; false for subclasses.
	 Abstract subclasses must redefine this again."

	^ self == UMRASTTranslatorBase.
]

{ #category : #initialization }
UMRASTTranslatorBase >> as: similarClass [
	self class == similarClass ifTrue:[
		^ self copy 
	] ifFalse:[
		^ super as: similarClass.
	]
]

{ #category : #initialization }
UMRASTTranslatorBase >> classForEffect [
	^self class
]

{ #category : #initialization }
UMRASTTranslatorBase >> classForValue [
	^self class
]

{ #category : #'inline messages' }
UMRASTTranslatorBase >> emitAnd: aMessageNode [
	
	super emitAnd: aMessageNode.
	self isForEffect ifTrue: [
		methodBuilder popTop.
	].
]

{ #category : #'inline messages' }
UMRASTTranslatorBase >> emitIfFalse: aMessageNode [
	self isForValue ifTrue: [ 
		self visitNode: aMessageNode receiver.
		methodBuilder jumpAheadTo: #false if: false.
		methodBuilder pushLiteral: nil.
		methodBuilder jumpAheadTo: #end.
		methodBuilder jumpAheadTarget: #false.
		self visitInlinedBlockNode: aMessageNode arguments first.
	methodBuilder jumpAheadTarget: #end.    
	] ifFalse: [ 
		self assert: self isForEffect.
		self forValue visitNode: aMessageNode receiver.
		methodBuilder jumpAheadTo: #else if: true.
		self visitInlinedBlockNode: aMessageNode arguments first.
		methodBuilder jumpAheadTarget: #else.   
	].
]

{ #category : #'inline messages' }
UMRASTTranslatorBase >> emitIfNotNil: aMessageNode [
	| args |

	valueTranslator visitNode: aMessageNode receiver.
	args := aMessageNode arguments.
	args first arguments ifNotEmpty: [ args first arguments first binding emitStore: methodBuilder ].   

	self isForValue ifTrue: [ 
		methodBuilder pushDup.
		methodBuilder pushLiteral: nil.
		methodBuilder send: #==.
		methodBuilder jumpAheadTo: #end if: true.
		methodBuilder popTop.
		self visitInlinedBlockNode: args first.
		methodBuilder jumpAheadTarget: #end. 
	] ifFalse: [ 

		methodBuilder pushLiteral: nil.
		methodBuilder send: #==.
		methodBuilder jumpAheadTo: #end if: true.
		self visitInlinedBlockNode: args first.
		methodBuilder jumpAheadTarget: #end.   
	].
]

{ #category : #'inline messages' }
UMRASTTranslatorBase >> emitIfTrue: aMessageNode [
	self isForValue ifTrue: [ 
		self visitNode: aMessageNode receiver.
		methodBuilder jumpAheadTo: #else if: false.
		self visitInlinedBlockNode:  aMessageNode arguments first.
		methodBuilder jumpAheadTo: #end.
		methodBuilder jumpAheadTarget: #else.
		methodBuilder pushLiteral: nil.
		methodBuilder jumpAheadTarget: #end.   
	] ifFalse: [ 
		self assert: self isForEffect.
		self forValue visitNode: aMessageNode receiver.
		methodBuilder jumpAheadTo: #else if: false.         
		self visitInlinedBlockNode: aMessageNode arguments first.
		methodBuilder jumpAheadTarget: #else.      
	].
]

{ #category : #'inline messages' }
UMRASTTranslatorBase >> emitMessageNode: aMessageNode [
	
	super emitMessageNode: aMessageNode.
	self isForEffect ifTrue: [
		methodBuilder popTop.
	].
]

{ #category : #'inline messages' }
UMRASTTranslatorBase >> emitOr: aMessageNode [

	super emitOr: aMessageNode.
	self isForEffect ifTrue: [
		methodBuilder popTop.
	].
]

{ #category : #'inline messages' }
UMRASTTranslatorBase >> emitWhileFalse: aMessageNode [

	super emitWhileFalse: aMessageNode.
	self isForValue ifTrue: [
		methodBuilder pushLiteral: nil.
	]
]

{ #category : #'inline messages' }
UMRASTTranslatorBase >> emitWhileTrue: aMessageNode [

	super emitWhileTrue: aMessageNode.
	self isForValue ifTrue: [
		methodBuilder pushLiteral: nil.
	]
]

{ #category : #accessing }
UMRASTTranslatorBase >> forEffect [
	^ effectTranslator
]

{ #category : #accessing }
UMRASTTranslatorBase >> forValue [
	^ valueTranslator
]

{ #category : #initialization }
UMRASTTranslatorBase >> initialize [ 
	self subclassResponsibility 
]

{ #category : #testing }
UMRASTTranslatorBase >> isForEffect [
	^self == effectTranslator
]

{ #category : #testing }
UMRASTTranslatorBase >> isForValue [
	^self == valueTranslator
]

{ #category : #'visitor-double dispatching' }
UMRASTTranslatorBase >> visitArrayNode: anArrayNode [ 
	"An arrayNode may have side effect, for example: '{self foo}'. So we cannot just generate nothing for this node."

	super visitArrayNode: anArrayNode.
	self isForEffect ifTrue: [
		methodBuilder popTop.
	].
]

{ #category : #'visitor-double dispatching' }
UMRASTTranslatorBase >> visitAssignmentNode: anAssignmentNode [ 

	super visitAssignmentNode: anAssignmentNode .
	self isForEffect ifTrue: [
		methodBuilder popTop.
	].
]

{ #category : #'visitor-double dispatching' }
UMRASTTranslatorBase >> visitBlockNode: aBlockNode [
	self isForValue ifTrue: [ 
		super visitBlockNode: aBlockNode
	] ifFalse: [ 
		"A block has no side effect, so a block translated for effect just doesn't generate anything" 
	].
]

{ #category : #'visitor-double dispatching' }
UMRASTTranslatorBase >> visitLiteralArrayNode: aLiteralNode [
	super visitLiteralArrayNode: aLiteralNode.
	self isForEffect ifTrue: [
		methodBuilder popTop.
	].
]

{ #category : #'visitor-double dispatching' }
UMRASTTranslatorBase >> visitLiteralNode: aLiteralNode [
	super visitLiteralNode: aLiteralNode.
	self isForEffect ifTrue: [
		methodBuilder popTop.
	].
]

{ #category : #'visitor-double dispatching' }
UMRASTTranslatorBase >> visitParseErrorNode: anErrorNode [  

	super visitParseErrorNode: anErrorNode.
	self isForEffect ifTrue: [
		methodBuilder popTop.
	].
]

{ #category : #'visitor-double dispatching' }
UMRASTTranslatorBase >> visitSequenceNode: aSequenceNode [ 
	| statements |

	statements := aSequenceNode statements.
	statements isEmpty ifTrue: [ 
		methodBuilder pushLiteral: nil.
	] ifFalse: [ 
		1 to: statements size - 1 do: [:i | 
			self forEffect visitNode: (statements at: i)
		].
		self forValue visitNode: statements last.
	].

	self isForValue ifTrue: [ 
		methodBuilder popTop
	].
]

{ #category : #'visitor-double dispatching' }
UMRASTTranslatorBase >> visitVariableNode: aVariableNode [
	super visitVariableNode: aVariableNode.
	self isForEffect ifTrue: [
		methodBuilder popTop.
	].
]
