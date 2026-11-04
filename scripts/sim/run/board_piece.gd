class_name BoardPiece
extends RefCounted
## Un elemento posseduto sulla plancia: un edificio oppure una truppa,
## con il prezzo pagato (serve per il rimborso della vendita, GDD §6.4).

var building: BuildingDef
var troop: TroopDef
## Oro pagato per ottenerlo. 0 per la dotazione iniziale e le ricompense.
var paid: int = 0


static func of_building(def: BuildingDef, p_paid: int) -> BoardPiece:
	var piece: BoardPiece = BoardPiece.new()
	piece.building = def
	piece.paid = p_paid
	return piece


static func of_troop(def: TroopDef, p_paid: int) -> BoardPiece:
	var piece: BoardPiece = BoardPiece.new()
	piece.troop = def
	piece.paid = p_paid
	return piece


func display_name() -> String:
	if building != null:
		return building.display_name
	if troop != null:
		return troop.display_name
	return "?"
