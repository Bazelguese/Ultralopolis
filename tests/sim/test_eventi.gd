extends GutTest
## Eventi, Visitatori e Fortune nei round (GDD §4.2.5, v0.23). Numeri solo di prova.

const Aiuti = preload("res://tests/sim/aiuti_consiglio.gd")

var catalog: CatalogDef
var rules: RunRules
var resistance_rules: ResistanceRules
var farm: BuildingDef
var monk: TroopDef
var soldier_troop: TroopDef
var advisor: AdvisorDef
var people: IdentityDef


func _option(label: String, gain: Dictionary = {}, cost: Dictionary = {}) -> EventOptionDef:
	var option: EventOptionDef = EventOptionDef.new()
	option.label = label
	if not gain.is_empty():
		option.gain = _amounts(gain)
	if not cost.is_empty():
		option.cost = _amounts(cost)
	return option


func _amounts(values: Dictionary) -> ResourceAmounts:
	var amounts: ResourceAmounts = ResourceAmounts.new()
	for key: String in values:
		amounts.set(key, values[key])
	return amounts


func _event(id: StringName, options: Array[EventOptionDef], family: EventDef.Family = EventDef.Family.EVENTO) -> EventDef:
	var event: EventDef = EventDef.new()
	event.id = id
	event.display_name = String(id)
	event.family = family
	event.sphere = "Fede"
	event.options = options
	return event


func before_each() -> void:
	farm = BuildingDef.new()
	farm.id = &"fattoria"
	farm.display_name = "Fattoria"
	farm.types = [&"Produzione"]
	farm.mana_interval_ms = 1000
	monk = TroopDef.new()
	monk.id = &"monaci"
	monk.display_name = "Monaci"
	monk.types = [&"Spirituale"]
	monk.cooldown_ms = 1000
	soldier_troop = TroopDef.new()
	soldier_troop.id = &"fanti"
	soldier_troop.display_name = "Fanti"
	soldier_troop.types = [&"Fante"]
	soldier_troop.cooldown_ms = 2000
	people = IdentityDef.new()
	people.id = &"popolo"
	people.display_name = "Popolo"
	people.dimension = IdentityDef.Dimension.POPOLO
	catalog = CatalogDef.new()
	catalog.buildings = [farm]
	catalog.troops = [monk, soldier_troop]
	var era2: EraDef = EraDef.new()
	era2.techs_required = 0
	catalog.eras = [EraDef.new(), era2]
	rules = RunRules.new()
	rules.starting_gold = 20
	rules.prototype_years = 0
	rules.starting_buildings = [farm]
	rules.starting_troops = [soldier_troop]
	advisor = Aiuti.consiglio_semplice(catalog, rules, [], 3)
	var second: AdvisorDef = Aiuti.consigliere(&"secondo", [Aiuti.TIPO_PROVA, &"Produzione", &"Fante", &"Spirituale"])
	var third: AdvisorDef = Aiuti.consigliere(&"terzo", [Aiuti.TIPO_PROVA, &"Produzione", &"Fante", &"Spirituale"])
	catalog.advisors = [advisor, second, third]
	rules.advisors_per_round = 3
	rules.special_card_chance_percent = 100
	resistance_rules = ResistanceRules.new()
	resistance_rules.per_era = [10, 10]
	resistance_rules.per_year = 0
	resistance_rules.per_building = 0
	resistance_rules.per_troop = 0


func _run(run_seed: int = 3) -> RunState:
	return RunState.new(catalog, rules, BattleRules.new(), resistance_rules, run_seed)


# --- Nel round ----------------------------------------------------------------------

func test_al_massimo_una_carta_speciale_al_posto_di_un_consigliere() -> void:
	catalog.events = [_event(&"a", [_option("Prendi", {"oro": 1})]), _event(&"b", [_option("Prendi", {"oro": 1})])]
	var run: RunState = _run()
	assert_not_null(run.event_choice, "Con probabilità 100 c'è sempre una carta speciale.")
	assert_eq(run.advisor_choices.size(), 2, "Prende il posto di un consigliere: 2 + 1 carte.")


