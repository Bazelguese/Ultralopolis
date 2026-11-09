extends ProvaBase
## Prove della plancia con la nazione al centro (9 novembre 2026), come l'eroe in Hearthstone o
## in The Bazaar. 0 = A · Ritratto sul bordo, 1 = B · Cartiglio fra le file, 2 = C · Colonna centrale.
## Scena finta: si conquistano due spazi truppa e uno edificio, per vedere come cresce la plancia.

@export var variante: int = 0

const TITOLI: Array[String] = ["A · Ritratto sul bordo", "B · Cartiglio fra le file", "C · Colonna centrale"]
const DESCRIZIONI: Array[String] = [
	"La nazione è un arco sul bordo verso di te, come l'eroe di Hearthstone. Le file restano centrate e crescono ai due lati.",
	"La nazione è un cartiglio fra truppe ed edifici, al centro della plancia. Le file crescono ai due lati.",
	"La nazione è una colonna che taglia la plancia a metà. Ogni spazio nuovo nasce accanto al centro e spinge fuori gli altri.",
]
const DURATA_PROVA: float = 11.0
const PASSO_T: float = 1.62
const PASSO_E: float = 2.3
const MISURA_T: Vector2 = Vector2(1.44, 2.16)
const MISURA_E: Vector2 = Vector2(2.13, 1.42)
## Truppe verso il nemico (in alto), edifici verso di te (in basso), come nel gioco.
var Z_T: float = -1.7
var Z_E: float = 1.9
## Mezza larghezza della colonna centrale (solo C).
const MEZZA_COLONNA: float = 1.25

var _camera: Camera3D
var _lanterna: OmniLight3D
var _shader: Shader
var _rumore: NoiseTexture2D
var _truppe: Array[Node3D] = []
var _edifici: Array[Node3D] = []
var _id_truppe: Array[String] = ["c8716e", "278014", "862b2d", "a4648d", "640641", "43a388", "ec7124"]
var _id_edifici: Array[String] = ["d61645", "19632f", "9928f9", "5066f4"]
var _fondo: MeshInstance3D
var _cornice: Array[MeshInstance3D] = []
var _vuoti: Array[Node3D] = []


func _ready() -> void:
	_font = load("res://font/BarlowSemiCondensed-ExtraBold.ttf") as FontFile
	_font_testo = load("res://font/Barlow-SemiBold.ttf") as FontFile
	costruisci()
	_passi = [[3.0, "nuova_truppa", []], [5.2, "nuova_truppa", []], [7.4, "nuovo_edificio", []]]


