class_name BattleSideSetup
extends RefCounted
## Ciò che una nazione porta in battaglia: edifici, truppe in ordine e Resistenza.
## Vale allo stesso modo per il giocatore, per un fantasma e per una plancia generata.

## Edifici che producono mana.
var buildings: Array[BuildingDef] = []
## Truppe da sinistra (indice 0) a destra (ultimo indice).
## La simulazione le valuta da destra verso sinistra (GDD §7.3).
var troops: Array[TroopDef] = []
## Resistenza con cui la nazione inizia lo scontro.
var max_resistance: int = 0


func _init(p_buildings: Array[BuildingDef] = [], p_troops: Array[TroopDef] = [], p_max_resistance: int = 0) -> void:
	buildings = p_buildings
	troops = p_troops
	max_resistance = p_max_resistance
