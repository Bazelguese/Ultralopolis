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

@export_group("In battaglia")
## Tipo di mana richiesto. Per ora esiste un solo tipo (GDD §5.3).
@export var mana_type: StringName = &"neutro"
## Mana consumato a ogni attivazione. Zero = truppa senza richiesta di mana.
@export var mana_cost: int = 0
## Tempo di ricarica in millisecondi. Parte pieno a inizio battaglia.
@export var cooldown_ms: int = 1000
## Danno inflitto alla Resistenza avversaria a ogni attivazione.
@export var damage: int = 0
