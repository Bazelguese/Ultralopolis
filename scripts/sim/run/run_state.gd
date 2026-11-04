class_name RunState
extends RefCounted
## Stato e regole di una run (GDD §3, §4, §5, §6, §10).
##
## Logica pura: l'interfaccia legge questo stato e chiama i metodi pubblici,
## che controllano sempre se l'azione è permessa. Se un'azione non è permessa
## il metodo restituisce false e spiega il motivo in last_error.
##
## Sequenza dell'anno (GDD §4.1):
##   PRODUZIONE (3 opportunità) -> SCELTA_INCONTRO -> [RICOMPENSA_INCONTRO]
##   -> PREPARAZIONE (3 opportunità) -> SCONTRO_FANTASMA -> anno successivo.

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

## Magazzino (GDD §5.3).
var gold: int = 0
var research: int = 0

var board: NationBoard = NationBoard.new()
## Malus e bonus attivi (GDD §8).
var modifiers: Modifiers = Modifiers.new()

## Numero dell'opportunità in corso nella macrofase (1, 2, 3).
var opportunity_number: int = 0
## Alternative dell'opportunità in corso.
var offers: Array[Offer] = []
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

## Cronaca della run per il giocatore, dal più vecchio al più recente.
var chronicle: Array[String] = []
## Motivo dell'ultima azione rifiutata.
var last_error: String = ""

## Nome scelto dal giocatore per la sua nazione.
var nation_name: String = "La tua nazione"
## Identità adottata: popolo, governo, credo, cultura e perk (GDD §9).
var identity: Array[IdentityDef] = []


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
	return maxi(0, run_rules.reroll_base_cost + reroll_extra + modifiers.flat(ModifierDef.Effect.COSTO_RINNOVO))


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
	var found: Array[IdentityDef] = []
	for def: IdentityDef in catalog.identities:
		if def.dimension == dimension:
			found.append(def)
	return found


## Quanti perk si scelgono alla creazione (non più di quelli disponibili).
func starting_perk_count() -> int:
	return mini(run_rules.starting_perks, identity_options(IdentityDef.Dimension.PERK).size())


## Crea la nazione: un elemento per ogni dimensione che ha opzioni, più i perk iniziali.
## Poi comincia l'anno 1.
func found_nation(p_name: String, choices: Array[IdentityDef]) -> bool:
	if phase != Phase.CREAZIONE_NAZIONE:
		return _fail("La nazione è già stata creata.")
	for dimension: IdentityDef.Dimension in IdentityDef.DIMENSION_NAMES:
		var wanted: int = 1
		if dimension == IdentityDef.Dimension.PERK:
			wanted = starting_perk_count()
		elif identity_options(dimension).is_empty():
			wanted = 0
		var chosen: int = 0
		for def: IdentityDef in choices:
			if def.dimension == dimension:
				chosen += 1
		if chosen != wanted:
			return _fail("Scegli %d × %s." % [wanted, IdentityDef.DIMENSION_NAMES[dimension]])
	for def: IdentityDef in choices:
		if not catalog.identities.has(def):
			return _fail("Elemento dell'identità non valido.")
		if choices.count(def) > 1:
			return _fail("Ogni elemento si sceglie una volta sola.")
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
## Tiene conto dei modificatori attivi (es. Ricerca dimezzata).
func production_preview() -> Vector2i:
	var preview: Vector2i = Vector2i.ZERO
	for piece: BoardPiece in board.buildings:
		preview.x += piece.building.gold_per_phase
		preview.y += piece.building.research_per_phase
	preview.x = Modifiers.apply_percent(preview.x, modifiers.percent(ModifierDef.Effect.PRODUZIONE_ORO))
	preview.y = Modifiers.apply_percent(preview.y, modifiers.percent(ModifierDef.Effect.PRODUZIONE_RICERCA))
	return preview


func is_shopping_phase() -> bool:
	return phase == Phase.PRODUZIONE or phase == Phase.PREPARAZIONE


func is_over() -> bool:
	return phase == Phase.FINE_RUN


