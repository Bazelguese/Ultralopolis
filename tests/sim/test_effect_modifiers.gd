extends GutTest
## Potenziamenti su tutti i valori d'effetto e modificatori dei valori di battaglia (GDD §6.5, §8.2, v0.16).

var rules: RunRules


func before_each() -> void:
	rules = RunRules.new()


func _mod(effect: ModifierDef.Effect, amount: int, value: ModifierDef.BattleValue = ModifierDef.BattleValue.DANNO, tag: StringName = &"") -> Modifiers:
	var def: ModifierDef = ModifierDef.new()
	def.id = StringName("m_%d_%d_%d" % [effect, value, amount])
	def.effect = effect
	def.amount = amount
	def.battle_value = value
	def.target_type = tag
	def.duration_kind = ModifierDef.Duration.PERMANENTE
	var mods: Modifiers = Modifiers.new()
	mods.apply(def, ActiveModifier.OriginKind.ALTRO, "Prova", 1, NationBoard.new(), RandomNumberGenerator.new())
	return mods


func _troop() -> TroopDef:
	var def: TroopDef = TroopDef.new()
	def.cooldown_ms = 2000
	def.damage = 4
	def.shield = 2
	def.heal = 0
	def.corruption = 3
	def.siege_damage = 6
	def.inefficiency_ms = 2000
	def.sabotage_ms = 1000
	return def


func test_ogni_livello_aumenta_tutti_i_valori_d_effetto() -> void:
	var def: TroopDef = _troop()
	var level3: TroopDef = ElementStats.troop(def, null, null, 3, rules)
	assert_eq(level3.damage, 8, "+100% al livello 3.")
	assert_eq(level3.shield, 4)
	assert_eq(level3.corruption, 6)
	assert_eq(level3.siege_damage, 12)
	assert_eq(level3.inefficiency_ms, 4000, "Anche le durate.")
	assert_eq(level3.sabotage_ms, 2000)
	assert_eq(level3.cooldown_ms, 2000, "La ricarica non cambia.")
	assert_eq(def.damage, 4, "La scheda del catalogo non cambia.")


func test_livello_2_arrotonda_per_difetto() -> void:
	var def: TroopDef = _troop()
	def.damage = 3
	assert_eq(ElementStats.troop(def, null, null, 2, rules).damage, 4, "3 +50% = 4,5 → 4.")


func test_edificio_potenziato_produce_piu_effetti_ma_lo_stesso_mana() -> void:
	var def: BuildingDef = BuildingDef.new()
	def.mana_amount = 1
	def.shield = 2
	def.heal = 2
	var level2: BuildingDef = ElementStats.building(def, null, null, 2, rules)
	assert_eq(level2.shield, 3)
	assert_eq(level2.heal, 3)
	assert_eq(level2.mana_amount, 1, "Il mana prodotto non cambia.")


func test_valore_fisso_solo_per_chi_lo_ha_gia() -> void:
	var mods: Modifiers = _mod(ModifierDef.Effect.VALORE_FISSO, 1, ModifierDef.BattleValue.CURA)
	var healer: TroopDef = _troop()
	healer.heal = 5
	assert_eq(ElementStats.troop(healer, BoardPiece.of_troop(healer, 0), mods, 1, rules).heal, 6, "Chi cura cura 1 in più.")
	var other: TroopDef = _troop()
	assert_eq(ElementStats.troop(other, BoardPiece.of_troop(other, 0), mods, 1, rules).heal, 0, "Chi non cura resta a 0.")


func test_valore_percentuale_con_tipo() -> void:
	var mods: Modifiers = _mod(ModifierDef.Effect.VALORE_PERCENTUALE, 25, ModifierDef.BattleValue.ASSEDIO, &"Assedio")
	var ram: TroopDef = _troop()
	ram.siege_damage = 8
	ram.types = [&"Assedio"]
	assert_eq(ElementStats.troop(ram, BoardPiece.of_troop(ram, 0), mods, 1, rules).siege_damage, 10)
	var not_siege: TroopDef = _troop()
	not_siege.siege_damage = 8
	assert_eq(ElementStats.troop(not_siege, BoardPiece.of_troop(not_siege, 0), mods, 1, rules).siege_damage, 8)


func test_scudo_ridotto_del_50() -> void:
	var mods: Modifiers = _mod(ModifierDef.Effect.VALORE_PERCENTUALE, -50, ModifierDef.BattleValue.SCUDO)
	var def: BuildingDef = BuildingDef.new()
	def.shield = 7
	assert_eq(ElementStats.building(def, BoardPiece.of_building(def, 0), mods, 1, rules).shield, 3)


func _run_with(modifier: ModifierDef) -> RunState:
	var troop: TroopDef = TroopDef.new()
	troop.cooldown_ms = 1000
	troop.food_tenths = 5
	var building: BuildingDef = BuildingDef.new()
	building.mana_interval_ms = 1000
	var catalog: CatalogDef = CatalogDef.new()
	catalog.eras = [EraDef.new()]
	var run_rules: RunRules = RunRules.new()
	run_rules.starting_buildings = [building]
	run_rules.starting_troops = [troop, troop]
	run_rules.prototype_years = 0
	var run: RunState = RunState.new(catalog, run_rules, BattleRules.new(), ResistanceRules.new(), 1)
	run.modifiers.apply(modifier, ActiveModifier.OriginKind.FANTASMA, "Prova", 0, run.board, RandomNumberGenerator.new())
	return run


func test_corruzione_e_sabotaggio_a_inizio_scontro() -> void:
	var seeds: ModifierDef = ModifierDef.new()
	seeds.id = &"semi"
	seeds.effect = ModifierDef.Effect.CORRUZIONE_INIZIALE
	seeds.amount = 5
	var run: RunState = _run_with(seeds)
	var net: ModifierDef = ModifierDef.new()
	net.id = &"rete"
	net.effect = ModifierDef.Effect.SABOTAGGIO_INIZIALE
	net.amount = 3000
	run.modifiers.apply(net, ActiveModifier.OriginKind.FANTASMA, "Prova", 0, run.board, RandomNumberGenerator.new())
	while run.phase != RunState.Phase.SCONTRO_FANTASMA:
		run.pass_opportunity()
	run.fight_ghost()
	var setup: BattleSideSetup = run.last_battle_setups()[0]
	assert_eq(setup.start_corruption, 5)
	assert_eq(setup.start_building_sabotage_ms, 3000)
	var replay: BattleSim = run.make_battle_replay()
	assert_eq(replay.get_corruption(BattleSim.SIDE_A), 5)
	assert_eq(replay.get_building_sabotage_ms(BattleSim.SIDE_A, 0), 3000)


func test_diserzioni_una_truppa_consuma_il_doppio() -> void:
	var desertion: ModifierDef = ModifierDef.new()
	desertion.id = &"diserzioni"
	desertion.effect = ModifierDef.Effect.CIBO_TRUPPA
	desertion.amount = 100
	desertion.target = ModifierDef.Target.TRUPPA_A_CASO
	var run: RunState = _run_with(desertion)
	var target: BoardPiece = run.modifiers.active[0].target_piece
	assert_eq(run.troop_ration(target), 10, "1 Cibo invece di 0,5.")
	var other: BoardPiece = run.board.troops[0] if run.board.troops[0] != target else run.board.troops[1]
	assert_eq(run.troop_ration(other), 5)
