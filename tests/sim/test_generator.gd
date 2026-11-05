extends GutTest
## Avversari generati e run completa (GDD §3.3, §3.4, §11.3).

func _catalog() -> CatalogDef:
	return load("res://data/catalog/catalog.tres") as CatalogDef


func _rules() -> RunRules:
	return load("res://data/rules/run_rules.tres") as RunRules


func test_stesso_seme_stesso_fantasma() -> void:
	var catalog: CatalogDef = _catalog()
	var a: GhostDef = OpponentGenerator.generate_ghost(catalog, catalog.generator, _rules(), 7, 1234)
	var b: GhostDef = OpponentGenerator.generate_ghost(catalog, catalog.generator, _rules(), 7, 1234)
	assert_eq(a.display_name, b.display_name)
	assert_eq(a.troops.size(), b.troops.size())
	for i: int in range(a.troops.size()):
		assert_eq(a.troops[i].id, b.troops[i].id)
	var c: GhostDef = OpponentGenerator.generate_ghost(catalog, catalog.generator, _rules(), 7, 999)
	assert_true(c.display_name != a.display_name or c.troops.size() != a.troops.size() or c.troops[0].id != a.troops[0].id, "Un altro seme dà un altro fantasma.")


func test_i_fantasmi_crescono_con_gli_anni() -> void:
	var catalog: CatalogDef = _catalog()
	var early: GhostDef = OpponentGenerator.generate_ghost(catalog, catalog.generator, _rules(), 4, 1)
	var late: GhostDef = OpponentGenerator.generate_ghost(catalog, catalog.generator, _rules(), 14, 1)
	assert_gt(late.troops.size(), early.troops.size(), "Più truppe.")
	assert_gte(late.buildings.size(), early.buildings.size(), "Almeno altrettanti edifici.")
	assert_gt(late.era, early.era, "Era più avanzata.")
	assert_true(late.buildings[0].is_capital, "Ogni fantasma ha la sua Capitale.")
	assert_false(late.identity.is_empty(), "Ha un'identità.")
	assert_eq(late.malus.size(), 1, "Lascia un malus.")
	assert_lte(late.troops.size(), _rules().max_troop_slots)
	assert_lte(late.buildings.size(), _rules().max_building_slots)


func test_gli_edifici_coprono_i_colori_delle_truppe() -> void:
	var catalog: CatalogDef = _catalog()
	for year: int in range(4, 16):
		var ghost: GhostDef = OpponentGenerator.generate_ghost(catalog, catalog.generator, _rules(), year, year * 3)
		var colors: Array[StringName] = []
		for building: BuildingDef in ghost.buildings:
			colors.append(building.mana_type)
		var needed: int = 0
		var covered: int = 0
		for troop: TroopDef in ghost.troops:
			if troop.mana_cost > 0:
				needed += 1
				if colors.has(troop.mana_type) or colors.has(BattleSim.MANA_ENERGETICO):
					covered += 1
		assert_eq(covered, needed, "Anno %d: ogni truppa ha mana del suo colore o energetico." % year)


func test_incontri_generati_a_difficolta_crescente() -> void:
	var catalog: CatalogDef = _catalog()
	var list: Array[EncounterDef] = OpponentGenerator.generate_encounters(catalog, catalog.generator, _rules(), 8, 5, 3)
	assert_eq(list.size(), 3)
	assert_lt(list[0].resistance, list[1].resistance)
	assert_lt(list[1].resistance, list[2].resistance)
	assert_eq(list[0].difficulty_label, "Facile")
	assert_eq(list[2].difficulty_label, "Difficile")
	assert_gt(list[2].rewards.size(), list[0].rewards.size(), "Ricompense migliori per i più difficili.")
	assert_ne(list[0].display_name, list[1].display_name, "Nomi diversi nello stesso anno.")


func test_la_run_usa_dati_scritti_poi_generati() -> void:
	var catalog: CatalogDef = _catalog()
	var run: RunState = RunState.new(catalog, _rules(), BattleRules.new(), ResistanceRules.new(), 3)
	run.found_nation("Prova", _choices(run))
	assert_eq(run.current_ghost.display_name, "Fantasma: Borgo di Valdacqua", "Anno 1: fantasma scritto a mano.")
	var generated: GhostDef = run.call("_ghost_for_year", 6)
	assert_eq(generated.year, 6, "Anno 6: fantasma generato.")
	var encounters: Array[EncounterDef] = run.call("_encounters_for_year", 6)
	assert_eq(encounters.size(), 3, "Anno 6: tre incontri generati.")


func test_ricompensa_di_una_risorsa() -> void:
	var reward: RewardDef = RewardDef.new()
	reward.kind = RewardDef.Kind.RISORSA
	reward.resource = Res.Type.CIBO
	reward.amount = 2
	var encounter: EncounterDef = EncounterDef.new()
	encounter.year = 1
	encounter.resistance = 1
	encounter.rewards = [reward]
	var catalog: CatalogDef = _catalog().duplicate() as CatalogDef
	catalog.encounters = [encounter, encounter, encounter]
	var run: RunState = RunState.new(catalog, _rules(), BattleRules.new(), ResistanceRules.new(), 3)
	run.found_nation("Prova", _choices(run))
	while run.phase == RunState.Phase.PRODUZIONE:
		run.pass_round()
	run.choose_encounter(0)
	var before: int = run.stock[Res.Type.CIBO]
	run.take_reward(0)
	assert_eq(run.stock[Res.Type.CIBO], before + 20 + run.production_per_phase()[Res.Type.CIBO], "2 Cibo (in decimi) + la produzione della Preparazione.")


func test_riepilogo_anno_per_anno() -> void:
	var run: RunState = RunState.new(_catalog(), _rules(), BattleRules.new(), ResistanceRules.new(), 3)
	run.found_nation("Prova", _choices(run))
	for year: int in range(2):
		while run.is_shopping_phase():
			run.pass_round()
		if run.phase == RunState.Phase.SCELTA_INCONTRO:
			run.choose_encounter(0)
		if run.phase == RunState.Phase.RICOMPENSA_INCONTRO:
			run.skip_reward()
		while run.is_shopping_phase():
			run.pass_round()
		run.fight_ghost()
	assert_eq(run.history.size(), 3, "Anni 1, 2 e l'anno 3 appena iniziato.")
	assert_ne(run.history[0].encounter_result, "")
	assert_ne(run.history[0].ghost_result, "")
	assert_eq(run.history[1].prestige_after, run.prestige)


func _choices(run: RunState) -> Array[IdentityDef]:
	var choices: Array[IdentityDef] = []
	for dimension: IdentityDef.Dimension in IdentityDef.CREATION_DIMENSIONS:
		var options: Array[IdentityDef] = run.identity_options(dimension)
		var count: int = run.starting_perk_count() if dimension == IdentityDef.Dimension.PERK else 1
		for i: int in range(count):
			choices.append(options[i])
	return choices
