class_name CalendarioSfondo
extends Control
## Il calendario del teatro di carta (richiesta di Davide, 8 novembre 2026): un velo trasparente
## sopra la scena e sotto l'interfaccia, che non occupa spazio. La stagione in filigrana e la fila
## dei mesi che scorre a ogni nuovo mese, con un sigillo di ceralacca che timbra il mese in corso.
## Solo scenografia: legge il calendario della partita, non decide niente.

const NOMI_MESI: PackedStringArray = ["Gennaio", "Febbraio", "Marzo", "Aprile", "Maggio", "Giugno",
		"Luglio", "Agosto", "Settembre", "Ottobre", "Novembre", "Dicembre"]
const COLORE_STAGIONE: Array[Color] = [Color("9cc0e4"), Color("8fcf73"), Color("f0b04a"), Color("dc7444")]
const INCHIOSTRO: Color = Color("0d0a08")
const CREMA: Color = Color("f2ead8")
## Distanza fra un mese e l'altro, in pixel (schermo di riferimento 1920 × 1080).
const PASSO: float = 250.0
## Altezza della fila sullo schermo (frazione dell'altezza).
const ALTEZZA_FILA: float = 0.215
## Quanto si vede la fila: è uno sfondo.
const TRASPARENZA: float = 0.32
const MESI_PER_LATO: int = 4

var _filigrana: Label
var _fila: Control
var _linea: Line2D
var _mesi: Array[Control] = []
var _anno: Label
var _sigillo: Control
var _lettere: Label
var _mese: int = 1
var _scorrimento: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_crea_filigrana()
	_crea_fila()


## La stagione scritta enorme, inclinata, appena visibile.
func _crea_filigrana() -> void:
	_filigrana = _etichetta("", 330, CREMA, 0)
	_filigrana.modulate.a = 0.05
	_filigrana.rotation = deg_to_rad(-7.0)
	_filigrana.position = Vector2(-60.0, 10.0)
	add_child(_filigrana)


func _crea_fila() -> void:
	_fila = Control.new()
	_fila.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fila.modulate.a = TRASPARENZA
	add_child(_fila)
	# Linea del tempo a inchiostro, con le tacche dei mesi.
	_linea = Line2D.new()
	_linea.width = 5.0
	_linea.default_color = Color(CREMA, 0.55)
	for i: int in range(-30, 31):
		_linea.add_point(Vector2(i * PASSO * 0.5, 74.0 + (8.0 if i % 2 == 0 else 0.0)))
	_fila.add_child(_linea)
	for m: int in range(12):
		var mese: Control = Control.new()
		mese.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var numero: Label = _etichetta(str(m + 1), 150, CREMA, 22)
		numero.position = Vector2(-numero.get_minimum_size().x * 0.5, -120.0)
		mese.add_child(numero)
		var nome: Label = _etichetta(NOMI_MESI[m].to_upper(), 34, COLORE_STAGIONE[m / 3], 10)
		nome.position = Vector2(-nome.get_minimum_size().x * 0.5, 30.0)
		mese.add_child(nome)
		mese.set_meta("numero", numero)
		mese.set_meta("nome", nome)
		_fila.add_child(mese)
		_mesi.append(mese)
	_anno = _etichetta("", 40, CREMA, 12)
	_fila.add_child(_anno)
	_sigillo = _crea_sigillo()
	_fila.add_child(_sigillo)
	_posiziona_fila()
	get_viewport().size_changed.connect(_posiziona_fila)


## Dimensione dello schermo su cui si dispone lo sfondo.
func _schermo() -> Vector2:
	return get_viewport_rect().size


func _base_fila() -> Vector2:
	return Vector2(_schermo().x * 0.5, _schermo().y * ALTEZZA_FILA)


func _posiziona_fila() -> void:
	if _fila == null:
		return
	_fila.position = _base_fila()
	_anno.position = Vector2(-_schermo().x * 0.5 + 360.0, -150.0)


func _etichetta(testo: String, dimensione: int, colore: Color, contorno: int) -> Label:
	var etichetta: Label = Label.new()
	etichetta.text = testo
	etichetta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var impostazioni: LabelSettings = LabelSettings.new()
	impostazioni.font = StileVisivo.FONT_TITOLI
	impostazioni.font_size = dimensione
	impostazioni.font_color = colore
	impostazioni.outline_size = contorno
	impostazioni.outline_color = INCHIOSTRO
	impostazioni.shadow_size = 0 if contorno == 0 else 4
	impostazioni.shadow_color = Color(0.0, 0.0, 0.0, 0.45)
	impostazioni.shadow_offset = Vector2(6.0, 6.0)
	etichetta.label_settings = impostazioni
	return etichetta


## Il sigillo di ceralacca con le iniziali della nazione.
func _crea_sigillo() -> Control:
	var nodo: Control = Control.new()
	nodo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var disco: TextureRect = TextureRect.new()
	disco.texture = _disegna_ceralacca()
	disco.mouse_filter = Control.MOUSE_FILTER_IGNORE
	disco.position = Vector2(-48.0, -48.0)
	disco.size = Vector2(96.0, 96.0)
	nodo.add_child(disco)
	_lettere = _etichetta("", 34, Color("ffd9c8"), 6)
	_lettere.label_settings.outline_color = Color("5a0d0a")
	_lettere.label_settings.shadow_size = 0
	_lettere.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lettere.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_lettere.position = Vector2(-48.0, -48.0)
	_lettere.size = Vector2(96.0, 96.0)
	nodo.add_child(_lettere)
	nodo.pivot_offset = Vector2.ZERO
	nodo.scale = Vector2.ZERO
	return nodo


