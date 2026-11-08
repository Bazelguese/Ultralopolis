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
## Tipi (GDD §6.6, v0.22), es. &"Fante", &"Fauna". Decidono quali consiglieri
## propongono e potenziano la truppa e a quali perk e modificatori risponde.
@export var types: Array[StringName] = []
## Cibo consumato a inizio anno, in decimi (5 = 0,5 Cibo, GDD §5.4).
@export var food_tenths: int = 5

@export_group("Nello scontro")
## Colore del mana richiesto: rosso, verde, blu o viola (GDD §5.3). Ignorato se mana_cost è 0.
@export var mana_type: StringName = &"rosso"
## Mana consumato a ogni attivazione. Zero = truppa senza richiesta di mana.
@export var mana_cost: int = 0
## Tempo di ricarica in millisecondi. Parte pieno a inizio battaglia.
@export var cooldown_ms: int = 1000
## Danno inflitto a ogni attivazione: colpisce prima lo scudo, poi la Resistenza (GDD §7.6).
@export var damage: int = 0
## Scudo aggiunto alla propria riserva a ogni attivazione (GDD §7.6.1).
@export var shield: int = 0
## Resistenza recuperata a ogni attivazione, mai oltre il massimo (GDD §7.6.2).
@export var heal: int = 0
## Corruzione inflitta all'avversario a ogni attivazione (GDD §7.6.3).
@export var corruption: int = 0
## Danno agli scudi (attacco d'assedio): solo truppe con tipo Assedio (GDD §7.6.4).
@export var siege_damage: int = 0
## Inefficienza inflitta (millisecondi) e sua categoria di bersaglio (GDD §7.7).
@export var inefficiency_ms: int = 0
@export var inefficiency_target: TimerTarget.Kind = TimerTarget.Kind.TRUPPE
## Sabotaggio inflitto (millisecondi) e sua categoria di bersaglio (GDD §7.7).
@export var sabotage_ms: int = 0
@export var sabotage_target: TimerTarget.Kind = TimerTarget.Kind.TRUPPE

