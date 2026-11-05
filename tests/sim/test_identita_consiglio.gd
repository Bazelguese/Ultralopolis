extends GutTest
## Effetti di governi e culture sul Consiglio e sulle risorse (GDD §9.2, §9.4; v0.24).
## Numeri solo di prova.

const Aiuti = preload("res://tests/sim/aiuti_consiglio.gd")

var catalog: CatalogDef
var rules: RunRules
var resistance_rules: ResistanceRules
var barracks: BuildingDef
var walls: BuildingDef
var soldier_troop: TroopDef
var drill: OpportunityDef
var cheap_drill: OpportunityDef
var advisors: Array[AdvisorDef] = []


func _advisor(id: StringName, types: Array[StringName], actions: Array[OpportunityDef] = [],
		resource: Res.Type = Res.Type.FERRO) -> AdvisorDef:
	return Aiuti.consigliere(id, types, actions, resource)


func _element(id: StringName, dimension: IdentityDef.Dimension) -> IdentityDef:
	var def: IdentityDef = IdentityDef.new()
	def.id = id
	def.display_name = String(id).capitalize()
	def.dimension = dimension
	return def


func before_each() -> void:
	barracks = BuildingDef.new()
	barracks.id = &"caserma"
	barracks.display_name = "Caserma"
	barracks.types = [&"Bellico"]
	barracks.cost_gold = 3
	barracks.mana_type = &"rosso"
	barracks.mana_amount = 1
	barracks.mana_interval_ms = 1000
	walls = BuildingDef.new()
	walls.id = &"mura"
	walls.display_name = "Mura"
	walls.types = [&"Guardiano"]
	walls.cost_gold = 2
	walls.mana_interval_ms = 1000
	soldier_troop = TroopDef.new()
	soldier_troop.id = &"fanti"
	soldier_troop.display_name = "Fanti"
	soldier_troop.types = [&"Bellico"]
	soldier_troop.cooldown_ms = 1000
	soldier_troop.food_tenths = 0
	drill = OpportunityDef.new()
	drill.id = &"addestramento"
	drill.display_name = "Addestramento"
	drill.kind = OpportunityDef.Kind.SCAMBIO_RISORSE
	drill.gain_gold = 1
	drill.cost_resources = ResourceAmounts.new()
	drill.cost_resources.ferro = 3
	cheap_drill = OpportunityDef.new()
	cheap_drill.id = &"ronda"
	cheap_drill.display_name = "Ronda"
	cheap_drill.kind = OpportunityDef.Kind.SCAMBIO_RISORSE
	cheap_drill.gain_gold = 1
	cheap_drill.cost_resources = ResourceAmounts.new()
	cheap_drill.cost_resources.ferro = 1
	advisors = [
		_advisor(&"generale", [&"Bellico"], [drill, cheap_drill]),
		_advisor(&"architetto", [&"Guardiano"], [], Res.Type.PIETRA),
		_advisor(&"sacerdote", [&"Bellico"], [], Res.Type.FEDE),
		_advisor(&"tesoriere", [&"Bellico", &"Guardiano"], [], Res.Type.INFLUENZA),
		_advisor(&"studioso", [&"Guardiano"], [], Res.Type.DOCUMENTI),
	]
	catalog = CatalogDef.new()
	catalog.buildings = [barracks, walls]
	catalog.troops = [soldier_troop]
	catalog.eras = [EraDef.new()]
	catalog.advisors = advisors
	rules = RunRules.new()
	rules.starting_gold = 50
	rules.prototype_years = 0
	rules.starting_buildings = [walls]
	rules.starting_troops = [soldier_troop]
	rules.starting_perks = 0
	rules.advisors_per_round = 3
	rules.rounds_per_season = 5
	var themes: PackedInt32Array = PackedInt32Array()
	for i: int in range(5):
		themes.append(RunState.RoundTheme.MISTO)
	rules.set_all_season_themes(themes)
	rules.special_card_chance_percent = 0
	resistance_rules = ResistanceRules.new()
	resistance_rules.per_era = [10]
	resistance_rules.per_year = 0
	resistance_rules.per_building = 0
	resistance_rules.per_troop = 0


