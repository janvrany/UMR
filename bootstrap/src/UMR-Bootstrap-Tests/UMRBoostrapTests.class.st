Class {
	#name : #UMRBoostrapTests,
	#superclass : #TestCaseParametrized,
	#instVars : [
		'target',
		'shell'
	],
	#category : #'UMR-Bootstrap-Tests'
}

{ #category : #running }
UMRBoostrapTests >> setUp [
	target := TRRV64GLinux default.
	shell := UMRShell forTarget: target.
]

{ #category : #running }
UMRBoostrapTests >> tearDown [
	super tearDown.
	shell notNil ifTrue: [ 
		shell tearDown.
		shell := nil.
	].
]

{ #category : #tests }
UMRBoostrapTests >> test01_meaningOfWorld [
	| program bootstrap |

	program := UMRModuleReader readFrom:('Program named:''', testSelector , ''' initializer:[ 42 ] !') readStream.
	bootstrap := UMRBootstrap forProgram: program target: target.
	shell setBootstrap: bootstrap.


	bootstrap bootstrap.
	bootstrap writeCodeTo: shell nzone.
	bootstrap writeHeapTo: shell nzone.


	self assert: shell run equals: (42 << 1) | 1
]

{ #category : #tests }
UMRBoostrapTests >> test02_simple [
	| program bootstrap |

	program := UMRModuleLoader new loadProgram: 'SimpleProgram'.
	bootstrap := UMRBootstrap forProgram: program target: target.
	shell setBootstrap: bootstrap.

	bootstrap bootstrap.
	bootstrap writeCodeTo: shell nzone.
	bootstrap writeHeapTo: shell heap1.

	self assert: shell run equals: (0 << 1) | 1
]
