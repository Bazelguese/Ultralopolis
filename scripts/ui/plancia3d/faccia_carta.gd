class_name FacciaCarta
extends Control
## Faccia di una carta disegnata in 2D (angoli arrotondati, cornice, illustrazione, numeri).
## Viene disegnata in un SubViewport e posata sulla tessera 3D come un'immagine.
## Solo presentazione.

var scheda: SchedaCarta
var stato: String = ""
var colore_stato: Color = StileVisivo.PERICOLO

var _sopra: Control
var _arte: TextureRect
var _iniziale: Label
var _numero_gemma: Label
var _nome: Label
var _testi_pastiglie: Array[Label] = []
var _riga: Label
var _malus: Label
var _fame: Label
var _stato: Label
var _dimensione_stato: int = 8

# Misure calcolate in base alla grandezza della carta.
var _bordo: float = 6.0
var _raggio: float = 14.0
var _area_arte: Rect2
var _area_nome: Rect2
var _area_basso: Rect2
var _pastiglie: Array[Rect2] = []
## Zona delle righe di simboli (consiglieri, azioni, eventi): vuota se la carta non ne ha.
var _area_simboli: Rect2


func imposta(p_scheda: SchedaCarta, misura: Vector2) -> void:
	scheda = p_scheda
	size = misura
	custom_minimum_size = misura
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_calcola_misure()
	_crea_arte()
	_sopra = Control.new()
	_sopra.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sopra.size = misura
	_sopra.draw.connect(_disegna_sopra)
	add_child(_sopra)
	_crea_scritte()
	queue_redraw()


func imposta_stato(testo: String, colore: Color) -> void:
	stato = testo
	colore_stato = colore
	_stato.text = testo
	_stato.visible = testo != ""
	_adatta_riquadro(_stato, StileVisivo.FONT_NUMERI, _dimensione_stato, _area_basso.size)
	var chiaro: bool = colore.get_luminance() > 0.55
	_stato.add_theme_color_override("font_color", StileVisivo.NOTTE if chiaro else Color.WHITE)
	_stato.add_theme_constant_override("outline_size", 0 if chiaro else 6)
	for testo_pastiglia: Label in _testi_pastiglie:
		testo_pastiglia.visible = testo == ""
	if _riga != null:
		_riga.visible = testo == ""
	_sopra.queue_redraw()


# --- Misure --------------------------------------------------------------------

func _calcola_misure() -> void:
	var lato: float = minf(size.x, size.y)
	_bordo = maxf(5.0, lato * 0.03)
	_raggio = lato * 0.08
	var margine: float = _bordo + lato * 0.03
	var con_simboli: bool = not scheda.simboli.is_empty()
	var altezza_arte: float = size.y * (0.5 if size.x < size.y else 0.46)
	# Con i simboli l'illustrazione si abbassa: lo spazio serve alle righe di simboli.
	if con_simboli:
		altezza_arte = size.y * 0.27
	# Sulla plancia la carta fa da base alla figurina: la pedana è più bassa, i numeri più grandi.
	elif scheda.come_base and size.y > size.x * 1.3:
		altezza_arte = size.y * 0.36
	_area_arte = Rect2(margine, margine, size.x - margine * 2.0, altezza_arte)
	var altezza_nome: float = size.y * (0.12 if con_simboli else 0.14)
	_area_nome = Rect2(_bordo, _area_arte.end.y + lato * 0.02, size.x - _bordo * 2.0, altezza_nome)
	# Le pastiglie restano ben dentro la cornice anche viste piccole e in prospettiva.
	var inizio_basso: float = _area_nome.end.y + lato * 0.04
	var rientro: float = margine + lato * 0.025
	_area_basso = Rect2(rientro, inizio_basso, size.x - rientro * 2.0, size.y - _bordo - lato * 0.075 - inizio_basso)
	_area_simboli = Rect2()
	if con_simboli:
		var inizio_simboli: float = _area_nome.end.y + lato * 0.03
		_area_simboli = Rect2(margine, inizio_simboli, size.x - margine * 2.0, size.y - _bordo - lato * 0.04 - inizio_simboli)
	_pastiglie.clear()
	if scheda.genere == SchedaCarta.Genere.TRUPPA and size.y > size.x * 1.3:
		# Tessera verticale 2:3: le due pastiglie una sopra l'altra, larghe quanto la carta.
		var alta: float = (_area_basso.size.y - lato * 0.04) * 0.5
		_pastiglie.append(Rect2(_area_basso.position, Vector2(_area_basso.size.x, alta)))
		_pastiglie.append(Rect2(_area_basso.position + Vector2(0.0, alta + lato * 0.04), Vector2(_area_basso.size.x, alta)))
	elif scheda.genere == SchedaCarta.Genere.TRUPPA:
		var meta: float = (_area_basso.size.x - lato * 0.04) * 0.5
		_pastiglie.append(Rect2(_area_basso.position, Vector2(meta, _area_basso.size.y)))
		_pastiglie.append(Rect2(_area_basso.position + Vector2(meta + lato * 0.04, 0.0), Vector2(meta, _area_basso.size.y)))
	elif scheda.genere == SchedaCarta.Genere.EDIFICIO and (scheda.mana != &"" or _effetto_principale() != ""):
		_pastiglie.append(_area_basso)


