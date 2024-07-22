Class {
	#name : #UMRModule,
	#superclass : #RGEnvironment,
	#instVars : [
		'initializer',
		'imports',
		'subsystems'
	],
	#category : #'UMR-ProgramDefinition'
}

{ #category : #'adding & removing' }
UMRModule >> addImport: import [
	self backend forEnvironment
		addImport: import
		to: self.

	(import hasResolvedName and:[import hasResolvedBehavior])
		ifTrue: [ self queryInterface behaviorsDictionary at: import name asSymbol put: import behavior].
]

{ #category : #'adding & removing' }
UMRModule >> addSubsystem: anUMRSubsystem [
	self pvtAddSubsystem: anUMRSubsystem.
	

	"Modified: / 22-12-2020 / 10:59:15 / Jan Vrany <jan.vrany@labware.com>"
]

{ #category : #cleaning }
UMRModule >> cleanSuperclassesOfMetaclasses [
	self ask behaviorsDo: [ :each | 
		(each isMetaclass and:[each isRingResolved]) ifTrue: [ 
			each superclass isRingResolved ifFalse: [ 
				self error: 'Invalid metaclass: unresolved (meta) superclass'.
			].
		]
	]
]

{ #category : #cleaning }
UMRModule >> cleanWithMetaclassNamed: ignored [
	subsystems value do: [:subsystem | subsystem cleanWithMetaclassNamed: ignored ].
	super cleanWithMetaclassNamed: ignored.
]

{ #category : #'default model values' }
UMRModule >> defaultImports [

	^ IdentitySet new
]

{ #category : #'default model values' }
UMRModule >> defaultSubsystems [

	^ IdentitySet new
]

{ #category : #'as yet unclassified' }
UMRModule >> ensureImportNamed: aSymbol [
	^ imports value 
		detect: [:each | each name = aSymbol] 
		ifNone: [ | import |
				import := UMRBehaviorImport named: aSymbol parent: self.
				self addImport: import.
				import ].
]

{ #category : #cleaning }
UMRModule >> ensureMetaclass: metaclassName [
	self error: 'Should not be called'
]

{ #category : #'accessing - backend' }
UMRModule >> importsDo: aBlock [

	self backend forEnvironment importsFor: self do: aBlock
]

{ #category : #initialization }
UMRModule >> initialize [

	super initialize.
	backend := UMRModuleBackend for: self.
	queryInterface := UMRModuleQueries for: self.   
	imports := self unresolvedValue: self defaultImports.
	subsystems := self unresolvedValue: self defaultSubsystems.
]

{ #category : #initialization }
UMRModule >> initializeUnresolved [

	super initializeUnresolved.
	backend := UMRModuleBackend for: self.
	queryInterface := UMRModuleQueries for: self.
	imports := self unresolvedValue: self defaultImports.  
	subsystems := self unresolvedValue: self defaultSubsystems.
]

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
UMRModule >> isProgram [
	^ false
]

{ #category : #lookup }
UMRModule >> lookupClass: className [
	^ self lookupClass: className recursively: false
]

{ #category : #lookup }
UMRModule >> lookupClass: className recursively: recursively [
	| class |

	class := self ask behaviorNamedExactlyAs: className ifAbsent: [ nil ].
	class notNil ifTrue: [ ^ class value ].

	class := imports detect: [:import | import name = className ] ifNone: [ nil ].
	class notNil ifTrue: [ ^ class behavior ].

	recursively ifTrue: [ 
		subsystems do: [:subsystem | 
			class := subsystem lookupClass: className recursively: recursively.
			class notNil ifTrue: [ ^ class value ].
		].
	].

	self error: 'Class not found: ', className
]

{ #category : #lookup }
UMRModule >> lookupSubsystem: subsystemName [
	^ subsystems detect: [:subsystem | subsystem name = subsystemName ] 
				 ifNone: [ self error:'Subsystem not found: ', subsystemName ]
]

{ #category : #printing }
UMRModule >> printOn: aStream [ 
	aStream nextPutAll: self name
]

{ #category : #'private - backend interface' }
UMRModule >> pvtAddBehavior: behavior [
	behavior isRingResolved ifTrue: [
		behaviors value do: [:each | 
			(each ~~ behavior and:[each isRingResolved and:[each name = behavior name]]) ifTrue: [ 
				self error: 'Attempting to redefine class: ', behavior name.
				^ self.
			].
		].
		imports value do: [:each | 
			each name = behavior name ifTrue: [ 
				self error: 'Attempting to redefine import: ', behavior name.
				^ self.
			].
		].
	].

	super pvtAddBehavior: behavior
]

{ #category : #'private - backend interface' }
UMRModule >> pvtAddImport: import [
	behaviors value do: [:each | 
		each name = import name ifTrue: [ 
			self error: 'Attempting to redefine class: ', import name.
			^ self.
		].
	].
	imports value do: [:each | 
		each name = import name ifTrue: [ 
			self error: 'Attempting to redefine import: ', import name.
			^ self.
		].
	].


	self environment verifyOwnership: import.
	
	imports isRingResolved ifFalse: [ 
		self pvtCleanImports ].
	
	(imports includes: import)
		ifFalse: [ 
			imports add: import.
			"self announcer behaviorAdded: import"].
]

{ #category : #'private - backend interface' }
UMRModule >> pvtAddSubsystem: subsystem [
	subsystems isRingResolved ifFalse: [ 
		self pvtCleanSubsystems ].
	
	(subsystems includes: subsystem)
		ifFalse: [ 
			subsystems add: subsystem.
			"self announcer subsystemAdded: subsystem"].
]

{ #category : #'private - backend interface' }
UMRModule >> pvtCleanImports [
	imports := self defaultImports.
		
	"TODO:Announce if not empty"
]

{ #category : #'private - backend interface' }
UMRModule >> pvtCleanSubsystems [
	subsystems := self defaultSubsystems.
		
	"TODO:Announce if not empty"
]

{ #category : #'private - backend interface' }
UMRModule >> pvtImportsDo: aBlock [
	imports value do: aBlock
]

{ #category : #accessing }
UMRModule >> subsystems [
	^ subsystems
]

{ #category : #cleaning }
UMRModule >> unifyMetaclass: ignored [
	self ask behaviorsDo: [ :meta | 
		(meta isMetaclass and:[meta isRingResolved]) ifTrue: [ 
			"If metaclass has not it's class set, we set it to
			 the class of root class class, which should be set"

			| root metameta |

			metameta := meta metaclass.
			root := meta.
			[ metameta isNil and:[ root notNil ]] whileTrue: [ 
				root metaclass isRingResolved ifTrue: [ 
					metameta := root metaclass.
					root := nil.
				] ifFalse: [ 
					root := root superclass.
				].
			].

			(metameta isNil or: [ metameta isRingResolved not]) ifTrue: [ 
				self error: 'Cannot locate class of metaclass'.
			].

			meta metaclass: metameta] 
	].
]
