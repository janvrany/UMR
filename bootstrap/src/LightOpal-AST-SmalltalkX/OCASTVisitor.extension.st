Extension { #name : #OCASTVisitor }

{ #category : #'*LightOpal-AST-SmalltalkX' }
OCASTVisitor >> acceptArrayNode: node [
	^ self visitArrayNode: node
]

{ #category : #'*LightOpal-AST-SmalltalkX' }
OCASTVisitor >> acceptAssignmentNode: node [
	^ self visitAssignmentNode: node
]

{ #category : #'*LightOpal-AST-SmalltalkX' }
OCASTVisitor >> acceptBlockNode: node [
	^ self visitBlockNode: node
]

{ #category : #'*LightOpal-AST-SmalltalkX' }
OCASTVisitor >> acceptCascadeNode: node [
	^ self visitCascadeNode: node
]

{ #category : #'*LightOpal-AST-SmalltalkX' }
OCASTVisitor >> acceptLiteralNode: node [
	^ self visitLiteralNode: node
]

{ #category : #'*LightOpal-AST-SmalltalkX' }
OCASTVisitor >> acceptMessageNode: node [
	^ self visitMessageNode: node
]

{ #category : #'*LightOpal-AST-SmalltalkX' }
OCASTVisitor >> acceptMethodNode: node [
	^ self visitMethodNode: node
]

{ #category : #'*LightOpal-AST-SmalltalkX' }
OCASTVisitor >> acceptOptimizedNode: node [
	^ self visitOptimizedNode: node
]

{ #category : #'*LightOpal-AST-SmalltalkX' }
OCASTVisitor >> acceptPragmaNode: node [
	^ self visitPragmaNode: node
]

{ #category : #'*LightOpal-AST-SmalltalkX' }
OCASTVisitor >> acceptReturnNode: node [
	^ self visitReturnNode: node
]

{ #category : #'*LightOpal-AST-SmalltalkX' }
OCASTVisitor >> acceptSTXPrimitiveCCodeNode: node [
	^ self visitSTXPrimitiveCCodeNode: node
]

{ #category : #'*LightOpal-AST-SmalltalkX' }
OCASTVisitor >> acceptSTXPrimitiveValueCCodeNode: node [
	^ self visitSTXPrimitiveValueCCodeNode: node
]

{ #category : #'*LightOpal-AST-SmalltalkX' }
OCASTVisitor >> acceptSequenceNode: node [
	^ self visitSequenceNode: node
]

{ #category : #'*LightOpal-AST-SmalltalkX' }
OCASTVisitor >> acceptVariableNode: node [
	^ self visitVariableNode: node
]