func _process(delta: float) -> void:
	tempo += delta
	while _indice < _passi.size() and float(_passi[_indice][0]) <= tempo:
		var passo: Array = _passi[_indice]
		_indice += 1
		callv(String(passo[1]), passo[2])
	_lanterna.position.x = sin(tempo * 0.6) * 3.0
	_lanterna.light_energy = 4.2 + sin(tempo * 13.0) * 0.1
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
	_rumore = NoiseTexture2D.new()
	var fn: FastNoiseLite = FastNoiseLite.new()
	fn.frequency = 0.03
	fn.fractal_octaves = 4
	_rumore.noise = fn
	_rumore.seamless = true
	var amb: Environment = Environment.new()
	amb.background_mode = Environment.BG_COLOR
	amb.background_color = Color("070605")
	amb.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	amb.ambient_light_color = Color("4a3c48")
	amb.ambient_light_energy = 0.8
	amb.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	amb.glow_enabled = true
	amb.glow_intensity = 0.5
	var we: WorldEnvironment = WorldEnvironment.new()
	we.environment = amb
	add_child(we)
	_camera = Camera3D.new()
	_camera.fov = 36.0
	add_child(_camera)
	_camera.look_at_from_position(Vector3(0.0, 14.5, 13.0), Vector3(0.0, 0.0, -0.2), Vector3.UP)
	_lanterna = OmniLight3D.new()
	_lanterna.light_color = Color("ffb067")
	_lanterna.light_energy = 4.2
	_lanterna.omni_range = 40.0
	_lanterna.omni_attenuation = 1.1
	_lanterna.shadow_enabled = true
	_lanterna.position = Vector3(0.0, 11.0, 6.0)
	add_child(_lanterna)
	var riempi: DirectionalLight3D = DirectionalLight3D.new()
	riempi.light_color = Color("ffe2c0")
	riempi.light_energy = 0.4
	riempi.rotation_degrees = Vector3(-60.0, -25.0, 0.0)
	add_child(riempi)
	_scatola(Vector3(80.0, 0.2, 60.0), Vector3(0.0, -0.45, 0.0), Color("151019"))
	# La plancia: un fondo scuro con la cornice crema, che si allarga ai due lati.
	_fondo = _scatola(Vector3(10.0, 0.3, 8.6), Vector3(0.0, -0.2, 0.2), Color("3d2f22"))
	for i: int in range(4):
		_cornice.append(_scatola(Vector3(1.0, 0.06, 1.0), Vector3.ZERO, Color("d8cbb0")))
	for i: int in range(4):
		_truppe.append(_tessera(_id_truppe[i], true, 0.0))
	for i: int in range(3):
		_edifici.append(_tessera(_id_edifici[i], false, 0.0))
	match variante:
		0:
			Z_T = -2.4
			Z_E = 1.0
			_ritratto()
		1:
			Z_T = -2.5
			Z_E = 2.6
			_cartiglio()
		2: _colonna()
	_disponi(0.0)
	var strato: CanvasLayer = CanvasLayer.new()
	strato.layer = 2
	add_child(strato)
	var titolo: Label = Label.new()
	titolo.text = TITOLI[variante]
	titolo.add_theme_font_override("font", _font)
	titolo.add_theme_font_size_override("font_size", 58)
	titolo.add_theme_color_override("font_color", Color("ece2cc"))
	titolo.position = Vector2(48, 26)
	strato.add_child(titolo)
	var spiega: Label = Label.new()
	spiega.text = DESCRIZIONI[variante]
	spiega.add_theme_font_override("font", _font_testo)
	spiega.add_theme_font_size_override("font_size", 26)
	spiega.add_theme_color_override("font_color", Color("cdbd9c"))
	spiega.position = Vector2(50, 100)
	spiega.size = Vector2(1820, 80)
	spiega.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	strato.add_child(spiega)
	strato_grana(0.035, "Prova della plancia con la nazione al centro — solo disposizione, tessere e disegni messi a caso")


# --- Pezzi ----------------------------------------------------------------------------

func _scatola(dim: Vector3, pos: Vector3, colore: Color, genitore: Node3D = null) -> MeshInstance3D:
	var m: MeshInstance3D = MeshInstance3D.new()
	var b: BoxMesh = BoxMesh.new()
	b.size = dim
	m.mesh = b
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = colore
	mat.albedo_texture = _rumore
	mat.uv1_triplanar = true
	mat.roughness = 0.95
	m.material_override = mat
	m.position = pos
	(genitore if genitore != null else self).add_child(m)
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


func _tessera(id: String, truppa: bool, ritardo: float) -> Node3D:
	var radice: Node3D = Node3D.new()
	add_child(radice)
	var misura: Vector2 = MISURA_T if truppa else MISURA_E
	_scatola(Vector3(misura.x + 0.08, 0.06, misura.y + 0.08), Vector3(0.0, 0.03, 0.0), Color("c8834a"), radice)
	_scatola(Vector3(misura.x - 0.06, 0.07, misura.y - 0.06), Vector3(0.0, 0.035, 0.0), Color("1e1712"), radice)
	_scatola(Vector3(misura.x * 0.85, 0.08, 0.3), Vector3(0.0, 0.04, misura.y * 0.25), Color("a42b26") if truppa else Color("c8a032"), radice)
	var alto: float = misura.x * (1.05 if truppa else 0.7)
	var perno: Node3D = Node3D.new()
	perno.position = Vector3(0.0, 0.07, -misura.y * 0.12)
	radice.add_child(perno)
	_quadro(Vector2(alto, alto), immagine("sagome", id), Vector3(0.0, alto * 0.5, 0.0), perno)
	if ritardo > 0.0:
		perno.rotation.x = PI * 0.5
		var t: Tween = create_tween()
		t.tween_interval(ritardo)
		t.tween_property(perno, "rotation:x", 0.0, 0.55).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return radice


