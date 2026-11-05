class_name OpportunityDef
extends Resource
## Un'azione del Consiglio (GDD §4.2.3): una delle proposte che un consigliere può fare,
## diversa dall'acquisto di un edificio o di una truppa. Ogni proposta è un singolo acquisto
## o una singola scelta. Prima del Consiglio (v0.21) si chiamava "opportunità".

## Non più usata dal Consiglio (le azioni valgono in entrambe le metà): resta per i vecchi dati.
enum Phase {
	PRODUZIONE,
	PREPARAZIONE,
}

enum Kind {
	COSTRUISCI_EDIFICIO,    ## Proposta di un edificio (i consiglieri la creano dai loro tipi).
	RECLUTA_TRUPPA,         ## Proposta di una truppa (i consiglieri la creano dai loro tipi).
	SPAZIO_EDIFICIO,        ## Un nuovo spazio edificio (es. Architetti).
	SPAZIO_TRUPPA,          ## Un nuovo spazio truppa (es. Quartiermastro).
	SCAMBIO_RISORSE,        ## Paghi risorse, ne ricevi altre (es. Studiosi, Esattori, Mercante, Scorte).
	MODIFICATORE_A_SCELTA,  ## Ricevi uno dei modificatori elencati (es. Assemblea, Addestramento, Fortificazioni).
	ACCORCIA_MALUS,         ## Accorcia di qualche anno un malus attivo a scelta (es. Ambasciata).
	SPIONAGGIO,             ## Un elemento del fantasma parte sabotato o rallentato (GDD §12).
	INCANTO,                ## Aggiunge un effetto e un costo di mana a una truppa (GDD §4.3).
	PERK,                   ## Un perk proposto dall'Anziano (GDD §4.2.2, §9.3).
}

## Criterio con cui lo spionaggio sceglie l'elemento nemico (GDD §12).
enum SpyCriterion {
	A_CASO,      ## Un elemento a caso fra quelli validi.
	ESTREMITA,   ## L'elemento all'estremità destra della fila (il primo ad agire).
	PIU_LENTO,   ## Ricarica o intervallo più lunghi.
	PIU_VELOCE,  ## Ricarica o intervallo più corti.
}

## Effetto dello spionaggio all'inizio dello scontro con il fantasma (GDD §7.7, §12).
enum SpyEffect {
	SABOTAGGIO,
	INEFFICIENZA,
}

@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""
## Non più usata (vedi Phase).
@export var phase: Phase = Phase.PRODUZIONE
@export var kind: Kind = Kind.COSTRUISCI_EDIFICIO

@export_group("Costo")
## Oro da pagare (le azioni non costano Oro, salvo gli spazi: GDD §4.2).
@export var cost_gold: int = 0
## Ricerca da pagare.
@export var cost_research: int = 0
## Altre risorse da pagare (es. Ferro per l'Addestramento, Stabilità per l'Ambasciata).
@export var cost_resources: ResourceAmounts

@export_group("Guadagno")
## Oro ricevuto (SCAMBIO_RISORSE).
@export var gain_gold: int = 0
## Ricerca ricevuta (SCAMBIO_RISORSE).
@export var gain_research: int = 0
## Altre risorse ricevute (SCAMBIO_RISORSE), es. il Cibo delle Scorte.
@export var gain_resources: ResourceAmounts
## Modificatori fra cui scegliere (MODIFICATORE_A_SCELTA). Con uno solo non c'è scelta.
@export var modifiers: Array[ModifierDef] = []
## Anni tolti al malus scelto (ACCORCIA_MALUS).
@export var shorten_years: int = 1

@export_group("Spionaggio")
@export var spy_effect: SpyEffect = SpyEffect.SABOTAGGIO
## Durata dell'effetto all'inizio dello scontro con il fantasma, in millisecondi.
@export var spy_ms: int = 5000
## Truppe, edifici o qualsiasi elemento.
@export var spy_target: TimerTarget.Kind = TimerTarget.Kind.TRUPPE
@export var spy_criterion: SpyCriterion = SpyCriterion.A_CASO

@export_group("Incanto")
## Valore di battaglia aggiunto alla truppa: danno, scudo, cura, Corruzione o Inefficienza (GDD §4.3).
@export var enchant_value: ModifierDef.BattleValue = ModifierDef.BattleValue.DANNO
## Quantità per era della truppa: posizione 0 = era 1 (in millisecondi per l'Inefficienza).
@export var enchant_amounts: PackedInt32Array = PackedInt32Array([2, 4, 6])
## Mana in più chiesto dalla truppa incantata (GDD §4.3: 2).
@export var enchant_mana: int = 2
## Colore del mana se la truppa prima non ne chiedeva (GDD §4.3).
@export var enchant_color: StringName = &"blu"
