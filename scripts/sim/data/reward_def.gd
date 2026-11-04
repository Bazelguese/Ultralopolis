class_name RewardDef
extends Resource
## Una ricompensa che un incontro del mondo può offrire (GDD §3.3).

enum Kind {
	ORO,
	RICERCA,
	EDIFICIO,
	TRUPPA,
}

@export var kind: Kind = Kind.ORO
## Quantità di Oro o Ricerca (per ORO e RICERCA).
@export var amount: int = 0
## Edificio regalato (per EDIFICIO).
@export var building: BuildingDef
## Truppa regalata (per TRUPPA).
@export var troop: TroopDef


func describe() -> String:
	match kind:
		Kind.ORO:
			return "%d Oro" % amount
		Kind.RICERCA:
			return "%d Ricerca" % amount
		Kind.EDIFICIO:
			return "Edificio: %s" % (building.display_name if building != null else "?")
		Kind.TRUPPA:
			return "Truppa: %s" % (troop.display_name if troop != null else "?")
	return "?"
