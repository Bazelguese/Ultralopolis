class_name HudPlancia
extends Control
## Interfaccia 2D sopra la plancia 3D (GDD §14.2, §14.3).
## Poche informazioni ai bordi; i dettagli si aprono a richiesta o passando il mouse.
## Solo presentazione: legge lo stato della run e avvisa la scena con i segnali.

signal azione_principale
signal rinnova
signal rinnova_risorsa
signal passa
signal nessuna_ricompensa
signal avanza_era
signal vendi_risorsa(tipo: int)
signal ricomincia
signal menu
signal pausa
signal velocita(fattore: float)
signal annulla

## Distanza dal fondo dello schermo dei comandi che stanno sopra la barra delle risorse.
const SOPRA_BARRA: float = -112.0
const COLORI_RISORSE: Dictionary[int, Color] = {
	Res.Type.ORO: Color("ffd76a"),
	Res.Type.RICERCA: Color("7fb4ff"),
	Res.Type.CIBO: Color("8fe08a"),
	Res.Type.LEGNO: Color("d9a066"),
	Res.Type.PIETRA: Color("c9d0dc"),
	Res.Type.FERRO: Color("a9bfd6"),
	Res.Type.FEDE: Color("f5e6a8"),
	Res.Type.INFLUENZA: Color("d6a6ff"),
	Res.Type.STABILITA: Color("8fd6d0"),
	Res.Type.DOCUMENTI: Color("e8b98a"),
}

var _nazione: Label
var _identita: Label
var _fase: Label
var _sotto_fase: Label
var _prestigio: Label
var _vittorie: Label
var _era: Label
var _malcontento: Label
var _malcontento_cella: Control
var _ultima_possibilita: Label
var _valori_risorse: Dictionary[int, Label] = {}
var _produzioni_risorse: Dictionary[int, Label] = {}
var _pulsante_era: Button
var _magazzino: PanelContainer
var _righe_magazzino: Dictionary[int, Label] = {}
var _vendite: Dictionary[int, Button] = {}
var _effetti: PanelContainer
var _lista_effetti: VBoxContainer
var _pulsante_effetti: Button
var _cronaca: PanelContainer
var _testo_cronaca: Label
var _comandi: VBoxContainer
var _suggerimento_fase: Label
var _pulsante_rinnova: Button
var _pulsante_rinnova_risorsa: Button
var _pulsante_passa: Button
var _pulsante_nessuna: Button
var _colonna_principale: VBoxContainer
var _principale: Button
var _barra_scontro: PanelContainer
var _tempo: Label
var _pulsante_pausa: Button
var _pulsanti_velocita: Array[Button] = []
var _pezzo: PanelContainer
var _titolo_pezzo: Label
var _testo_pezzo: Label
var _azioni_pezzo: HBoxContainer
var _scelte: PanelContainer
var _titolo_scelte: Label
var _testo_scelte: Label
var _voci_scelte: VBoxContainer
var _sostituzione: PanelContainer
var _testo_sostituzione: Label
var _esito: PanelContainer
var _titolo_esito: Label
var _sotto_esito: Label
var _righe_esito: VBoxContainer
var _al_continua: Callable
var _suggerimento: PanelContainer
var _titolo_suggerimento: Label
var _testo_suggerimento: Label
var _messaggio: Label
var _animazione_messaggio: Tween


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	theme = StileVisivo.tema_interfaccia()
	_crea_vignetta()
	_crea_nazione()
	_crea_fase()
	_crea_run()
	_crea_risorse()
	_crea_magazzino()
	_crea_pannelli_destra()
	_crea_comandi()
	_crea_principale()
	_crea_barra_scontro()
	_crea_pezzo()
	_crea_sostituzione()
	_crea_scelte()
	_crea_esito()
	_crea_suggerimento()
	_crea_messaggio()


# --- Costruzione -------------------------------------------------------------

func _ancora(controllo: Control, preset: Control.LayoutPreset, spostamento: Vector2) -> void:
	add_child(controllo)
	controllo.set_anchors_and_offsets_preset(preset, Control.PRESET_MODE_MINSIZE)
	match preset:
		Control.PRESET_TOP_RIGHT, Control.PRESET_CENTER_RIGHT:
			controllo.grow_horizontal = Control.GROW_DIRECTION_BEGIN
		Control.PRESET_BOTTOM_RIGHT:
			controllo.grow_horizontal = Control.GROW_DIRECTION_BEGIN
			controllo.grow_vertical = Control.GROW_DIRECTION_BEGIN
		Control.PRESET_BOTTOM_LEFT:
			controllo.grow_vertical = Control.GROW_DIRECTION_BEGIN
		Control.PRESET_CENTER_TOP:
			controllo.grow_horizontal = Control.GROW_DIRECTION_BOTH
		Control.PRESET_CENTER_BOTTOM:
			controllo.grow_horizontal = Control.GROW_DIRECTION_BOTH
			controllo.grow_vertical = Control.GROW_DIRECTION_BEGIN
		Control.PRESET_CENTER:
			controllo.grow_horizontal = Control.GROW_DIRECTION_BOTH
			controllo.grow_vertical = Control.GROW_DIRECTION_BOTH
	controllo.position += spostamento


