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
## Etichette (GDD §6.6), es. &"Agricolo", &"Sacro".
@export var tags: Array[StringName] = []
## La Capitale non si può vendere né sostituire (GDD §6.2).
@export var is_capital: bool = false

@export_group("Produzione per fase")
## Risorse depositate nel Magazzino all'inizio di ogni macrofase (unità intere).
@export var gold_per_phase: int = 0
@export var research_per_phase: int = 0
@export var food_per_phase: int = 0
@export var wood_per_phase: int = 0
@export var stone_per_phase: int = 0
@export var iron_per_phase: int = 0
@export var fauna_per_phase: int = 0
@export var faith_per_phase: int = 0
@export var influence_per_phase: int = 0

@export_group("In battaglia")
## Colore del mana prodotto: rosso, verde, blu o energetico (GDD §5.3).
## Indica anche la famiglia dell'edificio.
@export var mana_type: StringName = &"energetico"
## Mana prodotto a ogni intervallo. Zero = edificio neutro, senza colore (GDD §5.3).
@export var mana_amount: int = 0
## Intervallo di produzione in millisecondi (unico per tutto ciò che produce). Parte pieno.
@export var mana_interval_ms: int = 1000
## Scudo, cura e Corruzione all'avversario prodotti a ogni intervallo (GDD §7.6.5).
@export var shield: int = 0
@export var heal: int = 0
@export var corruption: int = 0
## Inefficienza e Sabotaggio inflitti a ogni intervallo (GDD §7.7).
@export var inefficiency_ms: int = 0
@export var inefficiency_target: TimerTarget.Kind = TimerTarget.Kind.TRUPPE
@export var sabotage_ms: int = 0
@export var sabotage_target: TimerTarget.Kind = TimerTarget.Kind.TRUPPE

@export_group("Spazi concessi")
## Spazi edificio aggiunti alla plancia finché l'edificio è costruito (GDD §6.3).
@export var extra_building_slots: int = 0
## Spazi truppa aggiunti alla plancia finché l'edificio è costruito (GDD §6.3).
@export var extra_troop_slots: int = 0

@export_group("Potenziamenti")
## Costo per salire di livello: posizione 0 = dal livello 1 al 2, posizione 1 = dal 2 al 3 (GDD §6.5).
@export var upgrade_costs: Array[ResourceAmounts] = []


## Produzione per fase di una risorsa, in unità intere.
func production(type: Res.Type) -> int:
	match type:
		Res.Type.ORO: return gold_per_phase
		Res.Type.RICERCA: return research_per_phase
		Res.Type.CIBO: return food_per_phase
		Res.Type.LEGNO: return wood_per_phase
		Res.Type.PIETRA: return stone_per_phase
		Res.Type.FERRO: return iron_per_phase
		Res.Type.FAUNA: return fauna_per_phase
		Res.Type.FEDE: return faith_per_phase
		Res.Type.INFLUENZA: return influence_per_phase
	return 0
