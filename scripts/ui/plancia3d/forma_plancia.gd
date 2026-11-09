class_name FormaPlancia
extends Node3D
## La plancia di un lato, sagomata attorno al cuore della nazione (Davide, 9 novembre 2026).
## Non è più un rettangolo: segue le due file e cresce con loro. La forma la indica il popolo
## (IdentityDef.board_shape) o l'incontro del mondo (EncounterDef.board_shape):
##   «ali»   due fasce a punta, una per fila, unite dal cuore;
##   «mura»  un blocco a gradini con merli sui lati lunghi e una torre a ogni angolo;
##   «arco»  le file curve attorno a un centro lontano, come le gradinate di un anfiteatro;
##   vuoto   una lastra semplice dagli angoli tondi (incontri senza forma propria).
## Strati dal basso: legno, profilo d'ottone, fondo, filetto d'ottone, fondo.
## Solo presentazione: non contiene regole di gioco.

const ALI: StringName = &"ali"
const MURA: StringName = &"mura"
const ARCO: StringName = &"arco"
## Mezza profondità delle fasce delle due file.
const FASCIA_TRUPPE: float = 1.38
const FASCIA_EDIFICI: float = 1.0
## Raggio dell'arco della fila delle truppe (forma «arco»).
const RAGGIO_ARCO: float = 26.0
const LEGNO: Color = Color("5a3824")
const OTTONE: Color = Color("c79a4a")
const FONDO_GIOCATORE: Color = StileVisivo.CARTA_PLANCIA
const FONDO_NEMICO: Color = StileVisivo.CARTA_PLANCIA_NEMICO
## Quota della faccia della plancia: sopra il calendario stampato sul tavolo, sotto le carte.
const CIMA: float = 0.024
## [rientro dal bordo, quota della faccia sotto CIMA, spessore]
const STRATI: Array = [[0.0, -0.012, 0.45], [0.11, -0.007, 0.1], [0.22, -0.004, 0.1], [0.36, -0.002, 0.1], [0.41, 0.0, 0.1]]

static var _venatura: NoiseTexture2D

var forma: StringName = &""
## 1 per il giocatore (file verso +z), -1 per il nemico (specchiato).
var segno: float = 1.0
var z_truppe: float = 1.75
var z_edifici: float = 4.85
var mezzo_cuore: float = 0.95
var estensioni: Vector4 = Vector4.ZERO
var _strati: Array[CSGPolygon3D] = []


func costruisci(forma_scelta: StringName, verso: float, fila_truppe: float, fila_edifici: float, cuore: float, nemico: bool) -> void:
	forma = forma_scelta
	segno = verso
	z_truppe = fila_truppe
	z_edifici = fila_edifici
	mezzo_cuore = cuore
	var fondo: Color = FONDO_NEMICO if nemico else FONDO_GIOCATORE
	var materiali: Array[Material] = [_materiale_legno(), StileVisivo.materiale(OTTONE, 0.3, 0.85),
		ScenaTeatro.materiale_carta(fondo, 2.0), StileVisivo.materiale(OTTONE.darkened(0.2), 0.35, 0.8),
		ScenaTeatro.materiale_carta(fondo, 2.0)]
	for k: int in range(STRATI.size()):
		var strato: CSGPolygon3D = CSGPolygon3D.new()
		strato.depth = float(STRATI[k][2])
		strato.material = materiali[k]
		strato.rotation.x = -PI * 0.5
		strato.position.y = CIMA + float(STRATI[k][1])
		add_child(strato)
		_strati.append(strato)


## Cambia forma (per esempio quando arriva un nemico diverso) e ridisegna.
func cambia_forma(nuova: StringName) -> void:
	if nuova == forma:
		return
	forma = nuova
	if estensioni != Vector4.ZERO:
		imposta(estensioni)


static func _materiale_legno() -> StandardMaterial3D:
	if _venatura == null:
		_venatura = NoiseTexture2D.new()
		var rumore: FastNoiseLite = FastNoiseLite.new()
		rumore.frequency = 0.012
		rumore.fractal_octaves = 5
		rumore.domain_warp_enabled = true
		rumore.domain_warp_amplitude = 30.0
		_venatura.noise = rumore
		_venatura.seamless = true
		_venatura.width = 512
		_venatura.height = 64
		var rampa: Gradient = Gradient.new()
		rampa.set_color(0, Color(0.72, 0.68, 0.64))
		rampa.set_color(1, Color(1.0, 1.0, 1.0))
		_venatura.color_ramp = rampa
	var materiale: StandardMaterial3D = StileVisivo.materiale(LEGNO, 0.55)
	materiale.albedo_texture = _venatura
	materiale.uv1_triplanar = true
	materiale.uv1_scale = Vector3(0.35, 0.35, 0.35)
	return materiale