func _pulsante(testo: String, al_clic: Callable) -> Button:
	var pulsante: Button = Button.new()
	pulsante.text = testo
	pulsante.pressed.connect(al_clic)
	return pulsante


## Coppia nome piccolo + numero grande. Restituisce [contenitore, etichetta del numero].
func _valore(nome: String, colore: Color = StileVisivo.TESTO) -> Array:
	var colonna: VBoxContainer = VBoxContainer.new()
	colonna.add_theme_constant_override("separation", -6)
	colonna.add_child(StileVisivo.etichetta(nome.to_upper(), StileVisivo.FONT_TESTO_FORTE, 14, StileVisivo.TESTO_TENUE))
	var valore: Label = StileVisivo.etichetta("", StileVisivo.FONT_TITOLI, 34, colore)
	colonna.add_child(valore)
	return [colonna, valore]


## Bordi dello schermo più scuri, per dare profondità alla scena.
func _crea_vignetta() -> void:
	var sfumatura: Gradient = Gradient.new()
	sfumatura.set_color(0, Color(0.0, 0.0, 0.0, 0.0))
	sfumatura.set_color(1, Color(0.0, 0.02, 0.06, 0.7))
	sfumatura.set_offset(0, 0.55)
	var trama: GradientTexture2D = GradientTexture2D.new()
	trama.gradient = sfumatura
	trama.fill = GradientTexture2D.FILL_RADIAL
	trama.fill_from = Vector2(0.5, 0.5)
	trama.fill_to = Vector2(1.15, 1.15)
	var vignetta: TextureRect = TextureRect.new()
	vignetta.texture = trama
	vignetta.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	vignetta.stretch_mode = TextureRect.STRETCH_SCALE
	vignetta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vignetta)
	vignetta.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _crea_nazione() -> void:
	var riquadro: PanelContainer = PanelContainer.new()
	var colonna: VBoxContainer = VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 0)
	riquadro.add_child(colonna)
	_nazione = StileVisivo.etichetta("", StileVisivo.FONT_TITOLI, 34)
	colonna.add_child(_nazione)
	_identita = StileVisivo.etichetta("", StileVisivo.FONT_TESTO, 16, StileVisivo.TESTO_TENUE)
	_identita.custom_minimum_size = Vector2(320, 0)
	_identita.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	colonna.add_child(_identita)
	_ancora(riquadro, Control.PRESET_TOP_LEFT, Vector2(24, 20))


func _crea_fase() -> void:
	var colonna: VBoxContainer = VBoxContainer.new()
	colonna.alignment = BoxContainer.ALIGNMENT_CENTER
	colonna.add_theme_constant_override("separation", 4)
	var riquadro: PanelContainer = PanelContainer.new()
	colonna.add_child(riquadro)
	_fase = StileVisivo.etichetta("", StileVisivo.FONT_TITOLI, 30)
	_fase.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	riquadro.add_child(_fase)
	_sotto_fase = StileVisivo.etichetta("", StileVisivo.FONT_TESTO_FORTE, 17, StileVisivo.TESTO_TENUE)
	_sotto_fase.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	colonna.add_child(_sotto_fase)
	_ancora(colonna, Control.PRESET_CENTER_TOP, Vector2(0, 18))


func _crea_run() -> void:
	var riquadro: PanelContainer = PanelContainer.new()
	var riga: HBoxContainer = HBoxContainer.new()
	riga.add_theme_constant_override("separation", 24)
	riquadro.add_child(riga)
	var prestigio: Array = _valore("Prestigio", StileVisivo.ORO_LUCE)
	riga.add_child(prestigio[0])
	_prestigio = prestigio[1]
	var vittorie: Array = _valore("Vittorie")
	riga.add_child(vittorie[0])
	_vittorie = vittorie[1]
	var era: Array = _valore("Era", Color("c7b8ff"))
	riga.add_child(era[0])
	_era = era[1]
	# Malcontento (GDD §5.5, v0.24): sempre visibile, con la soglia della Rivoluzione.
	var malcontento: Array = _valore("Malcontento")
	riga.add_child(malcontento[0])
	_malcontento = malcontento[1]
	_malcontento_cella = malcontento[0]
	_malcontento_cella.mouse_filter = Control.MOUSE_FILTER_PASS
	riga.add_child(_pulsante("Menu", func() -> void: menu.emit()))
	_ancora(riquadro, Control.PRESET_TOP_RIGHT, Vector2(-24, 20))
	_ultima_possibilita = StileVisivo.etichetta("ULTIMA POSSIBILITÀ", StileVisivo.FONT_TITOLI, 22, StileVisivo.PERICOLO)
	_ancora(_ultima_possibilita, Control.PRESET_TOP_RIGHT, Vector2(-30, 124))


