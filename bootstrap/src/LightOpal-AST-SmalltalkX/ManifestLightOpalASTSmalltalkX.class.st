Class {
	#name : #ManifestLightOpalASTSmalltalkX,
	#superclass : #PackageManifest,
	#category : #'LightOpal-AST-SmalltalkX-Manifest'
}

{ #category : #'stx - description' }
ManifestLightOpalASTSmalltalkX class >> mandatoryPreRequisites [
	"list packages which are mandatory as a prerequisite.
	 This are packages containing superclasses of my classes and classes which
	 are extended by myself.
	 They are mandatory, because we need these packages as a prerequisite for loading and compiling.
	 This method is generated automatically,
	 by searching along the inheritance chain of all of my classes.
	 Please take a look at the #referencedPreRequisites method as well."

	^ #(
		#'LightOpal-AST'    "OCASTVisitor - extended"
		#'stx:goodies/refactoryBrowser/parser'    "RBPragmaNode - extended"
		#'stx:libbasic'    "Object - extended"
		#'stx:libcompat'    "PackageManifest - superclass of ManifestLightOpalASTSmalltalkX"
	)
]

{ #category : #'stx - description' }
ManifestLightOpalASTSmalltalkX class >> referencedPreRequisites [
	"list packages which are a prerequisite, because they contain
	 classes which are referenced by my classes.
	 These packages are NOT needed as a prerequisite for compiling or loading,
	 however, a class from it may be referenced during execution and having it
	 unloaded then may lead to a runtime doesNotUnderstand error, unless the caller
	 includes explicit checks for the package being present.
	 This method is generated automatically,
	 by searching all classes (and their packages) which are referenced by my classes.
	 Please also take a look at the #mandatoryPreRequisites method"

	^ #(
	)
]
