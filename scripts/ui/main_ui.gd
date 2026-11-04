extends Control
## Interfaccia provvisoria della run (GDD §14.3, §15.2).
## Legge lo stato di RunState e chiama le sue azioni: nessuna regola di gioco qui.

## OFFERTA/RICOMPENSA: si sceglie cosa sostituire; SCELTA_OFFERTA: si sceglie una voce interna.
enum PendingKind { NESSUNA, OFFERTA, RICOMPENSA, SCELTA_OFFERTA }

var run: RunState

var _status_label: Label
var _resources_label: Label
var _buildings_title: Label
var _buildings_row: HBoxContainer
var _troops_title: Label
var _troops_row: HBoxContainer
var _resistance_label: Label
var _modifiers_box: VBoxContainer
var _action_box: VBoxContainer
var _message_label: Label
var _chronicle: RichTextLabel
var _battle_layer: Control

## Offerta o ricompensa in attesa che il giocatore scelga cosa sostituire.
var _pending_kind: PendingKind = PendingKind.NESSUNA
var _pending_index: int = -1
var _shown_chronicle: int = 0
var _board_title: Label
var _identity_label: Label


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
	top.add_child(UiKit.button("Ricomincia", _new_run))
	top.add_child(UiKit.button("Menu principale", _on_menu))
	_resources_label = UiKit.wrapped("", 17, Color(0.85, 0.85, 0.75))
	root.add_child(_resources_label)

	var middle: HBoxContainer = HBoxContainer.new()
	middle.size_flags_vertical = Control.SIZE_EXPAND_FILL
	middle.add_theme_constant_override("separation", 16)
	root.add_child(middle)

	# Plancia a sinistra.
	var board_panel: PanelContainer = UiKit.panel(UiKit.COLOR_PANEL)
	board_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	board_panel.size_flags_stretch_ratio = 1.4
	middle.add_child(board_panel)
	var board_scroll: ScrollContainer = ScrollContainer.new()
	board_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	board_panel.add_child(board_scroll)
	var board_box: VBoxContainer = VBoxContainer.new()
	board_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	board_box.add_theme_constant_override("separation", 10)
	board_scroll.add_child(board_box)
	_board_title = UiKit.label("La tua plancia", 26)
	board_box.add_child(_board_title)
	_identity_label = UiKit.wrapped("", 16, Color(0.75, 0.8, 1.0))
	board_box.add_child(_identity_label)
	_resistance_label = UiKit.label("", 18)
	board_box.add_child(_resistance_label)
	_modifiers_box = VBoxContainer.new()
	board_box.add_child(_modifiers_box)
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

## Nuova run con la nazione scelta nel menu (o con una nazione di prova se si avvia
## questa scena da sola in Godot).
func _new_run() -> void:
	var catalog: CatalogDef = GameSession.catalog()
	var run_rules: RunRules = GameSession.run_rules()
	var nation: NationTemplate = GameSession.selected_nation
	if nation == null or nation.problem(catalog, run_rules) != "":
		nation = _test_nation(catalog, run_rules)
	# Il seme sceglie le offerte; viene registrato nella run.
	var run_seed: int = randi()
	run = RunState.new(catalog, run_rules, GameSession.battle_rules(), GameSession.resistance_rules(), run_seed)
	if run.phase == RunState.Phase.CREAZIONE_NAZIONE:
		run.found_nation(nation.nation_name, nation.resolve(catalog))
	_shown_chronicle = 0
	_chronicle.clear()
	_cancel_pending()
	_message_label.text = ""
	_refresh()


## Nazione di prova: il primo elemento di ogni dimensione e i primi perk.
func _test_nation(catalog: CatalogDef, run_rules: RunRules) -> NationTemplate:
	var choices: Array[IdentityDef] = []
	for dimension: IdentityDef.Dimension in IdentityDef.CREATION_DIMENSIONS:
		var options: Array[IdentityDef] = IdentityRules.options(catalog, dimension)
		var count: int = IdentityRules.starting_perk_count(catalog, run_rules) if dimension == IdentityDef.Dimension.PERK else mini(1, options.size())
		for i: int in range(count):
			choices.append(options[i])
	return NationTemplate.from_choices("prova", "Nazione di prova", choices)


