Class {
	#name : #'UMRPrimitive_mbind',
	#superclass : #UMRPrimitive,
	#pools : [
		'TRDataTypes'
	],
	#category : #'UMR-Bootstrap-Primitives'
}

{ #category : #'compiler interface' }
UMRPrimitive_mbind >> compileUsing: bldr [
	| ofmt |

	bldr defineName: self name asString type: Address.
	bldr defineParameter: 'receiver' type: Address.
	bldr defineParameter: 'selector' type: Address.
	bldr defineParameter: 'nargs' type: Int32.

	bldr defineAutomatic: 'class' type: Address.
	bldr defineAutomatic: 'md' type: Address.
	bldr defineAutomatic: 'l' type: Int32.
	bldr defineAutomatic: 'i' type: Int32.

	ofmt := bldr compilation objectFormat.

	bldr astore: {
		ofmt loadClassOf: ( bldr aload: 'receiver' ) using: bldr .
		"-->" 'class' }.

	bldr astore: {
		ofmt loadSlotAt: (bldr iconst: 2"BOGUS, should ask env") of: ( bldr aload: 'class' ) using: bldr.
		"-->" 'md' }.

	bldr istore: {
		bldr iconst: 1.
		"-->" 'i' }.

	bldr istore: {
		ofmt loadSizeInSlotsOf: ( bldr aload: 'md' ) using: bldr .
		"-->" 'l' }.

	bldr while: (bldr icmplt: { bldr iload: 'i' . bldr iload: 'l' }) do: [:body |
		| selectorInMd |

		selectorInMd := ofmt loadSlotAt: ( body iload: 'i' ) of: ( body aload: 'md' ) using: body.

		body if: (body acmpeq: { selectorInMd . body aload: 'selector' }) then: [ :then |
			| method code |

			method := ofmt loadSlotAt: ( then iadd: { then iload: 'i' . then iconst: 1 } ) of: ( then aload: 'md' ) using: then.
			code := ofmt loadSlotAt: ( then iconst: 2 ) of: method using: then.
			then areturn: { code }.
		].

		body istore: {
			body iadd: { body iload: 'i' . body iconst: 2 } .
			"-->" 'i' }.
	].

	bldr areturn: { bldr aconst: 0 }
]

{ #category : #accessing }
UMRPrimitive_mbind >> name [
	^ 'mbind'
]

{ #category : #accessing }
UMRPrimitive_mbind >> numArgs [
	^ 3
]
