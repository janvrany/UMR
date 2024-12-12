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
UMRCompilerDriver >> compileMethod: anRGMethod [
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
UMRCompilerDriver >> compilePrim: primitive [
	| compilation builder object |

	compilation := UMRCompilation forBootstrap: bootstrap.

	builder := UMRPrimitiveBuilder forCompilation: compilation.
	primitive compileUsing: builder.

	compilation optimize.
	compilation compile.

	object := compilation codeBuffer.

	^ object
]

{ #category : #initialization }
UMRCompilerDriver >> initializeWithBootstrap: anUMRBootstrap [
	bootstrap := anUMRBootstrap
]
