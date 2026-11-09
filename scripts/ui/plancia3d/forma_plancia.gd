class_name FormaPlancia
extends Node3D
## La plancia di un lato, sagomata attorno al cuore della nazione (Davide, 9 novembre 2026).
## Non è più un rettangolo: segue le due file e cresce con loro. La forma la indica il popolo
## (IdentityDef.board_shape) o l'incontro del mondo (EncounterDef.board_shape):
##   «ali»   due fasce a punta, una per fila, unite dal cuore;
##   «mura»  un blocco a gradini con merli sui lati lunghi e una torre a ogni angolo;
##   «arco»  le file curve attorno a un centro lontano, come le gradinate di un anfiteatro;
##   vuoto   una lastra semplice dagli angoli tondi (incontri senza forma propria).
## Le plance dei nemici, una per famiglia di incontri, hanno il tratto caratteristico sul lato
## rivolto verso il giocatore (quello della fila delle truppe; Davide, 9 novembre 2026):
##   «nave»       mare: ponte in assi con la prua a punta, il bompresso e due cannoni;
##   «pelli»      terra selvaggia: pelle tesa, tirata a punte dai pali con le zanne d'osso;
##   «barricata»  fuorilegge: assi inchiodate e un cavallo di Frisia di pali appuntiti.
## Strati dal basso: legno, profilo d'ottone, fondo, filetto d'ottone, fondo (i colori cambiano
## con la forma).
## Solo presentazione: non contiene regole di gioco.

const ALI: StringName = &"ali"
const MURA: StringName = &"mura"
const ARCO: StringName = &"arco"
const NAVE: StringName = &"nave"
const PELLI: StringName = &"pelli"
const BARRICATA: StringName = &"barricata"
## Lunghezza della prua della nave, oltre il bordo della fila delle truppe.
const PRUA: float = 2.4
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
## [quota della faccia sotto CIMA, spessore]
const STRATI: Array = [[-0.012, 0.45], [-0.007, 0.1], [-0.004, 0.1], [-0.002, 0.1], [0.0, 0.1]]
## Rientro di ogni strato dal bordo, per forma (le altre forme usano RIENTRI_BASE).
const RIENTRI_BASE: Array[float] = [0.0, 0.11, 0.22, 0.36, 0.41]
const RIENTRI: Dictionary[StringName, Array] = {
	&"nave": [0.0, 0.16, 0.32, 0.32, 0.32],
	&"pelli": [0.0, 0.07, 0.14, 0.3, 0.33],
	&"barricata": [0.0, 0.0, 0.0, 0.0, 0.0],
}

static var _venatura: NoiseTexture2D
static var _assi: Dictionary = {}

var forma: StringName = &""
## 1 per il giocatore (file verso +z), -1 per il nemico (specchiato).
var segno: float = 1.0
var z_truppe: float = 1.75
var z_edifici: float = 4.85
var mezzo_cuore: float = 0.95
var estensioni: Vector4 = Vector4.ZERO
var _strati: Array[CSGPolygon3D] = []
var _nemico: bool = false
## Prua, pali, zanne e corde delle plance dei nemici, ricreati quando la forma cambia.
var _decori: Node3D


func costruisci(forma_scelta: StringName, verso: float, fila_truppe: float, fila_edifici: float, cuore: float, nemico: bool) -> void:
	forma = forma_scelta
	segno = verso
	z_truppe = fila_truppe
	z_edifici = fila_edifici
	mezzo_cuore = cuore
	_nemico = nemico
	for k: int in range(STRATI.size()):
		var strato: CSGPolygon3D = CSGPolygon3D.new()
		strato.depth = float(STRATI[k][1])
		strato.rotation.x = -PI * 0.5
		strato.position.y = CIMA + float(STRATI[k][0])
		add_child(strato)
		_strati.append(strato)
	_decori = Node3D.new()
	add_child(_decori)
	_applica_materiali()


## Cambia forma (per esempio quando arriva un nemico diverso) e ridisegna.
func cambia_forma(nuova: StringName) -> void:
	if nuova == forma:
		return
	forma = nuova
	_applica_materiali()
	if estensioni != Vector4.ZERO:
		imposta(estensioni)


