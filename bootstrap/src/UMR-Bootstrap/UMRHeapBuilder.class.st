Class {
	#name : #UMRHeapBuilder,
	#superclass : #UMRBuilder,
	#instVars : [
		'objects',
		'selectorMap',
		'rtNilDef',
		'rtClassDef',
		'rtArrayDef',
		'rtSelectorDef',
		'environment'
	],
	#category : #'UMR-Bootstrap-Builders'
}

{ #category : #building }
UMRHeapBuilder >> build [
	self genesis
]

{ #category : #genesis }
UMRHeapBuilder >> findRuntimeClasses [
	| rtPackage |

	rtPackage := RGPackage named: '<runtime objects>' parent: environment.
	rtNilDef := RGClass named: '<nil>' parent: environment.
	rtNilDef
		superclass: nil;
		metaclass: rtNilDef;
		package: rtPackage;
		layout: (RGFixedLayout parent: rtNilDef);
		instanceVariables: #().

	rtClassDef := RGClass named: '<class>' parent: environment.
	rtClassDef
		superclass: nil;
		metaclass: rtNilDef;
		package: rtPackage;
		layout: (RGFixedLayout parent: rtNilDef);
		instanceVariables: #( #format #size #superclass #methods ).

	rtArrayDef := RGClass named: '<array>' parent: environment.
	rtArrayDef
		superclass: nil;
		metaclass: rtNilDef;
		package: rtPackage;
		layout: (RGVariableLayout parent: rtNilDef);
		instanceVariables: #().

	rtSelectorDef := RGClass named: '<selector>' parent: environment.
	rtSelectorDef
		superclass: nil;
		metaclass: rtNilDef;
		package: rtPackage;
		layout: (RGByteLayout parent: rtNilDef);
		instanceVariables: #().

]

{ #category : #genesis }
UMRHeapBuilder >> genesis [
	"Create the world (should take less than 6 days)"

	"
	This is named 'genesis' to remind us those who had done this
	(and much more) before us. Namely SELF people. 

	I (JV) would like to use this opportunity and point you to

	https://github.com/russellallen/self/blob/2bcf2c4cab23f52bf68ac4f617020e748699a548/vm/src/any/memory/universe.cpp#L79
	"
	self findRuntimeClasses




	"
	| placeholder |

	placeholder := Object new.
	objects add: placeholder.

	nilObj := self makeInstanceOf: #UndefinedObject.
	trueObj := self makeInstanceOf: #True.
	falseObj := self makeInstanceOf: #False.
	specialObjectsArrayObj := self makeInstanceOf: #Array size: 5.

	objects remove: specialObjectsArrayObj.
	objects replaceAll: placeholder with: specialObjectsArrayObj.

	self makeClasses.
	self makeTOC.

	specialObjectsArrayObj at: 1 put: nilObj.
	specialObjectsArrayObj at: 2 put: trueObj.
	specialObjectsArrayObj at: 3 put: falseObj.
	specialObjectsArrayObj at: 4 put: (classDef2ClassObjMap at: (kernel at: #SmallInteger)).
	specialObjectsArrayObj at: 5 put: (self makeSymbol: #evaluate).

	self fixHierarchy.
	self fixBehaviors.
	"
	"Finally, make sure everythinbg is all right"
	"
	self validate
	"
]

{ #category : #initialization }
UMRHeapBuilder >> initializeWithProgram: programArg runtime: runtimeArg [
	super initializeWithProgram: programArg runtime: runtimeArg.
	objects := OrderedCollection new.
	selectorMap := Dictionary new.
]

{ #category : #utilities }
UMRHeapBuilder >> makeInstanceOf: classDef [
	^ self makeInstanceOf: classDef size: 0

]

{ #category : #utilities }
UMRHeapBuilder >> makeInstanceOf: clsDef size: size [

	"Allocate, nil-out and return an instance (as ObjectMap) of class `className`.
	`size` is the size of indexed part of the object (i.e., shall not include 
	named slots). For non-variable objects, must be 0.

	Slots of the object is set to nilObj (for pointer-objects) or to 0 (byte-objects).
	Smallinteger instances are set to 0.
	"
	| obj  |



	self assert: clsDef notNil.

	obj := UMRHeapObject new: clsDef size: size.
	obj isBytes ifTrue:[
			1 to: obj size do:[:i | obj at: i put: 0 ].
	] ifFalse:[
			obj isPointers ifTrue:[
					| numSlots null |

					numSlots := obj behaviorDef instSize.
					null := self nilObj.
					1 to: obj size do:[:i |                         
							i <= numSlots ifTrue:[
									obj slotAt: i put: null.                
							] ifFalse:[
									obj at: i - numSlots put: null.
							]
					]
			] ifFalse:[
					self assert: obj isImmediate.
					obj value: 0.
			]
	].
	obj isImmediate ifFalse:[
			objects add: obj.
	].
	^obj
]
