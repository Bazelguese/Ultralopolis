class_name IdentityDef
extends Resource
## Un elemento dell'identità della nazione (GDD §9): popolo, governo, credo, cultura o perk.
## Tutti usano la stessa scheda; ogni campo è facoltativo. Gli effetti si esprimono
## con il linguaggio del nucleo (P5): Resistenza, dotazione, opportunità, elementi, modificatori.

## Cause del Malcontento (GDD §5.5, v0.24): quella che ne ha prodotto di più decide quali governi
## può portare la Rivoluzione.
enum Grievance {
	SCONFITTE,  ## Scontri persi.
	CARESTIE,   ## Truppe rimaste senza Cibo.
	MALUS,      ## Malus subiti.
	EVENTI,     ## Scelte degli eventi.
}

const GRIEVANCE_NAMES: Dictionary[Grievance, String] = {
	Grievance.SCONFITTE: "le sconfitte",
	Grievance.CARESTIE: "le carestie",
	Grievance.MALUS: "i malus subiti",
	Grievance.EVENTI: "le scelte di governo",
}

enum Dimension {
	POPOLO,
	GOVERNO,
	CREDO,
	CULTURA,
	PERK,  ## Abilità passive, come quelle di The Bazaar: alcune all'inizio, altre durante la run.
	VIA,   ## Direzione scelta entrando in un'era, dalla seconda in poi (GDD §10.4).
	ASCENSIONE,  ## Scelta completando l'albero di una via (GDD §10.4.2, v0.27).
}

## Regole del nucleo che un'ascensione del livello 2 cambia (GDD §10.4.2, v0.27).
enum Rule {
	NESSUNA,
	SECONDA_NATURA,    ## Ogni truppa si incanta due volte (§4.3).
	ULTIMA_TRINCEA,    ## La prima volta che la Resistenza arriva a zero torna a 1 (§7.1).
	PRIMA_SCINTILLA,   ## Gli edifici iniziano lo scontro con l'intervallo a metà (§7.5).
	DISCIPLINA_FERREA, ## La truppa più a destra prenota il mana (§7.3).
	MANA_UNITO,        ## Si paga anche con gli altri colori (§5.3).
	MAESTRIA,          ## Le carte arrivano al livello 4 (§6.5).
	DOPPIO_ASCOLTO,    ## Una volta per metà anno due proposte dallo stesso consigliere (§4.2).
	ESERCITO_FRUGALE,  ## Le truppe senza Cibo non rallentano (§5.4).
}

const DIMENSION_NAMES: Dictionary[Dimension, String] = {
	Dimension.POPOLO: "Popolo",
	Dimension.GOVERNO: "Governo",
	Dimension.CREDO: "Credo",
	Dimension.CULTURA: "Cultura",
	Dimension.PERK: "Perk",
	Dimension.VIA: "Via",
	Dimension.ASCENSIONE: "Ascensione",
}

## Dimensioni scelte alla creazione della nazione (le vie arrivano dopo, con le ere).
const CREATION_DIMENSIONS: Array[Dimension] = [
	Dimension.POPOLO, Dimension.GOVERNO, Dimension.CREDO, Dimension.CULTURA, Dimension.PERK,
]

@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var dimension: Dimension = Dimension.POPOLO

@export_group("Tipo d'identità")
## Tipo d'identità dell'elemento, es. "Pietrosangue" o "Monarchico" (GDD §6.6, v0.24).
## Sta fuori da tutte le categorie: lo portano le carte esclusive dell'elemento, insieme ad
## almeno un tipo di categoria, e lo leggono perk, tratti ed eventi.
@export var identity_type: StringName = &""

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

@export_group("Governo a tier")
## Tier del governo (GDD §9.4, v0.24): alla creazione si sceglie solo il tier 1.
@export var tier: int = 1
## Governi del tier successivo a cui può evolvere (IdentityDef). Dichiarato come Resource
## per lo stesso motivo di requires_any (vedi sotto).
@export var evolves_to: Array[Resource] = []
## Tipi richiesti sulla plancia per raggiungere questo governo con una Riforma.
@export var reform_requires_types: Array[StringName] = []
## Cause del Malcontento per cui una Rivoluzione può portare a questo governo, di qualunque tier.
@export var revolution_causes: Array[Grievance] = []

@export_group("Consiglio")
## Effetti sul Consiglio e sulle risorse (GDD §9.2, v0.24): valgono fuori dalla battaglia e si
## sommano fra tutti gli elementi dell'identità.
## Consiglieri in più (o in meno) in ogni round.
@export var advisors_change: int = 0
## Consigliere che compare sempre fra quelli del round.
@export var always_present_advisor: AdvisorDef
## Consiglieri che non compaiono mai.
@export var excluded_advisors: Array[AdvisorDef] = []
## Peso in più del consigliere di corte (Monarchia). Convenzione provvisoria (GDD §16.3):
## il consigliere di corte è il primo consigliere ordinario ascoltato nella run.
@export var court_advisor_weight: int = 0
## Se vero, il consigliere di corte compare sempre fra quelli del round (Monarchia assoluta).
@export var court_advisor_always: bool = false
## Oro in più (o in meno) su ogni proposta che costa Oro.
@export var proposal_gold_change: int = 0
## Peso in più dei Visitatori fra le carte speciali (GDD §4.2.5).
@export var visitor_weight_change: int = 0
## Le azioni di questi consiglieri, e queste azioni, costano action_discount unità in meno di
## ogni risorsa del costo (Oro escluso), ma almeno 1.
@export var cheaper_advisors: Array[AdvisorDef] = []
@export var cheaper_actions: Array[OpportunityDef] = []
@export var action_discount: int = 0
## Unità in meno da vendere al mercato per 1 Oro (minimo 1).
@export var market_rate_change: int = 0
## Unità in meno a ogni Potenzia (minimo 1 per risorsa).
@export var upgrade_discount: int = 0
## Millisecondi in più (o in meno) per gli effetti dello spionaggio (GDD §4.2.3).
@export var spy_ms_change: int = 0

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

@export_group("Tradizioni (solo per le vie, GDD §10.4.1)")
## I 4 passi dell'albero della via, ognuno con la sua impresa.
@export var traditions: Array[TraditionDef] = []

@export_group("Ascensione (GDD §10.4.2)")
## Livello dell'ascensione: 1 = effetti di oggi, 2 = cambia una regola. 0 per chi non è un'ascensione.
@export var ascension_level: int = 0
## Regola cambiata dalle ascensioni del livello 2.
@export var rule: Rule = Rule.NESSUNA

@export_group("Tratto permanente")
## Modificatori che valgono per tutta la run.
@export var permanent_modifiers: Array[ModifierDef] = []