## Avvia una run con una nazione fatta solo di questo elemento dell'identità.
func _run_with(element: IdentityDef, run_seed: int = 5) -> RunState:
	catalog.identities = [element]
	var run: RunState = RunState.new(catalog, rules, BattleRules.new(), resistance_rules, run_seed)
	assert_true(run.found_nation("Prova", [element]), run.last_error)
	return run


func test_la_repubblica_mostra_un_consigliere_in_piu_e_le_proposte_costano_di_piu() -> void:
	var republic: IdentityDef = _element(&"repubblica", IdentityDef.Dimension.GOVERNO)
	republic.advisors_change = 1
	republic.proposal_gold_change = 1
	var run: RunState = _run_with(republic)
	assert_eq(run.advisors_per_round(), 4)
	assert_eq(run.advisor_choices.size(), 4, "4 consiglieri invece di 3.")
	assert_true(run.choose_advisor(0))
	for offer: Offer in run.offers:
		if offer.building == barracks:
			assert_eq(offer.price, 4, "La caserma costa 1 Oro in più.")
		if offer.troop == soldier_troop:
			assert_eq(offer.price, 1, "Anche le truppe costano 1 Oro in più.")
		if offer.opportunity == drill:
			assert_eq(offer.price, 0, "Le azioni senza Oro restano senza Oro.")


func test_la_dittatura_mostra_meno_consiglieri() -> void:
	var dictatorship: IdentityDef = _element(&"dittatura", IdentityDef.Dimension.GOVERNO)
	dictatorship.advisors_change = -1
	var run: RunState = _run_with(dictatorship)
	assert_eq(run.advisor_choices.size(), 2)


func test_il_consigliere_sempre_presente_compare_in_ogni_round() -> void:
	var theocracy: IdentityDef = _element(&"teocrazia", IdentityDef.Dimension.GOVERNO)
	theocracy.always_present_advisor = advisors[2]
	rules.special_card_chance_percent = 100
	var event: EventDef = EventDef.new()
	event.id = &"evento"
	event.repeatable = true
	var option: EventOptionDef = EventOptionDef.new()
	option.label = "Prendi"
	event.options = [option]
	catalog.events = [event]
	var run: RunState = _run_with(theocracy)
	for i: int in range(4):
		assert_true(run.advisor_choices.has(advisors[2]), "Il Sacerdote c'è sempre (round %d)." % run.round_number)
		run.pass_round()


func test_un_consigliere_escluso_non_compare_mai() -> void:
	var totalitarian: IdentityDef = _element(&"totalitarismo", IdentityDef.Dimension.GOVERNO)
	totalitarian.excluded_advisors = [advisors[1]]
	rules.advisors_per_round = 5
	var run: RunState = _run_with(totalitarian)
	for i: int in range(4):
		assert_false(run.advisor_choices.has(advisors[1]), "L'architetto è escluso.")
		assert_eq(run.advisor_choices.size(), 4)
		run.pass_round()


func test_il_consigliere_di_corte_e_il_primo_ascoltato() -> void:
	var absolute: IdentityDef = _element(&"monarchia_assoluta", IdentityDef.Dimension.GOVERNO)
	absolute.court_advisor_always = true
	var run: RunState = _run_with(absolute)
	assert_null(run.court_advisor, "All'inizio non c'è un consigliere di corte.")
	var first: AdvisorDef = run.advisor_choices[0]
	assert_true(run.choose_advisor(0))
	assert_eq(run.court_advisor, first, "Il primo consigliere ascoltato diventa di corte.")
	run.pass_round()
	for i: int in range(3):
		assert_true(run.advisor_choices.has(first), "Il consigliere di corte compare sempre.")
		assert_true(run.choose_advisor(run.advisor_choices.size() - 1))
		assert_eq(run.court_advisor, first, "Non cambia più.")
		run.pass_round()


