class_name HudPlancia
extends Control
## Interfaccia 2D sopra la plancia 3D (prova visiva, GDD §14.2).
## Poche informazioni ai bordi dello schermo; i dettagli compaiono passando il mouse.
## Solo presentazione: avvisa la scena con i segnali, non decide nulla.

signal cambia_vista_premuto
signal ricomincia_premuto
signal rinnova_premuto
signal passa_premuto
signal velocita_scelta(fattore: float)
signal pausa_premuta

var _fase: Label
var _tempo: Label
var _comandi_partita: Control
var _comandi_battaglia: Control
var _pulsante_vista: Button
var _pulsante_pausa: Button
var _pulsanti_velocita: Array[Button] = []
var _magazzino: PanelContainer
var _suggerimento: PanelContainer
var _titolo_suggerimento: Label
var _testo_suggerimento: Label
var _messaggio: Label
var _animazione_messaggio: Tween


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	theme = StileVisivo.tema_interfaccia()
	_crea_nazione()
	_crea_fase()
	_crea_run()
	_crea_risorse()
	_crea_comandi_partita()
	_crea_comandi_battaglia()
	_crea_pulsanti_destra()
	_crea_magazzino()
	_crea_suggerimento()
	_crea_messaggio()
	mostra_vista(0)


# --- Costruzione -------------------------------------------------------------

func _riquadro_ancorato(preset: Control.LayoutPreset, margine: Vector2) -> PanelContainer:
	var riquadro: PanelContainer = PanelContainer.new()
	add_child(riquadro)
	riquadro.set_anchors_and_offsets_preset(preset, Control.PRESET_MODE_MINSIZE)
	riquadro.position += margine
	return riquadro


func _crea_nazione() -> void:
	var riquadro: PanelContainer = _riquadro_ancorato(Control.PRESET_TOP_LEFT, Vector2(24, 20))
	var colonna: VBoxContainer = VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 0)
	riquadro.add_child(colonna)
	colonna.add_child(StileVisivo.etichetta("VALFIUME", StileVisivo.FONT_TITOLI, 34))
	colonna.add_child(StileVisivo.etichetta("Popolo del delta · Repubblica", StileVisivo.FONT_TESTO_FORTE, 16, StileVisivo.TESTO_TENUE))


func _crea_fase() -> void:
	var colonna: VBoxContainer = VBoxContainer.new()
	colonna.alignment = BoxContainer.ALIGNMENT_CENTER
	colonna.add_theme_constant_override("separation", 2)
	add_child(colonna)
	colonna.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_MINSIZE)
	colonna.position.y = 18
	colonna.grow_horizontal = Control.GROW_DIRECTION_BOTH
	var riquadro: PanelContainer = PanelContainer.new()
	colonna.add_child(riquadro)
	_fase = StileVisivo.etichetta("", StileVisivo.FONT_TITOLI, 30)
	_fase.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	riquadro.add_child(_fase)
	var avviso: Label = StileVisivo.etichetta("Prova visiva · grafica segnaposto · numeri di esempio", StileVisivo.FONT_TESTO_FORTE, 15, StileVisivo.TESTO_TENUE)
	avviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	colonna.add_child(avviso)


func _crea_run() -> void:
	var riquadro: PanelContainer = _riquadro_ancorato(Control.PRESET_TOP_RIGHT, Vector2(-24, 20))
	riquadro.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	var riga: HBoxContainer = HBoxContainer.new()
	riga.add_theme_constant_override("separation", 26)
	riquadro.add_child(riga)
	riga.add_child(_valore("Prestigio", "18", StileVisivo.ORO_LUCE))
	riga.add_child(_valore("Vittorie", "1/10"))


func _valore(nome: String, valore: String, colore: Color = StileVisivo.TESTO) -> VBoxContainer:
	var colonna: VBoxContainer = VBoxContainer.new()
	colonna.add_theme_constant_override("separation", -6)
	colonna.add_child(StileVisivo.etichetta(nome.to_upper(), StileVisivo.FONT_TESTO_FORTE, 14, StileVisivo.TESTO_TENUE))
	colonna.add_child(StileVisivo.etichetta(valore, StileVisivo.FONT_TITOLI, 34, colore))
	return colonna


