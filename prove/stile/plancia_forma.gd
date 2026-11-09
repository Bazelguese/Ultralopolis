extends ProvaBase
## Prova della forma della plancia attorno al cuore della nazione (9 novembre 2026).
## Il cuore resta quello approvato: due placche, stendardo sulla fila delle truppe, sfere del mana
## su quella degli edifici. Cambia la plancia attorno, che non è più un rettangolo ma segue le file
## e cresce con loro. Tre varianti:
##   0 «Ali»   due fasce sagomate a punta, una per fila, unite dal cuore;
##   1 «Mura»  la plancia come le mura della nazione: merli sui lati lunghi, torri agli angoli;
##   2 «Arco»  le file curve attorno al cuore, come un anfiteatro.
## L'ordine delle file è quello del gioco: da sinistra a destra, il pezzo nuovo arriva in fondo a
## destra e le due metà si ribilanciano.

@export var variante: int = 0

const DURATA_PROVA: float = 11.5
const PASSO_T: float = 1.62
const PASSO_E: float = 2.3
const MISURA_T: Vector2 = Vector2(1.44, 2.16)
const MISURA_E: Vector2 = Vector2(2.13, 1.42)
const Z_T: float = -1.55
const Z_E: float = 1.55
const MEZZO_CUORE: float = 0.95
const STACCO: float = 0.25
## Mezza profondità delle fasce delle due file.
const FASCIA_T: float = 1.38
const FASCIA_E: float = 1.0
## Raggio dell'arco della fila delle truppe (variante Arco).
const RAGGIO: float = 16.0
const MARGINE: float = 0.45
const PROFONDITA_PLACCA_MANA: float = 2.3
const LEGNO: Color = Color("3a2418")
const OTTONE: Color = Color("c79a4a")
const FONDO: Color = Color("2a2119")
const CUOIO: Color = Color("2a3f6e")
const CARTA: Color = Color("e6d8b8")
const NOMI: Array[String] = ["Ali", "Mura", "Arco"]
const SHADER_SFERA: String = """
shader_type spatial;
render_mode blend_mix, cull_back, depth_draw_always;
uniform vec3 colore : source_color = vec3(1.0);
uniform float carica = 0.0;
void fragment() {
	float bordo = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 2.5);
	vec2 p = UV * vec2(6.2831, 3.1416);
	float vortice = 0.5 + 0.5 * sin(p.x * 3.0 + TIME * 2.2 + sin(p.y * 4.0 - TIME * 1.7) * 1.8);
	float nucleo = pow(clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
	float accesa = step(0.001, carica);
	ALBEDO = mix(vec3(0.012, 0.01, 0.01), colore * 0.2, accesa);
	EMISSION = colore * (carica * (0.8 + 2.2 * vortice * nucleo) + bordo * (0.45 + 1.6 * carica));
	ROUGHNESS = 0.25;
	SPECULAR = 0.3;
	ALPHA = clamp(0.8 + 0.2 * bordo, 0.0, 1.0);
}
"""

var _camera: Camera3D
var _lanterna: OmniLight3D
var _shader: Shader
var _venatura: NoiseTexture2D
var _grana: NoiseTexture2D
var _truppe: Array[Node3D] = []
var _edifici: Array[Node3D] = []
var _id_truppe: Array[String] = ["c8716e", "278014", "862b2d", "a4648d", "640641", "43a388", "ec7124"]
var _id_edifici: Array[String] = ["d61645", "19632f", "9928f9", "5066f4", "62b753"]
## Gli strati della plancia, dal basso: [nodo, rientro dal bordo, quota della faccia].
var _strati: Array = []
## Estensioni delle file lungo la fila: [sinistra truppe, destra truppe, sinistra edifici, destra edifici].
var _estensioni: Vector4 = Vector4.ZERO
var _foto: String = ""


