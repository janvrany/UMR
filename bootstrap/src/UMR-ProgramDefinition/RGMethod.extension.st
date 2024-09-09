Extension { #name : #RGMethod }

{ #category : #'*UMR-ProgramDefinition' }
RGMethod >> sourceInfo [
	^ self propertyNamed: #sourceInfo ifAbsent: [ nil ]


]

{ #category : #'*UMR-ProgramDefinition' }
RGMethod >> sourceInfo: anUMRSourceInfo [
	self propertyNamed: #sourceInfo put: anUMRSourceInfo


]
