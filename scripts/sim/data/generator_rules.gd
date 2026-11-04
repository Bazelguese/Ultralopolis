class_name GeneratorRules
extends Resource
## Regole per generare fantasmi e incontri del mondo quando i dati scritti a mano non bastano
## (GDD §11.3, §3.3). Tutti i numeri sono placeholder: crescono con l'anno.

@export_group("Ere")
## Ogni quanti anni gli avversari generati passano all'era successiva.
@export var years_per_era: int = 4

@export_group("Fantasmi")
## Edifici oltre alla Capitale: base + anno × decimi / 10.
@export var ghost_buildings_base: int = 1
@export var ghost_buildings_per_year_tenths: int = 5
## Truppe: base + anno × decimi / 10.
@export var ghost_troops_base: int = 2
@export var ghost_troops_per_year_tenths: int = 6
## Ogni quanti anni le truppe dei fantasmi salgono di un livello.
@export var ghost_level_every_years: int = 5
## Perk di ogni fantasma generato.
@export var ghost_perks: int = 2
## Malus fra cui scegliere quello che il fantasma lascia in caso di sconfitta o pareggio.
@export var ghost_malus_pool: Array[ModifierDef] = []
## Parti del nome, es. "Ducato" + "di Pietrabianca".
@export var nation_name_prefixes: PackedStringArray = PackedStringArray()
@export var nation_name_places: PackedStringArray = PackedStringArray()

@export_group("Incontri del mondo")
## Nomi e descrizioni delle minacce (stesse posizioni nelle due liste).
@export var encounter_names: PackedStringArray = PackedStringArray()
@export var encounter_descriptions: PackedStringArray = PackedStringArray()
@export var difficulty_labels: PackedStringArray = PackedStringArray(["Facile", "Media", "Difficile"])
## Forza di ogni difficoltà in percentuale (Resistenza e ricompense).
@export var difficulty_percents: PackedInt32Array = PackedInt32Array([70, 100, 135])
@export var encounter_resistance_base: int = 15
@export var encounter_resistance_per_year: int = 7
## Truppe: base + anno × decimi / 10 + posizione della difficoltà.
@export var encounter_troops_base: int = 1
@export var encounter_troops_per_year_tenths: int = 4

@export_group("Ricompense degli incontri")
@export var reward_gold_base: int = 3
@export var reward_gold_per_year: int = 1
@export var reward_resource_base: int = 2
@export var reward_resource_per_year_tenths: int = 5
