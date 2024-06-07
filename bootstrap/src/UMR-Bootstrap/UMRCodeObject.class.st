Class {
	#name : #UMRCodeObject,
	#superclass : #Object,
	#instVars : [
		'methodDef',
		'code'
	],
	#category : #'UMR-Bootstrap'
}

{ #category : #'instance creation' }
UMRCodeObject class >> forMethod: methodDef code: code [
	^ self basicNew initializeWithMethod: methodDef code: code.
]

{ #category : #accessing }
UMRCodeObject >> bytes [
	^ code bytes
]

{ #category : #accessing }
UMRCodeObject >> code [
	^ code
]

{ #category : #initialization }
UMRCodeObject >> initializeWithMethod: methodDefArg code: codeArg [
	methodDef := methodDefArg.
	code := codeArg
]

{ #category : #relocation }
UMRCodeObject >> relocateTo: address [
	"Nothing to do now"
]
