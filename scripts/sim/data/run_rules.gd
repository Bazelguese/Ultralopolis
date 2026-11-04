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

@export_group("Plancia")
## Spazi iniziali (GDD §6.1: 4 edifici, 3 truppe).
@export var starting_building_slots: int = 4
@export var starting_troop_slots: int = 3
## Massimi della plancia (GDD §6.1: 10 edifici, 12 truppe).
@export var max_building_slots: int = 10
@export var max_troop_slots: int = 12
## Prezzo in Oro di uno spazio comprato come offerta (GDD §6.3).
@export var building_slot_price: int = 6
@export var troop_slot_price: int = 5

@export_group("Opportunità")
## Opportunità per macrofase (GDD §4.2: 3).
@export var opportunities_per_phase: int = 3
## Alternative mostrate in ogni opportunità (GDD §4.2: 3).
@export var alternatives_per_opportunity: int = 3
## Costo del primo rinnovo delle offerte.
@export var reroll_base_cost: int = 1
## Aumento del costo a ogni rinnovo.
@export var reroll_cost_increase: int = 1
