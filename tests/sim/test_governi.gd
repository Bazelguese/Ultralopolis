extends GutTest
## Governi a tier: evoluzione entrando in un'era e Riforma come evento (GDD §9.4, v0.24).
## Numeri solo di prova.

const Aiuti = preload("res://tests/sim/aiuti_consiglio.gd")

var catalog: CatalogDef
var rules: RunRules
var resistance_rules: ResistanceRules
var monarchy: IdentityDef
var absolute: IdentityDef
var constitutional: IdentityDef
var gold_bonus: ModifierDef
var walls: BuildingDef


func _government(id: StringName, tier: int) -> IdentityDef:
	var def: IdentityDef = IdentityDef.new()
	def.id = id
	def.display_name = String(id).capitalize()
	def.dimension = IdentityDef.Dimension.GOVERNO
	def.tier = tier
	return def


func before_each() -> void:
	walls = BuildingDef.new()
	walls.id = &"mura"
	walls.display_name = "Mura"
	walls.types = [&"Guardiano"]
	walls.cost_gold = 2
	walls.mana_interval_ms = 1000
	gold_bonus = ModifierDef.new()
	gold_bonus.id = &"tesoro_reale"
	gold_bonus.is_malus = false
	gold_bonus.effect = ModifierDef.Effect.RESISTENZA
	gold_bonus.amount = 7
	gold_bonus.duration_kind = ModifierDef.Duration.PERMANENTE
	gold_bonus.stacking = ModifierDef.Stacking.SOMMA_EFFETTI
	monarchy = _government(&"monarchia", 1)
	monarchy.permanent_modifiers = [gold_bonus]
	absolute = _government(&"monarchia_assoluta", 2)
	absolute.advisors_change = -1
	absolute.reform_requires_types = [&"Nobile"]
	constitutional = _government(&"monarchia_costituzionale", 2)
	monarchy.evolves_to = [absolute, constitutional]
	var towers: BuildingDef = walls.duplicate() as BuildingDef
	towers.id = &"torri"
	towers.era = 2
	catalog = CatalogDef.new()
	catalog.buildings = [walls, towers]
	var era2: EraDef = EraDef.new()
	era2.display_name = "Seconda"
	era2.research_cost = 1
	catalog.eras = [EraDef.new(), era2]
	catalog.identities = [monarchy, absolute, constitutional]
	rules = RunRules.new()
	rules.starting_gold = 20
	rules.prototype_years = 0
	rules.starting_buildings = [walls]
	rules.starting_troops = []
	rules.starting_perks = 0
	rules.special_card_chance_percent = 0
	Aiuti.consiglio_semplice(catalog, rules, [], 5)
	var second: AdvisorDef = Aiuti.consigliere(&"secondo", [&"Guardiano"])
	var third: AdvisorDef = Aiuti.consigliere(&"terzo", [&"Guardiano"])
	catalog.advisors.append_array([second, third])
	rules.advisors_per_round = 3
	resistance_rules = ResistanceRules.new()
	resistance_rules.per_era = [10, 10]
	resistance_rules.per_year = 0
	resistance_rules.per_building = 0
	resistance_rules.per_troop = 0


func _run(run_seed: int = 3) -> RunState:
	var run: RunState = RunState.new(catalog, rules, BattleRules.new(), resistance_rules, run_seed)
	assert_true(run.found_nation("Regno", [monarchy]), run.last_error)
	return run


func test_alla_creazione_si_sceglie_solo_il_tier_1() -> void:
	var options: Array[IdentityDef] = IdentityRules.options(catalog, IdentityDef.Dimension.GOVERNO)
	assert_eq(options, [monarchy] as Array[IdentityDef])
	var run: RunState = RunState.new(catalog, rules, BattleRules.new(), resistance_rules, 1)
	assert_false(run.found_nation("Regno", [absolute]), "Un governo di tier 2 non si sceglie alla creazione.")
	assert_string_contains(run.last_error, "non si sceglie alla creazione")


