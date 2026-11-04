class_name RunState
extends RefCounted
## Stato e regole di una run (GDD §3, §4, §5, §6, §10).
##
## Logica pura: l'interfaccia legge questo stato e chiama i metodi pubblici,
## che controllano sempre se l'azione è permessa. Se un'azione non è permessa
## il metodo restituisce false e spiega il motivo in last_error.
##
## Sequenza dell'anno (GDD §3.2, §4.1):
##   PRODUZIONE (5 round) -> SCELTA_INCONTRO -> [RICOMPENSA_INCONTRO]
##   -> PREPARAZIONE (5 round) -> SCONTRO_FANTASMA -> anno successivo.
## In ogni round si sceglie uno di 3 consiglieri e poi una delle sue proposte (GDD §4.2).

enum Phase {
	PRODUZIONE,
	SCELTA_INCONTRO,
	RICOMPENSA_INCONTRO,
	PREPARAZIONE,
	SCONTRO_FANTASMA,
	FINE_RUN,
	CREAZIONE_NAZIONE,  ## Prima dell'anno 1: si sceglie l'identità (GDD §9).
}

enum RunEnd {
	NESSUNA,
	VITTORIA,     ## Raggiunte le vittorie necessarie.
	SCONFITTA,    ## Persa una battaglia durante l'ultima possibilità.
	FINE_PROVA,   ## Finiti gli anni della run di prova (convenzione §16.3).
}

enum BattleKind {
	NESSUNA,
	INCONTRO,
	FANTASMA,
}

## Tipo del round: decide che cosa propongono i consiglieri (GDD §4.2).
enum RoundType {
	AZIONI,   ## Solo azioni.
	EDIFICI,  ## Solo edifici affini.
	TRUPPE,   ## Solo truppe affini.
	MISTO,    ## Azioni ed elementi.
}

const ROUND_TYPE_NAMES: Dictionary[RoundType, String] = {
	RoundType.AZIONI: "Azioni",
	RoundType.EDIFICI: "Edifici",
	RoundType.TRUPPE: "Truppe",
	RoundType.MISTO: "Misto",
}

## Colori del mana fra cui il Clown sceglie i suoi 4 elementi (GDD §4.2.2).
const CLOWN_COLORS: Array[StringName] = [&"rosso", &"verde", &"blu", &"neutro"]

const PHASE_NAMES: Dictionary[Phase, String] = {
	Phase.PRODUZIONE: "Produzione",
	Phase.SCELTA_INCONTRO: "Incontro del mondo",
	Phase.RICOMPENSA_INCONTRO: "Ricompensa",
	Phase.PREPARAZIONE: "Preparazione",
	Phase.SCONTRO_FANTASMA: "Scontro con il fantasma",
	Phase.FINE_RUN: "Fine della run",
	Phase.CREAZIONE_NAZIONE: "Creazione della nazione",
}

var catalog: CatalogDef
var run_rules: RunRules
var battle_rules: BattleRules
var resistance_rules: ResistanceRules

## Seme casuale della run, registrato per poterla riprodurre.
var run_seed: int = 0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

var year: int = 0
var phase: Phase = Phase.PRODUZIONE
var era: int = 1
var wins: int = 0
var prestige: int = 0
var last_chance: bool = false
var run_end: RunEnd = RunEnd.NESSUNA

## Magazzino (GDD §5.3): una casella per risorsa, in unità interne (il Cibo in decimi).
var stock: Array[int] = Res.empty()

var gold: int:
	get:
		return stock[Res.Type.ORO]
	set(value):
		stock[Res.Type.ORO] = value

var research: int:
	get:
		return stock[Res.Type.RICERCA]
	set(value):
		stock[Res.Type.RICERCA] = value

var board: NationBoard = NationBoard.new()
## Malus e bonus attivi (GDD §8).
var modifiers: Modifiers = Modifiers.new()

## Numero del round in corso nella metà dell'anno (1..5).
var round_number: int = 0
## Tipo del round in corso.
var round_type: RoundType = RoundType.MISTO
## Tipi dei round di questa metà, nell'ordine pescato.
var _half_round_types: Array[int] = []
## I consiglieri fra cui scegliere in questo round.
var councillor_choices: Array[CouncillorDef] = []
## Il consigliere scelto in questo round (null finché non si sceglie).
var councillor: CouncillorDef
## Proposte del consigliere scelto.
var offers: Array[Offer] = []
## Spionaggi comprati: valgono nel prossimo scontro con il fantasma (GDD §12).
var spy_actions: Array[OpportunityDef] = []
## Aumento accumulato del costo di rinnovo (GDD §4.2).
var reroll_extra: int = 0

## Fantasma dell'anno, fissato all'inizio dell'anno (GDD §4.1, §11.2).
var current_ghost: GhostDef
## Incontri fra cui scegliere quest'anno.
var encounter_choices: Array[EncounterDef] = []
## Incontro vinto, di cui si sta scegliendo la ricompensa.
var won_encounter: EncounterDef

## Ultima battaglia combattuta (già conclusa) e suoi dati.
var last_battle: BattleSim
var last_battle_kind: BattleKind = BattleKind.NESSUNA
var last_opponent_name: String = ""
var _last_setups: Array[BattleSideSetup] = []
## Seme dell'ultimo scontro, ricavato dal seme della run, dall'anno e dal tipo di scontro (§16.3).
var last_battle_seed: int = 0

## Riepilogo di un anno della run (per la schermata finale).
class YearRecord:
	var year: int = 0
	var era: int = 1
	var encounter_name: String = ""
	var encounter_result: String = ""
	var ghost_name: String = ""
	var ghost_result: String = ""
	var prestige_after: int = 0
	var wins_after: int = 0


## Un riepilogo per ogni anno giocato, dal primo all'ultimo.
var history: Array[YearRecord] = []

## Cronaca della run per il giocatore, dal più vecchio al più recente.
var chronicle: Array[String] = []
## Motivo dell'ultima azione rifiutata.
var last_error: String = ""

## Nome scelto dal giocatore per la sua nazione.
var nation_name: String = "La tua nazione"
## Identità adottata: popolo, governo, credo, cultura, perk e vie (GDD §9, §10.4).
var identity: Array[IdentityDef] = []
## Vie proposte entrando nell'era: finché non se ne sceglie una, le altre azioni aspettano.
var way_choices: Array[IdentityDef] = []


func _init(p_catalog: CatalogDef, p_run_rules: RunRules, p_battle_rules: BattleRules,
		p_resistance_rules: ResistanceRules, p_seed: int) -> void:
	catalog = p_catalog
	run_rules = p_run_rules
	battle_rules = p_battle_rules
	resistance_rules = p_resistance_rules
	run_seed = p_seed
	_rng.seed = p_seed

	prestige = run_rules.starting_prestige
	gold = run_rules.starting_gold
	research = run_rules.starting_research
	board.base_building_slots = run_rules.starting_building_slots
	board.base_troop_slots = run_rules.starting_troop_slots
	board.max_building_slots = run_rules.max_building_slots
	board.max_troop_slots = run_rules.max_troop_slots
	# La dotazione iniziale non è stata pagata: se venduta non rimborsa nulla.
	for def: BuildingDef in run_rules.starting_buildings:
		board.buildings.append(BoardPiece.of_building(def, 0))
	for def: TroopDef in run_rules.starting_troops:
		board.troops.append(BoardPiece.of_troop(def, 0))

	# Se il catalogo ha un'identità da scegliere, la run parte dalla creazione della nazione.
	if catalog.identities.is_empty():
		_log("Nasce una nuova nazione (seme %d)." % run_seed)
		_start_year(1)
	else:
		phase = Phase.CREAZIONE_NAZIONE


# --- Informazioni ------------------------------------------------------------

func phase_name() -> String:
	return PHASE_NAMES[phase]


func era_name(era_number: int = era) -> String:
	var index: int = era_number - 1
	if index >= 0 and index < catalog.eras.size():
		return catalog.eras[index].display_name
	return "Era %d" % era_number


