extends Control
## Creazione (o modifica) di una nazione, come in un GDR (GDD §9.1):
## nome, popolo, governo, credo, cultura e perk iniziali, tutti visibili insieme.

const COLOR_SELECTED: Color = Color(0.22, 0.34, 0.24)

var _catalog: CatalogDef
var _rules: RunRules
var _name_edit: LineEdit
var _columns: HBoxContainer
var _summary: Label
var _error: Label
var _save_button: Button

var _choice: Dictionary[IdentityDef.Dimension, IdentityDef] = {}
var _perks: Array[IdentityDef] = []


func _ready() -> void:
	_catalog = GameSession.catalog()
	_rules = GameSession.run_rules()
	_load_editing()

	var margin: MarginContainer = UiKit.screen(self)
	var root: VBoxContainer = VBoxContainer.new()
	root.add_theme_constant_override("separation", 14)
	margin.add_child(root)

	var editing: bool = GameSession.editing_nation != null
	root.add_child(UiKit.label("Modifica la nazione" if editing else "Crea la tua nazione", 36))
	root.add_child(UiKit.label("Come in un gioco di ruolo: scegli un nome, un elemento per colonna e i perk. Tutte le opzioni sono disponibili.", 16))

	var name_row: HBoxContainer = HBoxContainer.new()
	root.add_child(name_row)
	name_row.add_child(UiKit.label("Nome: ", 22))
	_name_edit = LineEdit.new()
	_name_edit.placeholder_text = "Nome della nazione"
	_name_edit.custom_minimum_size = Vector2(520, 0)
	_name_edit.add_theme_font_size_override("font_size", 22)
	if editing:
		_name_edit.text = GameSession.editing_nation.nation_name
	name_row.add_child(_name_edit)

	_columns = HBoxContainer.new()
	_columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_columns.add_theme_constant_override("separation", 12)
	root.add_child(_columns)

	_summary = UiKit.wrapped("", 18, Color(0.75, 0.8, 1.0))
	root.add_child(_summary)
	_error = UiKit.label("", 18, UiKit.COLOR_ERROR)
	root.add_child(_error)

	var buttons: HBoxContainer = HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 16)
	root.add_child(buttons)
	_save_button = UiKit.big_button("Salva la nazione", _on_save)
	buttons.add_child(_save_button)
	buttons.add_child(UiKit.big_button("Annulla", _on_cancel))

	_refresh()


## In modifica, parte dalle scelte già salvate.
func _load_editing() -> void:
	if GameSession.editing_nation == null:
		return
	for def: IdentityDef in GameSession.editing_nation.resolve(_catalog):
		if def.dimension == IdentityDef.Dimension.PERK:
			_perks.append(def)
		else:
			_choice[def.dimension] = def


func _refresh() -> void:
	UiKit.clear(_columns)
	for dimension: IdentityDef.Dimension in IdentityDef.CREATION_DIMENSIONS:
		var options: Array[IdentityDef] = IdentityRules.options(_catalog, dimension)
		if options.is_empty():
			continue
		_columns.add_child(_build_column(dimension, options))
	_summary.text = _summary_text()
	var problem: String = IdentityRules.validate(_catalog, _rules, _choices())
	_save_button.disabled = problem != ""
	_error.text = ""


func _build_column(dimension: IdentityDef.Dimension, options: Array[IdentityDef]) -> Control:
	var column: VBoxContainer = VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var is_perk: bool = dimension == IdentityDef.Dimension.PERK
	var title: String = IdentityDef.DIMENSION_NAMES[dimension]
	if is_perk:
		title = "Perk (%d/%d) — scorri per vederli tutti" % [_perks.size(), IdentityRules.starting_perk_count(_catalog, _rules)]
	column.add_child(UiKit.label(title, 24, UiKit.COLOR_WARNING))

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	var list: VBoxContainer = VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 8)
	scroll.add_child(list)

	for def: IdentityDef in options:
		var selected: bool = _perks.has(def) if is_perk else _choice.get(dimension) == def
		var card: PanelContainer = UiKit.panel(COLOR_SELECTED if selected else UiKit.COLOR_OFFER)
		var box: VBoxContainer = VBoxContainer.new()
		card.add_child(box)
		box.add_child(UiKit.wrapped(("✔ " if selected else "") + def.display_name, 20))
		if def.resistance_bonus != 0:
			box.add_child(UiKit.label("Resistenza %+d" % def.resistance_bonus, 15, Color(0.8, 0.85, 0.6)))
		box.add_child(UiKit.wrapped(def.description, 14))
		box.add_child(UiKit.button("Togli" if selected else "Scegli", _on_pick.bind(def)))
		list.add_child(card)
	return column


func _summary_text() -> String:
	var choices: Array[IdentityDef] = _choices()
	if choices.is_empty():
		return "Nessuna scelta ancora."
	var resistance: int = 0
	for def: IdentityDef in choices:
		resistance += def.resistance_bonus
	return "%s\nResistenza dall'identità: %+d" % [UiKit.identity_text(choices), resistance]


func _choices() -> Array[IdentityDef]:
	var choices: Array[IdentityDef] = []
	for dimension: IdentityDef.Dimension in IdentityDef.CREATION_DIMENSIONS:
		if _choice.has(dimension):
			choices.append(_choice[dimension])
	choices.append_array(_perks)
	return choices


func _on_pick(def: IdentityDef) -> void:
	if def.dimension == IdentityDef.Dimension.PERK:
		if _perks.has(def):
			_perks.erase(def)
		elif _perks.size() < IdentityRules.starting_perk_count(_catalog, _rules):
			_perks.append(def)
	elif _choice.get(def.dimension) == def:
		_choice.erase(def.dimension)
	else:
		_choice[def.dimension] = def
	_refresh()


func _on_save() -> void:
	var choices: Array[IdentityDef] = _choices()
	var problem: String = IdentityRules.validate(_catalog, _rules, choices)
	if problem != "":
		_error.text = problem
		return
	var nation_id: String = GameSession.editing_nation.id if GameSession.editing_nation != null else GameSession.new_nation_id()
	var nation: NationTemplate = NationTemplate.from_choices(nation_id, _name_edit.text, choices)
	if not NationStore.upsert(nation, GameSession.store_path):
		_error.text = "Non riesco a salvare la nazione sul disco."
		return
	GameSession.editing_nation = null
	GameSession.go(GameSession.creator_return_scene)


func _on_cancel() -> void:
	GameSession.editing_nation = null
	GameSession.go(GameSession.creator_return_scene)
