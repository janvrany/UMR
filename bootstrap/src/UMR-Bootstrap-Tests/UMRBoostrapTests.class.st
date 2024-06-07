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
	shell := TRCompilationTestShell forTarget: target.
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

	exit := shell debugger send: 'c' andWaitFor: GDBThreadGroupExitedEvent.

	self assert: exit exitCode equals: (42 << 1) | 1
]
