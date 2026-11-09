extends ProvaBase
## Prova della plancia con il cuore della nazione al centro (9 novembre 2026).
## Il cuore è un pezzo compatto, largo poco più di una tessera, che taglia la plancia: in alto lo
## stendardo con la Resistenza, in basso le sfere del mana nelle loro prese d'ottone. Le file di
## truppe ed edifici stanno ai due lati; ogni spazio nuovo nasce accanto al cuore, alternando
## destra e sinistra, e spinge fuori gli altri.

const DURATA_PROVA: float = 11.0
const PASSO_T: float = 1.62
const PASSO_E: float = 2.3
const MISURA_T: Vector2 = Vector2(1.44, 2.16)
const MISURA_E: Vector2 = Vector2(2.13, 1.42)
const Z_T: float = -1.55
const Z_E: float = 1.75
## Mezza larghezza del cuore e distanza fra il cuore e la prima tessera.
const MEZZO_CUORE: float = 0.85
const STACCO: float = 0.3
const PROFONDITA: float = 6.0
const CENTRO_Z: float = -0.08
const LEGNO: Color = Color("4a2f1d")
const LEGNO_SCURO: Color = Color("2a1a10")
const OTTONE: Color = Color("c79a4a")
const CUOIO: Color = Color("2a3f6e")
const CARTA: Color = Color("e6d8b8")

var _camera: Camera3D
var _lanterna: OmniLight3D
var _shader: Shader
var _venatura: NoiseTexture2D
var _grana: NoiseTexture2D
var _truppe: Array[Node3D] = []
var _edifici: Array[Node3D] = []
var _id_truppe: Array[String] = ["c8716e", "278014", "862b2d", "a4648d", "640641", "43a388", "ec7124"]
var _id_edifici: Array[String] = ["d61645", "19632f", "9928f9", "5066f4", "62b753"]
var _piano: MeshInstance3D
var _bordo: Array[MeshInstance3D] = []
var _sfere: Array[MeshInstance3D] = []
var _foto: String = ""


func _ready() -> void:
	_font = load("res://font/BarlowSemiCondensed-ExtraBold.ttf") as FontFile
	_font_testo = load("res://font/Barlow-SemiBold.ttf") as FontFile
	var argomenti: PackedStringArray = OS.get_cmdline_user_args()
	if argomenti.size() > 0:
		_foto = argomenti[0]
	costruisci()
	_passi = [[3.0, "nuova_truppa", []], [5.0, "nuova_truppa", []], [7.0, "nuovo_edificio", []], [8.6, "nuovo_edificio", []]]


func _process(delta: float) -> void:
	tempo += delta
	while _indice < _passi.size() and float(_passi[_indice][0]) <= tempo:
		var passo: Array = _passi[_indice]
		_indice += 1
		callv(String(passo[1]), passo[2])
	_lanterna.position.x = sin(tempo * 0.5) * 2.5
	_lanterna.light_energy = 3.6 + sin(tempo * 13.0) * 0.08
	for k: int in range(_sfere.size()):
		_sfere[k].position.y = _sfere[k].get_meta("y") + sin(tempo * 2.0 + k) * 0.02
	if _foto != "" and tempo >= 2.0:
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
	_camera.look_at_from_position(Vector3(0.0, 13.0, 11.6), Vector3(0.0, 0.0, -0.1), Vector3.UP)
	_lanterna = OmniLight3D.new()
	_lanterna.light_color = Color("ffb877")
	_lanterna.light_energy = 3.6
	_lanterna.omni_range = 40.0
	_lanterna.omni_attenuation = 1.1
	_lanterna.shadow_enabled = true
	_lanterna.position = Vector3(0.0, 10.0, 5.0)
	add_child(_lanterna)
	var riempi: DirectionalLight3D = DirectionalLight3D.new()
	riempi.light_color = Color("ffe6c8")
	riempi.light_energy = 0.45
	riempi.rotation_degrees = Vector3(-55.0, -30.0, 0.0)
	add_child(riempi)
	var fredda: DirectionalLight3D = DirectionalLight3D.new()
	fredda.light_color = Color("8aa0d8")
	fredda.light_energy = 0.3
	fredda.rotation_degrees = Vector3(-25.0, 160.0, 0.0)
	add_child(fredda)
	_scatola(Vector3(80.0, 0.2, 60.0), Vector3(0.0, -0.6, 0.0), Color("140f12"), _grana, 0.95)

	# La plancia: legno con la venatura e un bordo d'ottone sottile.
	_piano = _scatola(Vector3(10.0, 0.36, PROFONDITA), Vector3(0.0, -0.18, CENTRO_Z), LEGNO, _venatura, 0.6)
	for k: int in range(4):
		_bordo.append(_scatola(Vector3.ONE, Vector3.ZERO, OTTONE, null, 0.35, 0.8))
	_crea_cuore()
	for i: int in range(4):
		_truppe.append(_tessera(_id_truppe[i], true, 0.0))
	for i: int in range(3):
		_edifici.append(_tessera(_id_edifici[i], false, 0.0))
	_disponi(0.0)
	strato_grana(0.03, "Prova della plancia: il cuore della nazione al centro — tessere e disegni messi a caso")


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


