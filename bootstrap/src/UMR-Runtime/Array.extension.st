Extension { #name : #Array }

{ #category : #'*UMR-Runtime' }
Array >> pythonOn:aStream [
	aStream nextPut: $(.
	self 
		do: [:each | each pythonOn: aStream]
		separatedBy:[ aStream nextPutAll: ', ' ].
	aStream nextPut: $).  
]
