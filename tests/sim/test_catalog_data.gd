extends GutTest
## Controlli sui file dati veri del catalogo (data/).
## Servono a scoprire subito un errore di compilazione dei dati in Godot.

const CATALOG_PATH: String = "res://data/catalog/catalog.tres"
const RUN_RULES_PATH: String = "res://data/rules/run_rules.tres"
const BATTLE_RULES_PATH: String = "res://data/rules/battle_rules.tres"
const RESISTANCE_RULES_PATH: String = "res://data/rules/resistance_rules.tres"


func _catalog() -> CatalogDef:
	return load(CATALOG_PATH) as CatalogDef


func test_i_file_dati_si_caricano() -> void:
	assert_not_null(_catalog(), "Catalogo")
	assert_not_null(load(RUN_RULES_PATH) as RunRules, "Regole della run")
	assert_not_null(load(BATTLE_RULES_PATH) as BattleRules, "Regole della battaglia")
	assert_not_null(load(RESISTANCE_RULES_PATH) as ResistanceRules, "Regole della Resistenza")


func test_regole_confermate_nel_gdd() -> void:
	var rules: RunRules = load(RUN_RULES_PATH) as RunRules
	assert_eq(rules.wins_needed, 10, "GDD §3.4")
	assert_eq(rules.starting_prestige, 20, "GDD §3.4")
	assert_eq(rules.starting_building_slots, 4, "GDD §6.1")
	assert_eq(rules.starting_troop_slots, 3, "GDD §6.1")
	assert_eq(rules.max_building_slots, 10, "GDD §6.1")
	assert_eq(rules.max_troop_slots, 12, "GDD §6.1")
	assert_eq(rules.rounds_per_half, 5, "GDD §3.2: 5 round per metà")
	assert_eq(rules.councillors_per_round, 3, "GDD §4.2: 3 consiglieri")
	assert_eq(rules.proposals_per_councillor, 3, "GDD §4.2: 3 proposte")
	assert_eq(rules.clown_proposals, 4, "GDD §4.2.2: il Clown ne propone 4")
	assert_eq(rules.tier_names.size(), 3, "GDD §4.2.1: 3 livelli")
	var types: Array[int] = []
	for type: int in rules.round_types:
		types.append(type)
	types.sort()
	assert_eq(types, [0, 1, 2, 3, 3] as Array[int], "GDD §4.2: Azioni, Edifici, Truppe e due Misti")
	assert_eq(rules.starting_research, 0, "GDD §6.2")
	assert_eq(rules.starting_buildings.size(), 1, "GDD §6.2: un edificio di base")
	assert_eq(rules.starting_troops.size(), 1, "GDD §6.2: una truppa di base")
	assert_eq(rules.starting_troops[0].mana_cost, 0, "GDD §6.2: truppa di base senza mana")


func test_identificativi_unici_e_valori_validi() -> void:
	var catalog: CatalogDef = _catalog()
	var ids: Dictionary[StringName, bool] = {}
	for def: BuildingDef in catalog.buildings:
		assert_false(ids.has(def.id), "Id ripetuto: %s" % def.id)
		ids[def.id] = true
		assert_gt(def.mana_interval_ms, 0, "Intervallo di %s" % def.id)
		assert_between(def.era, 1, catalog.eras.size(), "Era di %s" % def.id)
	for def: TroopDef in catalog.troops:
		assert_false(ids.has(def.id), "Id ripetuto: %s" % def.id)
		ids[def.id] = true
		assert_gt(def.cooldown_ms, 0, "Ricarica di %s" % def.id)
		assert_between(def.era, 1, catalog.eras.size(), "Era di %s" % def.id)


func test_colori_etichette_e_capitale() -> void:
	var catalog: CatalogDef = _catalog()
	var rules: RunRules = load(RUN_RULES_PATH) as RunRules
	for def: BuildingDef in catalog.buildings:
		if def.mana_amount == 0:
			assert_eq(def.mana_type, BattleSim.MANA_NEUTRO, "Senza mana l'edificio è neutro (%s)" % def.id)
		else:
			assert_true(BattleSim.MANA_COLORS.has(def.mana_type), "Colore di %s" % def.id)
		assert_false(def.tags.is_empty(), "Etichette di %s" % def.id)
		assert_false(def.is_capital, "La Capitale non è fra le offerte (%s)" % def.id)
	for def: TroopDef in catalog.troops:
		assert_true(BattleSim.MANA_COLORS.has(def.mana_type), "Colore di %s" % def.id)
		assert_false(def.tags.is_empty(), "Etichette di %s" % def.id)
		assert_eq(def.upgrade_costs.size(), rules.max_level - 1, "Costi di potenziamento di %s" % def.id)
	assert_eq(rules.starting_buildings.size(), 1)
	assert_true(rules.starting_buildings[0].is_capital, "Si parte dalla Capitale.")
	for type: Res.Type in Res.NAMES:
		assert_gt(rules.starting_buildings[0].production(type), 0, "La Capitale produce %s" % Res.NAMES[type])


