Class {
	#name : #'UMRPrimitive_primSaySomething',
	#superclass : #UMRPrimitive,
	#pools : [
		'TRDataTypes'
	],
	#category : #'UMR-Bootstrap-Primitives'
}

{ #category : #'shell interface' }
UMRPrimitive_primSaySomething >> evalUsing: shell parameters: params [
	Transcript show: 'Hello UMR!'.
	^ 0
]

{ #category : #accessing }
UMRPrimitive_primSaySomething >> name [
	^ 'primSaySomething'
]

{ #category : #accessing }
UMRPrimitive_primSaySomething >> numArgs [
	^ 1 "self"
]
