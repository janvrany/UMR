Extension { #name : #RBVariableNode }

{ #category : #'*LightOpal-Semantics' }
RBVariableNode >> binding [
	^self propertyAt: #binding ifAbsent: [nil].

	"Created: / 25-07-2024 / 12:26:33 / Jan Vrany <jan.vrany@labware.com>"
]

{ #category : #'*LightOpal-Semantics' }
RBVariableNode >> binding: binding [
	binding isNil ifTrue: [
		self removeProperty: #binding ifAbsent: []
	] ifFalse: [
		self propertyAt: #binding put: binding.
	]

	"Created: / 25-07-2024 / 12:27:28 / Jan Vrany <jan.vrany@labware.com>"
]

{ #category : #'*LightOpal-Semantics' }
RBVariableNode >> isArg [

	^self binding isArg
]

{ #category : #'*LightOpal-Semantics' }
RBVariableNode >> isClean [
	^ (self isInstance | self isSpecialVariable) not
]

{ #category : #'*LightOpal-Semantics' }
RBVariableNode >> isGlobal [
	| binding |

	binding := self binding.
	binding notNil ifTrue: [ 
		^ binding isGlobal 
	] ifFalse: [ 
		^ self definingScope isNil
	].
]

{ #category : #'*LightOpal-Semantics' }
RBVariableNode >> isInstance [
	^self binding isInstance
]

{ #category : #'*LightOpal-Semantics' }
RBVariableNode >> isSpecialVariable [
	^ self binding isSpecialVariable
]

{ #category : #'*LightOpal-Semantics' }
RBVariableNode >> isTemp [
	^self binding isTemp
]

{ #category : #'*LightOpal-Semantics' }
RBVariableNode >> isUndeclared [

	^self binding isUndeclared
]
