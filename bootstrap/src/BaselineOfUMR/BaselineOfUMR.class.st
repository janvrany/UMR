Class {
	#name : #BaselineOfUMR,
	#superclass : #BaselineOf,
	#category : #BaselineOfUMR
}

{ #category : #baselines }
BaselineOfUMR >> baseline: spec [
        <baseline>
        spec
                for: #pharo
                do: [
                        spec baseline: 'Tinyrossa' with: [
                                spec repository: 'github://janvrany/Tinyrossa'
                        ].

                        spec
                                package: #'UMR-ProgramDefinition';
                                package: #'UMR-Bootstrap';
                                package: #'UMR-Runtime';
                                package: #'UMR-Bootstrap-Tests';
                                yourself.
                ]
]