func _scatola(dim: Vector3, pos: Vector3, colore: Color, trama: Texture2D = null, ruvido: float = 0.8, metallo: float = 0.0, genitore: Node3D = null) -> MeshInstance3D:
	var m: MeshInstance3D = MeshInstance3D.new()
	var b: BoxMesh = BoxMesh.new()
	b.size = dim
	m.mesh = b
	m.material_override = _materiale(colore, trama, ruvido, metallo)
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


## Una tessera: carta color crema posata in un incavo scuro del legno.
func _tessera(id: String, truppa: bool, ritardo: float) -> Node3D:
	var radice: Node3D = Node3D.new()
	add_child(radice)
	var misura: Vector2 = MISURA_T if truppa else MISURA_E
	_scatola(Vector3(misura.x + 0.12, 0.02, misura.y + 0.12), Vector3(0.0, 0.0, 0.0), LEGNO_SCURO, _venatura, 0.7, 0.0, radice)
	_scatola(Vector3(misura.x - 0.02, 0.05, misura.y - 0.02), Vector3(0.0, 0.025, 0.0), CARTA, _grana, 0.95, 0.0, radice)
	# Finestra dell'illustrazione e nastrino del tipo in fondo.
	_scatola(Vector3(misura.x - 0.22, 0.055, misura.y * 0.62), Vector3(0.0, 0.03, -misura.y * 0.1), Color("2b211b"), _grana, 0.9, 0.0, radice)
	_scatola(Vector3(misura.x * 0.5, 0.056, 0.12), Vector3(0.0, 0.03, misura.y * 0.36), Color("8e2a24") if truppa else Color("9a7a2a"), null, 0.8, 0.0, radice)
	var alto: float = misura.x * (1.05 if truppa else 0.68)
	var perno: Node3D = Node3D.new()
	perno.position = Vector3(0.0, 0.06, -misura.y * 0.12)
	radice.add_child(perno)
	_quadro(Vector2(alto, alto), immagine("sagome", id), Vector3(0.0, alto * 0.5, 0.0), perno)
	if ritardo > 0.0:
		perno.rotation.x = PI * 0.5
		var t: Tween = create_tween()
		t.tween_interval(ritardo)
		t.tween_property(perno, "rotation:x", 0.0, 0.55).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return radice


## Una placca sagomata a otto lati (angoli smussati), spessa "alto", con la faccia in cima a quota y.
func _placca(genitore: Node3D, centro: Vector3, misura: Vector2, smusso: float, alto: float, colore: Color, trama: Texture2D, ruvido: float, metallo: float) -> void:
	var w: float = misura.x * 0.5
	var d: float = misura.y * 0.5
	var c: float = smusso
	var forma: CSGPolygon3D = CSGPolygon3D.new()
	forma.polygon = PackedVector2Array([Vector2(-w + c, -d), Vector2(w - c, -d), Vector2(w, -d + c), Vector2(w, d - c),
		Vector2(w - c, d), Vector2(-w + c, d), Vector2(-w, d - c), Vector2(-w, -d + c)])
	forma.depth = alto
	forma.material = _materiale(colore, trama, ruvido, metallo)
	forma.rotation.x = -PI * 0.5
	forma.position = centro
	genitore.add_child(forma)


