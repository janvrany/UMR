Extension { #name : #TRLocation }

{ #category : #'*UMR-Bootstrap' }
TRLocation class >> here [
	| caller |

	caller := thisContext sender.

	Smalltalk isSmalltalkX ifTrue: [
		| class file line |

		class := caller method mclass.
		file := class name , '.class.st'.
		line := caller lineNumber.
		^ TRSourceLocation file: file line: line column: 0.

	].
	self notYetImplemented.

	"
	TRLocation perform: #here
	"
]
