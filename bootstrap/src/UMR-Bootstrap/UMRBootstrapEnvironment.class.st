Class {
	#name : #UMRBootstrapEnvironment,
	#superclass : #UMRSubsystem,
	#category : #'UMR-Bootstrap'
}

{ #category : #'adding & removing' }
UMRBootstrapEnvironment >> addSubsystem: anUMRSubsystem [
	self error: 'Cannot add subsystem to bootstrap environment. See #setProgramm:'


	"Modified: / 22-12-2020 / 10:59:15 / Jan Vrany <jan.vrany@labware.com>"
]

{ #category : #'private - backend interface' }
UMRBootstrapEnvironment >> pvtAddSubsystem: subsystem [
	self error: 'Cannot add subsystem to bootstrap environment. See #setProgramm:'
]

{ #category : #'private - backend interface' }
UMRBootstrapEnvironment >> pvtSetProgram: anUMRProgram [
	subsystems isRingResolved ifFalse: [
		self pvtCleanSubsystems ].

	subsystems := self defaultSubsystems add: anUMRProgram; yourself.
	"self announcer subsystemAdded: subsystem"
]

{ #category : #'adding & removing' }
UMRBootstrapEnvironment >> setProgram: anUMRProgram [
	self pvtSetProgram: anUMRProgram.



	"Modified: / 22-12-2020 / 10:59:15 / Jan Vrany <jan.vrany@labware.com>"
]
