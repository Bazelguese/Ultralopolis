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
signal scegli_tecnologia(indice: int)
signal vendi_risorsa(tipo: int)
signal ricomincia
signal menu
signal pausa
signal velocita(fattore: float)
signal annulla
## Reazione scelta nella cronaca della stagione (GDD §9.6).
signal scegli_cronaca(indice: int)

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
var _identita: HFlowContainer
var _firma_identita: String = ""
var _fase: Label
var _sotto_fase: Label
var _prestigio: Label
var _vittorie: Label
var _era: Label
var _malcontento: Label
var _malcontento_cella: Control
var _ultima_possibilita: Label
var _valori_risorse: Dictionary[int, Label] = {}
## Le celle della barra delle risorse: il tooltip dice da dove arriva la produzione.
var _celle_risorse: Dictionary[int, Control] = {}
var _flusso: FlussoAnno
var _produzioni_risorse: Dictionary[int, Label] = {}
var _pulsante_era: Button
var _magazzino: PanelContainer
var _righe_magazzino: Dictionary[int, Label] = {}
var _vendite: Dictionary[int, Button] = {}
var _pulsante_ricerca: Button
## Avviso sopra la barra quando nessuna tecnologia è in studio (la Ricerca resta ferma).
var _avviso_ricerca: Label
var _pulsazione_ricerca: Tween
var _ricerca: PanelContainer
var _stato_ricerca: Label
var _mano_ricerca: HBoxContainer
var _colonne_albero: Dictionary[StringName, VBoxContainer] = {}
var _pulsante_tradizioni: Button
var _tradizioni: PanelContainer
var _lista_tradizioni: VBoxContainer
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
var _azioni_pezzo: HFlowContainer
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
## Riquadro in alto al centro: annunci (nuovo round, round passato…) e titolo dello scontro.
var _annuncio: VBoxContainer
var _sotto_messaggio: Label
## Colonna a sinistra: scheda della nazione e, sotto, il calendario dell'anno.
var _colonna_sinistra: VBoxContainer
var _riquadro_fase: PanelContainer
var _inclinazioni: BarreInclinazioni
var _usanze: Label
var _pannello_cronaca: PanelContainer
var _momento_cronaca: Label
var _titolo_cronaca: Label
var _racconto_cronaca: Label
var _personaggio_cronaca: Label
var _reazioni_cronaca: VBoxContainer
var _firma_cronaca: String = ""
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
	_crea_ricerca()
	_crea_tradizioni()
	_crea_pannelli_destra()
	_crea_comandi()
	_crea_principale()
	_crea_barra_scontro()
	_crea_pezzo()
	_crea_sostituzione()
	_crea_scelte()
	_crea_esito()
	_crea_pannello_cronaca()
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
func _valore(nome: String, colore: Color = StileVisivo.TESTO, simbolo: StringName = &"") -> Array:
	var colonna: VBoxContainer = VBoxContainer.new()
	colonna.add_theme_constant_override("separation", -6)
	colonna.add_child(_intestazione(nome, simbolo))
	var valore: Label = StileVisivo.etichetta("", StileVisivo.FONT_TITOLI, 34, colore)
	colonna.add_child(valore)
	return [colonna, valore]


## Nome di un valore della barra, con accanto il suo simbolo (se ne ha uno): è lo stesso
## simbolo stampato sulle carte, così il giocatore impara a riconoscerlo.
func _intestazione(nome: String, simbolo: StringName) -> HBoxContainer:
	var testa: HBoxContainer = HBoxContainer.new()
	testa.add_theme_constant_override("separation", 4)
	testa.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var trama: Texture2D = Simboli.trama(simbolo, 18.0)
	if trama != null:
		var immagine: TextureRect = TextureRect.new()
		immagine.texture = trama
		immagine.custom_minimum_size = Vector2(16, 16)
		immagine.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		immagine.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		immagine.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		immagine.modulate = StileVisivo.TESTO_TENUE
		immagine.mouse_filter = Control.MOUSE_FILTER_IGNORE
		testa.add_child(immagine)
	testa.add_child(StileVisivo.etichetta(nome.to_upper(), StileVisivo.FONT_TESTO_FORTE, 14, StileVisivo.TESTO_TENUE))
	return testa


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
	# Nome della nazione e, accanto, Ricomincia (con la stessa nazione).
	var testa: HBoxContainer = HBoxContainer.new()
	testa.add_theme_constant_override("separation", 12)
	colonna.add_child(testa)
	_nazione = StileVisivo.etichetta("", StileVisivo.FONT_TITOLI, 34)
	_nazione.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	testa.add_child(_nazione)
	var ricomincia_pulsante: Button = _pulsante("Ricomincia", func() -> void: ricomincia.emit())
	ricomincia_pulsante.add_theme_font_size_override("font_size", 16)
	ricomincia_pulsante.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	ricomincia_pulsante.tooltip_text = "Nuova partita con la stessa nazione."
	testa.add_child(ricomincia_pulsante)
	# Ogni elemento dell'identità ha il suo riquadro con che cosa fa (P4).
	_identita = HFlowContainer.new()
	_identita.custom_minimum_size = Vector2(330, 0)
	_identita.add_theme_constant_override("h_separation", 4)
	_identita.add_theme_constant_override("v_separation", 0)
	colonna.add_child(_identita)
	# Inclinazioni, usanze e vocazioni (GDD §9.6, v0.29).
	_inclinazioni = BarreInclinazioni.new()
	colonna.add_child(_inclinazioni)
	_usanze = StileVisivo.etichetta("", StileVisivo.FONT_TESTO_FORTE, 15, StileVisivo.ORO_LUCE)
	_usanze.custom_minimum_size = Vector2(320, 0)
	_usanze.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_usanze.mouse_filter = Control.MOUSE_FILTER_STOP
	colonna.add_child(_usanze)
	_colonna_sinistra = VBoxContainer.new()
	_colonna_sinistra.add_theme_constant_override("separation", 10)
	_colonna_sinistra.add_child(riquadro)
	_ancora(_colonna_sinistra, Control.PRESET_TOP_LEFT, Vector2(24, 20))


