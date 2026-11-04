class_name TimerTarget
extends RefCounted
## Categoria di bersaglio di Inefficienza e Sabotaggio (GDD §7.7.1)
## e criterio con cui lo spionaggio sceglie il bersaglio prima dello scontro (§12).

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


## Come lo spionaggio sceglie il bersaglio fra gli elementi validi (GDD §7.7.1, v0.21).
enum Criterion {
	A_CASO,          ## A caso, con il seme dello scontro.
	PIU_A_DESTRA,    ## L'ultimo della fila (per le truppe: il primo ad agire).
	PIU_A_SINISTRA,  ## Il primo della fila.
	PIU_LENTO,       ## Ricarica (truppe) o intervallo (edifici) più lunghi.
	PIU_VELOCE,      ## Ricarica o intervallo più brevi.
}

const CRITERION_NAMES: Dictionary[Criterion, String] = {
	Criterion.A_CASO: "a caso",
	Criterion.PIU_A_DESTRA: "più a destra",
	Criterion.PIU_A_SINISTRA: "più a sinistra",
	Criterion.PIU_LENTO: "più lento",
	Criterion.PIU_VELOCE: "più veloce",
}
