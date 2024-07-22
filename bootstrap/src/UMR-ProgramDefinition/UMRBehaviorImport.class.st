Class {
	#name : #UMRBehaviorImport,
	#superclass : #RGObject,
	#instVars : [
		'behavior'
	],
	#category : #'UMR-ProgramDefinition'
}

{ #category : #accessing }
UMRBehaviorImport >> behavior [
	^ behavior
]

{ #category : #accessing }
UMRBehaviorImport >> behavior: anRGBehavior [
	self assert: anRGBehavior notNil.

	behavior := anRGBehavior.
	self propertyNamed: #resolved put: true
]

{ #category : #testing }
UMRBehaviorImport >> hasResolvedBehavior [
	^ self hasResolved: #behavior
]

{ #category : #initialization }
UMRBehaviorImport >> initialize [

	super initialize.
	behavior := RGBehavior unresolved.
]

{ #category : #initialization }
UMRBehaviorImport >> initializeUnresolved [

	super initializeUnresolved.
	behavior := RGBehavior unresolved.
]

{ #category : #testing }
UMRBehaviorImport >> isImport [
	^ true

	"Created: / 04-07-2024 / 11:43:06 / Jan Vrany <jan.vrany@labware.com>"
]

{ #category : #strategy }
UMRBehaviorImport >> package [

	^ nil
]

{ #category : #strategy }
UMRBehaviorImport >> package: anRGPackage [
	self shouldNotImplement
]

{ #category : #printing }
UMRBehaviorImport >> printOn: aStream [ 
	aStream nextPutAll: self name
]