## Il cuore della nazione: due placche sagomate, una per fila, unite da una barretta d'ottone.
## Sulla fila delle truppe lo stendardo con la Resistenza; sulla fila degli edifici, che producono
## il mana, le sfere nelle loro prese.
func _crea_cuore() -> void:
	var cuore: Node3D = Node3D.new()
	add_child(cuore)
	var largo: float = MEZZO_CUORE * 2.0
	var misure: Array[Vector2] = [Vector2(largo, MISURA_T.y + 0.1), Vector2(largo, MISURA_E.y + 0.2)]
	var zs: Array[float] = [Z_T, Z_E]
	for k: int in range(2):
		var c: Vector3 = Vector3(0.0, 0.0, zs[k])
		_placca(cuore, c + Vector3(0.0, 0.1, 0.0), misure[k] + Vector2(0.1, 0.1), 0.34, 0.12, LEGNO_SCURO, _venatura, 0.5, 0.0)
		_placca(cuore, c + Vector3(0.0, 0.15, 0.0), misure[k] - Vector2(0.04, 0.04), 0.3, 0.08, OTTONE, null, 0.3, 0.85)
		_placca(cuore, c + Vector3(0.0, 0.16, 0.0), misure[k] - Vector2(0.2, 0.2), 0.24, 0.08, CUOIO, _grana, 0.75, 0.0)
		# Filetto d'ottone inciso dentro il cuoio.
		_placca(cuore, c + Vector3(0.0, 0.165, 0.0), misure[k] - Vector2(0.34, 0.34), 0.18, 0.06, OTTONE.darkened(0.15), null, 0.35, 0.8)
		_placca(cuore, c + Vector3(0.0, 0.17, 0.0), misure[k] - Vector2(0.4, 0.4), 0.15, 0.06, CUOIO, _grana, 0.75, 0.0)
	# La barretta che unisce le due placche.
	var z0: float = Z_T + misure[0].y * 0.5
	var z1: float = Z_E - misure[1].y * 0.5
	for x: float in [-0.18, 0.18]:
		var barra: MeshInstance3D = MeshInstance3D.new()
		var cb: CylinderMesh = CylinderMesh.new()
		cb.top_radius = 0.045
		cb.bottom_radius = 0.045
		cb.height = z1 - z0 + 0.2
		barra.mesh = cb
		barra.material_override = _materiale(OTTONE, null, 0.3, 0.85)
		barra.rotation.x = PI * 0.5
		barra.position = Vector3(x, 0.1, (z0 + z1) * 0.5)
		cuore.add_child(barra)
	# Lo stendardo in piedi sulla placca delle truppe.
	var oro: StandardMaterial3D = _materiale(OTTONE, null, 0.3, 0.85)
	var stendardo: Node3D = Node3D.new()
	stendardo.position = Vector3(0.0, 0.17, Z_T + 0.55)
	stendardo.rotation.x = deg_to_rad(-22.0)
	cuore.add_child(stendardo)
	var asta: MeshInstance3D = MeshInstance3D.new()
	var ca: CylinderMesh = CylinderMesh.new()
	ca.top_radius = 0.03
	ca.bottom_radius = 0.04
	ca.height = 1.85
	asta.mesh = ca
	asta.material_override = oro
	asta.position = Vector3(0.0, 0.92, -0.04)
	stendardo.add_child(asta)
	var traversa: MeshInstance3D = MeshInstance3D.new()
	var ct: CylinderMesh = CylinderMesh.new()
	ct.top_radius = 0.028
	ct.bottom_radius = 0.028
	ct.height = 1.26
	traversa.mesh = ct
	traversa.material_override = oro
	traversa.rotation.z = PI * 0.5
	traversa.position = Vector3(0.0, 1.66, -0.02)
	stendardo.add_child(traversa)
	for x: float in [-0.66, 0.66]:
		var pomo: MeshInstance3D = MeshInstance3D.new()
		var sp: SphereMesh = SphereMesh.new()
		sp.radius = 0.055
		sp.height = 0.11
		pomo.mesh = sp
		pomo.material_override = oro
		pomo.position = Vector3(x, 1.66, -0.02)
		stendardo.add_child(pomo)
	var punta: MeshInstance3D = MeshInstance3D.new()
	var cp: CylinderMesh = CylinderMesh.new()
	cp.top_radius = 0.0
	cp.bottom_radius = 0.07
	cp.height = 0.2
	punta.mesh = cp
	punta.material_override = oro
	punta.position = Vector3(0.0, 1.92, -0.04)
	stendardo.add_child(punta)
	# Il drappo: crema con la fascia del colore della nazione e la coda a punte.
	var img: Image = Image.create(160, 200, false, Image.FORMAT_RGBA8)
	img.fill(Color("ece2cc"))
	img.fill_rect(Rect2i(0, 0, 160, 24), CUOIO.lightened(0.1))
	img.fill_rect(Rect2i(0, 24, 160, 3), Color("c8a46a"))
	img.fill_rect(Rect2i(0, 0, 4, 200), Color("c8b48e"))
	img.fill_rect(Rect2i(156, 0, 4, 200), Color("c8b48e"))
	for xx: int in range(160):
		var taglio: int = 168 + int(absf(float(xx % 53) - 26.5) * 1.2)
		for yy: int in range(taglio, 200):
			img.set_pixel(xx, yy, Color(0, 0, 0, 0))
	img.generate_mipmaps()
	_quadro(Vector2(1.18, 1.48), ImageTexture.create_from_image(img), Vector3(0.0, 0.9, 0.0), stendardo)
	var iniziali: Label3D = scritta("NP", 56, Color("ece2cc"), Color(0, 0, 0, 0), 0)
	iniziali.position = Vector3(0.0, 1.565, 0.01)
	stendardo.add_child(iniziali)
	var numero: Label3D = scritta("58", 130, Color("1a1410"), Color(0, 0, 0, 0), 0)
	numero.position = Vector3(0.0, 0.98, 0.01)
	stendardo.add_child(numero)
	var dicitura: Label3D = scritta("RESISTENZA", 26, Color("6a5440"), Color(0, 0, 0, 0), 0, true)
	dicitura.position = Vector3(0.0, 0.62, 0.01)
	stendardo.add_child(dicitura)
	# Le sfere del mana nelle prese d'ottone: la gialla al centro, le altre a croce.
	var centro: Vector3 = Vector3(0.0, 0.17, Z_E)
	_presa(cuore, centro, ENERGIA, 0.21, 2)
	var colori: Array[Color] = [ROSSO, VERDE, BLU, VIOLA]
	var punti: Array[Vector3] = [Vector3(0.0, 0.0, -0.48), Vector3(0.48, 0.0, 0.0), Vector3(0.0, 0.0, 0.48), Vector3(-0.48, 0.0, 0.0)]
	var quanti: Array[int] = [1, 0, 0, 3]
	for k: int in range(4):
		_presa(cuore, centro + punti[k], colori[k], 0.13, quanti[k])