func test_catalogo_bozza_3() -> void:
	var catalog: CatalogDef = _catalog()
	assert_eq(catalog.buildings.size(), 27, "27 edifici (Catalogo §8).")
	assert_eq(catalog.troops.size(), 24, "24 truppe.")
	assert_eq(catalog.eras[1].ways.size(), 4, "4 vie nell'era 2.")
	assert_eq(catalog.eras[2].ways.size(), 5, "4 vie più l'esclusiva nell'era 3.")
	for def: TroopDef in catalog.troops:
		if def.siege_damage > 0:
			assert_true(def.tags.has(&"Assedio"), "Solo le truppe Assedio hanno l'attacco d'assedio (%s)." % def.id)
	var perks: int = IdentityRules.options(catalog, IdentityDef.Dimension.PERK).size()
	assert_eq(perks, 11, "7 perk esistenti + 4 nuovi.")
	assert_eq(catalog.generator.ghost_malus_pool.size(), 12, "6 malus esistenti + 6 nuovi.")


func test_identita_complete() -> void:
	var catalog: CatalogDef = _catalog()
	var rules: RunRules = load(RUN_RULES_PATH) as RunRules
	var counts: Dictionary[IdentityDef.Dimension, int] = {}
	for def: IdentityDef in catalog.identities:
		counts[def.dimension] = counts.get(def.dimension, 0) + 1
	for dimension: IdentityDef.Dimension in IdentityDef.CREATION_DIMENSIONS:
		assert_gt(counts.get(dimension, 0), 0, "Opzioni per %s" % IdentityDef.DIMENSION_NAMES[dimension])
	assert_gte(counts.get(IdentityDef.Dimension.PERK, 0), rules.starting_perks, "Abbastanza perk iniziali")
	for ghost: GhostDef in catalog.ghosts:
		assert_false(ghost.identity.is_empty(), "Identità del fantasma %s" % ghost.display_name)


func test_il_consiglio() -> void:
	var catalog: CatalogDef = _catalog()
	var ids: Array[StringName] = []
	var specials: Array[CouncillorDef.Special] = []
	for def: CouncillorDef in catalog.councillors:
		ids.append(def.id)
		specials.append(def.special)
	assert_eq(catalog.councillors.size(), 10, "10 consiglieri (GDD §4.2.3).")
	assert_true(specials.has(CouncillorDef.Special.CLOWN), "C'è il Clown.")
	assert_true(specials.has(CouncillorDef.Special.ANZIANO), "C'è l'Anziano.")
	for action: OpportunityDef in catalog.opportunities:
		assert_true(ids.has(action.councillor), "%s appartiene a un consigliere esistente." % action.id)
	for def: CouncillorDef in catalog.councillors:
		if def.special != CouncillorDef.Special.NESSUNO:
			continue
		var has_something: bool = false
		for action: OpportunityDef in catalog.opportunities:
			if action.councillor == def.id:
				has_something = true
		for building: BuildingDef in catalog.buildings:
			if def.is_affine_building(building):
				has_something = true
		for troop: TroopDef in catalog.troops:
			if def.is_affine_troop(troop):
				has_something = true
		assert_true(has_something, "%s ha qualcosa da proporre." % def.display_name)
	var kinds: Array[OpportunityDef.Kind] = []
	for action: OpportunityDef in catalog.opportunities:
		kinds.append(action.kind)
	for kind: OpportunityDef.Kind in [OpportunityDef.Kind.INCANTA, OpportunityDef.Kind.SPIONAGGIO, OpportunityDef.Kind.PERK, OpportunityDef.Kind.POTENZIA_EDIFICIO, OpportunityDef.Kind.POTENZIA_TRUPPA]:
		assert_true(kinds.has(kind), "Il catalogo ha azioni di tipo %d." % kind)


