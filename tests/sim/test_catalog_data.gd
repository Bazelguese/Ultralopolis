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
	assert_eq(rules.advisors_per_round, 3, "GDD §4.2: 3 consiglieri per round")
	assert_eq(rules.proposals_per_advisor, 3, "GDD §4.2: 3 proposte")
	assert_eq(rules.elder_upgrades_per_year, 1, "GDD §4.2.2: l'Anziano potenzia una volta all'anno")
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


func test_colori_tipi_e_capitale() -> void:
	var catalog: CatalogDef = _catalog()
	var rules: RunRules = load(RUN_RULES_PATH) as RunRules
	for def: BuildingDef in catalog.buildings:
		if def.mana_amount == 0:
			assert_eq(def.mana_type, BattleSim.MANA_NEUTRO, "Senza mana l'edificio è neutro (%s)" % def.id)
		else:
			assert_true(BattleSim.MANA_COLORS.has(def.mana_type), "Colore di %s" % def.id)
		assert_false(def.types.is_empty(), "Tipi di %s" % def.id)
		assert_false(def.is_capital, "La Capitale non è fra le offerte (%s)" % def.id)
	for def: TroopDef in catalog.troops:
		assert_true(BattleSim.MANA_COLORS.has(def.mana_type), "Colore di %s" % def.id)
		assert_false(def.types.is_empty(), "Tipi di %s" % def.id)
	assert_eq(rules.starting_buildings.size(), 1)
	assert_true(rules.starting_buildings[0].is_capital, "Si parte dalla Capitale.")
	# GDD §6.2 (v0.22): la Capitale produce di base solo Oro, Cibo e Ricerca.
	var base: Array[Res.Type] = [Res.Type.ORO, Res.Type.CIBO, Res.Type.RICERCA]
	for type: Res.Type in Res.NAMES:
		if base.has(type):
			assert_gt(rules.starting_buildings[0].production(type), 0, "La Capitale produce %s" % Res.NAMES[type])
		else:
			assert_eq(rules.starting_buildings[0].production(type), 0, "Di base la Capitale non produce %s" % Res.NAMES[type])


func test_ogni_elemento_dell_identita_indica_una_risorsa_della_capitale() -> void:
	# GDD §6.2, §9.2 (v0.22): popolo, governo, credo e cultura indicano una risorsa ciascuno.
	var catalog: CatalogDef = _catalog()
	for def: IdentityDef in catalog.identities:
		if def.dimension == IdentityDef.Dimension.PERK:
			continue
		var capital_bonus: int = 0
		for modifier: ModifierDef in def.permanent_modifiers:
			if modifier.effect == ModifierDef.Effect.PRODUZIONE_PER_EDIFICIO and modifier.target_type == &"Capitale":
				capital_bonus += 1
				assert_eq(modifier.amount, 1, "+1 a fase (%s)" % def.id)
		assert_eq(capital_bonus, 1, "Una sola risorsa della Capitale per %s" % def.id)


func test_catalogo_bozza_3() -> void:
	var catalog: CatalogDef = _catalog()
	assert_eq(catalog.buildings.size(), 37, "37 edifici (Catalogo §8, bozza 4).")
	assert_eq(catalog.troops.size(), 30, "30 truppe (bozza 4).")
	assert_eq(catalog.eras[1].ways.size(), 4, "4 vie nell'era 2.")
	assert_eq(catalog.eras[2].ways.size(), 5, "4 vie più l'esclusiva nell'era 3.")
	for def: TroopDef in catalog.troops:
		if def.siege_damage > 0:
			assert_true(def.types.has(&"Assedio"), "Solo le truppe Assedio hanno l'attacco d'assedio (%s)." % def.id)
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


