extends Control
## Interfaccia provvisoria della run (GDD §14.3, §15.2).
## Legge lo stato di RunState e chiama le sue azioni: nessuna regola di gioco qui.

const CATALOG_PATH: String = "res://data/catalog/catalog.tres"
const RUN_RULES_PATH: String = "res://data/rules/run_rules.tres"
const BATTLE_RULES_PATH: String = "res://data/rules/battle_rules.tres"
const RESISTANCE_RULES_PATH: String = "res://data/rules/resistance_rules.tres"

enum PendingKind { NESSUNA, OFFERTA, RICOMPENSA }

var run: RunState

var _status_label: Label
var _buildings_title: Label
var _buildings_row: HBoxContainer
var _troops_title: Label
var _troops_row: HBoxContainer
var _resistance_label: Label
var _action_box: VBoxContainer
var _message_label: Label
var _chronicle: RichTextLabel
var _battle_layer: Control

## Offerta o ricompensa in attesa che il giocatore scelga cosa sostituire.
var _pending_kind: PendingKind = PendingKind.NESSUNA
var _pending_index: int = -1
var _shown_chronicle: int = 0


func _ready() -> void:
	var ui_theme: Theme = Theme.new()
	ui_theme.default_font_size = 18
	theme = ui_theme
	_build_layout()
	_new_run()


# --- Struttura della schermata ----------------------------------------------

func _build_layout() -> void:
	var background: ColorRect = ColorRect.new()
	background.color = Color(0.09, 0.09, 0.11)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 20)
	add_child(margin)

	var root: VBoxContainer = VBoxContainer.new()
	root.add_theme_constant_override("separation", 12)
	margin.add_child(root)

	var top: HBoxContainer = HBoxContainer.new()
	root.add_child(top)
	_status_label = UiKit.label("", 22)
	_status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(_status_label)
	top.add_child(UiKit.label("PROTOTIPO — grafica provvisoria", 14, UiKit.COLOR_WARNING))
	top.add_child(UiKit.button("Nuova run", _new_run))

	var middle: HBoxContainer = HBoxContainer.new()
	middle.size_flags_vertical = Control.SIZE_EXPAND_FILL
	middle.add_theme_constant_override("separation", 16)
	root.add_child(middle)

	# Plancia a sinistra.
	var board_panel: PanelContainer = UiKit.panel(UiKit.COLOR_PANEL)
	board_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	board_panel.size_flags_stretch_ratio = 1.4
	middle.add_child(board_panel)
	var board_box: VBoxContainer = VBoxContainer.new()
	board_box.add_theme_constant_override("separation", 10)
	board_panel.add_child(board_box)
	board_box.add_child(UiKit.label("La tua plancia", 26))
	_resistance_label = UiKit.label("", 18)
	board_box.add_child(_resistance_label)
	_buildings_title = UiKit.label("", 20)
	board_box.add_child(_buildings_title)
	_buildings_row = _wrapping_row(board_box)
	_troops_title = UiKit.label("", 20)
	board_box.add_child(_troops_title)
	_troops_row = _wrapping_row(board_box)

	# Azioni a destra.
	var action_panel: PanelContainer = UiKit.panel(UiKit.COLOR_PANEL)
	action_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	middle.add_child(action_panel)
	var action_scroll: ScrollContainer = ScrollContainer.new()
	action_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	action_panel.add_child(action_scroll)
	_action_box = VBoxContainer.new()
	_action_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_action_box.add_theme_constant_override("separation", 10)
	action_scroll.add_child(_action_box)

	_message_label = UiKit.wrapped("", 18, UiKit.COLOR_ERROR)
	root.add_child(_message_label)

	_chronicle = RichTextLabel.new()
	_chronicle.custom_minimum_size = Vector2(0, 170)
	_chronicle.scroll_following = true
	root.add_child(_chronicle)

	_battle_layer = Control.new()
	_battle_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_battle_layer.visible = false
	add_child(_battle_layer)


func _wrapping_row(parent: Control) -> HBoxContainer:
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 190)
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	parent.add_child(scroll)
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	scroll.add_child(row)
	return row


# --- Aggiornamento ----------------------------------------------------------