func _on_menu() -> void:
	GameSession.go(GameSession.MENU_SCENE)


func _refresh() -> void:
	_refresh_status()
	_refresh_board()
	_refresh_actions()
	_refresh_chronicle()


func _refresh_status() -> void:
	var text: String = "Anno %d   ·   %s   ·   Era: %s   ·   Vittorie %d/%d   ·   Prestigio %d" % [
		run.year, run.phase_name(), run.era_name(), run.wins, run.run_rules.wins_needed, run.prestige]
	if run.last_chance:
		text += " (ULTIMA POSSIBILITÀ)"
	_status_label.text = text
	var produced: Array[int] = run.production_per_phase()
	var parts: PackedStringArray = PackedStringArray()
	for type: Res.Type in Res.NAMES:
		parts.append("%s %s (+%s)" % [Res.NAMES[type], run.stock_text(type), Res.format(type, produced[type])])
	var upkeep: int = 0
	for piece: BoardPiece in run.board.troops:
		upkeep += piece.troop.food_tenths
	_resources_label.text = "   ·   ".join(parts) + "   —   Cibo richiesto dalle truppe a inizio anno: %s" % Res.format(Res.Type.CIBO, upkeep)


func _refresh_board() -> void:
	var board: NationBoard = run.board
	_board_title.text = run.nation_name
	var perk_names: PackedStringArray = PackedStringArray()
	for perk: IdentityDef in run.perks():
		perk_names.append(perk.display_name)
	if run.identity.is_empty():
		_identity_label.text = ""
	else:
		_identity_label.text = "%s\nPerk: %s" % [run.identity_summary(), ", ".join(perk_names) if not perk_names.is_empty() else "nessuno"]
	_resistance_label.text = "" if run.is_over() else "Resistenza nel prossimo scontro: %d" % run.player_resistance()
	if run.phase == RunState.Phase.CREAZIONE_NAZIONE:
		_resistance_label.text = ""
	UiKit.clear(_modifiers_box)
	var trait_counts: Dictionary[String, int] = {}
	var temporary: Array[ActiveModifier] = []
	for modifier: ActiveModifier in run.modifiers.active:
		if modifier.def.duration_kind == ModifierDef.Duration.PERMANENTE:
			trait_counts[modifier.def.display_name] = trait_counts.get(modifier.def.display_name, 0) + 1
		else:
			temporary.append(modifier)
	if not trait_counts.is_empty():
		var traits: PackedStringArray = PackedStringArray()
		for trait_name: String in trait_counts:
			var count: int = trait_counts[trait_name]
			traits.append(trait_name if count == 1 else "%s ×%d" % [trait_name, count])
		_modifiers_box.add_child(UiKit.wrapped("Tratti permanenti: " + " · ".join(traits), 14, Color(0.5, 0.9, 0.5)))
	if not temporary.is_empty():
		_modifiers_box.add_child(UiKit.label("Effetti attivi:", 18, UiKit.COLOR_WARNING))
		for modifier: ActiveModifier in temporary:
			var color: Color = UiKit.COLOR_ERROR if modifier.def.is_malus else Color(0.5, 0.9, 0.5)
			_modifiers_box.add_child(UiKit.wrapped("• %s\n   %s" % [modifier.describe(), modifier.def.description], 15, color))
	var replacing_building: bool = _pending_replaces_building()
	var replacing_troop: bool = _pending_replaces_troop()

	_buildings_title.text = "Edifici (%d/%d spazi, massimo %d)" % [board.buildings.size(), board.building_capacity(), board.max_building_slots]
	UiKit.clear(_buildings_row)
	for i: int in range(board.buildings.size()):
		var piece: BoardPiece = board.buildings[i]
		var card: PanelContainer = UiKit.panel(UiKit.COLOR_BUILDING, Vector2(230, 170))
		var box: VBoxContainer = VBoxContainer.new()
		card.add_child(box)
		box.add_child(UiKit.label(piece.building.display_name, 20))
		box.add_child(UiKit.wrapped(UiKit.building_details(run.effective_building(piece), run.building_production(piece)), 14))
		_add_piece_modifiers(box, piece)
		_add_level(box, piece)
		if replacing_building:
			var can_replace: bool = run.board.can_replace_building(i, _pending_building_def())
			box.add_child(UiKit.button("Sostituisci" if can_replace else "Concede spazi occupati", _on_replace.bind(i), can_replace))
		elif not run.is_over():
			_add_upgrade_button(box, piece, _on_upgrade_building.bind(i))
			if piece.building.is_capital:
				box.add_child(UiKit.label("Non si vende", 14, Color(0.7, 0.7, 0.7)))
			else:
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
		var card: PanelContainer = UiKit.panel(UiKit.COLOR_TROOP, Vector2(230, 170))
		var box: VBoxContainer = VBoxContainer.new()
		card.add_child(box)
		box.add_child(UiKit.label("%d. %s" % [i + 1, piece.troop.display_name], 20))
		box.add_child(UiKit.wrapped(UiKit.troop_details(run.effective_troop(piece)), 14))
		_add_piece_modifiers(box, piece)
		_add_level(box, piece)
		if piece.hungry:
			box.add_child(UiKit.label("⚠ Affamata: ricarica ×1,5", 14, UiKit.COLOR_ERROR))
		if replacing_troop:
			box.add_child(UiKit.button("Sostituisci", _on_replace.bind(i)))
		elif not run.is_over():
			var buttons: HBoxContainer = HBoxContainer.new()
			buttons.add_child(UiKit.button("◀", _on_move_troop.bind(i, i - 1), i > 0))
			buttons.add_child(UiKit.button("▶", _on_move_troop.bind(i, i + 1), i < board.troops.size() - 1))
			buttons.add_child(UiKit.button("Vendi (+%d)" % RunState.half_down(piece.paid), _on_sell_troop.bind(i)))
			box.add_child(buttons)
			_add_upgrade_button(box, piece, _on_upgrade_troop.bind(i))
		_troops_row.add_child(card)
	for i: int in range(board.troop_capacity() - board.troops.size()):
		_troops_row.add_child(_empty_slot())


