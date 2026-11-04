extends Control
## Menu principale: Gioca, Crea nazione, Esci dal gioco.


func _ready() -> void:
	var margin: MarginContainer = UiKit.screen(self)
	var center: CenterContainer = CenterContainer.new()
	margin.add_child(center)
	var column: VBoxContainer = VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 22)
	center.add_child(column)

	var title: Label = StileVisivo.etichetta("ULTRALOPOLIS", StileVisivo.FONT_TITOLI, 110, StileVisivo.ORO_LUCE)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_constant_override("outline_size", 16)
	title.add_theme_color_override("font_outline_color", StileVisivo.OMBRA_TESTO)
	column.add_child(title)
	var subtitle: Label = StileVisivo.etichetta("Prototipo", StileVisivo.FONT_TESTO_FORTE, 20, StileVisivo.TESTO_TENUE)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(subtitle)
	column.add_child(Control.new())

	column.add_child(UiKit.main_button("Gioca", _on_play))
	column.add_child(UiKit.big_button("Crea nazione", _on_create))
	column.add_child(UiKit.big_button("Esci dal gioco", _on_quit))

	var count: int = GameSession.saved_nations().size()
	var info: Label = UiKit.label("Nazioni create: %d" % count, 16, Color(0.6, 0.6, 0.65))
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(info)


func _on_play() -> void:
	GameSession.play()


func _on_create() -> void:
	GameSession.open_creator(null, GameSession.MENU_SCENE)


func _on_quit() -> void:
	get_tree().quit()
