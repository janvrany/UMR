Class {
	#name : #UMRCodeBuilder,
	#superclass : #UMRBuilder,
	#instVars : [
		'objects',
		'environment'
	],
	#pools : [
		'TRDataTypes'
	],
	#category : #'UMR-Bootstrap-Builders'
}

{ #category : #building }
UMRCodeBuilder >> build [
	self compile.
]

{ #category : #compiling }
UMRCodeBuilder >> compile [
	| queue processed |

	queue := OrderedCollection with: bootstrap program.
	processed := OrderedCollection new.

	[ queue notEmpty ] whileTrue: [ 
		| module |

		module := queue removeFirst.
		self compileModule: module.
		processed add: module.

		queue addAll: (module subsystems value reject: [:each | processed includes: each ])
	].
	self compilePrims.
	self compileMain: processed asArray reversed
]

{ #category : #compiling }
UMRCodeBuilder >> compileBehavior: anRGBehavior [
	anRGBehavior methods do: [:method |
		self compileMethod: method
	].
]

{ #category : #compiling }
UMRCodeBuilder >> compileClass: anRGBehavior [
	self compileBehavior: anRGBehavior.
	self compileBehavior: anRGBehavior metaclass.
]

{ #category : #compiling }
UMRCodeBuilder >> compileInitializer: anUMRInitializer [
	self compileMethod: anUMRInitializer
]

{ #category : #compiling }
UMRCodeBuilder >> compileMain: modules [
	| compilation main |

	self assert: modules last isProgram.
	self assert: modules last initializer notNil.

	compilation := UMRCompilation forBootstrap: bootstrap.

	main := TRILFunctionBuilder forCompilation: compilation.
	main defineName: 'main' type: Int32.
	main defineParameter: 'argc' type: Int32.
	main defineParameter: 'argv' type: Address.

	modules do:[:module|
		module initializer notNil ifTrue: [
			| minit minitRetVal |

			minit := module initializer printString.
			main defineFunction: minit type: Address.
			minitRetVal := main acall: { minit }.

			module isProgram ifTrue: [
				main ireturn: { main a2i: { minitRetVal } }
			].
		].
	].

	compilation optimize.
	compilation compile.

	objects add: compilation codeBuffer.
]

{ #category : #compiling }
UMRCodeBuilder >> compileMethod: anRGMethod [ 
	| compiler  object |

	compiler := UMRCompilerDriver forBootstrap: bootstrap.
	object := compiler compile: anRGMethod.
	objects add: object
]

{ #category : #compiling }
UMRCodeBuilder >> compileModule: anUMRModule [
	self compileInitializer: anUMRModule initializer.
	anUMRModule ask allClasses do: [:classDef | 
		self compileClass: classDef
	].
]

{ #category : #compiling }
UMRCodeBuilder >> compilePrim: prim [
	| compiler  object |

	compiler := UMRCompilerDriver forBootstrap: bootstrap.
	object := compiler compilePrim: prim.
	objects add: object
]

{ #category : #compiling }
UMRCodeBuilder >> compilePrims [
	self compilePrim: UMRPrimitive_mbind.
]

{ #category : #initialization }
UMRCodeBuilder >> initializeWithBootstrap: anUMRBoostrap [
	super initializeWithBootstrap: anUMRBoostrap.
	objects := OrderedCollection new.
]

{ #category : #accessing }
UMRCodeBuilder >> objects [
	^ objects
]
