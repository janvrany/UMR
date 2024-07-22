Class {
	#name : #UMRInitializer,
	#superclass : #RGMethod,
	#category : #'UMR-ProgramDefinition'
}

{ #category : #initialization }
UMRInitializer >> initialize [
	super initialize.
	name := '<minit>'
]

{ #category : #'queries - class' }
UMRInitializer >> methodClass [
	^RGClass unresolved 
		parent: self environment;
		yourself
]

{ #category : #accessing }
UMRInitializer >> parseTree [
	| statements |

	statements := RBParser parseExpression: self sourceCode onError: [ :msg :pos | ^ nil ].
	statements isSequence ifFalse:[
		statements := RBSequenceNode statements: { statements }.
	].
	^ (RBMethodNode selector: #initialize body: statements) addReturn; yourself.
]

{ #category : #accessing }
UMRInitializer >> sourceCode [
	^ sourceCode
]

{ #category : #accessing }
UMRInitializer >> sourceCode: anObject [
	sourceCode := anObject asString
]
