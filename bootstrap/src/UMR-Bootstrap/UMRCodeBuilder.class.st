Class {
	#name : #UMRCodeBuilder,
	#superclass : #UMRBuilder,
	#instVars : [
		'objects',
		'environment'
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
	processed := Set new.

	[ queue notEmpty ] whileTrue: [ 
		| module |

		module := queue removeFirst.
		self compileModule: module.
		processed add: module.

		queue addAll: (module subsystems value reject: [:each | processed includes: each ])
	].
]

{ #category : #compiling }
UMRCodeBuilder >> compileClass: anRGBehavior [
	self shouldImplement
]

{ #category : #compiling }
UMRCodeBuilder >> compileInitializer: anUMRInitializer [
	self compileMethod: anUMRInitializer
]

{ #category : #compiling }
UMRCodeBuilder >> compileMethod: anRGMethod [ 
	| compiler  object |

	compiler := UMRCompiler forTarget: bootstrap target.
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

{ #category : #initialization }
UMRCodeBuilder >> initializeWithBootstrap: anUMRBoostrap [
	super initializeWithBootstrap: anUMRBoostrap.
	objects := OrderedCollection new.
]

{ #category : #accessing }
UMRCodeBuilder >> objects [
	^ objects
]
