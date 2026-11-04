class_name OpportunityDef
extends Resource
## Un tipo di opportunità (GDD §4.2): una delle voci che possono comparire
## fra le 3 alternative di una scelta. Ogni alternativa è un singolo acquisto o una singola scelta.

enum Phase {
	PRODUZIONE,    ## Fase di costruzione.
	PREPARAZIONE,  ## Fase di disposizione.
}

enum Kind {
	COSTRUISCI_EDIFICIO,    ## Offre un edificio dell'era corrente, pescato a caso (es. Costruttori).
	RECLUTA_TRUPPA,         ## Offre una truppa dell'era corrente, pescata a caso (es. Reclutatori).
	SPAZIO_EDIFICIO,        ## Un nuovo spazio edificio (es. Architetti).
	SPAZIO_TRUPPA,          ## Un nuovo spazio truppa (es. Quartiermastro).
	SCAMBIO_RISORSE,        ## Paghi Oro e/o Ricerca, ricevi Oro e/o Ricerca (es. Studiosi, Esattori, Mercante).
	MODIFICATORE_A_SCELTA,  ## Ricevi uno dei modificatori elencati (es. Assemblea, Addestramento, Fortificazioni).
	ACCORCIA_MALUS,         ## Accorcia di qualche anno un malus attivo a scelta (es. Ambasciata).
}

@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var phase: Phase = Phase.PRODUZIONE
@export var kind: Kind = Kind.COSTRUISCI_EDIFICIO

@export_group("Costo")
## Oro da pagare (per gli edifici e le truppe conta invece il loro prezzo).
@export var cost_gold: int = 0
## Ricerca da pagare.
@export var cost_research: int = 0

@export_group("Guadagno")
## Oro ricevuto (SCAMBIO_RISORSE).
@export var gain_gold: int = 0
## Ricerca ricevuta (SCAMBIO_RISORSE).
@export var gain_research: int = 0
## Modificatori fra cui scegliere (MODIFICATORE_A_SCELTA). Con uno solo non c'è scelta.
@export var modifiers: Array[ModifierDef] = []
## Anni tolti al malus scelto (ACCORCIA_MALUS).
@export var shorten_years: int = 1