func _ready() -> void:
	_font = load("res://font/BarlowSemiCondensed-ExtraBold.ttf") as FontFile
	_font_testo = load("res://font/Barlow-SemiBold.ttf") as FontFile
	var argomenti: PackedStringArray = OS.get_cmdline_user_args()
	if argomenti.size() > 0:
		_foto = argomenti[0]
	costruisci()
	_passi = [[3.0, "nuova_truppa", []], [4.8, "nuova_truppa", []], [6.6, "nuovo_edificio", []], [8.4, "nuovo_edificio", []]]


func _process(delta: float) -> void:
	tempo += delta
	while _indice < _passi.size() and float(_passi[_indice][0]) <= tempo:
		var passo: Array = _passi[_indice]
		_indice += 1
		callv(String(passo[1]), passo[2])
	_lanterna.position.x = sin(tempo * 0.5) * 2.5
	_lanterna.light_energy = 3.4 + sin(tempo * 13.0) * 0.08
	if _foto != "" and tempo >= 1.5:
		get_viewport().get_texture().get_image().save_png(_foto)
		get_tree().quit()
	if tempo >= DURATA_PROVA:
		get_tree().quit()


func costruisci() -> void:
	_shader = Shader.new()
	_shader.code = """
shader_type spatial;
render_mode cull_disabled, depth_draw_opaque;
uniform sampler2D tex : source_color, filter_linear_mipmap;
void fragment() {
	vec4 c = texture(tex, UV);
	ALBEDO = c.rgb;
	ROUGHNESS = 0.9;
	ALPHA = c.a;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
}
"""
	_venatura = NoiseTexture2D.new()
	var fv: FastNoiseLite = FastNoiseLite.new()
	fv.frequency = 0.012
	fv.fractal_octaves = 5
	fv.domain_warp_enabled = true
	fv.domain_warp_amplitude = 30.0
	_venatura.noise = fv
	_venatura.seamless = true
	_venatura.width = 512
	_venatura.height = 64
	var rv: Gradient = Gradient.new()
	rv.set_color(0, Color(0.72, 0.68, 0.64))
	rv.set_color(1, Color(1.0, 1.0, 1.0))
	_venatura.color_ramp = rv
	_grana = NoiseTexture2D.new()
	var fg: FastNoiseLite = FastNoiseLite.new()
	fg.frequency = 0.08
	fg.fractal_octaves = 3
	_grana.noise = fg
	_grana.seamless = true
	var rg: Gradient = Gradient.new()
	rg.set_color(0, Color(0.85, 0.82, 0.8))
	rg.set_color(1, Color(1.0, 1.0, 1.0))
	_grana.color_ramp = rg

	var amb: Environment = Environment.new()
	amb.background_mode = Environment.BG_COLOR
	amb.background_color = Color("070605")
	amb.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	amb.ambient_light_color = Color("5a4a50")
	amb.ambient_light_energy = 0.7
	amb.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	amb.glow_enabled = true
	amb.glow_intensity = 0.6
	amb.glow_bloom = 0.05
	var we: WorldEnvironment = WorldEnvironment.new()
	we.environment = amb
	add_child(we)
	_camera = Camera3D.new()
	_camera.fov = 34.0
	add_child(_camera)
	_camera.look_at_from_position(Vector3(0.0, 14.0, 12.0), Vector3(0.0, 0.0, -0.4), Vector3.UP)
	_lanterna = OmniLight3D.new()
	_lanterna.light_color = Color("ffb877")
	_lanterna.light_energy = 3.4
	_lanterna.omni_range = 40.0
	_lanterna.omni_attenuation = 1.1
	_lanterna.shadow_enabled = true
	_lanterna.position = Vector3(0.0, 10.0, 5.0)
	add_child(_lanterna)
	var riempi: DirectionalLight3D = DirectionalLight3D.new()
	riempi.light_color = Color("ffe6c8")
	riempi.light_energy = 0.45
	riempi.rotation_degrees = Vector3(-55.0, -30.0, 0.0)
	riempi.shadow_enabled = true
	add_child(riempi)
	var fredda: DirectionalLight3D = DirectionalLight3D.new()
	fredda.light_color = Color("8aa0d8")
	fredda.light_energy = 0.3
	fredda.rotation_degrees = Vector3(-25.0, 160.0, 0.0)
	add_child(fredda)
	var tavolo: MeshInstance3D = MeshInstance3D.new()
	var bt: BoxMesh = BoxMesh.new()
	bt.size = Vector3(80.0, 0.2, 60.0)
	tavolo.mesh = bt
	tavolo.material_override = _materiale(Color("140f12"), _grana, 0.95)
	tavolo.position = Vector3(0.0, -0.5, 0.0)
	add_child(tavolo)

	# Gli strati della plancia: legno, profilo d'ottone, fondo, filetto d'ottone, fondo.
	var definizioni: Array = [
		[0.0, 0.0, 0.4, _materiale(LEGNO, _venatura, 0.55)],
		[0.09, 0.03, 0.1, _materiale(OTTONE, null, 0.3, 0.85)],
		[0.2, 0.04, 0.1, _materiale(FONDO, _grana, 0.9)],
		[0.34, 0.045, 0.1, _materiale(OTTONE.darkened(0.2), null, 0.35, 0.8)],
		[0.39, 0.05, 0.1, _materiale(FONDO, _grana, 0.9)]]
	for d: Array in definizioni:
		var forma: CSGPolygon3D = CSGPolygon3D.new()
		forma.depth = float(d[2])
		forma.material = d[3]
		forma.rotation.x = -PI * 0.5
		forma.position.y = float(d[1])
		add_child(forma)
		_strati.append([forma, float(d[0])])
	_crea_cuore()
	for i: int in range(4):
		_truppe.append(_tessera(_id_truppe[i], true, 0.0))
	for i: int in range(3):
		_edifici.append(_tessera(_id_edifici[i], false, 0.0))
	_disponi(0.0)
	strato_grana(0.03, "Forma della plancia %d · %s — il cuore resta al centro, la plancia segue le file" % [variante + 1, NOMI[variante]])


