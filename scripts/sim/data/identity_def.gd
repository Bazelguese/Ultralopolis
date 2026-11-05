class_name IdentityDef
extends Resource
## Un elemento dell'identità della nazione (GDD §9): popolo, governo, credo, cultura o perk.
## Tutti usano la stessa scheda; ogni campo è facoltativo. Gli effetti si esprimono
## con il linguaggio del nucleo (P5): Resistenza, dotazione, opportunità, elementi, modificatori.

enum Dimension {
	POPOLO,
	GOVERNO,
	CREDO,
	CULTURA,
	PERK,  ## Abilità passive, come quelle di The Bazaar: alcune all'inizio, altre durante la run.
	VIA,   ## Direzione scelta entrando in un'era, dalla seconda in poi (GDD §10.4).
}

const DIMENSION_NAMES: Dictionary[Dimension, String] = {
	Dimension.POPOLO: "Popolo",
	Dimension.GOVERNO: "Governo",
	Dimension.CREDO: "Credo",
	Dimension.CULTURA: "Cultura",
	Dimension.PERK: "Perk",
	Dimension.VIA: "Via",
}

## Dimensioni scelte alla creazione della nazione (le vie arrivano dopo, con le ere).
const CREATION_DIMENSIONS: Array[Dimension] = [
	Dimension.POPOLO, Dimension.GOVERNO, Dimension.CREDO, Dimension.CULTURA, Dimension.PERK,
]

@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var dimension: Dimension = Dimension.POPOLO

@export_group("Resistenza")
## Quota di Resistenza in ogni scontro (GDD §7.1.1).
@export var resistance_bonus: int = 0

@export_group("Dotazione")
## Oro ricevuto quando l'elemento viene adottato.
@export var extra_gold: int = 0
## Ricerca ricevuta quando l'elemento viene adottato.
@export var extra_research: int = 0
## Altre risorse ricevute quando l'elemento viene adottato (es. bonus immediato di una via).
@export var extra_resources: ResourceAmounts
## Spazi ricevuti quando l'elemento viene adottato (GDD §6.3, §10.4).
@export var extra_building_slots: int = 0
@export var extra_troop_slots: int = 0
## Edifici aggiunti alla plancia quando l'elemento viene adottato (se c'è spazio).
@export var extra_buildings: Array[BuildingDef] = []
## Truppe aggiunte alla plancia quando l'elemento viene adottato (se c'è spazio).
@export var extra_troops: Array[TroopDef] = []

@export_group("Opportunità")
## Tipi di opportunità che compaiono solo con questo elemento.
@export var exclusive_opportunities: Array[OpportunityDef] = []
## Azioni che compaiono più spesso fra le proposte (peso +1 ciascuno). Rendono più frequente
## anche il consigliere che le propone (GDD §4.2).
@export var favored_opportunities: Array[OpportunityDef] = []
## Consiglieri che compaiono più spesso nei round (peso +1 ciascuno, GDD §4.2).
@export var favored_advisors: Array[AdvisorDef] = []

@export_group("Elementi esclusivi")
## Edifici offerti dai Costruttori solo a questa nazione (nella loro era).
@export var exclusive_buildings: Array[BuildingDef] = []
## Truppe offerte dai Reclutatori solo a questa nazione (nella loro era).
@export var exclusive_troops: Array[TroopDef] = []

@export_group("Solo per le vie")
## Nota tecnica: questi due elenchi contengono elementi dell'identità (IdentityDef), ma sono
## dichiarati come Resource perché un modello che elenca sé stesso crea in Godot un riferimento
## circolare che non viene liberato alla chiusura.
## Se non è vuoto, la via compare solo a chi ha almeno uno di questi elementi (via esclusiva).
@export var requires_any: Array[Resource] = []
## Elementi dell'identità o vie precedenti che rendono la via più probabile (peso +1 ciascuno).
@export var favored_by: Array[Resource] = []

@export_group("Tratto permanente")
## Modificatori che valgono per tutta la run.
@export var permanent_modifiers: Array[ModifierDef] = []
