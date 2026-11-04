class_name CatalogDef
extends Resource
## Catalogo di gioco: tutto ciò che può comparire in una run (GDD §16.2).

@export var buildings: Array[BuildingDef] = []
@export var troops: Array[TroopDef] = []
## Ere in ordine: posizione 0 = prima era.
@export var eras: Array[EraDef] = []
@export var ghosts: Array[GhostDef] = []
@export var encounters: Array[EncounterDef] = []
## Tipi di opportunità che possono comparire fra le alternative (GDD §4.2).
@export var opportunities: Array[OpportunityDef] = []
