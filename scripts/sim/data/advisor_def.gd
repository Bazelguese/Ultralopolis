class_name AdvisorDef
extends Resource
## Un consigliere del Consiglio (GDD §4.2) con la sua categoria (GDD §4.2.4).
## La categoria è un insieme di tipi: il consigliere propone e potenzia le carte che hanno
## almeno uno di questi tipi. Contiene solo dati: le regole stanno in RunState.

enum Special {
	NESSUNO,  ## Consigliere ordinario, con una categoria.
	CLOWN,    ## Propone un elemento per ogni colore di mana e un edificio neutro (GDD §4.2.2).
	ANZIANO,  ## Propone perk ed edifici neutri; potenzia i neutri una volta all'anno.
}

@export var id: StringName = &""
## Nome del consigliere, es. "Generale".
@export var display_name: String = ""
## Nome della categoria, es. "Militare".
@export var category_name: String = ""
@export_multiline var description: String = ""
@export var special: Special = Special.NESSUNO

@export_group("Categoria")
## Tipi della categoria (GDD §4.2.4). Vuoto per Clown e Anziano.
@export var types: Array[StringName] = []

@export_group("Potenzia e rinnovo")
## Risorsa con cui si pagano Potenzia e, in alternativa all'Oro, il rinnovo (GDD §4.2.4, §5.3).
@export var upgrade_resource: Res.Type = Res.Type.ORO
## Ombra: oltre a upgrade_resource chiede una risorsa casuale, pescata fra quelle delle
## altre categorie quando il consigliere compare nel round (GDD §4.2.4).
@export var random_resource: bool = false

@export_group("Azioni")
## Azioni che il consigliere può proporre (GDD §4.2.3). Quelle esclusive di un elemento
## dell'identità compaiono solo a chi lo ha.
@export var actions: Array[OpportunityDef] = []


## true se la carta con questi tipi rientra nella categoria del consigliere.
func covers(card_types: Array[StringName]) -> bool:
	for card_type: StringName in card_types:
		if types.has(card_type):
			return true
	return false