## L'effetto più importante da mostrare nella prima pastiglia: danno, poi scudo, cura, Corruzione, assedio.
func _effetto_principale() -> String:
	if scheda.danno > 0:
		return "spada"
	if scheda.scudo > 0:
		return "scudo"
	if scheda.cura > 0:
		return "cura"
	if scheda.corruzione > 0:
		return "corruzione"
	if scheda.assedio > 0:
		return "assedio"
	return ""


func _valore_effetto(effetto: String) -> int:
	match effetto:
		"spada": return scheda.danno
		"scudo": return scheda.scudo
		"cura": return scheda.cura
		"corruzione": return scheda.corruzione
		"assedio": return scheda.assedio
	return 0


func _colore_effetto(effetto: String) -> Color:
	match effetto:
		"scudo": return Color("2f6fd0")
		"cura": return Color("2f9e57")
		"corruzione": return StileVisivo.COLORE_CORRUZIONE
		"assedio": return Color("7a6a55")
	return StileVisivo.PERICOLO.darkened(0.1)


# --- Disegno -------------------------------------------------------------------

## Fondo della carta: cornice del colore dell'era, faccia scura, fascia del nome.
func _draw() -> void:
	var cornice: Color = scheda.colore_cornice()
	var esterno: StyleBoxFlat = StyleBoxFlat.new()
	esterno.bg_color = cornice
	esterno.set_corner_radius_all(int(_raggio))
	esterno.anti_aliasing = true
	draw_style_box(esterno, Rect2(Vector2.ZERO, size))
	var lucido: StyleBoxFlat = StyleBoxFlat.new()
	lucido.bg_color = Color(1.0, 1.0, 1.0, 0.0)
	lucido.draw_center = false
	lucido.border_color = cornice.lightened(0.45)
	lucido.set_border_width_all(2)
	lucido.set_corner_radius_all(int(_raggio))
	draw_style_box(lucido, Rect2(Vector2.ONE, size - Vector2(2.0, 2.0)))
	var faccia: StyleBoxFlat = StyleBoxFlat.new()
	faccia.bg_color = StileVisivo.FACCIA_CARTA
	faccia.set_corner_radius_all(int(maxf(_raggio - _bordo, 2.0)))
	faccia.anti_aliasing = true
	draw_style_box(faccia, Rect2(Vector2(_bordo, _bordo), size - Vector2(_bordo, _bordo) * 2.0))
	draw_rect(_area_nome, StileVisivo.FASCIA_NOME)
	draw_line(_area_nome.position, Vector2(_area_nome.end.x, _area_nome.position.y), cornice.darkened(0.2), 2.0)


