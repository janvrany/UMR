Class {
	#name : #UMRBuilder,
	#superclass : #Object,
	#instVars : [
		'bootstrap'
	],
	#category : #'UMR-Bootstrap-Builders'
}

{ #category : #'instance creation' }
UMRBuilder class >> forBoostrap: anUMRBoostrap [
	^ self basicNew initializeWithBootstrap: anUMRBoostrap
]

{ #category : #building }
UMRBuilder >> build [
	self subclassResponsibility
]

{ #category : #initialization }
UMRBuilder >> initializeWithBootstrap: anUMRBoostrap [
	bootstrap := anUMRBoostrap
]
