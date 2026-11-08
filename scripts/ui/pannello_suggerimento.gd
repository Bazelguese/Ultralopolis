class_name PannelloSuggerimento
extends Control
## Il riquadro che compare passando il mouse (richiesta di Davide, 8 novembre, sul modello di
## The Bazaar): titolo, testo con le parole chiave colorate e, accanto, un riquadro più piccolo
## che spiega le parole chiave contenute (Scudo, Corruzione, Sabotaggio…).
## Usato dalle carte della plancia e da tutti i suggerimenti dell'interfaccia.
## Solo presentazione.

const LARGHEZZA_MINIMA: float = 140.0
const LARGHEZZA_MASSIMA: float = 440.0
const LARGHEZZA_SPIEGAZIONI: float = 290.0
const DIMENSIONE_TITOLO: int = 26
const DIMENSIONE_TESTO: int = 18
const DIMENSIONE_SPIEGAZIONE: int = 15
const MARGINE_SCHERMO: float = 16.0
## Fotogrammi in cui il riquadro resta invisibile dopo un cambio di testo:
## il tempo di impaginare il testo, così non si vede un riquadro della misura sbagliata.
const FOTOGRAMMI_IMPAGINAZIONE: int = 2

var _fila: HBoxContainer
var _principale: PanelContainer
var _titolo: Label
var _testo: RichTextLabel
var _spiegazioni: VBoxContainer
var _punto: Vector2 = Vector2.ZERO
var _sopra: bool = false
var _titolo_attuale: String = ""
var _testo_attuale: String = ""
var _attesa_impaginazione: int = 0


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_fila = HBoxContainer.new()
	_fila.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fila.add_theme_constant_override("separation", 8)
	_fila.alignment = BoxContainer.ALIGNMENT_BEGIN
	add_child(_fila)
	_principale = PanelContainer.new()
	_principale.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_principale.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	var stile: StyleBoxFlat = StileVisivo.riquadro(Color(0.035, 0.055, 0.1, 0.97), StileVisivo.ORO.darkened(0.25))
	stile.set_corner_radius_all(10)
	_principale.add_theme_stylebox_override("panel", stile)
	_fila.add_child(_principale)
	var colonna: VBoxContainer = VBoxContainer.new()
	colonna.mouse_filter = Control.MOUSE_FILTER_IGNORE
	colonna.add_theme_constant_override("separation", 6)
	_principale.add_child(colonna)
	_titolo = StileVisivo.etichetta("", StileVisivo.FONT_TITOLI, DIMENSIONE_TITOLO, StileVisivo.ORO_LUCE)
	_titolo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	colonna.add_child(_titolo)
	_testo = testo_colorato(DIMENSIONE_TESTO)
	colonna.add_child(_testo)
	_spiegazioni = VBoxContainer.new()
	_spiegazioni.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_spiegazioni.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_spiegazioni.add_theme_constant_override("separation", 6)
	_fila.add_child(_spiegazioni)
	set_process(false)


## Un RichTextLabel con i caratteri e i colori del gioco, che si allunga quanto il suo testo.
## La larghezza la decide chi lo usa (custom_minimum_size.x).
static func testo_colorato(dimensione: int, colore: Color = StileVisivo.TESTO) -> RichTextLabel:
	var risultato: RichTextLabel = RichTextLabel.new()
	risultato.bbcode_enabled = true
	risultato.fit_content = true
	risultato.scroll_active = false
	risultato.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	risultato.mouse_filter = Control.MOUSE_FILTER_IGNORE
	risultato.add_theme_font_override("normal_font", StileVisivo.FONT_TESTO)
	risultato.add_theme_font_override("bold_font", StileVisivo.FONT_TESTO_FORTE)
	risultato.add_theme_font_size_override("normal_font_size", dimensione)
	risultato.add_theme_font_size_override("bold_font_size", dimensione)
	risultato.add_theme_color_override("default_color", colore)
	risultato.add_theme_constant_override("line_separation", 2)
	return risultato


## Mostra il riquadro vicino al punto (coordinate dello schermo). Con sopra = true compare
## sopra il punto (le carte della plancia), altrimenti sotto (i controlli dell'interfaccia).
## Richiamarlo con lo stesso testo sposta soltanto il riquadro.
func mostra(titolo: String, testo: String, punto: Vector2, sopra: bool = false) -> void:
	_punto = punto
	_sopra = sopra
	if visible and titolo == _titolo_attuale and testo == _testo_attuale:
		return
	_titolo_attuale = titolo
	_testo_attuale = testo
	var larghezza: float = _larghezza_per(titolo, testo)
	_titolo.text = titolo
	_titolo.visible = titolo != ""
	_titolo.custom_minimum_size = Vector2(larghezza, 0.0)
	_testo.text = TestoRicco.colora(testo)
	_testo.visible = testo != ""
	_testo.custom_minimum_size = Vector2(larghezza, 0.0)
	_aggiorna_spiegazioni(titolo, testo)
	visible = true
	_attesa_impaginazione = FOTOGRAMMI_IMPAGINAZIONE
	_fila.modulate.a = 0.0
	set_process(true)
	_sistema()