## Ricerca necessaria per la prossima era, oppure -1 se non ci sono altre ere.
func next_era_cost() -> int:
	if era >= catalog.eras.size():
		return -1
	return catalog.eras[era].research_cost


func reroll_cost() -> int:
	return maxi(run_rules.reroll_min_cost, run_rules.reroll_base_cost + reroll_extra + modifiers.flat(ModifierDef.Effect.COSTO_RINNOVO))


## Resistenza con cui la nazione del giocatore inizia uno scontro (GDD §7.1.1).
func player_resistance() -> int:
	var base: int = ResistanceCalc.compute(resistance_rules, era, year, board.buildings.size(),
			board.troops.size(), _identity_resistance(identity))
	return maxi(1, base + modifiers.flat(ModifierDef.Effect.RESISTENZA))


## Resistenza del fantasma dell'anno, calcolata con la stessa formula.
func ghost_resistance() -> int:
	if current_ghost == null:
		return 0
	var identity_bonus: int = _identity_resistance(current_ghost.identity)
	var ghost_modifiers: Modifiers = _identity_modifiers(current_ghost.identity)
	var base: int = ResistanceCalc.compute(resistance_rules, current_ghost.era, year,
			current_ghost.buildings.size(), current_ghost.troops.size(), identity_bonus)
	return maxi(1, base + ghost_modifiers.flat(ModifierDef.Effect.RESISTENZA))


# --- Creazione della nazione (GDD §9) -------------------------------------------

## Elementi disponibili per una dimensione dell'identità (tutti, come in un GDR).
func identity_options(dimension: IdentityDef.Dimension) -> Array[IdentityDef]:
	return IdentityRules.options(catalog, dimension)


## Quanti perk si scelgono alla creazione (non più di quelli disponibili).
func starting_perk_count() -> int:
	return IdentityRules.starting_perk_count(catalog, run_rules)


## Crea la nazione: un elemento per ogni dimensione che ha opzioni, più i perk iniziali.
## Poi comincia l'anno 1.
func found_nation(p_name: String, choices: Array[IdentityDef]) -> bool:
	if phase != Phase.CREAZIONE_NAZIONE:
		return _fail("La nazione è già stata creata.")
	var problem: String = IdentityRules.validate(catalog, run_rules, choices)
	if problem != "":
		return _fail(problem)
	nation_name = p_name.strip_edges() if not p_name.strip_edges().is_empty() else "La tua nazione"
	_log("Nasce %s (seme %d)." % [nation_name, run_seed])
	for def: IdentityDef in choices:
		_adopt_identity(def)
	_start_year(1)
	return true


## Testo breve dell'identità, es. "Montanari · Monarchia · ...".
func identity_summary() -> String:
	var names: PackedStringArray = PackedStringArray()
	for def: IdentityDef in identity:
		if def.dimension != IdentityDef.Dimension.PERK:
			names.append(def.display_name)
	return " · ".join(names)


func perks() -> Array[IdentityDef]:
	var found: Array[IdentityDef] = []
	for def: IdentityDef in identity:
		if def.dimension == IdentityDef.Dimension.PERK:
			found.append(def)
	return found


## Oro e Ricerca che gli edifici depositeranno all'inizio della prossima macrofase.
func production_preview() -> Vector2i:
	var all: Array[int] = production_per_phase()
	return Vector2i(all[Res.Type.ORO], all[Res.Type.RICERCA])


## Tutte le risorse che gli edifici depositeranno all'inizio della prossima macrofase,
## in unità interne. Tiene conto di livelli e modificatori (es. Ricerca dimezzata).
func production_per_phase() -> Array[int]:
	var totals: Array[int] = Res.empty()
	for piece: BoardPiece in board.buildings:
		var produced: Array[int] = building_production(piece)
		for type: int in range(Res.COUNT):
			totals[type] += produced[type]
	for type: Res.Type in Res.NAMES:
		totals[type] = Modifiers.apply_percent(totals[type], _production_percent(type))
	return totals


## Produzione per fase di un singolo edificio, in unità interne, con il suo livello
## e i modificatori che lo riguardano (GDD §6.5).
func building_production(piece: BoardPiece) -> Array[int]:
	var produced: Array[int] = Res.empty()
	for type: Res.Type in Res.NAMES:
		var amount: int = piece.building.production(type)
		if amount > 0:
			amount += run_rules.building_production_per_level * (piece.level - 1)
		amount += modifiers.flat_production(type, piece)
		produced[type] = maxi(0, amount) * Res.scale(type)
	return produced


func _production_percent(type: Res.Type) -> int:
	var total: int = modifiers.production_percent(type)
	if type == Res.Type.ORO:
		total += modifiers.percent(ModifierDef.Effect.PRODUZIONE_ORO)
	elif type == Res.Type.RICERCA:
		total += modifiers.percent(ModifierDef.Effect.PRODUZIONE_RICERCA)
	return total


## Quantità di una risorsa nel Magazzino, come la vede il giocatore (es. "3,5").
func stock_text(type: Res.Type) -> String:
	return Res.format(type, stock[type])


# --- Potenziamenti (GDD §6.5) ------------------------------------------------------

## Costo per portare l'elemento al livello successivo, oppure null se non si può più potenziare.
func upgrade_cost_of(piece: BoardPiece) -> ResourceAmounts:
	if piece.level >= run_rules.max_level:
		return null
	var costs: Array[ResourceAmounts] = piece.building.upgrade_costs if piece.building != null else piece.troop.upgrade_costs
	var index: int = piece.level - 1
	if index >= costs.size() or costs[index] == null:
		return null
	return costs[index]


func can_pay(amounts: ResourceAmounts) -> bool:
	for type: Res.Type in Res.NAMES:
		if stock[type] < amounts.internal(type):
			return false
	return true


func upgrade_troop(index: int) -> bool:
	if index < 0 or index >= board.troops.size():
		return _fail("Truppa non valida.")
	return _upgrade(board.troops[index])


func upgrade_building(index: int) -> bool:
	if index < 0 or index >= board.buildings.size():
		return _fail("Edificio non valido.")
	return _upgrade(board.buildings[index])


## I potenziamenti si fanno in qualunque momento fuori dal combattimento e non
## consumano l'opportunità.
func _upgrade(piece: BoardPiece) -> bool:
	if not _require_not_over():
		return false
	if piece.level >= run_rules.max_level:
		return _fail("%s non si può potenziare oltre." % piece.display_name())
	var cost: ResourceAmounts = upgrade_cost_of(piece)
	if cost == null:
		return _fail("%s non si può potenziare oltre." % piece.display_name())
	if not can_pay(cost):
		return _fail("Risorse insufficienti (servono %s)." % cost.describe())
	for type: Res.Type in Res.NAMES:
		stock[type] -= cost.internal(type)
	piece.level += 1
	_log("%s sale al livello %d (%s)." % [piece.display_name(), piece.level, cost.describe()])
	return true


# --- Mercato delle risorse (GDD §5.3) -------------------------------------------

## Vende risorse in cambio di Oro, a tasso fisso. units: unità intere da vendere
## (multiplo del tasso). Si può fare in Produzione e Preparazione, senza consumare l'opportunità.
func sell_resource(type: Res.Type, units: int) -> bool:
	if not _require_shopping():
		return false
	if type == Res.Type.ORO:
		return _fail("L'Oro non si vende.")
	var rate: int = run_rules.market_units_per_gold
	if units <= 0 or units % rate != 0:
		return _fail("Si vende a gruppi di %d." % rate)
	var internal_amount: int = units * Res.scale(type)
	if stock[type] < internal_amount:
		return _fail("%s insufficiente." % Res.NAMES[type])
	stock[type] -= internal_amount
	@warning_ignore("integer_division")
	var earned: int = units / rate
	gold += earned
	_log("Mercato: venduti %d %s per %d Oro." % [units, Res.NAMES[type], earned])
	return true


# --- Cibo e mantenimento (GDD §5.4) ---------------------------------------------