## Tutto ciò che sta sopra l'illustrazione: gemma, livello, pastiglie, nastri, stato.
func _disegna_sopra() -> void:
	var lato: float = minf(size.x, size.y)
	_sopra.draw_rect(_area_arte, Color(0.0, 0.0, 0.0, 0.0), false, 2.0)
	_sopra.draw_rect(_area_arte.grow(1.0), scheda.colore_cornice().darkened(0.35), false, 2.0)

	# Pastiglie con icone.
	if scheda.genere == SchedaCarta.Genere.TRUPPA:
		var effetto: String = _effetto_principale()
		_pastiglia(_pastiglie[0], _colore_effetto(effetto), effetto if effetto != "" else "spada")
		_pastiglia(_pastiglie[1], Color("33415e"), "clessidra")
	elif _pastiglie.size() == 1:
		if scheda.mana != &"":
			_pastiglia(_pastiglie[0], StileVisivo.colore_mana_nome(scheda.mana).darkened(0.35), "gemma")
		else:
			var effetto_edificio: String = _effetto_principale()
			_pastiglia(_pastiglie[0], _colore_effetto(effetto_edificio), effetto_edificio)

	# Gemma del mana nell'angolo.
	if scheda.mana != &"":
		var centro: Vector2 = Vector2(_bordo + lato * 0.1, _bordo + lato * 0.1)
		var raggio: float = lato * 0.105
		var colore: Color = StileVisivo.colore_mana_nome(scheda.mana)
		_esagono(centro, raggio + 3.0, Color("0b1220"))
		_esagono(centro, raggio, colore)
		_esagono(centro + Vector2(0.0, -raggio * 0.2), raggio * 0.55, colore.lightened(0.35))

	# Livello: rombi in alto a destra.
	var passo: float = lato * 0.075
	for i: int in range(3):
		var centro_rombo: Vector2 = Vector2(_area_arte.end.x - passo * (2.6 - i) - 4.0, _area_arte.position.y + passo * 0.9)
		var pieno: bool = i < scheda.livello
		_rombo(centro_rombo, passo * 0.42 + 2.0, Color("0b1220"))
		_rombo(centro_rombo, passo * 0.42, StileVisivo.ORO_LUCE if pieno else Color("3a4560"))

	_disegna_simboli()

	if scheda.malus != "":
		_pillola(_malus, StileVisivo.PERICOLO)
	if scheda.affamata:
		_pillola(_fame, Color("e08a2e"))

	if stato != "":
		var nastro: StyleBoxFlat = StyleBoxFlat.new()
		nastro.bg_color = colore_stato
		nastro.set_corner_radius_all(int(lato * 0.04))
		_sopra.draw_style_box(nastro, _area_basso.grow(lato * 0.01))

	if not scheda.disponibile:
		var velo: StyleBoxFlat = StyleBoxFlat.new()
		velo.bg_color = Color(0.0, 0.0, 0.0, 0.5)
		velo.set_corner_radius_all(int(_raggio))
		_sopra.draw_style_box(velo, Rect2(Vector2.ZERO, size))


