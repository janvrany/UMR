Class {
	#name : #UMRCompilation,
	#superclass : #TRCompilation,
	#instVars : [
		'bootstrap'
	],
	#category : #'UMR-Bootstrap-Compiler'
}

{ #category : #'instance creation' }
UMRCompilation class >> forBootstrap: anUMRBootstrap [
	^ self forTarget: anUMRBootstrap target bootstrap: anUMRBootstrap
]

{ #category : #'instance creation' }
UMRCompilation class >> forConfig: aTRCompilationConfig [
	^ self shouldNotImplement. "Use #forConfig:bootstrap: or #forBootstrap:"
]

{ #category : #'instance creation' }
UMRCompilation class >> forConfig: aTRCompilationConfig bootstrap: anUMRBootstrap [
	^ self basicNew initializeWithConfig: aTRCompilationConfig bootstrap: anUMRBootstrap
]

{ #category : #'instance creation' }
UMRCompilation class >> forTarget: aTRCompilationTarget [
	^ self shouldNotImplement. "Use #forTarget:bootstrap: or #forBootstrap:"
]

{ #category : #'instance creation' }
UMRCompilation class >> forTarget: aTRCompilationTarget bootstrap: anUMRBootstrap [
	^ self forConfig: (TRCompilationConfig forTarget: aTRCompilationTarget) bootstrap: anUMRBootstrap
]

{ #category : #initialization }
UMRCompilation >> initializeWithConfig: aTRCompilationConfig [
	^ self shouldNotImplement. "Use #initializeWithConfig:bootstrap: instead"
]

{ #category : #initialization }
UMRCompilation >> initializeWithConfig: aTRCompilationConfig bootstrap: anUMRBootstrap [
	super initializeWithConfig: aTRCompilationConfig.
	bootstrap := anUMRBootstrap
]

{ #category : #accessing }
UMRCompilation >> objectFormat [
	^ bootstrap objectFormat
]

{ #category : #accessing }
UMRCompilation >> objectManager [
	^ bootstrap objectManager
]

{ #category : #accessing }
UMRCompilation >> primitiveIndex: aString [
	^ bootstrap primitiveIndex: aString
]

{ #category : #accessing }
UMRCompilation >> primitiveNamed: aString [
	^ bootstrap primitiveNamed: aString
]
