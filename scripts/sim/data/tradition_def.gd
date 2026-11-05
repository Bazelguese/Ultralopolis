class_name TraditionDef
extends Resource
## Un passo dell'albero di una via, cioè una tradizione (GDD §10.4.1, v0.26).
## Si completa da solo quando riesce la sua impresa; l'effetto vale subito e per sempre,
## con il linguaggio del nucleo (P5).

@export var id: StringName = &""
@export var display_name: String = ""
## Effetto in parole semplici.
@export_multiline var description: String = ""
## L'impresa che completa il passo.
@export var deed: DeedDef

@export_group("Effetti")
@export var permanent_modifiers: Array[ModifierDef] = []
## Spazi ricevuti (mai oltre il massimo della plancia).
@export var extra_building_slots: int = 0
@export var extra_troop_slots: int = 0
