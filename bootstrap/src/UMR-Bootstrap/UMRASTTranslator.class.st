Class {
	#name : #UMRASTTranslator,
	#superclass : #UMRASTTranslatorBase,
	#instVars : [
		'compilation'
	],
	#pools : [
		'TRDataTypes'
	],
	#category : #'UMR-Bootstrap-Compiler'
}

{ #category : #'instance creation' }
UMRASTTranslator class >> forCompilation: aTRCompilation [
	^ self basicNew initializeWithCompilation: aTRCompilation
]

{ #category : #'instance creation' }
UMRASTTranslator class >> new [
	self shouldNotImplement. "Use #forCompilation:"
]

{ #category : #initialization }
UMRASTTranslator >> initialize [
	self shouldNotImplement 
]

{ #category : #initialization }
UMRASTTranslator >> initializeWithCompilation: aTRCompilation [
	compilation := aTRCompilation.
	methodBuilder := UMRMethodBuilder forCompilation: compilation.
	effectTranslator := self copy.
	valueTranslator := self copy.
	effectTranslator instVarNamed: #effectTranslator put: effectTranslator.
	effectTranslator instVarNamed: #valueTranslator put: valueTranslator.
	valueTranslator instVarNamed: #effectTranslator put: effectTranslator.
	valueTranslator instVarNamed: #valueTranslator put: valueTranslator.
]

{ #category : #'visitor-double dispatching' }
UMRASTTranslator >> visitMethodNode: node [
	methodBuilder defineSelf.
	methodBuilder defineName: node compilationContext method printString.
	methodBuilder defineTemps: node scope tempVars.


	node scope tempVector ifNotEmpty: [
		methodBuilder 
			createTempVectorNamed: node scope tempVectorName 
			withVars: (node scope tempVector collect: [:each| each name]) asArray.
	].

	node pragmas do: [:pragma |
		self visitNode: pragma.
		pragma isPrimitive ifTrue: [
			"BOGUS: no support for primitive failure!"
			^ self
		].
	].
	self forEffect visitNode: node body.

	node body lastIsReturn ifFalse: [
		methodBuilder pushReceiver; returnTop
	]
]

{ #category : #'visitor-double dispatching' }
UMRASTTranslator >> visitNode: node [
	| retval |

	methodBuilder pushNode: node.
	retval := node acceptVisitor: self.
	methodBuilder popNode.
	^ retval
]

{ #category : #'visitor-double dispatching' }
UMRASTTranslator >> visitPragmaNode: aPragmaNode [
	aPragmaNode isPrimitive ifTrue: [
		self assert: aPragmaNode isPrimitiveError not description: 'prim errors not supported'.
		methodBuilder prim: (aPragmaNode argumentAt: #primitive:) value.
	].
]