## I materiali degli strati per la forma attuale.
func _applica_materiali() -> void:
	var materiali: Array[Material] = []
	match forma:
		NAVE:
			var assi: StandardMaterial3D = _materiale_assi(Color("9a7048"), 26)
			materiali = [_materiale_legno(Color("3b2416")), _materiale_legno(Color("7a4e2c")), assi, assi, assi]
		PELLI:
			var pelle: StandardMaterial3D = ScenaTeatro.materiale_carta(Color("9a6a44"), 1.5)
			materiali = [ScenaTeatro.materiale_carta(Color("2a1a10"), 1.5), ScenaTeatro.materiale_carta(Color("6b4428"), 1.5),
				pelle, StileVisivo.materiale(Color("4a2c18"), 0.9), pelle]
		BARRICATA:
			var grigie: StandardMaterial3D = _materiale_assi(Color("7a7064"), 40)
			materiali = [_materiale_legno(Color("2e2a26")), grigie, grigie, grigie, grigie]
		_:
			var fondo: Color = FONDO_NEMICO if _nemico else FONDO_GIOCATORE
			materiali = [_materiale_legno(LEGNO), StileVisivo.materiale(OTTONE, 0.3, 0.85),
				ScenaTeatro.materiale_carta(fondo, 2.0), StileVisivo.materiale(OTTONE.darkened(0.2), 0.35, 0.8),
				ScenaTeatro.materiale_carta(fondo, 2.0)]
	for k: int in range(_strati.size()):
		_strati[k].material = materiali[k]


## Assi di legno lungo la fila: strisce di tonalità diverse, fessure scure, giunture e chiodi.
## La trama è disegnata con un seme fisso, quindi è sempre la stessa.
static func _materiale_assi(colore: Color, altezza_asse: int) -> StandardMaterial3D:
	var chiave: String = "%s:%d" % [colore.to_html(), altezza_asse]
	if not _assi.has(chiave):
		var img: Image = Image.create(512, 512, false, Image.FORMAT_RGB8)
		var caso: RandomNumberGenerator = RandomNumberGenerator.new()
		caso.seed = 7
		var y: int = 0
		while y < 512:
			var tinta: Color = colore.darkened(caso.randf_range(-0.12, 0.18))
			var fine: int = mini(512, y + altezza_asse)
			img.fill_rect(Rect2i(0, y, 512, fine - y), tinta)
			img.fill_rect(Rect2i(0, fine - 3, 512, 3), colore.darkened(0.7))
			var x: int = caso.randi_range(0, 200)
			while x < 512:
				img.fill_rect(Rect2i(x, y, 3, fine - y), colore.darkened(0.65))
				img.fill_rect(Rect2i(x + 8, y + 6, 4, 4), Color("2a2622"))
				img.fill_rect(Rect2i(maxi(x - 12, 0), y + 6, 4, 4), Color("2a2622"))
				x += caso.randi_range(180, 320)
			y = fine
		img.generate_mipmaps()
		_assi[chiave] = ImageTexture.create_from_image(img)
	var materiale: StandardMaterial3D = StileVisivo.materiale(Color.WHITE, 0.85)
	materiale.albedo_texture = _assi[chiave]
	materiale.uv1_triplanar = true
	materiale.uv1_scale = Vector3(0.12, 0.12, 0.12)
	return materiale


static func _materiale_legno(colore: Color = LEGNO) -> StandardMaterial3D:
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
	var materiale: StandardMaterial3D = StileVisivo.materiale(colore, 0.55)
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


## Di quanto la plancia sporge verso il centro del tavolo oltre la fila delle truppe: le estremità
## dell'«arco», la prua della nave, i pali delle pelli e della barricata. Negli scontri le due
## plance si allontanano di tanto, per non toccarsi.
func rientro() -> float:
	match forma:
		NAVE:
			return PRUA + 1.2
		PELLI:
			return 1.5
		BARRICATA:
			return 1.3
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
	var tondo: float = 0.06 if forma == MURA or forma == BARRICATA else 0.25
	contorno = _piu_grande(Geometry2D.offset_polygon(contorno, -tondo, Geometry2D.JOIN_MITER))
	contorno = _piu_grande(Geometry2D.offset_polygon(contorno, tondo, Geometry2D.JOIN_ROUND))
	for k: int in range(_strati.size()):
		var rientri: Array = RIENTRI.get(forma, RIENTRI_BASE)
		var rientro_strato: float = float(rientri[k])
		var p: PackedVector2Array = contorno if rientro_strato <= 0.0 else _piu_grande(Geometry2D.offset_polygon(contorno, -rientro_strato, Geometry2D.JOIN_MITER))
		# Il poligono è nel piano (x, -z), specchiato per il nemico; l'ordine dei punti resta
		# antiorario.
		var girato: PackedVector2Array = PackedVector2Array()
		for v: Vector2 in p:
			girato.append(Vector2(v.x, -v.y * segno))
		if segno < 0.0:
			girato.reverse()
		_strati[k].polygon = girato
	_crea_decori(contorno, nuove)


