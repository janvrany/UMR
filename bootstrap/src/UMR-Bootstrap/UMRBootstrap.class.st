Class {
	#name : #UMRBootstrap,
	#superclass : #Object,
	#instVars : [
		'program',
		'target',
		'codeBuilder'
	],
	#category : #'UMR-Bootstrap'
}

{ #category : #'instance creation' }
UMRBootstrap class >> forProgram: program target: target [
	^ self basicNew initializeWithProgram: program target: target

]

{ #category : #building }
UMRBootstrap >> bootstrap [
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

{ #category : #'accessing - config' }
UMRBootstrap >> heapBuilderClass [
	^ UMRHeapBuilder

]

{ #category : #initialization }
UMRBootstrap >> initializeWithProgram: programArg target: targetArg [
	program := programArg.
	target := targetArg.
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
]
