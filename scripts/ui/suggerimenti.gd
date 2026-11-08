class_name Suggerimenti
extends Control
## I suggerimenti dell'interfaccia (al posto dei tooltip grigi di Godot): passando il mouse
## su un controllo compare un PannelloSuggerimento con il testo colorato e le spiegazioni
## delle parole chiave (richiesta di Davide, 8 novembre).
## Uso: Suggerimenti.imposta(controllo, testo, titolo) al posto di controllo.tooltip_text = testo.
## Basta un gestore nella scena (lo crea l'HUD). Solo presentazione.

const GRUPPO: StringName = &"suggerimenti"
const META_TESTO: StringName = &"suggerimento_testo"
const META_TITOLO: StringName = &"suggerimento_titolo"
const META_COLLEGATO: StringName = &"suggerimento_collegato"
## Attesa prima che il riquadro compaia, come i tooltip di Godot (un po' più rapida).
const ATTESA_S: float = 0.35

var _pannello: PannelloSuggerimento
var _bersaglio: Control = null
var _attesa: float = 0.0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_to_group(GRUPPO)
	_pannello = PannelloSuggerimento.new()
	add_child(_pannello)
	set_process(false)


# --- Per chi costruisce l'interfaccia -------------------------------------------

## Il controllo mostra questo suggerimento. Testo vuoto: nessun suggerimento.
static func imposta(controllo: Control, testo: String, titolo: String = "") -> void:
	controllo.set_meta(META_TESTO, testo)
	controllo.set_meta(META_TITOLO, titolo)
	_collega(controllo)


## Per i controlli con un suggerimento diverso in ogni punto (es. il calendario dell'anno):
## fonte riceve il punto nelle coordinate del controllo e restituisce il testo.
static func imposta_dinamico(controllo: Control, fonte: Callable, titolo: String = "") -> void:
	controllo.set_meta(META_TESTO, fonte)
	controllo.set_meta(META_TITOLO, titolo)
	_collega(controllo)


## Il testo del suggerimento di un controllo nel punto indicato (coordinate del controllo).
static func testo_di(controllo: Control, punto: Vector2 = Vector2.ZERO) -> String:
	if not controllo.has_meta(META_TESTO):
		return ""
	var valore: Variant = controllo.get_meta(META_TESTO)
	if valore is Callable:
		return str((valore as Callable).call(punto))
	return str(valore)


static func titolo_di(controllo: Control) -> String:
	return str(controllo.get_meta(META_TITOLO, ""))


static func _collega(controllo: Control) -> void:
	# Il tooltip di sistema resta vuoto, altrimenti comparirebbero due riquadri.
	controllo.tooltip_text = ""
	if controllo.mouse_filter == Control.MOUSE_FILTER_IGNORE:
		controllo.mouse_filter = Control.MOUSE_FILTER_PASS
	if controllo.has_meta(META_COLLEGATO):
		return
	controllo.set_meta(META_COLLEGATO, true)
	controllo.mouse_entered.connect(func() -> void: _avvisa(controllo, true))
	controllo.mouse_exited.connect(func() -> void: _avvisa(controllo, false))


static func _avvisa(controllo: Control, dentro: bool) -> void:
	if not is_instance_valid(controllo) or not controllo.is_inside_tree():
		return
	var gestore: Suggerimenti = controllo.get_tree().get_first_node_in_group(GRUPPO) as Suggerimenti
	if gestore == null:
		return
	if dentro:
		gestore._entra(controllo)
	else:
		gestore._esce(controllo)


# --- Il gestore ------------------------------------------------------------------

## Il riquadro dei suggerimenti (serve ai test).
func pannello() -> PannelloSuggerimento:
	return _pannello


func _entra(controllo: Control) -> void:
	_bersaglio = controllo
	_attesa = 0.0
	_pannello.nascondi()
	set_process(true)


func _esce(controllo: Control) -> void:
	if controllo == _bersaglio:
		_chiudi()


func _chiudi() -> void:
	_bersaglio = null
	_pannello.nascondi()
	set_process(false)


func _process(delta: float) -> void:
	if _bersaglio == null or not is_instance_valid(_bersaglio) or not _bersaglio.is_visible_in_tree():
		_chiudi()
		return
	if not _bersaglio.get_global_rect().has_point(_bersaglio.get_global_mouse_position()):
		_chiudi()
		return
	_attesa += delta
	if _attesa < ATTESA_S:
		return
	var testo: String = testo_di(_bersaglio, _bersaglio.get_local_mouse_position())
	var titolo: String = titolo_di(_bersaglio)
	if testo.strip_edges() == "" and titolo.strip_edges() == "":
		_pannello.nascondi()
		return
	if _pannello.visible and testo == _pannello.testo_mostrato() and titolo == _pannello.titolo_mostrato():
		return
	_pannello.mostra(titolo, testo, get_global_mouse_position())
