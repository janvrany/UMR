"
I am a helper class to simplify tests related to scopes. I collect all scopes of the AST.
This way one can easily check for scopes and variables even when the scopes are deeply nested.
Simple example (with just a method scope):

|ast scopes ivar|
ast := (OCOpalExamples>>#exampleiVar) 
		parseTree doSemanticAnalysisIn: OCOpalExamples.
scopes := (OCScopesCollector new visitNode: ast) scopes.
ivar := scopes first lookupVar: #iVar
"
Class {
	#name : #OCScopesCollector,
	#superclass : #OCASTVisitor,
	#instVars : [
		'scopes'
	],
	#category : #'LightOpal-Semantics-Tests'
}

{ #category : #'instance creation' }
OCScopesCollector class >> new [
	"return an initialized instance"

	^ self basicNew initialize.
]

{ #category : #initialization }
OCScopesCollector >> initialize [ 
	scopes := OrderedCollection new.
	super initialize
]

{ #category : #accessing }
OCScopesCollector >> scopes [ 
	^scopes
]

{ #category : #'as yet unclassified' }
OCScopesCollector >> visitBlockNode: aBlockNode [
	scopes add: aBlockNode owningScope.
	super visitBlockNode: aBlockNode
]

{ #category : #'as yet unclassified' }
OCScopesCollector >> visitMethodNode: aMethodNode [
	scopes add: aMethodNode owningScope.
	super visitMethodNode: aMethodNode
]
