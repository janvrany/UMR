Extension { #name : #RBProgramNodeVisitor }

{ #category : #'*LightOpal-AST-SmalltalkX' }
RBProgramNodeVisitor >> visitArgumentNode: node [
	^ self acceptVariableNode: node
]

{ #category : #'*LightOpal-AST-SmalltalkX' }
RBProgramNodeVisitor >> visitGlobalNode: node [
	^ self acceptVariableNode: node
]

{ #category : #'*LightOpal-AST-SmalltalkX' }
RBProgramNodeVisitor >> visitSelfNode: node [
	^ self acceptVariableNode: node
]

{ #category : #'*LightOpal-AST-SmalltalkX' }
RBProgramNodeVisitor >> visitSuperNode: node [
	^ self acceptVariableNode: node
]

{ #category : #'*LightOpal-AST-SmalltalkX' }
RBProgramNodeVisitor >> visitTemporaryNode: node [
	^ self acceptVariableNode: node
]

{ #category : #'*LightOpal-AST-SmalltalkX' }
RBProgramNodeVisitor >> visitThisContextNode: node [
	^ self acceptVariableNode: node
]
