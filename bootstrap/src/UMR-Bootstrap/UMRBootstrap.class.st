Class {
	#name : #UMRBootstrap,
	#superclass : #Object,
	#instVars : [
		'program',
		'target',
		'environment',
		'codeBuilder',
		'heapBuilder',
		'objectManager',
		'objectFormat',
		'primitives'
	],
	#category : #'UMR-Bootstrap'
}

{ #category : #'instance creation' }
UMRBootstrap class >> forProgram: program target: target [
	^ self basicNew initializeWithProgram: program target: target

]

{ #category : #building }
UMRBootstrap >> bootstrap [
	self heapBuilder build.
	self codeBuilder build.
]

{ #category : #accessing }
UMRBootstrap >> codeBuilder [
	codeBuilder isNil ifTrue: [ 
		codeBuilder := self codeBuilderClass forBoostrap: self.  
	].
	^ codeBuilder
]

{ #category : #'accessing - config' }
UMRBootstrap >> codeBuilderClass [
	^ UMRCodeBuilder

]

{ #category : #accessing }
UMRBootstrap >> codeObjects [
	^ self codeBuilder objects
]

{ #category : #accessing }
UMRBootstrap >> codeWriter [
	^ self codeWriterClass forBoostrap: self.
]

{ #category : #'accessing - config' }
UMRBootstrap >> codeWriterClass [
	^ UMRBinaryCodeWriter
]

{ #category : #accessing }
UMRBootstrap >> environment [
	^ environment
]

{ #category : #accessing }
UMRBootstrap >> heapBuilder [
	heapBuilder isNil ifTrue: [
		heapBuilder := self heapBuilderClass forBoostrap: self.
	].
	^ heapBuilder
]

{ #category : #'accessing - config' }
UMRBootstrap >> heapBuilderClass [
	^ UMRHeapBuilder

]

{ #category : #accessing }
UMRBootstrap >> heapObjects [
	^ self heapBuilder objects
]

{ #category : #accessing }
UMRBootstrap >> heapWriter [
	^ self heapWriterClass forBoostrap: self.
]

{ #category : #'accessing - config' }
UMRBootstrap >> heapWriterClass [
	^ UMRBinaryHeapWriter
]

{ #category : #initialization }
UMRBootstrap >> initializeWithProgram: programArg target: targetArg [
	program := programArg.
	target := targetArg.
	environment := UMRBootstrapEnvironment new.
	environment setProgram: program.
	objectManager := UMRObjectManager new.
	objectFormat := UMRObjectFormat1 forTarget: target.
	primitives := {
		UMRPrimitive_mbind new.
		UMRPrimitive_primNewObject new.
		UMRPrimitive_primSaySomething new.
	}
]

{ #category : #accessing }
UMRBootstrap >> objectFormat [
	^ objectFormat
]

{ #category : #accessing }
UMRBootstrap >> objectManager [
	^ objectManager
]

{ #category : #accessing }
UMRBootstrap >> primitiveIndex: aString [
	primitives withIndexDo:[:prim :primIndex |
		prim name = aString ifTrue: [ ^ primIndex ]
	].
	self error: 'No such primitive: ', aString.
	^ nil.
]

{ #category : #accessing }
UMRBootstrap >> primitiveNamed: aString [
	^ primitives
		detect: [:primitive | primitive name = aString ]
		ifNone: [ self error: 'No such primitive: ', aString. nil].
]

{ #category : #accessing }
UMRBootstrap >> primitives [
	^ primitives
]

{ #category : #accessing }
UMRBootstrap >> program [
	^ program
]

{ #category : #accessing }
UMRBootstrap >> target [
	^ target
]

{ #category : #writing }
UMRBootstrap >> writeCodeTo: destination [
	self codeWriter writeTo: destination
]

{ #category : #writing }
UMRBootstrap >> writeHeapTo: destination [
	self heapWriter writeTo: destination
]