func nascondi() -> void:
	visible = false
	_titolo_attuale = ""
	_testo_attuale = ""
	set_process(false)


## Testo semplice attualmente mostrato (serve ai test).
func testo_mostrato() -> String:
	return _testo_attuale


func titolo_mostrato() -> String:
	return _titolo_attuale


## Nomi delle parole chiave spiegate accanto al riquadro (serve ai test).
func spiegazioni_mostrate() -> PackedStringArray:
	var nomi: PackedStringArray = PackedStringArray()
	for riquadro: Node in _spiegazioni.get_children():
		nomi.append(String(riquadro.get_meta(&"voce", "")))
	return nomi


func _process(_delta: float) -> void:
	_sistema()
	if _attesa_impaginazione > 0:
		_attesa_impaginazione -= 1
		if _attesa_impaginazione == 0:
			_fila.modulate.a = 1.0


## Misura il riquadro sul testo e lo tiene dentro lo schermo.
func _sistema() -> void:
	_fila.reset_size()
	var schermo: Vector2 = get_viewport_rect().size
	var misura: Vector2 = _fila.size
	var posizione: Vector2
	if _sopra:
		posizione = _punto + Vector2(24.0, -misura.y - 16.0)
	else:
		posizione = _punto + Vector2(18.0, 24.0)
		if posizione.y + misura.y > schermo.y - MARGINE_SCHERMO:
			posizione.y = _punto.y - misura.y - 12.0
	if posizione.x + misura.x > schermo.x - MARGINE_SCHERMO:
		posizione.x = _punto.x - misura.x - 18.0
	var limite: Vector2 = Vector2(maxf(MARGINE_SCHERMO, schermo.x - misura.x - MARGINE_SCHERMO), maxf(MARGINE_SCHERMO, schermo.y - misura.y - MARGINE_SCHERMO))
	_fila.position = posizione.clamp(Vector2(MARGINE_SCHERMO, MARGINE_SCHERMO), limite)


## Larghezza del testo: quanto la riga più lunga, entro un minimo e un massimo,
## così un suggerimento breve non diventa un riquadro enorme.
func _larghezza_per(titolo: String, testo: String) -> float:
	var testo_largo: float = _riga_piu_lunga(testo, StileVisivo.FONT_TESTO_FORTE, DIMENSIONE_TESTO)
	var titolo_largo: float = _riga_piu_lunga(titolo, StileVisivo.FONT_TITOLI, DIMENSIONE_TITOLO)
	return clampf(maxf(testo_largo, titolo_largo) + 6.0, LARGHEZZA_MINIMA, LARGHEZZA_MASSIMA)


static func _riga_piu_lunga(testo: String, font: Font, dimensione: int) -> float:
	var massima: float = 0.0
	for riga: String in testo.split("\n"):
		massima = maxf(massima, font.get_string_size(riga, HORIZONTAL_ALIGNMENT_LEFT, -1.0, dimensione).x)
	return massima


## La parola del titolo non si spiega di nuovo: il riquadro parla già di lei (es. "Malcontento").
func _aggiorna_spiegazioni(titolo: String, testo: String) -> void:
	# Liberati subito: sono solo scritte, nessuno le usa più.
	for vecchio: Node in _spiegazioni.get_children():
		_spiegazioni.remove_child(vecchio)
		vecchio.free()
	for voce: VoceLessico in TestoRicco.voci_da_spiegare(titolo + "\n" + testo):
		if voce.nome.to_lower() != titolo.strip_edges().to_lower():
			_spiegazioni.add_child(_riquadro_spiegazione(voce))
	_spiegazioni.visible = _spiegazioni.get_child_count() > 0


func _riquadro_spiegazione(voce: VoceLessico) -> PanelContainer:
	var riquadro: PanelContainer = PanelContainer.new()
	riquadro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	riquadro.set_meta(&"voce", voce.nome)
	var stile: StyleBoxFlat = StileVisivo.riquadro(Color(0.05, 0.075, 0.13, 0.96), Color(voce.colore, 0.55))
	stile.set_corner_radius_all(8)
	stile.set_content_margin_all(10)
	stile.border_width_left = 4
	riquadro.add_theme_stylebox_override("panel", stile)
	var testo: RichTextLabel = testo_colorato(DIMENSIONE_SPIEGAZIONE)
	testo.custom_minimum_size = Vector2(LARGHEZZA_SPIEGAZIONI, 0.0)
	# Il nome nel suo colore, poi la spiegazione con le sue parole chiave colorate.
	var nome: String = "[font_size=%d][b][color=#%s]%s[/color][/b][/font_size]" % [DIMENSIONE_SPIEGAZIONE + 3, voce.colore.to_html(false), voce.nome]
	testo.text = "%s\n%s" % [nome, TestoRicco.colora(voce.definizione)]
	riquadro.add_child(testo)
	return riquadro