## Consumo di Cibo a inizio anno: mangiano prima le truppe più lente (a parità, quelle
## più a destra). Chi non riceve tutta la sua razione resta affamato fino all'anno dopo.
func _feed_troops() -> void:
	var order: Array[int] = []
	for i: int in range(board.troops.size()):
		order.append(i)
	order.sort_custom(_slower_first)
	var hungry_names: PackedStringArray = PackedStringArray()
	var eaten: int = 0
	for i: int in order:
		var piece: BoardPiece = board.troops[i]
		var ration: int = troop_ration(piece)
		if stock[Res.Type.CIBO] >= ration:
			stock[Res.Type.CIBO] -= ration
			eaten += ration
			piece.hungry = false
		else:
			piece.hungry = true
			hungry_names.append(piece.display_name())
	_log("Le truppe consumano %s Cibo." % Res.format(Res.Type.CIBO, eaten))
	if not hungry_names.is_empty():
		_log("Senza cibo (ricarica più lenta per un anno): %s." % ", ".join(hungry_names))


## Ordine del pasto: ricarica più lunga prima; a parità, la truppa più a destra.
func _slower_first(a: int, b: int) -> bool:
	var cooldown_a: int = _fed_cooldown(board.troops[a])
	var cooldown_b: int = _fed_cooldown(board.troops[b])
	if cooldown_a != cooldown_b:
		return cooldown_a > cooldown_b
	return a > b


## Ricarica di una truppa senza contare la fame.
func _fed_cooldown(piece: BoardPiece) -> int:
	var change: int = modifiers.percent(ModifierDef.Effect.RICARICA_TRUPPA, piece)
	return maxi(1, Modifiers.apply_percent(piece.troop.cooldown_ms, change))


func is_shopping_phase() -> bool:
	return phase == Phase.PRODUZIONE or phase == Phase.PREPARAZIONE


func is_over() -> bool:
	return phase == Phase.FINE_RUN


## true se nel round in corso bisogna ancora scegliere il consigliere.
func is_choosing_councillor() -> bool:
	return is_shopping_phase() and councillor == null


## Livello dei consiglieri: quello dell'era corrente (GDD §4.2.1).
func councillor_tier() -> int:
	return clampi(era, 1, maxi(run_rules.tier_names.size(), 1))


## Nome del consigliere con il suo livello, es. "Tesoriere · Ministro".
func councillor_title(def: CouncillorDef) -> String:
	var tier: int = councillor_tier()
	if tier - 1 < run_rules.tier_names.size():
		return "%s · %s" % [def.display_name, run_rules.tier_names[tier - 1]]
	return def.display_name


func round_type_name() -> String:
	return ROUND_TYPE_NAMES[round_type]


## true se l'offerta, per essere presa, richiede di sostituire un elemento.
func offer_needs_replacement(offer: Offer) -> bool:
	match offer.kind:
		OpportunityDef.Kind.COSTRUISCI_EDIFICIO:
			return not board.can_add_building(offer.building)
		OpportunityDef.Kind.RECLUTA_TRUPPA:
			return not board.has_free_troop_slot()
	return false


## true se il Magazzino basta a pagare l'offerta (senza contare rimborsi di sostituzione).
## Le proposte di potenziamento e di incanto si pagano solo con il loro costo.
func can_afford(offer: Offer) -> bool:
	if offer.other_cost != null and not can_pay(offer.other_cost):
		return false
	return gold >= offer.price and research >= offer.research_price


## Le scelte interne di un'offerta (es. quale bonus dell'Assemblea, quale truppa da addestrare,
## quale malus accorciare). Vuoto se non c'è nulla da scegliere.
func offer_choices(offer: Offer) -> Array[String]:
	var labels: Array[String] = []
	match offer.kind:
		OpportunityDef.Kind.MODIFICATORE_A_SCELTA:
			var choices: Array[Array] = _modifier_choices(offer)
			if choices.size() > 1:
				for choice: Array in choices:
					var def: ModifierDef = choice[0]
					var piece: BoardPiece = choice[1]
					labels.append(def.display_name if piece == null else "%s su %s" % [def.display_name, piece.display_name()])
		OpportunityDef.Kind.ACCORCIA_MALUS:
			var malus: Array[ActiveModifier] = modifiers.year_malus()
			if malus.size() > 1:
				for modifier: ActiveModifier in malus:
					labels.append(modifier.describe())
		OpportunityDef.Kind.POTENZIA_EDIFICIO, OpportunityDef.Kind.POTENZIA_TRUPPA, OpportunityDef.Kind.INCANTA:
			var pieces: Array[BoardPiece] = _offer_targets(offer.kind)
			if pieces.size() > 1:
				for piece: BoardPiece in pieces:
					labels.append("%s (livello %d)" % [piece.display_name(), piece.level])
	return labels


## Elementi su cui può agire una proposta di potenziamento o di incanto.
func _offer_targets(kind: OpportunityDef.Kind) -> Array[BoardPiece]:
	var pieces: Array[BoardPiece] = []
	match kind:
		OpportunityDef.Kind.POTENZIA_EDIFICIO:
			for piece: BoardPiece in board.buildings:
				if piece.level < run_rules.max_level:
					pieces.append(piece)
		OpportunityDef.Kind.POTENZIA_TRUPPA:
			for piece: BoardPiece in board.troops:
				if piece.level < run_rules.max_level:
					pieces.append(piece)
		OpportunityDef.Kind.INCANTA:
			for piece: BoardPiece in board.troops:
				if piece.enchantment == null:
					pieces.append(piece)
	return pieces


func reward_needs_replacement(reward: RewardDef) -> bool:
	match reward.kind:
		RewardDef.Kind.EDIFICIO:
			return not board.can_add_building(reward.building)
		RewardDef.Kind.TRUPPA:
			return not board.has_free_troop_slot()
	return false


func reward_choices() -> Array[RewardDef]:
	if phase != Phase.RICOMPENSA_INCONTRO or won_encounter == null:
		return []
	return won_encounter.rewards


## Edificio come entrerà in battaglia: livello e modificatori (GDD §6.5, §8).
func effective_building(piece: BoardPiece) -> BuildingDef:
	return ElementStats.building(piece.building, piece, modifiers, piece.level, run_rules)


## Truppa come entrerà in battaglia: livello, modificatori e fame (GDD §5.4, §6.5, §8).
func effective_troop(piece: BoardPiece) -> TroopDef:
	var hunger: int = run_rules.hunger_cooldown_percent if piece.hungry else 0
	return ElementStats.troop(piece.troop, piece, modifiers, piece.level, run_rules, hunger)


## Cibo consumato da una truppa a inizio anno, in decimi (GDD §5.4).
func troop_ration(piece: BoardPiece) -> int:
	return Modifiers.apply_percent(piece.troop.food_tenths, modifiers.percent(ModifierDef.Effect.CIBO_TRUPPA, piece))


## Le due nazioni dell'ultima battaglia: [giocatore, avversario].
func last_battle_setups() -> Array[BattleSideSetup]:
	return _last_setups


## Crea una copia nuova dell'ultima battaglia, da far scorrere passo per passo
## nell'interfaccia. Il risultato è identico a quello già registrato.
func make_battle_replay() -> BattleSim:
	if _last_setups.size() != 2:
		return null
	return BattleSim.new(battle_rules, _last_setups[0], _last_setups[1], last_battle_seed)


# --- Il Consiglio (GDD §4.2) ------------------------------------------------

## Sceglie uno dei consiglieri del round; la scelta è definitiva (GDD §4.2).
func choose_councillor(index: int) -> bool:
	if not _require_shopping():
		return false
	if councillor != null:
		return _fail("Hai già scelto un consigliere in questo round.")
	if index < 0 or index >= councillor_choices.size():
		return _fail("Consigliere non valido.")
	councillor = councillor_choices[index]
	_log("Round %d: ascolti %s." % [round_number, councillor_title(councillor)])
	_draw_offers()
	return true