## Calendario dell'anno in verticale, sotto la scheda della nazione, con la fase e la Resistenza
## del prossimo scontro (richiesta di Davide, 6 novembre).
func _crea_fase() -> void:
	var riquadro: PanelContainer = PanelContainer.new()
	var dentro: VBoxContainer = VBoxContainer.new()
	dentro.add_theme_constant_override("separation", 6)
	riquadro.add_child(dentro)
	_fase = StileVisivo.etichetta("", StileVisivo.FONT_TITOLI, 20)
	_fase.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_fase.custom_minimum_size = Vector2(266, 0)
	dentro.add_child(_fase)
	# Il flusso dell'anno, visivo (GDD §3.2, v0.25): stagioni, mesi, scontri e mese in corso.
	_flusso = FlussoAnno.new()
	_flusso.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	dentro.add_child(_flusso)
	_sotto_fase = StileVisivo.etichetta("", StileVisivo.FONT_TESTO_FORTE, 16, StileVisivo.TESTO_TENUE)
	_sotto_fase.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_sotto_fase.custom_minimum_size = Vector2(266, 0)
	dentro.add_child(_sotto_fase)
	# Stretto: sta a sinistra del ritratto della nazione.
	riquadro.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_colonna_sinistra.add_child(riquadro)
	_riquadro_fase = riquadro

	# In alto al centro: gli annunci della partita.
	_annuncio = VBoxContainer.new()
	_annuncio.alignment = BoxContainer.ALIGNMENT_CENTER
	_annuncio.add_theme_constant_override("separation", 0)
	_annuncio.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_messaggio = StileVisivo.etichetta("", StileVisivo.FONT_TITOLI, 46, StileVisivo.ORO_LUCE)
	_messaggio.add_theme_color_override("font_outline_color", StileVisivo.OMBRA_TESTO)
	_messaggio.add_theme_constant_override("outline_size", 12)
	_messaggio.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_messaggio.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_annuncio.add_child(_messaggio)
	_sotto_messaggio = StileVisivo.etichetta("", StileVisivo.FONT_TESTO_FORTE, 22, StileVisivo.TESTO)
	_sotto_messaggio.add_theme_color_override("font_outline_color", StileVisivo.OMBRA_TESTO)
	_sotto_messaggio.add_theme_constant_override("outline_size", 8)
	_sotto_messaggio.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sotto_messaggio.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_annuncio.add_child(_sotto_messaggio)
	_ancora(_annuncio, Control.PRESET_CENTER_TOP, Vector2(0, 26))
	_annuncio.modulate.a = 0.0


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
	var malcontento: Array = _valore("Malcontento", StileVisivo.TESTO, &"malcontento")
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
		cella.custom_minimum_size = Vector2(100, 0)
		cella.tooltip_text = "%s: quantità nel Magazzino e produzione della prossima stagione (d'inverno niente Cibo)." % Res.NAMES[tipo]
		if tipo == Res.Type.RICERCA:
			cella.tooltip_text = "Ricerca: va nella tecnologia che stai studiando (raccolta / costo).\nSenza una tecnologia in studio resta in attesa. Non si vende."

		cella.mouse_filter = Control.MOUSE_FILTER_PASS
		cella.add_child(_intestazione(Res.NAMES[tipo], Simboli.di_risorsa(tipo as Res.Type)))
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
		_celle_risorse[tipo] = cella
		_produzioni_risorse[tipo] = produzione
	var spinta: Control = Control.new()
	spinta.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	riga.add_child(spinta)
	_pulsante_ricerca = _pulsante("Ricerca", func() -> void: _ricerca.visible = not _ricerca.visible)
	_pulsante_ricerca.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	riga.add_child(_pulsante_ricerca)
	_avviso_ricerca = StileVisivo.etichetta("Nessuna tecnologia in studio: la Ricerca resta ferma. Clicca qui sotto, su Ricerca.",
			StileVisivo.FONT_TESTO_FORTE, 18, StileVisivo.PERICOLO)
	_avviso_ricerca.add_theme_constant_override("outline_size", 8)
	_avviso_ricerca.add_theme_color_override("font_outline_color", StileVisivo.OMBRA_TESTO)
	_avviso_ricerca.visible = false
	_pulsante_tradizioni = _pulsante("Tradizioni", func() -> void: _tradizioni.visible = not _tradizioni.visible)
	_pulsante_tradizioni.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	riga.add_child(_pulsante_tradizioni)
	var mercato: Button = _pulsante("Mercato", func() -> void: _magazzino.visible = not _magazzino.visible)
	mercato.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	riga.add_child(mercato)
	_pulsante_era = _pulsante("", func() -> void: avanza_era.emit())
	_pulsante_era.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	riga.add_child(_pulsante_era)
	add_child(barra)
	_ancora(_avviso_ricerca, Control.PRESET_BOTTOM_RIGHT, Vector2(-30, SOPRA_BARRA + 16.0))
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
		if tipo == Res.Type.ORO or tipo == Res.Type.RICERCA:
			# L'Oro non si vende; la Ricerca va nelle tecnologie (GDD §10.5).
			griglia.add_child(Control.new())
		else:
			var vendi: Button = _pulsante("Vendi", _on_vendi.bind(tipo))
			vendi.add_theme_font_size_override("font_size", 16)
			griglia.add_child(vendi)
			_vendite[tipo] = vendi
	_ancora(_magazzino, Control.PRESET_BOTTOM_LEFT, Vector2(24, SOPRA_BARRA))
	_magazzino.visible = false


