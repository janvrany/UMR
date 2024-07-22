"
Cluster is just a bunch of packages, all in the same environment

"
Class {
	#name : #UMRCluster,
	#superclass : #RGPackage,
	#instVars : [
		'packages'
	],
	#category : #'UMR-ProgramDefinition'
}

{ #category : #accessing }
UMRCluster >> initializer: anMTInitializer [
	self shouldNotImplement
]
