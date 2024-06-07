Class {
	#name : #UMRWriter,
	#superclass : #Object,
	#instVars : [
		'bootstrap'
	],
	#category : #'UMR-Bootstrap-Writers'
}

{ #category : #'instance creation' }
UMRWriter class >> forBoostrap: anUMRBoostrap [
	^ self basicNew initializeWithBootstrap: anUMRBoostrap
]

{ #category : #initialization }
UMRWriter >> initializeWithBootstrap: anUMRBoostrap [
	bootstrap := anUMRBoostrap
]

{ #category : #writing }
UMRWriter >> writeTo: destination [
	self subclassResponsibility
]