func _new_run() -> void:
	var catalog: CatalogDef = load(CATALOG_PATH) as CatalogDef
	var run_rules: RunRules = load(RUN_RULES_PATH) as RunRules
	var battle_rules: BattleRules = load(BATTLE_RULES_PATH) as BattleRules
	var resistance_rules: ResistanceRules = load(RESISTANCE_RULES_PATH) as ResistanceRules
	# Il seme sceglie le offerte; viene registrato nella run.
	var run_seed: int = randi()
	run = RunState.new(catalog, run_rules, battle_rules, resistance_rules, run_seed)
	_shown_chronicle = 0
	_chronicle.clear()
	_cancel_pending()
	_message_label.text = ""
	_refresh()


func _refresh() -> void:
	_refresh_status()
	_refresh_board()
	_refresh_actions()
	_refresh_chronicle()


func _refresh_status() -> void:
	var preview: Vector2i = run.production_preview()
	var text: String = "Anno %d   ·   %s   ·   Era: %s   ·   Vittorie %d/%d   ·   Prestigio %d" % [
		run.year, run.phase_name(), run.era_name(), run.wins, run.run_rules.wins_needed, run.prestige]
	if run.last_chance:
		text += " (ULTIMA POSSIBILITÀ)"
	text += "   ·   Oro %d (+%d a fase)   ·   Ricerca %d (+%d a fase)" % [run.gold, preview.x, run.research, preview.y]
	_status_label.text = text


func _refresh_board() -> void:
	var board: NationBoard = run.board
	_resistance_label.text = "" if run.is_over() else "Resistenza nel prossimo scontro: %d" % run.player_resistance()
	var replacing_building: bool = _pending_replaces_building()
	var replacing_troop: bool = _pending_replaces_troop()

	_buildings_title.text = "Edifici (%d/%d spazi, massimo %d)" % [board.buildings.size(), board.building_capacity(), board.max_building_slots]
	UiKit.clear(_buildings_row)
	for i: int in range(board.buildings.size()):
		var piece: BoardPiece = board.buildings[i]
		var card: PanelContainer = UiKit.panel(UiKit.COLOR_BUILDING, Vector2(210, 170))
		var box: VBoxContainer = VBoxContainer.new()
		card.add_child(box)
		box.add_child(UiKit.label(piece.building.display_name, 20))
		box.add_child(UiKit.label(UiKit.building_details(piece.building), 14))
		if replacing_building:
			var can_replace: bool = run.board.can_replace_building(i, _pending_building_def())
			box.add_child(UiKit.button("Sostituisci" if can_replace else "Concede spazi occupati", _on_replace.bind(i), can_replace))
		elif not run.is_over():
			var can_sell: bool = run.board.can_sell_building(i)
			var sell_text: String = "Vendi (+%d)" % RunState.half_down(piece.paid) if can_sell else "Concede spazi occupati"
			box.add_child(UiKit.button(sell_text, _on_sell_building.bind(i), can_sell))
		_buildings_row.add_child(card)
	for i: int in range(board.building_capacity() - board.buildings.size()):
		_buildings_row.add_child(_empty_slot())

	_troops_title.text = "Truppe (%d/%d spazi, massimo %d) — in battaglia si valutano da destra verso sinistra" % [board.troops.size(), board.troop_capacity(), board.max_troop_slots]
	UiKit.clear(_troops_row)
	for i: int in range(board.troops.size()):
		var piece: BoardPiece = board.troops[i]
		var card: PanelContainer = UiKit.panel(UiKit.COLOR_TROOP, Vector2(210, 170))
		var box: VBoxContainer = VBoxContainer.new()
		card.add_child(box)
		box.add_child(UiKit.label("%d. %s" % [i + 1, piece.troop.display_name], 20))
		box.add_child(UiKit.label(UiKit.troop_details(piece.troop), 14))
		if replacing_troop:
			box.add_child(UiKit.button("Sostituisci", _on_replace.bind(i)))
		elif not run.is_over():
			var buttons: HBoxContainer = HBoxContainer.new()
			buttons.add_child(UiKit.button("◀", _on_move_troop.bind(i, i - 1), i > 0))
			buttons.add_child(UiKit.button("▶", _on_move_troop.bind(i, i + 1), i < board.troops.size() - 1))
			buttons.add_child(UiKit.button("Vendi (+%d)" % RunState.half_down(piece.paid), _on_sell_troop.bind(i)))
			box.add_child(buttons)
		_troops_row.add_child(card)
	for i: int in range(board.troop_capacity() - board.troops.size()):
		_troops_row.add_child(_empty_slot())


