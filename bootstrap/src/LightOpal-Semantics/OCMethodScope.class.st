"
I am the scope for a Method
"
Class {
	#name : #OCMethodScope,
	#superclass : #OCAbstractMethodScope,
	#category : #'LightOpal-Semantics'
}

{ #category : #testing }
OCMethodScope >> isMethodScope [ 
	^true
]

{ #category : #scope }
OCMethodScope >> methodScope [

	^ self
]
