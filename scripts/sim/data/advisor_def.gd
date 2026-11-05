class_name AdvisorDef
extends Resource
## Un consigliere del Consiglio (GDD §4.2) con la sua categoria (GDD §4.2.4).
## La categoria è un insieme di tipi: il consigliere propone e potenzia le carte che hanno
## almeno uno di questi tipi. Contiene solo dati: le regole stanno in RunState.

enum Special {
	NESSUNO,  ## Consigliere ordinario, con una categoria.
	CLOWN,    ## Propone un elemento per ogni colore di mana e un edificio neutro (GDD §4.2.2).
	ANZIANO,  ## Propone perk ed edifici neutri; potenzia i neutri una volta all'anno.
	VISITATORE,  ## Di passaggio, al posto di un consigliere (GDD §4.2.5, v0.23): non potenzia.
}

## Esclusivi di altre nazioni che un visitatore può proporre.
enum Foreign {
	NESSUNO,
	PER_TIPO,  ## Solo quelli con un tipo del visitatore.
	TUTTI,
}

@export var id: StringName = &""
## Nome del consigliere, es. "Generale".
@export var display_name: String = ""
## Nome della categoria, es. "Militare".
@export var category_name: String = ""
@export_multiline var description: String = ""
@export var special: Special = Special.NESSUNO
## Colore di mana a cui tende la categoria (GDD §5.3): serve solo alla grafica della carta.
@export var color: StringName = &""

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


@export_group("Visitatore (GDD §4.2.5)")
## Radici, come per EventDef: richiede, favorito da, ere, tipi sulla plancia.
@export var requires_any: Array[Resource] = []
@export var favored_by: Array[Resource] = []
@export var min_era: int = 0
@export var max_era: int = 0
## Stagioni in cui la carta può comparire (GDD §4.2.5, v0.25): 0 inverno, 1 primavera, 2 estate,
## 3 autunno. Vuoto = tutte.
@export var seasons: PackedInt32Array = PackedInt32Array()
## Stagioni in cui la carta è più probabile (+1 di peso ciascuna).
@export var favored_seasons: PackedInt32Array = PackedInt32Array()
## Solo consiglieri ordinari: stagioni in cui compaiono più di rado (peso dimezzato, almeno 1).
@export var disfavored_seasons: PackedInt32Array = PackedInt32Array()
@export var requires_types: Array[StringName] = []
## Propone carte di qualsiasi tipo (altrimenti solo quelle con un suo tipo).
@export var any_type: bool = false
@export var offers_buildings: bool = true
@export var offers_troops: bool = true
@export var foreign_exclusives: Foreign = Foreign.NESSUNO
## Ere proposte rispetto a quella corrente: da era + era_shift_min a era + era_shift_max.
@export var era_shift_min: int = 0
@export var era_shift_max: int = 0
## Oro in più (o in meno) sul prezzo delle carte dell'era corrente e di quelle successive.
@export var price_extra: int = 0
@export var next_era_extra: int = 0
## Altro costo aggiunto a ogni carta proposta (es. 1 Documenti del Contrabbandiere).
@export var extra_cost: ResourceAmounts


## true se la carta con questi tipi rientra nella categoria del consigliere.
func covers(card_types: Array[StringName]) -> bool:
	for card_type: StringName in card_types:
		if types.has(card_type):
			return true
	return false
