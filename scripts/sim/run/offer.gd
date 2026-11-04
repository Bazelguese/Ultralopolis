class_name Offer
extends RefCounted
## Una delle alternative mostrate in un'opportunità (GDD §4.2).

enum Kind {
	EDIFICIO,
	TRUPPA,
	SPAZIO_EDIFICIO,
	SPAZIO_TRUPPA,
}

var kind: Kind = Kind.EDIFICIO
var building: BuildingDef
var troop: TroopDef
var price: int = 0


func describe() -> String:
	match kind:
		Kind.EDIFICIO:
			return "Edificio: %s" % building.display_name
		Kind.TRUPPA:
			return "Truppa: %s" % troop.display_name
		Kind.SPAZIO_EDIFICIO:
			return "Nuovo spazio edificio"
		Kind.SPAZIO_TRUPPA:
			return "Nuovo spazio truppa"
	return "?"
