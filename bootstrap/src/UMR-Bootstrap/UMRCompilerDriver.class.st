Class {
	#name : #UMRCompilerDriver,
	#superclass : #Object,
	#instVars : [
		'bootstrap',
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
UMRCompilerDriver class >> forBootstrap: anUMRBootstrap [
	^ self basicNew initializeWithBootstrap: anUMRBootstrap
]

{ #category : #compiling }
UMRCompilerDriver >> compile: anRGMethod [ 
	| compilation translator object |

	ast := anRGMethod parseTree.
	ast source: anRGMethod sourceCode.
	ast compilationContext: (UMRCompilationContext forBootstrap: bootstrap method: anRGMethod).
	OCASTSemanticAnalyzer new 
		compilationContext: ast compilationContext;
		analyze: ast.  
	
	compilation := UMRCompilation forBootstrap: bootstrap.
	translator := UMRASTTranslator forCompilation: compilation.
	translator visitNode: ast.
	
	compilation optimize.
	compilation compile.
	
	object := compilation codeBuffer.

	^ object





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

{ #category : #compiling }
UMRCompilerDriver >> compilePrim: primitiveBuilderClass [
	| compilation primitiveBuilder object |

	compilation := UMRCompilation forBootstrap: bootstrap.

	primitiveBuilder := primitiveBuilderClass forCompilation: compilation.
	primitiveBuilder build.

	compilation optimize.
	compilation compile.

	object := compilation codeBuffer.

	^ object
	
	



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
UMRCompilerDriver >> initializeWithBootstrap: anUMRBootstrap [
	bootstrap := anUMRBootstrap
]
