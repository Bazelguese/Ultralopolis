extends GutTest
## Risorse, mercato, Cibo, Capitale, mana a colori, potenziamenti ed etichette (GDD v0.12).
## Numeri solo di prova.

var capital: BuildingDef
var farm: BuildingDef
var slow: TroopDef
var fast: TroopDef
var catalog: CatalogDef
var run_rules: RunRules
var resistance_rules: ResistanceRules


func before_each() -> void:
	capital = BuildingDef.new()
	capital.id = &"capitale"
	capital.display_name = "Capitale"
	capital.is_capital = true
	capital.tags = [&"Capitale"]
	for field: String in ["gold_per_phase", "research_per_phase", "food_per_phase", "wood_per_phase", "stone_per_phase", "iron_per_phase", "faith_per_phase", "influence_per_phase", "stability_per_phase", "documents_per_phase"]:
		capital.set(field, 1)
	farm = BuildingDef.new()
	farm.id = &"fattoria"
	farm.display_name = "Fattoria"
	farm.tags = [&"Agricolo"]
	farm.food_per_phase = 2
	farm.cost_gold = 3
	var cost: ResourceAmounts = ResourceAmounts.new()
	cost.legno = 2
	farm.upgrade_costs = [cost]
	slow = TroopDef.new()
	slow.id = &"lenta"
	slow.display_name = "Lenta"
	slow.cooldown_ms = 3000
	slow.damage = 10
	slow.tags = [&"Fanteria"]
	fast = TroopDef.new()
	fast.id = &"veloce"
	fast.display_name = "Veloce"
	fast.cooldown_ms = 1000
	fast.damage = 4
	fast.tags = [&"Cavalleria"]
	var iron: ResourceAmounts = ResourceAmounts.new()
	iron.ferro = 2
	var more_iron: ResourceAmounts = ResourceAmounts.new()
	more_iron.ferro = 4
	fast.upgrade_costs = [iron, more_iron]

	catalog = CatalogDef.new()
	catalog.buildings = [farm]
	catalog.troops = [slow, fast]
	catalog.eras = [EraDef.new()]
	var opportunity: OpportunityDef = OpportunityDef.new()
	opportunity.kind = OpportunityDef.Kind.SCAMBIO_RISORSE
	catalog.opportunities = [opportunity]
	run_rules = RunRules.new()
	run_rules.starting_gold = 0
	run_rules.prototype_years = 0
	run_rules.starting_buildings = [capital]
	run_rules.starting_troops = [fast, slow]
	resistance_rules = ResistanceRules.new()
	resistance_rules.per_era = [10]
	resistance_rules.per_year = 0
	resistance_rules.per_building = 0
	resistance_rules.per_troop = 0


func _new_run() -> RunState:
	return RunState.new(catalog, run_rules, BattleRules.new(), resistance_rules, 1)


func _finish_year(run: RunState) -> void:
	while run.phase != RunState.Phase.SCONTRO_FANTASMA:
		run.pass_opportunity()
	run.fight_ghost()


# --- Risorse e Capitale ---------------------------------------------------------

func test_la_capitale_produce_un_po_di_tutto() -> void:
	var run: RunState = _new_run()
	for type: Res.Type in Res.NAMES:
		assert_eq(run.stock[type], 1 * Res.scale(type), "1 %s dalla Capitale" % Res.NAMES[type])
	assert_eq(run.stock_text(Res.Type.CIBO), "1")


func test_la_capitale_non_si_vende_ne_si_sostituisce() -> void:
	var run: RunState = _new_run()
	assert_false(run.sell_building(0))
	assert_false(run.board.can_replace_building(0, farm))


func test_formato_del_cibo() -> void:
	assert_eq(Res.format(Res.Type.CIBO, 35), "3,5")
	assert_eq(Res.format(Res.Type.CIBO, 40), "4")
	assert_eq(Res.format(Res.Type.FERRO, 7), "7")


# --- Mercato --------------------------------------------------------------------

func test_mercato_a_tasso_fisso() -> void:
	var run: RunState = _new_run()
	run.stock[Res.Type.FERRO] = 5
	assert_false(run.sell_resource(Res.Type.FERRO, 3), "Si vende a gruppi di 2.")
	assert_true(run.sell_resource(Res.Type.FERRO, 4))
	assert_eq(run.stock[Res.Type.FERRO], 1)
	assert_eq(run.gold, 1 + 2, "1 Oro della Capitale + 2 dalla vendita.")
	assert_false(run.sell_resource(Res.Type.FERRO, 2), "Ferro insufficiente.")
	assert_false(run.sell_resource(Res.Type.ORO, 2), "L'Oro non si vende.")
	assert_eq(run.opportunity_number, 1, "Il mercato non consuma l'opportunità.")