## Prende una proposta del consigliere pagando il suo prezzo e chiude il round.
## choice dipende dal tipo di proposta:
##   - edificio o truppa con la plancia piena: l'elemento da sostituire (venduto con rimborso dimezzato);
##   - modificatore a scelta o malus da accorciare: la voce scelta fra offer_choices();
##   - potenziamento o incanto: l'elemento scelto fra offer_choices().
func buy_offer(offer_index: int, choice: int = -1) -> bool:
	if not _require_shopping():
		return false
	if councillor == null:
		return _fail("Prima scegli un consigliere.")
	if offer_index < 0 or offer_index >= offers.size():
		return _fail("Offerta non valida.")
	var offer: Offer = offers[offer_index]
	var source: String = offer.title()

	match offer.kind:
		OpportunityDef.Kind.COSTRUISCI_EDIFICIO:
			if not _place_building(offer.building, offer.price, offer.price, choice):
				return false
		OpportunityDef.Kind.RECLUTA_TRUPPA:
			if not _place_troop(offer.troop, offer.price, offer.price, choice):
				return false
		OpportunityDef.Kind.SPAZIO_EDIFICIO:
			if board.building_capacity() >= board.max_building_slots:
				return _fail("La plancia ha già il massimo di spazi edificio.")
			if not _pay(offer):
				return false
			board.base_building_slots += 1
			_log("%s: nuovo spazio edificio (%s)." % [source, offer.cost_text()])
		OpportunityDef.Kind.SPAZIO_TRUPPA:
			if board.troop_capacity() >= board.max_troop_slots:
				return _fail("La plancia ha già il massimo di spazi truppa.")
			if not _pay(offer):
				return false
			board.base_troop_slots += 1
			_log("%s: nuovo spazio truppa (%s)." % [source, offer.cost_text()])
		OpportunityDef.Kind.SCAMBIO_RISORSE:
			if not _pay(offer):
				return false
			var gains: PackedStringArray = PackedStringArray()
			gold += offer.opportunity.gain_gold
			if offer.opportunity.gain_gold > 0:
				gains.append("%d Oro" % offer.opportunity.gain_gold)
			research += offer.opportunity.gain_research
			if offer.opportunity.gain_research > 0:
				gains.append("%d Ricerca" % offer.opportunity.gain_research)
			if offer.opportunity.gain_resources != null and not offer.opportunity.gain_resources.is_empty():
				for type: Res.Type in Res.NAMES:
					stock[type] += offer.opportunity.gain_resources.internal(type)
				gains.append(offer.opportunity.gain_resources.describe())
			_log("%s: paghi %s, ricevi %s." % [source, offer.cost_text(), ", ".join(gains)])
		OpportunityDef.Kind.MODIFICATORE_A_SCELTA:
			var choices: Array[Array] = _modifier_choices(offer)
			if choices.is_empty():
				return _fail("Non c'è nulla su cui applicarlo.")
			if choices.size() == 1:
				choice = 0
			if choice < 0 or choice >= choices.size():
				return _fail("Scegli quale effetto prendere.")
			if not _pay(offer):
				return false
			var def: ModifierDef = choices[choice][0]
			var piece: BoardPiece = choices[choice][1]
			_log(modifiers.apply(def, ActiveModifier.OriginKind.OPPORTUNITA, source, year, board, _rng, piece))
		OpportunityDef.Kind.ACCORCIA_MALUS:
			var malus: Array[ActiveModifier] = modifiers.year_malus()
			if malus.is_empty():
				return _fail("Non ci sono malus da accorciare.")
			if malus.size() == 1:
				choice = 0
			if choice < 0 or choice >= malus.size():
				return _fail("Scegli quale malus accorciare.")
			if not _pay(offer):
				return false
			_log("%s: %s" % [source, modifiers.shorten(malus[choice], offer.opportunity.shorten_years, year)])
		OpportunityDef.Kind.POTENZIA_EDIFICIO, OpportunityDef.Kind.POTENZIA_TRUPPA:
			var targets: Array[BoardPiece] = _offer_targets(offer.kind)
			if targets.is_empty():
				return _fail("Non c'è nulla da potenziare.")
			if targets.size() == 1:
				choice = 0
			if choice < 0 or choice >= targets.size():
				return _fail("Scegli che cosa potenziare.")
			if not _pay(offer):
				return false
			targets[choice].level += 1
			_log("%s: %s sale al livello %d." % [source, targets[choice].display_name(), targets[choice].level])
		OpportunityDef.Kind.INCANTA:
			var troops_to_enchant: Array[BoardPiece] = _offer_targets(offer.kind)
			if troops_to_enchant.is_empty():
				return _fail("Non ci sono truppe da incantare.")
			if troops_to_enchant.size() == 1:
				choice = 0
			if choice < 0 or choice >= troops_to_enchant.size():
				return _fail("Scegli quale truppa incantare.")
			if not _pay(offer):
				return false
			troops_to_enchant[choice].enchantment = offer.opportunity
			_log("%s: %s è incantata." % [source, troops_to_enchant[choice].display_name()])
		OpportunityDef.Kind.SPIONAGGIO:
			if not _pay(offer):
				return false
			spy_actions.append(offer.opportunity)
			_log("%s: agirà nello scontro con il fantasma." % source)
		OpportunityDef.Kind.PERK:
			if offer.perk == null or identity.has(offer.perk):
				return _fail("Hai già questo perk.")
			if not _pay(offer):
				return false
			_adopt_identity(offer.perk)
			_log("%s: nuovo perk %s." % [source, offer.perk.display_name])
	_next_round()
	return true


## Lascia passare il round, prima o dopo aver scelto il consigliere, senza ricevere nulla (GDD §4.2).
func pass_opportunity() -> bool:
	if not _require_shopping():
		return false
	_log("Round %d lasciato passare." % round_number)
	_next_round()
	return true


## Rinnova le proposte del consigliere scelto pagando Oro; il costo cresce a ogni rinnovo (GDD §4.2).
func reroll_offers() -> bool:
	if not _require_shopping():
		return false
	if councillor == null:
		return _fail("Prima scegli un consigliere: si rinnovano le sue proposte.")
	var cost: int = reroll_cost()
	if gold < cost:
		return _fail("Oro insufficiente per rinnovare (servono %d)." % cost)
	gold -= cost
	reroll_extra += run_rules.reroll_cost_increase
	_log("Offerte rinnovate per %d Oro." % cost)
	_draw_offers()
	return true


## Paga la Ricerca ed entra nella prossima era (GDD §10). Non consuma l'opportunità.
func advance_era() -> bool:
	if not _require_shopping():
		return false
	var cost: int = next_era_cost()
	if cost < 0:
		return _fail("Non ci sono altre ere.")
	if research < cost:
		return _fail("Ricerca insufficiente (servono %d)." % cost)
	research -= cost
	var next: EraDef = catalog.eras[era]
	era += 1
	board.base_building_slots += next.bonus_building_slots
	board.base_troop_slots += next.bonus_troop_slots
	_log("La nazione entra nell'era %s (%d Ricerca)." % [next.display_name, cost])
	# Dalla seconda era si sceglie una via fra 3 (GDD §10.4).
	way_choices = _draw_ways(next)
	if not way_choices.is_empty():
		_log("Scegli la via della nazione per l'era %s." % next.display_name)
	# Le offerte delle ere precedenti non restano disponibili (GDD §10.3):
	# le proposte in corso (o i consiglieri, se non è ancora stato scelto) vengono ripescate gratis.
	_redraw_round()
	return true


# --- Azioni sulla plancia (in qualunque momento fuori dal combattimento) -----

func sell_building(index: int) -> bool:
	if not _require_not_over():
		return false
	if index < 0 or index >= board.buildings.size():
		return _fail("Edificio non valido.")
	if board.buildings[index].building.is_capital:
		return _fail("La Capitale non si può vendere.")
	if not board.can_sell_building(index):
		return _fail("Prima libera gli spazi che questo edificio concede.")
	var piece: BoardPiece = board.buildings[index]
	board.buildings.remove_at(index)
	_refund(piece)
	_prune_modifiers()
	return true


func sell_troop(index: int) -> bool:
	if not _require_not_over():
		return false
	if index < 0 or index >= board.troops.size():
		return _fail("Truppa non valida.")
	var piece: BoardPiece = board.troops[index]
	board.troops.remove_at(index)
	_refund(piece)
	_prune_modifiers()
	return true


