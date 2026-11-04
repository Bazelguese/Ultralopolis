class_name CouncillorDef
extends Resource
## Un consigliere del Consiglio (GDD §4.2). Propone azioni (le OpportunityDef che lo indicano
## nel campo "councillor") ed edifici e truppe a lui affini.

enum Special {
	NESSUNO,  ## Consigliere normale: segue il tipo del round.
	CLOWN,    ## 4 elementi, edifici e truppe, ciascuno di un mana diverso (§4.2.2).
	ANZIANO,  ## Perk ed edifici neutri (§4.2.2).
}

@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var special: Special = Special.NESSUNO

@export_group("Elementi affini")
## Edifici affini: quelli che hanno almeno una di queste etichette.
@export var building_tags: Array[StringName] = []
## Truppe affini: quelle che hanno almeno una di queste etichette.
@export var troop_tags: Array[StringName] = []
## Singoli elementi affini, oltre a quelli scelti per etichetta.
@export var buildings: Array[BuildingDef] = []
@export var troops: Array[TroopDef] = []
## Affini anche tutti gli elementi che rallentano o sabotano (Maestro delle spie).
@export var disruptors: bool = false


func is_affine_building(def: BuildingDef) -> bool:
	if buildings.has(def):
		return true
	if disruptors and (def.inefficiency_ms > 0 or def.sabotage_ms > 0):
		return true
	for tag: StringName in building_tags:
		if def.tags.has(tag):
			return true
	return false


func is_affine_troop(def: TroopDef) -> bool:
	if troops.has(def):
		return true
	if disruptors and (def.inefficiency_ms > 0 or def.sabotage_ms > 0):
		return true
	for tag: StringName in troop_tags:
		if def.tags.has(tag):
			return true
	return false