# --- Materiali e pezzi ------------------------------------------------------------------

func _materiale(colore: Color, trama: Texture2D, ruvido: float, metallo: float = 0.0) -> StandardMaterial3D:
	var m: StandardMaterial3D = StandardMaterial3D.new()
	m.albedo_color = colore
	if trama != null:
		m.albedo_texture = trama
		m.uv1_triplanar = true
		m.uv1_scale = Vector3(0.35, 0.35, 0.35)
	m.roughness = ruvido
	m.metallic = metallo
	return m


func _scatola(dim: Vector3, pos: Vector3, colore: Color, trama: Texture2D, ruvido: float, genitore: Node3D) -> MeshInstance3D:
	var m: MeshInstance3D = MeshInstance3D.new()
	var b: BoxMesh = BoxMesh.new()
	b.size = dim
	m.mesh = b
	m.material_override = _materiale(colore, trama, ruvido)
	m.position = pos
	genitore.add_child(m)
	return m


func _quadro(misura: Vector2, trama: Texture2D, pos: Vector3, genitore: Node3D) -> MeshInstance3D:
	var q: QuadMesh = QuadMesh.new()
	q.size = misura
	var m: MeshInstance3D = MeshInstance3D.new()
	m.mesh = q
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = _shader
	mat.set_shader_parameter("tex", trama)
	m.material_override = mat
	m.position = pos
	genitore.add_child(m)
	return m


