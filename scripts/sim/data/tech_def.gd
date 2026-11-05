class_name TechDef
extends Resource
## Una tecnologia dell'albero (GDD §10.5, v0.25). Si completa con la Ricerca e dà un effetto
## permanente, espresso con il linguaggio del nucleo (P5): modificatori, perk, spazi o una linea.
## Contiene solo dati: le regole stanno in RunState.

## Rami dell'albero: uno per colore di mana (GDD §10.5.2).
const BRANCHES: Array[StringName] = [&"rosso", &"verde", &"blu", &"viola"]
const BRANCH_NAMES: Dictionary[StringName, String] = {
	&"rosso": "Rosso",
	&"verde": "Verde",
	&"blu": "Blu",
	&"viola": "Viola",
}

@export var id: StringName = &""
@export var display_name: String = ""
## Effetto in parole semplici, come lo legge il giocatore sulla carta.
@export_multiline var description: String = ""
## Sfera: il nome di una delle 8 categorie del Consiglio (es. "Militare"). Decide il ramo.
@export var sphere: String = ""
## Era della tecnologia: si può ricercare solo nella propria era o in quelle successive.
@export_range(1, 10) var era: int = 1
## Altezza dentro l'era: 1 (prima) o 2 (seconda, si apre con tecnologie della prima nello stesso ramo).
@export_range(1, 2) var tier: int = 1
## Ricerca necessaria per completarla.
@export var cost: int = 3

@export_group("Albero")
## Tecnologie che devono essere già completate (frecce precise dell'albero, anche di altri rami).
## Dichiarate come Resource per lo stesso motivo di IdentityDef.requires_any.
@export var prerequisites: Array[Resource] = []

@export_group("Radici")
## Compare solo a chi ha almeno uno di questi elementi dell'identità o vie (tecnologie esclusive).
@export var requires_any: Array[Resource] = []
## Elementi dell'identità o vie che la rendono più probabile nella mano (peso +1 ciascuno).
@export var favored_by: Array[Resource] = []
## Compare solo se sulla plancia c'è almeno una carta con uno di questi tipi.
@export var requires_types: Array[StringName] = []

@export_group("Effetti")
## Modificatori permanenti (dottrine, miglioramenti della nazione e del Consiglio).
@export var permanent_modifiers: Array[ModifierDef] = []
## Perk ottenuto con la tecnologia (GDD §9.3). Se la nazione lo ha già, la tecnologia non compare.
@export var perk: IdentityDef
## Linea di elementi sbloccata (GDD §10.5.5).
@export var line: LineDef
## Spazi ricevuti (mai oltre il massimo della plancia).
@export var extra_building_slots: int = 0
@export var extra_troop_slots: int = 0


## Ramo della tecnologia, ricavato dalla sfera (GDD §5.3, §10.5.2); &"" se la sfera non è valida.
func branch() -> StringName:
	return branch_of(sphere)


## Ramo di una sfera: ogni colore raccoglie le due categorie a cui tende.
static func branch_of(sphere_name: String) -> StringName:
	match sphere_name:
		"Militare", "Opera":
			return &"rosso"
		"Terra", "Ricchezza":
			return &"verde"
		"Fede", "Stato":
			return &"blu"
		"Conoscenza", "Ombra":
			return &"viola"
	return &""


## Altezza nell'albero di tutta la run: l'era 1 occupa le altezze 1 e 2, l'era 2 le 3 e 4...
func height() -> int:
	return (era - 1) * 2 + tier


## true se è esclusiva di qualche elemento dell'identità o via.
func is_exclusive() -> bool:
	return not requires_any.is_empty()
