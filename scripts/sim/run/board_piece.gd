class_name BoardPiece
extends RefCounted
## Un elemento posseduto sulla plancia: un edificio oppure una truppa,
## con il suo valore per il rimborso della vendita (GDD §6.4).

var building: BuildingDef
var troop: TroopDef
## Valore per il rimborso: il prezzo pagato; per le ricompense il prezzo di catalogo;
## 0 per la dotazione iniziale. La vendita rimborsa metà di questo valore.
var paid: int = 0
## Livello raggiunto con i potenziamenti (GDD §6.5).
var level: int = 1
## true se la truppa non ha mangiato all'ultimo consumo di Cibo (GDD §5.4).
var hungry: bool = false
## true se all'ultimo pagamento del mantenimento la carta non è stata pagata (GDD §5.6):
## nello scontro lavora più piano.
var neglected: bool = false
## Incanto del Sacerdote (GDD §4.3): una sola volta per truppa, per tutta la run.
var enchant: OpportunityDef
## Quantità dell'effetto dell'incanto, fissata quando la truppa viene incantata.
var enchant_amount: int = 0
## Quantità del secondo effetto, per gli incanti esclusivi che ne hanno due (GDD §9.4, v0.24).
var enchant_amount_2: int = 0
## Secondo incanto, possibile solo con l'ascensione Seconda natura (GDD §10.4.2, v0.27).
var second_enchant: OpportunityDef
var second_enchant_amount: int = 0
var second_enchant_amount_2: int = 0


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
