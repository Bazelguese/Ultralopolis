extends GutTest
## Verifiche dell'identità della nazione (GDD §9). Numeri solo di prova.

const Aiuti = preload("res://tests/sim/aiuti_consiglio.gd")

var farm: BuildingDef
var sword: TroopDef
var exclusive_troop: TroopDef
var catalog: CatalogDef
var run_rules: RunRules
var resistance_rules: ResistanceRules
var people: IdentityDef
var government: IdentityDef
var creed: IdentityDef
var culture: IdentityDef
var perk_a: IdentityDef
var perk_b: IdentityDef
var perk_c: IdentityDef
var builders: OpportunityDef
var collectors: OpportunityDef
var secret: OpportunityDef
var advisor: AdvisorDef


func _identity(id: StringName, dimension: IdentityDef.Dimension) -> IdentityDef:
	var def: IdentityDef = IdentityDef.new()
	def.id = id
	def.display_name = String(id)
	def.dimension = dimension
	return def


func _opportunity(id: StringName, phase: OpportunityDef.Phase, kind: OpportunityDef.Kind) -> OpportunityDef:
	var def: OpportunityDef = OpportunityDef.new()
	def.id = id
	def.display_name = String(id)
	def.phase = phase
	def.kind = kind
	def.gain_gold = 1
	return def


func _permanent(effect: ModifierDef.Effect, amount: int) -> ModifierDef:
	var def: ModifierDef = ModifierDef.new()
	def.id = StringName("perm_%d_%d" % [effect, amount])
	def.display_name = "Tratto"
	def.is_malus = false
	def.effect = effect
	def.amount = amount
	def.duration_kind = ModifierDef.Duration.PERMANENTE
	return def


func before_each() -> void:
	farm = BuildingDef.new()
	farm.id = &"fattoria"
	farm.display_name = "Fattoria"
	farm.gold_per_phase = 4
	sword = TroopDef.new()
	sword.id = &"spade"
	sword.display_name = "Spade"
	sword.cooldown_ms = 2000
	exclusive_troop = TroopDef.new()
	exclusive_troop.id = &"esclusiva"
	exclusive_troop.display_name = "Esclusiva"
	exclusive_troop.cooldown_ms = 1000

	builders = _opportunity(&"costruttori", OpportunityDef.Phase.PRODUZIONE, OpportunityDef.Kind.SCAMBIO_RISORSE)
	collectors = _opportunity(&"esattori", OpportunityDef.Phase.PRODUZIONE, OpportunityDef.Kind.SCAMBIO_RISORSE)
	secret = _opportunity(&"segreta", OpportunityDef.Phase.PRODUZIONE, OpportunityDef.Kind.SCAMBIO_RISORSE)

	people = _identity(&"popolo", IdentityDef.Dimension.POPOLO)
	people.resistance_bonus = 5
	people.extra_troops = [sword]
	people.exclusive_troops = [exclusive_troop]
	government = _identity(&"governo", IdentityDef.Dimension.GOVERNO)
	government.resistance_bonus = 3
	government.exclusive_opportunities = [secret]
	creed = _identity(&"credo", IdentityDef.Dimension.CREDO)
	creed.permanent_modifiers = [_permanent(ModifierDef.Effect.PRODUZIONE_ORO, 50)]
	culture = _identity(&"cultura", IdentityDef.Dimension.CULTURA)
	culture.extra_gold = 4
	culture.extra_research = 2
	culture.favored_opportunities = [collectors]
	perk_a = _identity(&"perk_a", IdentityDef.Dimension.PERK)
	perk_a.resistance_bonus = 2
	perk_b = _identity(&"perk_b", IdentityDef.Dimension.PERK)
	perk_b.permanent_modifiers = [_permanent(ModifierDef.Effect.RICARICA_TRUPPA, -50)]
	perk_c = _identity(&"perk_c", IdentityDef.Dimension.PERK)

	var era1: EraDef = EraDef.new()
	catalog = CatalogDef.new()
	catalog.buildings = [farm]
	catalog.troops = [sword]
	catalog.eras = [era1]
	catalog.identities = [people, government, creed, culture, perk_a, perk_b, perk_c]
	run_rules = RunRules.new()
	advisor = Aiuti.consiglio_semplice(catalog, run_rules, [builders, collectors, secret])
	run_rules.starting_gold = 0
	run_rules.starting_perks = 2
	run_rules.prototype_years = 0
	run_rules.starting_buildings = [farm]
	run_rules.starting_troops = []
	resistance_rules = ResistanceRules.new()
	resistance_rules.per_era = [10]
	resistance_rules.per_year = 0
	resistance_rules.per_building = 0
	resistance_rules.per_troop = 0


func _new_run(run_seed: int = 5) -> RunState:
	return RunState.new(catalog, run_rules, BattleRules.new(), resistance_rules, run_seed)


func _full_choice() -> Array[IdentityDef]:
	return [people, government, creed, culture, perk_a, perk_b]