func move_troop(from_index: int, to_index: int) -> bool:
	if not _require_not_over():
		return false
	if not board.move_troop(from_index, to_index):
		return _fail("Spostamento non valido.")
	return true


# --- Incontri del mondo -----------------------------------------------------

## Sceglie uno dei 3 incontri e combatte subito lo scontro (GDD §3.3).
func choose_encounter(index: int) -> bool:
	if phase != Phase.SCELTA_INCONTRO:
		return _fail("Ora non è il momento dell'incontro del mondo.")
	if index < 0 or index >= encounter_choices.size():
		return _fail("Incontro non valido.")
	var encounter: EncounterDef = encounter_choices[index]
	var enemy: BattleSideSetup = BattleSideSetup.new(encounter.buildings, encounter.troops, encounter.resistance)
	var outcome: BattleSim.Outcome = _fight(BattleKind.INCONTRO, encounter.display_name, enemy)
	if not history.is_empty():
		history[-1].encounter_name = "%s (%s)" % [encounter.display_name, encounter.difficulty_label]
		history[-1].encounter_result = _outcome_word(outcome)

	if _player_won_or_drew(outcome):
		# Il pareggio vale come vittoria (GDD §3.4).
		won_encounter = encounter
		_log("Incontro superato: %s." % encounter.display_name)
		_gain_loot(encounter.loot_gold, encounter.loot_research)
		phase = Phase.RICOMPENSA_INCONTRO
		return true

	var lost_gold: int = gold - half_down(gold)
	gold = half_down(gold)
	_log("Sconfitta contro %s: perso metà dell'Oro (%d)." % [encounter.display_name, lost_gold])
	if last_chance:
		_end_run(RunEnd.SCONFITTA)
		return true
	_enter_phase(Phase.PREPARAZIONE)
	return true


## Prende una ricompensa dell'incontro vinto (GDD §3.3).
func take_reward(index: int, replace_index: int = -1) -> bool:
	if phase != Phase.RICOMPENSA_INCONTRO:
		return _fail("Non ci sono ricompense da scegliere.")
	var rewards: Array[RewardDef] = reward_choices()
	if index < 0 or index >= rewards.size():
		return _fail("Ricompensa non valida.")
	var reward: RewardDef = rewards[index]
	match reward.kind:
		RewardDef.Kind.ORO:
			gold += reward.amount
		RewardDef.Kind.RICERCA:
			research += reward.amount
		RewardDef.Kind.RISORSA:
			stock[reward.resource] += reward.amount * Res.scale(reward.resource)
		RewardDef.Kind.EDIFICIO:
			# Gratis, ma vale come il prezzo di catalogo quando si vende (GDD §6.4).
			if not _place_building(reward.building, 0, reward.building.cost_gold, replace_index):
				return false
		RewardDef.Kind.TRUPPA:
			if not _place_troop(reward.troop, 0, reward.troop.cost_gold, replace_index):
				return false
		RewardDef.Kind.PERK:
			if identity.has(reward.perk):
				return _fail("Hai già questo perk.")
			_adopt_identity(reward.perk)
	_log("Ricompensa presa: %s." % reward.describe())
	won_encounter = null
	_enter_phase(Phase.PREPARAZIONE)
	return true


## Rinuncia alla ricompensa (GDD §3.3: il giocatore sceglie se prenderla).
func skip_reward() -> bool:
	if phase != Phase.RICOMPENSA_INCONTRO:
		return _fail("Non ci sono ricompense da scegliere.")
	_log("Nessuna ricompensa presa.")
	won_encounter = null
	_enter_phase(Phase.PREPARAZIONE)
	return true


# --- Scontro con il fantasma ------------------------------------------------

func fight_ghost() -> bool:
	if phase != Phase.SCONTRO_FANTASMA:
		return _fail("Ora non è il momento dello scontro con il fantasma.")
	var ghost_name: String = current_ghost.display_name if current_ghost != null else "Fantasma"
	var enemy: BattleSideSetup = BattleSideSetup.new([], [], 0)
	if current_ghost != null:
		enemy = _ghost_setup()
	var outcome: BattleSim.Outcome = _fight(BattleKind.FANTASMA, ghost_name, enemy)
	spy_actions = []
	for message: String in modifiers.on_ghost_fight_done():
		_log(message)
	if not history.is_empty():
		history[-1].ghost_name = ghost_name
		history[-1].ghost_result = _outcome_word(outcome)

	if _player_won_or_drew(outcome):
		wins += 1
		if outcome == BattleSim.Outcome.PAREGGIO:
			# Il pareggio conta come vittoria ma applica i malus del fantasma (GDD §3.4).
			_log("Pareggio contro %s: conta come vittoria (%d)." % [ghost_name, wins])
			_apply_ghost_malus(ghost_name)
		else:
			_log("Vittoria contro %s (%d)." % [ghost_name, wins])
		_gain_loot(run_rules.ghost_loot_gold, run_rules.ghost_loot_research)
		if wins >= run_rules.wins_needed:
			_end_run(RunEnd.VITTORIA)
			return true
	else:
		if last_chance:
			_log("Sconfitta contro %s durante l'ultima possibilità." % ghost_name)
			_end_run(RunEnd.SCONFITTA)
			return true
		prestige -= year
		_log("Sconfitta contro %s: perso %d Prestigio." % [ghost_name, year])
		_apply_ghost_malus(ghost_name)
		if prestige <= 0:
			prestige = 0
			last_chance = true
			_log("Il Prestigio è esaurito: ultima possibilità.")

	if run_rules.prototype_years > 0 and year >= run_rules.prototype_years:
		_end_run(RunEnd.FINE_PROVA)
		return true
	_start_year(year + 1)
	return true


# --- Parti interne ----------------------------------------------------------

## Bottino fisso di un nemico sconfitto: Oro e Ricerca nel Magazzino (convenzione provvisoria).
func _gain_loot(loot_gold: int, loot_research: int) -> void:
	if loot_gold <= 0 and loot_research <= 0:
		return
	gold += maxi(loot_gold, 0)
	research += maxi(loot_research, 0)
	var parts: PackedStringArray = PackedStringArray()
	if loot_gold > 0:
		parts.append("%d Oro" % loot_gold)
	if loot_research > 0:
		parts.append("%d Ricerca" % loot_research)
	_log("Bottino: %s." % " e ".join(parts))

func _start_year(new_year: int) -> void:
	_update_last_record()
	year = new_year
	current_ghost = _ghost_for_year(year)
	encounter_choices = _encounters_for_year(year)
	_log("— Anno %d —" % year)
	var record: YearRecord = YearRecord.new()
	record.year = year
	record.era = era
	record.prestige_after = prestige
	record.wins_after = wins
	history.append(record)
	for message: String in modifiers.on_new_year(year):
		_log(message)
	# Il consumo di Cibo avviene a inizio anno, dall'anno 2 (GDD §5.4).
	if year >= 2:
		_feed_troops()
	_enter_phase(Phase.PRODUZIONE)


func _enter_phase(new_phase: Phase) -> void:
	phase = new_phase
	offers = []
	councillor = null
	councillor_choices = []
	round_number = 0
	if is_shopping_phase():
		_collect_production()
		# L'ordine dei tipi di round della metà si pesca con il seme della run (GDD §4.2).
		_half_round_types = []
		var types: Array[int] = []
		for type: int in run_rules.round_types:
			types.append(type)
		while not types.is_empty():
			var pick: int = _rng.randi_range(0, types.size() - 1)
			_half_round_types.append(types[pick])
			types.remove_at(pick)
		_next_round()


## Ogni edificio presente deposita le sue risorse, una volta per macrofase (GDD §5.2).
func _collect_production() -> void:
	var collected: Array[int] = production_per_phase()
	var parts: PackedStringArray = PackedStringArray()
	for type: Res.Type in Res.NAMES:
		stock[type] += collected[type]
		if collected[type] != 0:
			parts.append("%s %s" % [Res.format(type, collected[type]), Res.NAMES[type]])
	_log("%s: gli edifici producono %s." % [phase_name(), ", ".join(parts) if not parts.is_empty() else "nulla"])