## true se l'offerta, per essere presa, richiede di sostituire un elemento.
func offer_needs_replacement(offer: Offer) -> bool:
	match offer.kind:
		OpportunityDef.Kind.COSTRUISCI_EDIFICIO:
			return not board.can_add_building(offer.building)
		OpportunityDef.Kind.RECLUTA_TRUPPA:
			return not board.has_free_troop_slot()
	return false


## true se il Magazzino basta a pagare l'offerta (senza contare rimborsi di sostituzione).
func can_afford(offer: Offer) -> bool:
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
	return labels


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


## Edificio come entrerà in battaglia, con i modificatori applicati (es. Inefficienza).
## Se serve restituisce una copia: le schede del catalogo non vengono mai toccate.
func effective_building(piece: BoardPiece) -> BuildingDef:
	var change: int = modifiers.percent(ModifierDef.Effect.INTERVALLO_MANA, piece)
	if change == 0:
		return piece.building
	var copy: BuildingDef = piece.building.duplicate() as BuildingDef
	copy.mana_interval_ms = maxi(1, Modifiers.apply_percent(copy.mana_interval_ms, change))
	return copy


## Truppa come entrerà in battaglia, con i modificatori applicati (es. ricarica più lunga).
func effective_troop(piece: BoardPiece) -> TroopDef:
	var change: int = modifiers.percent(ModifierDef.Effect.RICARICA_TRUPPA, piece)
	if change == 0:
		return piece.troop
	var copy: TroopDef = piece.troop.duplicate() as TroopDef
	copy.cooldown_ms = maxi(1, Modifiers.apply_percent(copy.cooldown_ms, change))
	return copy


## Le due nazioni dell'ultima battaglia: [giocatore, avversario].
func last_battle_setups() -> Array[BattleSideSetup]:
	return _last_setups


## Crea una copia nuova dell'ultima battaglia, da far scorrere passo per passo
## nell'interfaccia. Il risultato è identico a quello già registrato.
func make_battle_replay() -> BattleSim:
	if _last_setups.size() != 2:
		return null
	return BattleSim.new(battle_rules, _last_setups[0], _last_setups[1])


# --- Azioni delle opportunità -----------------------------------------------

## Prende un'offerta pagando il suo prezzo e chiude l'opportunità.
## choice dipende dal tipo di offerta:
##   - edificio o truppa con la plancia piena: l'elemento da sostituire (venduto con rimborso dimezzato);
##   - modificatore a scelta o malus da accorciare: la voce scelta fra offer_choices().
func buy_offer(offer_index: int, choice: int = -1) -> bool:
	if not _require_shopping():
		return false
	if offer_index < 0 or offer_index >= offers.size():
		return _fail("Offerta non valida.")
	var offer: Offer = offers[offer_index]
	var source: String = offer.opportunity.display_name

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
			gold += offer.opportunity.gain_gold
			research += offer.opportunity.gain_research
			_log("%s: paghi %s, ricevi %d Oro e %d Ricerca." % [source, offer.cost_text(), offer.opportunity.gain_gold, offer.opportunity.gain_research])
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
	_next_opportunity()
	return true


## Rinuncia all'opportunità in corso, senza ricevere nulla (GDD §4.2).
func pass_opportunity() -> bool:
	if not _require_shopping():
		return false
	_log("Opportunità %d lasciata passare." % opportunity_number)
	_next_opportunity()
	return true


## Rinnova le alternative pagando Oro; il costo cresce a ogni rinnovo (GDD §4.2).
func reroll_offers() -> bool:
	if not _require_shopping():
		return false
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
	# Le offerte delle ere precedenti non restano disponibili (GDD §10.3):
	# le alternative in corso vengono ripescate gratis dalla nuova era.
	_draw_offers()
	return true


# --- Azioni sulla plancia (in qualunque momento fuori dal combattimento) -----

func sell_building(index: int) -> bool:
	if not _require_not_over():
		return false
	if index < 0 or index >= board.buildings.size():
		return _fail("Edificio non valido.")
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

	if _player_won_or_drew(outcome):
		# Il pareggio vale come vittoria (GDD §3.4).
		won_encounter = encounter
		_log("Incontro superato: %s." % encounter.display_name)
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
	for message: String in modifiers.on_ghost_fight_done():
		_log(message)

	if _player_won_or_drew(outcome):
		wins += 1
		if outcome == BattleSim.Outcome.PAREGGIO:
			# Il pareggio conta come vittoria ma applica i malus del fantasma (GDD §3.4).
			_log("Pareggio contro %s: conta come vittoria (%d)." % [ghost_name, wins])
			_apply_ghost_malus(ghost_name)
		else:
			_log("Vittoria contro %s (%d)." % [ghost_name, wins])
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

