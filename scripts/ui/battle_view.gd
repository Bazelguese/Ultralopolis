class_name BattleView
extends PanelContainer
## Mostra uno scontro passo per passo (GDD §14.3, principio P4).
## Fa scorrere una copia della simulazione: la presentazione non decide nulla.
## Il tempo reale (delta) serve solo a decidere quando mostrare il passo successivo.

signal closed

const SPEEDS: Array[float] = [1.0, 2.0, 4.0]

var _sim: BattleSim
var _setups: Array[BattleSideSetup] = []
var _title: String = ""
var _side_names: Array[String] = ["La tua nazione", "Avversario"]
var _paused: bool = false
var _speed_index: int = 0
var _accumulated_ms: float = 0.0

var _time_label: Label
var _pause_button: Button
var _speed_button: Button
var _skip_button: Button
var _result_label: Label
var _continue_button: Button
var _log_label: RichTextLabel
var _resistance_bars: Array[ProgressBar] = []
var _resistance_labels: Array[Label] = []
var _mana_labels: Array[Label] = []
var _troop_bars: Array[Array] = [[], []]
var _troop_states: Array[Array] = [[], []]
var _troop_panels: Array[Array] = [[], []]
var _building_bars: Array[Array] = [[], []]
var _building_panels: Array[Array] = [[], []]


## setups: le due nazioni come sono entrate in battaglia (giocatore, avversario).
func setup(sim: BattleSim, setups: Array[BattleSideSetup], title: String, opponent_name: String) -> void:
	_sim = sim
	_setups = setups
	_title = title
	_side_names = ["La tua nazione", opponent_name]
	_build()
	_refresh()


func _ready() -> void:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.07, 0.09)
	style.set_content_margin_all(24)
	add_theme_stylebox_override("panel", style)


func _process(delta: float) -> void:
	if _sim == null or _paused or _sim.outcome != BattleSim.Outcome.IN_CORSO:
		return
	_accumulated_ms += delta * 1000.0 * SPEEDS[_speed_index]
	var tick: int = _sim.rules.tick_ms
	while _accumulated_ms >= tick and _sim.outcome == BattleSim.Outcome.IN_CORSO:
		_accumulated_ms -= tick
		_sim.step()
		_show_step_events()
	_refresh()


func _build() -> void:
	# Un posto per ciascuna nazione, indicizzato per lato (0 = giocatore, 1 = avversario).
	_resistance_bars.resize(2)
	_resistance_labels.resize(2)
	_mana_labels.resize(2)
	var root: VBoxContainer = VBoxContainer.new()
	root.add_theme_constant_override("separation", 14)
	add_child(root)

	var header: HBoxContainer = HBoxContainer.new()
	header.add_theme_constant_override("separation", 16)
	root.add_child(header)
	var title_label: Label = UiKit.label(_title, 30)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title_label)
	_time_label = UiKit.label("", 22)
	header.add_child(_time_label)
	_pause_button = UiKit.button("Pausa", _on_pause)
	header.add_child(_pause_button)
	_speed_button = UiKit.button("Velocità 1x", _on_speed)
	header.add_child(_speed_button)
	_skip_button = UiKit.button("Salta", _on_skip)
	header.add_child(_skip_button)

	root.add_child(UiKit.wrapped("Le truppe vengono valutate da destra verso sinistra. Logoramento da %s." % UiKit.seconds(_sim.rules.attrition_start_ms), 16, UiKit.COLOR_WARNING))

	# Avversario in alto, giocatore in basso.
	for side: int in [BattleSim.SIDE_B, BattleSim.SIDE_A]:
		root.add_child(_build_side(side))

	_result_label = UiKit.label("", 28, UiKit.COLOR_WARNING)
	root.add_child(_result_label)

	_log_label = RichTextLabel.new()
	_log_label.custom_minimum_size = Vector2(0, 160)
	_log_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_log_label.scroll_following = true
	root.add_child(_log_label)

	_continue_button = UiKit.button("Continua", _on_continue)
	_continue_button.visible = false
	root.add_child(_continue_button)