func test_il_consigliere_di_corte_compare_piu_spesso() -> void:
	var monarchy: IdentityDef = _element(&"monarchia", IdentityDef.Dimension.GOVERNO)
	monarchy.court_advisor_weight = 50
	rules.advisors_per_round = 1
	rules.rounds_per_season = 21
	var themes: PackedInt32Array = PackedInt32Array()
	for i: int in range(21):
		themes.append(RunState.RoundTheme.MISTO)
	rules.set_all_season_themes(themes)
	var run: RunState = _run_with(monarchy)
	assert_true(run.choose_advisor(0))
	var court: AdvisorDef = run.court_advisor
	var seen: int = 0
	for i: int in range(20):
		run.pass_round()
		assert_true(run.is_shopping_phase())
		if run.advisor_choices.has(court):
			seen += 1
	assert_gt(seen, 12, "Con un peso alto compare quasi sempre.")


func test_la_cultura_mercantile_vende_meglio() -> void:
	var merchants: IdentityDef = _element(&"mercantile", IdentityDef.Dimension.CULTURA)
	merchants.market_rate_change = 1
	var run: RunState = _run_with(merchants)
	assert_eq(run.market_rate(), 1)
	run.stock[Res.Type.LEGNO] = 3
	var before: int = run.gold
	assert_true(run.sell_resource(Res.Type.LEGNO, 1), run.last_error)
	assert_eq(run.gold, before + 1, "1 Legno per 1 Oro.")


func test_la_cultura_guerriera_paga_meno_le_azioni_del_generale() -> void:
	var warriors: IdentityDef = _element(&"guerriera", IdentityDef.Dimension.CULTURA)
	warriors.cheaper_advisors = [advisors[0]]
	warriors.action_discount = 1
	catalog.advisors = [advisors[0]]
	rules.advisors_per_round = 1
	rules.proposals_per_advisor = 9
	var run: RunState = _run_with(warriors)
	assert_true(run.choose_advisor(0))
	var checked: int = 0
	for offer: Offer in run.offers:
		if offer.opportunity == drill:
			assert_eq(offer.other_cost.whole(Res.Type.FERRO), 2, "3 Ferro diventano 2.")
			checked += 1
		if offer.opportunity == cheap_drill:
			assert_eq(offer.other_cost.whole(Res.Type.FERRO), 1, "Almeno 1.")
			checked += 1
	assert_eq(checked, 2, "Entrambe le azioni proposte.")
	assert_eq(drill.cost_resources.ferro, 3, "La scheda dell'azione non cambia.")


func test_la_cultura_artigiana_potenzia_a_meno() -> void:
	var artisans: IdentityDef = _element(&"artigiana", IdentityDef.Dimension.CULTURA)
	artisans.upgrade_discount = 1
	catalog.advisors = [advisors[1]]
	rules.advisors_per_round = 1
	rules.upgrade_cost_per_era = [2, 3]
	var run: RunState = _run_with(artisans)
	assert_true(run.choose_advisor(0))
	var cost: ResourceAmounts = run.upgrade_cost_of(run.board.buildings[0])
	assert_eq(cost.whole(Res.Type.PIETRA), 1, "2 Pietra diventano 1.")


func test_la_carta_speciale_non_sostituisce_un_consigliere_sempre_presente() -> void:
	var government: IdentityDef = _element(&"teocrazia", IdentityDef.Dimension.GOVERNO)
	government.always_present_advisor = advisors[2]
	government.advisors_change = -2
	rules.special_card_chance_percent = 100
	var event: EventDef = EventDef.new()
	event.id = &"evento"
	event.repeatable = true
	var option: EventOptionDef = EventOptionDef.new()
	option.label = "Prendi"
	event.options = [option]
	catalog.events = [event]
	var run: RunState = _run_with(government)
	assert_eq(run.advisor_choices, [advisors[2]] as Array[AdvisorDef], "Resta il Sacerdote.")
	assert_null(run.event_choice, "Non c'è posto per l'evento.")
