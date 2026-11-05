class_name LineDef
extends Resource
## Una linea di elementi (GDD §10.5.5, v0.26): una serie di edifici o truppe, uno per era, con lo
## stesso ruolo. Una tecnologia la sblocca; in ogni era compare fra le proposte la versione
## dell'era corrente, oppure, se manca, l'ultima versione precedente.
## Le versioni non stanno nel catalogo base (CatalogDef.buildings e troops).

@export var id: StringName = &""
@export var display_name: String = ""
## Versioni edificio della linea (una per era, l'era è quella dell'edificio).
@export var buildings: Array[BuildingDef] = []
## Versioni truppa della linea (una per era).
@export var troops: Array[TroopDef] = []


## Edificio della linea per quell'era: la versione dell'era, o l'ultima precedente; null se nessuna.
func building_for_era(target_era: int) -> BuildingDef:
	var best: BuildingDef = null
	for def: BuildingDef in buildings:
		if def.era <= target_era and (best == null or def.era > best.era):
			best = def
	return best


## Truppa della linea per quell'era: la versione dell'era, o l'ultima precedente; null se nessuna.
func troop_for_era(target_era: int) -> TroopDef:
	var best: TroopDef = null
	for def: TroopDef in troops:
		if def.era <= target_era and (best == null or def.era > best.era):
			best = def
	return best