func _trama_stendardo() -> ImageTexture:
	var img: Image = Image.create(160, 210, false, Image.FORMAT_RGBA8)
	img.fill(Color("ece2cc"))
	img.fill_rect(Rect2i(0, 0, 160, 26), Color("2f5fb8"))
	for xx: int in range(160):
		var taglio: int = 186 + int(absf(float(xx % 40) - 20.0) * 1.2)
		for yy: int in range(taglio, 210):
			img.set_pixel(xx, yy, Color(0, 0, 0, 0))
	img.generate_mipmaps()
	return ImageTexture.create_from_image(img)


## Lo stendardo con la Resistenza, inclinato verso di te come un leggio.
func _stendardo(pos: Vector3, scala: float) -> void:
	var perno: Node3D = Node3D.new()
	perno.position = pos
	perno.rotation.x = deg_to_rad(-55.0)
	perno.scale = Vector3.ONE * scala
	add_child(perno)
	_quadro(Vector2(1.4, 1.85), _trama_stendardo(), Vector3(0.0, 0.92, 0.0), perno)
	var np: Label3D = scritta("NP\n58", 110, Color("1a1410"), Color(0, 0, 0, 0), 0)
	np.position = Vector3(0.0, 0.95, 0.02)
	perno.add_child(np)


func _sfera(pos: Vector3, colore: Color, raggio: float, accesa: bool) -> void:
	var s: MeshInstance3D = MeshInstance3D.new()
	var sm: SphereMesh = SphereMesh.new()
	sm.radius = raggio
	sm.height = raggio * 2.0
	s.mesh = sm
	var mat: StandardMaterial3D = materiale_luce(colore, 1.5 if accesa else 0.25)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	mat.albedo_color = colore.darkened(0.6)
	s.material_override = mat
	s.position = pos + Vector3(0.0, raggio + 0.05, 0.0)
	add_child(s)


func _intarsio(punti: PackedVector2Array, y: float, colore: Color, bordo: Color) -> void:
	# Un intarsio piatto nella plancia: un poligono con il bordo crema.
	for strato: Array in [[1.08, bordo, 0.0], [1.0, colore, 0.01]]:
		var st: SurfaceTool = SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		var centro: Vector2 = Vector2.ZERO
		for p: Vector2 in punti:
			centro += p
		centro /= float(punti.size())
		for k: int in range(punti.size()):
			var a: Vector2 = centro + (punti[k] - centro) * float(strato[0])
			var b: Vector2 = centro + (punti[(k + 1) % punti.size()] - centro) * float(strato[0])
			for v: Vector2 in [centro, b, a]:
				st.set_normal(Vector3.UP)
				st.add_vertex(Vector3(v.x, y + float(strato[2]), v.y))
		var m: MeshInstance3D = MeshInstance3D.new()
		m.mesh = st.commit()
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.albedo_color = strato[1]
		mat.albedo_texture = _rumore
		mat.uv1_triplanar = true
		mat.roughness = 0.9
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		m.material_override = mat
		add_child(m)


# --- Le tre disposizioni --------------------------------------------------------------

## A: arco sul bordo verso il giocatore.
func _ritratto() -> void:
	var punti: PackedVector2Array = PackedVector2Array()
	for k: int in range(17):
		var a: float = PI + PI * float(k) / 16.0
		punti.append(Vector2(cos(a) * 2.4, 4.9 + sin(a) * 2.6))
	_intarsio(punti, 0.0, Color("2a1d14"), Color("c8a032"))
	_stendardo(Vector3(0.0, 0.05, 3.3), 0.7)
	var colori: Array[Color] = [ROSSO, VERDE, BLU, VIOLA]
	_sfera(Vector3(0.0, 0.0, 4.35), ENERGIA, 0.26, true)
	for k: int in range(4):
		var lato: float = -1.0 if k < 2 else 1.0
		var giro: float = 0.0 if k % 2 == 0 else 1.0
		_sfera(Vector3(lato * (1.15 + giro * 0.55), 0.0, 3.6 + giro * 0.9), colori[k], 0.2, false)


