Class {
	#name : #UMRMethodBuilder,
	#superclass : #Object,
	#instVars : [
		'compilation',
		'entry',
		'current',
		'nodes',
		'blocks'
	],
	#pools : [
		'TRDataTypes'
	],
	#category : #'UMR-Bootstrap-Compiler'
}

{ #category : #'instance creation' }
UMRMethodBuilder class >> forCompilation: aTRCompilation [
	^ self basicNew initializeWithCompilation: aTRCompilation
]

{ #category : #'instance creation' }
UMRMethodBuilder class >> new [
	self shouldNotImplement. "Use #forCompilation:"
]

{ #category : #primitives }
UMRMethodBuilder >> addPragma: pragma [
	(pragma key == #primitive:) ifTrue: [
		"Do nothing for now"
	].
]

{ #category : #symbols }
UMRMethodBuilder >> defineName: name [
	entry defineName: name type: Address
]

{ #category : #symbols }
UMRMethodBuilder >> defineSelf [
	entry defineParameter: 'self' type: Address
]

{ #category : #symbols }
UMRMethodBuilder >> defineTemp: temp [
	temp isArg ifTrue: [
		entry defineParameter: temp name type: Address
	] ifFalse: [
		entry defineAutomatic: temp name type: Address
	].
]

{ #category : #symbols }
UMRMethodBuilder >> defineTemps: temps [
	temps do: [ :temp | self defineTemp: temp ]
]

{ #category : #initialization }
UMRMethodBuilder >> initializeWithCompilation: aTRCompilation [

	compilation := aTRCompilation.
	entry := current := TRILBytecodeFunctionBuilder forCompilation: compilation.
	entry defineState: TRVMOperandStack new.
	entry defineFunction: 'mbind' type: Address.
	entry defineFunction: 'meval' type: Address. "<-- this is only a prototype, never actually called"

	nodes := OrderedCollection new.
]

{ #category : #locations }
UMRMethodBuilder >> popNode [
	self assert: nodes size > 0.

	nodes removeLast.
]

{ #category : #instructions }
UMRMethodBuilder >> popTop [
	current pop
]

{ #category : #instructions }
UMRMethodBuilder >> pushLiteral: value [
	| valueObj |

	value isInteger ifTrue:[
		"TODO, bogus, we need to go through object format class!"
		current push: (current aconst: value << 1 | 1).
		^ self
	].
	value isNil ifTrue: [
		valueObj := compilation objectManager lookupNil.
	] ifFalse: [
		self notYetImplemented.
	].

	current defineStatic: valueObj oop name type: Void.
	current push: (current loadaddr: valueObj oop name).
]

{ #category : #instructions }
UMRMethodBuilder >> pushLiteralVariable: assoc [
	| classObj |

	self assert:(assoc isKindOf: Association).
	self assert:(assoc value isClass).

	classObj := compilation objectManager lookupClass: assoc value.

	current defineStatic: classObj oop name type: Void.
	current push: (current loadaddr: classObj oop name).
]

{ #category : #locations }
UMRMethodBuilder >> pushNode: anRBProgramNode [
	| sourceInfo |

	self assert: (nodes notEmpty or: [ anRBProgramNode isMethod ]).
	nodes add: anRBProgramNode.

	sourceInfo := nodes first compilationContext sourceInfo.
	current location: (sourceInfo sourceLocationForNode: anRBProgramNode)
]

{ #category : #instructions }
UMRMethodBuilder >> pushReceiver [
	current push: (current aload: 'self')
]

{ #category : #instructions }
UMRMethodBuilder >> returnTop [
	current areturn: { current pop }
]

{ #category : #instructions }
UMRMethodBuilder >> send: selector [
	| selectorObj selectorOOP receiverOOP argumentOOPs codePtr retvalOOP |

	selectorObj := compilation objectManager lookupSelector: selector.
	current defineStatic: selectorObj oop name type: Void.
	selectorOOP := current loadaddr: selectorObj oop name.

	argumentOOPs := ((1 to: selector numArgs) collect: [ :i | current pop ]) reverse.
	receiverOOP := current pop.


	codePtr := current acall: { receiverOOP . selectorOOP . current iconst: selector numArgs . 'mbind' }.

	retvalOOP := current acalli: { codePtr . receiverOOP } , argumentOOPs , { 'meval' }.

	current push: retvalOOP.
]
