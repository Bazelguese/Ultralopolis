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
## Danno in più per ogni livello oltre il primo, in percentuale.
@export var troop_damage_percent_per_level: int = 50
## Unità in più, per ogni livello oltre il primo, di ogni risorsa che l'edificio produce.
@export var building_production_per_level: int = 1

@export_group("Opportunità")
## Opportunità per macrofase (GDD §4.2: 2).
@export var opportunities_per_phase: int = 2
## Alternative mostrate in ogni opportunità (GDD §4.2: 3).
@export var alternatives_per_opportunity: int = 3
## Costo del primo rinnovo delle offerte.
@export var reroll_base_cost: int = 1
## Aumento del costo a ogni rinnovo.
@export var reroll_cost_increase: int = 1
