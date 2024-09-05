Class {
	#name : #UMRShell,
	#superclass : #TRCompilationTestShellQEMU,
	#category : #'UMR-Runtime'
}

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
		heap2 := UMRCodeCache runtime: (codeCacheManager runtime) base: heap2Base size: heap2Size memory: debugger selectedInferior memory.
		codeCacheManager addSegment: heap1.
	].
	^ heap2
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

{ #category : #'running-private' }
UMRShell >> setUpDebuggerOnHost: host port: port [
	super setUpDebuggerOnHost: host port: port.

	self assert: (Smalltalk includesKey: #GDBDebugger).
	self assert:((Smalltalk getPackageDirectoryForPackage: UMRShell package) / '..' / '..' / '..' / 'shell' / 'shell-gdb.py') exists.

	"debugger cli"
	debugger send: 'source ', ((Smalltalk getPackageDirectoryForPackage: UMRShell package) / '..' / '..' / '..' / 'shell' / 'shell-gdb.py') pathName.
]