func _empty_slot() -> Control:
	var card: PanelContainer = UiKit.panel(UiKit.COLOR_EMPTY, Vector2(210, 170))
	card.add_child(UiKit.label("Spazio libero", 16, Color(0.6, 0.6, 0.6)))
	return card


func _refresh_actions() -> void:
	UiKit.clear(_action_box)
	if _pending_kind != PendingKind.NESSUNA:
		_action_box.add_child(UiKit.wrapped("Plancia piena: clicca «Sostituisci» sull'elemento da rimpiazzare.\nRiceverai metà del prezzo che avevi pagato.", 20, UiKit.COLOR_WARNING))
		_action_box.add_child(UiKit.button("Annulla", _on_cancel_pending))
		return
	match run.phase:
		RunState.Phase.PRODUZIONE, RunState.Phase.PREPARAZIONE:
			_show_opportunity()
		RunState.Phase.SCELTA_INCONTRO:
			_show_encounters()
		RunState.Phase.RICOMPENSA_INCONTRO:
			_show_rewards()
		RunState.Phase.SCONTRO_FANTASMA:
			_show_ghost()
		RunState.Phase.FINE_RUN:
			_show_end()


func _show_opportunity() -> void:
	var theme_text: String = "costruzione" if run.phase == RunState.Phase.PRODUZIONE else "reclutamento"
	_action_box.add_child(UiKit.wrapped("%s — opportunità %d di %d (%s)" % [run.phase_name(), run.opportunity_number, run.run_rules.opportunities_per_phase, theme_text], 24))
	_action_box.add_child(UiKit.wrapped("Scegli un'alternativa, rinnova le offerte o lascia passare l'opportunità.", 16))
	for i: int in range(run.offers.size()):
		var offer: Offer = run.offers[i]
		var card: PanelContainer = UiKit.panel(UiKit.COLOR_OFFER)
		var box: VBoxContainer = VBoxContainer.new()
		card.add_child(box)
		box.add_child(UiKit.wrapped("%s — %d Oro" % [offer.describe(), offer.price], 20))
		match offer.kind:
			Offer.Kind.EDIFICIO:
				box.add_child(UiKit.wrapped(UiKit.building_details(offer.building), 15))
			Offer.Kind.TRUPPA:
				box.add_child(UiKit.wrapped(UiKit.troop_details(offer.troop), 15))
			_:
				box.add_child(UiKit.wrapped("Aggiunge uno spazio alla plancia.", 15))
		var note: String = " (plancia piena: sostituzione)" if run.offer_needs_replacement(offer) else ""
		box.add_child(UiKit.button("Prendi" + note, _on_buy.bind(i), offer.price <= run.gold + _max_refund()))
		_action_box.add_child(card)

	var buttons: HBoxContainer = HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 10)
	buttons.add_child(UiKit.button("Rinnova le offerte (%d Oro)" % run.reroll_cost(), _on_reroll, run.gold >= run.reroll_cost()))
	buttons.add_child(UiKit.button("Lascia passare", _on_pass))
	_action_box.add_child(buttons)

	var era_cost: int = run.next_era_cost()
	if era_cost >= 0:
		_action_box.add_child(UiKit.wrapped("Ricerca: per entrare nell'era %s servono %d Ricerca (ne hai %d). Non consuma l'opportunità." % [run.era_name(run.era + 1), era_cost, run.research], 16))
		_action_box.add_child(UiKit.button("Avanza all'era %s" % run.era_name(run.era + 1), _on_advance_era, run.research >= era_cost))
	else:
		_action_box.add_child(UiKit.wrapped("Hai raggiunto l'ultima era disponibile.", 16))


func _show_encounters() -> void:
	_action_box.add_child(UiKit.wrapped("Incontro del mondo — scegli quale minaccia affrontare", 24))
	_action_box.add_child(UiKit.wrapped("Se perdi, l'Oro del Magazzino si dimezza. Se vinci, puoi scegliere una ricompensa.", 16))
	for i: int in range(run.encounter_choices.size()):
		var encounter: EncounterDef = run.encounter_choices[i]
		var card: PanelContainer = UiKit.panel(UiKit.COLOR_ENCOUNTER)
		var box: VBoxContainer = VBoxContainer.new()
		card.add_child(box)
		box.add_child(UiKit.wrapped("%s — %s" % [encounter.display_name, encounter.difficulty_label], 20))
		box.add_child(UiKit.wrapped(encounter.description, 15))
		box.add_child(UiKit.wrapped("Resistenza %d · Edifici: %s · Truppe: %s" % [encounter.resistance, _names_b(encounter.buildings), _names_t(encounter.troops)], 15))
		var rewards: PackedStringArray = PackedStringArray()
		for reward: RewardDef in encounter.rewards:
			rewards.append(reward.describe())
		box.add_child(UiKit.wrapped("Ricompense possibili: %s" % ", ".join(rewards), 15))
		box.add_child(UiKit.button("Affronta", _on_encounter.bind(i)))
		_action_box.add_child(card)


