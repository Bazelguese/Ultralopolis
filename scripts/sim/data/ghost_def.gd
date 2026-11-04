class_name GhostDef
extends Resource
## Avversario locale di prova per un anno (GDD §11.3, convenzione §16.3).
## Sostituisce il futuro servizio dei fantasmi online.

@export var display_name: String = ""
## Anno in cui si affronta questo fantasma.
@export var year: int = 1
## Era raggiunta dalla nazione copiata.
@export var era: int = 1
## Edifici della nazione copiata.
@export var buildings: Array[BuildingDef] = []
## Truppe da sinistra a destra.
@export var troops: Array[TroopDef] = []