## Pannello della Ricerca (GDD §10.5, §14.3): tecnologia in studio, mano di carte e albero.
func _crea_ricerca() -> void:
	_ricerca = PanelContainer.new()
	_ricerca.add_theme_stylebox_override("panel", StileVisivo.riquadro(Color(0.04, 0.06, 0.11, 0.96), StileVisivo.ORO))
	var colonna: VBoxContainer = VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 10)
	_ricerca.add_child(colonna)
	var testa: HBoxContainer = HBoxContainer.new()
	testa.add_child(StileVisivo.etichetta("RICERCA", StileVisivo.FONT_TITOLI, 34, StileVisivo.ORO_LUCE))
	var spinta: Control = Control.new()
	spinta.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	testa.add_child(spinta)
	testa.add_child(_pulsante("Chiudi", func() -> void: _ricerca.visible = false))
	colonna.add_child(testa)
	_stato_ricerca = StileVisivo.etichetta("", StileVisivo.FONT_TESTO, 18)
	_stato_ricerca.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_stato_ricerca.custom_minimum_size = Vector2(1400, 0)
	colonna.add_child(_stato_ricerca)
	colonna.add_child(StileVisivo.etichetta("LA MANO · scegli che cosa studiare (non consuma il round)", StileVisivo.FONT_TESTO_FORTE, 16, StileVisivo.TESTO_TENUE))
	_mano_ricerca = HBoxContainer.new()
	_mano_ricerca.add_theme_constant_override("separation", 12)
	colonna.add_child(_mano_ricerca)
	colonna.add_child(StileVisivo.etichetta("L'ALBERO · passa il mouse su una tecnologia per i dettagli", StileVisivo.FONT_TESTO_FORTE, 16, StileVisivo.TESTO_TENUE))
	var scorri: ScrollContainer = ScrollContainer.new()
	scorri.custom_minimum_size = Vector2(1400, 430)
	scorri.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	colonna.add_child(scorri)
	var rami: HBoxContainer = HBoxContainer.new()
	rami.add_theme_constant_override("separation", 18)
	rami.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scorri.add_child(rami)
	for ramo: StringName in TechDef.BRANCHES:
		var lista: VBoxContainer = VBoxContainer.new()
		lista.add_theme_constant_override("separation", 2)
		lista.custom_minimum_size = Vector2(335, 0)
		rami.add_child(lista)
		_colonne_albero[ramo] = lista
	_ancora(_ricerca, Control.PRESET_CENTER, Vector2.ZERO)
	_ricerca.visible = false


## Pannello delle Tradizioni (GDD §10.4.1, §14.3): per ogni via adottata i suoi passi,
## l'impresa con quanto manca e l'effetto; poi le ascensioni prese.
func _crea_tradizioni() -> void:
	_tradizioni = PanelContainer.new()
	_tradizioni.add_theme_stylebox_override("panel", StileVisivo.riquadro(Color(0.04, 0.06, 0.11, 0.96), StileVisivo.ORO))
	var colonna: VBoxContainer = VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 10)
	_tradizioni.add_child(colonna)
	var testa: HBoxContainer = HBoxContainer.new()
	testa.add_child(StileVisivo.etichetta("TRADIZIONI", StileVisivo.FONT_TITOLI, 34, StileVisivo.ORO_LUCE))
	var spinta: Control = Control.new()
	spinta.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	testa.add_child(spinta)
	testa.add_child(_pulsante("Chiudi", func() -> void: _tradizioni.visible = false))
	colonna.add_child(testa)
	var scorri: ScrollContainer = ScrollContainer.new()
	scorri.custom_minimum_size = Vector2(1000, 560)
	scorri.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	colonna.add_child(scorri)
	_lista_tradizioni = VBoxContainer.new()
	_lista_tradizioni.add_theme_constant_override("separation", 6)
	_lista_tradizioni.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scorri.add_child(_lista_tradizioni)
	_ancora(_tradizioni, Control.PRESET_CENTER, Vector2.ZERO)
	_tradizioni.visible = false


func _aggiorna_tradizioni(run: RunState) -> void:
	for figlio: Node in _lista_tradizioni.get_children():
		figlio.queue_free()
	var vie: Array[IdentityDef] = run.adopted_ways()
	var fatti: int = 0
	if vie.is_empty():
		_lista_tradizioni.add_child(_riga_tradizioni("Le tradizioni cominciano con la prima via, entrando nell'era 2.", StileVisivo.TESTO_TENUE, 18))
	for via: IdentityDef in vie:
		var completa: bool = run.completed_ways.has(via)
		_lista_tradizioni.add_child(_riga_tradizioni("%s%s" % [via.display_name.to_upper(), " · albero completo" if completa else ""], StileVisivo.ORO_LUCE, 22))
		for passo: TraditionDef in via.traditions:
			var fatto: bool = run.traditions_done.has(passo)
			if fatto:
				fatti += 1
			var impresa: String = passo.deed.describe() if passo.deed != null else ""
			var testo: String = "%s — %s (%s) → %s" % [passo.display_name, impresa, run.tradition_progress_text(passo), passo.description]
			_lista_tradizioni.add_child(_riga_tradizioni(testo, Color("9be8a5") if fatto else StileVisivo.TESTO, 17))
	var prese: Array[IdentityDef] = run.ascensions()
	if not prese.is_empty():
		_lista_tradizioni.add_child(_riga_tradizioni("ASCENSIONI", StileVisivo.ORO_LUCE, 22))
		for ascensione: IdentityDef in prese:
			_lista_tradizioni.add_child(_riga_tradizioni("%s (livello %d) → %s" % [ascensione.display_name, ascensione.ascension_level, ascensione.description], Color("c7b8ff"), 17))
	_pulsante_tradizioni.text = "Tradizioni · %d" % fatti