func _show_rewards() -> void:
	_action_box.add_child(UiKit.wrapped("Ricompensa — scegline una, oppure nessuna", 24))
	var rewards: Array[RewardDef] = run.reward_choices()
	for i: int in range(rewards.size()):
		var reward: RewardDef = rewards[i]
		var card: PanelContainer = UiKit.panel(UiKit.COLOR_REWARD)
		var box: VBoxContainer = VBoxContainer.new()
		card.add_child(box)
		box.add_child(UiKit.wrapped(reward.describe(), 20))
		if reward.kind == RewardDef.Kind.EDIFICIO:
			box.add_child(UiKit.wrapped(UiKit.building_details(reward.building), 15))
		elif reward.kind == RewardDef.Kind.TRUPPA:
			box.add_child(UiKit.wrapped(UiKit.troop_details(reward.troop), 15))
		var note: String = " (plancia piena: sostituzione)" if run.reward_needs_replacement(reward) else ""
		box.add_child(UiKit.button("Prendi" + note, _on_reward.bind(i)))
		_action_box.add_child(card)
	_action_box.add_child(UiKit.button("Nessuna ricompensa", _on_skip_reward))


func _show_ghost() -> void:
	_action_box.add_child(UiKit.wrapped("Scontro con il fantasma dell'anno", 24))
	var ghost: GhostDef = run.current_ghost
	if ghost != null:
		var card: PanelContainer = UiKit.panel(UiKit.COLOR_ENCOUNTER)
		var box: VBoxContainer = VBoxContainer.new()
		card.add_child(box)
		box.add_child(UiKit.wrapped(ghost.display_name, 20))
		box.add_child(UiKit.wrapped("Era: %s · Resistenza %d" % [run.era_name(ghost.era), run.ghost_resistance()], 15))
		box.add_child(UiKit.wrapped("Edifici: %s" % _names_b(ghost.buildings), 15))
		box.add_child(UiKit.wrapped("Truppe (da sinistra a destra): %s" % _names_t(ghost.troops), 15))
		_action_box.add_child(card)
	_action_box.add_child(UiKit.wrapped("Puoi ancora riordinare o vendere le truppe prima di combattere.\nSe perdi, perdi %d Prestigio." % run.year, 16))
	_action_box.add_child(UiKit.button("Combatti", _on_fight_ghost))


func _show_end() -> void:
	var text: String = ""
	match run.run_end:
		RunState.RunEnd.VITTORIA:
			text = "Hai vinto la run!"
		RunState.RunEnd.SCONFITTA:
			text = "La run è finita con una sconfitta."
		RunState.RunEnd.FINE_PROVA:
			text = "Fine della run di prova (%d anni)." % run.year
	_action_box.add_child(UiKit.wrapped(text, 28, UiKit.COLOR_WARNING))
	_action_box.add_child(UiKit.wrapped("Vittorie: %d · Prestigio: %d · Seme della run: %d" % [run.wins, run.prestige, run.run_seed], 18))
	_action_box.add_child(UiKit.button("Nuova run", _new_run))


func _refresh_chronicle() -> void:
	while _shown_chronicle < run.chronicle.size():
		var line: String = run.chronicle[_shown_chronicle]
		if line.begins_with("—"):
			_chronicle.push_bold()
			_chronicle.add_text(line + "\n")
			_chronicle.pop()
		else:
			_chronicle.add_text(line + "\n")
		_shown_chronicle += 1


# --- Azioni del giocatore ---------------------------------------------------

func _act(success: bool) -> void:
	_message_label.text = "" if success else run.last_error
	_refresh()


func _on_buy(index: int) -> void:
	if run.offer_needs_replacement(run.offers[index]):
		_start_pending(PendingKind.OFFERTA, index)
		return
	_act(run.buy_offer(index))