## B: cartiglio ovale fra le due file.
func _cartiglio() -> void:
	var punti: PackedVector2Array = PackedVector2Array()
	for k: int in range(32):
		var a: float = TAU * float(k) / 32.0
		punti.append(Vector2(cos(a) * 3.0, 0.15 + sin(a) * 1.0))
	_intarsio(punti, 0.0, Color("2a1d14"), Color("c8a032"))
	_stendardo(Vector3(0.0, 0.05, 0.25), 0.62)
	_sfera(Vector3(-1.2, 0.0, 0.15), ROSSO, 0.2, false)
	_sfera(Vector3(-2.1, 0.0, 0.15), VERDE, 0.2, false)
	_sfera(Vector3(1.2, 0.0, 0.15), BLU, 0.2, false)
	_sfera(Vector3(2.1, 0.0, 0.15), VIOLA, 0.2, false)
	_sfera(Vector3(0.0, 0.0, 0.95), ENERGIA, 0.22, true)


## C: colonna a forma di scudo che taglia la plancia.
func _colonna() -> void:
	var punti: PackedVector2Array = PackedVector2Array([
		Vector2(-MEZZA_COLONNA, -3.6), Vector2(MEZZA_COLONNA, -3.6), Vector2(MEZZA_COLONNA, 2.9),
		Vector2(0.0, 4.2), Vector2(-MEZZA_COLONNA, 2.9)])
	_intarsio(punti, 0.0, Color("2a1d14"), Color("c8a032"))
	_stendardo(Vector3(0.0, 0.05, -1.6), 0.75)
	_sfera(Vector3(0.0, 0.0, 1.2), ENERGIA, 0.26, true)
	_sfera(Vector3(-0.62, 0.0, 0.55), ROSSO, 0.19, false)
	_sfera(Vector3(0.62, 0.0, 0.55), VERDE, 0.19, false)
	_sfera(Vector3(-0.62, 0.0, 1.85), BLU, 0.19, false)
	_sfera(Vector3(0.62, 0.0, 1.85), VIOLA, 0.19, false)


# --- Disposizione e crescita ------------------------------------------------------------

## Posizioni x delle tessere di una fila. A e B: fila centrata. C: metà a sinistra della colonna,
## metà a destra; la tessera nuova nasce accanto al centro.
func _posizioni(quante: int, passo: float) -> Array[float]:
	var xs: Array[float] = []
	if variante == 2:
		var sinistra: int = quante / 2
		var destra: int = quante - sinistra
		for i: int in range(sinistra):
			xs.append(-MEZZA_COLONNA - 0.25 - (sinistra - i - 0.5) * passo)
		for i: int in range(destra):
			xs.append(MEZZA_COLONNA + 0.25 + (i + 0.5) * passo)
	else:
		for i: int in range(quante):
			xs.append((i - (quante - 1) * 0.5) * passo)
	return xs


