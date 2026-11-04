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
## Valori di partenza che un modificatore può cambiare (GDD §8.2, v0.16).
var start_shield: int = 0
var start_corruption: int = 0
## Un edificio a caso parte sabotato per questi millisecondi (es. malus Rete compromessa).
var start_building_sabotage_ms: int = 0
## Effetti dello spionaggio avversario a inizio scontro (GDD §12):
## [sabotaggio (true) o rallentamento (false), TimerTarget.Kind, TimerTarget.Criterion, millisecondi].
var start_timer_effects: Array[Array] = []


func _init(p_buildings: Array[BuildingDef] = [], p_troops: Array[TroopDef] = [], p_max_resistance: int = 0) -> void:
	buildings = p_buildings
	troops = p_troops
	max_resistance = p_max_resistance
