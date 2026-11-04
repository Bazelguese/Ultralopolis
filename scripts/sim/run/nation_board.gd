class_name NationBoard
extends RefCounted
## Plancia della nazione: due file separate, edifici e truppe (GDD §6).

## Edifici posseduti.
var buildings: Array[BoardPiece] = []
## Truppe da sinistra (indice 0) a destra (ultimo indice).
var troops: Array[BoardPiece] = []
## Spazi edificio iniziali più quelli guadagnati con le ere e con gli acquisti.
var base_building_slots: int = 4
## Spazi truppa iniziali più quelli guadagnati con le ere e con gli acquisti.
var base_troop_slots: int = 3
var max_building_slots: int = 10
var max_troop_slots: int = 12


## Spazi edificio disponibili, compresi quelli concessi dagli edifici (GDD §6.3).
func building_capacity() -> int:
	return _building_capacity_for(building_defs())


## Spazi truppa disponibili, compresi quelli concessi dagli edifici (GDD §6.3).
func troop_capacity() -> int:
	return _troop_capacity_for(building_defs())


func has_free_building_slot() -> bool:
	return buildings.size() < building_capacity()


func has_free_troop_slot() -> bool:
	return troops.size() < troop_capacity()


func building_defs() -> Array[BuildingDef]:
	var defs: Array[BuildingDef] = []
	for piece: BoardPiece in buildings:
		defs.append(piece.building)
	return defs


func troop_defs() -> Array[TroopDef]:
	var defs: Array[TroopDef] = []
	for piece: BoardPiece in troops:
		defs.append(piece.troop)
	return defs


## Vendere un edificio non deve lasciare elementi senza spazio
## (succede se l'edificio concede spazi, es. una caserma).
func can_sell_building(index: int) -> bool:
	if index < 0 or index >= buildings.size():
		return false
	if buildings[index].building.is_capital:
		return false
	var defs: Array[BuildingDef] = building_defs()
	defs.remove_at(index)
	return _fits(defs, buildings.size() - 1, troops.size())


## Sostituire un edificio con un altro non deve lasciare elementi senza spazio.
func can_replace_building(index: int, new_def: BuildingDef) -> bool:
	if index < 0 or index >= buildings.size():
		return false
	if buildings[index].building.is_capital:
		return false
	var defs: Array[BuildingDef] = building_defs()
	defs[index] = new_def
	return _fits(defs, buildings.size(), troops.size())


## Aggiungere un edificio in uno spazio libero.
func can_add_building(new_def: BuildingDef) -> bool:
	var defs: Array[BuildingDef] = building_defs()
	defs.append(new_def)
	return buildings.size() < building_capacity() and _fits(defs, buildings.size() + 1, troops.size())


## Sposta una truppa da una posizione a un'altra (GDD §6.1).
func move_troop(from_index: int, to_index: int) -> bool:
	if from_index < 0 or from_index >= troops.size() or to_index < 0 or to_index >= troops.size():
		return false
	var piece: BoardPiece = troops[from_index]
	troops.remove_at(from_index)
	troops.insert(to_index, piece)
	return true


func _fits(defs: Array[BuildingDef], building_count: int, troop_count: int) -> bool:
	return building_count <= _building_capacity_for(defs) and troop_count <= _troop_capacity_for(defs)


func _building_capacity_for(defs: Array[BuildingDef]) -> int:
	var total: int = base_building_slots
	for def: BuildingDef in defs:
		total += def.extra_building_slots
	return mini(total, max_building_slots)


func _troop_capacity_for(defs: Array[BuildingDef]) -> int:
	var total: int = base_troop_slots
	for def: BuildingDef in defs:
		total += def.extra_troop_slots
	return mini(total, max_troop_slots)