func _riga_tradizioni(testo: String, colore: Color, dimensione: int) -> Label:
	var riga: Label = StileVisivo.etichetta(testo, StileVisivo.FONT_TESTO, dimensione, colore)
	riga.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	riga.custom_minimum_size = Vector2(960, 0)
	return riga


## true se il pannello delle Tradizioni è aperto.
func tradizioni_visibile() -> bool:
	return _tradizioni.visible


## true se il pannello della Ricerca è aperto.
func ricerca_visibile() -> bool:
	return _ricerca.visible


func _on_scegli_tecnologia(indice: int) -> void:
	scegli_tecnologia.emit(indice)


func _aggiorna_ricerca(run: RunState) -> void:
	var righe: PackedStringArray = PackedStringArray()
	if run.current_tech != null:
		righe.append("In studio: %s — %d/%d Ricerca. %s" % [run.current_tech.display_name, run.tech_progress_of(run.current_tech), run.current_tech.cost, run.current_tech.description])
	else:
		righe.append("Nessuna tecnologia in studio: la Ricerca resta in attesa (%d) e passa alla prima che scegli." % run.research_waiting())
	var produzione: int = run.production_per_phase()[Res.Type.RICERCA]
	righe.append("Ricerca alla prossima produzione: +%d." % produzione)
	var servono: int = run.next_era_techs_needed()
	if servono >= 0:
		righe.append("Prossima era (%s): %d/%d tecnologie dell'era %s." % [run.era_name(run.era + 1), mini(run.techs_done_in_era(run.era), servono), servono, run.era_name()])
	_stato_ricerca.text = "\n".join(righe)

	for figlio: Node in _mano_ricerca.get_children():
		figlio.queue_free()
	var carte: Array[TechDef] = run.tech_hand_cards()
	for i: int in range(carte.size()):
		var tecnologia: TechDef = carte[i]
		var carta: Button = Button.new()
		carta.text = _testo_carta(run, tecnologia)
		carta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		carta.alignment = HORIZONTAL_ALIGNMENT_LEFT
		carta.custom_minimum_size = Vector2(330, 150)
		carta.add_theme_font_size_override("font_size", 17)
		carta.disabled = tecnologia == run.current_tech
		var motivo: String = run.tech_block_reason(tecnologia, run.is_golden(tecnologia))
		if motivo != "":
			carta.disabled = true
			carta.tooltip_text = motivo
		carta.pressed.connect(_on_scegli_tecnologia.bind(i))
		_mano_ricerca.add_child(carta)
	if carte.is_empty():
		_mano_ricerca.add_child(StileVisivo.etichetta("Nessuna tecnologia da studiare per ora.", StileVisivo.FONT_TESTO, 17, StileVisivo.TESTO_TENUE))

	for ramo: StringName in _colonne_albero:
		var lista: VBoxContainer = _colonne_albero[ramo]
		for figlio: Node in lista.get_children():
			figlio.queue_free()
		lista.add_child(StileVisivo.etichetta("RAMO %s" % TechDef.BRANCH_NAMES[ramo].to_upper(), StileVisivo.FONT_TITOLI, 22, StileVisivo.colore_mana_nome(ramo)))
		var era_mostrata: int = 0
		for tecnologia: TechDef in run.tree_technologies():
			if tecnologia.branch() != ramo:
				continue
			if tecnologia.era != era_mostrata:
				era_mostrata = tecnologia.era
				lista.add_child(StileVisivo.etichetta(run.era_name(era_mostrata), StileVisivo.FONT_TESTO_FORTE, 15, StileVisivo.TESTO_TENUE))
			lista.add_child(_voce_albero(run, tecnologia))


func _testo_carta(run: RunState, tecnologia: TechDef) -> String:
	var stato: String = ""
	if run.is_golden(tecnologia):
		stato = "Carta dorata · "
	elif tecnologia == run.current_tech:
		stato = "In studio · "
	elif run.tech_status(tecnologia) == RunState.TechStatus.INIZIATA:
		stato = "Iniziata · "
	var testo: String = "%s\n%s%s · %s · altezza %d\n%d/%d Ricerca\n%s" % [tecnologia.display_name, stato,
			TechDef.BRANCH_NAMES.get(tecnologia.branch(), "?"), tecnologia.sphere, tecnologia.tier,
			run.tech_progress_of(tecnologia), tecnologia.cost, tecnologia.description]
	return testo + _riga_beneficiari(run, tecnologia.permanent_modifiers)


## "Ne beneficiano: Milizia, Lancieri" per un bonus legato a un tipo (GDD §6.6), vuoto se nessuna.
static func _riga_beneficiari(run: RunState, modificatori: Array[ModifierDef]) -> String:
	var nomi: PackedStringArray = PackedStringArray()
	for pezzo: BoardPiece in run.pieces_boosted_by(modificatori):
		nomi.append(pezzo.display_name())
	return "\n▲ Ne beneficiano: %s" % ", ".join(nomi) if not nomi.is_empty() else ""


