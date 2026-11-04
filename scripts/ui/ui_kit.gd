class_name UiKit
extends RefCounted
## Piccoli aiuti per costruire l'interfaccia provvisoria (segnaposto, GDD §14).
## Nessuna regola di gioco qui: solo forma e colori.

const COLOR_BUILDING: Color = Color(0.36, 0.27, 0.16)
const COLOR_TROOP: Color = Color(0.42, 0.17, 0.17)
const COLOR_EMPTY: Color = Color(0.2, 0.2, 0.22)
const COLOR_OFFER: Color = Color(0.17, 0.27, 0.36)
const COLOR_ENCOUNTER: Color = Color(0.3, 0.2, 0.36)
const COLOR_REWARD: Color = Color(0.18, 0.34, 0.22)
const COLOR_PANEL: Color = Color(0.12, 0.12, 0.14)
const COLOR_WARNING: Color = Color(1.0, 0.75, 0.3)
const COLOR_ERROR: Color = Color(1.0, 0.45, 0.45)


static func panel(color: Color, min_size: Vector2 = Vector2.ZERO) -> PanelContainer:
	var container: PanelContainer = PanelContainer.new()
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(6)
	style.set_content_margin_all(10)
	style.border_color = color.lightened(0.25)
	style.set_border_width_all(2)
	container.add_theme_stylebox_override("panel", style)
	container.custom_minimum_size = min_size
	return container


## Scritta su una riga (va a capo solo dove il testo contiene "\n").
static func label(text: String, size: int = 0, color: Color = Color.WHITE) -> Label:
	var result: Label = Label.new()
	result.text = text
	if size > 0:
		result.add_theme_font_size_override("font_size", size)
	if color != Color.WHITE:
		result.add_theme_color_override("font_color", color)
	return result


## Scritta che va a capo da sola: da usare solo in colonne con larghezza definita.
static func wrapped(text: String, size: int = 0, color: Color = Color.WHITE) -> Label:
	var result: Label = label(text, size, color)
	result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return result


static func button(text: String, callback: Callable, enabled: bool = true) -> Button:
	var result: Button = Button.new()
	result.text = text
	result.disabled = not enabled
	result.pressed.connect(callback)
	return result


static func clear(node: Node) -> void:
	for child: Node in node.get_children():
		node.remove_child(child)
		child.queue_free()


static func seconds(ms: int) -> String:
	return "%.1f s" % (ms / 1000.0)


static func building_details(def: BuildingDef) -> String:
	var parts: PackedStringArray = PackedStringArray()
	if def.gold_per_phase > 0:
		parts.append("+%d Oro" % def.gold_per_phase)
	if def.research_per_phase > 0:
		parts.append("+%d Ricerca" % def.research_per_phase)
	var economy: String = ", ".join(parts) + " a fase" if not parts.is_empty() else "Nessuna risorsa"
	var text: String = "%s\nMana: +%d ogni %s" % [economy, def.mana_amount, seconds(def.mana_interval_ms)]
	if def.extra_building_slots > 0:
		text += "\n+%d spazio edificio" % def.extra_building_slots
	if def.extra_troop_slots > 0:
		text += "\n+%d spazio truppa" % def.extra_troop_slots
	return text


static func troop_details(def: TroopDef) -> String:
	var cost: String = "senza mana" if def.mana_cost == 0 else "%d mana" % def.mana_cost
	return "Danno %d, %s\nRicarica %s" % [def.damage, cost, seconds(def.cooldown_ms)]


## Riassunto dell'identità: "Popolo · Governo · ..." e i perk su una seconda riga.
static func identity_text(defs: Array[IdentityDef]) -> String:
	var main: PackedStringArray = PackedStringArray()
	var perks: PackedStringArray = PackedStringArray()
	for def: IdentityDef in defs:
		if def.dimension == IdentityDef.Dimension.PERK:
			perks.append(def.display_name)
		else:
			main.append(def.display_name)
	return "%s\nPerk: %s" % [" · ".join(main), ", ".join(perks) if not perks.is_empty() else "nessuno"]


## Sfondo a tutto schermo e margini standard; restituisce il contenitore in cui costruire.
static func screen(root: Control) -> MarginContainer:
	var ui_theme: Theme = Theme.new()
	ui_theme.default_font_size = 18
	root.theme = ui_theme
	var background: ColorRect = ColorRect.new()
	background.color = Color(0.09, 0.09, 0.11)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(background)
	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	root.add_child(margin)
	return margin


## Pulsante grande per menu e schermate principali.
static func big_button(text: String, callback: Callable, enabled: bool = true) -> Button:
	var result: Button = button(text, callback, enabled)
	result.custom_minimum_size = Vector2(420, 64)
	result.add_theme_font_size_override("font_size", 26)
	var states: Dictionary[String, Color] = {
		"normal": Color(0.2, 0.24, 0.32),
		"hover": Color(0.28, 0.34, 0.46),
		"pressed": Color(0.16, 0.2, 0.27),
		"disabled": Color(0.15, 0.15, 0.17),
		"focus": Color(0.28, 0.34, 0.46),
	}
	for state: String in states:
		var style: StyleBoxFlat = StyleBoxFlat.new()
		style.bg_color = states[state]
		style.set_corner_radius_all(8)
		style.border_color = Color(0.95, 0.85, 0.55, 0.6 if state != "disabled" else 0.15)
		style.set_border_width_all(2)
		if state == "focus":
			style.draw_center = false
		result.add_theme_stylebox_override(state, style)
	return result
