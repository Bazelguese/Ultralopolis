extends GutTest
## Verifiche delle tradizioni delle vie e delle ascensioni (GDD §10.4.1, §10.4.2, §17; v0.27).
## I numeri qui servono solo ai test e non sono valori di gioco.

const Aiuti = preload("res://tests/sim/aiuti_consiglio.gd")

var catalog: CatalogDef
var rules: RunRules
var way: IdentityDef
var second_way: IdentityDef
var win_step: TraditionDef
var cards_step: TraditionDef
var slot_step: TraditionDef
var gold_step: TraditionDef
var fante: TroopDef
var level1: Array[IdentityDef] = []
var level2: Array[IdentityDef] = []


func _deed(kind: DeedDef.Kind, amount: int) -> DeedDef:
	var deed: DeedDef = DeedDef.new()
	deed.kind = kind
	deed.amount = amount
	return deed


func _step(id: StringName, deed: DeedDef) -> TraditionDef:
	var step: TraditionDef = TraditionDef.new()
	step.id = id
	step.display_name = String(id)
	step.deed = deed
	return step


func _ascension(id: StringName, level: int, rule: IdentityDef.Rule = IdentityDef.Rule.NESSUNA) -> IdentityDef:
	var def: IdentityDef = IdentityDef.new()
	def.id = id
	def.display_name = String(id)
	def.dimension = IdentityDef.Dimension.ASCENSIONE
	def.ascension_level = level
	def.rule = rule
	return def


func before_each() -> void:
	win_step = _step(&"vittorie", _deed(DeedDef.Kind.VITTORIE, 1))
	var cards: DeedDef = _deed(DeedDef.Kind.CARTE, 2)
	cards.types = [&"Fante"]
	cards_step = _step(&"carte", cards)
	var resistance: ModifierDef = ModifierDef.new()
	resistance.id = &"resistenza_passo"
	resistance.effect = ModifierDef.Effect.RESISTENZA
	resistance.amount = 4
	resistance.is_malus = false
	resistance.duration_kind = ModifierDef.Duration.PERMANENTE
	cards_step.permanent_modifiers = [resistance]
	slot_step = _step(&"spazio", _deed(DeedDef.Kind.MALCONTENTO_MASSIMO, 5))
	slot_step.extra_troop_slots = 1
	gold_step = _step(&"oro", _deed(DeedDef.Kind.PRODUZIONE, 3))
	way = IdentityDef.new()
	way.id = &"via"
	way.display_name = "Via di prova"
	way.dimension = IdentityDef.Dimension.VIA
	way.traditions = [win_step, cards_step, slot_step, gold_step]
	second_way = IdentityDef.new()
	second_way.id = &"via2"
	second_way.display_name = "Seconda via"
	second_way.dimension = IdentityDef.Dimension.VIA
	second_way.traditions = [_step(&"x", _deed(DeedDef.Kind.MALCONTENTO_MASSIMO, 5))]

	level1 = [_ascension(&"a1", 1), _ascension(&"b1", 1), _ascension(&"c1", 1), _ascension(&"d1", 1)]
	level2 = [_ascension(&"natura", 2, IdentityDef.Rule.SECONDA_NATURA), _ascension(&"maestria", 2, IdentityDef.Rule.MAESTRIA),
			_ascension(&"frugale", 2, IdentityDef.Rule.ESERCITO_FRUGALE)]

	fante = TroopDef.new()
	fante.id = &"fante"
	fante.display_name = "Fante"
	fante.types = [&"Fante"]
	fante.cooldown_ms = 1000
	fante.damage = 2
	var era1: EraDef = EraDef.new()
	catalog = CatalogDef.new()
	catalog.eras = [era1]
	catalog.troops = [fante]
	catalog.ascensions = level1 + level2
	rules = RunRules.new()
	rules.prototype_years = 0
	rules.starting_gold = 0
	rules.starting_buildings = []
	rules.starting_troops = []
	Aiuti.consiglio_semplice(catalog, rules)