func _build_side(side: int) -> Control:
	var setup_data: BattleSideSetup = _setups[side]
	var box: PanelContainer = UiKit.panel(UiKit.COLOR_PANEL)
	var column: VBoxContainer = VBoxContainer.new()
	box.add_child(column)

	var top: HBoxContainer = HBoxContainer.new()
	top.add_theme_constant_override("separation", 20)
	column.add_child(top)
	var name_label: Label = UiKit.label(_side_names[side], 24)
	name_label.custom_minimum_size = Vector2(380, 0)
	top.add_child(name_label)
	var bar: ProgressBar = ProgressBar.new()
	bar.custom_minimum_size = Vector2(420, 28)
	bar.max_value = maxi(_sim.get_max_resistance(side), 1)
	bar.show_percentage = false
	var fill: StyleBoxFlat = StyleBoxFlat.new()
	fill.bg_color = Color(0.3, 0.75, 0.4) if side == BattleSim.SIDE_A else Color(0.85, 0.3, 0.3)
	fill.set_corner_radius_all(4)
	bar.add_theme_stylebox_override("fill", fill)
	var empty: StyleBoxFlat = StyleBoxFlat.new()
	empty.bg_color = Color(0.2, 0.2, 0.22)
	empty.set_corner_radius_all(4)
	bar.add_theme_stylebox_override("background", empty)
	top.add_child(bar)
	_resistance_bars[side] = bar
	var resistance_label: Label = UiKit.label("", 20)
	resistance_label.custom_minimum_size = Vector2(240, 0)
	top.add_child(resistance_label)
	_resistance_labels[side] = resistance_label
	var mana_label: Label = UiKit.label("", 20, Color(0.6, 0.8, 1.0))
	top.add_child(mana_label)
	_mana_labels[side] = mana_label

	var buildings_row: HBoxContainer = HBoxContainer.new()
	buildings_row.add_theme_constant_override("separation", 8)
	column.add_child(buildings_row)
	buildings_row.add_child(UiKit.label("Edifici:", 16))
	for i: int in range(setup_data.buildings.size()):
		var def: BuildingDef = setup_data.buildings[i]
		var piece: PanelContainer = UiKit.panel(UiKit.COLOR_BUILDING, Vector2(150, 0))
		var piece_box: VBoxContainer = VBoxContainer.new()
		piece.add_child(piece_box)
		piece_box.add_child(UiKit.label("%s\n+%d mana" % [def.display_name, def.mana_amount], 15))
		var production: ProgressBar = ProgressBar.new()
		production.max_value = def.mana_interval_ms
		production.custom_minimum_size = Vector2(0, 10)
		production.show_percentage = false
		piece_box.add_child(production)
		buildings_row.add_child(piece)
		_building_bars[side].append(production)
		_building_panels[side].append(piece)

	var troops_row: HBoxContainer = HBoxContainer.new()
	troops_row.add_theme_constant_override("separation", 8)
	column.add_child(troops_row)
	troops_row.add_child(UiKit.label("Truppe:", 16))
	for i: int in range(setup_data.troops.size()):
		var def: TroopDef = setup_data.troops[i]
		var piece: PanelContainer = UiKit.panel(UiKit.COLOR_TROOP, Vector2(200, 0))
		var piece_box: VBoxContainer = VBoxContainer.new()
		piece.add_child(piece_box)
		var cost_text: String = "senza mana" if def.mana_cost == 0 else "%d mana" % def.mana_cost
		piece_box.add_child(UiKit.label("%s\n%d danni, %s" % [def.display_name, def.damage, cost_text], 16))
		var cooldown: ProgressBar = ProgressBar.new()
		cooldown.max_value = def.cooldown_ms
		cooldown.custom_minimum_size = Vector2(0, 12)
		cooldown.show_percentage = false
		piece_box.add_child(cooldown)
		var state: Label = UiKit.label("", 14)
		piece_box.add_child(state)
		troops_row.add_child(piece)
		_troop_bars[side].append(cooldown)
		_troop_states[side].append(state)
		_troop_panels[side].append(piece)
	return box


