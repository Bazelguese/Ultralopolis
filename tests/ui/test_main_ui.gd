extends GutTest
## Prova di funzionamento della schermata di gioco: parte dalla nazione scelta e attraversa un anno.

const TEST_STORE: String = "user://test_nazioni_gioco.json"


func before_each() -> void:
	GameSession.navigation_enabled = false
	GameSession.store_path = TEST_STORE


func after_each() -> void:
	GameSession.navigation_enabled = true
	GameSession.store_path = NationStore.DEFAULT_PATH
	GameSession.selected_nation = null
	if FileAccess.file_exists(TEST_STORE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_STORE))


func _nation(name: String) -> NationTemplate:
	var catalog: CatalogDef = GameSession.catalog()
	var rules: RunRules = GameSession.run_rules()
	var choices: Array[IdentityDef] = []
	for dimension: IdentityDef.Dimension in IdentityDef.CREATION_DIMENSIONS:
		var options: Array[IdentityDef] = IdentityRules.options(catalog, dimension)
		var count: int = IdentityRules.starting_perk_count(catalog, rules) if dimension == IdentityDef.Dimension.PERK else 1
		for i: int in range(count):
			choices.append(options[options.size() - 1 - i])
	return NationTemplate.from_choices("prova_ui", name, choices)


func test_la_partita_parte_dalla_nazione_scelta_e_attraversa_un_anno() -> void:
	GameSession.selected_nation = _nation("Regno di Prova")
	var main: Control = (load("res://scenes/main.tscn") as PackedScene).instantiate() as Control
	add_child_autofree(main)
	await wait_physics_frames(2)
	var run: RunState = main.get("run")
	assert_eq(run.phase, RunState.Phase.PRODUZIONE, "La partita comincia dall'anno 1.")
	assert_eq(run.nation_name, "Regno di Prova")
	assert_eq(run.identity.size(), GameSession.selected_nation.identity_ids.size())

	while run.is_shopping_phase():
		main.call("_on_pass")
	main.call("_on_encounter", 0)
	var layer: Control = main.get("_battle_layer")
	assert_true(layer.visible, "Si apre la visione della battaglia.")
	var view: BattleView = layer.get_child(0) as BattleView
	view.call("_on_skip")
	view.call("_on_continue")
	assert_false(layer.visible)
	if run.phase == RunState.Phase.RICOMPENSA_INCONTRO:
		main.call("_on_skip_reward")
	while run.is_shopping_phase():
		main.call("_on_pass")
	main.call("_on_fight_ghost")
	(layer.get_child(0) as BattleView).call("_on_continue")
	assert_eq(run.year, 2, "Dopo il fantasma inizia l'anno 2.")

	main.call("_on_menu")
	assert_eq(GameSession.last_scene_request, GameSession.MENU_SCENE, "Il pulsante porta al menu.")


func test_senza_nazione_scelta_usa_una_nazione_di_prova() -> void:
	var main: Control = (load("res://scenes/main.tscn") as PackedScene).instantiate() as Control
	add_child_autofree(main)
	await wait_physics_frames(2)
	var run: RunState = main.get("run")
	assert_eq(run.phase, RunState.Phase.PRODUZIONE)
	assert_eq(run.nation_name, "Nazione di prova")
