extends GutTest
## Mantenimento delle carte (GDD §5.6, v0.28). Numeri solo di prova.

const Aiuti = preload("res://tests/sim/aiuti_consiglio.gd")

var catalog: CatalogDef
var rules: RunRules
var resistance_rules: ResistanceRules
var soldiers: TroopDef
var monks: TroopDef
var walls: BuildingDef
var guards: TroopDef
var race: IdentityDef
var general: AdvisorDef
var priest: AdvisorDef


func _troop(id: StringName, types: Array[StringName]) -> TroopDef:
	var def: TroopDef = TroopDef.new()
	def.id = id
	def.display_name = String(id).capitalize()
	def.types = types
	def.cooldown_ms = 1000
	def.food_tenths = 0
	def.damage = 1
	return def


func before_each() -> void:
	soldiers = _troop(&"fanti", [&"Fante"])
	monks = _troop(&"monaci", [&"Spirituale"])
	guards = _troop(&"guardie", [&"Pietrosangue", &"Fante"])
	walls = BuildingDef.new()
	walls.id = &"mura"
	walls.display_name = "Mura"
	walls.types = [&"Fante"]
	walls.mana_interval_ms = 2000
	race = IdentityDef.new()
	race.id = &"razza"
	race.dimension = IdentityDef.Dimension.POPOLO
	race.identity_type = &"Pietrosangue"
	race.exclusive_troops = [guards]
	general = Aiuti.consigliere(&"generale", [&"Fante"], [], Res.Type.FERRO)
	priest = Aiuti.consigliere(&"sacerdote", [&"Spirituale"], [], Res.Type.FEDE)
	catalog = CatalogDef.new()
	catalog.buildings = [walls]
	catalog.troops = [soldiers, monks]
	catalog.eras = [EraDef.new()]
	catalog.identities = [race]
	catalog.advisors = [general, priest]
	rules = RunRules.new()
	rules.prototype_years = 0
	rules.starting_buildings = [walls]
	rules.starting_troops = [soldiers, monks, guards]
	rules.starting_perks = 0
	resistance_rules = ResistanceRules.new()
	resistance_rules.per_era = [10]
	resistance_rules.per_year = 0
	resistance_rules.per_building = 0
	resistance_rules.per_troop = 0


func _run() -> RunState:
	var run: RunState = RunState.new(catalog, rules, BattleRules.new(), resistance_rules, 3)
	assert_true(run.found_nation("Prova", [race]), run.last_error)
	for type: Res.Type in Res.NAMES:
		run.stock[type] = 0
	return run


func test_pagano_le_carte_potenziate_e_quelle_speciali() -> void:
	var run: RunState = _run()
	var fanti: BoardPiece = run.board.troops[0]
	var monaci: BoardPiece = run.board.troops[1]
	var guardie: BoardPiece = run.board.troops[2]
	assert_null(run.upkeep_of(fanti), "Una carta base al livello 1 non paga.")
	fanti.level = 3
	assert_eq(run.upkeep_of(fanti).whole(Res.Type.FERRO), 2, "Livello 3: 2 unità della risorsa del Generale (Fante).")
	monaci.level = 2
	assert_eq(run.upkeep_of(monaci).whole(Res.Type.FEDE), 1, "Spirituale: Fede.")
	assert_eq(run.upkeep_of(guardie).whole(Res.Type.FERRO), 1, "Esclusiva della razza: carta speciale; il tipo d'identità si salta.")
	assert_true(run.is_special_card(guards))
	assert_false(run.is_special_card(soldiers))


func test_si_paga_da_destra_e_chi_resta_senza_e_trascurato() -> void:
	var run: RunState = _run()
	var fanti: BoardPiece = run.board.troops[0]
	var guardie: BoardPiece = run.board.troops[2]
	fanti.level = 2
	run.stock[Res.Type.FERRO] = 1
	var cooldown: int = run.effective_troop(fanti).cooldown_ms
	run.call("_pay_upkeep")
	assert_false(guardie.neglected, "Le guardie, più a destra, pagano per prime.")
	assert_true(fanti.neglected, "Ai fanti non resta Ferro: trascurati.")
	assert_eq(run.stock[Res.Type.FERRO], 0)
	assert_eq(run.malcontent, 1, "+1 Malcontento per la carta non pagata.")
	assert_eq(run.effective_troop(fanti).cooldown_ms, cooldown * 3 / 2, "Trascurata: ricarica ×1,5.")
	run.stock[Res.Type.FERRO] = 5
	run.call("_pay_upkeep")
	assert_false(fanti.neglected, "Pagata la volta dopo, torna normale.")


func test_si_paga_prima_degli_scontri() -> void:
	var run: RunState = _run()
	run.board.troops[0].level = 2
	run.stock[Res.Type.FERRO] = 10
	while run.is_shopping_phase():
		run.pass_round()
	assert_eq(run.phase, RunState.Phase.SCONTRO_FANTASMA, "Senza incontri nei dati si arriva al fantasma.")
	var before: int = run.stock[Res.Type.FERRO]
	run.fight_ghost()
	assert_eq(run.stock[Res.Type.FERRO], before - 2, "Fanti livello 2 (1) + guardie speciali (1).")


func test_anche_gli_edifici_pagano_e_rallentano() -> void:
	var run: RunState = _run()
	var mura: BoardPiece = run.board.buildings[0]
	mura.level = 2
	var interval: int = run.effective_building(mura).mana_interval_ms
	run.call("_pay_upkeep")
	assert_true(mura.neglected)
	assert_eq(run.effective_building(mura).mana_interval_ms, interval * 3 / 2, "Intervallo ×1,5.")
	assert_eq(run.upkeep_total().whole(Res.Type.FERRO), 2, "Mura livello 2 + guardie speciali.")
