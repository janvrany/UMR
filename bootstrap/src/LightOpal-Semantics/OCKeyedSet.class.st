"
Like Set except a key of every element is used for hashing and searching instead of the element itself.  keyBlock gets the key of an element.
"
Class {
	#name : #OCKeyedSet,
	#superclass : #Object,
	#instVars : [
		'values',
		'keyBlock'
	],
	#category : #'LightOpal-Semantics'
}

{ #category : #'instance creation' }
OCKeyedSet class >> keyBlock: oneArgBlock [
 	"Create a new KeySet whose way to access an element's key is by executing oneArgBlock on the element"

 	^ self new keyBlock: oneArgBlock
]

{ #category : #'instance creation' }
OCKeyedSet class >> new [
	^ self new: 7
]

{ #category : #'instance creation' }
OCKeyedSet class >> new: capacity [
	^ self basicNew initialize: capacity
]

{ #category : #'adding & removing' }
OCKeyedSet >> add: value [
	values at: (keyBlock value: value) put: value.
	^ value
]

{ #category : #accessing }
OCKeyedSet >> at: key ifAbsent: block [
	^ values at: key ifAbsent: block
]

{ #category : #accessing }
OCKeyedSet >> at: key ifPresent: presentBlock [
	| value |

	value := self at: key ifAbsent: [ ^ nil ].
	^ presentBlock value: value
]

{ #category : #accessing }
OCKeyedSet >> at: key ifPresent: presentBlock ifAbsent: absentBlock [
	| value |

	value := self at: key ifAbsent: [ ^ absentBlock value ].
	^ presentBlock value: value
]

{ #category : #initialization }
OCKeyedSet >> initialize: n [
		values := SmallDictionary new: n.
		keyBlock := [:element | element key].
]

{ #category : #initialize }
OCKeyedSet >> keyBlock: oneArgBlock [
 	"When evaluated return the key of the argument which will be an element of the set"

 	keyBlock := oneArgBlock
]

{ #category : #accessing }
OCKeyedSet >> size [
	^ values size
]
