class_name RunRules
extends Resource
## Regole numeriche della run (GDD §3, §4, §6). Valori placeholder salvo dove indicato.

@export_group("Vittoria e Prestigio")
## Vittorie necessarie per vincere la run (GDD §3.4: 10).
@export var wins_needed: int = 10
## Prestigio iniziale (GDD §3.4: 20).
@export var starting_prestige: int = 20
## Anni della run di prova; 0 = nessun limite (convenzione §16.3: 3).
@export var prototype_years: int = 3
## Bottino fisso per una vittoria (o un pareggio) contro il fantasma: Oro e Ricerca.
@export var ghost_loot_gold: int = 0
@export var ghost_loot_research: int = 0

@export_group("Dotazione iniziale")
@export var starting_gold: int = 5
@export var starting_research: int = 0
@export var starting_buildings: Array[BuildingDef] = []
@export var starting_troops: Array[TroopDef] = []
## Perk scelti alla creazione della nazione (placeholder).
@export var starting_perks: int = 2

@export_group("Plancia")
## Spazi iniziali (GDD §6.1: 4 edifici, 3 truppe).
@export var starting_building_slots: int = 4
@export var starting_troop_slots: int = 3
## Massimi della plancia (GDD §6.1: 10 edifici, 12 truppe).
@export var max_building_slots: int = 10
@export var max_troop_slots: int = 12

@export_group("Risorse e mantenimento")
## Unità di una risorsa da vendere al mercato per ottenere 1 Oro (GDD §5.3).
@export var market_units_per_gold: int = 2
## Aumento della ricarica di una truppa affamata, in percentuale (GDD §5.4: +50%).
@export var hunger_cooldown_percent: int = 50

@export_group("Potenziamenti")
## Livello massimo di edifici e truppe (GDD §6.5).
@export var max_level: int = 3
## Aumento di tutti i valori d'effetto per ogni livello oltre il primo, in percentuale
## (danno, scudo, cura, Corruzione, assedio, durate; il mana non cambia, GDD §6.5).
@export var troop_damage_percent_per_level: int = 50
## Unità in più, per ogni livello oltre il primo, di ogni risorsa che l'edificio produce.
@export var building_production_per_level: int = 1

@export_group("Consiglio")
## Round in ciascuna delle due metà dell'anno (GDD §3.2: 5).
@export var rounds_per_half: int = 5
## Consiglieri pescati in ogni round (GDD §4.2: 3).
@export var councillors_per_round: int = 3
## Proposte di un consigliere (GDD §4.2: 3).
@export var proposals_per_councillor: int = 3
## Proposte del Clown (GDD §4.2.2: 4).
@export var clown_proposals: int = 4
## Tipi dei round di una metà, mescolati con il seme della run all'inizio di ogni metà:
## 0 Azioni, 1 Edifici, 2 Truppe, 3 Misto (GDD §4.2).
@export var round_types: PackedInt32Array = PackedInt32Array([0, 1, 2, 3, 3])
## Nomi dei livelli dei consiglieri, uno per era (GDD §4.2.1).
@export var tier_names: PackedStringArray = PackedStringArray(["Funzionario", "Ministro", "Gran Consigliere"])
## Costo del primo rinnovo delle proposte.
@export var reroll_base_cost: int = 1
## Il rinnovo non costa mai meno di così, nemmeno con i bonus che lo riducono.
@export var reroll_min_cost: int = 1
## Aumento del costo a ogni rinnovo.
@export var reroll_cost_increase: int = 1
