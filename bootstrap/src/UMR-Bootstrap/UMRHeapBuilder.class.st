Class {
	#name : #UMRHeapBuilder,
	#superclass : #UMRBuilder,
	#instVars : [
		'environment',
		'objs',
		'objNil'
	],
	#pools : [
		'TRDataTypes'
	],
	#category : #'UMR-Bootstrap-Builders'
}

{ #category : #building }
UMRHeapBuilder >> build [
	self genesis
]

{ #category : #genesis }
UMRHeapBuilder >> fixClasses [
	objs do: [:obj |
		obj classSlotPut: (bootstrap objectManager lookupClass: obj classDef)
	].
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

	self initEnvironment.
	self makeNil.
	self makeClasses.

	self fixClasses.


	"
	| placeholder |

	placeholder := Object new.
	objects add: placeholder.

	nilObj :=
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
	"
	self halt.
	"
]

{ #category : #genesis }
UMRHeapBuilder >> initEnvironment [
	"Create a 'root' environment (module) containing the program and
	 core classes. This simplifies the rest of the building process."

	| corePackage nilClass arrayClass smallIntegerClass compiledCodeClass selectorClass |

	"Now, create core classes."
	corePackage := RGPackage named: 'core' parent: environment.

	nilClass := environment ensureClassNamed: #UndefinedObject.
	nilClass
		superclass: nil;
		layout: (RGFixedLayout parent: nilClass);
		instanceVariables: #();
		package: corePackage.
	nilClass
		metaclass: (environment ensureClassNamed: #'UndefinedObject class').
	(nilClass metaclass)
		superclass: nil;
		layout: (RGFixedLayout parent: nilClass metaclass);
		instanceVariables: #( 'structure' 'instanceMD' 'instVarCount' 'superclass' ).
	nilClass metaclass metaclass: nilClass metaclass.

	arrayClass := environment ensureClassNamed: #Array.
	arrayClass
		superclass: nil;
		layout: (RGVariableLayout parent: arrayClass);
		instanceVariables: #();
		package: corePackage.
	arrayClass metaclass: (environment ensureClassNamed: #'Array class').
	(arrayClass metaclass)
		superclass: nil;
		layout: (RGFixedLayout parent: arrayClass metaclass);
		instanceVariables: #( 'structure' 'instanceMD' 'instVarCount' 'superclass' ).
	arrayClass metaclass metaclass: arrayClass metaclass.
	 "MethodDictionary is an alias for an Array"
	(environment ensureImportNamed: #MethodDictionary) behavior: arrayClass.

	smallIntegerClass := environment ensureClassNamed: #SmallInteger.
	smallIntegerClass
		superclass: nil;
		layout: (RGImmediateLayout parent: smallIntegerClass);
		instanceVariables: #();
		package: corePackage.
	smallIntegerClass
		metaclass: (environment ensureClassNamed: #'SmallInteger class').
	(smallIntegerClass metaclass)
		superclass: nil;
		layout: (RGFixedLayout parent: smallIntegerClass metaclass);
		instanceVariables: #( 'structure' 'instanceMD' 'instVarCount' 'superclass' ).
	smallIntegerClass metaclass metaclass: smallIntegerClass metaclass.

	compiledCodeClass := environment ensureClassNamed: #CompiledCode.
	compiledCodeClass
		superclass: nil;
		layout: (RGFixedLayout parent: compiledCodeClass);
		instanceVariables: #( #literalFrame #code );
		package: corePackage.
	compiledCodeClass
		metaclass: (environment ensureClassNamed: #'CompiledCode class').
	(compiledCodeClass metaclass)
		superclass: nil;
		layout: (RGFixedLayout parent: compiledCodeClass metaclass);
		instanceVariables: #( 'structure' 'instanceMD' 'instVarCount' 'superclass' ).
	compiledCodeClass metaclass metaclass: compiledCodeClass metaclass.
	 "CompiledMethod is an alias for an CompiledCode"
	(environment ensureImportNamed: #CompiledMethod)
		behavior: compiledCodeClass.
	 "CompiledMethod is an alias for an CompiledBlock"
	(environment ensureImportNamed: #CompiledBlock)
		behavior: compiledCodeClass.

	selectorClass := environment ensureClassNamed: #Selector.
	selectorClass
		superclass: nil;
		layout: (RGFixedLayout parent: nilClass);
		instanceVariables: #();
		package: corePackage.
	selectorClass
		metaclass: (environment ensureClassNamed: #'Selector class').
	(selectorClass metaclass)
		superclass: nil;
		layout: (RGFixedLayout parent: selectorClass metaclass);
		instanceVariables: #( 'structure' 'instanceMD' 'instVarCount' 'superclass' ).
	selectorClass metaclass metaclass: selectorClass metaclass.

	environment clean
]

{ #category : #initialization }
UMRHeapBuilder >> initializeWithBootstrap: anUMRBoostrap [
	super initializeWithBootstrap: anUMRBoostrap.
	objs := OrderedCollection new.
	environment := bootstrap environment.
]

{ #category : #genesis }
UMRHeapBuilder >> makeBehavior: behaviorDef [
	"Create a behavior object (either class or metaclass) and return it."

	| mdObj behaviorObj |

	behaviorDef metaclass instSize >= 4.

	mdObj := self makeInstanceOf: (environment lookupClass: #MethodDictionary) size: behaviorDef methods size * 2.
	mdObj label: 'vmt_' , behaviorDef name.
	1 to: behaviorDef methods size do: [:index |
		| methodDef methodObj selectorObj |

		methodDef := behaviorDef methods at: index.
		methodObj := self makeCompiledMethod: methodDef.
		selectorObj := self makeSelector: methodDef selector.
		mdObj indexedSlotAt: ((index - 1) * 2) + 1 put: selectorObj.
		mdObj indexedSlotAt: ((index - 1) * 2) + 2 put: methodObj.
	].

	behaviorObj := self makeInstanceOf: behaviorDef metaclass.
	behaviorObj label: 'cls_' , behaviorDef name.
	behaviorObj namedSlot: #instanceMD put: mdObj.

	bootstrap objectManager defineClass: behaviorDef obj: behaviorObj.

	^ behaviorObj
]

{ #category : #genesis }
UMRHeapBuilder >> makeClass: clsDef [
	"Create a single class and return it."
	self assert: clsDef notNil.
	self assert: clsDef isMeta not.

	self makeBehavior: clsDef.
	self makeBehavior: clsDef metaclass.
	"
	classDef2ClassObjMap at: clsDef put: clsObj.
	clsObj instanceBehavior: (self makeBehaviorFor: clsObj methods: clsDef methods).
	clsObj name: (self makeSymbol: clsDef name).

	metaObj := self makeInstanceOf: #Metaclass.
	classDef2ClassObjMap at: clsDef metaclass put: metaObj.
	metaObj instanceBehavior: (self makeBehaviorFor: metaObj methods: clsDef metaclass methods).
	metaObj class: clsObj.

	clsObj behavior: metaObj instanceBehavior.
	"
	^ bootstrap objectManager lookupClass: clsDef.
]

{ #category : #genesis }
UMRHeapBuilder >> makeClasses [
	"Traverse all modules recursively and create classes
	 and their metaclasses."

	| queue processed |

	queue := OrderedCollection with: environment.
	processed := Set new.

	[ queue notEmpty ] whileTrue: [
		| module |

		module := queue removeFirst.
		self makeClassesOf: module.
		processed add: module.

		queue addAll: (module subsystems value reject: [:each | processed includes: each ])
	].
]

{ #category : #genesis }
UMRHeapBuilder >> makeClassesOf: module [
	"Make (create) all classes and their metaclasses DEFINED in
	 given module."

	module behaviorsDo: [:behavior|
		behavior isMeta not ifTrue: [
			self makeClass: behavior.
		].
	]
]

{ #category : #genesis }
UMRHeapBuilder >> makeCompiledMethod: methodDef [
	| methodObj codeObj |

	codeObj := self makeInteger: 0.
	codeObj label: methodDef printString.

	methodObj := self makeInstanceOf: (environment lookupClass: #CompiledMethod).
	methodObj
		  label: 'mth_' , methodDef methodClass name , '>>' , methodDef selector.

	methodObj namedSlot: #code put: codeObj.
	^ methodObj
]

{ #category : #utilities }
UMRHeapBuilder >> makeInstanceOf: classDef [
	^ self makeInstanceOf: classDef size: 0
]

{ #category : #utilities }
UMRHeapBuilder >> makeInstanceOf: classDef size: size [
	"Allocate, nil-out and return an instance (as UMRHeapObject) of class `className`.
	 `size` is the size of indexed part of the object (i.e., shall not include
	 named slots). For non-variable objects, must be 0.

	 Slots of the object is set to nilObj (for pointer-objects) or to 0 (byte-objects).
	 Smallinteger instances are set to 0."

	| obj  objCls |

	self assert: classDef notNil.
	obj := UMRObject new: classDef size: size.
	objCls := bootstrap objectManager lookupClass: classDef ifAbsent: [ objNil ].
	obj classSlotPut: objCls.
	1 to: obj classDef instSize do: [:i |
		obj namedSlotAt: i put: objNil
	].
	classDef isBytes ifTrue: [
		1 to: obj size do: [:i |
			obj byteAt: i put: 0
		].
	] ifFalse: [
		classDef isPointers ifTrue: [
			1 to: size do: [:i |
				obj indexedSlotAt: i put: objNil
			]
		] ifFalse: [
			self assert: obj isImmediate.
			obj value: 0.
		]
	].
	classDef isImmediateClass ifFalse: [
		| label |

		label := 'OBJ_' , (objs size + 1
						printLeftPaddedWith: $0
						to: 8
						base: 10).
		obj label: label.
		objs add: obj.
	].
	^ obj
]

{ #category : #genesis }
UMRHeapBuilder >> makeInteger: value [
	| valueObj |

	valueObj := self makeInstanceOf: (environment lookupClass: #SmallInteger).
	valueObj value: value.
	^ valueObj.
]

{ #category : #genesis }
UMRHeapBuilder >> makeNil [
	"Create nil object"

	objNil := self makeInstanceOf: (environment lookupClass: #UndefinedObject).
	objNil label: 'nil'.
	objNil classSlotPut: objNil.

	bootstrap objectManager defineNilObj: objNil.
]

{ #category : #genesis }
UMRHeapBuilder >> makeSelector: symbol [
	"Create a selector object for given symbol"

	| selector |

	selector := self makeInstanceOf: (environment lookupClass: #Selector).
	selector label: 'sel_' , symbol storeString.
	bootstrap objectManager defineSelector: symbol obj: selector.

	^ selector
]

{ #category : #accessing }
UMRHeapBuilder >> objects [
	^ objs
]
