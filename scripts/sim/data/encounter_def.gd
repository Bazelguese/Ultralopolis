class_name EncounterDef
extends Resource
## Un incontro del mondo: minaccia con una plancia generata (GDD §3.3).

@export var display_name: String = ""
@export_multiline var description: String = ""
## Anno in cui l'incontro può comparire.
@export var year: int = 1
## Stagione dell'incontro (GDD §3.3, v0.25): 0 = fine primavera, 1 = fine estate.
@export_enum("Primavera", "Estate") var season: int = 0
## Etichetta di difficoltà mostrata al giocatore (es. "Facile").
@export var difficulty_label: String = ""
## Resistenza fissa della plancia generata (niente calcolo, GDD §3.3).
@export var resistance: int = 20
## Forma della plancia dell'incontro (solo aspetto): una per famiglia di incontri. Vuoto = forma
## semplice, finché la famiglia non ha la sua.
@export var board_shape: StringName = &""
@export var buildings: Array[BuildingDef] = []
## Truppe da sinistra a destra.
@export var troops: Array[TroopDef] = []
## Ricompense fra cui il giocatore può sceglierne una (o nessuna) se vince.
@export var rewards: Array[RewardDef] = []
## Bottino fisso se vince (anche con un pareggio), in aggiunta alla ricompensa a scelta.
@export var loot_gold: int = 0
@export var loot_research: int = 0
