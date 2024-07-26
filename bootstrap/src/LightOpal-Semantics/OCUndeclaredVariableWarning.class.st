"
I get signalled when a temporary variable is used that is not defined.  My default action is to create an Undeclared binding and add it to the Undeclared dictionary.
"
Class {
	#name : #OCUndeclaredVariableWarning,
	#superclass : #OCSemanticWarning,
	#category : #'LightOpal-Semantics'
}

{ #category : #correcting }
OCUndeclaredVariableWarning >> declareClassVar [

	self methodClass instanceSide
		addClassVarNamed: node name asSymbol.
	^ self lookUpVariable
]

{ #category : #correcting }
OCUndeclaredVariableWarning >> declareGlobal [

	Smalltalk at: node name asSymbol put: nil.
	^self lookUpVariable
]

{ #category : #correcting }
OCUndeclaredVariableWarning >> declareInstVar: name [
	"Declare an instance variable."
	self methodClass addInstVarNamed: name.
	"We are changing a class after the scope hierarchy was created, so we need to update the
	Instance Scope"
	self methodNode scope instanceScope slots: self methodClass allSlots.
	^ self lookUpVariable
]

{ #category : #correcting }
OCUndeclaredVariableWarning >> declareUndefined [

	Undeclared add: (#UndeclaredVariable asClass named: node name asSymbol).
	^OCUndeclaredVariable new name: node name asSymbol
]

{ #category : #correcting }
OCUndeclaredVariableWarning >> defaultAction [
	| varName className selector |
	
		className  :=  self methodClass name .
	selector := self methodNode selector. 
	varName := node name.

	#NewUndeclaredWarning asClass signal: varName in: (self methodNode selector 
		ifNotNil: [className, '>>', selector]
			ifNil: ['<unknown>']).

	^super defaultAction ifNil: [
		Undeclared add: (#UndeclaredVariable asClass named: varName asSymbol).
		OCUndeclaredVariable new name: varName asSymbol]
]

{ #category : #correcting }
OCUndeclaredVariableWarning >> defineClass: className [ 
	"Prompts the user to define a new class."
	
	| classSymbol systemCategory classDefinition |
	classSymbol := className asSymbol.
	systemCategory := self methodClass category
		ifNil: [ 'Unknown' ].
	classDefinition := 'Object subclass: #' , classSymbol , '
		instanceVariableNames: '''' 
		classVariableNames: ''''
		category: ''' , systemCategory , ''''.
	classDefinition := UIManager default 
		multiLineRequest: 'Edit class definition:'
		initialAnswer: classDefinition
		answerHeight: 150.
	(classDefinition isNil or: [ classDefinition isEmpty ])
		ifTrue: [ ^ Abort signal ].
	self class compiler
		source: classDefinition;
		logged: true;
		evaluate.
	^ (node owningScope lookupVar: className)
		ifNil: [self error: 'should be not happen']
]

{ #category : #correcting }
OCUndeclaredVariableWarning >> defineTrait: traitName [ 
	"Prompts the user to define a new trait."
	
	| traitSymbol systemCategory traitDefinition |
	traitSymbol := traitName asSymbol.
	systemCategory := self methodClass category
		ifNil: [ 'Unknown' ].
	traitDefinition := 'Trait named: #' , traitSymbol , '
		uses:{} 
		package: ''' , systemCategory , ''''.
	traitDefinition := UIManager default 
		multiLineRequest: 'Edit trait definition:'
		initialAnswer: traitDefinition
		answerHeight: 150.
	(traitDefinition isNil or: [ traitDefinition isEmpty ])
		ifTrue: [ ^ Abort signal ].
	self class compiler
		source: traitDefinition;
		logged: true;
		evaluate.
	^ (node owningScope lookupVar: traitSymbol)
		ifNil: [self error: 'should be not happen']
]

{ #category : #correcting }
OCUndeclaredVariableWarning >> lookUpVariable [
	^ (node owningScope lookupVar: node name)
		ifNil: [self error: 'should be found']
]

{ #category : #accessing }
OCUndeclaredVariableWarning >> node: aVariableNode [

	super node: aVariableNode.
	messageText := 'Undeclared temp: ', aVariableNode name.

]

{ #category : #correcting }
OCUndeclaredVariableWarning >> possibleVariablesFor: proposedVariable [ 
	| results class |
	class := node methodNode methodClass .
	
	results := proposedVariable correctAgainst: node temporaryVariables
								continuedFrom: nil.
	proposedVariable first canBeGlobalVarInitial ifTrue:
		[ results := class possibleVariablesFor: proposedVariable
						continuedFrom: results ].
	^ proposedVariable correctAgainst: nil continuedFrom: results.

]

{ #category : #correcting }
OCUndeclaredVariableWarning >> substituteVariable: varName atInterval: anInterval [ 
	self 
		substituteWord: varName
		wordInterval: anInterval
		offset: 0.
	self methodNode source: self requestor text.
	node replaceWith:((RBVariableNode named: varName) binding: (node owningScope lookupVar: varName)).
	^ (node owningScope lookupVar: varName)
		ifNil: [self error: 'should be found'].
]

{ #category : #correcting }
OCUndeclaredVariableWarning >> substituteWord: correctWord wordInterval: spot offset: o [
	"Substitute the correctSelector into the (presuamed interactive) receiver."

	self requestor correctFrom: (spot first + o)
					to: (spot last + o)
					with: correctWord.

	^ o + correctWord size - spot size
]
