Extension { #name : #RBMessageNode }

{ #category : #'*LightOpal-AST-SmalltalkX' }
RBMessageNode >> isSelfSend [
	^ receiver isVariable and: [ receiver name = 'self' ]
]

{ #category : #'*LightOpal-AST-SmalltalkX' }
RBMessageNode >> isSuperSend [
	^ receiver isVariable and: [ receiver name = 'super' ]
]