func test_senza_probabilita_compaiono_solo_consiglieri() -> void:
	rules.special_card_chance_percent = 0
	catalog.events = [_event(&"a", [_option("Prendi", {"oro": 1})])]
	var run: RunState = _run()
	for i: int in range(3):
		assert_null(run.event_choice)
		assert_eq(run.advisor_choices.size(), 3)
		run.pass_round()


func test_un_evento_compare_una_sola_volta_per_run() -> void:
	catalog.events = [_event(&"unico", [_option("Prendi", {"oro": 1})])]
	var run: RunState = _run()
	assert_not_null(run.event_choice)
	for i: int in range(5):
		run.pass_round()
		assert_null(run.event_choice, "L'evento non torna.")


func test_una_fortuna_non_torna_nello_stesso_anno_ma_l_anno_dopo_si() -> void:
	catalog.events = [_event(&"dono", [_option("Prendi", {"oro": 1})], EventDef.Family.FORTUNA)]
	var run: RunState = _run()
	assert_not_null(run.event_choice)
	run.pass_round()
	assert_null(run.event_choice, "Non due volte nello stesso anno.")
	while run.year == 1:
		match run.phase:
			RunState.Phase.SCONTRO_FANTASMA:
				run.fight_ghost()
			_:
				run.pass_round()
	assert_not_null(run.event_choice, "L'anno dopo può tornare.")


func test_scegliere_l_evento_e_la_scelta_del_round() -> void:
	catalog.events = [_event(&"a", [_option("Prendi", {"oro": 2})])]
	var run: RunState = _run()
	var gold_before: int = run.gold
	assert_true(run.choose_event())
	assert_false(run.choose_advisor(0), "Scelto l'evento, niente consigliere.")
	assert_ne(run.upgrade_block_reason(run.board.troops[0]), "", "Niente Potenzia con un evento.")
	assert_true(run.take_event_option(0))
	assert_eq(run.gold, gold_before + 2)
	assert_eq(run.round_number, 2, "L'opzione chiude il round.")


# --- Radici ------------------------------------------------------------------------

func test_le_radici_decidono_se_la_carta_compare() -> void:
	var exclusive: EventDef = _event(&"esclusivo", [_option("Prendi", {"oro": 1})])
	exclusive.requires_any = [people]
	var later: EventDef = _event(&"era2", [_option("Prendi", {"oro": 1})])
	later.min_era = 2
	var monks_only: EventDef = _event(&"monaci", [_option("Prendi", {"oro": 1})])
	monks_only.requires_types = [&"Spirituale"]
	catalog.events = [exclusive, later, monks_only]
	var run: RunState = _run()
	assert_null(run.event_choice, "Nessuna radice soddisfatta: nessun evento.")
	run.board.troops.append(BoardPiece.of_troop(monk, 0))
	run.pass_round()
	assert_eq(run.event_choice, monks_only, "Con una carta Spirituale compare l'evento dei monaci.")


func test_una_carta_favorita_esce_piu_spesso() -> void:
	var favored: EventDef = _event(&"favorito", [_option("Prendi", {"oro": 1})], EventDef.Family.FORTUNA)
	favored.favored_by = [people]
	favored.repeatable = true
	var other: EventDef = _event(&"altro", [_option("Prendi", {"oro": 1})], EventDef.Family.FORTUNA)
	catalog.events = [favored, other]
	catalog.identities = [people]
	rules.starting_perks = 0
	var counts: Dictionary[StringName, int] = {}
	for run_seed: int in range(1, 301):
		var run: RunState = _run(run_seed)
		run.found_nation("X", [people])
		if run.event_choice != null:
			counts[run.event_choice.id] = counts.get(run.event_choice.id, 0) + 1
	assert_gt(counts.get(&"favorito", 0), counts.get(&"altro", 0) * 3 / 2, "Peso 2 contro 1.")


