class_name OpportunityDef
extends Resource
## Un'azione del Consiglio (GDD §4.2): una delle proposte che un consigliere può fare.
## Ogni proposta è un singolo acquisto o una singola scelta.
## (Il nome della classe viene dalle "opportunità" delle versioni precedenti del GDD.)

enum Kind {
	COSTRUISCI_EDIFICIO,    ## Offre un edificio dell'era corrente, pescato a caso (es. Costruttori).
	RECLUTA_TRUPPA,         ## Offre una truppa dell'era corrente, pescata a caso (es. Reclutatori).
	SPAZIO_EDIFICIO,        ## Un nuovo spazio edificio (es. Architetti).
	SPAZIO_TRUPPA,          ## Un nuovo spazio truppa (es. Quartiermastro).
	SCAMBIO_RISORSE,        ## Paghi Oro e/o Ricerca, ricevi Oro e/o Ricerca (es. Studiosi, Esattori, Mercante).
	MODIFICATORE_A_SCELTA,  ## Ricevi uno dei modificatori elencati (es. Assemblea, Addestramento, Fortificazioni).
	ACCORCIA_MALUS,         ## Accorcia di qualche anno un malus attivo a scelta (es. Ambasciata).
	POTENZIA_EDIFICIO,      ## Un edificio a scelta sale di un livello (GDD §6.5).
	POTENZIA_TRUPPA,        ## Una truppa a scelta sale di un livello.
	INCANTA,                ## Incanta una truppa a scelta (GDD §4.3).
	SPIONAGGIO,             ## Lo scontro con il fantasma parte con un suo elemento sabotato o rallentato (§12).
	PERK,                   ## Un perk non ancora posseduto, pescato a caso (Anziano, §4.2.2).
}

## Effetto aggiunto da un incanto (GDD §4.3).
enum Enchant {
	DANNO,
	SCUDO,
	CURA,
	CORRUZIONE,
	RALLENTAMENTO,
}

@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var kind: Kind = Kind.SCAMBIO_RISORSE
## Il consigliere che propone questa azione (id di un CouncillorDef).
@export var councillor: StringName = &""
## Livello minimo del consigliere (cioè l'era, §4.2.1) perché l'azione compaia.
@export var min_tier: int = 1

@export_group("Costo")
## Oro da pagare (per gli edifici e le truppe conta invece il loro prezzo).
@export var cost_gold: int = 0
## Ricerca da pagare.
@export var cost_research: int = 0
## Altre risorse da pagare (es. Ferro per l'Addestramento, Influenza per l'Ambasciata).
@export var cost_resources: ResourceAmounts

@export_group("Guadagno")
## Oro ricevuto (SCAMBIO_RISORSE).
@export var gain_gold: int = 0
## Ricerca ricevuta (SCAMBIO_RISORSE).
@export var gain_research: int = 0
## Altre risorse ricevute (SCAMBIO_RISORSE), es. Cibo e Fauna per le Scorte.
@export var gain_resources: ResourceAmounts
## Modificatori fra cui scegliere (MODIFICATORE_A_SCELTA). Con uno solo non c'è scelta.
@export var modifiers: Array[ModifierDef] = []
## Anni tolti al malus scelto (ACCORCIA_MALUS).
@export var shorten_years: int = 1

@export_group("Incanto")
@export var enchant_effect: Enchant = Enchant.DANNO
## Valore dell'effetto; per il rallentamento sono millisecondi.
@export var enchant_value: int = 2
## Mana in più richiesto dalla truppa incantata.
@export var enchant_mana_cost: int = 2
## Colore del mana per una truppa che non usava mana.
@export var enchant_mana_type: StringName = &"rosso"
## Bersagli del rallentamento aggiunto.
@export var enchant_slow_target: TimerTarget.Kind = TimerTarget.Kind.TRUPPE

@export_group("Spionaggio")
## true: Sabotaggio; false: Inefficienza (rallentamento).
@export var spy_sabotage: bool = true
@export var spy_duration_ms: int = 5000
@export var spy_target: TimerTarget.Kind = TimerTarget.Kind.TRUPPE
@export var spy_criterion: TimerTarget.Criterion = TimerTarget.Criterion.A_CASO
