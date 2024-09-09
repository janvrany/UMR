Extension { #name : #RGObject }

{ #category : #'*UMR-Bootstrap' }
RGObject >> obj [
	"Return UMR object (instance of `UMRHeapObject`) representing
	 the receiver during bootstrap"

	^ self propertyNamed: #obj ifAbsent: [ nil ]

	"Created: / 09-08-2024 / 15:47:57 / Jan Vrany <jan.vrany@labware.com>"
]

{ #category : #'*UMR-Bootstrap' }
RGObject >> obj: anUMRHeapObject [
	"Set UMR object (instance of `UMRHeapObject`) representing
	 the receiver during bootstrap"

	self propertyNamed: #obj put: anUMRHeapObject

	"Created: / 09-08-2024 / 15:48:25 / Jan Vrany <jan.vrany@labware.com>"
]
