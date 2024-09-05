Extension { #name : #True }

{ #category : #'*UMR-Runtime' }
True >> pythonOn: aStream [
	aStream nextPutAll: 'True'  
]