## Barra lunga in fondo allo schermo, sempre visibile: tutte le risorse del Magazzino
## con la quantità e, accanto, quanto producono a ogni fase.
func _crea_risorse() -> void:
	var barra: PanelContainer = PanelContainer.new()
	var riga: HBoxContainer = HBoxContainer.new()
	riga.add_theme_constant_override("separation", 6)
	barra.add_child(riga)
	for tipo: int in Res.NAMES:
		var cella: VBoxContainer = VBoxContainer.new()
		cella.add_theme_constant_override("separation", -6)
		cella.custom_minimum_size = Vector2(124, 0)
		cella.tooltip_text = "%s: quantità nel Magazzino e produzione a ogni fase." % Res.NAMES[tipo]
		cella.mouse_filter = Control.MOUSE_FILTER_PASS
		cella.add_child(StileVisivo.etichetta(Res.NAMES[tipo].to_upper(), StileVisivo.FONT_TESTO_FORTE, 14, StileVisivo.TESTO_TENUE))
		var valori: HBoxContainer = HBoxContainer.new()
		valori.add_theme_constant_override("separation", 6)
		var valore: Label = StileVisivo.etichetta("", StileVisivo.FONT_TITOLI, 30, COLORI_RISORSE[tipo])
		valori.add_child(valore)
		var produzione: Label = StileVisivo.etichetta("", StileVisivo.FONT_NUMERI, 17, StileVisivo.TESTO_TENUE)
		produzione.size_flags_vertical = Control.SIZE_SHRINK_END
		valori.add_child(produzione)
		cella.add_child(valori)
		riga.add_child(cella)
		_valori_risorse[tipo] = valore
		_produzioni_risorse[tipo] = produzione
	var spinta: Control = Control.new()
	spinta.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	riga.add_child(spinta)
	var mercato: Button = _pulsante("Mercato", func() -> void: _magazzino.visible = not _magazzino.visible)
	mercato.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	riga.add_child(mercato)
	_pulsante_era = _pulsante("", func() -> void: avanza_era.emit())
	_pulsante_era.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	riga.add_child(_pulsante_era)
	add_child(barra)
	barra.anchor_left = 0.0
	barra.anchor_right = 1.0
	barra.anchor_top = 1.0
	barra.anchor_bottom = 1.0
	barra.grow_vertical = Control.GROW_DIRECTION_BEGIN
	barra.offset_left = 24.0
	barra.offset_right = -24.0
	barra.offset_bottom = -16.0
	barra.offset_top = -16.0 - barra.get_combined_minimum_size().y


func _crea_magazzino() -> void:
	_magazzino = PanelContainer.new()
	var colonna: VBoxContainer = VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 6)
	_magazzino.add_child(colonna)
	colonna.add_child(StileVisivo.etichetta("MERCATO", StileVisivo.FONT_TITOLI, 28, StileVisivo.ORO_LUCE))
	colonna.add_child(StileVisivo.etichetta("Vendi le risorse in cambio di Oro", StileVisivo.FONT_TESTO, 15, StileVisivo.TESTO_TENUE))
	var griglia: GridContainer = GridContainer.new()
	griglia.columns = 2
	griglia.add_theme_constant_override("h_separation", 18)
	griglia.add_theme_constant_override("v_separation", 4)
	colonna.add_child(griglia)
	for tipo: int in Res.NAMES:
		var riga: Label = StileVisivo.etichetta("", StileVisivo.FONT_TESTO_FORTE, 19)
		riga.custom_minimum_size = Vector2(240, 0)
		griglia.add_child(riga)
		_righe_magazzino[tipo] = riga
		if tipo == Res.Type.ORO:
			griglia.add_child(Control.new())
		else:
			var vendi: Button = _pulsante("Vendi", _on_vendi.bind(tipo))
			vendi.add_theme_font_size_override("font_size", 16)
			griglia.add_child(vendi)
			_vendite[tipo] = vendi
	_ancora(_magazzino, Control.PRESET_BOTTOM_LEFT, Vector2(24, SOPRA_BARRA))
	_magazzino.visible = false


func _on_vendi(tipo: int) -> void:
	vendi_risorsa.emit(tipo)


