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

	var title: Label = UiKit.label("ULTRALOPOLIS", 72, Color(0.95, 0.85, 0.55))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	var subtitle: Label = UiKit.label("Prototipo — grafica provvisoria", 18, UiKit.COLOR_WARNING)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(subtitle)
	column.add_child(Control.new())

	column.add_child(UiKit.big_button("Gioca", _on_play))
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