## Una tecnologia dell'albero: colore e parola dicono lo stato, il suggerimento il perché (P4).
func _voce_albero(run: RunState, tecnologia: TechDef) -> Label:
	var stato: RunState.TechStatus = run.tech_status(tecnologia)
	var colore: Color = StileVisivo.TESTO
	var nota: String = ""
	match stato:
		RunState.TechStatus.COMPLETATA:
			colore = Color("9be8a5")
			nota = " · fatta"
		RunState.TechStatus.IN_CORSO:
			colore = StileVisivo.ORO_LUCE
			nota = " · in studio %d/%d" % [run.tech_progress_of(tecnologia), tecnologia.cost]
		RunState.TechStatus.INIZIATA:
			colore = Color("7fb4ff")
			nota = " · iniziata %d/%d" % [run.tech_progress_of(tecnologia), tecnologia.cost]
		RunState.TechStatus.BLOCCATA:
			colore = StileVisivo.TESTO_TENUE
			nota = " · bloccata"
	var voce: Label = StileVisivo.etichetta("%s%s (%d)%s" % ["  " if tecnologia.tier == 2 else "", tecnologia.display_name, tecnologia.cost, nota], StileVisivo.FONT_TESTO, 16, colore)
	voce.mouse_filter = Control.MOUSE_FILTER_PASS
	var aiuto: String = "%s (%s, altezza %d)\n%s%s" % [tecnologia.display_name, tecnologia.sphere, tecnologia.tier, tecnologia.description,
			_riga_beneficiari(run, tecnologia.permanent_modifiers)]
	if stato == RunState.TechStatus.BLOCCATA:
		aiuto += "\nBloccata: %s" % run.tech_block_reason(tecnologia)
	voce.tooltip_text = aiuto
	return voce


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
	# Larghezza fissa: testo e pulsanti vanno a capo invece di allargare il pannello oltre lo schermo.
	_testo_pezzo.custom_minimum_size = Vector2(560, 0)
	colonna.add_child(_testo_pezzo)
	_azioni_pezzo = HFlowContainer.new()
	_azioni_pezzo.add_theme_constant_override("h_separation", 8)
	_azioni_pezzo.add_theme_constant_override("v_separation", 8)
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


## Pannello della cronaca: il momento, la scena e le reazioni possibili della nazione.
func _crea_pannello_cronaca() -> void:
	_pannello_cronaca = PanelContainer.new()
	_pannello_cronaca.add_theme_stylebox_override("panel", StileVisivo.riquadro(Color(0.09, 0.07, 0.05, 0.96), StileVisivo.ORO))
	var colonna: VBoxContainer = VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 10)
	colonna.custom_minimum_size = Vector2(700, 0)
	_pannello_cronaca.add_child(colonna)
	_momento_cronaca = StileVisivo.etichetta("", StileVisivo.FONT_TITOLI, 20, StileVisivo.ORO)
	_momento_cronaca.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	colonna.add_child(_momento_cronaca)
	_titolo_cronaca = StileVisivo.etichetta("", StileVisivo.FONT_TITOLI, 46, StileVisivo.ORO_LUCE)
	_titolo_cronaca.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	colonna.add_child(_titolo_cronaca)
	_racconto_cronaca = StileVisivo.etichetta("", StileVisivo.FONT_TESTO, 21)
	_racconto_cronaca.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_racconto_cronaca.custom_minimum_size = Vector2(700, 0)
	_racconto_cronaca.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	colonna.add_child(_racconto_cronaca)
	_personaggio_cronaca = StileVisivo.etichetta("", StileVisivo.FONT_TESTO_FORTE, 17, StileVisivo.TESTO_TENUE)
	_personaggio_cronaca.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_personaggio_cronaca.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_personaggio_cronaca.custom_minimum_size = Vector2(700, 0)
	colonna.add_child(_personaggio_cronaca)
	colonna.add_child(StileVisivo.etichetta("Come reagisce la nazione?", StileVisivo.FONT_TITOLI, 22, StileVisivo.TESTO))
	_reazioni_cronaca = VBoxContainer.new()
	_reazioni_cronaca.add_theme_constant_override("separation", 8)
	colonna.add_child(_reazioni_cronaca)
	_ancora(_pannello_cronaca, Control.PRESET_CENTER, Vector2.ZERO)
	_pannello_cronaca.visible = false


## Mostra la cronaca della stagione quando la nazione deve reagire; le carte e lo scontro hanno la
## precedenza (P4: si vede sempre perché una reazione non si può scegliere).
func _aggiorna_cronaca(run: RunState) -> void:
	var attiva: bool = run.phase == RunState.Phase.CRONACA and run.current_chronicle != null \
			and run.way_choices.is_empty() and run.ascension_choices.is_empty() and run.government_choices.is_empty() \
			and not _esito.visible and not _barra_scontro.visible
	if not attiva:
		_pannello_cronaca.visible = false
		_firma_cronaca = ""
		return
	var cronaca: ChronicleDef = run.current_chronicle
	var opzioni: Array[EventOptionDef] = run.chronicle_options()
	var firma: String = "%s|%d|%d" % [cronaca.id, run.year, run.season]
	for opzione: EventOptionDef in opzioni:
		firma += "|%s" % run.option_block_reason(opzione)
	if firma == _firma_cronaca and _pannello_cronaca.visible:
		return
	_firma_cronaca = firma
	_momento_cronaca.text = "%s · anno %d" % [run.chronicle_moment().to_upper(), run.year]
	_titolo_cronaca.text = run.chronicle_text(cronaca.display_name)
	_racconto_cronaca.text = run.chronicle_text(cronaca.description)
	_personaggio_cronaca.text = ""
	if cronaca.requires_character != null:
		var chi: NationCharacter = run.character_of(cronaca.requires_character)
		if chi != null:
			_personaggio_cronaca.text = "%s · fiducia %+d" % [chi.describe(), chi.affinity]
	elif run.offered_vocation != null:
		_personaggio_cronaca.text = "Nasce dalle usanze: %s" % " + ".join(_nomi(run.offered_vocation.requires_customs))
	_personaggio_cronaca.visible = _personaggio_cronaca.text != ""
	for figlio: Node in _reazioni_cronaca.get_children():
		figlio.queue_free()
	for i: int in range(opzioni.size()):
		_reazioni_cronaca.add_child(_reazione(run, opzioni[i], i))
	_pannello_cronaca.visible = true
	_centra(_pannello_cronaca)
	_ricentra_dopo_impaginazione(_pannello_cronaca)