func test_il_consiglio_del_prototipo() -> void:
	# GDD §4.2.2, §4.2.3 (v0.22): 8 consiglieri ordinari con azioni, più Clown e Anziano.
	var catalog: CatalogDef = _catalog()
	var specials: Array[AdvisorDef.Special] = []
	for advisor: AdvisorDef in catalog.advisors:
		if advisor.special != AdvisorDef.Special.NESSUNO:
			specials.append(advisor.special)
			continue
		assert_false(advisor.actions.is_empty(), "Azioni di %s" % advisor.display_name)
		for action: OpportunityDef in advisor.actions:
			assert_ne(action.kind, OpportunityDef.Kind.COSTRUISCI_EDIFICIO, "Gli edifici vengono dai tipi (%s)" % action.id)
			assert_ne(action.kind, OpportunityDef.Kind.RECLUTA_TRUPPA, "Le truppe vengono dai tipi (%s)" % action.id)
			assert_eq(action.cost_gold if action.kind not in [OpportunityDef.Kind.SPAZIO_EDIFICIO, OpportunityDef.Kind.SPAZIO_TRUPPA] else 0, 0,
					"Le azioni non costano Oro, salvo gli spazi (GDD §4.2): %s" % action.id)
		if advisor.random_resource:
			assert_eq(advisor.upgrade_resource, Res.Type.ORO, "Ombra: Oro più una risorsa casuale")
	assert_true(specials.has(AdvisorDef.Special.CLOWN), "C'è il Clown")
	assert_true(specials.has(AdvisorDef.Special.ANZIANO), "C'è l'Anziano")


func test_ogni_risorsa_di_categoria_paga_almeno_un_azione() -> void:
	# GDD §4.2.3, §5.3 (v0.22).
	var catalog: CatalogDef = _catalog()
	var paid: Dictionary[Res.Type, bool] = {}
	for advisor: AdvisorDef in catalog.advisors:
		for action: OpportunityDef in advisor.actions:
			if action.cost_resources != null:
				for type: Res.Type in Res.NAMES:
					if action.cost_resources.whole(type) > 0:
						paid[type] = true
	for advisor: AdvisorDef in catalog.advisors:
		if advisor.special == AdvisorDef.Special.NESSUNO and not advisor.random_resource:
			assert_true(paid.has(advisor.upgrade_resource), "%s paga almeno un'azione" % Res.NAMES[advisor.upgrade_resource])


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
	while not run.is_over() and guard < 1000:
		guard += 1
		match run.phase:
			RunState.Phase.PRODUZIONE, RunState.Phase.PREPARAZIONE:
				# Ascolta il primo consigliere, potenzia se può, compra la prima proposta che si può
				# pagare senza sostituzioni e senza scelte, altrimenti passa.
				if run.chosen_advisor == null and not run.advisor_choices.is_empty():
					run.choose_advisor(0)
				for piece: BoardPiece in run.board.buildings + run.board.troops:
					var cost: ResourceAmounts = run.upgrade_cost_of(piece)
					if run.upgrade_block_reason(piece) == "" and cost != null and run.can_pay(cost):
						run.upgrade_building(run.board.buildings.find(piece)) if piece.building != null else run.upgrade_troop(run.board.troops.find(piece))
						break
				var bought: bool = false
				for i: int in range(run.offers.size()):
					var offer: Offer = run.offers[i]
					if run.can_afford(offer) and not run.offer_needs_replacement(offer) and run.offer_choices(offer).is_empty():
						bought = run.buy_offer(i)
						break
				if not bought:
					run.pass_round()
			RunState.Phase.SCELTA_INCONTRO:
				run.choose_encounter(0)
			RunState.Phase.RICOMPENSA_INCONTRO:
				run.take_reward(0)
			RunState.Phase.SCONTRO_FANTASMA:
				run.fight_ghost()
	assert_true(run.is_over(), "La run termina.")
	assert_lt(guard, 1000, "Nessun ciclo infinito.")
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