func _add_level(box: VBoxContainer, piece: BoardPiece) -> void:
	if piece.level > 1:
		box.add_child(UiKit.label("Livello %d" % piece.level, 14, Color(0.95, 0.85, 0.55)))


## Pulsante "Potenzia" con il costo del prossimo livello (GDD §6.5).
func _add_upgrade_button(box: VBoxContainer, piece: BoardPiece, callback: Callable) -> void:
	var cost: ResourceAmounts = run.upgrade_cost_of(piece)
	if cost == null:
		return
	box.add_child(UiKit.button("Potenzia (%s)" % cost.describe(), callback, run.can_pay(cost)))


func _on_upgrade_building(index: int) -> void:
	_act(run.upgrade_building(index))


func _on_upgrade_troop(index: int) -> void:
	_act(run.upgrade_troop(index))


## Mercato delle risorse (GDD §5.3): vende a gruppi al tasso fisso.
func _show_market() -> void:
	var rate: int = run.run_rules.market_units_per_gold
	_action_box.add_child(UiKit.wrapped("Mercato: vendi %d unità di una risorsa per 1 Oro (non consuma l'opportunità)." % rate, 16))
	var grid: GridContainer = GridContainer.new()
	grid.columns = 4
	for type: Res.Type in Res.NAMES:
		if type == Res.Type.ORO:
			continue
		var enough: bool = run.stock[type] >= rate * Res.scale(type)
		grid.add_child(UiKit.button("Vendi %d %s" % [rate, Res.NAMES[type]], _on_sell_resource.bind(type), enough))
	_action_box.add_child(grid)


