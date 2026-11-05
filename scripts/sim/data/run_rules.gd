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

@export_group("Tecnologie (GDD §10.5, v0.26)")
## Carte della mano delle tecnologie (GDD §10.5.3: 3).
@export var tech_hand_size: int = 3
## Sconto sulla carta scartata: il peso si dimezza a ogni scarto, fino a 1 / 2^tech_discard_max_halvings
## del peso pieno (placeholder §16.3: 3, cioè 1/8).
@export var tech_discard_max_halvings: int = 3
## Parte del costo già pagata in una carta dorata, in percentuale (placeholder §16.3: 50).
@export var golden_progress_percent: int = 50
## Tecnologie della prima altezza di un ramo che aprono la seconda altezza dello stesso ramo
## nella stessa era (placeholder §16.3: 1).
@export var tech_second_tier_needed: int = 1

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
## Nomi dei livelli del Consiglio, uno per era (GDD §4.2.1, nomi placeholder).
@export var council_level_names: PackedStringArray = PackedStringArray(["Funzionari", "Ministri", "Gran Consiglieri"])
## Round in ogni stagione dell'anno (GDD §3.2, v0.25: 3, uno per mese).
@export var rounds_per_season: int = 3
## Consiglieri pescati in ogni round, diversi fra loro (GDD §4.2: 3).
@export var advisors_per_round: int = 3
## Proposte mostrate dal consigliere scelto (GDD §4.2: 3; il Clown ne mostra una per colore più un neutro).
@export var proposals_per_advisor: int = 3
## Temi dei round di ogni stagione, nell'ordine inverno, primavera, estate, autunno (GDD §4.2, v0.25),
## pescati in ordine casuale con il seme della run: 0 = Azioni, 1 = Edifici, 2 = Truppe, 3 = Misto.
## Se una stagione ha meno temi che round si ripete l'ultimo; se manca una stagione vale l'ultima.
@export var season_themes: Array[PackedInt32Array] = [
	PackedInt32Array([0, 1, 3]),
	PackedInt32Array([1, 3, 3]),
	PackedInt32Array([2, 1, 3]),
	PackedInt32Array([2, 0, 3]),
]
## Costo di Potenzia: per salire al livello 2 servono upgrade_cost_per_era[0] × era della carta
## unità della risorsa del consigliere, per il livello 3 upgrade_cost_per_era[1] × era (placeholder).
@export var upgrade_cost_per_era: PackedInt32Array = PackedInt32Array([2, 3])
## Malcontento (GDD §5.5, v0.24). Tutti i valori sono placeholder (§16.3).
## Raggiunta la soglia, il round successivo mostra solo la Rivoluzione.
@export var malcontent_threshold: int = 10
## Da questo valore il gioco avverte che la rivoluzione si avvicina.
@export var malcontent_warning: int = 7
@export var malcontent_per_ghost_defeat: int = 2
@export var malcontent_per_encounter_defeat: int = 1
## Per ogni truppa che resta senza Cibo al consumo di inizio anno (carestia).
@export var malcontent_per_hungry_troop: int = 1
## Per ogni malus subito dal fantasma.
@export var malcontent_per_malus: int = 1
## Riforma (GDD §9.4, v0.24): Influenza per ogni tier del governo da raggiungere (placeholder).
@export var reform_influence_per_tier: int = 3
## Potenzia dell'Anziano (solo edifici neutri) per anno (GDD §4.2.2: 1).
@export var elder_upgrades_per_year: int = 1
## Probabilità, in percentuale, che in un round una delle carte sia un Evento, un Visitatore
## o una Fortuna al posto di un consigliere (GDD §4.2.5: in media 1 round su 3).
@export var special_card_chance_percent: int = 33
## Pesi delle tre famiglie (GDD §4.2.5: 5, 3, 2).
@export var event_weight: int = 5
@export var visitor_weight: int = 3
@export var fortune_weight: int = 2
## Costo del primo rinnovo delle proposte.
@export var reroll_base_cost: int = 1
## Il rinnovo non costa mai meno di così, nemmeno con i bonus che lo riducono.
@export var reroll_min_cost: int = 1
## Aumento del costo a ogni rinnovo.
@export var reroll_cost_increase: int = 1


## Stessi temi in tutte e quattro le stagioni (comodo per le prove e per i test).
func set_all_season_themes(themes: PackedInt32Array) -> void:
	season_themes = [themes, themes, themes, themes]