static func _nomi(elementi: Array[Resource]) -> PackedStringArray:
	var nomi: PackedStringArray = PackedStringArray()
	for elemento: Resource in elementi:
		nomi.append((elemento as IdentityDef).display_name)
	return nomi


## Una reazione: il pulsante con il nome, sotto che cosa fa, dove spinge la nazione e che cosa costa.
func _reazione(run: RunState, opzione: EventOptionDef, indice: int) -> Control:
	var riga: VBoxContainer = VBoxContainer.new()
	riga.add_theme_constant_override("separation", 2)
	var pulsante: Button = _pulsante(run.chronicle_text(opzione.label), func() -> void: scegli_cronaca.emit(indice))
	pulsante.custom_minimum_size = Vector2(0, 48)
	var motivo: String = run.option_block_reason(opzione)
	pulsante.disabled = motivo != ""
	pulsante.tooltip_text = motivo
	riga.add_child(pulsante)
	var parti: PackedStringArray = PackedStringArray()
	if opzione.description != "":
		parti.append(run.chronicle_text(opzione.description))
	var spinta: String = Inclination.describe_shift(opzione.inclination_shift)
	if spinta != "":
		parti.append(spinta)
	if motivo != "":
		parti.append(motivo)
	if not parti.is_empty():
		var nota: Label = StileVisivo.etichetta("  ".join(parti), StileVisivo.FONT_TESTO, 16, StileVisivo.PERICOLO if motivo != "" else StileVisivo.TESTO_TENUE)
		nota.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		nota.custom_minimum_size = Vector2(700, 0)
		riga.add_child(nota)
	return riga


func cronaca_visibile() -> bool:
	return _pannello_cronaca.visible


## Elementi dell'identità come voci separate: passando il mouse si legge che cosa fanno.
func _aggiorna_identita(run: RunState) -> void:
	var elementi: Array[IdentityDef] = []
	for elemento: IdentityDef in run.identity:
		if elemento.dimension not in [IdentityDef.Dimension.USANZA, IdentityDef.Dimension.VOCAZIONE]:
			elementi.append(elemento)
	var firma: String = ""
	for elemento: IdentityDef in elementi:
		firma += "|%s" % elemento.id
	if firma == _firma_identita:
		return
	_firma_identita = firma
	for figlio: Node in _identita.get_children():
		figlio.queue_free()
	for i: int in range(elementi.size()):
		var elemento: IdentityDef = elementi[i]
		var perk: bool = elemento.dimension in [IdentityDef.Dimension.PERK, IdentityDef.Dimension.ASCENSIONE]
		var voce: Label = StileVisivo.etichetta(elemento.display_name + (" ·" if i < elementi.size() - 1 else ""),
				StileVisivo.FONT_TESTO, 16, Color("c7b8ff") if perk else StileVisivo.TESTO_TENUE)
		voce.mouse_filter = Control.MOUSE_FILTER_STOP
		voce.mouse_default_cursor_shape = Control.CURSOR_HELP
		voce.tooltip_text = "%s — %s\n%s" % [IdentityDef.DIMENSION_NAMES[elemento.dimension], elemento.display_name, elemento.description]
		_identita.add_child(voce)


## Inclinazioni, usanze, vocazioni e personaggi sulla scheda della nazione.
func _aggiorna_nazione(run: RunState) -> void:
	var usanze: PackedStringArray = PackedStringArray()
	var aiuto: PackedStringArray = PackedStringArray()
	for usanza: IdentityDef in run.customs():
		usanze.append(usanza.display_name)
		aiuto.append("Usanza %s (dall'anno %d): %s" % [usanza.display_name, run.custom_years.get(usanza.id, run.year), usanza.description])
	var testo: PackedStringArray = PackedStringArray()
	for vocazione: IdentityDef in run.vocations():
		testo.append("Vocazione: %s" % vocazione.display_name)
		aiuto.append("Vocazione %s: %s" % [vocazione.display_name, vocazione.description])
	if not usanze.is_empty():
		testo.append("Usanze: %s" % " · ".join(usanze))
	var persone: PackedStringArray = PackedStringArray()
	for chi: NationCharacter in run.characters:
		persone.append("%s (%s)" % [chi.name, chi.def.role.to_lower()])
		aiuto.append("%s · fiducia %+d" % [chi.describe(), chi.affinity])
	if not persone.is_empty():
		testo.append("Personaggi: %s" % " · ".join(persone))
	_usanze.text = "\n".join(testo)
	_usanze.visible = not testo.is_empty()
	_usanze.tooltip_text = "\n".join(aiuto)
	var spiegazione: String = "Inclinazioni della nazione: le cronache le spostano con le tue scelte. A %d passi da un lato nasce un'usanza; due usanze adatte aprono una vocazione." % run.run_rules.inclination_limit
	_inclinazioni.aggiorna(run.inclinations, run.run_rules.inclination_limit, spiegazione)


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
	# Il messaggio sta nel riquadro degli annunci, in alto al centro (_crea_fase).
	pass


