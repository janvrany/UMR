Class {
	#name : #UMRModuleBackend,
	#superclass : #RGEnvironmentBackend,
	#category : #'UMR-ProgramDefinition'
}

{ #category : #environment }
UMRModuleBackend >> addImport: anUMRBehaviorImport to: anUMRModule [

	^ anUMRModule pvtAddImport: anUMRBehaviorImport
]

{ #category : #environment }
UMRModuleBackend >> importsFor: anUMRModule do: aBlock [

	^  anUMRModule pvtImportsDo: aBlock
]
