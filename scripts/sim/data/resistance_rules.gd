class_name ResistanceRules
extends Resource
## Valori per il calcolo della Resistenza (GDD §7.1.1). Tutti placeholder.

## Quota data dall'era: posizione 0 = era 1, posizione 1 = era 2, ...
@export var per_era: Array[int] = [20, 30, 40]
## Aumento per ogni anno (convenzione: anno N vale N volte questo numero).
@export var per_year: int = 5
## Quota per ogni edificio costruito.
@export var per_building: int = 2
## Quota per ogni truppa posizionata.
@export var per_troop: int = 2
