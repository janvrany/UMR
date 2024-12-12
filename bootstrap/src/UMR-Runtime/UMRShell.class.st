Class {
	#name : #UMRShell,
	#superclass : #TRCompilationTestShellQEMU,
	#instVars : [
		'runtime',
		'bootstrap'
	],
	#pools : [
		'GDBSignals',
		'GDBStopReasons'
	],
	#category : #'UMR-Runtime'
}

{ #category : #accessing }
UMRShell >> bootstrap [
	^ bootstrap
]

{ #category : #'event handling' }
UMRShell >> handlePrim: primNo parameters: params [
	| prim |

	prim := bootstrap primitives at: primNo ifAbsent: [ self error:'Invalid primitive ', primNo printString ].
	^ prim evalUsing: self parameters: params

	"
	debugger cli
	"
]

{ #category : #'event handling' }
UMRShell >> handleTRAP: frame [
	^ runtime target handleTRAPfor:self in: frame.
]

{ #category : #accessing }
UMRShell >> heap1 [
	heap1 isNil ifTrue: [
		heap1 := UMRCodeCache runtime: (codeCacheManager runtime) base: heap1Base size: heap1Size memory: debugger selectedInferior memory.
		codeCacheManager addSegment: heap1.
	].
	^ heap1
]

{ #category : #accessing }
UMRShell >> heap2 [
	heap2 isNil ifTrue: [
		heap2 := UMRCodeCache
				runtime: (codeCacheManager runtime)
				base: heap2Base
				size: heap2Size
				memory: debugger selectedInferior memory.
		codeCacheManager addSegment: heap2.
	].
	^ heap2
]

{ #category : #initialization }
UMRShell >> initializeWithTarget: aTRCompilationTarget [
	super initializeWithTarget: aTRCompilationTarget.
	runtime := UMRRuntime forTarget: target.
	codeCacheManager := TRCodeCacheManager runtime: runtime
]

{ #category : #accessing }
UMRShell >> memory [
	^ debugger selectedInferior memory
]

{ #category : #accessing }
UMRShell >> nzone1 [
	nzone1 isNil ifTrue: [
		nzone1 := UMRCodeCache runtime: (codeCacheManager runtime) base: nzone1Base size: nzone1Size memory: debugger selectedInferior memory.
		codeCacheManager addSegment: nzone1.
	].
	^ nzone1
]

{ #category : #accessing }
UMRShell >> nzone2 [
	nzone2 isNil ifTrue: [
		nzone2 := UMRCodeCache runtime: (codeCacheManager runtime) base: nzone2Base size: nzone2Size memory: debugger selectedInferior memory.
		codeCacheManager addSegment: nzone2.
	].
	^ nzone2
]

{ #category : #running }
UMRShell >> run [
	"Run the code injected into the shell. Return the exit status code once
	 it finishes."

	| stop done |

	self entry: (self nzone1 exports at: (TRFunctionSymbol name: 'main' type: (TRDataType named: 'Int32') linkage:nil)).

	"
	debugger cli
	"
	done := false.
	[ done  ] whileFalse: [
		stop := self debugger send: 'c' andWaitFor: GDBThreadGroupExitedEvent , GDBStoppedEvent.
		stop reason = Exited ifTrue: [
			done := true.
		] ifFalse: [
		(stop reason = SignalReceived and:[stop signal = GDB_SIGNAL_TRAP]) ifTrue: [
			"Got SIGTRAP, might be this is semihosting call?"
			self handleTRAP: stop frame.
		] ifFalse: [
			self assert: false description: 'Unexpected stop (crash or leftover breakpoint?'.
		]].
	].


	"
	self debugger cli
	"
	self assert: stop reason equals: Exited.
	^ stop exitCode
]

{ #category : #accessing }
UMRShell >> runtime [
	^ runtime
]

{ #category : #initialization }
UMRShell >> setBootstrap: anUMRBootstrap [
	bootstrap := anUMRBootstrap
]

{ #category : #'running-private' }
UMRShell >> setUpDebuggerOnHost: host port: port [
	super setUpDebuggerOnHost: host port: port.

	self assert: (Smalltalk includesKey: #GDBDebugger).
	self assert:((Smalltalk getPackageDirectoryForPackage: UMRShell package) / '..' / '..' / '..' / 'shell' / 'shell-gdb.py') exists.

	"debugger cli"
	debugger send: 'source ', ((Smalltalk getPackageDirectoryForPackage: UMRShell package) / '..' / '..' / '..' / 'shell' / 'shell-gdb.py') pathName.
]