func test_ogni_tipo_delle_carte_sta_in_una_categoria() -> void:
	# GDD §4.2.4, §6.6 (v0.22): i tipi delle carte formano le categorie dei consiglieri.
	var catalog: CatalogDef = _catalog()
	var in_categories: Dictionary[StringName, bool] = {}
	var ordinary: int = 0
	for advisor: AdvisorDef in catalog.advisors:
		if advisor.special == AdvisorDef.Special.NESSUNO:
			ordinary += 1
			assert_false(advisor.types.is_empty(), "Tipi della categoria %s" % advisor.category_name)
		for card_type: StringName in advisor.types:
			in_categories[card_type] = true
	assert_eq(ordinary, 8, "8 categorie (GDD §4.2.4).")
	var used: Dictionary[StringName, bool] = {}
	var cards: Array[Array] = []
	for def: BuildingDef in catalog.buildings:
		cards.append([def.id, def.types])
	for def: TroopDef in catalog.troops:
		cards.append([def.id, def.types])
	for identity: IdentityDef in catalog.identities:
		for def: BuildingDef in identity.exclusive_buildings:
			cards.append([def.id, def.types])
		for def: TroopDef in identity.exclusive_troops:
			cards.append([def.id, def.types])
	# I tipi d'identità stanno fuori dalle categorie (GDD §6.6, v0.24).
	var identity_types: Array[StringName] = IdentityRules.identity_types(catalog)
	for card: Array in cards:
		var card_types: Array[StringName] = card[1]
		assert_between(card_types.size(), 1, 3, "1–3 tipi per %s" % card[0])
		var category_types: int = 0
		for card_type: StringName in card_types:
			used[card_type] = true
			if identity_types.has(card_type):
				continue
			category_types += 1
			assert_true(in_categories.has(card_type), "Il tipo %s di %s sta in una categoria" % [card_type, card[0]])
		assert_gt(category_types, 0, "%s ha almeno un tipo di categoria" % card[0])
	for card_type: StringName in in_categories:
		assert_true(used.has(card_type), "Il tipo %s è usato da almeno una carta" % card_type)


func test_ogni_era_ha_truppe_di_tutti_e_quattro_i_colori() -> void:
	# GDD §5.3 (v0.22): quattro colori; il catalogo ne offre in ogni era.
	var catalog: CatalogDef = _catalog()
	for era: int in range(1, catalog.eras.size() + 1):
		var colors: Dictionary[StringName, bool] = {}
		for def: TroopDef in catalog.troops:
			if def.era == era and def.mana_cost > 0:
				colors[def.mana_type] = true
		for color: StringName in [BattleSim.MANA_ROSSO, BattleSim.MANA_VERDE, BattleSim.MANA_BLU, BattleSim.MANA_VIOLA]:
			assert_true(colors.has(color), "Era %d: truppe %s" % [era, color])


func test_ogni_consigliere_ha_edifici_truppe_e_azioni_in_ogni_era() -> void:
	# Catalogo bozza 4: niente consiglieri a mani vuote nei round Edifici, Truppe e Azioni.
	var catalog: CatalogDef = _catalog()
	var exclusive: Array[OpportunityDef] = []
	for def: IdentityDef in catalog.identities:
		exclusive.append_array(def.exclusive_opportunities)
	for advisor: AdvisorDef in catalog.advisors:
		if advisor.special != AdvisorDef.Special.NESSUNO:
			continue
		var common_actions: int = 0
		for action: OpportunityDef in advisor.actions:
			if not exclusive.has(action):
				common_actions += 1
		assert_gte(common_actions, 2, "%s ha almeno due azioni comuni" % advisor.display_name)
		for era: int in range(1, catalog.eras.size() + 1):
			var buildings: int = 0
			var troops: int = 0
			for def: BuildingDef in catalog.buildings:
				if def.era == era and advisor.covers(def.types):
					buildings += 1
			for def: TroopDef in catalog.troops:
				if def.era == era and advisor.covers(def.types):
					troops += 1
			assert_gt(buildings, 0, "%s: edifici nell'era %d" % [advisor.display_name, era])
			assert_gt(troops, 0, "%s: truppe nell'era %d" % [advisor.display_name, era])