# --- Opzioni ---------------------------------------------------------------------------

func test_le_opzioni_bloccate_si_vedono_e_dicono_perche() -> void:
	var free_option: EventOptionDef = _option("Sempre", {"fede": 1})
	var by_type: EventOptionDef = _option("Con i monaci", {"fede": 5})
	by_type.requires_types = [&"Spirituale"]
	var by_identity: EventOptionDef = _option("Solo per il popolo", {"oro": 5})
	by_identity.requires_identity = [people]
	var costly: EventOptionDef = _option("Cara", {"fede": 9}, {"oro": 100})
	catalog.events = [_event(&"scelte", [free_option, by_type, by_identity, costly])]
	var run: RunState = _run()
	assert_true(run.choose_event())
	assert_eq(run.event_options().size(), 4, "Le opzioni bloccate restano visibili.")
	assert_eq(run.option_block_reason(free_option), "")
	assert_string_contains(run.option_block_reason(by_type), "Spirituale")
	assert_string_contains(run.option_block_reason(by_identity), "Popolo")
	assert_string_contains(run.option_block_reason(costly), "Risorse insufficienti")
	assert_false(run.take_event_option(1), "Un'opzione bloccata non si prende.")
	run.board.troops.append(BoardPiece.of_troop(monk, 0))
	assert_eq(run.option_block_reason(by_type), "", "Con una carta Spirituale si sblocca.")
	assert_true(run.take_event_option(1))
	assert_eq(run.stock[Res.Type.FEDE], 5)


func test_opzione_che_potenzia_una_carta_a_scelta() -> void:
	var training: EventOptionDef = _option("Addestra")
	training.upgrade = true
	training.upgrade_types = [&"Fante"]
	training.upgrade_kind = EventOptionDef.PieceKind.TRUPPA
	catalog.events = [_event(&"torneo", [training])]
	rules.starting_troops = [soldier_troop, soldier_troop]
	var run: RunState = _run()
	run.choose_event()
	assert_eq(run.option_choices(training).size(), 2, "Si sceglie quale truppa Fante.")
	assert_false(run.take_event_option(0), "Senza scelta non si può.")
	assert_true(run.take_event_option(0, 1))
	assert_eq(run.board.troops[1].level, 2)
	assert_eq(run.board.troops[0].level, 1)


func test_opzione_che_regala_una_truppa_e_lo_spionaggio() -> void:
	var gift: EventOptionDef = _option("Arruola")
	gift.give_troop = monk
	var spy_action: OpportunityDef = OpportunityDef.new()
	spy_action.spy_effect = OpportunityDef.SpyEffect.SABOTAGGIO
	spy_action.spy_ms = 5000
	spy_action.spy_criterion = OpportunityDef.SpyCriterion.PIU_VELOCE
	var spy: EventOptionDef = _option("Infiltra")
	spy.spy = spy_action
	var ghost: GhostDef = GhostDef.new()
	ghost.year = 1
	ghost.troops = [soldier_troop, monk]
	catalog.ghosts = [ghost]
	catalog.events = [_event(&"dono", [gift]), _event(&"spie", [spy])]
	var run: RunState = _run()
	var first: StringName = run.event_choice.id
	run.choose_event()
	assert_true(run.take_event_option(0))
	run.choose_event()
	assert_true(run.take_event_option(0))
	assert_eq(run.board.troops.size(), 2, "La truppa regalata entra nella plancia.")
	assert_eq(run.board.troops[1].paid, monk.cost_gold, "Vale il prezzo di catalogo.")
	assert_eq(run.spy_effects.size(), 1)
	assert_eq(run.spy_effects[0][1], BattleSim.TROOP_INDEX_OFFSET + 1, "La truppa più veloce del fantasma.")
	assert_ne(first, &"", "Due eventi in due round.")


