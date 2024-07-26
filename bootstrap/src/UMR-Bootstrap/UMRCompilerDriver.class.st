Class {
	#name : #UMRCompilerDriver,
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
UMRCompilerDriver class >> forTarget: target [
	^ self basicNew initializeWithTarget: target
]

{ #category : #compiling }
UMRCompilerDriver >> compile: anRGMethod [ 
	| compilation translator |

	ast := anRGMethod parseTree.
	ast compilationContext: (CompilationContext new).
	ast compilationContext 
			environment: anRGMethod methodClass environment;
			class: anRGMethod methodClass.
	OCASTSemanticAnalyzer new 
		compilationContext: ast compilationContext;
		analyze: ast.  
	
	compilation := TRCompilation forTarget: target.     
	translator := UMRASTTranslator forCompilation: compilation.
	translator visitNode: ast.
	
	compilation optimize.
	compilation compile.
	
	^ UMRCodeObject forMethod: anRGMethod code: compilation codeBuffer  
	
	



	"
	| compilation |

	compilation := TRCompilation forTarget: target.
	method := anRGMethod.
	ast := method parseTree.
	ir := 
	ast acceptVisitor: self.
	compilation optimize.
	compilation compile.
	
	"
]

{ #category : #initialization }
UMRCompilerDriver >> initializeWithTarget: targetArg [
	target := targetArg
]
