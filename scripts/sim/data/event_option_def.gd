class_name EventOptionDef
extends Resource
## Un'opzione di un Evento o il dono di una Fortuna (GDD §4.2.5, v0.23).
## Può chiedere un requisito della nazione; costi ed effetti usano il linguaggio del nucleo (P5).

## Su quali carte agisce il potenziamento dell'opzione.
enum PieceKind {
	QUALSIASI,
	EDIFICIO,
	TRUPPA,
}

## Testo breve sul pulsante o sulla carta, es. "Alza gli argini".
@export var label: String = ""
## Che cosa succede, in parole semplici.
@export_multiline var description: String = ""

@export_group("Requisito")
## L'opzione è disponibile solo con almeno uno di questi elementi dell'identità (IdentityDef).
## Dichiarati come Resource per lo stesso motivo di IdentityDef.requires_any.
@export var requires_identity: Array[Resource] = []
## L'opzione è disponibile solo con almeno una carta sulla plancia che ha uno di questi tipi.
@export var requires_types: Array[StringName] = []
## Carte considerate per requires_types.
@export var requires_kind: PieceKind = PieceKind.QUALSIASI
## Testo del requisito, es. "Spirituale"; se vuoto lo si ricava dai campi sopra.
@export var requirement_label: String = ""

@export_group("Costo")
@export var cost: ResourceAmounts

@export_group("Effetti")
## Risorse ricevute. Per le Fortune possono crescere con l'era (EventDef.scale_with_era).
@export var gain: ResourceAmounts
## Modificatori applicati (bonus o malus per un anno, fino al prossimo fantasma o permanenti).
## Un modificatore TRUPPA_SCELTA si applica alla truppa scelta dal giocatore.
@export var modifiers: Array[ModifierDef] = []
## Edificio o truppa regalati (se c'è uno spazio libero).
@export var give_building: BuildingDef
@export var give_troop: TroopDef
## In alternativa: una carta a caso dell'era corrente, con almeno uno di questi tipi
## (vuoto = qualsiasi tipo), del genere indicato.
@export var give_random: bool = false
@export var give_random_kind: PieceKind = PieceKind.EDIFICIO
@export var give_random_types: Array[StringName] = []
## Una carta a scelta della plancia, con uno di questi tipi, sale di un livello.
@export var upgrade: bool = false
@export var upgrade_types: Array[StringName] = []
@export var upgrade_kind: PieceKind = PieceKind.QUALSIASI
## Spazi ricevuti (mai oltre il massimo della plancia).
@export var extra_building_slots: int = 0
@export var extra_troop_slots: int = 0
## Spionaggio sul fantasma dell'anno: si usano i campi di spionaggio di questa azione.
@export var spy: OpportunityDef
## Nuovo governo della nazione (IdentityDef), per la Riforma e la Rivoluzione (GDD §9.4, v0.24).
@export var change_government: Resource
