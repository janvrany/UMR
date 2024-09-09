"
Very simple (almost unusable) object format.

Header
	+ 0  class ref
	+ 8  unaligned size of an object body in bytes (i.e., excluding header)
	+16  instvar 1
	+24  instvar 2
		 ...
		 indexed var 1 / byte 1
		 indexed var 3 / byte 2
		 ...

"
Class {
	#name : #UMRObjectFormat1,
	#superclass : #UMRObjectFormat,
	#pools : [
		'TRDataTypes'
	],
	#category : #'UMR-Bootstrap-Objects'
}

{ #category : #'compiler helpers' }
UMRObjectFormat1 >> loadClassOf: ptr using: builder [
	self assert: ptr isTRILNode.
	self assert: ptr type == Address.

	^ builder aloadi: { ptr }
]

{ #category : #'compiler helpers' }
UMRObjectFormat1 >> loadSizeInBytesOf: ptr using: builder [
	self assert: ptr isTRILNode.
	self assert: ptr type == Address.

	^ builder iloadi: {
		builder aiadd: {
			ptr .
			builder iconst: 8"Size of class slot" } }
]

{ #category : #'compiler helpers' }
UMRObjectFormat1 >> loadSizeInSlotsOf: ptr using: builder [
	self assert: ptr isTRILNode.
	self assert: ptr type == Address.

	^ builder idiv: {
		self loadSizeInBytesOf: ptr using: builder .
		builder iconst: self sizeOfRef }
]

{ #category : #'compiler helpers' }
UMRObjectFormat1 >> loadSlotAt: idx of: ptr using: builder [
	"idx is 1-based!"

	self assert: idx isTRILNode.
	self assert: idx type == Int32.
	self assert: ptr isTRILNode.
	self assert: ptr type == Address.

	^ builder aloadi: {
		builder aiadd: {
			ptr .
			builder iadd: {
				builder iconst: self sizeOfObjectHeader - (self sizeOfRef"<-- compenzation for 1-base index").
				builder imul: { idx. builder iconst: self sizeOfRef } } } }.
]

{ #category : #queries }
UMRObjectFormat1 >> sizeOfObject: anUMRObject [
	"Return the size of an object in bytes, including header
	 and excluding any alignment."

	^self sizeOfObjectHeader
		+ (anUMRObject slots size * self sizeOfRef)
		+ (anUMRObject bytes size)
]

{ #category : #queries }
UMRObjectFormat1 >> sizeOfObjectHeader [
	^16
]

{ #category : #queries }
UMRObjectFormat1 >> sizeOfPtr [
	^ 8 "BOGUS"
]

{ #category : #queries }
UMRObjectFormat1 >> sizeOfRef [
	^ 8 "BOGUS"
]

{ #category : #'writer helpers' }
UMRObjectFormat1 >> write: object using: write [
	| abs |

	"BOGUS: get architecture-specific absolute 64bit relocation.
	 Should be done in a better way"

	write class == AcDSLRV64GAssembler ifTrue: [
		abs := R_RISCV_64
	] ifFalse: [
		self notYetImplemented
	].

	"Header"
	write ptr: abs % object classSlot oop.
	write int64: (self sizeOfObject: object) - self sizeOfObjectHeader.

	"Body"
	object slots do: [:slot |
		write ptr: abs % slot oop.
	].
	write byte: object bytes.
]