func _start_year(new_year: int) -> void:
	year = new_year
	current_ghost = _ghost_for_year(year)
	encounter_choices = _encounters_for_year(year)
	_log("— Anno %d —" % year)
	for message: String in modifiers.on_new_year(year):
		_log(message)
	_enter_phase(Phase.PRODUZIONE)


func _enter_phase(new_phase: Phase) -> void:
	phase = new_phase
	offers = []
	opportunity_number = 0
	if is_shopping_phase():
		_collect_production()
		_next_opportunity()


## Ogni edificio presente deposita le sue risorse, una volta per macrofase (GDD §5.2).
func _collect_production() -> void:
	var collected: Vector2i = production_preview()
	gold += collected.x
	research += collected.y
	_log("%s: gli edifici producono %d Oro e %d Ricerca." % [phase_name(), collected.x, collected.y])


func _next_opportunity() -> void:
	opportunity_number += 1
	if opportunity_number > run_rules.opportunities_per_phase:
		_end_shopping_phase()
		return
	# A ogni nuova opportunità l'aumento accumulato del rinnovo si dimezza (GDD §4.2).
	reroll_extra = half_down(reroll_extra)
	_draw_offers()


func _end_shopping_phase() -> void:
	offers = []
	if phase == Phase.PRODUZIONE:
		phase = Phase.SCELTA_INCONTRO
		if encounter_choices.is_empty():
			push_warning("RunState: nessun incontro nei dati per l'anno %d." % year)
			_enter_phase(Phase.PREPARAZIONE)
	elif phase == Phase.PREPARAZIONE:
		phase = Phase.SCONTRO_FANTASMA


## Pesca a caso le alternative (GDD §4.2): tipi di opportunità diversi fra loro, tutti con la
## stessa probabilità; per costruttori e reclutatori si pesca poi l'elemento dell'era corrente.
func _draw_offers() -> void:
	var pool: Array[OpportunityDef] = _available_opportunities()
	var weights: Array[int] = []
	for opportunity: OpportunityDef in pool:
		weights.append(_opportunity_weight(opportunity))
	offers = []
	var wanted: int = maxi(1, run_rules.alternatives_per_opportunity + modifiers.flat(ModifierDef.Effect.ALTERNATIVE_OFFERTE))
	var count: int = mini(wanted, pool.size())
	for i: int in range(count):
		var total: int = 0
		for weight: int in weights:
			total += weight
		var roll: int = _rng.randi_range(0, total - 1)
		var pick: int = 0
		while roll >= weights[pick]:
			roll -= weights[pick]
			pick += 1
		offers.append(_make_offer(pool[pick]))
		pool.remove_at(pick)
		weights.remove_at(pick)


## Peso di un tipo di opportunità: 1, più 1 per ogni elemento dell'identità che lo favorisce.
func _opportunity_weight(opportunity: OpportunityDef) -> int:
	var weight: int = 1
	for def: IdentityDef in identity:
		if def.favored_opportunities.has(opportunity):
			weight += 1
	return weight


