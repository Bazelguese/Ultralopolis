class_name EraDef
extends Resource
## Un'era (GDD §10). Nomi e valori placeholder.

@export var display_name: String = ""
## Ricerca da pagare per entrare in quest'era (ignorato per la prima era).
@export var research_cost: int = 0
## Spazi edificio guadagnati entrando in quest'era (GDD §6.3).
@export var bonus_building_slots: int = 0
## Spazi truppa guadagnati entrando in quest'era (GDD §6.3).
@export var bonus_troop_slots: int = 0
