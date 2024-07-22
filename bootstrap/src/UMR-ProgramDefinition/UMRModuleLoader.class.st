Class {
	#name : #UMRModuleLoader,
	#superclass : #Object,
	#instVars : [
		'path'
	],
	#category : #'UMR-ProgramDefinition-Loader'
}

{ #category : #'instance creation' }
UMRModuleLoader class >> new [
	"return an initialized instance"

	^ self basicNew initialize.
]

{ #category : #initialization }
UMRModuleLoader >> initialize [
	"Invoked when a new instance is created."

	path := { '/home/jv/Projects/Phoenix/Modtalk/Revived/modtalk' asFilename }
]

{ #category : #loading }
UMRModuleLoader >> loadCluster: name into: module [
	| file |

	file := self searchPathFor: name , '.clt'.
	file readStreamDo: [ :s |
		UMRModuleReader readFrom: file readStream into: module
	].
]

{ #category : #loading }
UMRModuleLoader >> loadPackage: name into: module [
	| file |

	file := self searchPathFor: name , '.pkg'.
	file readStreamDo: [ :s |
		UMRModuleReader readFrom: file readStream into: module
	].
]

{ #category : #loading }
UMRModuleLoader >> loadProgram: name [
	| file module |

	file := self searchPathFor: name , '.prg'.
	file readStreamDo: [ :s |
		module := UMRModuleReader readFrom: file readStream.
	].
	^ module
]

{ #category : #loading }
UMRModuleLoader >> loadSubsystem: name [
	| file module |

	file := self searchPathFor: name , '.sbs'.
	file readStreamDo: [ :s |
		module := UMRModuleReader readFrom: file readStream.
	].
	^ module
]

{ #category : #accessing }
UMRModuleLoader >> path [
	^ path
]

{ #category : #accessing }
UMRModuleLoader >> path: aCollection [
	path := aCollection.
]

{ #category : #searching }
UMRModuleLoader >> searchPathFor: name [
	path do: [:element |
		element directories do: [ :dir | 
			| file |

			file := dir / name.
			file exists ifTrue: [ ^ file ]
		].
	].
	self error: 'Cannot locate file named ', name
]