# --- Aggiornamento della partita ---------------------------------------------------

func aggiorna_partita(run: RunState) -> void:
	_nazione.text = run.nation_name.to_upper()
	_aggiorna_identita(run)
	_aggiorna_nazione(run)
	var comprando: bool = run.is_shopping_phase()
	# GDD §3.2 (v0.25): anno, stagione e mese, es. "Anno 2 · Estate · Agosto".
	_flusso.visible = true
	_flusso.aggiorna(run)
	_fase.text = "Anno %d · %s" % [run.year, run.phase_name()]
	if comprando:
		_fase.text += " · %s · tema: %s" % [run.month_name(), run.theme_name()]
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

	var produzione: Array[int] = run.next_season_production()
	for tipo: int in _celle_risorse:
		var testa: String = "%s: %s nel Magazzino." % [Res.NAMES[tipo], run.stock_text(tipo)]
		if tipo == Res.Type.RICERCA:
			testa = "Ricerca: va nella tecnologia che stai studiando. Senza una tecnologia in studio resta in attesa. Non si vende."
		_celle_risorse[tipo].tooltip_text = "%s\nProssima stagione +%s:\n%s" % [testa, Res.format(tipo, produzione[tipo]),
				"\n".join(run.production_origin_lines(tipo))]
		var mantenimento: PackedStringArray = run.upkeep_lines(tipo)
		if not mantenimento.is_empty():
			_celle_risorse[tipo].tooltip_text += "\nMantenimento prima di ogni scontro:\n%s" % "\n".join(mantenimento)
		var richieste: PackedStringArray = run.resource_demand_lines(tipo)
		if not richieste.is_empty():
			_celle_risorse[tipo].tooltip_text += "\nChi la chiede:\n%s" % "\n".join(richieste)
	for tipo: int in _valori_risorse:
		_valori_risorse[tipo].text = run.stock_text(tipo)
		_produzioni_risorse[tipo].text = "+%s" % Res.format(tipo, produzione[tipo]) if produzione[tipo] > 0 else ""
	# La Ricerca va nella tecnologia in studio (GDD §10.5): raccolta / costo, oppure in attesa.
	if run.current_tech != null:
		_valori_risorse[Res.Type.RICERCA].text = "%d/%d" % [run.tech_progress_of(run.current_tech), run.current_tech.cost]
	_pulsante_ricerca.text = "Ricerca · %s" % (run.current_tech.display_name if run.current_tech != null else "scegli")
	_aggiorna_avviso_ricerca(run)
	var tecnologie_era: int = run.next_era_techs_needed()
	if tecnologie_era >= 0:
		var fatte: int = mini(run.techs_done_in_era(run.era), tecnologie_era)
		_pulsante_era.text = "Entra in %s · %d/%d tecnologie" % [run.era_name(run.era + 1), fatte, tecnologie_era]
		_pulsante_era.visible = true
		_pulsante_era.disabled = not comprando or run.era_block_reason() != ""
		_pulsante_era.tooltip_text = run.era_block_reason() if run.era_block_reason() != "" else "Entri quando vuoi: le offerte dell'era attuale spariscono."
	else:
		_pulsante_era.visible = false
	_aggiorna_ricerca(run)
	_aggiorna_tradizioni(run)
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
	var storia: Array[String] = run.story.slice(maxi(0, run.story.size() - 5))
	storia.reverse()
	_testo_cronaca.text = ("STORIA DELLA NAZIONE\n%s\n\nREGISTRO\n" % "\n".join(storia) if not storia.is_empty() else "") + "\n".join(ultime)

	var scelta_via: bool = not run.way_choices.is_empty() or not run.government_choices.is_empty() or not run.ascension_choices.is_empty()
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
		RunState.Phase.CONSIGLIO:
			_suggerimento_fase.text = _testo_consiglio(run)
		RunState.Phase.SCELTA_INCONTRO:
			_suggerimento_fase.text = "Incontro del mondo: scegli quale minaccia affrontare. Se perdi, l'Oro si dimezza." + _testo_mantenimento(run)
		RunState.Phase.RICOMPENSA_INCONTRO:
			_suggerimento_fase.text = "Hai vinto l'incontro: scegli una ricompensa."
		RunState.Phase.SCONTRO_FANTASMA:
			_suggerimento_fase.text = "Il fantasma ti aspetta. Puoi ancora riordinare o vendere le truppe." + _testo_mantenimento(run)
			_principale.text = "Affronta il fantasma"
		RunState.Phase.FINE_RUN:
			_suggerimento_fase.text = _testo_fine(run)
			_principale.text = "Nuova partita"
		RunState.Phase.CRONACA:
			_suggerimento_fase.text = "%s: scegli come reagisce la nazione. Poi comincia la stagione." % run.chronicle_moment()
		_:
			_suggerimento_fase.text = ""
	if not run.way_choices.is_empty():
		_suggerimento_fase.text = "Nuova era: scegli la via della nazione. Diventa parte della tua identità."
	elif not run.ascension_choices.is_empty():
		_suggerimento_fase.text = "Albero di una via completo: scegli un'ascensione. È per sempre."
	elif not run.government_choices.is_empty():
		_suggerimento_fase.text = "Nuova era: il governo può evolvere. Scegli la nuova forma, oppure resta com'è."
	_aggiorna_cronaca(run)


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


