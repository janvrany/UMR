Extension { #name : #Object }

{ #category : #'*UMR-Runtime' }
Object >> pythonOn:aStream [
	"Print this object on `aStream` as Python object .
	 Kind of #storeOn: but using Python syntax."

	self error: 'This object cannot be represented as Python object'

   "
	(1@2) pythonOn:Transcript
	(1@2) pythonOn:Transcript
   "  
]