func test_mercato_del_cibo_in_unita_intere() -> void:
	var run: RunState = _new_run()
	run.stock[Res.Type.CIBO] = 25
	assert_true(run.sell_resource(Res.Type.CIBO, 2))
	assert_eq(run.stock_text(Res.Type.CIBO), "0,5")


# --- Cibo (GDD §5.4) ---------------------------------------------------------------

func test_nel_primo_anno_non_si_mangia() -> void:
	var run: RunState = _new_run()
	assert_eq(run.stock[Res.Type.CIBO], 10, "Il Cibo della Capitale resta intatto.")
	for piece: BoardPiece in run.board.troops:
		assert_false(piece.hungry)


func test_mangiano_prima_le_truppe_piu_lente() -> void:
	capital.food_per_phase = 0
	var run: RunState = _new_run()
	run.stock[Res.Type.CIBO] = 5  # mezza razione: basta per una truppa
	_finish_year(run)
	assert_eq(run.year, 2)
	var fast_piece: BoardPiece = run.board.troops[0]
	var slow_piece: BoardPiece = run.board.troops[1]
	assert_false(slow_piece.hungry, "La lenta mangia per prima.")
	assert_true(fast_piece.hungry, "La veloce resta senza cibo.")
	assert_eq(run.stock[Res.Type.CIBO], 0)
	assert_eq(run.effective_troop(fast_piece).cooldown_ms, 1500, "Ricarica ×1,5.")
	assert_eq(run.effective_troop(slow_piece).cooldown_ms, 3000)


func test_a_parita_mangia_prima_la_truppa_piu_a_destra() -> void:
	capital.food_per_phase = 0
	run_rules.starting_troops = [slow, slow]
	var run: RunState = _new_run()
	run.stock[Res.Type.CIBO] = 5
	_finish_year(run)
	assert_true(run.board.troops[0].hungry)
	assert_false(run.board.troops[1].hungry, "La più a destra mangia.")


func test_razione_intera_o_niente_e_avanzo_alla_successiva() -> void:
	capital.food_per_phase = 0
	var greedy: TroopDef = slow.duplicate() as TroopDef
	greedy.food_tenths = 20  # 2 Cibo
	run_rules.starting_troops = [fast, greedy]
	var run: RunState = _new_run()
	run.stock[Res.Type.CIBO] = 15  # 1,5 Cibo: non basta alla lenta, basta alla veloce
	_finish_year(run)
	assert_true(run.board.troops[1].hungry, "La lenta non riceve una razione parziale.")
	assert_false(run.board.troops[0].hungry, "L'avanzo va alla veloce.")
	assert_eq(run.stock[Res.Type.CIBO], 10)


func test_la_fame_dura_fino_all_anno_dopo() -> void:
	capital.food_per_phase = 0
	var run: RunState = _new_run()
	run.stock[Res.Type.CIBO] = 0
	_finish_year(run)
	assert_true(run.board.troops[0].hungry)
	run.stock[Res.Type.CIBO] = 100
	_finish_year(run)
	assert_false(run.board.troops[0].hungry, "Con il cibo dell'anno 3 torna sazia.")


func test_le_truppe_reclutate_durante_l_anno_sono_sazie() -> void:
	var run: RunState = _new_run()
	run.board.troops.append(BoardPiece.of_troop(slow, 0))
	assert_false(run.board.troops[2].hungry)


# --- Mana a colori (GDD §5.3) ---------------------------------------------------------

func _building(color: StringName, amount: int) -> BuildingDef:
	var def: BuildingDef = BuildingDef.new()
	def.mana_type = color
	def.mana_amount = amount
	def.mana_interval_ms = 1000
	return def


func _troop(color: StringName, cost: int) -> TroopDef:
	var def: TroopDef = TroopDef.new()
	def.mana_type = color
	def.mana_cost = cost
	def.cooldown_ms = 1000
	def.damage = 1
	return def


func test_ogni_truppa_paga_il_suo_colore() -> void:
	var side: BattleSideSetup = BattleSideSetup.new([_building(BattleSim.MANA_VERDE, 2)], [_troop(BattleSim.MANA_ROSSO, 2)], 100)
	var sim: BattleSim = BattleSim.new(BattleRules.new(), side, BattleSideSetup.new([], [], 1000))
	for i: int in range(10):
		sim.step()
	assert_eq(sim.get_troop_state(BattleSim.SIDE_A, 0), BattleSim.TroopState.IN_ATTESA_DI_MANA, "Il verde non paga il rosso.")
	assert_eq(sim.get_mana(BattleSim.SIDE_A, BattleSim.MANA_VERDE), 2)


