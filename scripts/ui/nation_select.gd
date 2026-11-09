extends Control
## Selezione della nazione con cui giocare: Gioca, Modifica, Elimina.

var _list: VBoxContainer
var _confirm: ConfirmationDialog
var _pending_delete: NationTemplate


func _ready() -> void:
	var margin: MarginContainer = UiKit.screen(self)
	var root: VBoxContainer = VBoxContainer.new()
	root.add_theme_constant_override("separation", 16)
	margin.add_child(root)

	root.add_child(UiKit.label("Scegli la nazione con cui giocare", 36))
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll)
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 12)
	scroll.add_child(_list)

	var bottom: HBoxContainer = HBoxContainer.new()
	bottom.add_theme_constant_override("separation", 16)
	root.add_child(bottom)
	bottom.add_child(UiKit.big_button("Crea nuova nazione", _on_create))
	bottom.add_child(UiKit.big_button("Indietro", _on_back))

	_confirm = ConfirmationDialog.new()
	_confirm.title = "Conferma"
	_confirm.ok_button_text = "Elimina"
	_confirm.cancel_button_text = "Annulla"
	_confirm.confirmed.connect(_on_delete_confirmed)
	add_child(_confirm)

	_refresh()


func _refresh() -> void:
	UiKit.clear(_list)
	var catalog: CatalogDef = GameSession.catalog()
	var rules: RunRules = GameSession.run_rules()
	# La nazione di test è sempre in cima: si può solo giocare, non modificare né eliminare.
	var test_nation: NationTemplate = GameSession.test_nation()
	if test_nation != null:
		_list.add_child(_card(test_nation, catalog, rules, GameSession.test_nation_setup().describe()))
	var nations: Array[NationTemplate] = GameSession.saved_nations()
	if nations.is_empty():
		_list.add_child(UiKit.label("Nessuna nazione creata.", 22, Color(0.6, 0.6, 0.65)))
		return
	for nation: NationTemplate in nations:
		_list.add_child(_card(nation, catalog, rules))


## Scheda di una nazione nella lista. La nazione di test ha una riga in più con la sua dotazione
## e solo il pulsante Gioca.
func _card(nation: NationTemplate, catalog: CatalogDef, rules: RunRules, test_note: String = "") -> PanelContainer:
	var card: PanelContainer = UiKit.panel(UiKit.COLOR_OFFER)
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	card.add_child(row)
	var info: VBoxContainer = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(info)
	info.add_child(UiKit.label(nation.nation_name, 28))
	info.add_child(UiKit.label(UiKit.identity_text(nation.resolve(catalog)), 16, Color(0.75, 0.8, 1.0)))
	if nation.is_test:
		info.add_child(UiKit.wrapped("Solo per le prove: %s." % test_note, 16, Color(0.95, 0.8, 0.45)))
	var problem: String = nation.problem(catalog, rules)
	if problem != "":
		info.add_child(UiKit.label(problem, 16, UiKit.COLOR_ERROR))
	var play: Button = UiKit.button("Gioca", _on_play.bind(nation), problem == "")
	play.custom_minimum_size = Vector2(160, 56)
	row.add_child(play)
	if nation.is_test:
		return card
	var edit: Button = UiKit.button("Modifica", _on_edit.bind(nation))
	edit.custom_minimum_size = Vector2(160, 56)
	row.add_child(edit)
	var delete: Button = UiKit.button("Elimina", _on_delete.bind(nation))
	delete.custom_minimum_size = Vector2(160, 56)
	row.add_child(delete)
	return card


func _on_play(nation: NationTemplate) -> void:
	GameSession.start_game(nation)


func _on_edit(nation: NationTemplate) -> void:
	GameSession.open_creator(nation, GameSession.SELECT_SCENE)


func _on_delete(nation: NationTemplate) -> void:
	_pending_delete = nation
	_confirm.dialog_text = "Eliminare la nazione «%s»? Non si potrà recuperare." % nation.nation_name
	_confirm.popup_centered()


func _on_delete_confirmed() -> void:
	if _pending_delete != null:
		NationStore.remove(_pending_delete.id, GameSession.store_path)
		_pending_delete = null
	_refresh()


func _on_create() -> void:
	GameSession.open_creator(null, GameSession.SELECT_SCENE)


func _on_back() -> void:
	GameSession.go(GameSession.MENU_SCENE)