func _contorno(e: Vector4) -> PackedVector2Array:
	match forma:
		ALI:
			return _contorno_ali(e)
		MURA:
			return _contorno_mura(e)
		ARCO:
			return _contorno_arco(e)
		NAVE:
			return _contorno_nave(e)
		PELLI:
			return _contorno_pelli(e)
		BARRICATA:
			return _contorno_barricata(e)
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


# --- Le plance dei nemici --------------------------------------------------------------------
# Il «fronte» è il lato della fila delle truppe: per il nemico è quello rivolto verso il giocatore.

## Nave: il ponte di una nave che ti viene addosso. La prua a punta sta al centro del fronte;
## i fianchi finiscono tondi, la poppa è dritta.
func _contorno_nave(e: Vector4) -> PackedVector2Array:
	var sinistra: float = maxf(e.x, e.z)
	var destra: float = maxf(e.y, e.w)
	var fronte: float = z_truppe - FASCIA_TRUPPE - 0.2
	var poppa: float = z_edifici + FASCIA_EDIFICI + 0.25
	var mezzo: float = (fronte + poppa) * 0.5
	var mezza: float = (poppa - fronte) * 0.5
	var p: PackedVector2Array = PackedVector2Array()
	for k: int in range(13):
		var a: float = PI * 0.5 + PI * float(k) / 12.0
		p.append(Vector2(-sinistra + cos(a) * 0.9, mezzo + sin(a) * mezza))
	var largo: float = 2.7
	p.append(Vector2(-largo, fronte))
	for k: int in range(1, 16):
		var x: float = lerpf(-largo, largo, float(k) / 16.0)
		p.append(Vector2(x, fronte - PRUA * (1.0 - pow(absf(x) / largo, 1.5))))
	p.append(Vector2(largo, fronte))
	for k: int in range(13):
		var a: float = -PI * 0.5 + PI * float(k) / 12.0
		p.append(Vector2(destra + cos(a) * 0.9, mezzo + sin(a) * mezza))
	return p


## Pelli: una pelle tesa dal bordo irregolare. Il fronte è tirato a punte dai pali; il retro è
## più morbido.
func _contorno_pelli(e: Vector4) -> PackedVector2Array:
	var centro: float = (z_truppe + z_edifici) * 0.5
	var mezza_z: float = (z_edifici + FASCIA_EDIFICI - z_truppe + FASCIA_TRUPPE) * 0.5 + 0.35
	var p: PackedVector2Array = PackedVector2Array()
	var passi: int = 120
	for k: int in range(passi):
		var a: float = TAU * float(k) / float(passi)
		var c: float = cos(a)
		var sn: float = sin(a)
		var rx: float = (maxf(e.x, e.z) if c < 0.0 else maxf(e.y, e.w)) + 0.45
		var x: float = signf(c) * pow(absf(c), 0.28) * rx
		var z: float = signf(sn) * pow(absf(sn), 0.28) * mezza_z
		if sn < 0.0:
			z -= pow(absf(sin(x * PI / 1.6)), 6.0) * 0.55 * pow(absf(sn), 2.0)
		else:
			z += 0.08 * sin(x * 2.3) * sn
		x += 0.12 * sin(a * 9.0) * absf(c)
		p.append(Vector2(x, centro + z))
	return p


## Barricata: per ogni fila assi inchiodate di lunghezze diverse (sempre le stesse: seme fisso),
## unite al cuore.
func _contorno_barricata(e: Vector4) -> PackedVector2Array:
	var caso: RandomNumberGenerator = RandomNumberGenerator.new()
	caso.seed = 11
	var contorno: PackedVector2Array = _ottagono((mezzo_cuore + 0.4) * 2.0, z_truppe - FASCIA_TRUPPE - 0.3, z_edifici + FASCIA_EDIFICI + 0.3, 0.15)
	for fila: Array in [[z_truppe, FASCIA_TRUPPE, e.x, e.y, 5], [z_edifici, FASCIA_EDIFICI, e.z, e.w, 4]]:
		var z0: float = float(fila[0]) - float(fila[1])
		var alto: float = float(fila[1]) * 2.0 / float(fila[4])
		for k: int in range(int(fila[4])):
			var a: float = float(fila[2]) + caso.randf_range(-0.15, 0.55)
			var b: float = float(fila[3]) + caso.randf_range(-0.15, 0.55)
			var z: float = z0 + alto * k
			contorno = _unisci(contorno, _rettangolo(-a, b, z - 0.01, z + alto + 0.01))
	return contorno


