Class {
	#name : #'UMRPrimitive_primNewObject',
	#superclass : #UMRPrimitive,
	#pools : [
		'TRDataTypes'
	],
	#category : #'UMR-Bootstrap-Primitives'
}

{ #category : #'shell interface' }
UMRPrimitive_primNewObject >> evalUsing: shell parameters: params [
	| of zelf nslots newoop |

	of := shell bootstrap objectFormat.
	zelf := params first.

	nslots := of decodeImmInteger: (of readSlotAt: 3  of: zelf using: shell memory).

	newoop := shell heap2 allocCode: (of sizeOfObjectHeader + (nslots * of sizeOfRef)).
	"BOGUS - we should let object format to initialize the object!"
	of writeClassOf: newoop with: zelf using: shell memory.
	of writeSizeInBytesOf: newoop with: nslots * of sizeOfRef using: shell memory.

	^ newoop
]

{ #category : #accessing }
UMRPrimitive_primNewObject >> name [
	^ 'primNewObject'
]

{ #category : #accessing }
UMRPrimitive_primNewObject >> numArgs [
	^ 1 "self"
]
