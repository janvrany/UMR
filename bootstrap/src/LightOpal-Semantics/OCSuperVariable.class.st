"
I model super variables
"
Class {
	#name : #OCSuperVariable,
	#superclass : #OCSpecialVariable,
	#category : #'LightOpal-Semantics'
}

{ #category : #accessing }
OCSuperVariable class >> semanticNodeClass [

	^RBSuperNode 
]

{ #category : #initialization }
OCSuperVariable >> initialize [
	super initialize.
	
	name := 'super'
]

{ #category : #testing }
OCSuperVariable >> isSelfOrSuper [
	
	^ true
]

{ #category : #testing }
OCSuperVariable >> isSuper [
	^true
]