## Dove sta il punto s di una fila (s = distanza dal centro lungo la fila, negativa a sinistra):
## [posizione, rotazione attorno all'asse verticale]. Nell'«arco» le carte seguono la curva.
func punto(truppa: bool, s: float) -> Array:
	var z: float = z_truppe if truppa else z_edifici
	if forma != ARCO:
		return [Vector3(s, 0.0, z * segno), 0.0]
	var r: float = _raggio(truppa)
	var angolo: float = s / r
	var centro: float = z_truppe - RAGGIO_ARCO
	return [Vector3(sin(angolo) * r, 0.0, (centro + cos(angolo) * r) * segno), angolo * segno]


func _raggio(truppa: bool) -> float:
	return RAGGIO_ARCO if truppa else RAGGIO_ARCO + (z_edifici - z_truppe)


## Di quanto le estremità dell'«arco» rientrano verso il centro del tavolo (negli scontri le due
## plance si allontanano di tanto, per non toccarsi).
func rientro() -> float:
	if forma != ARCO:
		return 0.0
	var s: float = maxf(estensioni.x, estensioni.y)
	return RAGGIO_ARCO * (1.0 - cos(minf(s / RAGGIO_ARCO, PI * 0.5)))


## Estensioni delle file lungo la fila: sinistra e destra delle truppe, sinistra e destra degli
## edifici (margine compreso). Ricostruisce tutti gli strati.
func imposta(nuove: Vector4) -> void:
	estensioni = nuove
	var contorno: PackedVector2Array = _contorno(nuove)
	# Angoli appena arrotondati: si stringe e si riallarga con giunture tonde (le mura poco,
	# per non cancellare i merli).
	var tondo: float = 0.06 if forma == MURA else 0.25
	contorno = _piu_grande(Geometry2D.offset_polygon(contorno, -tondo, Geometry2D.JOIN_MITER))
	contorno = _piu_grande(Geometry2D.offset_polygon(contorno, tondo, Geometry2D.JOIN_ROUND))
	for k: int in range(_strati.size()):
		var rientro_strato: float = float(STRATI[k][0])
		var p: PackedVector2Array = contorno if rientro_strato <= 0.0 else _piu_grande(Geometry2D.offset_polygon(contorno, -rientro_strato, Geometry2D.JOIN_MITER))
		# Il poligono è nel piano (x, -z), specchiato per il nemico; l'ordine dei punti resta
		# antiorario.
		var girato: PackedVector2Array = PackedVector2Array()
		for v: Vector2 in p:
			girato.append(Vector2(v.x, -v.y * segno))
		if segno < 0.0:
			girato.reverse()
		_strati[k].polygon = girato


func _contorno(e: Vector4) -> PackedVector2Array:
	match forma:
		ALI:
			return _contorno_ali(e)
		MURA:
			return _contorno_mura(e)
		ARCO:
			return _contorno_arco(e)
	return _contorno_semplice(e)


func _cuore(sporgenza: float, smusso: float) -> PackedVector2Array:
	return _ottagono((mezzo_cuore + 0.45) * 2.0, z_truppe - FASCIA_TRUPPE - sporgenza, z_edifici + FASCIA_EDIFICI + sporgenza, smusso)


## Lastra semplice, larga quanto la fila più lunga.
func _contorno_semplice(e: Vector4) -> PackedVector2Array:
	var mezza: float = maxf(maxf(e.x, e.y), maxf(e.z, e.w))
	return _rettangolo(-mezza, mezza, z_truppe - FASCIA_TRUPPE - 0.2, z_edifici + FASCIA_EDIFICI + 0.2)


## Ali: una fascia per fila con le estremità a punta; il cuore le unisce ed esce davanti e dietro.
func _contorno_ali(e: Vector4) -> PackedVector2Array:
	var punta: float = 0.75
	var t: float = z_truppe
	var d: float = z_edifici
	var truppe: PackedVector2Array = PackedVector2Array([Vector2(-e.x, t - FASCIA_TRUPPE), Vector2(e.y, t - FASCIA_TRUPPE), Vector2(e.y + punta, t),
		Vector2(e.y, t + FASCIA_TRUPPE), Vector2(-e.x, t + FASCIA_TRUPPE), Vector2(-e.x - punta, t)])
	var edifici: PackedVector2Array = PackedVector2Array([Vector2(-e.z, d - FASCIA_EDIFICI), Vector2(e.w, d - FASCIA_EDIFICI), Vector2(e.w + punta, d),
		Vector2(e.w, d + FASCIA_EDIFICI), Vector2(-e.z, d + FASCIA_EDIFICI), Vector2(-e.z - punta, d)])
	# Le due fasce non si toccano: si uniscono una alla volta al cuore.
	return _unisci(_unisci(_cuore(0.45, 0.7), truppe), edifici)