func _crea_pannelli_destra() -> void:
	var colonna: VBoxContainer = VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 8)
	_pulsante_effetti = _pulsante("Effetti", func() -> void: _alterna(_effetti))
	colonna.add_child(_pulsante_effetti)
	colonna.add_child(_pulsante("Cronaca", func() -> void: _alterna(_cronaca)))
	_ancora(colonna, Control.PRESET_CENTER_RIGHT, Vector2(-24, -60))

	_effetti = PanelContainer.new()
	var lista: VBoxContainer = VBoxContainer.new()
	lista.add_theme_constant_override("separation", 6)
	_effetti.add_child(lista)
	lista.add_child(StileVisivo.etichetta("EFFETTI ATTIVI", StileVisivo.FONT_TITOLI, 26, StileVisivo.ORO_LUCE))
	_lista_effetti = VBoxContainer.new()
	lista.add_child(_lista_effetti)
	_ancora(_effetti, Control.PRESET_CENTER_RIGHT, Vector2(-180, -160))
	_effetti.visible = false

	_cronaca = PanelContainer.new()
	var colonna_cronaca: VBoxContainer = VBoxContainer.new()
	_cronaca.add_child(colonna_cronaca)
	colonna_cronaca.add_child(StileVisivo.etichetta("CRONACA", StileVisivo.FONT_TITOLI, 26, StileVisivo.ORO_LUCE))
	_testo_cronaca = StileVisivo.etichetta("", StileVisivo.FONT_TESTO, 17)
	_testo_cronaca.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_testo_cronaca.custom_minimum_size = Vector2(480, 0)
	colonna_cronaca.add_child(_testo_cronaca)
	_ancora(_cronaca, Control.PRESET_CENTER_RIGHT, Vector2(-180, -220))
	_cronaca.visible = false


func _alterna(pannello: Control) -> void:
	var visibile: bool = not pannello.visible
	_effetti.visible = false
	_cronaca.visible = false
	pannello.visible = visibile


func _crea_comandi() -> void:
	_comandi = VBoxContainer.new()
	_comandi.alignment = BoxContainer.ALIGNMENT_CENTER
	_comandi.add_theme_constant_override("separation", 8)
	_suggerimento_fase = StileVisivo.etichetta("", StileVisivo.FONT_TESTO_FORTE, 19, StileVisivo.TESTO)
	_suggerimento_fase.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_suggerimento_fase.add_theme_constant_override("outline_size", 8)
	_suggerimento_fase.add_theme_color_override("font_outline_color", StileVisivo.OMBRA_TESTO)
	_comandi.add_child(_suggerimento_fase)
	var riga: HBoxContainer = HBoxContainer.new()
	riga.alignment = BoxContainer.ALIGNMENT_CENTER
	riga.add_theme_constant_override("separation", 12)
	_comandi.add_child(riga)
	_pulsante_rinnova = _pulsante("", func() -> void: rinnova.emit())
	riga.add_child(_pulsante_rinnova)
	_pulsante_rinnova_risorsa = _pulsante("", func() -> void: rinnova_risorsa.emit())
	riga.add_child(_pulsante_rinnova_risorsa)
	_pulsante_passa = _pulsante("Passa il round", func() -> void: passa.emit())
	riga.add_child(_pulsante_passa)
	_pulsante_nessuna = _pulsante("Nessuna ricompensa", func() -> void: nessuna_ricompensa.emit())
	riga.add_child(_pulsante_nessuna)
	_ancora(_comandi, Control.PRESET_CENTER_BOTTOM, Vector2(0, SOPRA_BARRA))


func _crea_principale() -> void:
	_colonna_principale = VBoxContainer.new()
	_colonna_principale.add_theme_constant_override("separation", 10)
	_colonna_principale.add_child(_pulsante("Ricomincia", func() -> void: ricomincia.emit()))
	_principale = _pulsante("", func() -> void: azione_principale.emit())
	_principale.custom_minimum_size = Vector2(320, 68)
	StileVisivo.rendi_principale(_principale)
	_colonna_principale.add_child(_principale)
	_ancora(_colonna_principale, Control.PRESET_BOTTOM_RIGHT, Vector2(-24, SOPRA_BARRA))


func _crea_barra_scontro() -> void:
	_barra_scontro = PanelContainer.new()
	var riga: HBoxContainer = HBoxContainer.new()
	riga.add_theme_constant_override("separation", 10)
	_barra_scontro.add_child(riga)
	_tempo = StileVisivo.etichetta("0 s", StileVisivo.FONT_TITOLI, 30)
	_tempo.custom_minimum_size = Vector2(110, 0)
	riga.add_child(_tempo)
	_pulsante_pausa = _pulsante("Pausa", func() -> void: pausa.emit())
	riga.add_child(_pulsante_pausa)
	for fattore: float in [1.0, 2.0, 4.0]:
		var pulsante: Button = Button.new()
		pulsante.text = "%d×" % int(fattore)
		pulsante.toggle_mode = true
		pulsante.button_pressed = fattore == 1.0
		pulsante.pressed.connect(_on_velocita.bind(fattore, pulsante))
		riga.add_child(pulsante)
		_pulsanti_velocita.append(pulsante)
	riga.add_child(_pulsante("Salta alla fine", func() -> void: azione_principale.emit()))
	_ancora(_barra_scontro, Control.PRESET_CENTER_BOTTOM, Vector2(0, SOPRA_BARRA))
	_barra_scontro.visible = false