## Tipi di opportunità della fase corrente che hanno senso adesso
## (es. niente Ambasciata se non ci sono malus, niente spazi oltre il massimo).
func _available_opportunities() -> Array[OpportunityDef]:
	var wanted_phase: OpportunityDef.Phase = OpportunityDef.Phase.PRODUZIONE if phase == Phase.PRODUZIONE else OpportunityDef.Phase.PREPARAZIONE
	var pool: Array[OpportunityDef] = []
	var candidates: Array[OpportunityDef] = catalog.opportunities.duplicate()
	for def: IdentityDef in identity:
		for opportunity: OpportunityDef in def.exclusive_opportunities:
			if not candidates.has(opportunity):
				candidates.append(opportunity)
	for opportunity: OpportunityDef in candidates:
		if opportunity.phase != wanted_phase:
			continue
		match opportunity.kind:
			OpportunityDef.Kind.COSTRUISCI_EDIFICIO:
				if _buildings_of_era().is_empty():
					continue
			OpportunityDef.Kind.RECLUTA_TRUPPA:
				if _troops_of_era().is_empty():
					continue
			OpportunityDef.Kind.SPAZIO_EDIFICIO:
				if board.building_capacity() >= board.max_building_slots:
					continue
			OpportunityDef.Kind.SPAZIO_TRUPPA:
				if board.troop_capacity() >= board.max_troop_slots:
					continue
			OpportunityDef.Kind.MODIFICATORE_A_SCELTA:
				if _modifier_choices_for(opportunity).is_empty():
					continue
			OpportunityDef.Kind.ACCORCIA_MALUS:
				if modifiers.year_malus().is_empty():
					continue
		pool.append(opportunity)
	return pool


func _make_offer(opportunity: OpportunityDef) -> Offer:
	var offer: Offer = Offer.new()
	offer.opportunity = opportunity
	offer.price = opportunity.cost_gold
	offer.research_price = opportunity.cost_research
	match opportunity.kind:
		OpportunityDef.Kind.COSTRUISCI_EDIFICIO:
			var buildings: Array[BuildingDef] = _buildings_of_era()
			offer.building = buildings[_rng.randi_range(0, buildings.size() - 1)]
			offer.price = offer.building.cost_gold
		OpportunityDef.Kind.RECLUTA_TRUPPA:
			var troops: Array[TroopDef] = _troops_of_era()
			offer.troop = troops[_rng.randi_range(0, troops.size() - 1)]
			offer.price = offer.troop.cost_gold
	return offer


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
	_last_setups = [player, enemy]
	last_battle = BattleSim.new(battle_rules, player, enemy)
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


func _player_won_or_drew(outcome: BattleSim.Outcome) -> bool:
	return outcome == BattleSim.Outcome.VITTORIA_A \
		or outcome == BattleSim.Outcome.PAREGGIO \
		or outcome == BattleSim.Outcome.INTERROTTA


func _ghost_for_year(target_year: int) -> GhostDef:
	var best: GhostDef = null
	for ghost: GhostDef in catalog.ghosts:
		if ghost.year == target_year:
			return ghost
		if ghost.year < target_year and (best == null or ghost.year > best.year):
			best = ghost
	if best != null:
		push_warning("RunState: nessun fantasma per l'anno %d, uso quello dell'anno %d." % [target_year, best.year])
	return best


func _encounters_for_year(target_year: int) -> Array[EncounterDef]:
	var found: Array[EncounterDef] = []
	for encounter: EncounterDef in catalog.encounters:
		if encounter.year == target_year and found.size() < 3:
			found.append(encounter)
	return found


func _end_run(result: RunEnd) -> void:
	run_end = result
	phase = Phase.FINE_RUN
	offers = []
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
	return true


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
	var interval_change: int = ghost_modifiers.percent(ModifierDef.Effect.INTERVALLO_MANA)
	for def: BuildingDef in current_ghost.buildings:
		var copy: BuildingDef = def
		if interval_change != 0:
			copy = def.duplicate() as BuildingDef
			copy.mana_interval_ms = maxi(1, Modifiers.apply_percent(def.mana_interval_ms, interval_change))
		buildings.append(copy)
	var troops: Array[TroopDef] = []
	var cooldown_change: int = ghost_modifiers.percent(ModifierDef.Effect.RICARICA_TRUPPA)
	for def: TroopDef in current_ghost.troops:
		var copy: TroopDef = def
		if cooldown_change != 0:
			copy = def.duplicate() as TroopDef
			copy.cooldown_ms = maxi(1, Modifiers.apply_percent(def.cooldown_ms, cooldown_change))
		troops.append(copy)
	return BattleSideSetup.new(buildings, troops, ghost_resistance())


## Metà di un numero intero, arrotondata per difetto (per numeri non negativi).
@warning_ignore("integer_division")
static func half_down(value: int) -> int:
	return value / 2


func _fail(message: String) -> bool:
	last_error = message
	return false


func _log(message: String) -> void:
	chronicle.append(message)
