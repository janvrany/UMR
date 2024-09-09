Class {
	#name : #UMRTonelWriter,
	#superclass : #TonelWriter,
	#instVars : [
		'positions'
	],
	#category : #'UMR-Bootstrap-Utils-Source'
}

{ #category : #'instance creation' }
UMRTonelWriter class >> new [
	"return an initialized instance"

	^ self basicNew initialize.
]

{ #category : #utilities }
UMRTonelWriter class >> positionOfMethod: method on: stream [
	| mcpkg mcwc mcvi mcversion mcsnap writer |

	self assert: method methodClass package = method package.

	Smalltalk isSmalltalkX ifTrue:[
		mcpkg := MCPackage named: method package.
		mcwc := mcpkg workingCopy.
		mcvi := MCVersionInfo forPackage: method package.
		[
			mcversion := mcwc newVersion.
		] on:MCVersionNameAndMessageRequest do:[:ex |
			ex resume:(Array with:mcvi name with:mcvi message)
		].
		mcsnap := mcversion snapshot.
	] ifFalse:[
	Smalltalk isPharo ifTrue:[
		mcpkg := method package mcPackage.
		mcsnap := method package mcWorkingCopy snapshot.
	] ifFalse:[
		self error:'Unsupported dialect'
	]].
	writer := self new.
	writer snapshot: mcsnap name: mcpkg name.
	writer writeClassNamed: method methodClass name on: stream.
	^ writer positionOfMethod: method
]

{ #category : #initialization }
UMRTonelWriter >> initialize [
	"Invoked when a new instance is created."

	"  please change as required (and remove this comment)"
	positions := Dictionary new.

	"  super initialize.   -- commented since inherited method does nothing"
]

{ #category : #queries }
UMRTonelWriter >> positionOfMethod: method [
	| methodDef |

	methodDef := snapshot definitions
					detect: [:e|
						e isMethodDefinition
							and:[e actualClass == method methodClass
							and:[e selector = method selector ]]].
	^ positions at: methodDef.
]

{ #category : #accessing }
UMRTonelWriter >> snapshot: snapshotArg name: name [
	self snapshot: snapshotArg.
	packageDir := name.
]

{ #category : #writing }
UMRTonelWriter >> writeClassNamed: className on: streamArg [
	| classDef |

	classDef := snapshot definitions detect: [:e | e isClassDefinition and:[e className = className ] ].
	self writeClass: classDef on: streamArg.
]

{ #category : #'private writing' }
UMRTonelWriter >> writeMethodDefinition: aMethodDefinition parent: aClassDefinition on: aStream [
	| nl |

	nl := self newLine.
	self
		splitMethodSource: aMethodDefinition
		into: [ :methodDeclaration :methodBody | | fullClassName |
			fullClassName := self classNameFor: aMethodDefinition parent: aClassDefinition.
			aStream
				<< nl
				<< (self methodDefinitionOf: aMethodDefinition) << nl.
			positions at: aMethodDefinition put: aStream position.
			aStream
				<< fullClassName << ' >> ' << methodDeclaration
				<< ' [' << methodBody << nl << ']' << nl ]
]

{ #category : #writing }
UMRTonelWriter >> writePackage: ignored [
	self shouldNotImplement
]

{ #category : #writing }
UMRTonelWriter >> writeSnapshot: ignored [
	self shouldNotImplement
]

{ #category : #writing }
UMRTonelWriter >> writeVersion: ignored [
	self shouldNotImplement
]
