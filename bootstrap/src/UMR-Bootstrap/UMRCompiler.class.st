Class {
	#name : #UMRCompiler,
	#superclass : #RBProgramNodeVisitor,
	#instVars : [
		'target',
		'method',
		'ast',
		'ir'
	],
	#pools : [
		'TRDataTypes'
	],
	#category : #'UMR-Bootstrap-Compiler'
}

{ #category : #'instance creation' }
UMRCompiler class >> forTarget: target [
	^ self basicNew initializeWithTarget: target
]

{ #category : #'visiting - Smalltalk/X compatibility' }
UMRCompiler >> acceptLiteralNode: node [
	^ self visitLiteralNode: node
]

{ #category : #'visiting - Smalltalk/X compatibility' }
UMRCompiler >> acceptMethodNode: node [
	^ self visitMethodNode: node
]

{ #category : #'visiting - Smalltalk/X compatibility' }
UMRCompiler >> acceptReturnNode: node [
	^ self visitReturnNode: node
]

{ #category : #'visiting - Smalltalk/X compatibility' }
UMRCompiler >> acceptSequenceNode: node [
	^ self visitSequenceNode: node
]

{ #category : #compiling }
UMRCompiler >> compile: anRGMethod [ 
	| compilation |

	compilation := TRCompilation forTarget: target.
	method := anRGMethod.
	ast := method parseTree.
	ir := UMRMethodBuilder forCompilation: compilation.
	ast acceptVisitor: self.
	compilation optimize.
	compilation compile.
	^ UMRCodeObject forMethod: anRGMethod code: compilation codeBuffer
]

{ #category : #initialization }
UMRCompiler >> initializeWithTarget: targetArg [
	target := targetArg
]

{ #category : #visiting }
UMRCompiler >> visitLiteralNode: node [
	node value isInteger ifTrue: [ 
		^ ir aconst: (node value << 1) | 1
	].
	self error: 'Unsupported literal value'
]

{ #category : #visiting }
UMRCompiler >> visitMethodNode: node [
	self assert: node == ast.

	ir defineName: method printString type: Address.
	ir defineParameter: 'self' type: Address.
	node arguments do: [:arg | 
		ir defineParameter: arg name type: Address.
	].

	node body acceptVisitor: self.

	^ nil



	"Modified: / 22-09-2015 / 18:00:43 / Jan Vrany <jan.vrany@fit.cvut.cz>"
]

{ #category : #visiting }
UMRCompiler >> visitNode: aNode [ 
	self shouldImplement: thisContext sender selector
]

{ #category : #visiting }
UMRCompiler >> visitReturnNode: node [
	ir areturn: { node value acceptVisitor: self }
]

{ #category : #visiting }
UMRCompiler >> visitSequenceNode: node [
	node statements do: [:statement | 
		statement acceptVisitor: self.
		statement isReturn ifTrue: [ ^ nil ].
	].

	^ nil
]