func _pastiglia(area: Rect2, colore: Color, icona: String) -> void:
	var fondo: StyleBoxFlat = StyleBoxFlat.new()
	fondo.bg_color = colore
	fondo.set_corner_radius_all(int(area.size.y * 0.3))
	fondo.border_color = colore.lightened(0.25)
	fondo.border_width_top = 2
	_sopra.draw_style_box(fondo, area)
	var lato_icona: float = area.size.y * 0.54
	var centro: Vector2 = Vector2(area.position.x + area.size.y * 0.5, area.get_center().y)
	match icona:
		"spada":
			var l: float = lato_icona * 0.5
			_sopra.draw_colored_polygon(PackedVector2Array([centro + Vector2(0, -l), centro + Vector2(l * 0.18, -l * 0.3), centro + Vector2(l * 0.18, l * 0.35), centro + Vector2(-l * 0.18, l * 0.35), centro + Vector2(-l * 0.18, -l * 0.3)]), Color.WHITE)
			_sopra.draw_rect(Rect2(centro + Vector2(-l * 0.55, l * 0.35), Vector2(l * 1.1, l * 0.16)), Color.WHITE)
			_sopra.draw_rect(Rect2(centro + Vector2(-l * 0.12, l * 0.5), Vector2(l * 0.24, l * 0.45)), Color.WHITE)
		"clessidra":
			var l: float = lato_icona * 0.45
			_sopra.draw_colored_polygon(PackedVector2Array([centro + Vector2(-l * 0.7, -l), centro + Vector2(l * 0.7, -l), centro]), Color.WHITE)
			_sopra.draw_colored_polygon(PackedVector2Array([centro, centro + Vector2(l * 0.7, l), centro + Vector2(-l * 0.7, l)]), Color.WHITE)
		"gemma":
			_esagono(centro, lato_icona * 0.42, StileVisivo.colore_mana_nome(scheda.mana).lightened(0.3))
		"scudo", "assedio":
			var l: float = lato_icona * 0.45
			_sopra.draw_colored_polygon(PackedVector2Array([centro + Vector2(-l * 0.8, -l), centro + Vector2(l * 0.8, -l), centro + Vector2(l * 0.8, 0.0), centro + Vector2(0.0, l), centro + Vector2(-l * 0.8, 0.0)]), Color.WHITE)
		"cura":
			var l: float = lato_icona * 0.45
			_sopra.draw_rect(Rect2(centro + Vector2(-l * 0.25, -l), Vector2(l * 0.5, l * 2.0)), Color.WHITE)
			_sopra.draw_rect(Rect2(centro + Vector2(-l, -l * 0.25), Vector2(l * 2.0, l * 0.5)), Color.WHITE)
		"corruzione":
			var l: float = lato_icona * 0.45
			_sopra.draw_colored_polygon(PackedVector2Array([centro + Vector2(0.0, -l), centro + Vector2(l * 0.7, l * 0.2), centro + Vector2(0.0, l), centro + Vector2(-l * 0.7, l * 0.2)]), Color.WHITE)


func _esagono(centro: Vector2, raggio: float, colore: Color) -> void:
	var punti: PackedVector2Array = PackedVector2Array()
	for i: int in range(6):
		var angolo: float = deg_to_rad(60.0 * i - 90.0)
		punti.append(centro + Vector2(cos(angolo), sin(angolo)) * raggio)
	_sopra.draw_colored_polygon(punti, colore)


func _rombo(centro: Vector2, raggio: float, colore: Color) -> void:
	_sopra.draw_colored_polygon(PackedVector2Array([centro + Vector2(0, -raggio), centro + Vector2(raggio, 0), centro + Vector2(0, raggio), centro + Vector2(-raggio, 0)]), colore)


func _pillola(etichetta: Label, colore: Color) -> void:
	var fondo: StyleBoxFlat = StyleBoxFlat.new()
	fondo.bg_color = colore
	fondo.set_corner_radius_all(int(etichetta.size.y * 0.5))
	_sopra.draw_style_box(fondo, Rect2(etichetta.position, etichetta.size).grow_individual(8.0, 0.0, 8.0, 0.0))


# --- Simboli -------------------------------------------------------------------
# Righe di simboli come nei giochi da tavolo (RigaSimboli): numeri e simboli, centrati,
# una riga per ogni cosa che la carta può fare. Le righe troppo lunghe si rimpiccioliscono.

## Cambia le righe di simboli senza ricostruire la carta (es. un'opzione che diventa pagabile).
func imposta_simboli(righe: Array[RigaSimboli]) -> void:
	scheda.simboli = righe
	_sopra.queue_redraw()


func _disegna_simboli() -> void:
	var righe: Array[RigaSimboli] = scheda.simboli
	if righe.is_empty() or _area_simboli.size.y <= 0.0:
		return
	var stacco: float = minf(size.x, size.y) * 0.018
	# Le righe corte si affiancano sulla stessa linea, ognuna nella sua pastiglia, così non si
	# spreca spazio (richiesta di Davide). Meno linee = linee più alte = simboli più grandi:
	# si riprova finché il numero di linee non cambia più.
	var linee: Array[Array] = []
	for riga: RigaSimboli in righe:
		linee.append([riga])
	for tentativo: int in range(4):
		var nuove: Array[Array] = _impacchetta(righe, _altezza_linea(linee.size(), stacco), stacco)
		var stabile: bool = nuove.size() == linee.size()
		linee = nuove
		if stabile:
			break
	var altezza: float = _altezza_linea(linee.size(), stacco)
	var totale: float = altezza * linee.size() + stacco * (linee.size() - 1)
	var y: float = _area_simboli.position.y + (_area_simboli.size.y - totale) * 0.5
	for linea: Array in linee:
		_disegna_linea(linea, y, altezza, stacco)
		y += altezza + stacco