## Una tessera: carta color crema con la finestra del disegno e la figurina in piedi.
func _tessera(id: String, truppa: bool, ritardo: float) -> Node3D:
	var radice: Node3D = Node3D.new()
	add_child(radice)
	var misura: Vector2 = MISURA_T if truppa else MISURA_E
	_scatola(Vector3(misura.x, 0.04, misura.y), Vector3(0.0, 0.07, 0.0), CARTA, _grana, 0.95, radice)
	_scatola(Vector3(misura.x - 0.2, 0.045, misura.y * 0.62), Vector3(0.0, 0.072, -misura.y * 0.1), Color("2b211b"), _grana, 0.9, radice)
	_scatola(Vector3(misura.x * 0.5, 0.046, 0.12), Vector3(0.0, 0.073, misura.y * 0.36), Color("8e2a24") if truppa else Color("9a7a2a"), null, 0.8, radice)
	var alto: float = misura.x * (1.05 if truppa else 0.68)
	var perno: Node3D = Node3D.new()
	perno.position = Vector3(0.0, 0.1, -misura.y * 0.12)
	radice.add_child(perno)
	_quadro(Vector2(alto, alto), immagine("sagome", id), Vector3(0.0, alto * 0.5, 0.0), perno)
	if ritardo > 0.0:
		perno.rotation.x = PI * 0.5
		var t: Tween = create_tween()
		t.tween_interval(ritardo)
		t.tween_property(perno, "rotation:x", 0.0, 0.55).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return radice


## Una placca a otto lati (angoli smussati) con la faccia a quota "cima".
func _placca(genitore: Node3D, centro: Vector3, misura: Vector2, smusso: float, cima: float, materiale: Material) -> void:
	var w: float = misura.x * 0.5
	var d: float = misura.y * 0.5
	var c: float = smusso
	var forma: CSGPolygon3D = CSGPolygon3D.new()
	forma.polygon = PackedVector2Array([Vector2(-w + c, -d), Vector2(w - c, -d), Vector2(w, -d + c), Vector2(w, d - c),
		Vector2(w - c, d), Vector2(-w + c, d), Vector2(-w, d - c), Vector2(-w, -d + c)])
	forma.depth = 0.12
	forma.material = materiale
	forma.rotation.x = -PI * 0.5
	forma.position = Vector3(centro.x, cima, centro.z)
	genitore.add_child(forma)


