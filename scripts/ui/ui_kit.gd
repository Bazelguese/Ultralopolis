class_name UiKit
extends RefCounted
## Piccoli aiuti per costruire l'interfaccia (GDD §14).
## Nessuna regola di gioco qui: solo forma e colori.
## Colori e caratteri seguono lo stile del gioco (StileVisivo).

const COLOR_BUILDING: Color = Color("3a3014")
const COLOR_TROOP: Color = Color("3b1822")
const COLOR_EMPTY: Color = Color("18202f")
const COLOR_OFFER: Color = Color("1d2a4a")
const COLOR_ENCOUNTER: Color = Color("35193c")
const COLOR_REWARD: Color = Color("163a2a")
const COLOR_PANEL: Color = Color("0f1626")
const COLOR_WARNING: Color = Color("ffd76a")
const COLOR_ERROR: Color = Color("ff7b7b")


static func panel(color: Color, min_size: Vector2 = Vector2.ZERO) -> PanelContainer:
	var container: PanelContainer = PanelContainer.new()
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(color, 0.92)
	style.set_corner_radius_all(12)
	style.set_content_margin_all(12)
	style.border_color = color.lightened(0.3)
	style.set_border_width_all(2)
	style.anti_aliasing = true
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


## Colori associati ai colori del mana, per le scritte.
const MANA_TEXT_COLORS: Dictionary[StringName, Color] = {
	&"rosso": Color(1.0, 0.5, 0.45),
	&"verde": Color(0.55, 0.9, 0.55),
	&"blu": Color(0.55, 0.75, 1.0),
	&"viola": Color(0.8, 0.55, 1.0),
	&"energetico": Color(1.0, 0.9, 0.45),
}


## Descrizione di un edificio. produced: produzione per fase in unità interne
## (se vuota si usa quella di base della scheda).
static func building_details(def: BuildingDef, produced: Array[int] = []) -> String:
	var parts: PackedStringArray = PackedStringArray()
	for type: Res.Type in Res.NAMES:
		var amount: int = produced[type] if not produced.is_empty() else def.production(type) * Res.scale(type)
		if amount > 0:
			parts.append("+%s %s" % [Res.format(type, amount), Res.NAMES[type]])
	var economy: String = ", ".join(parts) + " a fase" if not parts.is_empty() else "Nessuna risorsa"
	var battle: String = "Mana %s: +%d" % [def.mana_type, def.mana_amount] if def.mana_amount > 0 else "Neutro (nessun mana)"
	var effects: String = building_effects(def)
	if effects != "":
		battle += " · " + effects
	var text: String = "%s\n%s ogni %s" % [economy, battle, seconds(def.mana_interval_ms)]
	if def.extra_building_slots > 0:
		text += "\n+%d spazio edificio" % def.extra_building_slots
	if def.extra_troop_slots > 0:
		text += "\n+%d spazio truppa" % def.extra_troop_slots
	if not def.types.is_empty():
		text += "\n[%s]" % ", ".join(def.types)
	return text


static func troop_details(def: TroopDef) -> String:
	var cost: String = "senza mana" if def.mana_cost == 0 else "%d mana %s" % [def.mana_cost, def.mana_type]
	var effects: String = troop_effects(def)
	var text: String = "%s\n%s · Ricarica %s · Cibo %s" % [effects if effects != "" else "Nessun effetto", cost, seconds(def.cooldown_ms), Res.format(Res.Type.CIBO, def.food_tenths)]
	if not def.types.is_empty():
		text += "\n[%s]" % ", ".join(def.types)
	return text


## Effetti di una truppa a ogni attivazione, es. "Danno 4 · Scudo 2" (GDD §7.6, §7.7).
static func troop_effects(def: TroopDef) -> String:
	var parts: PackedStringArray = _effect_parts(def.damage, def.shield, def.heal, def.corruption,
			def.inefficiency_ms, def.inefficiency_target, def.sabotage_ms, def.sabotage_target)
	if def.siege_damage > 0:
		parts.insert(0, "Assedio %d" % def.siege_damage)
	return " · ".join(parts)


## Effetti di un edificio a ogni intervallo, oltre al mana.
static func building_effects(def: BuildingDef) -> String:
	return " · ".join(_effect_parts(0, def.shield, def.heal, def.corruption,
			def.inefficiency_ms, def.inefficiency_target, def.sabotage_ms, def.sabotage_target))


static func _effect_parts(damage: int, shield: int, heal: int, corruption: int, slow_ms: int,
		slow_target: TimerTarget.Kind, sabotage_ms: int, sabotage_target: TimerTarget.Kind) -> PackedStringArray:
	var parts: PackedStringArray = PackedStringArray()
	if damage > 0:
		parts.append("Danno %d" % damage)
	if shield > 0:
		parts.append("Scudo %d" % shield)
	if heal > 0:
		parts.append("Cura %d" % heal)
	if corruption > 0:
		parts.append("Corruzione %d" % corruption)
	if slow_ms > 0:
		parts.append("Rallenta %s (%s)" % [seconds(slow_ms), TimerTarget.NAMES[slow_target]])
	if sabotage_ms > 0:
		parts.append("Sabota %s (%s)" % [seconds(sabotage_ms), TimerTarget.NAMES[sabotage_target]])
	return parts


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
	var ui_theme: Theme = StileVisivo.tema_interfaccia()
	ui_theme.default_font_size = 19
	root.theme = ui_theme
	var background: ColorRect = ColorRect.new()
	background.color = StileVisivo.NOTTE
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(background)
	var glow: TextureRect = TextureRect.new()
	glow.texture = _background_glow()
	glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	glow.stretch_mode = TextureRect.STRETCH_SCALE
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glow.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(glow)
	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	root.add_child(margin)
	return margin


## Alone di luce al centro dello sfondo, che sfuma verso bordi più scuri.
static func _background_glow() -> GradientTexture2D:
	var gradient: Gradient = Gradient.new()
	gradient.set_color(0, Color(0.17, 0.25, 0.45, 0.55))
	gradient.set_color(1, Color(0.0, 0.01, 0.04, 0.85))
	var texture: GradientTexture2D = GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.42)
	texture.fill_to = Vector2(1.15, 1.15)
	return texture


## Pulsante grande per menu e schermate principali.
static func big_button(text: String, callback: Callable, enabled: bool = true) -> Button:
	var result: Button = button(text, callback, enabled)
	result.custom_minimum_size = Vector2(440, 66)
	result.add_theme_font_override("font", StileVisivo.FONT_TITOLI)
	result.add_theme_font_size_override("font_size", 28)
	var states: Dictionary[String, Color] = {
		"normal": Color("1d2840"),
		"hover": Color("2a3a5c"),
		"pressed": Color("141c2e"),
		"disabled": Color("151b28"),
		"focus": Color("2a3a5c"),
	}
	for state: String in states:
		var style: StyleBoxFlat = StileVisivo.riquadro(states[state], Color(1.0, 1.0, 1.0, 0.18 if state != "disabled" else 0.06))
		if state == "hover" or state == "focus":
			style.border_color = StileVisivo.COLORE_GIOCATORE
		result.add_theme_stylebox_override(state, style)
	return result


## Pulsante grande dorato per l'azione principale di una schermata.
static func main_button(text: String, callback: Callable, enabled: bool = true) -> Button:
	var result: Button = button(text, callback, enabled)
	result.custom_minimum_size = Vector2(440, 74)
	StileVisivo.rendi_principale(result)
	result.add_theme_font_size_override("font_size", 32)
	return result
