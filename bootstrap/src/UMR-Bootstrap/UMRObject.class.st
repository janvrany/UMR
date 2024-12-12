Class {
	#name : #UMRObject,
	#superclass : #Object,
	#instVars : [
		'classDef',
		'oop',
		'class',
		'slots',
		'bytes',
		'value'
	],
	#pools : [
		'TRDataTypes'
	],
	#category : #'UMR-Bootstrap-Objects'
}

{ #category : #'instance creation' }
UMRObject class >> new: classDef size: size [
	^ self basicNew initializeWithClass: classDef size: size
]

{ #category : #converting }
UMRObject >> asAcDSLOperand [
	^ AcDSLSymbol value: self oop
]

{ #category : #accessing }
UMRObject >> byteAt: i [
	"Return byte value at given index, starting with 1."

	self assert: classDef isBytes.
	self assert: (i between: 1 and: bytes size).

	^bytes at: classDef instSize
]

{ #category : #accessing }
UMRObject >> byteAt: i put: b [
	"Set byte value at given index, starting with 1."

	self assert: classDef isBytes.
	self assert: (i between: 1 and: bytes size).
	self assert: (b between: 0 and: 255).

	bytes at: i put: b
]

{ #category : #accessing }
UMRObject >> bytes [
	^ bytes
]

{ #category : #accessing }
UMRObject >> classDef [
	^ classDef
]

{ #category : #accessing }
UMRObject >> classSlot [
	^ class
]

{ #category : #accessing }
UMRObject >> classSlotPut: v [
	class := v.
]

{ #category : #accessing }
UMRObject >> indexedSlotAt: i [
	"Return indexed slot value at given index, starting with 1. This CANNOT be
	 used for accessing named slots (aka, instance variables), to access
	 them use #namedSlotAt:"

	self assert: classDef isPointers.
	self assert: (i between: 1 and: slots size - classDef instSize).

	^slots at: classDef instSize + i
]

{ #category : #accessing }
UMRObject >> indexedSlotAt: i put: v [
	"Set indexed slot value at given index, starting with 1. This CANNOT be
	 used for setting named slots (aka, instance variables), to set
	 them use #namedSlotAt:put:"

	self assert: classDef isPointers.
	self assert: (i between: 1 and: slots size - classDef instSize).
	self assert: (v isKindOf: self class).

	slots at: classDef instSize + i put: v.
]

{ #category : #initialization }
UMRObject >> initializeWithClass: classDefArg size: size [
	self assert: (classDefArg isVariable or:[size == 0]).

	classDef := classDefArg.
	classDef isPointers ifTrue: [
		slots := Array new: classDef instSize + size.
		bytes := #[]
	] ifFalse: [
	classDef isBytes ifTrue: [
		slots := Array new: classDef instSize.
		bytes := ByteArray new: size.
	]].
]

{ #category : #accessing }
UMRObject >> label: aString [
	self assert: aString isString.

	oop := TRStaticSymbol name: aString type: Address.
]

{ #category : #accessing }
UMRObject >> namedSlot: name [
	| i |

	i := classDef allInstVarNames indexOf: name.
	i == 0 ifTrue: [ self error:'No such named slot: ', name ].

	^ self namedSlotAt: i.
]

{ #category : #accessing }
UMRObject >> namedSlot: name put: v [
	| i |

	i := classDef allInstVarNames indexOf: name.
	i == 0 ifTrue: [ self error:'No such named slot: ', name ].

	self namedSlotAt: i put: v
]

{ #category : #accessing }
UMRObject >> namedSlotAt: i [
	"Get named slot (instvar) at given index `i`, starting with 1. This CANNOT be used
	 for accessing indexed slots  (i.e., variable part of array-like objects),
	 to access them use #indexedSlotAt:"

	self assert: (i between: 1 and: classDef instSize).

	^slots at: i
]

{ #category : #accessing }
UMRObject >> namedSlotAt: i put: v [
	"Set named slot (instvar) at given index `i`, starting with 1. This CANNOT be used
	 for setting indexed slots  (i.e., variable part of array-like objects),
	 to set them use #indexedSlotAt:put:"

	self assert: (i between: 1 and: classDef instSize).
	self assert: (v isKindOf: self class).

	slots at: i put: v
]

{ #category : #accessing }
UMRObject >> oop [
	self assert:(oop notNil or: [classDef isImmediateClass]).

	^ oop ? value
]

{ #category : #printing }
UMRObject >> printOn: aStream [
	classDef isImmediateClass ifTrue: [
		value printOn: aStream.
		^ self.
	].
	classDef isMetaclass ifTrue: [
		| nonMeta |

		nonMeta := classDef propertyNamed: #creator.
		nonMeta notNil ifTrue: [
			aStream nextPutAll: nonMeta name.
		] ifFalse: [
			aStream nextPutAll: classDef name.
		].
		^ self.
	].
	aStream nextPutAll: 'a '.
	aStream nextPutAll: classDef name.
]

{ #category : #accessing }
UMRObject >> slots [
	^ slots
]

{ #category : #accessing }
UMRObject >> value [
	"Get value if an immediate object"

	self assert: classDef isImmediateClass.

	^ value
]

{ #category : #accessing }
UMRObject >> value: v [
	"Set value if an immediate object"

	self assert: classDef isImmediateClass.
	value := v.
]