## Il cuore della nazione: due placche, una per fila, unite da due barrette d'ottone.
func _crea_cuore() -> void:
	var cuore: Node3D = Node3D.new()
	add_child(cuore)
	var largo: float = MEZZO_CUORE * 2.0
	var misure: Array[Vector2] = [Vector2(largo, MISURA_T.y + 0.1), Vector2(largo, PROFONDITA_PLACCA_MANA)]
	var zs: Array[float] = [Z_T, Z_E]
	var base: StandardMaterial3D = _materiale(Color("1c1612"), _venatura, 0.5)
	var ottone: StandardMaterial3D = _materiale(OTTONE, null, 0.3, 0.85)
	var filetto: StandardMaterial3D = _materiale(OTTONE.darkened(0.15), null, 0.35, 0.8)
	var pannello: StandardMaterial3D = _materiale(CUOIO, _grana, 0.75)
	var strati: Array = [[-0.05, 0.34, 0.12, base], [0.02, 0.3, 0.17, ottone], [0.1, 0.24, 0.18, pannello],
		[0.17, 0.18, 0.185, filetto], [0.2, 0.15, 0.19, pannello]]
	for k: int in range(2):
		for strato: Array in strati:
			var r: float = float(strato[0])
			_placca(cuore, Vector3(0.0, 0.0, zs[k]), misure[k] - Vector2(r, r) * 2.0, float(strato[1]), float(strato[2]), strato[3])
	var z0: float = Z_T + misure[0].y * 0.5
	var z1: float = Z_E - misure[1].y * 0.5
	for x: float in [-0.18, 0.18]:
		var barra: MeshInstance3D = MeshInstance3D.new()
		var cb: CylinderMesh = CylinderMesh.new()
		cb.top_radius = 0.045
		cb.bottom_radius = 0.045
		cb.height = z1 - z0 + 0.2
		barra.mesh = cb
		barra.material_override = ottone
		barra.rotation.x = PI * 0.5
		barra.position = Vector3(x, 0.1, (z0 + z1) * 0.5)
		cuore.add_child(barra)
	# Lo stendardo steso sulla placca delle truppe, come fuori dagli scontri.
	var img: Image = Image.create(160, 200, false, Image.FORMAT_RGBA8)
	img.fill(Color("ece2cc"))
	img.fill_rect(Rect2i(0, 0, 160, 26), CUOIO.lightened(0.15))
	img.fill_rect(Rect2i(0, 26, 160, 4), Color("1a1410"))
	for xx: int in range(160):
		var taglio: int = 172 + int(absf(float(xx % 40) - 20.0) * 1.3)
		for yy: int in range(taglio, 200):
			img.set_pixel(xx, yy, Color(0, 0, 0, 0))
	img.generate_mipmaps()
	var telo: MeshInstance3D = _quadro(Vector2(1.3, 1.62), ImageTexture.create_from_image(img), Vector3(0.0, 0.2, Z_T), cuore)
	telo.rotation.x = -PI * 0.5
	var iniziali: Label3D = scritta("NP", 60, Color("1a1410"), Color(0, 0, 0, 0), 0)
	iniziali.rotation.x = -PI * 0.5
	iniziali.position = Vector3(0.0, 0.205, Z_T - 0.35)
	cuore.add_child(iniziali)
	var numero: Label3D = scritta("58", 120, Color("1a1410"), Color(0, 0, 0, 0), 0)
	numero.rotation.x = -PI * 0.5
	numero.position = Vector3(0.0, 0.205, Z_T + 0.2)
	cuore.add_child(numero)
	# Le sfere del mana come nel gioco: la gialla al centro, le altre a croce.
	var sfera_shader: Shader = Shader.new()
	sfera_shader.code = SHADER_SFERA
	var centro: Vector3 = Vector3(0.0, 0.19, Z_E)
	var colori: Array[Color] = [ENERGIA, ROSSO, VERDE, BLU, VIOLA]
	var punti: Array[Vector3] = [Vector3.ZERO, Vector3(0.0, 0.0, -0.8), Vector3(0.62, 0.0, 0.0), Vector3(0.0, 0.0, 0.8), Vector3(-0.62, 0.0, 0.0)]
	var cariche: Array[float] = [0.6, 0.35, 0.0, 0.0, 0.5]
	for k: int in range(5):
		var raggio: float = 0.26 if k == 0 else 0.2
		var nodo: Node3D = Node3D.new()
		nodo.position = centro + punti[k]
		cuore.add_child(nodo)
		var anello: MeshInstance3D = MeshInstance3D.new()
		var ca: CylinderMesh = CylinderMesh.new()
		ca.top_radius = raggio * 0.95
		ca.bottom_radius = raggio * 1.15
		ca.height = 0.05
		anello.mesh = ca
		anello.material_override = _materiale(Color("c9bfa8"), null, 0.9)
		anello.position.y = 0.025
		nodo.add_child(anello)
		var sfera: MeshInstance3D = MeshInstance3D.new()
		var s: SphereMesh = SphereMesh.new()
		s.radius = raggio
		s.height = raggio * 2.0
		s.radial_segments = 32
		s.rings = 16
		sfera.mesh = s
		var m: ShaderMaterial = ShaderMaterial.new()
		m.shader = sfera_shader
		m.set_shader_parameter("colore", colori[k])
		m.set_shader_parameter("carica", cariche[k])
		sfera.material_override = m
		sfera.position.y = 0.05 + raggio
		nodo.add_child(sfera)
		if cariche[k] > 0.0:
			var luce: OmniLight3D = OmniLight3D.new()
			luce.light_color = colori[k]
			luce.light_energy = cariche[k] * 1.6
			luce.omni_range = 1.4
			luce.position.y = sfera.position.y
			nodo.add_child(luce)


# --- Le file e la forma della plancia ------------------------------------------------------

## Posizioni lungo la fila (s): la metà di sinistra è la più corta, come nel gioco.
func _posizioni(quante: int, passo: float) -> Array[float]:
	var xs: Array[float] = []
	var sinistra: int = quante / 2
	for i: int in range(sinistra):
		xs.append(-MEZZO_CUORE - STACCO - (sinistra - i - 0.5) * passo)
	for i: int in range(quante - sinistra):
		xs.append(MEZZO_CUORE + STACCO + (i + 0.5) * passo)
	return xs


