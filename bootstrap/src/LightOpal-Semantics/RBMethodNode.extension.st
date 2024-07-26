Extension { #name : #RBMethodNode }

{ #category : #'*LightOpal-Semantics' }
RBMethodNode >> doSemanticAnalysis [

	self compilationContext ifNil: [ self methodClass: nil class ].

	self
		compilationContext semanticAnalyzerClass new
			compilationContext: self compilationContext;
			analyze: self
]

{ #category : #'*LightOpal-Semantics' }
RBMethodNode >> doSemanticAnalysisIn: behavior [
	behavior ifNotNil: [self methodClass: behavior].
	self doSemanticAnalysis
]

{ #category : #'*LightOpal-Semantics' }
RBMethodNode class >> errorMethodNode: selector errorMessage: messageText [	
	| message |
	message := RBMessageNode 
		receiver: RBSelfNode new
		selector: #error: 
		arguments: {RBLiteralNode value: messageText}.
	^ self 
		selector: selector 
		arguments: ((1 to: selector numArgs) collect: [ :i | RBArgumentNode named: 't' , i asString ]) 
		body: (RBSequenceNode statements: {message}) 
]

{ #category : #'*LightOpal-Semantics' }
RBMethodNode >> methodProperties [
	^self propertyAt: #methodProperties ifAbsent: nil
]

{ #category : #'*LightOpal-Semantics' }
RBMethodNode >> methodPropertyAt: aKey [
	
	^self methodPropertyAt: aKey ifAbsent: [ self error: 'Property not found' ]
]

{ #category : #'*LightOpal-Semantics' }
RBMethodNode >> methodPropertyAt: aKey ifAbsent: absentBlock [
	| existingProperties |
	existingProperties := self propertyAt: #methodProperties ifAbsent: absentBlock.
	
	^existingProperties propertyAt: aKey ifAbsent: absentBlock
]

{ #category : #'*LightOpal-Semantics' }
RBMethodNode >> notShadowedTemporaryNamesFrom: aContext [
	| ownVariableNames |
	ownVariableNames := self allDefinedVariables collect: [ :var | var asString ].
	^ aContext tempNames difference: ownVariableNames

]

{ #category : #'*LightOpal-Semantics' }
RBMethodNode >> owningScope [
	^ self scope
]

{ #category : #'*LightOpal-Semantics' }
RBMethodNode >> rewriteTempsForContext: aContext [
	| rewriter contextOnlyTemps |
	rewriter := RBParseTreeRewriter new.
	contextOnlyTemps := self notShadowedTemporaryNamesFrom: aContext.
	aContext tempNames do:
			[ :tempName | 
			(contextOnlyTemps includes: tempName)
				ifTrue:
					[ rewriter
						replace: tempName , ' := ``@object' with: 'ThisContext tempNamed: ', tempName asString printString  , ' put: ``@object';
						replace: tempName with: 'ThisContext tempNamed: ' , tempName asString printString ] ].
	^ rewriter
		executeTree: self;
		tree
]

{ #category : #'*LightOpal-Semantics' }
RBMethodNode >> scope [
	^ self propertyAt: #scope ifAbsent: nil

	"Created: / 24-07-2024 / 14:28:32 / Jan Vrany <jan.vrany@labware.com>"
]

{ #category : #'*LightOpal-Semantics' }
RBMethodNode >> scope: scope [
	^ self propertyAt: #scope put: scope

	"Created: / 24-07-2024 / 14:28:43 / Jan Vrany <jan.vrany@labware.com>"
]

{ #category : #'*LightOpal-Semantics' }
RBMethodNode >> startWithoutParentheses [
	^ 1
]
