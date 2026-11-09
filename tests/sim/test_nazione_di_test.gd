extends GutTest
## Nazione di test (convenzione §16.3): parte con le risorse del file dati e con tutti gli spazi
## della plancia liberi. Usa il catalogo e le regole veri del gioco.

var catalog: CatalogDef
var run_rules: RunRules
var setup: TestNationDef


func before_each() -> void:
	catalog = load("res://data/catalog/catalog.tres") as CatalogDef
	run_rules = load("res://data/rules/run_rules.tres") as RunRules
	setup = load("res://data/rules/test_nation.tres") as TestNationDef


func _run() -> RunState:
	return RunState.new(catalog, run_rules, load("res://data/rules/battle_rules.tres") as BattleRules,
			load("res://data/rules/resistance_rules.tres") as ResistanceRules, 1234)


func test_il_file_dati_chiede_99_di_ogni_risorsa_tranne_la_ricerca() -> void:
	assert_not_null(setup, "Il file della nazione di test si carica.")
	for type: Res.Type in Res.NAMES:
		var expected: int = 0 if type == Res.Type.RICERCA else 99
		assert_eq(setup.starting_resources.whole(type), expected, Res.NAMES[type])
	assert_true(setup.open_all_slots, "Tutti gli spazi liberi.")


func test_la_dotazione_di_test_sostituisce_quella_normale() -> void:
	var run: RunState = _run()
	run.apply_test_setup(setup)
	for type: Res.Type in Res.NAMES:
		var expected: int = 0 if type == Res.Type.RICERCA else 99 * Res.scale(type)
		assert_eq(run.stock[type], expected, "%s prima dell'identità." % Res.NAMES[type])
	assert_eq(run.board.building_capacity(), run_rules.max_building_slots, "Spazi edificio al massimo.")
	assert_eq(run.board.troop_capacity(), run_rules.max_troop_slots, "Spazi truppa al massimo.")


func test_dopo_la_fondazione_restano_almeno_99_e_tutti_gli_spazi() -> void:
	var run: RunState = _run()
	run.apply_test_setup(setup)
	assert_true(run.found_nation(setup.nation_name, NationTemplate.first_choices(catalog, run_rules)), run.last_error)
	for type: Res.Type in Res.NAMES:
		if type == Res.Type.RICERCA:
			continue
		assert_gte(run.stock[type], 99 * Res.scale(type), "%s: 99 più quanto dà l'identità e il primo inverno." % Res.NAMES[type])
	assert_eq(run.board.building_capacity(), run_rules.max_building_slots)
	assert_eq(run.board.troop_capacity(), run_rules.max_troop_slots)
	assert_true(run.board.has_free_building_slot(), "Restano spazi edificio liberi.")
	assert_true(run.board.has_free_troop_slot(), "Restano spazi truppa liberi.")


func test_senza_spazi_aperti_la_plancia_resta_normale() -> void:
	var run: RunState = _run()
	var partial: TestNationDef = TestNationDef.new()
	partial.open_all_slots = false
	run.apply_test_setup(partial)
	assert_eq(run.board.base_building_slots, run_rules.starting_building_slots)
	assert_eq(run.board.base_troop_slots, run_rules.starting_troop_slots)
	assert_eq(run.gold, run_rules.starting_gold, "Senza risorse indicate resta la dotazione normale.")