## Prua, cannoni, pali, zanne e corde. Le posizioni sono scritte come per il giocatore e
## specchiate per il nemico.
func _crea_decori(contorno: PackedVector2Array, e: Vector4) -> void:
	for figlio: Node in _decori.get_children():
		figlio.queue_free()
	var fronte: float = z_truppe - FASCIA_TRUPPE
	match forma:
		NAVE:
			# La murata: un corrimano di legno scuro lungo tutto lo scafo (un anello: il contorno
			# meno il suo interno, sottratto con la CSG).
			var murata: CSGPolygon3D = CSGPolygon3D.new()
			murata.polygon = _nel_piano(contorno)
			murata.depth = 0.16
			murata.rotation.x = -PI * 0.5
			murata.position.y = CIMA + 0.14
			murata.material = _materiale_legno(Color("4a2c18"))
			var vuoto: CSGPolygon3D = CSGPolygon3D.new()
			vuoto.operation = CSGShape3D.OPERATION_SUBTRACTION
			vuoto.polygon = _nel_piano(_piu_grande(Geometry2D.offset_polygon(contorno, -0.18, Geometry2D.JOIN_ROUND)))
			vuoto.depth = 0.4
			vuoto.position.z = 0.1
			murata.add_child(vuoto)
			_decori.add_child(murata)
			var punta: Vector3 = Vector3(0.0, CIMA + 0.25, fronte - 0.2 - PRUA)
			_palo(punta + Vector3(0.0, 0.0, 0.6), Vector3(deg_to_rad(-62.0), 0.0, 0.0), 0.07, 2.2, Color("3a2414"), true)
			var polena: MeshInstance3D = MeshInstance3D.new()
			var disco: CylinderMesh = CylinderMesh.new()
			disco.top_radius = 0.32
			disco.bottom_radius = 0.32
			disco.height = 0.08
			polena.mesh = disco
			polena.material_override = StileVisivo.materiale(OTTONE, 0.3, 0.85)
			polena.position = _in_scena(punta + Vector3(0.0, -0.05, 0.75))
			_decori.add_child(polena)
			for x: float in [-1.7, 1.7]:
				_palo(Vector3(x, CIMA + 0.27, fronte + 0.25), Vector3(deg_to_rad(-90.0), 0.0, 0.0), 0.11, 0.9, Color("1c1a1a"), false)
			var x: float = -maxf(e.x, e.z) + 0.8
			while x < maxf(e.y, e.w):
				_palo(Vector3(x, CIMA, z_edifici + FASCIA_EDIFICI + 0.05), Vector3.ZERO, 0.07, 0.35, Color("2a1a10"), false)
				x += 2.4
		PELLI:
			# I pali stanno nelle punte della pelle (dove sin(x·π/1.6) vale ±1), con due zanne
			# d'osso incrociate puntate in avanti.
			var bordo: float = fronte - 0.35
			var x: float = -0.8 - 1.6 * floorf((minf(e.x, e.z) - 0.8) / 1.6)
			while x <= minf(e.y, e.w):
				var dove: Vector3 = Vector3(x, 0.0, bordo - 0.6)
				_palo(dove, Vector3.ZERO, 0.09, 0.75, Color("3a2414"), true)
				_corda(Vector3(x, CIMA + 0.04, bordo - 0.2), dove + Vector3(0.0, 0.5, 0.0))
				for piega: float in [-22.0, 22.0]:
					_palo(dove + Vector3(0.0, 0.3, 0.0), Vector3(deg_to_rad(-62.0), 0.0, deg_to_rad(piega)), 0.065, 0.7, Color("efe4c8"), true)
				x += 1.6
			for angolo: Vector2 in [Vector2(-maxf(e.x, e.z) - 0.9, z_edifici + 0.4), Vector2(maxf(e.y, e.w) + 0.9, z_edifici + 0.4)]:
				_palo(Vector3(angolo.x, 0.0, angolo.y), Vector3.ZERO, 0.07, 0.7, Color("3a2414"), true)
				_corda(Vector3(angolo.x * 0.93, CIMA + 0.04, angolo.y), Vector3(angolo.x, 0.5, angolo.y))
		BARRICATA:
			# Un cavallo di Frisia: pali appuntiti incrociati a X, legati da una trave.
			var x: float = -e.x + 0.4
			var k: int = 0
			while x < e.y - 0.3:
				_palo(Vector3(x, 0.0, fronte + 0.1), Vector3(deg_to_rad(-48.0), 0.0, deg_to_rad(25.0 if k % 2 == 0 else -25.0)), 0.1, 1.5, Color("8a7e70"), true)
				x += 0.55
				k += 1
			var trave: MeshInstance3D = MeshInstance3D.new()
			var cilindro: CylinderMesh = CylinderMesh.new()
			cilindro.top_radius = 0.1
			cilindro.bottom_radius = 0.1
			cilindro.height = e.x + e.y
			trave.mesh = cilindro
			trave.material_override = _materiale_legno(Color("4a4038"))
			trave.rotation.z = PI * 0.5
			trave.position = _in_scena(Vector3((e.y - e.x) * 0.5, 0.5, fronte - 0.35))
			_decori.add_child(trave)