## Mura: un blocco a gradini (le file hanno lunghezze diverse), merli sui lati lunghi esterni,
## una torre tonda a ogni angolo e il cuore come porta che sporge davanti e dietro.
func _contorno_mura(e: Vector4) -> PackedVector2Array:
	var dietro: float = z_truppe - FASCIA_TRUPPE
	var davanti: float = z_edifici + FASCIA_EDIFICI
	var mezzo: float = (z_truppe + FASCIA_TRUPPE + z_edifici - FASCIA_EDIFICI) * 0.5
	var truppe: PackedVector2Array = PackedVector2Array()
	truppe.append(Vector2(-e.x, mezzo + 0.1))
	truppe.append_array(_merli(-e.x, e.y, dietro, -1.0))
	truppe.append(Vector2(e.y, mezzo + 0.1))
	var edifici: PackedVector2Array = PackedVector2Array()
	edifici.append(Vector2(e.w, mezzo - 0.1))
	var merli: PackedVector2Array = _merli(-e.z, e.w, davanti, 1.0)
	merli.reverse()
	edifici.append_array(merli)
	edifici.append(Vector2(-e.z, mezzo - 0.1))
	var contorno: PackedVector2Array = _unisci(truppe, edifici)
	for angolo: Vector2 in [Vector2(-e.x, dietro), Vector2(e.y, dietro), Vector2(-e.z, davanti), Vector2(e.w, davanti)]:
		contorno = _unisci(contorno, _cerchio(angolo, 0.62))
	return _unisci(contorno, _cuore(0.5, 0.45))


## Un lato con i merli fra x0 e x1, a quota z; i merli sporgono verso "verso".
static func _merli(x0: float, x1: float, z: float, verso: float) -> PackedVector2Array:
	var p: PackedVector2Array = PackedVector2Array()
	var dente: float = 0.42
	p.append(Vector2(x0, z))
	var x: float = x0 + 0.5
	while x + dente < x1 - 0.5:
		p.append(Vector2(x, z))
		p.append(Vector2(x, z + verso * 0.34))
		p.append(Vector2(x + dente, z + verso * 0.34))
		p.append(Vector2(x + dente, z))
		x += 0.8
	p.append(Vector2(x1, z))
	return p


## Arco: ogni fila ha la sua fascia curva, lunga quanto lei; il cuore sporge davanti e dietro.
func _contorno_arco(e: Vector4) -> PackedVector2Array:
	var r_edifici: float = _raggio(false)
	var mezzo: float = (RAGGIO_ARCO + FASCIA_TRUPPE + r_edifici - FASCIA_EDIFICI) * 0.5
	var truppe: PackedVector2Array = _fascia_curva(RAGGIO_ARCO - FASCIA_TRUPPE, mezzo + 0.1, -e.x, e.y, RAGGIO_ARCO)
	var edifici: PackedVector2Array = _fascia_curva(mezzo - 0.1, r_edifici + FASCIA_EDIFICI, -e.z, e.w, r_edifici)
	return _unisci(_unisci(truppe, edifici), _cuore(0.45, 0.7))


## Una fascia curva fra due raggi, dal punto s0 al punto s1 della fila di raggio r_fila.
func _fascia_curva(r0: float, r1: float, s0: float, s1: float, r_fila: float) -> PackedVector2Array:
	var centro: float = z_truppe - RAGGIO_ARCO
	var p: PackedVector2Array = PackedVector2Array()
	var passi: int = 40
	for k: int in range(passi + 1):
		var a: float = lerpf(s0, s1, float(k) / float(passi)) / r_fila
		p.append(Vector2(sin(a) * r0, centro + cos(a) * r0))
	for k: int in range(passi + 1):
		var a: float = lerpf(s1, s0, float(k) / float(passi)) / r_fila
		p.append(Vector2(sin(a) * r1, centro + cos(a) * r1))
	return p


# --- Geometria ---------------------------------------------------------------------------

static func _piu_grande(poligoni: Array[PackedVector2Array]) -> PackedVector2Array:
	var migliore: PackedVector2Array = PackedVector2Array()
	var area: float = -1.0
	for p: PackedVector2Array in poligoni:
		var a: float = absf(_area(p))
		if a > area:
			area = a
			migliore = p
	return migliore


static func _area(p: PackedVector2Array) -> float:
	var a: float = 0.0
	for i: int in range(p.size()):
		var q: Vector2 = p[(i + 1) % p.size()]
		a += p[i].x * q.y - q.x * p[i].y
	return a * 0.5


static func _unisci(a: PackedVector2Array, b: PackedVector2Array) -> PackedVector2Array:
	return _piu_grande(Geometry2D.merge_polygons(a, b))


static func _rettangolo(x0: float, x1: float, z0: float, z1: float) -> PackedVector2Array:
	return PackedVector2Array([Vector2(x0, z0), Vector2(x1, z0), Vector2(x1, z1), Vector2(x0, z1)])


static func _ottagono(larghezza: float, z0: float, z1: float, smusso: float) -> PackedVector2Array:
	var w: float = larghezza * 0.5
	return PackedVector2Array([Vector2(-w + smusso, z0), Vector2(w - smusso, z0), Vector2(w, z0 + smusso), Vector2(w, z1 - smusso),
		Vector2(w - smusso, z1), Vector2(-w + smusso, z1), Vector2(-w, z1 - smusso), Vector2(-w, z0 + smusso)])


static func _cerchio(centro: Vector2, raggio: float) -> PackedVector2Array:
	var p: PackedVector2Array = PackedVector2Array()
	for k: int in range(28):
		var a: float = TAU * float(k) / 28.0
		p.append(centro + Vector2(cos(a), sin(a)) * raggio)
	return p