func _raggio_fila(truppa: bool) -> float:
	return RAGGIO if truppa else RAGGIO + (Z_E - Z_T)


## Dove sta il punto s di una fila: posizione e rotazione (nell'Arco le carte seguono la curva).
func _punto(truppa: bool, s: float) -> Array:
	var z: float = Z_T if truppa else Z_E
	if variante != 2:
		return [Vector3(s, 0.0, z), 0.0]
	var r: float = _raggio_fila(truppa)
	var angolo: float = s / r
	var zc: float = Z_T - RAGGIO
	return [Vector3(sin(angolo) * r, 0.0, zc + cos(angolo) * r), angolo]


func _disponi(durata: float) -> void:
	var st: Array[float] = _posizioni(_truppe.size(), PASSO_T)
	var se: Array[float] = _posizioni(_edifici.size(), PASSO_E)
	for i: int in range(_truppe.size()):
		_muovi(_truppe[i], _punto(true, st[i]), durata)
	for i: int in range(_edifici.size()):
		_muovi(_edifici[i], _punto(false, se[i]), durata)
	var nt: int = _truppe.size() / 2
	var ne: int = _edifici.size() / 2
	var bordo: float = MEZZO_CUORE + STACCO
	var nuove: Vector4 = Vector4(bordo + nt * PASSO_T, bordo + (_truppe.size() - nt) * PASSO_T,
		bordo + ne * PASSO_E, bordo + (_edifici.size() - ne) * PASSO_E) + Vector4.ONE * MARGINE
	if durata <= 0.0:
		_imposta_forma(nuove)
		return
	var t: Tween = create_tween()
	t.tween_method(_imposta_forma, _estensioni, nuove, durata).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)


func _muovi(n: Node3D, dove: Array, durata: float) -> void:
	var pos: Vector3 = dove[0]
	var angolo: float = float(dove[1])
	if durata <= 0.0:
		n.position = pos
		n.rotation.y = angolo
		return
	var t: Tween = create_tween()
	t.set_parallel(true)
	t.tween_property(n, "position", pos, durata).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(n, "rotation:y", angolo, durata).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)


## Ricostruisce il contorno della plancia e tutti i suoi strati.
func _imposta_forma(estensioni: Vector4) -> void:
	_estensioni = estensioni
	var contorno: PackedVector2Array = _contorno(estensioni)
	# Angoli appena arrotondati: si stringe e si riallarga con giunture tonde.
	# (Le Mura arrotondano poco, per non cancellare i merli.)
	var tondo: float = 0.06 if variante == 1 else 0.25
	contorno = _piu_grande(Geometry2D.offset_polygon(contorno, -tondo, Geometry2D.JOIN_MITER))
	contorno = _piu_grande(Geometry2D.offset_polygon(contorno, tondo, Geometry2D.JOIN_ROUND))
	for strato: Array in _strati:
		var forma: CSGPolygon3D = strato[0]
		var rientro: float = float(strato[1])
		var p: PackedVector2Array = contorno if rientro <= 0.0 else _piu_grande(Geometry2D.offset_polygon(contorno, -rientro, Geometry2D.JOIN_MITER))
		# Il poligono sta nel piano x, -z (la placca è ruotata per guardare in alto).
		var girato: PackedVector2Array = PackedVector2Array()
		for v: Vector2 in p:
			girato.append(Vector2(v.x, -v.y))
		forma.polygon = girato


func _piu_grande(poligoni: Array[PackedVector2Array]) -> PackedVector2Array:
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


func _unisci(a: PackedVector2Array, b: PackedVector2Array) -> PackedVector2Array:
	return _piu_grande(Geometry2D.merge_polygons(a, b))