func _crea_pezzo() -> void:
	_pezzo = PanelContainer.new()
	var colonna: VBoxContainer = VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 8)
	_pezzo.add_child(colonna)
	_titolo_pezzo = StileVisivo.etichetta("", StileVisivo.FONT_TITOLI, 30)
	colonna.add_child(_titolo_pezzo)
	_testo_pezzo = StileVisivo.etichetta("", StileVisivo.FONT_TESTO, 18)
	_testo_pezzo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_testo_pezzo.custom_minimum_size = Vector2(400, 0)
	colonna.add_child(_testo_pezzo)
	_azioni_pezzo = HBoxContainer.new()
	_azioni_pezzo.add_theme_constant_override("separation", 8)
	colonna.add_child(_azioni_pezzo)
	_ancora(_pezzo, Control.PRESET_BOTTOM_RIGHT, Vector2(-24, SOPRA_BARRA - 166.0))
	_pezzo.visible = false


func _crea_sostituzione() -> void:
	_sostituzione = PanelContainer.new()
	_sostituzione.add_theme_stylebox_override("panel", StileVisivo.riquadro(Color(0.35, 0.08, 0.1, 0.92), StileVisivo.PERICOLO))
	var riga: HBoxContainer = HBoxContainer.new()
	riga.add_theme_constant_override("separation", 16)
	_sostituzione.add_child(riga)
	_testo_sostituzione = StileVisivo.etichetta("", StileVisivo.FONT_TESTO_FORTE, 20)
	riga.add_child(_testo_sostituzione)
	riga.add_child(_pulsante("Annulla", func() -> void: annulla.emit()))
	_ancora(_sostituzione, Control.PRESET_CENTER_TOP, Vector2(0, 130))
	_sostituzione.visible = false


func _crea_scelte() -> void:
	_scelte = PanelContainer.new()
	var colonna: VBoxContainer = VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 10)
	_scelte.add_child(colonna)
	_titolo_scelte = StileVisivo.etichetta("", StileVisivo.FONT_TITOLI, 34, StileVisivo.ORO_LUCE)
	colonna.add_child(_titolo_scelte)
	_testo_scelte = StileVisivo.etichetta("", StileVisivo.FONT_TESTO, 18)
	_testo_scelte.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_testo_scelte.custom_minimum_size = Vector2(520, 0)
	colonna.add_child(_testo_scelte)
	_voci_scelte = VBoxContainer.new()
	_voci_scelte.add_theme_constant_override("separation", 8)
	colonna.add_child(_voci_scelte)
	colonna.add_child(_pulsante("Annulla", func() -> void: _scelte.visible = false))
	_ancora(_scelte, Control.PRESET_CENTER, Vector2.ZERO)
	_scelte.visible = false


func _crea_esito() -> void:
	_esito = PanelContainer.new()
	_esito.add_theme_stylebox_override("panel", StileVisivo.riquadro(Color(0.04, 0.06, 0.11, 0.95), StileVisivo.ORO))
	var colonna: VBoxContainer = VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 10)
	colonna.custom_minimum_size = Vector2(640, 0)
	_esito.add_child(colonna)
	_titolo_esito = StileVisivo.etichetta("", StileVisivo.FONT_TITOLI, 80)
	_titolo_esito.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	colonna.add_child(_titolo_esito)
	_sotto_esito = StileVisivo.etichetta("", StileVisivo.FONT_TESTO_FORTE, 21, StileVisivo.TESTO_TENUE)
	_sotto_esito.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sotto_esito.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	colonna.add_child(_sotto_esito)
	_righe_esito = VBoxContainer.new()
	_righe_esito.add_theme_constant_override("separation", 6)
	colonna.add_child(_righe_esito)
	var continua: Button = _pulsante("Continua", _on_continua_esito)
	continua.custom_minimum_size = Vector2(0, 64)
	StileVisivo.rendi_principale(continua)
	colonna.add_child(continua)
	_ancora(_esito, Control.PRESET_CENTER, Vector2.ZERO)
	_esito.visible = false


func _crea_suggerimento() -> void:
	_suggerimento = PanelContainer.new()
	_suggerimento.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var colonna: VBoxContainer = VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 4)
	_suggerimento.add_child(colonna)
	_titolo_suggerimento = StileVisivo.etichetta("", StileVisivo.FONT_TITOLI, 28)
	colonna.add_child(_titolo_suggerimento)
	_testo_suggerimento = StileVisivo.etichetta("", StileVisivo.FONT_TESTO, 18)
	_testo_suggerimento.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_testo_suggerimento.custom_minimum_size = Vector2(400, 0)
	colonna.add_child(_testo_suggerimento)
	add_child(_suggerimento)
	_suggerimento.visible = false


func _crea_messaggio() -> void:
	_messaggio = StileVisivo.etichetta("", StileVisivo.FONT_TITOLI, 52, StileVisivo.ORO_LUCE)
	_messaggio.add_theme_color_override("font_outline_color", StileVisivo.OMBRA_TESTO)
	_messaggio.add_theme_constant_override("outline_size", 12)
	_messaggio.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_messaggio.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_messaggio)
	_messaggio.modulate.a = 0.0


