extends GutTest
## Verifiche del calcolo della Resistenza (GDD §7.1.1).


func _rules() -> ResistanceRules:
	var rules: ResistanceRules = ResistanceRules.new()
	rules.per_era = [20, 30, 40]
	rules.per_year = 5
	rules.per_building = 2
	rules.per_troop = 3
	return rules


func test_somma_di_era_anni_edifici_e_truppe() -> void:
	# Era 2 (30) + anno 3 (15) + 4 edifici (8) + 2 truppe (6) = 59
	assert_eq(ResistanceCalc.compute(_rules(), 2, 3, 4, 2), 59)


func test_identita_si_aggiunge_alla_somma() -> void:
	assert_eq(ResistanceCalc.compute(_rules(), 1, 1, 0, 0, 7), 20 + 5 + 7)


func test_ogni_anno_aumenta_la_resistenza() -> void:
	var year_1: int = ResistanceCalc.compute(_rules(), 1, 1, 0, 0)
	var year_2: int = ResistanceCalc.compute(_rules(), 1, 2, 0, 0)
	assert_eq(year_2 - year_1, 5)


func test_era_piu_alta_resistenza_piu_alta() -> void:
	assert_gt(ResistanceCalc.compute(_rules(), 3, 1, 0, 0), ResistanceCalc.compute(_rules(), 2, 1, 0, 0))


func test_dati_reali_si_caricano() -> void:
	var rules: ResistanceRules = load("res://data/rules/resistance_rules.tres") as ResistanceRules
	assert_not_null(rules, "Il file dati della Resistenza si carica.")
	var battle_rules: BattleRules = load("res://data/rules/battle_rules.tres") as BattleRules
	assert_not_null(battle_rules, "Il file dati della battaglia si carica.")
	assert_eq(battle_rules.attrition_start_ms, 45000, "Il logoramento parte a 45 secondi.")