func _rettangolo(x0: float, x1: float, z0: float, z1: float) -> PackedVector2Array:
	return PackedVector2Array([Vector2(x0, z0), Vector2(x1, z0), Vector2(x1, z1), Vector2(x0, z1)])


func _ottagono(larghezza: float, z0: float, z1: float, smusso: float) -> PackedVector2Array:
	var w: float = larghezza * 0.5
	return PackedVector2Array([Vector2(-w + smusso, z0), Vector2(w - smusso, z0), Vector2(w, z0 + smusso), Vector2(w, z1 - smusso),
		Vector2(w - smusso, z1), Vector2(-w + smusso, z1), Vector2(-w, z1 - smusso), Vector2(-w, z0 + smusso)])


func _cerchio(centro: Vector2, raggio: float) -> PackedVector2Array:
	var p: PackedVector2Array = PackedVector2Array()
	for k: int in range(28):
		var a: float = TAU * float(k) / 28.0
		p.append(centro + Vector2(cos(a), sin(a)) * raggio)
	return p


## Il contorno (in x, z) per le estensioni date.
func _contorno(e: Vector4) -> PackedVector2Array:
	match variante:
		0:
			return _contorno_ali(e)
		1:
			return _contorno_mura(e)
	return _contorno_arco(e)


## Ali: una fascia per fila con le estremità a punta; il cuore le unisce ed esce davanti e dietro.
func _contorno_ali(e: Vector4) -> PackedVector2Array:
	var punta: float = 0.75
	var truppe: PackedVector2Array = PackedVector2Array([Vector2(-e.x, Z_T - FASCIA_T), Vector2(e.y, Z_T - FASCIA_T), Vector2(e.y + punta, Z_T),
		Vector2(e.y, Z_T + FASCIA_T), Vector2(-e.x, Z_T + FASCIA_T), Vector2(-e.x - punta, Z_T)])
	var edifici: PackedVector2Array = PackedVector2Array([Vector2(-e.z, Z_E - FASCIA_E), Vector2(e.w, Z_E - FASCIA_E), Vector2(e.w + punta, Z_E),
		Vector2(e.w, Z_E + FASCIA_E), Vector2(-e.z, Z_E + FASCIA_E), Vector2(-e.z - punta, Z_E)])
	var cuore: PackedVector2Array = _ottagono((MEZZO_CUORE + 0.45) * 2.0, Z_T - FASCIA_T - 0.45, Z_E + FASCIA_E + 0.45, 0.7)
	# Le due fasce non si toccano: si uniscono una alla volta al cuore.
	return _unisci(_unisci(cuore, truppe), edifici)


## Mura: un solo blocco a gradini (le file hanno lunghezze diverse), merli sui lati lunghi
## esterni, una torre tonda a ogni angolo e il cuore come porta che sporge davanti e dietro.
func _contorno_mura(e: Vector4) -> PackedVector2Array:
	var dietro: float = Z_T - FASCIA_T
	var davanti: float = Z_E + FASCIA_E
	var mezzo: float = (Z_T + FASCIA_T + Z_E - FASCIA_E) * 0.5
	# Fila delle truppe, con i merli sul lato di dietro.
	var truppe: PackedVector2Array = PackedVector2Array()
	truppe.append(Vector2(-e.x, mezzo + 0.1))
	truppe.append_array(_merli(-e.x, e.y, dietro, -1.0))
	truppe.append(Vector2(e.y, mezzo + 0.1))
	# Fila degli edifici, con i merli sul lato davanti.
	var edifici: PackedVector2Array = PackedVector2Array()
	edifici.append(Vector2(e.w, mezzo - 0.1))
	var merli: PackedVector2Array = _merli(-e.z, e.w, davanti, 1.0)
	merli.reverse()
	edifici.append_array(merli)
	edifici.append(Vector2(-e.z, mezzo - 0.1))
	var forma: PackedVector2Array = _unisci(truppe, edifici)
	for angolo: Vector2 in [Vector2(-e.x, dietro), Vector2(e.y, dietro), Vector2(-e.z, davanti), Vector2(e.w, davanti)]:
		forma = _unisci(forma, _cerchio(angolo, 0.62))
	forma = _unisci(forma, _ottagono((MEZZO_CUORE + 0.4) * 2.0, dietro - 0.5, davanti + 0.5, 0.45))
	return forma