func _refresh() -> void:
	_time_label.text = "Tempo: %s" % UiKit.seconds(_sim.elapsed_ms)
	for side: int in range(2):
		var resistance: int = _sim.get_resistance(side)
		_resistance_bars[side].value = maxi(resistance, 0)
		_resistance_labels[side].text = "Resistenza %d / %d" % [resistance, _sim.get_max_resistance(side)]
		_mana_labels[side].text = "Mana: %d" % _sim.get_mana(side)
		for i: int in range(_building_bars[side].size()):
			var bar: ProgressBar = _building_bars[side][i]
			bar.value = bar.max_value - _sim.get_building_production_left_ms(side, i)
		for i: int in range(_troop_bars[side].size()):
			var bar: ProgressBar = _troop_bars[side][i]
			var state_label: Label = _troop_states[side][i]
			var left: int = _sim.get_troop_cooldown_left_ms(side, i)
			match _sim.get_troop_state(side, i):
				BattleSim.TroopState.IN_ATTESA_DI_MANA:
					bar.value = bar.max_value
					var troop: TroopDef = _setups[side].troops[i]
					state_label.text = "In attesa di mana (serve %d, ce n'è %d)" % [troop.mana_cost, _sim.get_mana(side, troop.mana_type)]
					state_label.add_theme_color_override("font_color", UiKit.COLOR_WARNING)
				BattleSim.TroopState.IN_RICARICA:
					bar.value = bar.max_value - left
					state_label.text = "Ricarica: %s" % UiKit.seconds(left)
					state_label.remove_theme_color_override("font_color")
	var running: bool = _sim.outcome == BattleSim.Outcome.IN_CORSO
	_pause_button.disabled = not running
	_speed_button.disabled = not running
	_skip_button.disabled = not running
	if not running and not _continue_button.visible:
		_result_label.text = _outcome_text()
		_continue_button.visible = true


func _show_step_events(animate: bool = true) -> void:
	for event: BattleEvent in _sim.last_step_events:
		match event.kind:
			BattleEvent.Kind.ATTIVAZIONE:
				if animate:
					_flash(_troop_panels[event.side][event.index], Color(1.6, 1.6, 1.2))
				_log("%s: %s colpisce per %d." % [UiKit.seconds(event.time_ms), _side_names[event.side], event.amount])
			BattleEvent.Kind.IN_ATTESA_MANA:
				_log("%s: %s, una truppa aspetta il mana (riserva %d)." % [UiKit.seconds(event.time_ms), _side_names[event.side], event.mana_after], UiKit.COLOR_WARNING)
			BattleEvent.Kind.MANA_PRODOTTO:
				if animate:
					_flash(_building_panels[event.side][event.index], Color(1.0, 1.3, 1.6))
			BattleEvent.Kind.LOGORAMENTO:
				_log("%s: logoramento, %s perde %d." % [UiKit.seconds(event.time_ms), _side_names[event.side], event.amount], UiKit.COLOR_ERROR)


func _flash(node: Control, color: Color) -> void:
	node.modulate = color
	var tween: Tween = node.create_tween()
	tween.tween_property(node, "modulate", Color.WHITE, 0.25)


func _log(text: String, color: Color = Color.WHITE) -> void:
	_log_label.push_color(color)
	_log_label.add_text(text + "\n")
	_log_label.pop()


func _outcome_text() -> String:
	match _sim.outcome:
		BattleSim.Outcome.VITTORIA_A:
			return "Vittoria!"
		BattleSim.Outcome.VITTORIA_B:
			return "Sconfitta."
		BattleSim.Outcome.PAREGGIO:
			return "Pareggio: conta come vittoria."
		BattleSim.Outcome.INTERROTTA:
			return "Scontro interrotto (limite di sicurezza)."
	return ""


func _on_pause() -> void:
	_paused = not _paused
	_pause_button.text = "Riprendi" if _paused else "Pausa"


func _on_speed() -> void:
	_speed_index = (_speed_index + 1) % SPEEDS.size()
	_speed_button.text = "Velocità %dx" % int(SPEEDS[_speed_index])


func _on_skip() -> void:
	_log("Visualizzazione saltata: ecco il resto dello scontro.", UiKit.COLOR_WARNING)
	while _sim.outcome == BattleSim.Outcome.IN_CORSO:
		_sim.step()
		_show_step_events(false)
	_refresh()


func _on_continue() -> void:
	closed.emit()
