Class {
	#name : #UMRModuleReader,
	#superclass : #Object,
	#instVars : [
		'stream',
		'chunk',
		'chunkPos',
		'chunkExpr',
		'module',
		'artefact',
		'annotations'
	],
	#classVars : [
		'LayoutMap'
	],
	#category : #'UMR-ProgramDefinition-Reader'
}

{ #category : #initialization }
UMRModuleReader class >> initialize [
	LayoutMap := Dictionary newFromPairs: {
		#none . RGFixedLayout.
	}
]

{ #category : #'instance creation' }
UMRModuleReader class >> new [
	"return an initialized instance"

	^ self basicNew initialize.
]

{ #category : #utilities }
UMRModuleReader class >> readFrom: aStream [
	^ self new 
		stream: aStream; 
		read.
]

{ #category : #utilities }
UMRModuleReader class >> readFrom: aStream into: anUMRModule [
	^ self new 
		stream: aStream; 
		module: anUMRModule;
		read.
]

{ #category : #accessing }
UMRModuleReader >> module [
	^ module
]

{ #category : #accessing }
UMRModuleReader >> module: anUMRModule [
	module := anUMRModule.
]

{ #category : #processing }
UMRModuleReader >> process1 [
	"Read and process next chunk from input stream. Return true,
	 if chunk was read processed, false otherwise."

	self readNextChunk ifFalse: [ ^ false ].

	chunkExpr := RBParser parseExpression: chunk.
	(chunkExpr isMessage and: [ chunkExpr receiver isVariable ]) ifTrue: [
		| handler artefactType |

		chunkExpr selector = #method ifTrue: [
			^ self processMethodDefinition: false.
		].

		chunkExpr selector = #classMethod ifTrue: [
			^ self processMethodDefinition: true
		].

		chunkExpr selector = #named:superclass:indexedInstanceVariables:instanceVariableNames:classVariableNames:sharedPools:classInstanceVariableNames: ifTrue: [
			self assert: chunkExpr receiver name = 'Class'.
			^ self processClassDefinition
		].

		chunkExpr selector = #key:value: ifTrue: [
			self assert: chunkExpr receiver name = 'Annotation'.
			^ self processAnnotation.
		].

		artefact isNil ifTrue: [
			artefactType := chunkExpr receiver name
		] ifFalse: [
			self assert: chunkExpr receiver name = artefact name.
			artefactType := artefact class name copyFrom: 4 to: artefact class name size.
		].

		handler := Symbol findInterned: ('process_' , artefactType , '_' , chunkExpr selector).
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

{ #category : #processing }
UMRModuleReader >> processAnnotation [
	"Ignored for now"

	^ true
]

{ #category : #processing }
UMRModuleReader >> processClassDefinition [
	| params superclass class meta |

	params := SmallDictionary new.
	chunkExpr selector keywords with: chunkExpr arguments do: [:param :valueNode | 
		params at: param put: valueNode value
	].
	superclass := (params at: #superclass:) = 'nil'
					ifTrue:[ nil ]
					ifFalse:[ module ensureClassNamed: (params at: #superclass:) ].

	"First, create the class itself."
	class := module ensureClassNamed: (params at:#named:) asSymbol.
	class
		superclass: superclass;
		layout: ((LayoutMap at: (params at: #indexedInstanceVariables:)) parent: class);
		instanceVariables: ((params at: #instanceVariableNames:) substrings:' ') asArray;
		package: artefact.

	"Now, create the metaclass"
	meta := module ensureClassNamed: (class name , ' class') asSymbol.
	meta 
		superclass: (superclass isNil ifTrue:[nil] ifFalse:[superclass metaclass]);
		layout: ((LayoutMap at: #none) parent: class);
		instanceVariables: ((params at: #classInstanceVariableNames:) substrings:' ') asArray.

	"If this is root of the class hierarchy, make sure it has the structure required
	 by runtime."
	superclass isNil ifTrue: [ 
		self assert: (meta instVarNames size >= 4).
		self assert: (meta instVarNames at: 1) = 'structure'.
		self assert: (meta instVarNames at: 2) = 'instanceMD'.
		self assert: (meta instVarNames at: 3) = 'instVarCount'.
		self assert: (meta instVarNames at: 4) = 'superclass'.
	].

	"Also, if it is a root class, make the metaclass also a class of metaclass"
	superclass isNil ifTrue: [ 
		meta metaclass: meta.
	].

	^ true
]

{ #category : #processing }
UMRModuleReader >> processMethodDefinition: classMethod [
	| source sourceRef class method |

	class := module ensureClassNamed: chunkExpr receiver name.
	classMethod ifTrue: [ 
		class := class metaclass.
	].

	self readNextChunk.
	source := chunk.
	sourceRef := UMRSourceInfo file: stream fileName position: chunkPos length: source size lines: stream lineEnds.

	method := RGMethod named: (RBParser parseMethodPattern: source) parent: class.
	method package: artefact.
	method sourceCode: source.
	method sourceInfo: sourceRef.

	class addLocalMethod: method.

	^ true
]

{ #category : #processing }
UMRModuleReader >> process_Cluster_addPackageNamed: packageName repositoryName: ignored [
	UMRModuleLoader new loadPackage: packageName into: module.
]

{ #category : #processing }
UMRModuleReader >> process_Cluster_named: name [
	| cluster |

	cluster := artefact := UMRCluster named: name parent: module.
	module addPackage: cluster.
]

{ #category : #processing }
UMRModuleReader >> process_Package_named: name [
	| package |

	package := artefact := RGPackage named: name parent: module.
	module addPackage: package.
]

{ #category : #processing }
UMRModuleReader >> process_Program_addSubsystemNamed: subsystemName repositoryName: ignored [
	| subsystem |

	subsystem := UMRModuleLoader new loadSubsystem: subsystemName.
	module addSubsystem: subsystem.
]

{ #category : #processing }
UMRModuleReader >> process_Program_importClass: exportedName from: subsystemName as: localName [
	| subsystem exportedClass import |

	subsystem := artefact lookupSubsystem: subsystemName.
	exportedClass := subsystem lookupClass: exportedName.

	import := module ensureImportNamed: localName.
	import behavior: exportedClass.
]

{ #category : #processing }
UMRModuleReader >> process_Program_named: name initializer: initializerNode [
	| source sourceRef initializer |

	initializerNode body sourceInterval notEmpty ifTrue:[
		source := (chunk copyFrom: initializerNode body sourceInterval first
										  to: initializerNode body sourceInterval last).
	] ifFalse: [
		source := ''.
	].
	sourceRef := UMRSourceInfo file: stream fileName position: chunkPos + initializerNode body start length: source size lines: stream lineEnds.

	initializer := UMRInitializer new.
	initializer sourceCode: source.
	initializer sourceInfo: sourceRef.


	module := artefact := UMRProgram named: name.
	module initializer: initializer.
]

{ #category : #processing }
UMRModuleReader >> process_Subsystem_named: name initializer: initializerNode [
	| source sourceRef initializer |

	initializerNode body sourceInterval notEmpty ifTrue:[
		source := (chunk copyFrom: initializerNode body sourceInterval first
										  to: initializerNode body sourceInterval last).
	] ifFalse: [
		source := ''.
	].
	sourceRef := UMRSourceInfo file: stream fileName position: chunkPos + initializerNode body start  length: source size lines: stream lineEnds.

	initializer := UMRInitializer new.
	initializer sourceCode: source.
	initializer sourceInfo: sourceRef.

	module := artefact := UMRSubsystem named: name.
	module initializer: initializer.
]

{ #category : #processing }
UMRModuleReader >> process_Subsystem_rootClusterNamed:clusterName repositoryName: ignored [
	UMRModuleLoader new loadCluster: clusterName into: module.
]

{ #category : #reading }
UMRModuleReader >> read [
	artefact := nil.

	[ self process1 ] whileTrue.

	^ module clean
]

{ #category : #'reading-private' }
UMRModuleReader >> readNextChunk [
	"Read next chunk from input stream and set `chunk` and `chunkPos`
	 instvar.

	 Return true, if chunk was read, false otherwise (in that case,
	 `chunk` and `chunkPos` is set to `nil`.)
	"
	stream atEnd ifTrue: [
		chunk := chunkPos := nil.
		^ false
	].
	stream skipSeparators.
	chunkPos := stream position.
	chunk := stream nextChunk.
	chunk isEmptyOrNil ifTrue: [
		chunk := chunkPos := nil.
		^ false
	].
	^ true
]

{ #category : #accessing }
UMRModuleReader >> stream [
	^ stream
]

{ #category : #accessing }
UMRModuleReader >> stream: aStream [
	stream := UMRLineTrackingReadStream on: aStream.
]