## Altezza di ogni linea se le linee sono "quante".
func _altezza_linea(quante: int, stacco: float) -> float:
	var n: int = maxi(quante, 1)
	return minf((_area_simboli.size.y - stacco * (n - 1)) / n, _area_simboli.size.y * 0.36)


## Larghezza che serve a una riga, con il margine della sua pastiglia, su una linea alta "altezza".
func _larghezza_pastiglia(riga: RigaSimboli, altezza: float) -> float:
	return DisegnoSimboli.larghezza_pastiglia(riga, altezza)


## Mette le righe, in ordine, sulle linee: una riga va accanto alla precedente se ci sta.
func _impacchetta(righe: Array[RigaSimboli], altezza: float, stacco: float) -> Array[Array]:
	var linee: Array[Array] = []
	var occupata: float = 0.0
	for riga: RigaSimboli in righe:
		var serve: float = _larghezza_pastiglia(riga, altezza)
		# Una riga secondaria (il Potenzia) sta sempre su una linea sua, senza vicine.
		var da_sola: bool = riga.rilievo == RigaSimboli.Rilievo.SECONDARIA
		var precedente_sola: bool = not linee.is_empty() and (linee[linee.size() - 1][0] as RigaSimboli).rilievo == RigaSimboli.Rilievo.SECONDARIA
		if linee.is_empty() or da_sola or precedente_sola or occupata + stacco + serve > _area_simboli.size.x:
			linee.append([riga])
			occupata = serve
		else:
			linee[linee.size() - 1].append(riga)
			occupata += stacco + serve
	return linee


## Una linea: le pastiglie si dividono la larghezza in proporzione a quanto serve a ciascuna.
func _disegna_linea(linea: Array, y: float, altezza: float, stacco: float) -> void:
	var richieste: Array[float] = []
	var somma: float = 0.0
	for elemento: Variant in linea:
		var serve: float = _larghezza_pastiglia(elemento as RigaSimboli, altezza)
		richieste.append(serve)
		somma += serve
	var avanzo: float = _area_simboli.size.x - somma - stacco * (linea.size() - 1)
	var x: float = _area_simboli.position.x
	for i: int in range(linea.size()):
		var riga: RigaSimboli = linea[i] as RigaSimboli
		var larghezza: float = _area_simboli.size.x
		if linea.size() > 1:
			larghezza = richieste[i] + avanzo * richieste[i] / maxf(somma, 1.0)
		DisegnoSimboli.pastiglia(_sopra, riga, Rect2(x, y, larghezza, altezza), scheda.colore_cornice())
		x += larghezza + stacco


# --- Elementi ------------------------------------------------------------------

