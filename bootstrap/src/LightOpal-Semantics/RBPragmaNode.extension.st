Extension { #name : #RBPragmaNode }

{ #category : #'*LightOpal-Semantics' }
RBPragmaNode >> asPragma [
	^ Pragma
		selector: selector
		arguments: (arguments collect: [ :each | each value ]) asArray
]
