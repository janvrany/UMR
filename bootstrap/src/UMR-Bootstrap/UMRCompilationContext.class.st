Class {
	#name : #UMRCompilationContext,
	#superclass : #CompilationContext,
	#instVars : [
		'bootstrap',
		'method'
	],
	#category : #'UMR-Bootstrap-Compiler'
}

{ #category : #'instance creation' }
UMRCompilationContext class >> forBootstrap: anUMRBootstrap method: anRGMethod [
	^ self basicNew initializeWithBootstrap: anUMRBootstrap method: anRGMethod
]

{ #category : #'instance creation' }
UMRCompilationContext class >> new [
	self shouldNotImplement. "Use #forBootstrap:method:"
]

{ #category : #accessing }
UMRCompilationContext >> bootstrap [
	^ bootstrap
]

{ #category : #initialization }
UMRCompilationContext >> initializeWithBootstrap: anUMRBootstrap method: anRGMethod [
	super initialize.

	bootstrap := anUMRBootstrap.
	method := anRGMethod.

	self class: anRGMethod methodClass.
	self environment: anRGMethod methodClass environment
]

{ #category : #accessing }
UMRCompilationContext >> method [
	^ method
]

{ #category : #accessing }
UMRCompilationContext >> sourceInfo [
	^ method sourceInfo
]
