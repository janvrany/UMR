Class {
	#name : #UMRObjectFormat,
	#superclass : #Object,
	#instVars : [
		'target'
	],
	#category : #'UMR-Bootstrap-Objects'
}

{ #category : #'instance creation' }
UMRObjectFormat class >> forTarget: aTRTarget [
	^ self basicNew initalizeWithTarget: aTRTarget
]

{ #category : #queries }
UMRObjectFormat class >> isAbstract [
	"Return if this class is an abstract class.
	 True is returned here for myself only; false for subclasses.
	 Abstract subclasses must redefine this again."

	^ self == UMRObjectFormat.
]

{ #category : #'instance creation' }
UMRObjectFormat class >> new [
	^ self shouldNotImplement "Use forTarget: instead"
]

{ #category : #initialization }
UMRObjectFormat >> initalizeWithTarget: aTRTarget [
	target := aTRTarget
]
