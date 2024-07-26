Class {
	#name : #OCASTVisitor,
	#superclass : #Object,
	#category : #'LightOpal-AST-Visitors'
}

{ #category : #visiting }
OCASTVisitor >> visitArgumentNode: anArgumentNode [
	"Sent *each time* an argument node is found"

	^ self visitVariableNode: anArgumentNode
]

{ #category : #visiting }
OCASTVisitor >> visitArgumentNodes: aNodeCollection [
	"Sent *once* when visiting method and block nodes"

	^ aNodeCollection do: [ :each | self visitArgumentNode: each ]
]

{ #category : #visiting }
OCASTVisitor >> visitArrayNode: anArrayNode [
	anArrayNode children do: [ :each | self visitNode: each ]
]

{ #category : #visiting }
OCASTVisitor >> visitAssignmentNode: anAssignmentNode [
	self visitNode: anAssignmentNode variable.
	self visitNode: anAssignmentNode value
]

{ #category : #visiting }
OCASTVisitor >> visitBlockNode: aBlockNode [
	self visitArgumentNodes: aBlockNode arguments.
	self visitNode: aBlockNode body
]

{ #category : #visiting }
OCASTVisitor >> visitCascadeNode: aCascadeNode [
	aCascadeNode messages do: [ :each | self visitNode: each ]
]

{ #category : #visiting }
OCASTVisitor >> visitGlobalNode: aSelfNode [
	^ self visitVariableNode: aSelfNode
]

{ #category : #visiting }
OCASTVisitor >> visitInstanceVariableNode: aSelfNode [
	^ self visitVariableNode: aSelfNode
]

{ #category : #visiting }
OCASTVisitor >> visitLiteralArrayNode: aRBLiteralArrayNode [
	aRBLiteralArrayNode contents do: [ :each | self visitNode: each ]
]

{ #category : #visiting }
OCASTVisitor >> visitLiteralNode: aLiteralNode [
	
]

{ #category : #visiting }
OCASTVisitor >> visitLiteralValueNode: aRBLiteralValueNode [
	"Redirect the message by default to #visitLiteralNode: for retrocompatibility (pharo 8)"

	^ self visitLiteralNode: aRBLiteralValueNode
]

{ #category : #visiting }
OCASTVisitor >> visitMessageNode: aMessageNode [
	(aMessageNode isCascaded not or: [ aMessageNode isFirstCascaded ])
		ifTrue: [ self visitNode: aMessageNode receiver ].
	aMessageNode arguments do: [ :each | self visitNode: each ]
]

{ #category : #visiting }
OCASTVisitor >> visitMethodNode: aMethodNode [
	self visitArgumentNodes: aMethodNode arguments.
	aMethodNode pragmas do: [ :each | self visitNode: each ].
	self visitNode: aMethodNode body
]

{ #category : #visiting }
OCASTVisitor >> visitNode: aNode [
	^ aNode acceptVisitor: self
]

{ #category : #visiting }
OCASTVisitor >> visitParseErrorNode: anErrorNode [
	
]

{ #category : #visiting }
OCASTVisitor >> visitPatternBlockNode: aRBPatternBlockNode [
	self visitArgumentNodes: aRBPatternBlockNode arguments.
	self visitNode: aRBPatternBlockNode body
]

{ #category : #visiting }
OCASTVisitor >> visitPatternWrapperBlockNode: aRBPatternWrapperBlockNode [
	self visitNode: aRBPatternWrapperBlockNode wrappedNode.
	self visitArgumentNodes: aRBPatternWrapperBlockNode arguments.
	self visitNode: aRBPatternWrapperBlockNode body
]

{ #category : #visiting }
OCASTVisitor >> visitPragmaNode: aPragmaNode [
	aPragmaNode arguments do: [ :each | self visitNode: each ]
]

{ #category : #visiting }
OCASTVisitor >> visitReturnNode: aReturnNode [
	^ self visitNode: aReturnNode value
]

{ #category : #visiting }
OCASTVisitor >> visitSelfNode: aSelfNode [
	^ self visitVariableNode: aSelfNode
]

{ #category : #visiting }
OCASTVisitor >> visitSequenceNode: aSequenceNode [
	self visitTemporaryNodes: aSequenceNode temporaries.
	aSequenceNode statements do: [ :each | self visitNode: each ]
]

{ #category : #visiting }
OCASTVisitor >> visitSuperNode: aSuperNode [
	^ self visitVariableNode: aSuperNode
]

{ #category : #visiting }
OCASTVisitor >> visitTemporaryDeclarationNode: aTemporaryDeclarationNode [
	"| temp |
	temp is a temporary node as we can find in the body of methods, but it can't be visited the same way.
	Redirect the message on argumentNodeVisitor as a way to keep retrocompatibility"

	^ self visitArgumentNode: aTemporaryDeclarationNode
]

{ #category : #visiting }
OCASTVisitor >> visitTemporaryNode: aNode [
	"Sent *each time* a temporary node is found"

	^ self visitVariableNode: aNode
]

{ #category : #visiting }
OCASTVisitor >> visitTemporaryNodes: aNodeCollection [
	"This is triggered when defining the temporaries between the pipes"

	^ aNodeCollection
		do: [ :each | self visitTemporaryDeclarationNode: each ]
]

{ #category : #visiting }
OCASTVisitor >> visitThisContextNode: aThisContextNode [
	^ self visitVariableNode: aThisContextNode
]

{ #category : #visiting }
OCASTVisitor >> visitVariableNode: aVariableNode [
	^ aVariableNode
]