func _presa(genitore: Node3D, pos: Vector3, colore: Color, raggio: float, quanti: int) -> void:
	var anello: MeshInstance3D = MeshInstance3D.new()
	var t: TorusMesh = TorusMesh.new()
	t.inner_radius = raggio * 0.95
	t.outer_radius = raggio * 1.28
	t.rings = 24
	t.ring_segments = 8
	anello.mesh = t
	anello.material_override = _materiale(OTTONE, null, 0.28, 0.9)
	anello.position = pos + Vector3(0.0, 0.03, 0.0)
	genitore.add_child(anello)
	var sfera: MeshInstance3D = MeshInstance3D.new()
	var s: SphereMesh = SphereMesh.new()
	s.radius = raggio
	s.height = raggio * 2.0
	s.radial_segments = 32
	s.rings = 16
	sfera.mesh = s
	var m: StandardMaterial3D = StandardMaterial3D.new()
	m.albedo_color = colore.darkened(0.75) if quanti == 0 else colore.darkened(0.2)
	m.metallic_specular = 0.9
	m.roughness = 0.08
	m.rim_enabled = true
	m.rim = 0.6
	m.rim_tint = 0.5
	m.emission_enabled = true
	m.emission = colore
	m.emission_energy_multiplier = 0.12 if quanti == 0 else 1.6 + quanti * 0.4
	sfera.material_override = m
	sfera.position = pos + Vector3(0.0, raggio * 0.7, 0.0)
	sfera.set_meta("y", sfera.position.y)
	genitore.add_child(sfera)
	_sfere.append(sfera)
	if quanti > 0:
		var luce: OmniLight3D = OmniLight3D.new()
		luce.light_color = colore
		luce.light_energy = 0.8
		luce.omni_range = 1.4
		sfera.add_child(luce)
		var n: Label3D = scritta(str(quanti), 56, Color("ece2cc"), colore.darkened(0.7), 10)
		n.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		n.position = Vector3(raggio + 0.12, raggio + 0.05, 0.0)
		n.no_depth_test = true
		sfera.add_child(n)