func test_la_fortuna_cresce_con_l_era() -> void:
	var gift: EventDef = _event(&"dono", [_option("Prendi", {"fede": 3})], EventDef.Family.FORTUNA)
	gift.scale_with_era = true
	gift.min_era = 2
	catalog.events = [gift]
	var run: RunState = _run()
	assert_null(run.event_choice)
	run.research = 1
	assert_true(run.advance_era())
	assert_eq(run.event_choice, gift, "Nella nuova era i consiglieri e la carta speciale si ripescano.")
	run.choose_event()
	assert_true(run.take_event_option(0))
	assert_eq(run.stock[Res.Type.FEDE], 6, "3 Fede × era 2.")


# --- Visitatori ----------------------------------------------------------------------

func test_il_visitatore_propone_carte_straniere_e_dell_era_successiva() -> void:
	var foreign: BuildingDef = BuildingDef.new()
	foreign.id = &"porto"
	foreign.display_name = "Porto"
	foreign.types = [&"Produzione"]
	foreign.cost_gold = 4
	foreign.mana_interval_ms = 1000
	# Esclusivo di una via che la nazione non ha: per lei è una carta "straniera".
	var other_way: IdentityDef = IdentityDef.new()
	other_way.id = &"altra_via"
	other_way.dimension = IdentityDef.Dimension.VIA
	other_way.exclusive_buildings = [foreign]
	catalog.eras[0].ways = [other_way]
	var future: BuildingDef = BuildingDef.new()
	future.id = &"futuro"
	future.display_name = "Futuro"
	future.era = 2
	future.types = [&"Produzione"]
	future.cost_gold = 7
	future.mana_interval_ms = 1000
	catalog.buildings = [farm, future]
	var merchant: AdvisorDef = Aiuti.consigliere(&"mercante", [&"Produzione"])
	merchant.special = AdvisorDef.Special.VISITATORE
	merchant.offers_troops = false
	merchant.foreign_exclusives = AdvisorDef.Foreign.PER_TIPO
	merchant.era_shift_max = 1
	merchant.price_extra = 1
	merchant.next_era_extra = 3
	merchant.extra_cost = _amounts({"documenti": 1})
	catalog.visitors = [merchant]
	rules.proposals_per_advisor = 5
	var run: RunState = _run()
	var index: int = run.advisor_choices.find(merchant)
	assert_ne(index, -1, "Il visitatore prende il posto di un consigliere.")
	assert_true(run.choose_advisor(index))
	var prices: Dictionary[StringName, int] = {}
	for offer: Offer in run.offers:
		prices[offer.building.id] = offer.price
	assert_eq(prices.get(&"porto", -1), 5, "Esclusivo di un'altra nazione, 1 Oro in più.")
	assert_eq(prices.get(&"futuro", -1), 10, "Carta dell'era successiva, 3 Oro in più.")
	assert_null(run.reroll_resource_cost(), "Si rinnova solo in Oro.")
	assert_ne(run.upgrade_block_reason(run.board.buildings[0]), "", "I visitatori non potenziano.")
	var porto: int = -1
	for i: int in range(run.offers.size()):
		if run.offers[i].building == foreign:
			porto = i
	assert_false(run.buy_offer(porto), "Serve anche 1 Documenti.")
	run.stock[Res.Type.DOCUMENTI] = 1
	assert_true(run.buy_offer(porto))
	assert_eq(run.stock[Res.Type.DOCUMENTI], 0)
	assert_eq(run.board.buildings[-1].building, foreign)


func test_un_tipo_d_identita_straniero_sblocca_l_opzione() -> void:
	# GDD §6.6 (v0.24): una carta esclusiva di un'altra nazione porta in casa il suo tipo
	# d'identità, che sblocca le opzioni di quella nazione.
	var archers: TroopDef = TroopDef.new()
	archers.id = &"arcieri"
	archers.display_name = "Arcieri"
	archers.types = [&"Fante", &"Cinerale"]
	archers.cooldown_ms = 1000
	var free_option: EventOptionDef = _option("Sempre", {"oro": 1})
	var by_identity_type: EventOptionDef = _option("Volano sopra la cenere", {"ferro": 3})
	by_identity_type.requires_types = [&"Cinerale"]
	catalog.events = [_event(&"montagna", [free_option, by_identity_type])]
	var run: RunState = _run()
	assert_true(run.choose_event())
	assert_string_contains(run.option_block_reason(by_identity_type), "Cinerale")
	run.board.troops.append(BoardPiece.of_troop(archers, 0))
	assert_eq(run.option_block_reason(by_identity_type), "", "La carta straniera porta il suo tipo.")
	assert_true(run.take_event_option(1))
	assert_eq(run.stock[Res.Type.FERRO], 3)