func test_ogni_anno_di_prova_ha_fantasma_e_tre_incontri() -> void:
	var catalog: CatalogDef = _catalog()
	assert_not_null(catalog.generator, "Dopo gli anni scritti a mano, fantasmi e incontri sono generati.")
	for year: int in range(1, 4):
		var ghosts: int = 0
		for ghost: GhostDef in catalog.ghosts:
			if ghost.year == year:
				ghosts += 1
		assert_eq(ghosts, 1, "Un fantasma per l'anno %d" % year)
		for ghost: GhostDef in catalog.ghosts:
			if ghost.year == year:
				assert_false(ghost.malus.is_empty(), "Ogni fantasma ha un malus (anno %d)" % year)
		var encounters: int = 0
		for encounter: EncounterDef in catalog.encounters:
			if encounter.year == year:
				encounters += 1
				assert_gt(encounter.resistance, 0, "Resistenza di %s" % encounter.display_name)
				assert_false(encounter.rewards.is_empty(), "Ricompense di %s" % encounter.display_name)
		assert_eq(encounters, 3, "Tre incontri per l'anno %d" % year)


func test_una_run_completa_con_i_dati_veri_arriva_alla_fine() -> void:
	var run: RunState = RunState.new(_catalog(), load(RUN_RULES_PATH) as RunRules,
			load(BATTLE_RULES_PATH) as BattleRules, load(RESISTANCE_RULES_PATH) as ResistanceRules, 7)
	var choices: Array[IdentityDef] = []
	for dimension: IdentityDef.Dimension in IdentityDef.CREATION_DIMENSIONS:
		var options: Array[IdentityDef] = run.identity_options(dimension)
		var count: int = run.starting_perk_count() if dimension == IdentityDef.Dimension.PERK else mini(1, options.size())
		for i: int in range(count):
			choices.append(options[i])
	assert_true(run.found_nation("Prova", choices), "La nazione si crea con i dati veri.")
	var guard: int = 0
	while not run.is_over() and guard < 5000:
		guard += 1
		match run.phase:
			RunState.Phase.PRODUZIONE, RunState.Phase.PREPARAZIONE:
				if not run.way_choices.is_empty():
					run.choose_way(0)
					continue
				if run.is_choosing_councillor() and not run.councillor_choices.is_empty():
					run.choose_councillor(0)
					continue
				# Compra la prima proposta che si può pagare senza sostituzioni, altrimenti passa.
				var bought: bool = false
				for i: int in range(run.offers.size()):
					var offer: Offer = run.offers[i]
					if run.can_afford(offer) and not run.offer_needs_replacement(offer):
						bought = run.buy_offer(i, 0 if not run.offer_choices(offer).is_empty() else -1)
						break
				if not bought:
					run.pass_opportunity()
			RunState.Phase.SCELTA_INCONTRO:
				run.choose_encounter(0)
			RunState.Phase.RICOMPENSA_INCONTRO:
				run.take_reward(0)
			RunState.Phase.SCONTRO_FANTASMA:
				run.fight_ghost()
	assert_true(run.is_over(), "La run termina.")
	assert_lt(guard, 5000, "Nessun ciclo infinito.")
	assert_ne(run.run_end, RunState.RunEnd.FINE_PROVA, "La run è completa: finisce con vittoria o sconfitta.")
	assert_eq(run.history.size(), run.year, "Un riepilogo per ogni anno.")


func test_bottino_dei_nemici() -> void:
	var rules: RunRules = load(RUN_RULES_PATH) as RunRules
	assert_eq(rules.ghost_loot_gold, 3, "Fantasma: 3 Oro.")
	assert_eq(rules.ghost_loot_research, 2, "Fantasma: 2 Ricerca.")
	var catalog: CatalogDef = _catalog()
	for encounter: EncounterDef in catalog.encounters:
		assert_gt(encounter.loot_gold, 0, "Bottino di %s" % encounter.display_name)
		assert_gt(encounter.loot_research, 0, "Ricerca di %s" % encounter.display_name)
	var generati: Array[EncounterDef] = OpponentGenerator.generate_encounters(catalog, catalog.generator, rules, 5, 1, 3)
	assert_eq(generati[0].loot_gold, 2, "Facile: 2 Oro.")
	assert_eq(generati[2].loot_research, 3, "Difficile: 3 Ricerca.")