func _next_round() -> void:
	round_number += 1
	offers = []
	councillor = null
	councillor_choices = []
	if round_number > run_rules.rounds_per_half:
		_end_shopping_phase()
		return
	# A ogni nuovo round l'aumento accumulato del rinnovo si dimezza (GDD §4.2).
	reroll_extra = half_down(reroll_extra)
	var index: int = round_number - 1
	round_type = _half_round_types[index] as RoundType if index < _half_round_types.size() else RoundType.MISTO
	_draw_councillors()


func _end_shopping_phase() -> void:
	offers = []
	councillor = null
	councillor_choices = []
	if phase == Phase.PRODUZIONE:
		phase = Phase.SCELTA_INCONTRO
		if encounter_choices.is_empty():
			push_warning("RunState: nessun incontro nei dati per l'anno %d." % year)
			_enter_phase(Phase.PREPARAZIONE)
	elif phase == Phase.PREPARAZIONE:
		phase = Phase.SCONTRO_FANTASMA


## Ripesca il round in corso: i consiglieri se non è stato scelto, altrimenti le sue proposte.
func _redraw_round() -> void:
	if not is_shopping_phase():
		return
	if councillor == null:
		_draw_councillors()
	else:
		_draw_offers()


## Pesca i consiglieri del round: diversi fra loro, solo quelli che hanno qualcosa da
## proporre per il tipo del round, più probabili se l'identità li favorisce (GDD §4.2).
func _draw_councillors() -> void:
	councillor_choices = []
	var pool: Array[CouncillorDef] = []
	var weights: Array[int] = []
	for def: CouncillorDef in catalog.councillors:
		if not _candidate_offers(def).is_empty():
			pool.append(def)
			weights.append(_councillor_weight(def))
	var count: int = mini(run_rules.councillors_per_round, pool.size())
	for i: int in range(count):
		var pick: int = _weighted_pick(weights)
		councillor_choices.append(pool[pick])
		pool.remove_at(pick)
		weights.remove_at(pick)


## Peso di un consigliere: 1, più 1 per ogni elemento dell'identità che lo favorisce
## direttamente o che favorisce una delle sue azioni (§16.3).
func _councillor_weight(def: CouncillorDef) -> int:
	var weight: int = 1
	for element: IdentityDef in identity:
		var favored: bool = element.favored_councillors.has(def)
		for action: OpportunityDef in element.favored_opportunities:
			if action.councillor == def.id:
				favored = true
		if favored:
			weight += 1
	return weight


## Posizione pescata a caso, con probabilità proporzionale ai pesi.
func _weighted_pick(weights: Array[int]) -> int:
	var total: int = 0
	for weight: int in weights:
		total += weight
	var roll: int = _rng.randi_range(0, maxi(total, 1) - 1)
	var pick: int = 0
	while pick < weights.size() - 1 and roll >= weights[pick]:
		roll -= weights[pick]
		pick += 1
	return pick


## Pesca le proposte del consigliere scelto (GDD §4.2): 3 diverse fra quelle possibili;
## il Clown ne propone 4, ciascuna di un mana diverso (§4.2.2).
func _draw_offers() -> void:
	offers = []
	if councillor == null:
		return
	var candidates: Array[Offer] = _candidate_offers(councillor)
	var extra: int = modifiers.flat(ModifierDef.Effect.ALTERNATIVE_OFFERTE)
	if councillor.special == CouncillorDef.Special.CLOWN:
		var wanted_clown: int = maxi(1, run_rules.clown_proposals + extra)
		var colors: Array[StringName] = CLOWN_COLORS.duplicate()
		while offers.size() < wanted_clown and not colors.is_empty():
			var color: StringName = colors.pop_at(_rng.randi_range(0, colors.size() - 1))
			var same_color: Array[Offer] = []
			for candidate: Offer in candidates:
				if _offer_mana(candidate) == color:
					same_color.append(candidate)
			if not same_color.is_empty():
				offers.append(same_color[_rng.randi_range(0, same_color.size() - 1)])
		return
	var weights: Array[int] = []
	for candidate: Offer in candidates:
		weights.append(_offer_weight(candidate))
	var wanted: int = maxi(1, run_rules.proposals_per_councillor + extra)
	for i: int in range(mini(wanted, candidates.size())):
		var pick: int = _weighted_pick(weights)
		offers.append(candidates[pick])
		candidates.remove_at(pick)
		weights.remove_at(pick)


## Peso di una proposta: le azioni favorite dall'identità sono più probabili (§16.3).
func _offer_weight(offer: Offer) -> int:
	var weight: int = 1
	if offer.opportunity != null:
		for element: IdentityDef in identity:
			if element.favored_opportunities.has(offer.opportunity):
				weight += 1
	return weight


## Colore del mana di un elemento proposto, per il Clown. Senza mana: "neutro".
static func _offer_mana(offer: Offer) -> StringName:
	if offer.building != null:
		return offer.building.mana_type if offer.building.mana_amount > 0 else BattleSim.MANA_NEUTRO
	if offer.troop != null:
		return offer.troop.mana_type if offer.troop.mana_cost > 0 else BattleSim.MANA_NEUTRO
	return &""


## Tutte le proposte che un consigliere può fare adesso, secondo il tipo del round.
func _candidate_offers(def: CouncillorDef) -> Array[Offer]:
	var result: Array[Offer] = []
	match def.special:
		CouncillorDef.Special.CLOWN:
			for building_def: BuildingDef in _buildings_of_era():
				result.append(Offer.of_building(building_def, def))
			for troop_def: TroopDef in _troops_of_era():
				result.append(Offer.of_troop(troop_def, def))
			return result
		CouncillorDef.Special.ANZIANO:
			for action: OpportunityDef in _councillor_actions(def):
				if action.kind == OpportunityDef.Kind.PERK:
					for perk: IdentityDef in _perks_to_offer():
						var perk_offer: Offer = Offer.of_action(action, def)
						perk_offer.perk = perk
						result.append(perk_offer)
				else:
					result.append(Offer.of_action(action, def))
			for building_def: BuildingDef in _buildings_of_era():
				if building_def.mana_amount == 0:
					result.append(Offer.of_building(building_def, def))
			return result
	if round_type == RoundType.AZIONI or round_type == RoundType.MISTO:
		for action: OpportunityDef in _councillor_actions(def):
			result.append(Offer.of_action(action, def))
	if round_type == RoundType.EDIFICI or round_type == RoundType.MISTO:
		for building_def: BuildingDef in _buildings_of_era():
			if def.is_affine_building(building_def):
				result.append(Offer.of_building(building_def, def))
	if round_type == RoundType.TRUPPE or round_type == RoundType.MISTO:
		for troop_def: TroopDef in _troops_of_era():
			if def.is_affine_troop(troop_def):
				result.append(Offer.of_troop(troop_def, def))
	return result


## Perk che l'Anziano può proporre: quelli del catalogo non ancora posseduti.
func _perks_to_offer() -> Array[IdentityDef]:
	var perks_found: Array[IdentityDef] = []
	for def: IdentityDef in catalog.identities:
		if def.dimension == IdentityDef.Dimension.PERK and not identity.has(def):
			perks_found.append(def)
	return perks_found


## Azioni del consigliere che hanno senso adesso, del suo livello, esclusive dell'identità comprese
## (es. niente Ambasciata senza malus, niente spazi oltre il massimo).
func _councillor_actions(def: CouncillorDef) -> Array[OpportunityDef]:
	var candidates: Array[OpportunityDef] = catalog.opportunities.duplicate()
	for element: IdentityDef in identity:
		for action: OpportunityDef in element.exclusive_opportunities:
			if not candidates.has(action):
				candidates.append(action)
	var result: Array[OpportunityDef] = []
	for action: OpportunityDef in candidates:
		if action.councillor != def.id or action.min_tier > councillor_tier():
			continue
		if _action_makes_sense(action):
			result.append(action)
	return result


