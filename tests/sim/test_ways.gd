extends GutTest
## Vie delle ere (GDD §10.4, §17).

var era1: EraDef
var era2: EraDef
var commerce: IdentityDef
var war: IdentityDef
var faith: IdentityDef
var knowledge: IdentityDef
var spirits: IdentityDef
var merchants: IdentityDef
var catalog: CatalogDef
var rules: RunRules
var exclusive_building: BuildingDef


func _way(id: StringName) -> IdentityDef:
	var def: IdentityDef = IdentityDef.new()
	def.id = id
	def.display_name = String(id)
	def.dimension = IdentityDef.Dimension.VIA
	return def


func before_each() -> void:
	merchants = IdentityDef.new()
	merchants.id = &"cultura_mercantile"
	merchants.dimension = IdentityDef.Dimension.CULTURA
	commerce = _way(&"commercio")
	commerce.favored_by = [merchants]
	commerce.extra_gold = 6
	commerce.extra_troop_slots = 1
	var faith_bonus: ResourceAmounts = ResourceAmounts.new()
	faith_bonus.fede = 4
	war = _way(&"guerra")
	faith = _way(&"fede")
	faith.extra_resources = faith_bonus
	knowledge = _way(&"sapere")
	spirits = _way(&"spiriti")
	spirits.requires_any = [merchants]
	exclusive_building = BuildingDef.new()
	exclusive_building.id = &"fondaco"
	exclusive_building.era = 2
	commerce.exclusive_buildings = [exclusive_building]
	var opportunity: OpportunityDef = OpportunityDef.new()
	opportunity.kind = OpportunityDef.Kind.COSTRUISCI_EDIFICIO
	opportunity.phase = OpportunityDef.Phase.PRODUZIONE

	era1 = EraDef.new()
	era2 = EraDef.new()
	era2.display_name = "Sviluppo"
	era2.research_cost = 5
	era2.ways = [commerce, war, faith, knowledge]
	catalog = CatalogDef.new()
	catalog.eras = [era1, era2]
	var common: BuildingDef = BuildingDef.new()
	common.id = &"comune"
	common.era = 2
	catalog.buildings = [common]
	catalog.opportunities = [opportunity]
	rules = RunRules.new()
	rules.starting_gold = 0
	rules.prototype_years = 0
	rules.starting_buildings = []
	rules.starting_troops = []


func _run(run_seed: int = 1) -> RunState:
	var run: RunState = RunState.new(catalog, rules, BattleRules.new(), ResistanceRules.new(), run_seed)
	run.research = 5
	return run


func test_entrando_nella_seconda_era_si_sceglie_fra_tre_vie() -> void:
	var run: RunState = _run()
	assert_true(run.advance_era())
	assert_eq(run.way_choices.size(), 3)
	assert_false(run.pass_opportunity(), "Prima la scelta della via.")
	assert_true(run.choose_way(0))
	assert_true(run.way_choices.is_empty())
	assert_true(run.pass_opportunity())


func test_la_via_diventa_identita_e_da_il_bonus_immediato() -> void:
	var run: RunState = _run()
	run.advance_era()
	var index: int = run.way_choices.find(commerce)
	if index < 0:
		run.way_choices[0] = commerce
		index = 0
	var slots_before: int = run.board.troop_capacity()
	run.choose_way(index)
	assert_true(run.identity.has(commerce))
	assert_eq(run.gold, 6, "+6 Oro subito.")
	assert_eq(run.board.troop_capacity(), slots_before + 1, "+1 spazio truppa.")


func test_bonus_immediato_di_altre_risorse() -> void:
	var run: RunState = _run()
	run.advance_era()
	run.way_choices[0] = faith
	run.choose_way(0)
	assert_eq(run.stock[Res.Type.FEDE], 4)


func test_via_esclusiva_solo_con_l_elemento_richiesto() -> void:
	era2.ways = [spirits, war]
	var run: RunState = _run()
	run.advance_era()
	assert_eq(run.way_choices, [war] as Array[IdentityDef], "Senza Cultura mercantile la Via degli Spiriti non esce.")
	var with_culture: RunState = _run()
	with_culture.identity.append(merchants)
	with_culture.advance_era()
	assert_true(with_culture.way_choices.has(spirits))


func test_le_vie_favorite_escono_piu_spesso() -> void:
	era2.ways = [commerce, war, faith, knowledge]
	var with_count: int = 0
	var without_count: int = 0
	for run_seed: int in range(200):
		var run: RunState = _run(run_seed)
		run.identity.append(merchants)
		run.advance_era()
		if run.way_choices.has(commerce):
			with_count += 1
		var plain: RunState = _run(run_seed)
		plain.advance_era()
		if plain.way_choices.has(commerce):
			without_count += 1
	assert_gt(with_count, without_count, "Peso 2 contro 1.")


func test_meno_di_tre_vie_si_mostrano_tutte() -> void:
	era2.ways = [war, faith]
	var run: RunState = _run()
	run.advance_era()
	assert_eq(run.way_choices.size(), 2)


func test_esclusivi_della_via_solo_nella_loro_era_e_per_chi_ha_la_via() -> void:
	var run: RunState = _run()
	run.advance_era()
	run.way_choices[0] = commerce
	run.choose_way(0)
	var seen: bool = false
	for attempt: int in range(40):
		for offer: Offer in run.offers:
			if offer.building == exclusive_building:
				seen = true
		run.gold += run.reroll_cost()
		run.reroll_offers()
	assert_true(seen, "Il Fondaco compare nell'era 2 per chi ha la Via del Commercio.")
	var other: RunState = _run()
	other.advance_era()
	other.way_choices[0] = war
	other.choose_way(0)
	for attempt: int in range(40):
		for offer: Offer in other.offers:
			assert_ne(offer.building, exclusive_building)
		other.gold += other.reroll_cost()
		other.reroll_offers()


func test_nessuna_via_nella_prima_era() -> void:
	var run: RunState = _run()
	assert_true(run.way_choices.is_empty())


func test_i_fantasmi_generati_hanno_una_via_per_era() -> void:
	var real: CatalogDef = load("res://data/catalog/catalog.tres") as CatalogDef
	var real_rules: RunRules = load("res://data/rules/run_rules.tres") as RunRules
	var ghost: GhostDef = OpponentGenerator.generate_ghost(real, real.generator, real_rules, 12, 3)
	var ways: int = 0
	for element: IdentityDef in ghost.identity:
		if element.dimension == IdentityDef.Dimension.VIA:
			ways += 1
	var expected: int = 0
	for era_index: int in range(1, ghost.era):
		if not real.eras[era_index].ways.is_empty():
			expected += 1
	assert_eq(ways, expected)
