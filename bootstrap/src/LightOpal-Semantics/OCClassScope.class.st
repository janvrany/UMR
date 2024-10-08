"
I include all variable enries for class, pool and global vars.
"
Class {
	#name : #OCClassScope,
	#superclass : #OCAbstractScope,
	#instVars : [
		'class'
	],
	#category : #'LightOpal-Semantics'
}

{ #category : #'instance creation' }
OCClassScope class >> for: aClass [
	^self new 
		class: aClass;
		yourself
]

{ #category : #accessing }
OCClassScope >> class: aBehavior [

	class := aBehavior
]

{ #category : #accessing }
OCClassScope >> environment [
	^class classPool
]

{ #category : #lookup }
OCClassScope >> findVariable: lookupBlock ifNone: notFoundBlock [ 

	^class findGlobalVariable: lookupBlock ifNone: notFoundBlock
]

{ #category : #accessing }
OCClassScope >> getClass [
	^class
]

{ #category : #levels }
OCClassScope >> instanceScope [

	^ OCInstanceScope new
		slots: class allSlots;
		outerScope: self;
		yourself
]

{ #category : #lookup }
OCClassScope >> lookupVar: name [
	"Return a SemVar for my pool var with this name.  Return nil if none found"

	^(class innerBindingOf: name asSymbol) 
		ifNotNil: [:assoc | OCLiteralVariable new 
			assoc: assoc; 
			scope: self; 
			yourself]
		ifNil: [ outerScope lookupVar: name] 
]

{ #category : #lookup }
OCClassScope >> lookupVarForDeclaration: name [
	^self lookupVar: name
]

{ #category : #levels }
OCClassScope >> newMethodScope [
	^ self instanceScope newMethodScope
]

{ #category : #printing }
OCClassScope >> printOn: stream [

	class printOn: stream.
]