func _action_makes_sense(action: OpportunityDef) -> bool:
	match action.kind:
		OpportunityDef.Kind.COSTRUISCI_EDIFICIO, OpportunityDef.Kind.RECLUTA_TRUPPA:
			return false  # Gli elementi arrivano direttamente dal consigliere.
		OpportunityDef.Kind.SPAZIO_EDIFICIO:
			return board.building_capacity() < board.max_building_slots
		OpportunityDef.Kind.SPAZIO_TRUPPA:
			return board.troop_capacity() < board.max_troop_slots
		OpportunityDef.Kind.MODIFICATORE_A_SCELTA:
			return not _modifier_choices_for(action).is_empty()
		OpportunityDef.Kind.ACCORCIA_MALUS:
			return not modifiers.year_malus().is_empty()
		OpportunityDef.Kind.POTENZIA_EDIFICIO, OpportunityDef.Kind.POTENZIA_TRUPPA, OpportunityDef.Kind.INCANTA:
			return not _offer_targets(action.kind).is_empty()
		OpportunityDef.Kind.SPIONAGGIO:
			return current_ghost != null
		OpportunityDef.Kind.PERK:
			return not _perks_to_offer().is_empty()
	return true


## Edifici offerti: solo quelli dell'era corrente (GDD §10.3).
func _buildings_of_era() -> Array[BuildingDef]:
	var candidates: Array[BuildingDef] = catalog.buildings.duplicate()
	for identity_def: IdentityDef in identity:
		candidates.append_array(identity_def.exclusive_buildings)
	var found: Array[BuildingDef] = []
	for def: BuildingDef in candidates:
		if def.era == era and not found.has(def):
			found.append(def)
	return found


func _troops_of_era() -> Array[TroopDef]:
	var candidates: Array[TroopDef] = catalog.troops.duplicate()
	for identity_def: IdentityDef in identity:
		candidates.append_array(identity_def.exclusive_troops)
	var found: Array[TroopDef] = []
	for def: TroopDef in candidates:
		if def.era == era and not found.has(def):
			found.append(def)
	return found


## Voci fra cui scegliere per un'offerta di modificatori: [modificatore, elemento o null].
func _modifier_choices(offer: Offer) -> Array[Array]:
	if offer.opportunity == null:
		return []
	return _modifier_choices_for(offer.opportunity)


func _modifier_choices_for(opportunity: OpportunityDef) -> Array[Array]:
	var choices: Array[Array] = []
	for def: ModifierDef in opportunity.modifiers:
		match def.target:
			ModifierDef.Target.TRUPPA_SCELTA:
				for piece: BoardPiece in board.troops:
					choices.append([def, piece])
			ModifierDef.Target.EDIFICIO_SCELTO:
				for piece: BoardPiece in board.buildings:
					choices.append([def, piece])
			_:
				choices.append([def, null])
	return choices


## Paga Oro e Ricerca di un'offerta, se bastano.
func _pay(offer: Offer) -> bool:
	if not can_afford(offer):
		return _fail("Risorse insufficienti (servono %s)." % offer.cost_text())
	gold -= offer.price
	research -= offer.research_price
	if offer.other_cost != null:
		for type: Res.Type in Res.NAMES:
			stock[type] -= offer.other_cost.internal(type)
	return true


## Mette un edificio sulla plancia, in uno spazio libero o al posto di un altro.
## price: Oro da pagare adesso. value: valore su cui si calcolerà il rimborso della vendita.
## La sostituzione equivale a vendere e costruire (GDD §6.4): il rimborso conta per il pagamento.
func _place_building(def: BuildingDef, price: int, value: int, replace_index: int) -> bool:
	if board.can_add_building(def) and replace_index < 0:
		if gold < price:
			return _fail("Oro insufficiente.")
		gold -= price
		board.buildings.append(BoardPiece.of_building(def, value))
		_log("Costruito: %s." % def.display_name)
		return true
	if replace_index < 0:
		return _fail("Plancia piena: scegli un edificio da sostituire.")
	if replace_index < board.buildings.size() and board.buildings[replace_index].building.is_capital:
		return _fail("La Capitale non si può sostituire.")
	if not board.can_replace_building(replace_index, def):
		return _fail("Sostituzione non possibile: lascerebbe elementi senza spazio.")
	var old_piece: BoardPiece = board.buildings[replace_index]
	var refund: int = half_down(old_piece.paid)
	if gold + refund < price:
		return _fail("Oro insufficiente.")
	gold += refund - price
	board.buildings[replace_index] = BoardPiece.of_building(def, value)
	_prune_modifiers()
	_log("%s sostituisce %s (rimborso %d Oro)." % [def.display_name, old_piece.display_name(), refund])
	return true


func _place_troop(def: TroopDef, price: int, value: int, replace_index: int) -> bool:
	if board.has_free_troop_slot() and replace_index < 0:
		if gold < price:
			return _fail("Oro insufficiente.")
		gold -= price
		board.troops.append(BoardPiece.of_troop(def, value))
		_log("Reclutato: %s." % def.display_name)
		return true
	if replace_index < 0:
		return _fail("Plancia piena: scegli una truppa da sostituire.")
	if replace_index >= board.troops.size():
		return _fail("Truppa da sostituire non valida.")
	var old_piece: BoardPiece = board.troops[replace_index]
	var refund: int = half_down(old_piece.paid)
	if gold + refund < price:
		return _fail("Oro insufficiente.")
	gold += refund - price
	board.troops[replace_index] = BoardPiece.of_troop(def, value)
	_prune_modifiers()
	_log("%s sostituisce %s (rimborso %d Oro)." % [def.display_name, old_piece.display_name(), refund])
	return true


## Rimborso della vendita: metà del prezzo pagato, per difetto (GDD §6.4).
func _refund(piece: BoardPiece) -> void:
	var refund: int = half_down(piece.paid)
	gold += refund
	_log("Venduto: %s (rimborso %d Oro)." % [piece.display_name(), refund])


func _fight(kind: BattleKind, opponent_name: String, enemy: BattleSideSetup) -> BattleSim.Outcome:
	var player: BattleSideSetup = BattleSideSetup.new(_battle_buildings(), _battle_troops(), player_resistance())
	_apply_start_values(player, modifiers)
	_last_setups = [player, enemy]
	last_battle_seed = run_seed * 7919 + year * 104729 + int(kind)
	last_battle = BattleSim.new(battle_rules, player, enemy, last_battle_seed)
	last_battle_kind = kind
	last_opponent_name = opponent_name
	var outcome: BattleSim.Outcome = last_battle.run_to_end()
	if outcome == BattleSim.Outcome.INTERROTTA:
		push_warning("RunState: scontro interrotto per il limite di sicurezza, trattato come pareggio.")
	return outcome


## Malus del fantasma dopo una sconfitta o un pareggio (GDD §11.1), con il suo nome come origine.
func _apply_ghost_malus(ghost_name: String) -> void:
	if current_ghost == null:
		return
	for def: ModifierDef in current_ghost.malus:
		_log(modifiers.apply(def, ActiveModifier.OriginKind.FANTASMA, ghost_name, year, board, _rng))


## Toglie i modificatori di elementi che non sono più sulla plancia.
func _prune_modifiers() -> void:
	for message: String in modifiers.prune(board):
		_log(message)


func _battle_buildings() -> Array[BuildingDef]:
	var defs: Array[BuildingDef] = []
	for piece: BoardPiece in board.buildings:
		defs.append(effective_building(piece))
	return defs


func _battle_troops() -> Array[TroopDef]:
	var defs: Array[TroopDef] = []
	for piece: BoardPiece in board.troops:
		defs.append(effective_troop(piece))
	return defs


## Aggiorna Prestigio, vittorie ed era dell'ultimo anno registrato.
func _update_last_record() -> void:
	if history.is_empty():
		return
	history[-1].prestige_after = prestige
	history[-1].wins_after = wins
	history[-1].era = era


static func _outcome_word(outcome: BattleSim.Outcome) -> String:
	match outcome:
		BattleSim.Outcome.VITTORIA_A:
			return "Vittoria"
		BattleSim.Outcome.VITTORIA_B:
			return "Sconfitta"
		BattleSim.Outcome.PAREGGIO:
			return "Pareggio"
	return "Interrotto"


