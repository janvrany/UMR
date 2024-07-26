Extension { #name : #RBBlockNode }

{ #category : #'*LightOpal-Semantics' }
RBBlockNode >> enclosingMethodOrBlockNode [
	^ parent ifNotNil: [ parent methodOrBlockNode ]
]

{ #category : #'*LightOpal-Semantics' }
RBBlockNode >> ir [

	^ self propertyAt: #ir ifAbsent: [ self parent methodOrBlockNode ir ]
]

{ #category : #'*LightOpal-Semantics' }
RBBlockNode >> ir: aIRMethodNode [

	^ self propertyAt: #ir put: aIRMethodNode.
]

{ #category : #'*LightOpal-Semantics' }
RBBlockNode >> irInstruction [
	^ self parent methodOrBlockNode ir firstInstructionMatching: [:instr | instr sourceNode == self ]
]

{ #category : #'*LightOpal-Semantics' }
RBBlockNode >> isClean [
	"a block is clean if it has no escaping vars, has no non local return and its children are clean"
	self isInlined ifTrue: [ ^ false ].
	self scope hasEscapingVars ifTrue: [ ^ false ].
	self hasBlockReturn ifTrue: [ ^ false ].
	^ super isClean
	
]

{ #category : #'*LightOpal-Semantics' }
RBBlockNode >> isInlined [
	parent isMessage ifFalse: [ ^ false ].
	parent isInlineAndOr ifTrue: [^ true].
	parent isInlineIf ifTrue: [^ true].
	parent isInlineIfNil ifTrue: [^ true].
	^ self isInlinedLoop
]

{ #category : #'*LightOpal-Semantics' }
RBBlockNode >> isInlinedLoop [
	parent isMessage ifFalse: [ ^ false ].
	parent isInlineToDo ifTrue: [^ true].
	parent isInlineWhile ifTrue: [^ true].
	parent isInlineTimesRepeat ifTrue: [^ true].
	parent isInlineRepeat ifTrue: [ ^true ].
	(parent parent isSqueakArray and: [parent parent parent isMessage and: [parent parent parent isInlineCase]]) ifTrue: [^ true].
	parent isInlineCase ifTrue: [^ true].  "otherwise branch"
	^ false
]

{ #category : #'*LightOpal-Semantics' }
RBBlockNode >> owningScope [

	^ self scope ifNil: ["inlined" ^ parent owningScope]
]

{ #category : #'*LightOpal-Semantics' }
RBBlockNode >> scope [
	^ self propertyAt: #scope ifAbsent: nil

	"Created: / 24-07-2024 / 14:28:32 / Jan Vrany <jan.vrany@labware.com>"
]

{ #category : #'*LightOpal-Semantics' }
RBBlockNode >> scope: scope [
	^ self propertyAt: #scope put: scope

	"Created: / 24-07-2024 / 14:28:43 / Jan Vrany <jan.vrany@labware.com>"
]

{ #category : #'*LightOpal-Semantics' }
RBBlockNode >> sourceNodeExecutedForPC: anInteger [
	self methodNode ir.
	(self hasProperty: #ir) ifTrue: [ "FullBlockClosure"
		^(self ir fullBlockInstructionForPC: anInteger) sourceNodeExecuted ].
	^ self methodNode sourceNodeExecutedForPC: anInteger
]

{ #category : #'*LightOpal-Semantics' }
RBBlockNode >> sourceNodeForPC: anInteger [ 
	self methodNode ir.
	(self hasProperty: #ir) ifTrue: [ "FullBlockClosure"
		^(self ir fullBlockInstructionForPC: anInteger) sourceNode ].
	^ self methodNode sourceNodeForPC: anInteger
]