func _run() -> RunState:
	return RunState.new(catalog, rules, BattleRules.new(), ResistanceRules.new(), 3)


func _adopt(run: RunState, def: IdentityDef) -> void:
	run._adopt_identity(def)
	run._check_traditions()


# --- Passi e imprese (GDD §10.4.1) ---------------------------------------------------

func test_un_traguardo_conta_solo_dopo_l_adozione() -> void:
	var run: RunState = _run()
	run._note_deed(DeedDef.Kind.VITTORIE, &"fantasma")
	_adopt(run, way)
	assert_false(run.traditions_done.has(win_step), "La vittoria di prima non conta.")
	assert_eq(run.tradition_progress_text(win_step), "0/1")
	run._note_deed(DeedDef.Kind.VITTORIE, &"incontro")
	run._check_traditions()
	assert_true(run.traditions_done.has(win_step), "Dopo l'adozione la vittoria conta.")


func test_un_impresa_di_stato_si_completa_appena_e_vera_e_da_il_suo_effetto() -> void:
	var run: RunState = _run()
	_adopt(run, way)
	run.board.base_troop_slots = 5
	run.board.troops.append(BoardPiece.of_troop(fante, 0))
	run._check_traditions()
	assert_false(run.traditions_done.has(cards_step), "Una carta Fante non basta.")
	assert_eq(run.tradition_progress_text(cards_step), "1/2")
	run.board.troops.append(BoardPiece.of_troop(fante, 0))
	run._check_traditions()
	assert_true(run.traditions_done.has(cards_step))
	assert_eq(run.modifiers.flat(ModifierDef.Effect.RESISTENZA), 4, "L'effetto vale subito: +4 Resistenza.")
	var origin_ok: bool = false
	for modifier: ActiveModifier in run.modifiers.active:
		if modifier.origin_kind == ActiveModifier.OriginKind.TRADIZIONE:
			origin_ok = true
	assert_true(origin_ok, "L'origine è la tradizione.")


func test_malcontento_a_fine_anno_e_produzione() -> void:
	var run: RunState = _run()
	_adopt(run, way)
	assert_false(run.traditions_done.has(slot_step), "Il Malcontento si guarda a fine anno.")
	var slots: int = run.board.troop_capacity()
	run._check_traditions(true)
	assert_true(run.traditions_done.has(slot_step))
	assert_eq(run.board.troop_capacity(), slots + 1)
	var collected: Array[int] = Res.empty()
	collected[Res.Type.ORO] = 2
	run._note_production(collected)
	run._check_traditions()
	assert_false(run.traditions_done.has(gold_step))
	collected[Res.Type.ORO] = 3
	run._note_production(collected)
	run._check_traditions()
	assert_true(run.traditions_done.has(gold_step), "Una produzione di 3 Oro basta.")


# --- Ascensioni (GDD §10.4.2) ------------------------------------------------------

func _complete_tree(run: RunState) -> void:
	_adopt(run, way)
	run.board.base_troop_slots = 5
	run.board.troops.append(BoardPiece.of_troop(fante, 0))
	run.board.troops.append(BoardPiece.of_troop(fante, 0))
	run._note_deed(DeedDef.Kind.VITTORIE, &"fantasma")
	var collected: Array[int] = Res.empty()
	collected[Res.Type.ORO] = 3
	run._note_production(collected)
	run._check_traditions(true)


func test_albero_completo_ascensione_di_livello_1_poi_di_livello_2() -> void:
	var run: RunState = _run()
	_complete_tree(run)
	assert_eq(run.ascension_choices.size(), 3, "Si sceglie fra 3.")
	for def: IdentityDef in run.ascension_choices:
		assert_eq(def.ascension_level, 1, "La prima ascensione è di livello 1.")
	assert_false(run.pass_round(), "Prima si sceglie l'ascensione.")
	var chosen: IdentityDef = run.ascension_choices[0]
	assert_true(run.choose_ascension(0))
	assert_true(run.identity.has(chosen))
	assert_true(run.ascension_choices.is_empty())
	_adopt(run, second_way)
	run._check_traditions(true)
	assert_eq(run.ascension_choices.size(), 3)
	for def: IdentityDef in run.ascension_choices:
		assert_eq(def.ascension_level, 2, "La seconda è di livello 2.")
		assert_ne(def, chosen, "Un'ascensione presa non si ripresenta.")


