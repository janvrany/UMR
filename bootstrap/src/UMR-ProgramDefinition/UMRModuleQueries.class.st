Class {
	#name : #UMRModuleQueries,
	#superclass : #RGEnvironmentQueryInterface,
	#category : #'UMR-ProgramDefinition'
}

{ #category : #caching }
UMRModuleQueries >> behaviorsDictionary [

	behaviorsDictionary isNil ifTrue: [ 
		behaviorsDictionary := IdentityDictionary new.
		self behaviorsDo: [:each | behaviorsDictionary at: each name put: each ].
		self importsDo: [ :each | behaviorsDictionary at: each name put: each behavior ].
	].
	^ behaviorsDictionary
]

{ #category : #'as yet unclassified' }
UMRModuleQueries >> importsDo: aBlock [

	self environment importsDo: aBlock
]
