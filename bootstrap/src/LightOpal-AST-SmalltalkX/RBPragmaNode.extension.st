Extension { #name : #RBPragmaNode }

{ #category : #'*LightOpal-AST-SmalltalkX' }
RBPragmaNode >> isPrimitiveError [
	^ #( primitive:error: primitive:module:error: primitive:error:module:) includes: self selector

	"Created: / 25-07-2024 / 12:12:54 / Jan Vrany <jan.vrany@labware.com>"
]