# --- Aggiornamento della partita ---------------------------------------------------

func aggiorna_partita(run: RunState) -> void:
	_nazione.text = run.nation_name.to_upper()
	_identita.text = run.identity_summary()
	var comprando: bool = run.is_shopping_phase()
	_fase.text = "Anno %d · %s" % [run.year, run.phase_name()]
	if comprando:
		_fase.text += " · round %d di %d · tema: %s" % [run.round_number, run.run_rules.rounds_per_half, run.theme_name()]
	_sotto_fase.text = "Resistenza nel prossimo scontro: %d" % run.player_resistance()
	_prestigio.text = str(run.prestige)
	_vittorie.text = "%d/%d" % [run.wins, run.run_rules.wins_needed]
	_era.text = run.era_name()
	_ultima_possibilita.visible = run.last_chance
	_malcontento.text = "%d/%d" % [run.malcontent, run.run_rules.malcontent_threshold]
	var vicina: bool = run.malcontent >= run.run_rules.malcontent_warning
	_malcontento.add_theme_color_override("font_color", StileVisivo.PERICOLO if vicina else StileVisivo.TESTO)
	_malcontento_cella.tooltip_text = "Malcontento: sale con sconfitte, carestie, malus ed eventi; scende spendendo Stabilità (Cancelliere), Fede o Cibo. A %d scoppia la Rivoluzione.%s" % [
			run.run_rules.malcontent_threshold, "\nLa rivoluzione si avvicina!" if vicina else ""]

	var produzione: Array[int] = run.production_per_phase()
	for tipo: int in _valori_risorse:
		_valori_risorse[tipo].text = run.stock_text(tipo)
		_produzioni_risorse[tipo].text = "+%s" % Res.format(tipo, produzione[tipo]) if produzione[tipo] > 0 else ""
	var costo_era: int = run.next_era_cost()
	if costo_era >= 0:
		_valori_risorse[Res.Type.RICERCA].text = "%s/%d" % [run.stock_text(Res.Type.RICERCA), costo_era]
		_pulsante_era.text = "Avanza a %s · %d Ricerca" % [run.era_name(run.era + 1), costo_era]
		_pulsante_era.visible = true
		_pulsante_era.disabled = not comprando or run.research < costo_era
	else:
		_pulsante_era.visible = false
	var lotto: int = run.market_rate()
	for tipo: int in _righe_magazzino:
		_righe_magazzino[tipo].text = "%s  %s" % [Res.NAMES[tipo], run.stock_text(tipo)]
		if _vendite.has(tipo):
			_vendite[tipo].text = "Vendi %d → 1 Oro" % lotto
			_vendite[tipo].disabled = not comprando or run.stock[tipo] < lotto * Res.scale(tipo)

	for figlio: Node in _lista_effetti.get_children():
		figlio.queue_free()
	for modificatore: ActiveModifier in run.modifiers.active:
		var voce: Label = StileVisivo.etichetta("• " + modificatore.describe(), StileVisivo.FONT_TESTO, 17, Color("ff9b9b") if modificatore.def.is_malus else Color("9be8a5"))
		voce.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		voce.custom_minimum_size = Vector2(480, 0)
		_lista_effetti.add_child(voce)
	if run.modifiers.active.is_empty():
		_lista_effetti.add_child(StileVisivo.etichetta("Nessun effetto attivo.", StileVisivo.FONT_TESTO, 17, StileVisivo.TESTO_TENUE))
	_pulsante_effetti.text = "Effetti (%d)" % run.modifiers.active.size()
	var ultime: Array[String] = run.chronicle.slice(maxi(0, run.chronicle.size() - 14))
	ultime.reverse()
	_testo_cronaca.text = "\n".join(ultime)

	var scelta_via: bool = not run.way_choices.is_empty() or not run.government_choices.is_empty()
	var consigliere: AdvisorDef = run.chosen_advisor
	_pulsante_rinnova.visible = comprando and not scelta_via and consigliere != null
	_pulsante_passa.visible = comprando and not scelta_via and not run.is_revolution_round()
	_pulsante_rinnova.text = "Rinnova · %d Oro" % run.reroll_cost()
	_pulsante_rinnova.disabled = run.gold < run.reroll_cost()
	var costo_risorsa: ResourceAmounts = run.reroll_resource_cost()
	_pulsante_rinnova_risorsa.visible = _pulsante_rinnova.visible and costo_risorsa != null
	if costo_risorsa != null:
		_pulsante_rinnova_risorsa.text = "Rinnova · %s" % costo_risorsa.describe()
		_pulsante_rinnova_risorsa.disabled = not run.can_pay(costo_risorsa)
	_pulsante_nessuna.visible = run.phase == RunState.Phase.RICOMPENSA_INCONTRO
	_principale.visible = run.phase in [RunState.Phase.SCONTRO_FANTASMA, RunState.Phase.FINE_RUN]
	match run.phase:
		RunState.Phase.PRODUZIONE, RunState.Phase.PREPARAZIONE:
			_suggerimento_fase.text = _testo_consiglio(run)
		RunState.Phase.SCELTA_INCONTRO:
			_suggerimento_fase.text = "Incontro del mondo: scegli quale minaccia affrontare. Se perdi, l'Oro si dimezza."
		RunState.Phase.RICOMPENSA_INCONTRO:
			_suggerimento_fase.text = "Hai vinto l'incontro: scegli una ricompensa."
		RunState.Phase.SCONTRO_FANTASMA:
			_suggerimento_fase.text = "Il fantasma ti aspetta. Puoi ancora riordinare o vendere le truppe."
			_principale.text = "Affronta il fantasma"
		RunState.Phase.FINE_RUN:
			_suggerimento_fase.text = _testo_fine(run)
			_principale.text = "Nuova partita"
		_:
			_suggerimento_fase.text = ""
	if not run.way_choices.is_empty():
		_suggerimento_fase.text = "Nuova era: scegli la via della nazione. Diventa parte della tua identità."
	elif not run.government_choices.is_empty():
		_suggerimento_fase.text = "Nuova era: il governo può evolvere. Scegli la nuova forma, oppure resta com'è."