func _player_won_or_drew(outcome: BattleSim.Outcome) -> bool:
	return outcome == BattleSim.Outcome.VITTORIA_A \
		or outcome == BattleSim.Outcome.PAREGGIO \
		or outcome == BattleSim.Outcome.INTERROTTA


## Fantasma dell'anno: quello scritto nei dati, altrimenti uno generato (GDD §11.3).
func _ghost_for_year(target_year: int) -> GhostDef:
	var best: GhostDef = null
	for ghost: GhostDef in catalog.ghosts:
		if ghost.year == target_year:
			return ghost
		if ghost.year < target_year and (best == null or ghost.year > best.year):
			best = ghost
	if catalog.generator != null:
		return OpponentGenerator.generate_ghost(catalog, catalog.generator, run_rules, target_year, run_seed)
	if best != null:
		push_warning("RunState: nessun fantasma per l'anno %d, uso quello dell'anno %d." % [target_year, best.year])
	return best


## Incontri dell'anno: quelli scritti nei dati, completati fino a 3 con incontri generati (GDD §3.3).
func _encounters_for_year(target_year: int) -> Array[EncounterDef]:
	var found: Array[EncounterDef] = []
	for encounter: EncounterDef in catalog.encounters:
		if encounter.year == target_year and found.size() < 3:
			found.append(encounter)
	if found.size() < 3 and catalog.generator != null:
		found.append_array(OpponentGenerator.generate_encounters(catalog, catalog.generator, run_rules,
				target_year, run_seed, 3 - found.size(), found.size()))
	return found


func _end_run(result: RunEnd) -> void:
	run_end = result
	_update_last_record()
	phase = Phase.FINE_RUN
	offers = []
	councillor = null
	councillor_choices = []
	spy_actions = []
	match result:
		RunEnd.VITTORIA:
			_log("La nazione ha raggiunto %d vittorie: run vinta!" % wins)
		RunEnd.SCONFITTA:
			_log("La run è finita con una sconfitta.")
		RunEnd.FINE_PROVA:
			_log("Fine della run di prova dopo %d anni." % year)


func _require_shopping() -> bool:
	if not is_shopping_phase():
		return _fail("Questa azione è possibile solo in Produzione o Preparazione.")
	if not way_choices.is_empty():
		return _fail("Prima scegli la via della nazione.")
	return true


# --- Vie delle ere (GDD §10.4) -----------------------------------------------------

## Sceglie una delle vie proposte: diventa parte dell'identità, con il suo bonus immediato.
func choose_way(index: int) -> bool:
	if index < 0 or index >= way_choices.size():
		return _fail("Via non valida.")
	var way: IdentityDef = way_choices[index]
	way_choices = []
	_adopt_identity(way)
	# Le proposte in corso tengono conto della via appena scelta.
	_redraw_round()
	return true


## Tre vie pescate dal pool dell'era, pesate da identità e vie già scelte (§16.3).
func _draw_ways(era_def: EraDef) -> Array[IdentityDef]:
	var pool: Array[IdentityDef] = []
	var weights: Array[int] = []
	for way: IdentityDef in era_def.ways:
		if identity.has(way):
			continue
		if not way.requires_any.is_empty():
			var allowed: bool = false
			for needed: Resource in way.requires_any:
				if identity.has(needed):
					allowed = true
			if not allowed:
				continue
		var weight: int = 1
		for element: IdentityDef in identity:
			if way.favored_by.has(element):
				weight += 1
		pool.append(way)
		weights.append(weight)
	var picked: Array[IdentityDef] = []
	for i: int in range(mini(3, pool.size())):
		var total: int = 0
		for weight: int in weights:
			total += weight
		var roll: int = _rng.randi_range(0, total - 1)
		var pick: int = 0
		while roll >= weights[pick]:
			roll -= weights[pick]
			pick += 1
		picked.append(pool[pick])
		pool.remove_at(pick)
		weights.remove_at(pick)
	return picked


func _require_not_over() -> bool:
	if is_over():
		return _fail("La run è finita.")
	if phase == Phase.CREAZIONE_NAZIONE:
		return _fail("Prima crea la nazione.")
	return true


## Adotta un elemento dell'identità: dotazione, tratto permanente e, implicitamente,
## Resistenza, opportunità ed elementi esclusivi (letti da identity quando servono).
func _adopt_identity(def: IdentityDef) -> void:
	identity.append(def)
	_log("%s: %s." % [IdentityDef.DIMENSION_NAMES[def.dimension], def.display_name])
	gold += def.extra_gold
	research += def.extra_research
	if def.extra_resources != null:
		for type: Res.Type in Res.NAMES:
			stock[type] += def.extra_resources.internal(type)
	board.base_building_slots += def.extra_building_slots
	board.base_troop_slots += def.extra_troop_slots
	for building: BuildingDef in def.extra_buildings:
		if board.can_add_building(building):
			board.buildings.append(BoardPiece.of_building(building, 0))
		else:
			_log("Nessuno spazio per %s." % building.display_name)
	for troop: TroopDef in def.extra_troops:
		if board.has_free_troop_slot():
			board.troops.append(BoardPiece.of_troop(troop, 0))
		else:
			_log("Nessuno spazio per %s." % troop.display_name)
	for modifier: ModifierDef in def.permanent_modifiers:
		_log(modifiers.apply(modifier, ActiveModifier.OriginKind.IDENTITA, def.display_name, year, board, _rng))


static func _identity_resistance(elements: Array[IdentityDef]) -> int:
	var total: int = 0
	for def: IdentityDef in elements:
		total += def.resistance_bonus
	return total


## Modificatori permanenti di un'identità, per una nazione che non è il giocatore (es. un fantasma).
func _identity_modifiers(elements: Array[IdentityDef]) -> Modifiers:
	var result: Modifiers = Modifiers.new()
	var empty_board: NationBoard = NationBoard.new()
	for def: IdentityDef in elements:
		for modifier: ModifierDef in def.permanent_modifiers:
			if modifier.target == ModifierDef.Target.NAZIONE:
				result.apply(modifier, ActiveModifier.OriginKind.IDENTITA, def.display_name, year, empty_board, _rng)
	return result


## Il fantasma come entra in battaglia: con la Resistenza e i tratti della sua identità.
func _ghost_setup() -> BattleSideSetup:
	var ghost_modifiers: Modifiers = _identity_modifiers(current_ghost.identity)
	var buildings: Array[BuildingDef] = []
	for def: BuildingDef in current_ghost.buildings:
		buildings.append(ElementStats.building(def, BoardPiece.of_building(def, 0), ghost_modifiers, 1, run_rules))
	var troops: Array[TroopDef] = []
	for def: TroopDef in current_ghost.troops:
		troops.append(ElementStats.troop(def, BoardPiece.of_troop(def, 0), ghost_modifiers, 1, run_rules))
	var setup: BattleSideSetup = BattleSideSetup.new(buildings, troops, ghost_resistance())
	_apply_start_values(setup, ghost_modifiers)
	# Lo spionaggio del giocatore agisce sulla copia affrontata (GDD §11.1, §12).
	for spy: OpportunityDef in spy_actions:
		setup.start_timer_effects.append([spy.spy_sabotage, spy.spy_target, spy.spy_criterion, spy.spy_duration_ms])
	return setup


## Valori di partenza dello scontro cambiati dai modificatori (GDD §8.2, v0.16).
static func _apply_start_values(setup: BattleSideSetup, mods: Modifiers) -> void:
	setup.start_shield = maxi(0, mods.flat(ModifierDef.Effect.SCUDO_INIZIALE))
	setup.start_corruption = maxi(0, mods.flat(ModifierDef.Effect.CORRUZIONE_INIZIALE))
	setup.start_building_sabotage_ms = maxi(0, mods.flat(ModifierDef.Effect.SABOTAGGIO_INIZIALE))


## Metà di un numero intero, arrotondata per difetto (per numeri non negativi).
@warning_ignore("integer_division")
static func half_down(value: int) -> int:
	return value / 2


func _fail(message: String) -> bool:
	last_error = message
	return false


func _log(message: String) -> void:
	chronicle.append(message)
