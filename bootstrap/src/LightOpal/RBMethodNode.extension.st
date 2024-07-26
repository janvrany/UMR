Extension { #name : #RBMethodNode }

{ #category : #'*LightOpal-Core' }
RBMethodNode >> compilationContext [
	^ self propertyAt: #compilationContext ifAbsent: nil

	"Created: / 25-07-2024 / 16:22:43 / Jan Vrany <jan.vrany@labware.com>"
]

{ #category : #'*LightOpal-Core' }
RBMethodNode >> compilationContext: aCompilationContext [
	^ self propertyAt: #compilationContext put: aCompilationContext

	"Created: / 25-07-2024 / 16:25:06 / Jan Vrany <jan.vrany@labware.com>"
]

{ #category : #'*LightOpal-Core' }
RBMethodNode >> methodClass [
	^ self compilationContext getClass

	"Created: / 25-07-2024 / 21:48:24 / Jan Vrany <jan.vrany@labware.com>"
]

{ #category : #'*LightOpal-Core' }
RBMethodNode >> methodClass: aClass [
	| context |

	context := self compilationContext.
	context isNil ifTrue: [ 
		context := CompilationContext new.
		self compilationContext: context.
	].
	context class: aClass.

	"Created: / 25-07-2024 / 21:48:35 / Jan Vrany <jan.vrany@labware.com>"
]