## Suggerimento durante i round del Consiglio (GDD §4.2).
func _testo_consiglio(run: RunState) -> String:
	var consigliere: AdvisorDef = run.chosen_advisor
	if run.is_revolution_round():
		if run.chosen_event == null:
			return "Il Malcontento è esploso: scoppia la Rivoluzione. Non si può evitare."
		return "Rivoluzione: scegli il nuovo governo. Il Malcontento poi si azzera."
	if run.chosen_event != null:
		if run.chosen_event.family == EventDef.Family.FORTUNA:
			return "%s: prendi il dono, oppure passa." % run.chosen_event.display_name
		return "%s: scegli un'opzione, oppure passa. Le opzioni spente dicono che cosa serve." % run.chosen_event.display_name
	if consigliere == null:
		if run.advisor_choices.is_empty() and run.event_choice == null:
			return "Nessun consigliere ha proposte per questo tema: passa il round."
		var speciale: bool = run.event_choice != null
		for scelta: AdvisorDef in run.advisor_choices:
			if scelta.special == AdvisorDef.Special.VISITATORE:
				speciale = true
		if speciale:
			return "Scegli una carta (tema: %s): un consigliere, oppure chi è arrivato in questo round." % run.theme_name()
		return "Scegli quale consigliere ascoltare (tema: %s). Passa il mouse sulle carte per i dettagli." % run.theme_name()
	var testo: String = "%s: prendi una proposta, oppure passa." % consigliere.display_name
	if run.upgrade_used:
		testo += " Potenzia già usato in questo round."
	elif consigliere.special == AdvisorDef.Special.NESSUNO:
		testo += " Potenzia: clicca una tua carta con tipo %s." % ", ".join(consigliere.types)
	elif consigliere.special == AdvisorDef.Special.ANZIANO and run.elder_upgrades_used < run.run_rules.elder_upgrades_per_year:
		testo += " Potenzia: clicca un tuo edificio neutro."
	return testo


func _testo_fine(run: RunState) -> String:
	match run.run_end:
		RunState.RunEnd.VITTORIA:
			return "Hai vinto la partita! Vittorie %d, Prestigio %d." % [run.wins, run.prestige]
		RunState.RunEnd.SCONFITTA:
			return "La partita è finita con una sconfitta."
		RunState.RunEnd.FINE_PROVA:
			return "Fine della partita di prova (%d anni)." % run.year
	return ""


## In battaglia restano solo i comandi dello scontro.
func modalita_scontro(attiva: bool, titolo: String = "") -> void:
	_comandi.visible = not attiva
	_barra_scontro.visible = attiva
	_colonna_principale.visible = not attiva
	_magazzino.visible = false
	_effetti.visible = false
	_cronaca.visible = false
	nascondi_pezzo()
	if attiva:
		_fase.text = titolo
		_sotto_fase.text = "Le truppe agiscono da destra verso sinistra"
		imposta_pausa(false)


func imposta_tempo(millisecondi: int) -> void:
	_tempo.text = SchedaCarta.secondi(millisecondi)


func imposta_pausa(in_pausa: bool) -> void:
	_pulsante_pausa.text = "Riprendi" if in_pausa else "Pausa"


# --- Pannelli a richiesta ----------------------------------------------------------