func test_entrando_in_un_era_il_governo_puo_evolvere() -> void:
	var run: RunState = _run()
	var before: int = run.player_resistance()
	run.research = 5
	assert_true(run.advance_era())
	assert_eq(run.government_choices, [absolute, constitutional] as Array[IdentityDef], "Si propongono i rami possibili.")
	assert_false(run.pass_round(), "Prima si decide sul governo.")
	assert_true(run.choose_government(0))
	assert_eq(run.government(), absolute)
	assert_false(run.identity.has(monarchy), "Il vecchio governo esce dall'identità.")
	assert_eq(run.player_resistance(), before - 7, "Il tratto del vecchio governo finisce.")
	assert_eq(run.advisor_choices.size(), 2, "Valgono subito gli effetti del nuovo governo.")
	assert_true(run.government_choices.is_empty())
	assert_true(run.pass_round())


func test_l_evoluzione_si_puo_rifiutare() -> void:
	var run: RunState = _run()
	run.research = 5
	assert_true(run.advance_era())
	assert_true(run.refuse_evolution())
	assert_eq(run.government(), monarchy)
	assert_true(run.pass_round())
	assert_false(run.refuse_evolution(), "Non c'è più nulla da rifiutare.")


func test_dal_tier_piu_alto_non_si_evolve() -> void:
	monarchy.evolves_to = []
	var run: RunState = _run()
	run.research = 5
	assert_true(run.advance_era())
	assert_true(run.government_choices.is_empty())


func _reform() -> EventDef:
	var later: EventOptionDef = EventOptionDef.new()
	later.label = "Rimanda"
	var event: EventDef = EventDef.new()
	event.id = &"riforma"
	event.display_name = "La Riforma"
	event.special = EventDef.Special.RIFORMA
	event.repeatable = true
	event.options = [later]
	return event


func test_la_riforma_offre_un_ramo_per_opzione_pagato_in_influenza() -> void:
	catalog.events = [_reform()]
	rules.special_card_chance_percent = 100
	rules.reform_influence_per_tier = 3
	var run: RunState = _run()
	assert_true(run.choose_event())
	var options: Array[EventOptionDef] = run.event_options()
	assert_eq(options.size(), 3, "Due rami più Rimanda.")
	assert_eq(options[0].change_government, absolute)
	assert_eq(options[0].cost.whole(Res.Type.INFLUENZA), 6, "3 Influenza per tier.")
	assert_string_contains(run.option_block_reason(options[0]), "Nobile", "La Monarchia assoluta chiede una carta Nobile.")
	assert_string_contains(run.option_block_reason(options[1]), "Risorse insufficienti")
	assert_eq(run.option_block_reason(options[2]), "", "Rimanda è sempre libera.")
	run.stock[Res.Type.INFLUENZA] = 6
	assert_true(run.take_event_option(1))
	assert_eq(run.government(), constitutional)
	assert_eq(run.stock[Res.Type.INFLUENZA], 0)


func test_la_riforma_compare_solo_se_il_governo_puo_evolvere() -> void:
	monarchy.evolves_to = []
	catalog.events = [_reform()]
	rules.special_card_chance_percent = 100
	var run: RunState = _run()
	assert_null(run.event_choice, "Senza rami la Riforma non compare.")


func test_l_albero_dei_governi_del_catalogo() -> void:
	# GDD §9.4.1 (v0.24): si evolve solo in avanti, al tier successivo; ogni governo dei tier
	# più alti si raggiunge da almeno un ramo.
	var real: CatalogDef = load("res://data/catalog/catalog.tres") as CatalogDef
	var reached: Dictionary[StringName, bool] = {}
	var governments: Array[IdentityDef] = []
	for def: IdentityDef in real.identities:
		if def.dimension != IdentityDef.Dimension.GOVERNO:
			continue
		governments.append(def)
		for target: Resource in def.evolves_to:
			var next: IdentityDef = target as IdentityDef
			assert_not_null(next)
			assert_eq(next.tier, def.tier + 1, "%s → %s: un tier alla volta" % [def.id, next.id])
			assert_true(real.identities.has(next), "%s è nel catalogo" % next.id)
			reached[next.id] = true
	assert_eq(governments.size(), 11, "3 governi di tier 1, 5 di tier 2, 3 di tier 3.")
	for def: IdentityDef in governments:
		if def.tier > 1:
			assert_true(reached.has(def.id), "%s si raggiunge da un ramo" % def.id)
