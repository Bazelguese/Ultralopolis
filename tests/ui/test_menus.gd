extends GutTest
## Menu principale, selezione e creazione delle nazioni.

const TEST_STORE: String = "user://test_nazioni_menu.json"


func before_each() -> void:
	GameSession.navigation_enabled = false
	GameSession.store_path = TEST_STORE
	GameSession.editing_nation = null
	if FileAccess.file_exists(TEST_STORE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_STORE))


func after_each() -> void:
	GameSession.navigation_enabled = true
	GameSession.store_path = NationStore.DEFAULT_PATH
	GameSession.editing_nation = null
	GameSession.selected_nation = null
	if FileAccess.file_exists(TEST_STORE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_STORE))


func _open(scene_path: String) -> Control:
	var screen: Control = (load(scene_path) as PackedScene).instantiate() as Control
	add_child_autofree(screen)
	return screen


## Sceglie nella schermata di creazione il primo elemento di ogni colonna e i primi perk.
func _fill_creator(creator: Control) -> void:
	var catalog: CatalogDef = GameSession.catalog()
	var rules: RunRules = GameSession.run_rules()
	for dimension: IdentityDef.Dimension in IdentityDef.DIMENSION_NAMES:
		var options: Array[IdentityDef] = IdentityRules.options(catalog, dimension)
		var count: int = IdentityRules.starting_perk_count(catalog, rules) if dimension == IdentityDef.Dimension.PERK else 1
		for i: int in range(count):
			creator.call("_on_pick", options[i])


func test_gioca_senza_nazioni_porta_alla_creazione() -> void:
	var menu: Control = _open("res://scenes/main_menu.tscn")
	menu.call("_on_play")
	assert_eq(GameSession.last_scene_request, GameSession.CREATOR_SCENE)
	assert_eq(GameSession.creator_return_scene, GameSession.SELECT_SCENE, "Dopo la creazione si torna alla lista.")


func test_crea_nazione_dal_menu_torna_al_menu() -> void:
	var menu: Control = _open("res://scenes/main_menu.tscn")
	menu.call("_on_create")
	assert_eq(GameSession.last_scene_request, GameSession.CREATOR_SCENE)
	var creator: Control = _open("res://scenes/nation_creator.tscn")
	_fill_creator(creator)
	(creator.get("_name_edit") as LineEdit).text = "Regno del Test"
	creator.call("_on_save")
	assert_eq(GameSession.last_scene_request, GameSession.MENU_SCENE, "Torna al menu principale.")
	var saved: Array[NationTemplate] = GameSession.saved_nations()
	assert_eq(saved.size(), 1, "La nazione è salvata.")
	assert_eq(saved[0].nation_name, "Regno del Test")


func test_il_salvataggio_richiede_una_scelta_completa() -> void:
	var creator: Control = _open("res://scenes/nation_creator.tscn")
	assert_true((creator.get("_save_button") as Button).disabled, "Senza scelte non si salva.")
	_fill_creator(creator)
	assert_false((creator.get("_save_button") as Button).disabled)


func test_gioca_con_nazioni_porta_alla_lista_e_poi_alla_partita() -> void:
	var creator: Control = _open("res://scenes/nation_creator.tscn")
	_fill_creator(creator)
	creator.call("_on_save")
	var menu: Control = _open("res://scenes/main_menu.tscn")
	menu.call("_on_play")
	assert_eq(GameSession.last_scene_request, GameSession.SELECT_SCENE)
	var select: Control = _open("res://scenes/nation_select.tscn")
	var nation: NationTemplate = GameSession.saved_nations()[0]
	select.call("_on_play", nation)
	assert_eq(GameSession.last_scene_request, GameSession.GAME_SCENE)
	assert_eq(GameSession.selected_nation.id, nation.id)


func test_modifica_mantiene_la_stessa_nazione() -> void:
	var creator: Control = _open("res://scenes/nation_creator.tscn")
	_fill_creator(creator)
	(creator.get("_name_edit") as LineEdit).text = "Primo nome"
	creator.call("_on_save")
	var nation: NationTemplate = GameSession.saved_nations()[0]
	var select: Control = _open("res://scenes/nation_select.tscn")
	select.call("_on_edit", nation)
	assert_eq(GameSession.editing_nation.id, nation.id)
	var editor: Control = _open("res://scenes/nation_creator.tscn")
	assert_eq((editor.get("_name_edit") as LineEdit).text, "Primo nome", "La modifica parte dai dati salvati.")
	assert_false((editor.get("_save_button") as Button).disabled, "Le scelte salvate sono già selezionate.")
	(editor.get("_name_edit") as LineEdit).text = "Nuovo nome"
	editor.call("_on_save")
	var saved: Array[NationTemplate] = GameSession.saved_nations()
	assert_eq(saved.size(), 1, "Nessuna copia: è la stessa nazione.")
	assert_eq(saved[0].nation_name, "Nuovo nome")
	assert_eq(GameSession.last_scene_request, GameSession.SELECT_SCENE, "Dalla lista si torna alla lista.")


func test_elimina_con_conferma() -> void:
	var creator: Control = _open("res://scenes/nation_creator.tscn")
	_fill_creator(creator)
	creator.call("_on_save")
	var select: Control = _open("res://scenes/nation_select.tscn")
	select.call("_on_delete", GameSession.saved_nations()[0])
	assert_eq(GameSession.saved_nations().size(), 1, "Prima della conferma non si elimina nulla.")
	select.call("_on_delete_confirmed")
	assert_eq(GameSession.saved_nations().size(), 0)
