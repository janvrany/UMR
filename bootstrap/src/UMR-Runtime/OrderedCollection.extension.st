Extension { #name : #OrderedCollection }

{ #category : #'*UMR-Runtime' }
OrderedCollection >> pythonOn:aStream [
	aStream nextPut: $[ .
	self 
		do: [:each | each pythonOn: aStream]
		separatedBy:[ aStream nextPutAll: ', ' ].
	aStream nextPut: $].  
]
