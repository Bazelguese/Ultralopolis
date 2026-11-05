class_name EventDef
extends Resource
## Un Evento o una Fortuna (GDD §4.2.5, v0.23): una carta che nei round può comparire al posto
## di un consigliere. Ha una sfera (una categoria del Consiglio), delle radici che la rendono
## esclusiva o più frequente e delle opzioni. Contiene solo dati: le regole stanno in RunState.

enum Family {
	EVENTO,   ## Testo e 2-3 opzioni, alcune sbloccate dalla nazione.
	FORTUNA,  ## Un dono semplice: una sola opzione.
}

## Eventi con opzioni costruite dalle regole invece che scritte nei dati (GDD §9.4, v0.24).
enum Special {
	NESSUNO,
	RIFORMA,  ## Un'opzione per ogni governo a cui il governo attuale può evolvere, pagata in Influenza.
}

@export var id: StringName = &""
@export var display_name: String = ""
## Testo dell'evento, come lo legge il giocatore.
@export_multiline var description: String = ""
@export var family: Family = Family.EVENTO
## Le opzioni scritte nei dati si aggiungono, in coda, a quelle costruite dalle regole.
@export var special: Special = Special.NESSUNO
## Sfera: il nome di una categoria del Consiglio (es. "Fede"), per tema e cornice.
@export var sphere: String = ""
## Colore della sfera (solo grafica), come AdvisorDef.color.
@export var color: StringName = &""

@export_group("Radici")
## La carta compare solo a chi ha almeno uno di questi elementi dell'identità o vie (IdentityDef).
@export var requires_any: Array[Resource] = []
## Elementi dell'identità o vie che la rendono più probabile (peso +1 ciascuno).
@export var favored_by: Array[Resource] = []
## Era minima e massima in cui può comparire (0 = nessun limite).
@export var min_era: int = 0
@export var max_era: int = 0
## Compare solo se sulla plancia c'è almeno una carta con uno di questi tipi.
@export var requires_types: Array[StringName] = []
## Compare solo se nel Magazzino c'è almeno questa quantità (unità intere) di queste risorse.
@export var requires_stock: ResourceAmounts
## Compare solo se c'è almeno un malus attivo.
@export var requires_malus: bool = false
## Un evento compare una sola volta per run, salvo se ripetibile (le Fortune lo sono sempre).
@export var repeatable: bool = false

@export_group("Opzioni")
@export var options: Array[EventOptionDef] = []
## Fortune: le risorse ricevute si moltiplicano per l'era corrente.
@export var scale_with_era: bool = false
