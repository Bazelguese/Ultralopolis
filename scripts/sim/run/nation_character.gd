class_name NationCharacter
extends RefCounted
## Un personaggio ricorrente entrato nella storia della nazione (GDD §9.6, v0.29): il ruolo,
## il nome pescato e quanta fiducia ha nella nazione (cambia con le scelte delle cronache).

var def: CharacterDef
var name: String = ""
var affinity: int = 0
## Anno in cui è entrato nella storia.
var since_year: int = 0


func _init(p_def: CharacterDef, p_name: String, p_affinity: int, p_year: int) -> void:
	def = p_def
	name = p_name
	affinity = p_affinity
	since_year = p_year


## "Varo, il Generale".
func describe() -> String:
	return "%s, %s" % [name, def.role.to_lower()]
