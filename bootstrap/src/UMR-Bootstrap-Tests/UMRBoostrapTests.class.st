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
	| program bootstrap exit |

	program := UMRModuleReader readFrom:('Program named:''', testSelector , ''' initializer:[ 42 ] !') readStream.
	bootstrap := UMRBootstrap forProgram: program target: target.

	bootstrap bootstrap.
	bootstrap writeCodeTo: shell nzone.
	bootstrap writeHeapTo: shell nzone.

	shell entry: (shell nzone exports at: (TRFunctionSymbol name: 'main' type: (TRDataType named: 'Int32') linkage:nil)).
	"
	shell debugger cli
	"
	exit := shell debugger send: 'c' andWaitFor: GDBThreadGroupExitedEvent , GDBStoppedEvent.

	self assert: exit exitCode equals: (42 << 1) | 1
]

{ #category : #tests }
UMRBoostrapTests >> test02_simple [
	| program bootstrap exit |

	program := UMRModuleLoader new loadProgram: 'SimpleProgram'.
	bootstrap := UMRBootstrap forProgram: program target: target.

	bootstrap bootstrap.
	bootstrap writeCodeTo: shell nzone.
	bootstrap writeHeapTo: shell heap1.

	shell entry: (shell nzone exports at: (TRFunctionSymbol name: 'main' type: (TRDataType named: 'Int32') linkage:nil)).
	"
	shell debugger cli
	"
	exit := shell debugger send: 'c' andWaitFor: GDBThreadGroupExitedEvent, GDBStoppedEvent.

	self assert: exit class equals: GDBThreadGroupExitedEvent.
	self assert: exit exitCode equals: (42 << 1) | 1
]
