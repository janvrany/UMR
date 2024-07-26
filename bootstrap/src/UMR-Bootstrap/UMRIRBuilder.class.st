Class {
	#name : #UMRIRBuilder,
	#superclass : #Object,
	#instVars : [
		'compilation',
		'entry',
		'current',
		'blocks'
	],
	#pools : [
		'TRDataTypes'
	],
	#category : #'UMR-Bootstrap-Compiler'
}

{ #category : #'instance creation' }
UMRIRBuilder class >> forCompilation: aTRCompilation [
	^ self basicNew initializeWithCompilation: aTRCompilation
]

{ #category : #'instance creation' }
UMRIRBuilder class >> new [
	self shouldNotImplement. "Use #forCompilation:"
]

{ #category : #symbols }
UMRIRBuilder >> defineName: name [
	entry defineName: name type: Address
]

{ #category : #symbols }
UMRIRBuilder >> defineSelf [
	entry defineParameter: 'self' type: Address
]

{ #category : #symbols }
UMRIRBuilder >> defineTemp: temp [
	temp isArg ifTrue: [ 
		entry defineParameter: temp name type: Address
	] ifFalse: [ 
		entry defineAutomatic: temp name type: Address
	].
]

{ #category : #symbols }
UMRIRBuilder >> defineTemps: temps [
	temps do: [ :temp | self defineTemp: temp ]
]

{ #category : #initialization }
UMRIRBuilder >> initializeWithCompilation: aTRCompilation [

	compilation := aTRCompilation.
	entry := current := TRILBytecodeFunctionBuilder forCompilation: compilation.
	entry defineState: TRVMOperandStack new.
]

{ #category : #instructions }
UMRIRBuilder >> popTop [
	current pop
]

{ #category : #instructions }
UMRIRBuilder >> pushLiteral: value [
	value isInteger ifTrue:[
		"TODO, bogus, we need to go through object format class!"
		current push: (current aconst: value << 1 | 1).
		^ self
	].
	self notYetImplemented
]

{ #category : #instructions }
UMRIRBuilder >> returnTop [
	current areturn: { current pop }
]
