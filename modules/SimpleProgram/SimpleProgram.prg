Program
	named: 'SimpleProgram'
	initializer: [SimpleObject new saySomething. 0] !

SimpleProgram
	addSubsystemNamed: 'SimpleSubsystem' repositoryName: 'SimpleProgram' !

SimpleProgram
	importClass: 'Object' from: 'SimpleSubsystem' as: 'SimpleObject' !
