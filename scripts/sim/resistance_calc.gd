class_name ResistanceCalc
extends RefCounted
## Calcolo della Resistenza massima di una nazione (GDD §7.1.1).
## Somma di era, identità, anni, edifici e truppe.


## Restituisce la Resistenza massima con cui la nazione inizia lo scontro.
## identity_bonus: quota di governo, credo e razza (nel prototipo vale 0).
static func compute(
		rules: ResistanceRules,
		era: int,
		year: int,
		building_count: int,
		troop_count: int,
		identity_bonus: int = 0) -> int:
	var total: int = 0
	total += _era_share(rules, era)
	total += identity_bonus
	total += rules.per_year * maxi(year, 0)
	total += rules.per_building * maxi(building_count, 0)
	total += rules.per_troop * maxi(troop_count, 0)
	return total


static func _era_share(rules: ResistanceRules, era: int) -> int:
	if rules.per_era.is_empty():
		push_error("ResistanceRules: manca la quota per le ere.")
		return 0
	var index: int = era - 1
	if index < 0:
		push_error("ResistanceCalc: era non valida (%d)." % era)
		return rules.per_era[0]
	if index >= rules.per_era.size():
		push_warning("ResistanceCalc: era %d senza quota nei dati, uso l'ultima disponibile." % era)
		return rules.per_era[rules.per_era.size() - 1]
	return rules.per_era[index]