func _crea_arte() -> void:
	_arte = TextureRect.new()
	_arte.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_arte.position = _area_arte.position
	_arte.size = _area_arte.size
	_arte.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_arte.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	add_child(_arte)
	if scheda.come_base and scheda.illustrazione != null:
		_arte.texture = _pedana()
		return
	if scheda.illustrazione != null:
		_arte.texture = scheda.illustrazione
		return
	# Segnaposto: sfumatura del colore del mana con l'iniziale.
	var colore: Color = StileVisivo.colore_mana_nome(scheda.mana) if scheda.mana != &"" else StileVisivo.PIETRA_CHIARA
	if scheda.genere == SchedaCarta.Genere.AZIONE:
		colore = StileVisivo.CORNICE_AZIONE.darkened(0.2)
	elif scheda.genere == SchedaCarta.Genere.VIA:
		colore = StileVisivo.ORO.darkened(0.15)
	elif scheda.genere == SchedaCarta.Genere.CONSIGLIERE:
		colore = scheda.colore_cornice().darkened(0.25)
	elif scheda.genere in [SchedaCarta.Genere.INCONTRO, SchedaCarta.Genere.FANTASMA]:
		colore = StileVisivo.CORNICE_MINACCIA.darkened(0.25)
	var sfumatura: Gradient = Gradient.new()
	sfumatura.set_color(0, colore.lightened(0.05))
	sfumatura.set_color(1, colore.darkened(0.7))
	var trama: GradientTexture2D = GradientTexture2D.new()
	trama.gradient = sfumatura
	trama.fill = GradientTexture2D.FILL_RADIAL
	trama.fill_from = Vector2(0.5, 0.4)
	trama.fill_to = Vector2(1.05, 1.05)
	trama.width = 128
	trama.height = 128
	_arte.texture = trama
	var parole: PackedStringArray = scheda.titolo.split(" ", false)
	var parola: String = parole[parole.size() - 1] if scheda.genere == SchedaCarta.Genere.VIA and not parole.is_empty() else scheda.titolo
	_iniziale = _etichetta(parola.substr(0, 1).to_upper(), StileVisivo.FONT_TITOLI, int(_area_arte.size.y * 0.72), Color(1.0, 1.0, 1.0, 0.9), 12)
	_iniziale.position = _area_arte.position
	_iniziale.size = _area_arte.size
	_iniziale.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_iniziale.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(_iniziale)


## Teatro di carta: la pedana su cui sta la figurina. Una superficie uniforme, senza l'ombra
## ovale che c'era prima (toglieva risalto alla figurina; Davide, 9 novembre 2026).
const COLORE_PEDANA: Color = Color("1e1711")


func _pedana() -> Texture2D:
	var img: Image = Image.create(4, 4, false, Image.FORMAT_RGB8)
	img.fill(COLORE_PEDANA)
	return ImageTexture.create_from_image(img)


## Fondo della zona dell'illustrazione, da 0 (alto della carta) a 1 (basso).
func fondo_arte() -> float:
	return _area_arte.end.y / maxf(size.y, 1.0)


## Centro verticale della zona dell'illustrazione, da 0 (alto della carta) a 1 (basso).
func centro_arte() -> float:
	return (_area_arte.position.y + _area_arte.size.y * 0.5) / maxf(size.y, 1.0)


