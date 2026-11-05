class_name EraDef
extends Resource
## Un'era (GDD §10). Nomi e valori placeholder.

@export var display_name: String = ""
## Tecnologie dell'era precedente da completare per entrare in quest'era (GDD §10.3, v0.25).
## Ignorato per la prima era. Zero = nessuna tecnologia richiesta.
@export var techs_required: int = 0
## Spazi edificio guadagnati entrando in quest'era (GDD §6.3).
@export var bonus_building_slots: int = 0
## Spazi truppa guadagnati entrando in quest'era (GDD §6.3).
@export var bonus_troop_slots: int = 0
## Pool di vie fra cui scegliere entrando in quest'era (GDD §10.4). Vuoto per la prima era.
@export var ways: Array[IdentityDef] = []
