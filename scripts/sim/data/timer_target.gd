class_name TimerTarget
extends RefCounted
## Categoria di bersaglio di Inefficienza e Sabotaggio (GDD §7.7.1).

enum Kind {
	TRUPPE,     ## Solo truppe avversarie.
	EDIFICI,    ## Solo edifici avversari.
	QUALSIASI,  ## Truppe ed edifici avversari.
}

const NAMES: Dictionary[Kind, String] = {
	Kind.TRUPPE: "truppe",
	Kind.EDIFICI: "edifici",
	Kind.QUALSIASI: "qualsiasi",
}