func test_eventi_visitatori_e_fortune_del_catalogo() -> void:
	# Bozza v0.23: 18 eventi, 6 fortune, 6 visitatori; ogni evento ha un'opzione senza requisiti.
	var catalog: CatalogDef = _catalog()
	var categories: Array[String] = []
	for advisor: AdvisorDef in catalog.advisors:
		if advisor.category_name != "":
			categories.append(advisor.category_name)
	var events: int = 0
	var fortunes: int = 0
	for event: EventDef in catalog.events:
		assert_true(categories.has(event.sphere), "La sfera di %s è una categoria" % event.id)
		assert_false(event.options.is_empty(), "Opzioni di %s" % event.id)
		var free: bool = false
		for option: EventOptionDef in event.options:
			if option.requires_identity.is_empty() and option.requires_types.is_empty():
				free = true
		assert_true(free, "%s ha un'opzione senza requisiti" % event.id)
		if event.family == EventDef.Family.FORTUNA:
			fortunes += 1
			assert_eq(event.options.size(), 1, "Una Fortuna è un dono solo (%s)" % event.id)
		else:
			events += 1
	assert_eq(events, 19, "18 eventi più la Riforma (v0.24).")
	assert_eq(fortunes, 6)
	assert_eq(catalog.visitors.size(), 6)
	for visitor: AdvisorDef in catalog.visitors:
		assert_eq(visitor.special, AdvisorDef.Special.VISITATORE, "%s è un visitatore" % visitor.id)
		assert_true(categories.has(visitor.category_name), "La sfera di %s è una categoria" % visitor.id)


func test_identita_del_prototipo_v024() -> void:
	# GDD §9.3 (v0.24): 3 razze, 3 governi alla creazione, 4 credi, 4 culture.
	# L'Ordine della Ragione non è più un credo: il sapere passa alla Cultura erudita.
	var catalog: CatalogDef = _catalog()
	var expected: Dictionary[IdentityDef.Dimension, Array] = {
		IdentityDef.Dimension.POPOLO: [&"pietrosangue", &"maremani", &"cinerali"],
		IdentityDef.Dimension.GOVERNO: [&"monarchia", &"repubblica", &"teocrazia"],
		IdentityDef.Dimension.CREDO: [&"culto_solare", &"spiriti_dei_luoghi", &"culto_degli_antenati", &"culto_del_vuoto"],
		IdentityDef.Dimension.CULTURA: [&"cultura_mercantile", &"cultura_guerriera", &"cultura_erudita", &"cultura_artigiana"],
	}
	for dimension: IdentityDef.Dimension in expected:
		var ids: Array[StringName] = []
		for def: IdentityDef in IdentityRules.options(catalog, dimension):
			ids.append(def.id)
		for wanted: StringName in expected[dimension]:
			assert_true(ids.has(wanted), "%s fra le opzioni" % wanted)
		assert_eq(ids.size(), expected[dimension].size(), "Numero di opzioni per %s" % IdentityDef.DIMENSION_NAMES[dimension])


func test_tipi_d_identita() -> void:
	# GDD §6.6 (v0.24): un tipo per elemento, fuori dalle categorie; le carte esclusive
	# dell'elemento lo portano, con al massimo 1 tipo d'identità per carta.
	var catalog: CatalogDef = _catalog()
	var categories: Dictionary[StringName, bool] = {}
	for advisor: AdvisorDef in catalog.advisors:
		for card_type: StringName in advisor.types:
			categories[card_type] = true
	var identity_types: Array[StringName] = IdentityRules.identity_types(catalog)
	var seen: Dictionary[StringName, bool] = {}
	for def: IdentityDef in catalog.identities:
		if def.dimension == IdentityDef.Dimension.PERK:
			continue
		assert_ne(def.identity_type, &"", "Tipo d'identità di %s" % def.id)
		assert_false(seen.has(def.identity_type), "Tipo ripetuto: %s" % def.identity_type)
		seen[def.identity_type] = true
		assert_false(categories.has(def.identity_type), "%s sta fuori dalle categorie" % def.identity_type)
		var cards: Array[Array] = []
		for card: BuildingDef in def.exclusive_buildings:
			cards.append([card.id, card.types])
		for card: TroopDef in def.exclusive_troops:
			cards.append([card.id, card.types])
		for card: Array in cards:
			var card_types: Array[StringName] = card[1]
			assert_true(card_types.has(def.identity_type), "%s porta il tipo %s" % [card[0], def.identity_type])
			var count: int = 0
			for card_type: StringName in card_types:
				if identity_types.has(card_type):
					count += 1
			assert_eq(count, 1, "Un solo tipo d'identità su %s" % card[0])
