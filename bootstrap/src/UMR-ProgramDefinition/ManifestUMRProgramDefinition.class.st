Class {
	#name : #ManifestUMRProgramDefinition,
	#superclass : #PackageManifest,
	#category : #'UMR-ProgramDefinition-Manifest'
}

{ #category : #'stx - description' }
ManifestUMRProgramDefinition class >> mandatoryPreRequisites [
	"list packages which are mandatory as a prerequisite.
	 This are packages containing superclasses of my classes and classes which
	 are extended by myself.
	 They are mandatory, because we need these packages as a prerequisite for loading and compiling.
	 This method is generated automatically,
	 by searching along the inheritance chain of all of my classes.
	 Please take a look at the #referencedPreRequisites method as well."

	^ #(
		#'stx:goodies/ring/core'    "RGElement - superclass of UMRInitializer"
		#'stx:libbasic'    "Object - superclass of UMREnvironment"
		#'stx:libcompat'    "PackageManifest - superclass of ManifestUMRProgramDefinition"
	)
]

{ #category : #'stx - description' }
ManifestUMRProgramDefinition class >> referencedPreRequisites [
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
		#'stx:goodies/refactoryBrowser/parser'    "RBParser - referenced by UMRModuleReader>>readNextChunk"
	)
]
