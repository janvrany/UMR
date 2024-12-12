Class {
	#name : #UMRPrimitive,
	#superclass : #Object,
	#pools : [
		'TRDataTypes'
	],
	#category : #'UMR-Bootstrap-Primitives'
}

{ #category : #'compiler interface' }
UMRPrimitive >> callUsing: bldr [
	| paramSymbols paramValues |

	paramSymbols := bldr compilation symbolManager lookupSymbolsByType: TRParameterSymbol.
	paramSymbols := paramSymbols sorted: [ :a :b | a index < b index ].
	paramValues := paramSymbols collect: [ :param | bldr aload: param name ].

	^ self callUsing: bldr parameters: paramValues
]

{ #category : #'compiler interface' }
UMRPrimitive >> callUsing: bldr parameters: params [
	"Call the primitive with given parameters. Return
	 the result.

	 Note, that for now there's no support for primitive
	 to fail!
	"
	self assert: params size == self numArgs.

	bldr defineFunction: self name type: Address.
	^ bldr acall: params , { self name }
]

{ #category : #'compiler interface' }
UMRPrimitive >> compileUsing: bldr [
	| params primNo |

	bldr defineFunction: self name , 'Impl' type: Address linkage: TRRV64GSemihostingLinkage.
	bldr defineName: self name asString type: Address.
	(1 to: self numArgs) collect: [ :i | bldr defineParameter: 'a', i printString type: Address ].

	primNo := bldr compilation primitiveIndex: self name.
	params := (1 to: self numArgs) collect: [ :i | bldr aload: 'a', i printString ].

	bldr areturn: {
		bldr acall: { bldr iconst: primNo } , params , { self name , 'Impl' }
	}
]

{ #category : #'shell interface' }
UMRPrimitive >> evalUsing: shell parameters: params [
	^ self subclassResponsibility
]

{ #category : #accessing }
UMRPrimitive >> name [
	^ self subclassResponsibility
]

{ #category : #accessing }
UMRPrimitive >> numArgs [
	self subclassResponsibility
]