func test_un_evento_di_stagione_compare_solo_in_quella_stagione() -> void:
	# GDD §4.2.5 (v0.25): la stagione è una radice delle carte speciali.
	var flood: EventDef = _event(&"piena", [_option("Prendi", {"oro": 1})])
	flood.seasons = PackedInt32Array([RunState.Season.PRIMAVERA])
	flood.repeatable = true
	catalog.events = [flood]
	var run: RunState = _run()
	assert_eq(run.season, RunState.Season.INVERNO)
	assert_null(run.event_choice, "D'inverno la piena non arriva.")
	while run.season == RunState.Season.INVERNO:
		run.pass_round()
	assert_eq(run.event_choice, flood, "In primavera sì.")


func test_le_stagioni_cambiano_il_peso_dei_consiglieri() -> void:
	# GDD §4.2 (Proposta v0.25): d'inverno più Cancelliere, meno Generale.
	var chancellor: AdvisorDef = Aiuti.consigliere(&"cancelliere", [&"Produzione"])
	chancellor.favored_seasons = PackedInt32Array([RunState.Season.INVERNO])
	var general: AdvisorDef = Aiuti.consigliere(&"generale", [&"Fante"])
	general.disfavored_seasons = PackedInt32Array([RunState.Season.INVERNO])
	var run: RunState = _run()
	assert_eq(run.call("_advisor_weight", chancellor), 2, "Inverno: +1.")
	assert_eq(run.call("_advisor_weight", general), 1, "Inverno: dimezzato, ma almeno 1.")
	while run.season == RunState.Season.INVERNO:
		run.pass_round()
	assert_eq(run.call("_advisor_weight", chancellor), 1, "Primavera: peso normale.")


func test_si_vede_chi_riceve_un_bonus_legato_a_un_tipo() -> void:
	# Richiesta di Davide (6 novembre): segnalare le interazioni fra tipi.
	var faster: ModifierDef = ModifierDef.new()
	faster.id = &"fanti_veloci"
	faster.display_name = "Fanti veloci"
	faster.description = "Le truppe Fante ricaricano il 10% più in fretta."
	faster.is_malus = false
	faster.effect = ModifierDef.Effect.RICARICA_TRUPPA
	faster.target_type = &"Fante"
	faster.amount = -10
	faster.duration_kind = ModifierDef.Duration.PERMANENTE
	var run: RunState = _run()
	# Prima di averlo: quali carte ne beneficerebbero (la truppa Fante, non la fattoria).
	var pieces: Array[BoardPiece] = run.pieces_boosted_by([faster] as Array[ModifierDef])
	assert_eq(pieces.size(), 1)
	assert_eq(pieces[0].troop, soldier_troop)
	# Dopo averlo: una carta Fante in offerta mostra il bonus che riceverebbe.
	run.modifiers.apply(faster, ActiveModifier.OriginKind.IDENTITA, "Via della Guerra", run.year, run.board, RandomNumberGenerator.new())
	var lines: PackedStringArray = run.type_bonuses_for([&"Fante"] as Array[StringName], false)
	assert_eq(lines.size(), 1)
	assert_string_contains(lines[0], "Via della Guerra")
	assert_true(run.type_bonuses_for([&"Fante"] as Array[StringName], true).is_empty(), "Un bonus delle truppe non tocca gli edifici.")
	assert_true(run.type_bonuses_for([&"Spirituale"] as Array[StringName], false).is_empty())