func test_l_energetico_vale_come_qualsiasi_colore_e_si_usa_per_ultimo() -> void:
	var side: BattleSideSetup = BattleSideSetup.new(
		[_building(BattleSim.MANA_ROSSO, 1), _building(BattleSim.MANA_ENERGETICO, 2)],
		[_troop(BattleSim.MANA_ROSSO, 2)], 100)
	var sim: BattleSim = BattleSim.new(BattleRules.new(), side, BattleSideSetup.new([], [], 1000))
	for i: int in range(10):
		sim.step()
	assert_eq(sim.get_troop_state(BattleSim.SIDE_A, 0), BattleSim.TroopState.IN_RICARICA, "Si attiva con 1 rosso + 1 energetico.")
	assert_eq(sim.get_mana(BattleSim.SIDE_A, BattleSim.MANA_ROSSO), 0, "Prima si spende il rosso.")
	assert_eq(sim.get_mana(BattleSim.SIDE_A, BattleSim.MANA_ENERGETICO), 1, "Poi l'energetico, solo quanto serve.")


# --- Potenziamenti (GDD §6.5) ------------------------------------------------------

func test_potenziare_una_truppa() -> void:
	var run: RunState = _new_run()
	var piece: BoardPiece = run.board.troops[0]
	assert_false(run.upgrade_troop(0), "Serve Ferro.")
	run.stock[Res.Type.FERRO] = 6
	assert_true(run.upgrade_troop(0))
	assert_eq(piece.level, 2)
	assert_eq(run.effective_troop(piece).damage, 6, "4 danni +50%.")
	assert_true(run.upgrade_troop(0))
	assert_eq(piece.level, 3)
	assert_eq(run.effective_troop(piece).damage, 8)
	assert_eq(run.stock[Res.Type.FERRO], 0)
	assert_false(run.upgrade_troop(0), "Livello massimo.")


func test_potenziare_un_edificio() -> void:
	var run: RunState = _new_run()
	run.board.buildings.append(BoardPiece.of_building(farm, 3))
	run.stock[Res.Type.LEGNO] = 2
	assert_true(run.upgrade_building(1))
	var produced: Array[int] = run.building_production(run.board.buildings[1])
	assert_eq(produced[Res.Type.CIBO], 30, "2 Cibo +1 per il livello 2, in decimi.")
	assert_null(run.upgrade_cost_of(run.board.buildings[1]), "Non ci sono altri livelli nei dati.")


func test_elementi_senza_costi_non_si_potenziano() -> void:
	var run: RunState = _new_run()
	assert_null(run.upgrade_cost_of(run.board.troops[1]))
	assert_false(run.upgrade_troop(1))


# --- Etichette (GDD §6.6) ------------------------------------------------------------

func test_un_modificatore_con_etichetta_vale_solo_per_quell_etichetta() -> void:
	var run: RunState = _new_run()
	var bonus: ModifierDef = ModifierDef.new()
	bonus.id = &"cavalleria_rapida"
	bonus.is_malus = false
	bonus.effect = ModifierDef.Effect.RICARICA_TRUPPA
	bonus.amount = -50
	bonus.target_tag = &"Cavalleria"
	bonus.duration_kind = ModifierDef.Duration.PERMANENTE
	run.modifiers.apply(bonus, ActiveModifier.OriginKind.ALTRO, "Prova", run.year, run.board, RandomNumberGenerator.new())
	assert_eq(run.effective_troop(run.board.troops[0]).cooldown_ms, 500, "La Cavalleria accelera.")
	assert_eq(run.effective_troop(run.board.troops[1]).cooldown_ms, 3000, "La Fanteria no.")


func test_produzione_extra_per_gli_edifici_con_etichetta() -> void:
	var run: RunState = _new_run()
	var bonus: ModifierDef = ModifierDef.new()
	bonus.id = &"capitale_ricca"
	bonus.is_malus = false
	bonus.effect = ModifierDef.Effect.PRODUZIONE_PER_EDIFICIO
	bonus.resource = Res.Type.FEDE
	bonus.amount = 2
	bonus.target_tag = &"Capitale"
	bonus.duration_kind = ModifierDef.Duration.PERMANENTE
	run.modifiers.apply(bonus, ActiveModifier.OriginKind.ALTRO, "Prova", run.year, run.board, RandomNumberGenerator.new())
	assert_eq(run.production_per_phase()[Res.Type.FEDE], 3, "1 di base + 2 sulla Capitale.")
