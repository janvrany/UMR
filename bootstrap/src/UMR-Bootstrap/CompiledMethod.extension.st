Extension { #name : #CompiledMethod }

{ #category : #'*UMR-Bootstrap' }
CompiledMethod >> sourceInfo [
	"Return an UMRSourceInfo for class in the image.

	 Extremely ugly, read at your own risk! I take no responsibility
   for any injuries. You have been warned!
	"

	| pkgDir |

	pkgDir := Smalltalk getPackageDirectoryForPackage: self package.
	pkgDir notNil ifTrue: [
		self package = self methodClass package ifTrue: [
			| file |

			file := pkgDir / (self methodClass name , '.class.st').
			file exists ifTrue: [
				"Sigh, Tonel..."
				| stream position |
				stream := UMRLineTrackingWriteStream on: String new writeStream.
				position := UMRTonelWriter positionOfMethod: self on: stream.
				^ UMRSourceInfo
								file: file
								position: position
								length: nil
								lines: stream lineEnds	"Unknown because of bad design of Tonel" ]
		] ifFalse: [
			"Extension"
			self error: 'Not implemented'
		]
	].
	^ nil

	"
  (UMRPrimitive_mbind >> #build) sourceInfo
  "
]
