class_name TroopDef
extends Resource
## Scheda di una truppa del catalogo (GDD §7.2).
## Contiene solo dati: le regole che li usano stanno nella simulazione.

## Identificativo unico, usato nei salvataggi.
@export var id: StringName = &""
## Nome mostrato al giocatore.
@export var display_name: String = ""
## Era in cui la truppa compare fra le offerte.
@export_range(1, 10) var era: int = 1
## Prezzo in Oro.
@export var cost_gold: int = 0
## Etichette (GDD §6.6), es. &"Fanteria", &"Cavalleria".
@export var tags: Array[StringName] = []
## Cibo consumato a inizio anno, in decimi (5 = 0,5 Cibo, GDD §5.4).
@export var food_tenths: int = 5

@export_group("In battaglia")
## Colore del mana richiesto: rosso, verde o blu (GDD §5.3). Ignorato se mana_cost è 0.
@export var mana_type: StringName = &"rosso"
## Mana consumato a ogni attivazione. Zero = truppa senza richiesta di mana.
@export var mana_cost: int = 0
## Tempo di ricarica in millisecondi. Parte pieno a inizio battaglia.
@export var cooldown_ms: int = 1000
## Danno inflitto alla Resistenza avversaria a ogni attivazione.
@export var damage: int = 0

@export_group("Potenziamenti")
## Costo per salire di livello: posizione 0 = dal livello 1 al 2, posizione 1 = dal 2 al 3 (GDD §6.5).
@export var upgrade_costs: Array[ResourceAmounts] = []