func test_seconda_natura_due_incanti() -> void:
	var spell: OpportunityDef = OpportunityDef.new()
	spell.id = &"furia"
	spell.kind = OpportunityDef.Kind.INCANTO
	spell.enchant_value = ModifierDef.BattleValue.DANNO
	spell.enchant_amounts = PackedInt32Array([3])
	spell.enchant_mana = 2
	spell.enchant_color = &"rosso"
	var run: RunState = _run()
	var piece: BoardPiece = BoardPiece.of_troop(fante, 0)
	run.board.troops = [piece]
	piece.enchant = spell
	piece.enchant_amount = 3
	assert_true(run._enchantable_troops().is_empty(), "Senza l'ascensione una volta sola.")
	run.identity.append(level2[0])
	assert_eq(run._enchantable_troops().size(), 1, "Con Seconda natura si incanta di nuovo.")
	piece.second_enchant = spell
	piece.second_enchant_amount = 3
	var troop: TroopDef = run.effective_troop(piece)
	assert_eq(troop.damage, 2 + 3 + 3, "Due effetti.")
	assert_eq(troop.mana_cost, 4, "Due volte il mana dell'incanto.")
	assert_true(run._enchantable_troops().is_empty(), "Non una terza volta.")


func test_maestria_livello_4() -> void:
	var run: RunState = _run()
	assert_eq(run.max_level(), 3)
	run.identity.append(level2[1])
	assert_eq(run.max_level(), 4)
	var piece: BoardPiece = BoardPiece.of_troop(fante, 0)
	piece.level = 3
	run.chosen_advisor = catalog.advisors[0]
	var cost: ResourceAmounts = run.upgrade_cost_of(piece)
	assert_not_null(cost, "Si potenzia al livello 4.")
	assert_eq(cost.internal(catalog.advisors[0].upgrade_resource), 4, "4 × era 1.")


func test_esercito_frugale() -> void:
	var run: RunState = _run()
	var piece: BoardPiece = BoardPiece.of_troop(fante, 0)
	piece.hungry = true
	assert_eq(run.effective_troop(piece).cooldown_ms, 1500, "Senza Cibo la ricarica dura una volta e mezza.")
	run.identity.append(level2[2])
	assert_eq(run.effective_troop(piece).cooldown_ms, 1000, "Con Esercito frugale non rallenta.")


func test_doppio_ascolto() -> void:
	var collectors: OpportunityDef = OpportunityDef.new()
	collectors.id = &"esattori"
	collectors.kind = OpportunityDef.Kind.SCAMBIO_RISORSE
	collectors.gain_gold = 1
	var tribute: OpportunityDef = OpportunityDef.new()
	tribute.id = &"tributo"
	tribute.kind = OpportunityDef.Kind.SCAMBIO_RISORSE
	tribute.gain_gold = 2
	Aiuti.consiglio_semplice(catalog, rules, [collectors, tribute])
	rules.set_all_season_themes(PackedInt32Array([RunState.RoundTheme.AZIONI, RunState.RoundTheme.AZIONI]))
	var run: RunState = _run()
	run.identity.append(_ascension(&"doppio", 2, IdentityDef.Rule.DOPPIO_ASCOLTO))
	Aiuti.ascolta(run)
	var round_before: int = run.round_number
	var offers_before: int = run.offers.size()
	assert_true(run.buy_offer(0))
	assert_eq(run.round_number, round_before, "Il round resta aperto.")
	assert_eq(run.offers.size(), offers_before - 1, "La proposta presa sparisce.")
	assert_true(run.buy_offer(0))
	assert_ne(run.round_number, round_before, "Dopo la seconda proposta il round si chiude.")
	Aiuti.ascolta(run)
	var round_now: int = run.round_number
	assert_true(run.buy_offer(0))
	assert_ne(run.round_number, round_now, "Una volta sola per stagione.")


