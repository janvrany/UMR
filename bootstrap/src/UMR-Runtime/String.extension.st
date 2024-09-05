Extension { #name : #String }

{ #category : #'*UMR-Runtime' }
String >> pythonOn:aStream [

	aStream nextPut: $".
	self do:[:char | 
		char codePoint < 128 ifTrue:[
			aStream nextPut: char
		] ifFalse:[ 
			aStream nextPutAll: '\u'.
					aStream nextPutAll: (char codePoint printLeftPaddedWith:$0 to:4 base:16)
		].
	].
	aStream nextPut: $".      
]