func _on_reward(index: int) -> void:
	if run.reward_needs_replacement(run.reward_choices()[index]):
		_start_pending(PendingKind.RICOMPENSA, index)
		return
	_act(run.take_reward(index))


func _on_replace(replace_index: int) -> void:
	var kind: PendingKind = _pending_kind
	var index: int = _pending_index
	_cancel_pending()
	if kind == PendingKind.OFFERTA:
		_act(run.buy_offer(index, replace_index))
	elif kind == PendingKind.RICOMPENSA:
		_act(run.take_reward(index, replace_index))


func _on_cancel_pending() -> void:
	_cancel_pending()
	_refresh()


func _on_reroll() -> void:
	_act(run.reroll_offers())


func _on_pass() -> void:
	_act(run.pass_opportunity())


func _on_advance_era() -> void:
	_act(run.advance_era())


func _on_sell_building(index: int) -> void:
	_act(run.sell_building(index))


func _on_sell_troop(index: int) -> void:
	_act(run.sell_troop(index))


func _on_move_troop(from_index: int, to_index: int) -> void:
	_act(run.move_troop(from_index, to_index))


func _on_skip_reward() -> void:
	_act(run.skip_reward())


func _on_encounter(index: int) -> void:
	var encounter_name: String = run.encounter_choices[index].display_name
	var ok: bool = run.choose_encounter(index)
	_act(ok)
	if ok:
		_show_battle("Incontro del mondo: %s" % encounter_name)


func _on_fight_ghost() -> void:
	var ok: bool = run.fight_ghost()
	_act(ok)
	if ok:
		_show_battle("Scontro con il fantasma")


func _show_battle(title: String) -> void:
	UiKit.clear(_battle_layer)
	var view: BattleView = BattleView.new()
	view.set_anchors_preset(Control.PRESET_FULL_RECT)
	_battle_layer.add_child(view)
	view.setup(run.make_battle_replay(), run.last_battle_setups(), title, run.last_opponent_name)
	view.closed.connect(_on_battle_closed)
	_battle_layer.visible = true


func _on_battle_closed() -> void:
	_battle_layer.visible = false
	UiKit.clear(_battle_layer)
	_refresh()


# --- Aiuti ------------------------------------------------------------------

func _start_pending(kind: PendingKind, index: int) -> void:
	_pending_kind = kind
	_pending_index = index
	_message_label.text = ""
	_refresh()


func _cancel_pending() -> void:
	_pending_kind = PendingKind.NESSUNA
	_pending_index = -1


func _pending_replaces_building() -> bool:
	if _pending_kind == PendingKind.OFFERTA:
		return run.offers[_pending_index].kind == Offer.Kind.EDIFICIO
	if _pending_kind == PendingKind.RICOMPENSA:
		return run.reward_choices()[_pending_index].kind == RewardDef.Kind.EDIFICIO
	return false


func _pending_building_def() -> BuildingDef:
	if _pending_kind == PendingKind.OFFERTA:
		return run.offers[_pending_index].building
	if _pending_kind == PendingKind.RICOMPENSA:
		return run.reward_choices()[_pending_index].building
	return null


func _pending_replaces_troop() -> bool:
	if _pending_kind == PendingKind.OFFERTA:
		return run.offers[_pending_index].kind == Offer.Kind.TRUPPA
	if _pending_kind == PendingKind.RICOMPENSA:
		return run.reward_choices()[_pending_index].kind == RewardDef.Kind.TRUPPA
	return false


## Rimborso più alto ottenibile sostituendo un elemento (solo per abilitare il pulsante;
## il controllo vero lo fa RunState).
func _max_refund() -> int:
	var best: int = 0
	for piece: BoardPiece in run.board.buildings + run.board.troops:
		best = maxi(best, RunState.half_down(piece.paid))
	return best


func _names_b(defs: Array[BuildingDef]) -> String:
	var names: PackedStringArray = PackedStringArray()
	for def: BuildingDef in defs:
		names.append(def.display_name)
	return ", ".join(names) if not names.is_empty() else "nessuno"


func _names_t(defs: Array[TroopDef]) -> String:
	var names: PackedStringArray = PackedStringArray()
	for def: TroopDef in defs:
		names.append(def.display_name)
	return ", ".join(names) if not names.is_empty() else "nessuna"