## Un punto scritto come per il giocatore, specchiato per il nemico.
func _in_scena(punto_giocatore: Vector3) -> Vector3:
	return Vector3(punto_giocatore.x, punto_giocatore.y, punto_giocatore.z * segno)


## Un contorno (x, z) nel piano delle placche ruotate, specchiato per il nemico.
func _nel_piano(p: PackedVector2Array) -> PackedVector2Array:
	var girato: PackedVector2Array = PackedVector2Array()
	for v: Vector2 in p:
		girato.append(Vector2(v.x, -v.y * segno))
	if segno < 0.0:
		girato.reverse()
	return girato


## Un palo (o un'asta, una zanna, un cannone) in piedi in "dove", ruotato come per il giocatore.
func _palo(dove: Vector3, rotazione: Vector3, raggio: float, alto: float, colore: Color, punta: bool) -> void:
	var nodo: Node3D = Node3D.new()
	nodo.position = _in_scena(dove)
	# Specchiare la profondità inverte le rotazioni attorno agli assi x e y.
	nodo.rotation = Vector3(rotazione.x * segno, rotazione.y * segno, rotazione.z)
	_decori.add_child(nodo)
	var materiale: StandardMaterial3D = _materiale_legno(colore)
	var asta: MeshInstance3D = MeshInstance3D.new()
	var cilindro: CylinderMesh = CylinderMesh.new()
	cilindro.top_radius = raggio
	cilindro.bottom_radius = raggio * 1.1
	cilindro.height = alto
	cilindro.radial_segments = 8
	asta.mesh = cilindro
	asta.material_override = materiale
	asta.position.y = alto * 0.5
	nodo.add_child(asta)
	if punta:
		var cima: MeshInstance3D = MeshInstance3D.new()
		var cono: CylinderMesh = CylinderMesh.new()
		cono.top_radius = 0.0
		cono.bottom_radius = raggio
		cono.height = raggio * 3.0
		cono.radial_segments = 8
		cima.mesh = cono
		cima.material_override = materiale
		cima.position.y = alto + raggio * 1.5
		nodo.add_child(cima)


func _corda(da_giocatore: Vector3, a_giocatore: Vector3) -> void:
	var da: Vector3 = _in_scena(da_giocatore)
	var a: Vector3 = _in_scena(a_giocatore)
	var corda: MeshInstance3D = MeshInstance3D.new()
	var cilindro: CylinderMesh = CylinderMesh.new()
	cilindro.top_radius = 0.018
	cilindro.bottom_radius = 0.018
	cilindro.height = da.distance_to(a)
	cilindro.radial_segments = 6
	corda.mesh = cilindro
	corda.material_override = StileVisivo.materiale(Color("c8b48a"), 0.95)
	_decori.add_child(corda)
	corda.position = (da + a) * 0.5
	var su: Vector3 = (a - da).normalized()
	var lato: Vector3 = su.cross(Vector3.RIGHT if absf(su.x) < 0.9 else Vector3.FORWARD).normalized()
	corda.basis = Basis(lato, su, lato.cross(su)).orthonormalized()


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