## Un lato con i merli fra x0 e x1, a quota z; i merli sporgono verso "verso".
func _merli(x0: float, x1: float, z: float, verso: float) -> PackedVector2Array:
	var p: PackedVector2Array = PackedVector2Array()
	var passo: float = 0.8
	var dente: float = 0.42
	p.append(Vector2(x0, z))
	var x: float = x0 + 0.5
	while x + dente < x1 - 0.5:
		p.append(Vector2(x, z))
		p.append(Vector2(x, z + verso * 0.34))
		p.append(Vector2(x + dente, z + verso * 0.34))
		p.append(Vector2(x + dente, z))
		x += passo
	p.append(Vector2(x1, z))
	return p


## Arco: le due file curve attorno a un centro lontano, come le gradinate di un anfiteatro.
## Ogni fila ha la sua fascia curva, lunga quanto lei; il cuore sporge davanti e dietro.
func _contorno_arco(e: Vector4) -> PackedVector2Array:
	var r_e: float = _raggio_fila(false)
	var mezzo: float = (RAGGIO + FASCIA_T + r_e - FASCIA_E) * 0.5
	var truppe: PackedVector2Array = _fascia_curva(RAGGIO - FASCIA_T, mezzo + 0.1, -e.x, e.y, RAGGIO)
	var edifici: PackedVector2Array = _fascia_curva(mezzo - 0.1, r_e + FASCIA_E, -e.z, e.w, r_e)
	var cuore: PackedVector2Array = _ottagono((MEZZO_CUORE + 0.45) * 2.0, Z_T - FASCIA_T - 0.45, Z_E + FASCIA_E + 0.45, 0.7)
	return _unisci(_unisci(truppe, edifici), cuore)


## Una fascia curva fra due raggi, dal punto s0 al punto s1 della fila di raggio r_fila.
func _fascia_curva(r0: float, r1: float, s0: float, s1: float, r_fila: float) -> PackedVector2Array:
	var zc: float = Z_T - RAGGIO
	var p: PackedVector2Array = PackedVector2Array()
	var passi: int = 40
	for k: int in range(passi + 1):
		var a: float = lerpf(s0, s1, float(k) / float(passi)) / r_fila
		p.append(Vector2(sin(a) * r0, zc + cos(a) * r0))
	for k: int in range(passi + 1):
		var a: float = lerpf(s1, s0, float(k) / float(passi)) / r_fila
		p.append(Vector2(sin(a) * r1, zc + cos(a) * r1))
	return p


# --- Crescita --------------------------------------------------------------------------------

## Il pezzo nuovo arriva in fondo a destra; le due metà si ribilanciano.
func _aggiungi(fila: Array[Node3D], nuova: Node3D, passo: float, truppa: bool) -> void:
	fila.append(nuova)
	var s: Array[float] = _posizioni(fila.size(), passo)
	var dove: Array = _punto(truppa, s[s.size() - 1])
	nuova.position = dove[0]
	nuova.rotation.y = float(dove[1])
	nuova.scale = Vector3(0.01, 1.0, 0.01)
	var t: Tween = create_tween()
	t.tween_interval(0.25)
	t.tween_property(nuova, "scale", Vector3.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	esplodi(self, nuova.position + Vector3(0.0, 0.4, 0.0), scintille(Color("ffd27a"), 30, 2.0, -2.0, 0.7, 0.06))
	_disponi(0.6)


func nuova_truppa() -> void:
	_aggiungi(_truppe, _tessera(_id_truppe[_truppe.size()], true, 0.55), PASSO_T, true)


func nuovo_edificio() -> void:
	_aggiungi(_edifici, _tessera(_id_edifici[_edifici.size()], false, 0.55), PASSO_E, false)
