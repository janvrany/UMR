"
Very simple, idiotic and unusable object format.

Header
	+ 0  class ref
	+ 8  unaligned size of an object body in bytes (i.e., excluding header)
	+16  instvar 1
	+24  instvar 2
		 ...
		 indexed var 1 / byte 1
		 indexed var 3 / byte 2
		 ...

No support for immediate objects. Integers are encoded
raw (no tagging), there's no way one can tell integer
from heap object.

"
Class {
	#name : #UMRObjectFormat1,
	#superclass : #UMRObjectFormat,
	#pools : [
		'AcIntLimits',
		'TRDataTypes'
	],
	#category : #'UMR-Bootstrap-Objects'
}

{ #category : #'encoding & decoding' }
UMRObjectFormat1 >> decodeImmInteger: value [
	"Given an immediate integer OOP, return its value"

	self assert:(value between: UINT64_MIN and: UINT64_MAX).

	^ value
]

{ #category : #'encoding & decoding' }
UMRObjectFormat1 >> encodeImmInteger: value [
	"Given an (integer) value, encode it according to the object format
	 as immediate object and return its OOP."

	self assert: value isInteger.
	self assert:(value between: (INT64_MIN >> 1) and: (INT64_MAX >> 1)).

	^ value
]

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

{ #category : #'evaluator interface' }
UMRObjectFormat1 >> readSizeInBytesOf: ptr using: memory [
	"idx is 1-based!"

	self assert: ptr isInteger.
	self assert:(memory isKindOf: GDBThreadGroupMemory).

	^ memory unsignedLongLongAt: ptr + 8
]

{ #category : #'evaluator interface' }
UMRObjectFormat1 >> readSizeInSlotsOf: ptr using: memory [
	| sizeInBytes |

	sizeInBytes := self readSizeInBytesOf: ptr using: memory.
	self assert:(sizeInBytes \\ self sizeOfRef) == 0.
	^ sizeInBytes // self sizeOfRef
]

{ #category : #'evaluator interface' }
UMRObjectFormat1 >> readSlotAt: idx of: ptr using: memory [
	"idx is 1-based!"

	| nslots pslot |

	self assert: ptr isInteger.
	self assert: idx isInteger.
	self assert:(memory isKindOf: GDBThreadGroupMemory).

	nslots := self readSizeInSlotsOf: ptr using: memory.
	self assert: idx <= nslots.

	pslot := ptr + self sizeOfObjectHeader + ((idx - 1) * self sizeOfRef).

	^ memory unsignedLongLongAt: pslot.

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
	object slots do: [:value |
		write ptr: abs % value oop.
	].
	write byte: object bytes.
]

{ #category : #'evaluator interface' }
UMRObjectFormat1 >> writeClassOf: objptr with: clsptr using: memory [
	"idx is 1-based!"

	self assert: objptr isInteger.
	self assert: clsptr isInteger.
	self assert:(memory isKindOf: GDBThreadGroupMemory).

	^ memory unsignedLongLongAt: objptr put: clsptr
]

{ #category : #'evaluator interface' }
UMRObjectFormat1 >> writeSizeInBytesOf: ptr with: size using: memory [
	"idx is 1-based!"

	self assert: ptr isInteger.
	self assert: size isInteger.
	self assert:(memory isKindOf: GDBThreadGroupMemory).

	^ memory unsignedLongLongAt: ptr + 8 put: size
]
