Extension { #name : #RBProgramNode }

{ #category : #'*LightOpal-Semantics' }
RBProgramNode >> asDoit [
	"The VM can only evaluate methods. wrap this ast in a doit MethodNode"
	^RBMethodNode 
		selector: #DoIt
		body: self asSequenceNode transformLastToReturn.
]

{ #category : #'*LightOpal-Semantics' }
RBProgramNode >> asDoitForContext: aContext [
	"The VM can only evaluate methods. wrap this ast in a doitIn MethodNode to evaluate in a context"
	| methodNode |
	
	methodNode := RBMethodNode 
		selector: #DoItIn:
		arguments: { RBVariableNode named: 'ThisContext' } 
		body: self asSequenceNode transformLastToReturn.
	
	methodNode methodClass: aContext receiver class.
	methodNode rewriteTempsForContext: aContext.
	^methodNode
		
	
]

{ #category : #'*LightOpal-Semantics' }
RBProgramNode >> asSequenceNode [
	^RBSequenceNode statements: {self} 
]

{ #category : #'*LightOpal-Semantics' }
RBProgramNode >> doSemanticAnalysis [
	self methodNode ifNil: [ ^self ].
	^ self methodNode doSemanticAnalysis.
	
]

{ #category : #'*LightOpal-Semantics' }
RBProgramNode >> doSemanticAnalysisIn: aClass [
	self methodNode ifNil: [ ^self ].
	^ self methodNode doSemanticAnalysisIn: aClass
]

{ #category : #'*LightOpal-Semantics' }
RBProgramNode >> enclosingMethodOrBlockNode [
	^ self methodOrBlockNode 
]

{ #category : #'*LightOpal-Semantics' }
RBProgramNode >> irInstruction [
	^ self methodOrBlockNode ir firstInstructionMatching: [:instr | instr sourceNode == self ]
]

{ #category : #'*LightOpal-Semantics' }
RBProgramNode >> isClean [
	^ self children allSatisfy: [ :child | child isClean ]
]

{ #category : #'*LightOpal-Semantics' }
RBProgramNode >> owningScope [

	^ parent owningScope 
]

{ #category : #'*LightOpal-Semantics' }
RBProgramNode >> printAsIfCompiledOn: aStream [ 
	aStream nextPutAll: self formattedCode
]

{ #category : #'*LightOpal-Semantics' }
RBProgramNode >> scope [
	parent isNil ifTrue: [ ^ nil ].
	^ parent scope

	"Created: / 24-07-2024 / 14:27:01 / Jan Vrany <jan.vrany@labware.com>"
]
