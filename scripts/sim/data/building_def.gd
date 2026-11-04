class_name BuildingDef
extends Resource
## Scheda di un edificio del catalogo (GDD §5.1, §7.4).
## Contiene solo dati: le regole che li usano stanno nella simulazione.

## Identificativo unico, usato nei salvataggi.
@export var id: StringName = &""
## Nome mostrato al giocatore.
@export var display_name: String = ""
## Era in cui l'edificio compare fra le offerte.
@export_range(1, 10) var era: int = 1
## Prezzo in Oro.
@export var cost_gold: int = 0

@export_group("Fuori dal combattimento")
## Oro depositato nel Magazzino all'inizio di ogni macrofase.
@export var gold_per_phase: int = 0
## Ricerca depositata nel Magazzino all'inizio di ogni macrofase.
@export var research_per_phase: int = 0

@export_group("In battaglia")
## Tipo di mana prodotto. Per ora esiste un solo tipo (GDD §5.3).
@export var mana_type: StringName = &"neutro"
## Mana prodotto a ogni intervallo.
@export var mana_amount: int = 0
## Intervallo di produzione in millisecondi. Parte pieno a inizio battaglia.
@export var mana_interval_ms: int = 1000
