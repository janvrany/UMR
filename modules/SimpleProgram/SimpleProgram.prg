Program
	named: 'SimpleProgram'
	initializer: [
		| o |

		o := SimpleObject new.
		o saySomething.
		0 "exit code".
	] !

SimpleProgram
	addSubsystemNamed: 'SimpleSubsystem' repositoryName: 'SimpleProgram' !

SimpleProgram
	importClass: 'Object' from: 'SimpleSubsystem' as: 'SimpleObject' !
