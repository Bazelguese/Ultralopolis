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
## Carta dorata (GDD §10.5.6, v0.26): una tecnologia già iniziata. Se give_random_tech è vero,
## una tecnologia a caso fra quelle ricercabili nella sua era, della sfera indicata (vuota = qualsiasi).
@export var give_tech: TechDef
@export var give_random_tech: bool = false
@export var give_tech_sphere: String = ""
## Nuovo governo della nazione (IdentityDef), per la Riforma e la Rivoluzione (GDD §9.4, v0.24).
@export var change_government: Resource
## Malcontento in più (o, se negativo, in meno) (GDD §5.5, v0.24).
@export var malcontent_change: int = 0

@export_group("Cronache (GDD §9.6, v0.29)")
## Passi sulle quattro inclinazioni, nell'ordine Spada, Porta, Altare, Legge (Inclination.Axis):
## positivo verso Conquistatrice, Aperta, Devota, Ordinata; negativo verso l'altro polo.
@export var inclination_shift: PackedInt32Array = PackedInt32Array()
## Ricordi che la scelta lascia nella nazione (per le catene) e ricordi che cancella.
@export var set_flags: Array[StringName] = []
@export var clear_flags: Array[StringName] = []
## Personaggio che entra nella storia della nazione, con la fiducia iniziale.
@export var introduce_character: CharacterDef
## Fiducia in più o in meno del personaggio della cronaca (introdotto o richiesto).
@export var character_affinity: int = 0
## Il personaggio della cronaca esce dalla storia.
@export var character_leaves: bool = false
## Vocazione accettata (IdentityDef), per le opzioni costruite dalle regole.
@export var vocation: Resource
## Riga che resta nella storia della nazione, es. "Il popolo festeggiò per tre giorni."
@export var story: String = ""