func _disegna_ceralacca() -> ImageTexture:
	var lato: int = 128
	var img: Image = Image.create(lato, lato, false, Image.FORMAT_RGBA8)
	var centro: Vector2 = Vector2(lato, lato) * 0.5
	for y: int in range(lato):
		for x: int in range(lato):
			var p: Vector2 = Vector2(x, y) - centro
			var raggio: float = 54.0 + 5.0 * sin(p.angle() * 7.0) + 3.0 * sin(p.angle() * 13.0)
			var d: float = p.length()
			if d < raggio:
				var c: Color = Color("a3201a") if d < 40.0 else Color("8a1712")
				if d > 36.0 and d < 40.0:
					c = Color("6a100c")
				img.set_pixel(x, y, c)
	img.generate_mipmaps()
	return ImageTexture.create_from_image(img)


# --- Il calendario della partita ------------------------------------------------------

func imposta_iniziali(testo: String) -> void:
	_lettere.text = testo


## Porta la fila al mese indicato: scivola con uno scatto, il mese nuovo esce di colpo e il
## sigillo lo timbra.
func vai_al_mese(anno: int, mese: int, nome_stagione: String, subito: bool) -> void:
	_mese = mese
	_anno.text = "ANNO %d · %s" % [anno, nome_stagione.to_upper()]
	_filigrana.text = nome_stagione.to_upper()
	var durata: float = 0.0 if subito else 0.75
	if _scorrimento != null and _scorrimento.is_valid():
		_scorrimento.kill()
	if durata > 0.0:
		_scorrimento = create_tween()
		_scorrimento.set_parallel(true)
		# Allungamento durante la corsa, come un colpo di pennello.
		_fila.scale = Vector2(1.0, 1.0)
		_scorrimento.tween_property(_fila, "scale", Vector2(1.06, 0.97), durata * 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_scorrimento.chain().tween_property(_fila, "scale", Vector2.ONE, durata * 0.6).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	for m: int in range(12):
		var k: int = (m + 1) - mese
		if k > 6:
			k -= 12
		elif k < -5:
			k += 12
		var nodo: Control = _mesi[m]
		var visibile: bool = absi(k) <= MESI_PER_LATO
		var scala: float = 1.25 if k == 0 else maxf(0.35, 0.72 - 0.1 * float(absi(k) - 1))
		# Altezze sfalsate e piccole rotazioni: la fila non è una riga da registro.
		var su: float = -18.0 if k == 0 else (14.0 if k % 2 == 0 else -6.0) + float(absi(k)) * 4.0
		var posizione: Vector2 = Vector2(float(k) * PASSO - signf(float(k)) * 40.0, su)
		var giro: float = deg_to_rad(-6.0 if k == 0 else (4.0 if k % 2 == 0 else -3.0))
		var opacita: float = 0.0 if not visibile else (1.0 if k == 0 else maxf(0.25, 0.75 - 0.15 * float(absi(k) - 1)))
		var numero: Label = nodo.get_meta("numero")
		numero.label_settings.font_color = COLORE_STAGIONE[m / 3].lerp(CREMA, 0.25) if k == 0 else CREMA
		if durata <= 0.0:
			nodo.position = posizione
			nodo.scale = Vector2.ONE * scala
			nodo.rotation = giro
			nodo.modulate.a = opacita
		else:
			_scorrimento.tween_property(nodo, "position", posizione, durata).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
			_scorrimento.tween_property(nodo, "scale", Vector2.ONE * scala, durata).set_trans(Tween.TRANS_BACK if k == 0 else Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			_scorrimento.tween_property(nodo, "rotation", giro, durata)
			_scorrimento.tween_property(nodo, "modulate:a", opacita, durata)
	# La linea del tempo scorre con la fila.
	var spostamento: float = fposmod(-float(mese) * PASSO, PASSO)
	if durata <= 0.0:
		_linea.position.x = spostamento
	else:
		_linea.position.x = spostamento + PASSO
		_scorrimento.tween_property(_linea, "position:x", spostamento, durata).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	_timbra(durata)


func _timbra(ritardo: float) -> void:
	var arrivo: Vector2 = Vector2(92.0, -112.0)
	_sigillo.rotation = deg_to_rad(-14.0)
	if ritardo <= 0.0:
		_sigillo.position = arrivo
		_sigillo.scale = Vector2.ONE
		return
	var t: Tween = create_tween()
	t.tween_property(_sigillo, "scale", Vector2.ZERO, 0.12)
	t.tween_interval(maxf(0.0, ritardo - 0.12))
	t.tween_callback(func() -> void: _sigillo.position = arrivo + Vector2(30.0, -60.0))
	t.tween_property(_sigillo, "scale", Vector2.ONE * 2.2, 0.01)
	t.tween_property(_sigillo, "position", arrivo, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(_sigillo, "scale", Vector2.ONE * 0.9, 0.14)
	t.tween_callback(_scuoti)
	t.tween_property(_sigillo, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Il colpo del sigillo fa tremare un attimo la fila.
func _scuoti() -> void:
	var base: Vector2 = _base_fila()
	var t: Tween = create_tween()
	for i: int in range(4):
		t.tween_property(_fila, "position", base + Vector2(randf_range(-7.0, 7.0), randf_range(-5.0, 5.0)), 0.03)
	t.tween_property(_fila, "position", base, 0.05)


## La fila si nasconde durante gli scontri (resta il fondo).
func mostra_fila(visibile: bool) -> void:
	var t: Tween = create_tween()
	t.tween_property(_fila, "modulate:a", TRASPARENZA if visibile else 0.0, 0.4)
	t.parallel().tween_property(_filigrana, "modulate:a", 0.05 if visibile else 0.0, 0.4)