func _crea_scritte() -> void:
	var lato: float = minf(size.x, size.y)
	if scheda.mana != &"":
		var centro: Vector2 = Vector2(_bordo + lato * 0.1, _bordo + lato * 0.1)
		_numero_gemma = _etichetta(str(scheda.mana_numero), StileVisivo.FONT_TITOLI, int(lato * 0.14), Color.WHITE, 8)
		_numero_gemma.position = centro - Vector2(lato * 0.1, lato * 0.1)
		_numero_gemma.size = Vector2(lato * 0.2, lato * 0.2)
		_numero_gemma.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_numero_gemma.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		add_child(_numero_gemma)

	_nome = _etichetta(scheda.titolo.to_upper(), StileVisivo.FONT_TITOLI, int(_area_nome.size.y * 0.62), StileVisivo.TESTO, 6)
	_nome.position = _area_nome.position
	_nome.size = _area_nome.size
	_nome.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_nome.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_nome.clip_text = true
	_nome.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_adatta(_nome, StileVisivo.FONT_TITOLI, int(_area_nome.size.y * 0.62), _area_nome.size.x - lato * 0.06)
	add_child(_nome)

	var testi: Array[String] = []
	var ritmo: String = SchedaCarta.secondi(scheda.ritmo_ms).replace(" ", "")
	if scheda.genere == SchedaCarta.Genere.TRUPPA:
		testi = [str(_valore_effetto(_effetto_principale())), ritmo]
	elif _pastiglie.size() == 1:
		var quanto: int = scheda.mana_numero if scheda.mana != &"" else _valore_effetto(_effetto_principale())
		testi = ["+%d · %s" % [quanto, ritmo]]
	for i: int in range(testi.size()):
		var area: Rect2 = _pastiglie[i]
		var testo: Label = _etichetta(testi[i], StileVisivo.FONT_TITOLI, int(area.size.y * 0.62), Color.WHITE, 6)
		testo.position = area.position + Vector2(area.size.y * 0.85, 0.0)
		testo.size = Vector2(area.size.x - area.size.y * 0.95, area.size.y)
		_adatta(testo, StileVisivo.FONT_TITOLI, int(area.size.y * 0.62), testo.size.x - 6.0)
		testo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		testo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		add_child(testo)
		_testi_pastiglie.append(testo)
	if testi.is_empty() and scheda.simboli.is_empty():
		_riga = _etichetta(scheda.riga, StileVisivo.FONT_NUMERI, int(_area_basso.size.y * 0.42), StileVisivo.ORO_LUCE, 6)
		_riga.position = _area_basso.position
		_riga.size = _area_basso.size
		_riga.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_riga.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_riga.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_adatta_riquadro(_riga, StileVisivo.FONT_NUMERI, int(_area_basso.size.y * 0.42), _area_basso.size)
		add_child(_riga)

	_malus = _etichetta(scheda.malus.to_upper(), StileVisivo.FONT_TITOLI, int(lato * 0.075), Color.WHITE, 0)
	_adatta(_malus, StileVisivo.FONT_TITOLI, int(lato * 0.075), size.x - 24.0 - _bordo * 2.0)
	_malus.position = Vector2(size.x * 0.5, _area_arte.end.y - lato * 0.11)
	_malus.reset_size()
	_malus.position.x -= _malus.size.x * 0.5
	_malus.visible = scheda.malus != ""
	add_child(_malus)

	_fame = _etichetta("AFFAMATA", StileVisivo.FONT_TITOLI, int(lato * 0.075), Color.WHITE, 0)
	_fame.position = Vector2(size.x * 0.5, _area_arte.position.y + lato * 0.03)
	_fame.reset_size()
	_fame.position.x -= _fame.size.x * 0.5
	_fame.visible = scheda.affamata
	add_child(_fame)

	_dimensione_stato = int(_area_basso.size.y * 0.36)
	_stato = _etichetta("", StileVisivo.FONT_NUMERI, _dimensione_stato, Color.WHITE, 6)
	_stato.position = _area_basso.position
	_stato.size = _area_basso.size
	_stato.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_stato.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_stato.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_stato.visible = false
	add_child(_stato)


func _etichetta(testo: String, font: Font, dimensione: int, colore: Color, contorno: int) -> Label:
	var risultato: Label = StileVisivo.etichetta(testo, font, maxi(dimensione, 8), colore)
	risultato.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if contorno > 0:
		risultato.add_theme_constant_override("outline_size", contorno)
		risultato.add_theme_color_override("font_outline_color", StileVisivo.OMBRA_TESTO)
	return risultato


## Riduce il carattere finché il testo sta su una riga larga al massimo "larghezza".
func _adatta(etichetta: Label, font: Font, dimensione: int, larghezza: float) -> void:
	var misura: int = maxi(dimensione, 8)
	while misura > 8 and font.get_string_size(etichetta.text, HORIZONTAL_ALIGNMENT_LEFT, -1, misura).x > larghezza:
		misura -= 1
	etichetta.add_theme_font_size_override("font_size", misura)


## Come _adatta, per i testi che vanno a capo: devono stare dentro il riquadro "area".
func _adatta_riquadro(etichetta: Label, font: Font, dimensione: int, area: Vector2) -> void:
	var misura: int = maxi(dimensione, 8)
	var larghezza: float = area.x - 10.0
	while misura > 8 and font.get_multiline_string_size(etichetta.text, HORIZONTAL_ALIGNMENT_CENTER, larghezza, misura).y > area.y * 0.92:
		misura -= 1
	etichetta.add_theme_font_size_override("font_size", misura)


## Le offerte restano sul tavolo: quando cambia solo se si possono pagare, si aggiorna il velo.
func imposta_disponibile(disponibile: bool) -> void:
	scheda.disponibile = disponibile
	_sopra.queue_redraw()