# --- Regole della battaglia (GDD §10.4.2) ---------------------------------------------

func _battle_rules() -> BattleRules:
	var battle: BattleRules = BattleRules.new()
	battle.tick_ms = 100
	return battle


func _troop(mana_type: StringName, mana_cost: int, cooldown_ms: int, damage: int) -> TroopDef:
	var troop: TroopDef = TroopDef.new()
	troop.id = &"truppa"
	troop.mana_type = mana_type
	troop.mana_cost = mana_cost
	troop.cooldown_ms = cooldown_ms
	troop.damage = damage
	return troop


func _building(mana_type: StringName, amount: int, interval_ms: int) -> BuildingDef:
	var building: BuildingDef = BuildingDef.new()
	building.id = &"edificio"
	building.mana_type = mana_type
	building.mana_amount = amount
	building.mana_interval_ms = interval_ms
	return building


func test_ultima_trincea() -> void:
	var weak: BattleSideSetup = BattleSideSetup.new([], [], 5)
	weak.last_stand = true
	var strong: BattleSideSetup = BattleSideSetup.new([], [_troop(&"rosso", 0, 1000, 10)], 1000)
	var sim: BattleSim = BattleSim.new(_battle_rules(), weak, strong)
	while sim.elapsed_ms < 1000:
		sim.step()
	assert_eq(sim.outcome, BattleSim.Outcome.IN_CORSO, "Il primo colpo mortale non basta.")
	assert_eq(sim.get_resistance(BattleSim.SIDE_A), 1, "La Resistenza torna a 1.")
	var saved: bool = false
	for event: BattleEvent in sim.events:
		if event.kind == BattleEvent.Kind.ULTIMA_TRINCEA:
			saved = true
	assert_true(saved, "Il salvataggio si vede fra i fatti dello scontro (P4).")
	assert_eq(sim.run_to_end(), BattleSim.Outcome.VITTORIA_B, "La seconda volta lo scontro è perso.")
	var corrupted: BattleSideSetup = BattleSideSetup.new([], [], 5)
	corrupted.last_stand = true
	corrupted.start_corruption = 5
	var sim2: BattleSim = BattleSim.new(_battle_rules(), corrupted, BattleSideSetup.new([], [], 1000))
	sim2.step()
	assert_eq(sim2.outcome, BattleSim.Outcome.VITTORIA_B, "Non salva dalla Corruzione.")


func test_prima_scintilla() -> void:
	var side: BattleSideSetup = BattleSideSetup.new([_building(&"rosso", 1, 2000)], [], 100)
	side.first_spark = true
	var sim: BattleSim = BattleSim.new(_battle_rules(), side, BattleSideSetup.new([], [], 100))
	assert_eq(sim.get_building_production_left_ms(BattleSim.SIDE_A, 0), 1000, "L'intervallo parte a metà.")


func test_disciplina_ferrea() -> void:
	# Truppa costosa a destra, economica a sinistra e una senza mana in mezzo.
	var troops: Array[TroopDef] = [_troop(&"rosso", 1, 100, 1), _troop(&"rosso", 0, 100, 1), _troop(&"rosso", 5, 100, 1)]
	var side: BattleSideSetup = BattleSideSetup.new([_building(&"rosso", 1, 100)], troops, 1000)
	side.reserve_mana = true
	var sim: BattleSim = BattleSim.new(_battle_rules(), side, BattleSideSetup.new([], [], 100000))
	sim.step()
	sim.step()
	assert_eq(sim.get_troop_state(BattleSim.SIDE_A, 0), BattleSim.TroopState.MANA_PRENOTATO, "L'economica aspetta: il mana è prenotato.")
	assert_gt(sim.get_mana(BattleSim.SIDE_A, &"rosso"), 0, "Il mana resta per la truppa più a destra.")
	var free_troop_active: bool = false
	for event: BattleEvent in sim.events:
		if event.kind == BattleEvent.Kind.ATTIVAZIONE and event.index == 1:
			free_troop_active = true
	assert_true(free_troop_active, "La truppa senza mana si attiva comunque.")


