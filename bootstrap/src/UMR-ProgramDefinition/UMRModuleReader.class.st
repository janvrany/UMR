Class {
	#name : #UMRModuleReader,
	#superclass : #Object,
	#instVars : [
		'environment',
		'stream',
		'chunk',
		'chunkExpr',
		'module',
		'annotations',
		'program'
	],
	#classVars : [
		'Handlers'
	],
	#category : #'UMR-ProgramDefinition-Reader'
}

{ #category : #initialization }
UMRModuleReader class >> initialize [
]

{ #category : #'instance creation' }
UMRModuleReader class >> new [
	"return an initialized instance"

	^ self basicNew initialize.
]

{ #category : #utilities }
UMRModuleReader class >> readFrom: aStream [
	^ self new stream: aStream; read.
]

{ #category : #processing }
UMRModuleReader >> process_Cluster_addPackageNamed: packageName repositoryName: ignored [
	| package |

	package := UMRModuleLoader new loadPackage: packageName.
	self notYetImplemented.
]

{ #category : #processing }
UMRModuleReader >> process_Cluster_named: name [
	module := UMRCluster named: name parent: environment.
	environment addPackage: module.
]

{ #category : #processing }
UMRModuleReader >> process_Package_named: name [
	module := UMRPackage named: name parent: environment.
	environment addPackage: module.
]

{ #category : #processing }
UMRModuleReader >> process_Program_addSubsystemNamed: subsystemName repositoryName: ignored [
	| subsystem |

	subsystem := UMRModuleLoader new loadSubsystem: subsystemName.
	self notYetImplemented.
]

{ #category : #processing }
UMRModuleReader >> process_Program_importClass: exportedName from: subsystemName as: localName [
	self notYetImplemented
]

{ #category : #processing }
UMRModuleReader >> process_Program_named: name initializer: initializerNode [
	| initializer |

	initializer := UMRInitializer new sourceCode:
					(chunk copyFrom: initializerNode body sourceInterval first
								 to: initializerNode body sourceInterval last).

	module := UMRProgram named: name parent: environment.
	module initializer: initializer.

	environment addPackage: module.
]

{ #category : #processing }
UMRModuleReader >> process_Subsystem_named: name initializer: initializerNode [
	| initializer |

	initializer := UMRInitializer new sourceCode:
					(chunk copyFrom: initializerNode body sourceInterval start
								 to: initializerNode body sourceInterval stop).

	module := UMRSubsystem named: name parent: environment.
	module initializer: initializer.

	environment addPackage: module.
]

{ #category : #processing }
UMRModuleReader >> process_Subsystem_rootClusterNamed:clusterName repositoryName: ignored [
	| cluster |

	cluster := UMRModuleLoader new loadCluster: clusterName.
	self notYetImplemented
]

{ #category : #reading }
UMRModuleReader >> read [
	environment := UMREnvironment new.
	module := nil.

	[ self readNextChunk ] whileTrue.

	^ module
]

{ #category : #'reading-private' }
UMRModuleReader >> readNextChunk [
	stream atEnd ifTrue: [ ^ false ].

	stream skipSeparators.
	chunk := stream nextChunk.
	chunk isEmptyOrNil ifTrue: [ ^ false ].

	chunkExpr := RBParser parseExpression: chunk.

	(chunkExpr isMessage and: [ chunkExpr receiver isVariable ]) ifTrue: [
		| handler moduleType |

		chunkExpr selector = #method ifTrue: [ 
			^ self notYetImplemented
		].

		chunkExpr selector = #classMethod ifTrue: [ 
			^ self notYetImplemented
		].

		chunkExpr selector = #named:superclass:indexedInstanceVariables:instanceVariableNames:classVariableNames:sharedPools:classInstanceVariableNames: ifTrue: [ 
			^ self notYetImplemented
		].

		module isNil ifTrue: [ 
			moduleType := chunkExpr receiver name
		] ifFalse: [ 
			moduleType := module class name copyFrom: 4 to: module class name size.
		].

		handler := Symbol findInterned: ('process_' , moduleType , '_' , chunkExpr selector).
		(handler notNil and: [ self respondsTo: handler ]) ifTrue: [ 
			| args |
			args := chunkExpr arguments collect: [ :e|e value ].
			self perform: handler withArguments: args asArray.
			^ true
		].
		self error: 'Unsupported chunk type'.
		^ false
	].
	self error: 'Unsupported chunk type'.
	^ false
]

{ #category : #accessing }
UMRModuleReader >> stream [
	^ stream
]

{ #category : #accessing }
UMRModuleReader >> stream: aStream [
	stream := aStream.
]
