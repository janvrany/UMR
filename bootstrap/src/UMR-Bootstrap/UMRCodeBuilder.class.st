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
	bootstrap program environment packagesDo: [ :module | self compileModule: module ]
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
	anUMRModule definedClasses do: [:classDef | 
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