func _crea_risorse() -> void:
	var riquadro: PanelContainer = _riquadro_ancorato(Control.PRESET_BOTTOM_LEFT, Vector2(24, -24))
	riquadro.grow_vertical = Control.GROW_DIRECTION_BEGIN
	var riga: HBoxContainer = HBoxContainer.new()
	riga.add_theme_constant_override("separation", 22)
	riquadro.add_child(riga)
	riga.add_child(_valore("Oro", "9", StileVisivo.ORO_LUCE))
	riga.add_child(_valore("Ricerca", "7/8", Color("7fb4ff")))
	riga.add_child(_valore("Cibo", "6", Color("8fe08a")))
	var pulsante: Button = Button.new()
	pulsante.text = "Magazzino"
	pulsante.pressed.connect(_on_magazzino)
	riga.add_child(pulsante)


func _crea_comandi_partita() -> void:
	var colonna: VBoxContainer = VBoxContainer.new()
	colonna.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(colonna)
	colonna.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE)
	colonna.grow_horizontal = Control.GROW_DIRECTION_BOTH
	colonna.grow_vertical = Control.GROW_DIRECTION_BEGIN
	colonna.position.y -= 24
	var riga: HBoxContainer = HBoxContainer.new()
	riga.alignment = BoxContainer.ALIGNMENT_CENTER
	riga.add_theme_constant_override("separation", 12)
	colonna.add_child(riga)
	var rinnova: Button = Button.new()
	rinnova.text = "Rinnova le offerte · 1 Oro"
	rinnova.pressed.connect(func() -> void: rinnova_premuto.emit())
	riga.add_child(rinnova)
	var passa: Button = Button.new()
	passa.text = "Passa"
	passa.pressed.connect(func() -> void: passa_premuto.emit())
	riga.add_child(passa)
	_comandi_partita = colonna


func _crea_comandi_battaglia() -> void:
	var riquadro: PanelContainer = PanelContainer.new()
	add_child(riquadro)
	riquadro.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE)
	riquadro.grow_horizontal = Control.GROW_DIRECTION_BOTH
	riquadro.grow_vertical = Control.GROW_DIRECTION_BEGIN
	riquadro.position.y -= 24
	var riga: HBoxContainer = HBoxContainer.new()
	riga.add_theme_constant_override("separation", 10)
	riquadro.add_child(riga)
	_tempo = StileVisivo.etichetta("0,0 s", StileVisivo.FONT_TITOLI, 30)
	_tempo.custom_minimum_size = Vector2(110, 0)
	riga.add_child(_tempo)
	_pulsante_pausa = Button.new()
	_pulsante_pausa.text = "Pausa"
	_pulsante_pausa.pressed.connect(func() -> void: pausa_premuta.emit())
	riga.add_child(_pulsante_pausa)
	for fattore: float in [1.0, 2.0, 4.0]:
		var pulsante: Button = Button.new()
		pulsante.text = "%d×" % int(fattore)
		pulsante.toggle_mode = true
		pulsante.button_pressed = fattore == 1.0
		pulsante.pressed.connect(_on_velocita.bind(fattore, pulsante))
		riga.add_child(pulsante)
		_pulsanti_velocita.append(pulsante)
	_comandi_battaglia = riquadro


func _crea_pulsanti_destra() -> void:
	var colonna: VBoxContainer = VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 10)
	add_child(colonna)
	colonna.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_MINSIZE)
	colonna.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	colonna.grow_vertical = Control.GROW_DIRECTION_BEGIN
	colonna.position += Vector2(-24, -24)
	var ricomincia: Button = Button.new()
	ricomincia.text = "Ricomincia la prova"
	ricomincia.pressed.connect(func() -> void: ricomincia_premuto.emit())
	colonna.add_child(ricomincia)
	_pulsante_vista = Button.new()
	_pulsante_vista.custom_minimum_size = Vector2(300, 68)
	StileVisivo.rendi_principale(_pulsante_vista)
	_pulsante_vista.pressed.connect(func() -> void: cambia_vista_premuto.emit())
	colonna.add_child(_pulsante_vista)