func _on_sell_resource(type: Res.Type) -> void:
	_act(run.sell_resource(type, run.run_rules.market_units_per_gold))


## Segnala sulla carta i malus o bonus che colpiscono proprio quell'elemento.
func _add_piece_modifiers(box: VBoxContainer, piece: BoardPiece) -> void:
	for modifier: ActiveModifier in run.modifiers.for_piece(piece):
		var color: Color = UiKit.COLOR_ERROR if modifier.def.is_malus else Color(0.5, 0.9, 0.5)
		box.add_child(UiKit.label("⚠ %s" % modifier.def.display_name, 14, color))


func _empty_slot() -> Control:
	var card: PanelContainer = UiKit.panel(UiKit.COLOR_EMPTY, Vector2(210, 170))
	card.add_child(UiKit.label("Spazio libero", 16, Color(0.6, 0.6, 0.6)))
	return card


func _refresh_actions() -> void:
	UiKit.clear(_action_box)
	if _pending_kind == PendingKind.SCELTA_OFFERTA:
		_show_offer_choices()
		return
	if _pending_kind != PendingKind.NESSUNA:
		_action_box.add_child(UiKit.wrapped("Plancia piena: clicca «Sostituisci» sull'elemento da rimpiazzare.\nRiceverai metà del prezzo che avevi pagato.", 20, UiKit.COLOR_WARNING))
		_action_box.add_child(UiKit.button("Annulla", _on_cancel_pending))
		return
	if not run.way_choices.is_empty():
		_show_ways()
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
	var theme_text: String = "costruzione" if run.phase == RunState.Phase.PRODUZIONE else "disposizione"
	_action_box.add_child(UiKit.wrapped("%s — opportunità %d di %d (%s)" % [run.phase_name(), run.opportunity_number, run.run_rules.opportunities_per_phase, theme_text], 24))
	_action_box.add_child(UiKit.wrapped("Scegli un'alternativa, rinnova le offerte o lascia passare l'opportunità.", 16))
	for i: int in range(run.offers.size()):
		var offer: Offer = run.offers[i]
		var card: PanelContainer = UiKit.panel(UiKit.COLOR_OFFER)
		var box: VBoxContainer = VBoxContainer.new()
		card.add_child(box)
		box.add_child(UiKit.wrapped("%s — %s" % [offer.describe(), offer.cost_text()], 20))
		match offer.kind:
			OpportunityDef.Kind.COSTRUISCI_EDIFICIO:
				box.add_child(UiKit.wrapped(UiKit.building_details(offer.building), 15))
			OpportunityDef.Kind.RECLUTA_TRUPPA:
				box.add_child(UiKit.wrapped(UiKit.troop_details(offer.troop), 15))
			_:
				box.add_child(UiKit.wrapped(offer.opportunity.description, 15))
		var note: String = ""
		var enabled: bool = run.can_afford(offer)
		if run.offer_needs_replacement(offer):
			note = " (plancia piena: sostituzione)"
			enabled = offer.price <= run.gold + _max_refund()
		elif not run.offer_choices(offer).is_empty():
			note = " (poi scegli)"
		box.add_child(UiKit.button("Prendi" + note, _on_buy.bind(i), enabled))
		_action_box.add_child(card)

	var buttons: HBoxContainer = HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 10)
	buttons.add_child(UiKit.button("Rinnova le offerte (%d Oro)" % run.reroll_cost(), _on_reroll, run.gold >= run.reroll_cost()))
	buttons.add_child(UiKit.button("Lascia passare", _on_pass))
	_action_box.add_child(buttons)

	_show_market()

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
		for def: ModifierDef in ghost.malus:
			box.add_child(UiKit.wrapped("Se perdi o pareggi subisci: %s per %d anno/i — %s" % [def.display_name, def.duration_years, def.description], 15, UiKit.COLOR_WARNING))
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
	_action_box.add_child(UiKit.wrapped("%s — %d anni · Vittorie %d/%d · Prestigio %d · Era %s · Seme %d" % [
		run.nation_name, run.year, run.wins, run.run_rules.wins_needed, run.prestige, run.era_name(), run.run_seed], 18))
	_action_box.add_child(UiKit.button("Nuova run con la stessa nazione", _new_run))
	_action_box.add_child(UiKit.button("Menu principale", _on_menu))
	_action_box.add_child(UiKit.label("Riepilogo anno per anno", 22, UiKit.COLOR_WARNING))
	var table: GridContainer = GridContainer.new()
	table.columns = 6
	table.add_theme_constant_override("h_separation", 18)
	for heading: String in ["Anno", "Era", "Incontro", "Fantasma", "Vittorie", "Prestigio"]:
		table.add_child(UiKit.label(heading, 16, Color(0.75, 0.8, 1.0)))
	for record: RunState.YearRecord in run.history:
		table.add_child(UiKit.label(str(record.year), 15))
		table.add_child(UiKit.label(run.era_name(record.era), 15))
		table.add_child(UiKit.label("%s: %s" % [record.encounter_name, record.encounter_result] if record.encounter_name != "" else "—", 15, _result_color(record.encounter_result)))
		table.add_child(UiKit.label("%s: %s" % [record.ghost_name.trim_prefix("Fantasma: "), record.ghost_result] if record.ghost_name != "" else "—", 15, _result_color(record.ghost_result)))
		table.add_child(UiKit.label(str(record.wins_after), 15))
		table.add_child(UiKit.label(str(record.prestige_after), 15))
	_action_box.add_child(table)