## azioni: elenco di { "testo": String, "attiva": bool, "clic": Callable }.
func mostra_pezzo(titolo: String, testo: String, azioni: Array[Dictionary]) -> void:
	_titolo_pezzo.text = titolo
	_testo_pezzo.text = testo
	for figlio: Node in _azioni_pezzo.get_children():
		figlio.queue_free()
	for azione: Dictionary in azioni:
		var pulsante: Button = _pulsante(azione["testo"], azione["clic"])
		pulsante.disabled = not azione["attiva"]
		_azioni_pezzo.add_child(pulsante)
	_azioni_pezzo.add_child(_pulsante("Chiudi", func() -> void: annulla.emit()))
	_pezzo.visible = true
	_pezzo.reset_size()


func nascondi_pezzo() -> void:
	_pezzo.visible = false


## scelto riceve la posizione della voce scelta.
func mostra_scelte(titolo: String, testo: String, voci: Array[String], scelto: Callable) -> void:
	_titolo_scelte.text = titolo
	_testo_scelte.text = testo
	for figlio: Node in _voci_scelte.get_children():
		figlio.queue_free()
	for i: int in range(voci.size()):
		_voci_scelte.add_child(_pulsante(voci[i], _on_voce.bind(scelto, i)))
	_scelte.visible = true
	_centra(_scelte)


func _on_voce(scelto: Callable, posizione: int) -> void:
	_scelte.visible = false
	scelto.call(posizione)


func mostra_sostituzione(testo: String) -> void:
	_testo_sostituzione.text = testo
	_sostituzione.visible = true
	_sostituzione.reset_size()


func nascondi_sostituzione() -> void:
	_sostituzione.visible = false


func mostra_esito(titolo: String, sottotitolo: String, righe: Array[String], colore: Color, al_continua: Callable) -> void:
	_titolo_esito.text = titolo
	_titolo_esito.add_theme_color_override("font_color", colore)
	_sotto_esito.text = sottotitolo
	for figlio: Node in _righe_esito.get_children():
		figlio.queue_free()
	for riga: String in righe:
		var etichetta: Label = StileVisivo.etichetta("• " + riga, StileVisivo.FONT_TESTO, 19)
		etichetta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		etichetta.custom_minimum_size = Vector2(600, 0)
		etichetta.size = Vector2(600, 0)
		_righe_esito.add_child(etichetta)
	_al_continua = al_continua
	_esito.visible = true
	_centra(_esito)
	# Le scritte che vanno a capo conoscono la loro altezza solo dopo un passaggio di impaginazione.
	_ricentra_dopo_impaginazione(_esito)
	_esito.pivot_offset = _esito.size * 0.5
	_esito.scale = Vector2.ONE * 0.9
	var animazione: Tween = create_tween()
	animazione.tween_property(_esito, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Dimensione minima e posizione al centro dello schermo (per i pannelli che cambiano contenuto).
func _centra(pannello: Control) -> void:
	pannello.set_anchors_preset(Control.PRESET_TOP_LEFT)
	pannello.size = Vector2.ZERO
	pannello.size = pannello.get_combined_minimum_size()
	pannello.position = (get_viewport_rect().size - pannello.size) * 0.5


func _ricentra_dopo_impaginazione(pannello: Control) -> void:
	await get_tree().process_frame
	if is_instance_valid(pannello) and pannello.visible:
		_centra(pannello)
		pannello.pivot_offset = pannello.size * 0.5


func esito_visibile() -> bool:
	return _esito.visible


func _on_continua_esito() -> void:
	_esito.visible = false
	if _al_continua.is_valid():
		_al_continua.call()


func mostra_suggerimento(titolo: String, testo: String, posizione: Vector2) -> void:
	_titolo_suggerimento.text = titolo
	_testo_suggerimento.text = testo
	_suggerimento.visible = true
	_suggerimento.reset_size()
	var limite: Vector2 = get_viewport_rect().size - _suggerimento.size - Vector2(16, 16)
	_suggerimento.position = (posizione + Vector2(24, -_suggerimento.size.y - 16)).clamp(Vector2(16, 16), limite)


func nascondi_suggerimento() -> void:
	_suggerimento.visible = false


func mostra_messaggio(testo: String, errore: bool = false) -> void:
	_messaggio.text = testo
	_messaggio.add_theme_color_override("font_color", StileVisivo.PERICOLO.lightened(0.2) if errore else StileVisivo.ORO_LUCE)
	_messaggio.add_theme_font_size_override("font_size", 30 if errore else 52)
	_messaggio.reset_size()
	_messaggio.position = (get_viewport_rect().size - _messaggio.size) * Vector2(0.5, 0.4)
	if _animazione_messaggio != null and _animazione_messaggio.is_valid():
		_animazione_messaggio.kill()
	_animazione_messaggio = create_tween()
	_animazione_messaggio.tween_property(_messaggio, "modulate:a", 1.0, 0.15)
	_animazione_messaggio.tween_interval(1.8 if errore else 1.2)
	_animazione_messaggio.tween_property(_messaggio, "modulate:a", 0.0, 0.4)


func _on_velocita(fattore: float, scelto: Button) -> void:
	for pulsante: Button in _pulsanti_velocita:
		pulsante.button_pressed = pulsante == scelto
	velocita.emit(fattore)
