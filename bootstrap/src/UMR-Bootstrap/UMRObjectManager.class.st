Class {
	#name : #UMRObjectManager,
	#superclass : #Object,
	#instVars : [
		'behaviorMap',
		'selectorMap',
		'nilObj'
	],
	#category : #'UMR-Bootstrap-Objects'
}

{ #category : #'instance creation' }
UMRObjectManager class >> new [
	"return an initialized instance"

	^ self basicNew initialize.
]

{ #category : #'adding & removing' }
UMRObjectManager >> defineClass: classDef obj: classObj [
	behaviorMap at: classDef put: classObj
]

{ #category : #'adding & removing' }
UMRObjectManager >> defineNilObj: nilObjArg [
	nilObj := nilObjArg
]

{ #category : #'adding & removing' }
UMRObjectManager >> defineSelector: selector obj: selectorObj [
	selectorMap at: selector put: selectorObj
]

{ #category : #initialization }
UMRObjectManager >> initialize [
	super initialize.
	behaviorMap := Dictionary new.
	selectorMap := Dictionary new.
]

{ #category : #lookup }
UMRObjectManager >> lookupClass: classDef [
	^ self lookupClass: classDef ifAbsent: [ self error:'Missing class object for class ', classDef name ]
]

{ #category : #lookup }
UMRObjectManager >> lookupClass: classDef ifAbsent: block [
	self assert: classDef isBehavior.

	^ behaviorMap at: classDef ifAbsent: block
]

{ #category : #lookup }
UMRObjectManager >> lookupNil [
	^ nilObj
]

{ #category : #lookup }
UMRObjectManager >> lookupSelector: selector [
	^ selectorMap at: selector ifAbsent: [ self error:'Missing selector object for ', selector printString ]
]