# --- Creazione --------------------------------------------------------------

func test_la_run_comincia_dalla_creazione() -> void:
	var run: RunState = _new_run()
	assert_eq(run.phase, RunState.Phase.CREAZIONE_NAZIONE)
	assert_eq(run.year, 0)
	assert_false(run.sell_building(0), "Prima si crea la nazione.")
	assert_eq(run.identity_options(IdentityDef.Dimension.PERK).size(), 3, "Tutte le opzioni sono disponibili.")


func test_creazione_valida_e_inizio_anno_1() -> void:
	var run: RunState = _new_run()
	assert_true(run.found_nation("Regno di Prova", _full_choice()))
	assert_eq(run.nation_name, "Regno di Prova")
	assert_eq(run.year, 1)
	assert_eq(run.phase, RunState.Phase.PRODUZIONE)
	assert_eq(run.identity.size(), 6)
	assert_eq(run.perks().size(), 2)


func test_creazione_incompleta_o_sbagliata() -> void:
	var run: RunState = _new_run()
	assert_false(run.found_nation("X", [people, government, creed, perk_a, perk_b]), "Manca la cultura.")
	assert_false(run.found_nation("X", [people, government, creed, culture, perk_a]), "Manca un perk.")
	assert_false(run.found_nation("X", [people, government, creed, culture, perk_a, perk_a]), "Perk ripetuto.")
	var other_people: IdentityDef = _identity(&"altro", IdentityDef.Dimension.POPOLO)
	catalog.identities.append(other_people)
	assert_false(run.found_nation("X", [people, other_people, government, creed, culture, perk_a, perk_b]), "Due popoli.")
	assert_eq(run.phase, RunState.Phase.CREAZIONE_NAZIONE)


func test_nome_vuoto() -> void:
	var run: RunState = _new_run()
	run.found_nation("   ", _full_choice())
	assert_eq(run.nation_name, "La tua nazione")


# --- Effetti ------------------------------------------------------------------

func test_resistenza_dell_identita() -> void:
	var run: RunState = _new_run()
	run.found_nation("X", _full_choice())
	# Era 10 + popolo 5 + governo 3 + perk 2
	assert_eq(run.player_resistance(), 20)


func test_dotazione_dell_identita() -> void:
	var run: RunState = _new_run()
	run.found_nation("X", _full_choice())
	assert_eq(run.board.troops.size(), 1, "Il popolo porta una truppa.")
	assert_eq(run.board.troops[0].paid, 0, "Fa parte della dotazione: non rimborsa.")
	# Oro: 4 della cultura + raccolta della Produzione (4 +50% del credo = 6)
	assert_eq(run.gold, 10)
	assert_eq(run.research, 2)


func test_dotazione_senza_spazio_viene_saltata() -> void:
	run_rules.starting_troops = [sword, sword, sword]
	var run: RunState = _new_run()
	run.found_nation("X", _full_choice())
	assert_eq(run.board.troops.size(), 3, "Nessuno spazio per la truppa del popolo.")


func test_tratto_permanente_dura_tutta_la_run() -> void:
	var run: RunState = _new_run()
	run.found_nation("X", _full_choice())
	assert_eq(run.production_preview().x, 6, "4 Oro +50% del credo.")
	for i: int in range(3):
		while not run.is_over() and run.phase != RunState.Phase.SCONTRO_FANTASMA:
			run.pass_round()
		run.fight_ghost()
	assert_eq(run.year, 4)
	assert_eq(run.production_preview().x, 6, "Ancora attivo dopo tre anni.")
	assert_string_contains(run.modifiers.active[0].describe(), "per tutta la run")


func test_tratto_in_battaglia() -> void:
	var run: RunState = _new_run()
	run.found_nation("X", _full_choice())
	assert_eq(run.effective_troop(run.board.troops[0]).cooldown_ms, 1000, "2000 ms -50% del perk.")


func test_i_tratti_permanenti_non_si_accorciano() -> void:
	var run: RunState = _new_run()
	run.found_nation("X", _full_choice())
	assert_eq(run.modifiers.year_malus().size(), 0, "L'Ambasciata non li vede.")


# --- Azioni, consiglieri ed elementi esclusivi ----------------------------------

func test_azione_esclusiva_solo_con_l_identita() -> void:
	run_rules.half_themes = PackedInt32Array([RunState.RoundTheme.AZIONI, RunState.RoundTheme.AZIONI])
	var with_identity: RunState = _new_run()
	with_identity.found_nation("X", _full_choice())
	Aiuti.ascolta(with_identity)
	var ids: Array[StringName] = []
	for offer: Offer in with_identity.offers:
		ids.append(offer.opportunity.id)
	assert_true(ids.has(&"segreta"), "Il governo porta la sua azione esclusiva.")

	var other_government: IdentityDef = _identity(&"altro_governo", IdentityDef.Dimension.GOVERNO)
	catalog.identities.append(other_government)
	var without: RunState = _new_run()
	without.found_nation("X", [people, other_government, creed, culture, perk_a, perk_b])
	Aiuti.ascolta(without)
	for attempt: int in range(30):
		for offer: Offer in without.offers:
			if offer.opportunity != null:
				assert_ne(offer.opportunity.id, &"segreta")
		without.gold += without.reroll_cost()
		without.reroll_offers()


