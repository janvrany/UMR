Class {
	#name : #UMRModule,
	#superclass : #RGPackage,
	#instVars : [
		'initializer'
	],
	#category : #'UMR-ProgramDefinition'
}

{ #category : #accessing }
UMRModule >> initializer [
	^ initializer
]

{ #category : #accessing }
UMRModule >> initializer: anMTInitializer [
	initializer := anMTInitializer.
	initializer parent: self.
]

{ #category : #testing }
UMRModule >> isPackage [
	^ false
]

{ #category : #testing }
UMRModule >> isProgram [
	^ false
]