## Senza una tecnologia in studio (e con tecnologie da scegliere) il pulsante Ricerca diventa
## rosso e pulsa, la casella della Ricerca dice quanta ne aspetta e sopra la barra compare un avviso.
func _aggiorna_avviso_ricerca(run: RunState) -> void:
	var ferma: bool = run.current_tech == null and not run.tech_hand_cards().is_empty() and run.phase != RunState.Phase.FINE_RUN
	_avviso_ricerca.visible = ferma
	StileVisivo.rendi_allarme(_pulsante_ricerca, ferma)
	if ferma:
		_pulsante_ricerca.text = "Ricerca · scegli!"
		_valori_risorse[Res.Type.RICERCA].text = str(run.research_waiting())
		_valori_risorse[Res.Type.RICERCA].add_theme_color_override("font_color", StileVisivo.PERICOLO)
		_produzioni_risorse[Res.Type.RICERCA].text = "ferma"
		_produzioni_risorse[Res.Type.RICERCA].add_theme_color_override("font_color", StileVisivo.PERICOLO)
		if _pulsazione_ricerca == null or not _pulsazione_ricerca.is_valid():
			_pulsazione_ricerca = create_tween().set_loops()
			_pulsazione_ricerca.tween_property(_pulsante_ricerca, "modulate", Color(1.0, 1.0, 1.0, 0.55), 0.6)
			_pulsazione_ricerca.tween_property(_pulsante_ricerca, "modulate", Color.WHITE, 0.6)
	else:
		_valori_risorse[Res.Type.RICERCA].add_theme_color_override("font_color", COLORI_RISORSE[Res.Type.RICERCA])
		_produzioni_risorse[Res.Type.RICERCA].add_theme_color_override("font_color", StileVisivo.TESTO_TENUE)
		if _pulsazione_ricerca != null and _pulsazione_ricerca.is_valid():
			_pulsazione_ricerca.kill()
		_pulsante_ricerca.modulate = Color.WHITE


## Prima di uno scontro: quanto si paga di mantenimento e chi resterebbe trascurato (GDD §5.6).
static func _testo_mantenimento(run: RunState) -> String:
	var totale: ResourceAmounts = run.upkeep_total()
	if totale.is_empty():
		return ""
	var testo: String = "\nMantenimento prima dello scontro: %s." % totale.describe()
	if not run.can_pay(totale):
		testo += " Non basta: alcune carte saranno trascurate (+1 Malcontento ciascuna)."
	return testo


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
		_flusso.visible = false
		_avviso_ricerca.visible = false
		_fase.text = titolo
		_sotto_fase.text = "Le truppe agiscono da destra verso sinistra"
		imposta_pausa(false)
	# Durante lo scontro il titolo resta in alto al centro; il calendario si nasconde.
	_riquadro_fase.visible = not attiva
	if _animazione_messaggio != null and _animazione_messaggio.is_valid():
		_animazione_messaggio.kill()
	_messaggio.text = titolo if attiva else ""
	_messaggio.add_theme_color_override("font_color", StileVisivo.ORO_LUCE)
	_sotto_messaggio.text = "Le truppe agiscono da destra verso sinistra" if attiva else ""
	_annuncio.modulate.a = 1.0 if attiva else 0.0


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


## Il riquadro sta in alto a destra del mouse. Se è indicata la carta da non coprire
## (una carta ingrandita, con i simboli), sta sotto di lei; se lì non c'è posto, al suo fianco.
func mostra_suggerimento(titolo: String, testo: String, posizione: Vector2, carta: Rect2 = Rect2()) -> void:
	_titolo_suggerimento.text = titolo
	_testo_suggerimento.text = testo
	_suggerimento.visible = true
	_suggerimento.reset_size()
	var schermo: Vector2 = get_viewport_rect().size
	var misura: Vector2 = _suggerimento.size
	var limite: Vector2 = schermo - misura - Vector2(16, 16)
	var punto: Vector2 = posizione + Vector2(24, -misura.y - 16)
	if carta.has_area():
		if carta.end.y + 12 + misura.y <= schermo.y - 16:
			punto = Vector2(carta.get_center().x - misura.x * 0.5, carta.end.y + 12)
		elif carta.end.x + 12 + misura.x <= schermo.x - 16:
			punto = Vector2(carta.end.x + 12, carta.position.y)
		else:
			punto = Vector2(carta.position.x - 12 - misura.x, carta.position.y)
	_suggerimento.position = punto.clamp(Vector2(16, 16), limite)


func nascondi_suggerimento() -> void:
	_suggerimento.visible = false


## Annuncio in alto al centro (richiesta di Davide, 6 novembre): "Round passato", "Nuovo round"…
## sotto è una seconda riga facoltativa. Gli errori sono in rosso e restano un po' di più.
func mostra_messaggio(testo: String, errore: bool = false, sotto: String = "") -> void:
	if _barra_scontro.visible and not errore:
		return
	_messaggio.text = testo
	_messaggio.add_theme_color_override("font_color", StileVisivo.PERICOLO.lightened(0.2) if errore else StileVisivo.ORO_LUCE)
	_messaggio.add_theme_font_size_override("font_size", 28 if errore else 46)
	_sotto_messaggio.text = sotto
	_sotto_messaggio.visible = sotto != ""
	if _animazione_messaggio != null and _animazione_messaggio.is_valid():
		_animazione_messaggio.kill()
	_animazione_messaggio = create_tween()
	_animazione_messaggio.tween_property(_annuncio, "modulate:a", 1.0, 0.15)
	_animazione_messaggio.tween_interval(2.6 if errore else 2.0)
	_animazione_messaggio.tween_property(_annuncio, "modulate:a", 0.0, 0.5)


func _on_velocita(fattore: float, scelto: Button) -> void:
	for pulsante: Button in _pulsanti_velocita:
		pulsante.button_pressed = pulsante == scelto
	velocita.emit(fattore)
