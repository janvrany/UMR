Class {
	#name : #UMRBinaryHeapWriter,
	#superclass : #UMRWriter,
	#instVars : [
		'write',
		'abs'
	],
	#category : #'UMR-Bootstrap-Writers'
}

{ #category : #'writing - private' }
UMRBinaryHeapWriter >> write: object [
	"Write single object"

	write globl: object oop.
	write label: object oop.

	bootstrap objectFormat write: object using: write.
]

{ #category : #writing }
UMRBinaryHeapWriter >> writeTo: heapCache [
	"TODO: Following is so ugly, shall we move assemblerClass to target? Or even config?"
	write := bootstrap target codeGeneratorClass basicNew assemblerClass new.

	bootstrap heapObjects do: [:object |
		self write: object
	].
	heapCache add: write memory.
]