# --- Disposizione e crescita ---------------------------------------------------------------

func _posizioni(quante: int, passo: float) -> Array[float]:
	var xs: Array[float] = []
	var sinistra: int = quante / 2
	var destra: int = quante - sinistra
	for i: int in range(sinistra):
		xs.append(-MEZZO_CUORE - STACCO - (sinistra - i - 0.5) * passo)
	for i: int in range(destra):
		xs.append(MEZZO_CUORE + STACCO + (i + 0.5) * passo)
	return xs


func _disponi(durata: float) -> void:
	var xt: Array[float] = _posizioni(_truppe.size(), PASSO_T)
	var xe: Array[float] = _posizioni(_edifici.size(), PASSO_E)
	for i: int in range(_truppe.size()):
		_muovi(_truppe[i], Vector3(xt[i], 0.0, Z_T), durata)
	for i: int in range(_edifici.size()):
		_muovi(_edifici[i], Vector3(xe[i], 0.0, Z_E), durata)
	var mezza: float = 0.0
	for x: float in xt:
		mezza = maxf(mezza, absf(x) + PASSO_T * 0.5)
	for x: float in xe:
		mezza = maxf(mezza, absf(x) + PASSO_E * 0.5)
	mezza += 0.3
	var b: BoxMesh = _piano.mesh as BoxMesh
	var lati: Array = [[Vector3(mezza * 2.0 + 0.12, 0.08, 0.1), Vector3(0.0, 0.02, CENTRO_Z - PROFONDITA * 0.5)],
		[Vector3(mezza * 2.0 + 0.12, 0.08, 0.1), Vector3(0.0, 0.02, CENTRO_Z + PROFONDITA * 0.5)],
		[Vector3(0.1, 0.08, PROFONDITA), Vector3(-mezza, 0.02, CENTRO_Z)],
		[Vector3(0.1, 0.08, PROFONDITA), Vector3(mezza, 0.02, CENTRO_Z)]]
	if durata <= 0.0:
		b.size.x = mezza * 2.0
		for k: int in range(4):
			(_bordo[k].mesh as BoxMesh).size = lati[k][0]
			_bordo[k].position = lati[k][1]
		return
	var t: Tween = create_tween()
	t.set_parallel(true)
	t.tween_method(func(v: float) -> void: b.size.x = v, b.size.x, mezza * 2.0, durata).set_trans(Tween.TRANS_CUBIC)
	for k: int in range(4):
		var bm: BoxMesh = _bordo[k].mesh as BoxMesh
		t.tween_method(func(v: Vector3) -> void: bm.size = v, bm.size, lati[k][0], durata).set_trans(Tween.TRANS_CUBIC)
		t.tween_property(_bordo[k], "position", lati[k][1], durata).set_trans(Tween.TRANS_CUBIC)


func _muovi(n: Node3D, pos: Vector3, durata: float) -> void:
	if durata <= 0.0:
		n.position = pos
		return
	var t: Tween = create_tween()
	t.tween_property(n, "position", pos, durata).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)


## Lo spazio nuovo nasce accanto al cuore, dal lato più corto, e spinge fuori gli altri.
func _inserisci(fila: Array[Node3D], nuova: Node3D, passo: float, z: float) -> void:
	var sinistra_dopo: int = (fila.size() + 1) / 2
	var indice: int = sinistra_dopo - 1 if (fila.size() + 1) % 2 == 0 else sinistra_dopo
	fila.insert(indice, nuova)
	var xs: Array[float] = _posizioni(fila.size(), passo)
	nuova.position = Vector3(xs[indice], 0.0, z)
	nuova.scale = Vector3(0.01, 1.0, 0.01)
	var t: Tween = create_tween()
	t.tween_interval(0.25)
	t.tween_property(nuova, "scale", Vector3.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	esplodi(self, nuova.position + Vector3(0.0, 0.4, 0.0), scintille(Color("ffd27a"), 30, 2.0, -2.0, 0.7, 0.06))
	_disponi(0.6)


func nuova_truppa() -> void:
	_inserisci(_truppe, _tessera(_id_truppe[_truppe.size()], true, 0.55), PASSO_T, Z_T)


func nuovo_edificio() -> void:
	_inserisci(_edifici, _tessera(_id_edifici[_edifici.size()], false, 0.55), PASSO_E, Z_E)