func test_mana_unito() -> void:
	var side: BattleSideSetup = BattleSideSetup.new([_building(&"verde", 2, 100)], [_troop(&"rosso", 2, 100, 3)], 1000)
	var sim: BattleSim = BattleSim.new(_battle_rules(), side, BattleSideSetup.new([], [], 100000))
	sim.step()
	assert_eq(sim.get_troop_state(BattleSim.SIDE_A, 0), BattleSim.TroopState.IN_ATTESA_DI_MANA, "Senza Mana unito il verde non paga il rosso.")
	side.any_color = true
	var united: BattleSim = BattleSim.new(_battle_rules(), side, BattleSideSetup.new([], [], 100000))
	united.step()
	assert_eq(united.get_mana(BattleSim.SIDE_A, &"verde"), 0, "Con Mana unito paga con il verde.")


# --- Fantasmi e dati veri (§16.3, Catalogo §4.4 e §4.5) ------------------------------------

func test_i_fantasmi_generati_hanno_passi_e_ascensioni() -> void:
	var era2: EraDef = EraDef.new()
	era2.ways = [way]
	var era3: EraDef = EraDef.new()
	era3.ways = [second_way]
	catalog.eras = [EraDef.new(), era2, era3]
	var generator: GeneratorRules = GeneratorRules.new()
	generator.years_per_era = 1
	var ghost: GhostDef = OpponentGenerator.generate_ghost(catalog, generator, rules, 3, 9)
	assert_eq(ghost.era, 3)
	for step: TraditionDef in way.traditions:
		assert_true(ghost.traditions.has(step), "Tutti i passi della via dell'era passata.")
	var found: int = 0
	for def: IdentityDef in ghost.identity:
		if def.dimension == IdentityDef.Dimension.ASCENSIONE:
			found += 1
			assert_eq(def.ascension_level, 1)
	assert_eq(found, 1, "Un'ascensione per l'albero completo.")


func test_il_catalogo_delle_tradizioni_rispetta_le_regole() -> void:
	var real: CatalogDef = load("res://data/catalog/catalog.tres")
	var advisor_ids: Array[StringName] = []
	for advisor: AdvisorDef in real.advisors:
		advisor_ids.append(advisor.id)
	var ways: int = 0
	for era_def: EraDef in real.eras:
		for def: IdentityDef in era_def.ways:
			ways += 1
			assert_eq(def.traditions.size(), 4, "%s: 4 passi." % def.display_name)
			for step: TraditionDef in def.traditions:
				assert_not_null(step.deed, "Impresa di %s." % step.display_name)
				assert_ne(step.description, "", "Effetto di %s." % step.display_name)
				var effects: int = step.permanent_modifiers.size() + (1 if step.extra_building_slots + step.extra_troop_slots > 0 else 0)
				assert_eq(effects, 1, "Un effetto per %s." % step.display_name)
				if step.deed.kind == DeedDef.Kind.PROPOSTE:
					assert_true(advisor_ids.has(step.deed.advisor_id), "Consigliere esistente per %s." % step.display_name)
	assert_eq(ways, 9, "Le 9 vie del prototipo.")
	var by_level: Dictionary = {1: 0, 2: 0}
	var rules_seen: Array[int] = []
	for def: IdentityDef in real.ascensions:
		assert_eq(def.dimension, IdentityDef.Dimension.ASCENSIONE)
		by_level[def.ascension_level] = by_level.get(def.ascension_level, 0) + 1
		if def.ascension_level == 2:
			assert_ne(def.rule, IdentityDef.Rule.NESSUNA, "%s cambia una regola." % def.display_name)
			assert_false(rules_seen.has(def.rule), "Una regola per ascensione.")
			rules_seen.append(def.rule)
	assert_eq(by_level[1], 6, "6 ascensioni del livello 1.")
	assert_eq(by_level[2], 8, "8 ascensioni del livello 2.")
