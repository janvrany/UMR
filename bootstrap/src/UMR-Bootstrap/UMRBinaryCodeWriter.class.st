Class {
	#name : #UMRBinaryCodeWriter,
	#superclass : #UMRWriter,
	#category : #'UMR-Bootstrap-Writers'
}

{ #category : #writing }
UMRBinaryCodeWriter >> writeTo: codeCache [
	bootstrap codeObjects do: [:object | 
		codeCache add: object code.
	].
]
