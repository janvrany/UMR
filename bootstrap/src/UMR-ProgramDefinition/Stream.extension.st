Extension { #name : #Stream }

{ #category : #'*UMR-ProgramDefinition' }
Stream >> fileName [
	"Return filename of underlaying stream or nil, if not
	 reading from/writing to a file. For compatibility with
	 file streams."

	^ nil
]