func _disponi(durata: float) -> void:
	var xt: Array[float] = _posizioni(_truppe.size(), PASSO_T)
	var xe: Array[float] = _posizioni(_edifici.size(), PASSO_E)
	for i: int in range(_truppe.size()):
		_muovi(_truppe[i], Vector3(xt[i], 0.0, Z_T), durata)
	for i: int in range(_edifici.size()):
		_muovi(_edifici[i], Vector3(xe[i], 0.0, Z_E), durata)
	var mezza: float = maxf(absf(xt[0]) + PASSO_T * 0.5, absf(xe[0]) + PASSO_E * 0.5)
	mezza = maxf(mezza, maxf(absf(xt[xt.size() - 1]) + PASSO_T * 0.5, absf(xe[xe.size() - 1]) + PASSO_E * 0.5)) + 0.7
	mezza = maxf(mezza, 3.6)
	var profondita: float = [10.2, 8.8, 8.6][variante]
	var centro_z: float = [0.35, 0.05, 0.2][variante]
	var b: BoxMesh = _fondo.mesh as BoxMesh
	var lati: Array = [[Vector3(mezza * 2.0 + 0.2, 0.06, 0.16), Vector3(0.0, 0.0, centro_z - profondita * 0.5)],
		[Vector3(mezza * 2.0 + 0.2, 0.06, 0.16), Vector3(0.0, 0.0, centro_z + profondita * 0.5)],
		[Vector3(0.16, 0.06, profondita), Vector3(-mezza, 0.0, centro_z)],
		[Vector3(0.16, 0.06, profondita), Vector3(mezza, 0.0, centro_z)]]
	if durata <= 0.0:
		b.size = Vector3(mezza * 2.0, 0.3, profondita)
		_fondo.position.z = centro_z
		for k: int in range(4):
			(_cornice[k].mesh as BoxMesh).size = lati[k][0]
			_cornice[k].position = lati[k][1]
		return
	var t: Tween = create_tween()
	t.set_parallel(true)
	t.tween_method(func(v: float) -> void: b.size.x = v, b.size.x, mezza * 2.0, durata).set_trans(Tween.TRANS_CUBIC)
	for k: int in range(4):
		var cm: BoxMesh = _cornice[k].mesh as BoxMesh
		t.tween_method(func(v: Vector3) -> void: cm.size = v, cm.size, lati[k][0], durata).set_trans(Tween.TRANS_CUBIC)
		t.tween_property(_cornice[k], "position", lati[k][1], durata).set_trans(Tween.TRANS_CUBIC)


func _muovi(n: Node3D, pos: Vector3, durata: float) -> void:
	if durata <= 0.0:
		n.position = pos
		return
	var t: Tween = create_tween()
	t.tween_property(n, "position", pos, durata).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)


func nuova_truppa() -> void:
	var nuova: Node3D = _tessera(_id_truppe[_truppe.size()], true, 0.55)
	if variante == 2:
		# Nasce accanto alla colonna, dal lato più corto.
		var sinistra: int = (_truppe.size() + 1) / 2
		var indice: int = sinistra - 1 if (_truppe.size() + 1) % 2 == 0 else sinistra
		_truppe.insert(indice, nuova)
	else:
		# Si aggiunge in fondo a destra: la fila si ricentra.
		_truppe.append(nuova)
	var xt: Array[float] = _posizioni(_truppe.size(), PASSO_T)
	nuova.position = Vector3(xt[_truppe.find(nuova)], 0.0, Z_T)
	nuova.scale = Vector3(0.01, 1.0, 0.01)
	var t: Tween = create_tween()
	t.tween_interval(0.2)
	t.tween_property(nuova, "scale", Vector3.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	esplodi(self, nuova.position + Vector3(0.0, 0.5, 0.0), scintille(Color("ffd27a"), 30, 2.2, -2.0, 0.7, 0.07))
	_disponi(0.6)


func nuovo_edificio() -> void:
	var nuovo: Node3D = _tessera(_id_edifici[_edifici.size()], false, 0.55)
	if variante == 2:
		var sinistra: int = (_edifici.size() + 1) / 2
		var indice: int = sinistra - 1 if (_edifici.size() + 1) % 2 == 0 else sinistra
		_edifici.insert(indice, nuovo)
	else:
		_edifici.append(nuovo)
	var xe: Array[float] = _posizioni(_edifici.size(), PASSO_E)
	nuovo.position = Vector3(xe[_edifici.find(nuovo)], 0.0, Z_E)
	nuovo.scale = Vector3(0.01, 1.0, 0.01)
	var t: Tween = create_tween()
	t.tween_interval(0.2)
	t.tween_property(nuovo, "scale", Vector3.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	esplodi(self, nuovo.position + Vector3(0.0, 0.5, 0.0), scintille(Color("ffd27a"), 30, 2.2, -2.0, 0.7, 0.07))
	_disponi(0.6)