func test_azione_favorita_compare_piu_spesso() -> void:
	run_rules.proposals_per_advisor = 1
	run_rules.half_themes = PackedInt32Array([RunState.RoundTheme.AZIONI, RunState.RoundTheme.AZIONI])
	advisor.actions = [builders, collectors]
	government.exclusive_opportunities = []
	var run: RunState = _new_run(11)
	run.found_nation("X", _full_choice())
	Aiuti.ascolta(run)
	var counts: Dictionary[StringName, int] = {}
	for attempt: int in range(600):
		var id: StringName = run.offers[0].opportunity.id
		counts[id] = counts.get(id, 0) + 1
		run.gold += run.reroll_cost()
		run.reroll_offers()
	# Peso 2 contro 1: circa 400 contro 200.
	assert_gt(counts.get(&"esattori", 0), counts.get(&"costruttori", 0) * 3 / 2, "Gli esattori favoriti escono più spesso.")


func test_consigliere_favorito_compare_piu_spesso() -> void:
	var favored: AdvisorDef = Aiuti.consigliere(&"favorito", [Aiuti.TIPO_PROVA])
	var other: AdvisorDef = Aiuti.consigliere(&"altro", [Aiuti.TIPO_PROVA])
	catalog.advisors = [favored, other]
	culture.favored_advisors = [favored]
	run_rules.rounds_per_half = 200
	var temi: PackedInt32Array = PackedInt32Array()
	temi.resize(200)
	temi.fill(RunState.RoundTheme.MISTO)
	run_rules.half_themes = temi
	var run: RunState = _new_run(13)
	run.found_nation("X", _full_choice())
	var counts: Dictionary[StringName, int] = {}
	for attempt: int in range(200):
		var id: StringName = run.advisor_choices[0].id
		counts[id] = counts.get(id, 0) + 1
		run.pass_round()
	# Peso 2 contro 1: circa 133 contro 67.
	assert_gt(counts.get(&"favorito", 0), counts.get(&"altro", 0) * 3 / 2, "Il consigliere favorito dall'identità esce più spesso.")


func test_truppa_esclusiva_fra_le_proposte() -> void:
	var run: RunState = _new_run()
	run.found_nation("X", _full_choice())
	Aiuti.ascolta(run)
	var seen: bool = false
	for attempt: int in range(40):
		for offer: Offer in run.offers:
			if offer.troop == exclusive_troop:
				seen = true
		run.gold += run.reroll_cost()
		run.reroll_offers()
	assert_true(seen, "Il popolo può reclutare la sua truppa esclusiva.")


# --- Perk come ricompensa -------------------------------------------------------

func test_perk_ottenuto_come_ricompensa() -> void:
	var reward: RewardDef = RewardDef.new()
	reward.kind = RewardDef.Kind.PERK
	reward.perk = perk_c
	perk_c.resistance_bonus = 4
	var encounter: EncounterDef = EncounterDef.new()
	encounter.year = 1
	encounter.resistance = 1
	encounter.rewards = [reward]
	catalog.encounters = [encounter]
	var run: RunState = _new_run()
	run.found_nation("X", _full_choice())
	while run.phase == RunState.Phase.PRODUZIONE:
		run.pass_round()
	run.choose_encounter(0)
	var before: int = run.player_resistance()
	assert_true(run.take_reward(0))
	assert_eq(run.perks().size(), 3)
	assert_eq(run.player_resistance(), before + 4)


# --- Fantasmi -------------------------------------------------------------------

func test_identita_del_fantasma() -> void:
	var ghost_perk: IdentityDef = _identity(&"perk_fantasma", IdentityDef.Dimension.PERK)
	ghost_perk.resistance_bonus = 7
	ghost_perk.permanent_modifiers = [_permanent(ModifierDef.Effect.RICARICA_TRUPPA, -50)]
	var ghost: GhostDef = GhostDef.new()
	ghost.year = 1
	ghost.era = 1
	ghost.troops = [sword]
	ghost.identity = [ghost_perk]
	catalog.ghosts = [ghost]
	var run: RunState = _new_run()
	run.found_nation("X", _full_choice())
	assert_eq(run.ghost_resistance(), 17, "Era 10 + perk 7.")
	while run.phase != RunState.Phase.SCONTRO_FANTASMA:
		run.pass_round()
	run.fight_ghost()
	assert_eq(run.last_battle_setups()[1].troops[0].cooldown_ms, 1000, "Il tratto vale anche per il fantasma.")
	assert_eq(sword.cooldown_ms, 2000, "La scheda del catalogo non cambia.")