func _result_color(result: String) -> Color:
	match result:
		"Vittoria", "Pareggio":
			return Color(0.55, 0.9, 0.55)
		"Sconfitta":
			return UiKit.COLOR_ERROR
	return Color.WHITE


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
	if not run.offer_choices(run.offers[index]).is_empty():
		_start_pending(PendingKind.SCELTA_OFFERTA, index)
		return
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


## Scelta della via entrando in una nuova era (GDD §10.4).
func _show_ways() -> void:
	_action_box.add_child(UiKit.wrapped("Nuova era: %s — scegli la via della nazione" % run.era_name(), 24))
	_action_box.add_child(UiKit.wrapped("La via diventa parte della tua identità: offerte, elementi esclusivi, un tratto permanente e un bonus immediato.", 16))
	for i: int in range(run.way_choices.size()):
		var way: IdentityDef = run.way_choices[i]
		var card: PanelContainer = UiKit.panel(UiKit.COLOR_ENCOUNTER)
		var box: VBoxContainer = VBoxContainer.new()
		card.add_child(box)
		box.add_child(UiKit.wrapped(way.display_name, 20))
		box.add_child(UiKit.wrapped(way.description, 15))
		box.add_child(UiKit.button("Scegli questa via", _on_choose_way.bind(i)))
		_action_box.add_child(card)


func _on_choose_way(index: int) -> void:
	_act(run.choose_way(index))


## Seconda scelta di un'offerta (quale bonus, quale truppa, quale malus).
func _show_offer_choices() -> void:
	var offer: Offer = run.offers[_pending_index]
	_action_box.add_child(UiKit.wrapped("%s — scegli:" % offer.describe(), 24))
	_action_box.add_child(UiKit.wrapped(offer.opportunity.description, 16))
	var labels: Array[String] = run.offer_choices(offer)
	for i: int in range(labels.size()):
		_action_box.add_child(UiKit.button(labels[i], _on_offer_choice.bind(i)))
	_action_box.add_child(UiKit.button("Annulla", _on_cancel_pending))


func _on_offer_choice(choice: int) -> void:
	var index: int = _pending_index
	_cancel_pending()
	_act(run.buy_offer(index, choice))


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
		return run.offers[_pending_index].kind == OpportunityDef.Kind.COSTRUISCI_EDIFICIO
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
		return run.offers[_pending_index].kind == OpportunityDef.Kind.RECLUTA_TRUPPA
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