func _crea_magazzino() -> void:
	_magazzino = PanelContainer.new()
	add_child(_magazzino)
	_magazzino.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT, Control.PRESET_MODE_MINSIZE)
	_magazzino.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_magazzino.position += Vector2(24, -120)
	var colonna: VBoxContainer = VBoxContainer.new()
	_magazzino.add_child(colonna)
	colonna.add_child(StileVisivo.etichetta("Magazzino", StileVisivo.FONT_TITOLI, 28, StileVisivo.ORO))
	var griglia: GridContainer = GridContainer.new()
	griglia.columns = 3
	griglia.add_theme_constant_override("h_separation", 28)
	griglia.add_theme_constant_override("v_separation", 6)
	colonna.add_child(griglia)
	var risorse: Array[String] = ["Oro 9 (+5)", "Ricerca 7 (+3)", "Cibo 6 (+3)", "Legno 3 (+1)", "Pietra 2 (+1)", "Ferro 2 (+1)", "Fauna 1 (+1)", "Fede 1 (+1)", "Influenza 1 (+1)"]
	for voce: String in risorse:
		griglia.add_child(StileVisivo.etichetta(voce, StileVisivo.FONT_TESTO, 20))
	var vendi: Button = Button.new()
	vendi.text = "Vendi risorse · 2 → 1 Oro"
	colonna.add_child(vendi)
	_magazzino.visible = false


func _crea_suggerimento() -> void:
	_suggerimento = PanelContainer.new()
	_suggerimento.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_suggerimento.custom_minimum_size = Vector2(340, 0)
	add_child(_suggerimento)
	var colonna: VBoxContainer = VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 4)
	_suggerimento.add_child(colonna)
	_titolo_suggerimento = StileVisivo.etichetta("", StileVisivo.FONT_TITOLI, 28)
	colonna.add_child(_titolo_suggerimento)
	_testo_suggerimento = StileVisivo.etichetta("", StileVisivo.FONT_TESTO, 19)
	_testo_suggerimento.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_testo_suggerimento.custom_minimum_size = Vector2(340, 0)
	colonna.add_child(_testo_suggerimento)
	_suggerimento.visible = false


func _crea_messaggio() -> void:
	_messaggio = StileVisivo.etichetta("", StileVisivo.FONT_TITOLI, 56, StileVisivo.ORO_LUCE)
	_messaggio.add_theme_color_override("font_outline_color", StileVisivo.OMBRA_TESTO)
	_messaggio.add_theme_constant_override("outline_size", 10)
	_messaggio.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_messaggio)
	_messaggio.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
	_messaggio.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_messaggio.modulate.a = 0.0


# --- Aggiornamento -------------------------------------------------------------

## vista: 0 = partita, 1 = battaglia (stessi valori dell'enum della scena).
func mostra_vista(vista: int) -> void:
	var battaglia: bool = vista == 1
	_fase.text = "Anno III · Scontro con il fantasma" if battaglia else "Anno III · Produzione · opportunità 1 di 2"
	_comandi_partita.visible = not battaglia
	_comandi_battaglia.visible = battaglia
	_pulsante_vista.text = "Torna alla partita" if battaglia else "Vai allo scontro"
	_magazzino.visible = false


func imposta_tempo(secondi: float) -> void:
	_tempo.text = ("%.1f s" % secondi).replace(".", ",")


func imposta_pausa(in_pausa: bool) -> void:
	_pulsante_pausa.text = "Riprendi" if in_pausa else "Pausa"


func mostra_suggerimento(titolo: String, testo: String, posizione: Vector2) -> void:
	_titolo_suggerimento.text = titolo
	_testo_suggerimento.text = testo
	_suggerimento.visible = true
	_suggerimento.reset_size()
	var limite: Vector2 = get_viewport_rect().size - _suggerimento.size - Vector2(16, 16)
	_suggerimento.position = (posizione + Vector2(24, -_suggerimento.size.y - 16)).clamp(Vector2(16, 16), limite)


func nascondi_suggerimento() -> void:
	_suggerimento.visible = false


func mostra_messaggio(testo: String) -> void:
	_messaggio.text = testo
	_messaggio.reset_size()
	_messaggio.position = (get_viewport_rect().size - _messaggio.size) * Vector2(0.5, 0.42)
	if _animazione_messaggio != null and _animazione_messaggio.is_valid():
		_animazione_messaggio.kill()
	_animazione_messaggio = create_tween()
	_animazione_messaggio.tween_property(_messaggio, "modulate:a", 1.0, 0.2)
	_animazione_messaggio.tween_interval(1.6)
	_animazione_messaggio.tween_property(_messaggio, "modulate:a", 0.0, 0.5)


func _on_magazzino() -> void:
	_magazzino.visible = not _magazzino.visible


func _on_velocita(fattore: float, scelto: Button) -> void:
	for pulsante: Button in _pulsanti_velocita:
		pulsante.button_pressed = pulsante == scelto
	velocita_scelta.emit(fattore)
