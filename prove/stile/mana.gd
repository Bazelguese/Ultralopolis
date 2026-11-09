extends ProvaBase
## Prove del mana (8 novembre 2026): tre modi di mostrare la riserva di mana nel teatro di carta.
## 0 = Ghirlanda di lanterne, 1 = Gru di carta, 2 = Rosone.
## Scena finta: un edificio produce, una truppa spende. Solo aspetto e animazione.

@export var variante: int = 0

const TITOLI: Array[String] = ["A · Ghirlanda di lanterne", "B · Gru di carta", "C · Rosone di vetro colorato"]
const DESCRIZIONI: Array[String] = [
	"Ogni mana accende una lanterna di carta del suo colore sulla ghirlanda: si contano le lanterne accese.",
	"Ogni mana è una gru di carta che vola dall'edificio e si posa sul filo: la truppa la richiama per spenderla.",
	"Ogni colore è un petalo del rosone: si accende a spicchi, e proietta la sua luce colorata sul tavolo.",
]
const DURATA_PROVA: float = 9.0

var _camera: Camera3D
var _lanterna: OmniLight3D
var _edificio: Node3D
var _truppa: Node3D
var _mat_truppa: ShaderMaterial
var _rumore: NoiseTexture2D
var _shader: Shader
# Ghirlanda
var _lanterne: Array = []
# Gru
var _filo_gru: Array = []
var _gru_posate: Array = []
# Rosone
var _spicchi: Array = []
var _luce_rosone: OmniLight3D
var _rosone: Node3D

## Ordine dei mana prodotti nella prova (indice in COLORI_MANA).
const PRODUZIONE: Array[int] = [0, 1, 0, 2, 4, 0, 3]


func _ready() -> void:
	_font = load("res://font/BarlowSemiCondensed-ExtraBold.ttf") as FontFile
	_font_testo = load("res://font/Barlow-SemiBold.ttf") as FontFile
	costruisci()
	var t: float = 0.9
	for c: int in PRODUZIONE:
		_passi.append([t, "produci", [0, c]])
		t += 0.55
	_passi.append([t + 0.5, "spendi", [0, 0, 0, 2]])
	_passi.append([t + 2.0, "spendi", [0, 0, 1, 1]])


func _process(delta: float) -> void:
	tempo += delta
	while _indice < _passi.size() and float(_passi[_indice][0]) <= tempo:
		var passo: Array = _passi[_indice]
		_indice += 1
		callv(String(passo[1]), passo[2])
	aggiorna(delta)
	if tempo >= DURATA_PROVA:
		get_tree().quit()


func costruisci() -> void:
	_shader = Shader.new()
	_shader.code = """
shader_type spatial;
render_mode cull_disabled, depth_draw_opaque;
uniform sampler2D tex : source_color, filter_linear_mipmap;
uniform float lampo = 0.0;
void fragment() {
	vec4 c = texture(tex, UV);
	ALBEDO = c.rgb;
	EMISSION = c.rgb * lampo;
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
	amb.background_color = Color("040302")
	amb.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	amb.ambient_light_color = Color("3a2c3c")
	amb.ambient_light_energy = 0.4
	amb.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	amb.glow_enabled = true
	amb.glow_intensity = 0.9
	amb.glow_bloom = 0.1
	var we: WorldEnvironment = WorldEnvironment.new()
	we.environment = amb
	add_child(we)
	_camera = Camera3D.new()
	_camera.fov = 38.0
	add_child(_camera)
	_camera.look_at_from_position(Vector3(0.4, 5.4, 9.4), Vector3(0.4, 1.9, 0.0), Vector3.UP)
	_lanterna = OmniLight3D.new()
	_lanterna.light_color = Color("ffb067")
	_lanterna.light_energy = 2.4
	_lanterna.omni_range = 26.0
	_lanterna.shadow_enabled = true
	_lanterna.position = Vector3(1.0, 7.0, 5.0)
	add_child(_lanterna)

	var tavolo: MeshInstance3D = MeshInstance3D.new()
	var bt: BoxMesh = BoxMesh.new()
	bt.size = Vector3(40.0, 0.2, 30.0)
	tavolo.mesh = bt
	var mt: StandardMaterial3D = StandardMaterial3D.new()
	mt.albedo_color = Color("3d2f22")
	mt.albedo_texture = _rumore
	mt.uv1_triplanar = true
	mt.roughness = 0.95
	tavolo.material_override = mt
	tavolo.position.y = -0.1
	add_child(tavolo)

	_edificio = _sagoma("9928f9", Vector3(-3.4, 0.0, 1.0), 2.4)
	var dati_truppa: Array = _sagoma_mat("c8716e", Vector3(3.6, 0.0, 1.2), 2.6)
	_truppa = dati_truppa[0]
	_mat_truppa = dati_truppa[1]
	var e: Label3D = scritta("EDIFICIO", 50, Color("ece2cc"), Color.BLACK, 10)
	e.position = Vector3(-3.4, 0.05, 2.2)
	e.rotation.x = -PI * 0.5
	add_child(e)
	var tr: Label3D = scritta("TRUPPA", 50, Color("ece2cc"), Color.BLACK, 10)
	tr.position = Vector3(3.6, 0.05, 2.4)
	tr.rotation.x = -PI * 0.5
	add_child(tr)

	match variante:
		0: _crea_ghirlanda()
		1: _crea_filo_gru()
		2: _crea_rosone()

	var strato: CanvasLayer = CanvasLayer.new()
	strato.layer = 2
	add_child(strato)
	var titolo: Label = Label.new()
	titolo.text = TITOLI[variante]
	titolo.add_theme_font_override("font", _font)
	titolo.add_theme_font_size_override("font_size", 64)
	titolo.add_theme_color_override("font_color", Color("ece2cc"))
	titolo.position = Vector2(56, 40)
	strato.add_child(titolo)
	var spiega: Label = Label.new()
	spiega.text = DESCRIZIONI[variante]
	spiega.add_theme_font_override("font", _font_testo)
	spiega.add_theme_font_size_override("font_size", 28)
	spiega.add_theme_color_override("font_color", Color("cdbd9c"))
	spiega.position = Vector2(58, 122)
	strato.add_child(spiega)
	strato_grana(0.04, "Prova del mana — scena finta, solo per vedere aspetto e animazioni")


func _sagoma(id: String, pos: Vector3, altezza: float) -> Node3D:
	return _sagoma_mat(id, pos, altezza)[0]


func _sagoma_mat(id: String, pos: Vector3, altezza: float) -> Array:
	var perno: Node3D = Node3D.new()
	perno.position = pos
	add_child(perno)
	var q: QuadMesh = QuadMesh.new()
	q.size = Vector2(altezza, altezza)
	var mi: MeshInstance3D = MeshInstance3D.new()
	mi.mesh = q
	mi.position.y = altezza * 0.5
	var m: ShaderMaterial = ShaderMaterial.new()
	m.shader = _shader
	m.set_shader_parameter("tex", immagine("sagome", id))
	mi.material_override = m
	perno.add_child(mi)
	return [perno, m]


func _vola(da: Vector3, a: Vector3, colore: Color, durata: float, arco: float, fine: Callable) -> void:
	var p: MeshInstance3D = MeshInstance3D.new()
	var s: SphereMesh = SphereMesh.new()
	s.radius = 0.07
	s.height = 0.14
	p.mesh = s
	p.material_override = materiale_luce(colore, 8.0)
	add_child(p)
	var scia: CPUParticles3D = scintille(colore, 50, 0.3, 0.3, 0.5, 0.07)
	scia.one_shot = false
	scia.explosiveness = 0.0
	scia.local_coords = false
	p.add_child(scia)
	scia.emitting = true
	var alto: Vector3 = (da + a) * 0.5 + Vector3(0.0, arco, 0.0)
	var t: Tween = create_tween()
	t.tween_method(func(k: float) -> void:
		p.position = da.lerp(alto, k).lerp(alto.lerp(a, k), k), 0.0, 1.0, durata).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_callback(func() -> void:
		scia.emitting = false
		p.mesh = null
		fine.call())
	t.tween_interval(0.6)
	t.tween_callback(p.queue_free)


func _lampo_truppa() -> void:
	var t: Tween = create_tween()
	t.tween_method(func(v: float) -> void: _mat_truppa.set_shader_parameter("lampo", v), 1.2, 0.0, 0.5)
	var b: Tween = create_tween()
	b.tween_property(_truppa, "rotation:x", -0.35, 0.09)
	b.tween_property(_truppa, "rotation:x", 0.0, 0.4).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


func aggiorna(_delta: float) -> void:
	_lanterna.light_energy = 2.4 + sin(tempo * 13.0) * 0.1
	match variante:
		0:
			for k: int in range(_lanterne.size()):
				var l: Dictionary = _lanterne[k]
				(l["nodo"] as Node3D).rotation.z = sin(tempo * 1.6 + k * 0.7) * 0.08
		1:
			for g: Node3D in _gru_posate:
				if is_instance_valid(g):
					g.rotation.y = sin(tempo * 2.0 + g.position.x) * 0.15
		2:
			_rosone.rotation.z = sin(tempo * 0.4) * 0.03


func produci(_lato: int, colore: int) -> void:
	var da: Vector3 = _edificio.position + Vector3(0.0, 1.8, 0.0)
	var t: Tween = create_tween()
	t.tween_property(_edificio, "scale", Vector3.ONE * 1.06, 0.07)
	t.tween_property(_edificio, "scale", Vector3.ONE, 0.12)
	match variante:
		0: _produci_lanterna(da, colore)
		1: _produci_gru(da, colore)
		2: _produci_rosone(da, colore)


func spendi(_lato: int, _truppa_i: int, colore: int, quanti: int) -> void:
	for k: int in range(quanti):
		var t: Tween = create_tween()
		t.tween_interval(k * 0.25)
		match variante:
			0: t.tween_callback(_spendi_lanterna.bind(colore))
			1: t.tween_callback(_spendi_gru.bind(colore))
			2: t.tween_callback(_spendi_rosone.bind(colore))
	var lampo: Tween = create_tween()
	lampo.tween_interval(0.25 * quanti + 0.5)
	lampo.tween_callback(_lampo_truppa)


# --- A: ghirlanda di lanterne ---------------------------------------------------------

func _crea_ghirlanda() -> void:
	var punti: int = 9
	var filo: Array = []
	for k: int in range(punti):
		var x: float = -2.6 + k * 0.72
		var y: float = 3.1 - sin(float(k) / float(punti - 1) * PI) * 0.55
		filo.append(Vector3(x, y, -0.6))
	# Il filo.
	for k: int in range(punti - 1):
		var tratto: MeshInstance3D = MeshInstance3D.new()
		var c: CylinderMesh = CylinderMesh.new()
		c.top_radius = 0.012
		c.bottom_radius = 0.012
		c.height = (filo[k + 1] as Vector3).distance_to(filo[k])
		tratto.mesh = c
		var mf: StandardMaterial3D = StandardMaterial3D.new()
		mf.albedo_color = Color("1a1410")
		tratto.material_override = mf
		add_child(tratto)
		tratto.position = ((filo[k] as Vector3) + (filo[k + 1] as Vector3)) * 0.5
		tratto.look_at(filo[k + 1], Vector3.UP)
		tratto.rotate_object_local(Vector3.RIGHT, PI * 0.5)
	for k: int in range(punti):
		var nodo: Node3D = Node3D.new()
		nodo.position = filo[k]
		add_child(nodo)
		var corpo: MeshInstance3D = MeshInstance3D.new()
		var cm: CylinderMesh = CylinderMesh.new()
		cm.top_radius = 0.17
		cm.bottom_radius = 0.19
		cm.height = 0.42
		cm.radial_segments = 10
		corpo.mesh = cm
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.albedo_color = Color("ece2cc")
		mat.emission_enabled = true
		mat.emission = Color.BLACK
		mat.roughness = 0.9
		corpo.material_override = mat
		corpo.position.y = -0.3
		nodo.add_child(corpo)
		for anello: float in [-0.1, -0.5]:
			var a: MeshInstance3D = MeshInstance3D.new()
			var am: CylinderMesh = CylinderMesh.new()
			am.top_radius = 0.2
			am.bottom_radius = 0.2
			am.height = 0.04
			a.mesh = am
			var ma: StandardMaterial3D = StandardMaterial3D.new()
			ma.albedo_color = Color("1a1410")
			a.material_override = ma
			a.position.y = anello
			nodo.add_child(a)
		var luce: OmniLight3D = OmniLight3D.new()
		luce.light_energy = 0.0
		luce.omni_range = 2.2
		luce.position.y = -0.3
		nodo.add_child(luce)
		_lanterne.append({"nodo": nodo, "mat": mat, "luce": luce, "colore": -1})


func _produci_lanterna(da: Vector3, colore: int) -> void:
	var libera: int = -1
	for k: int in range(_lanterne.size()):
		if int(_lanterne[k]["colore"]) == -1:
			libera = k
			break
	if libera < 0:
		return
	_lanterne[libera]["colore"] = colore
	var l: Dictionary = _lanterne[libera]
	var arrivo: Vector3 = (l["nodo"] as Node3D).position + Vector3(0.0, -0.3, 0.0)
	_vola(da, arrivo, COLORI_MANA[colore], 0.6, 1.0, func() -> void:
		var mat: StandardMaterial3D = l["mat"]
		var luce: OmniLight3D = l["luce"]
		luce.light_color = COLORI_MANA[colore]
		var t: Tween = create_tween()
		t.set_parallel(true)
		t.tween_property(mat, "emission", COLORI_MANA[colore], 0.15)
		t.tween_property(mat, "emission_energy_multiplier", 2.2, 0.15)
		t.tween_property(luce, "light_energy", 1.4, 0.2)
		var nodo: Node3D = l["nodo"]
		nodo.scale = Vector3.ONE * 1.35
		t.tween_property(nodo, "scale", Vector3.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		esplodi(self, arrivo, scintille(COLORI_MANA[colore], 20, 1.5, -1.0, 0.6, 0.05)))


func _spendi_lanterna(colore: int) -> void:
	for k: int in range(_lanterne.size() - 1, -1, -1):
		var l: Dictionary = _lanterne[k]
		if int(l["colore"]) == colore:
			l["colore"] = -1
			var mat: StandardMaterial3D = l["mat"]
			var luce: OmniLight3D = l["luce"]
			var t: Tween = create_tween()
			t.set_parallel(true)
			t.tween_property(mat, "emission", Color.BLACK, 0.3)
			t.tween_property(luce, "light_energy", 0.0, 0.3)
			var da: Vector3 = (l["nodo"] as Node3D).position + Vector3(0.0, -0.3, 0.0)
			_vola(da, _truppa.position + Vector3(0.0, 1.6, 0.0), COLORI_MANA[colore], 0.45, 0.4, func() -> void:
				esplodi(self, _truppa.position + Vector3(0.0, 1.6, 0.2), scintille(COLORI_MANA[colore], 30, 2.5, -2.0, 0.6, 0.06)))
			return


# --- B: gru di carta ----------------------------------------------------------------

func _crea_filo_gru() -> void:
	var asta: MeshInstance3D = MeshInstance3D.new()
	var b: BoxMesh = BoxMesh.new()
	b.size = Vector3(5.6, 0.06, 0.06)
	asta.mesh = b
	var m: StandardMaterial3D = StandardMaterial3D.new()
	m.albedo_color = Color("2a1d12")
	asta.material_override = m
	asta.position = Vector3(0.3, 2.6, -0.6)
	add_child(asta)
	for x: float in [-2.45, 3.05]:
		var palo: MeshInstance3D = MeshInstance3D.new()
		var c: CylinderMesh = CylinderMesh.new()
		c.top_radius = 0.04
		c.bottom_radius = 0.05
		c.height = 2.6
		palo.mesh = c
		palo.material_override = m
		palo.position = Vector3(x, 1.3, -0.6)
		add_child(palo)
	for k: int in range(8):
		_filo_gru.append({"pos": Vector3(-2.0 + k * 0.66, 2.66, -0.6), "gru": null, "colore": -1})


## Una gru di carta: corpo a prisma, collo e coda a punta, due ali che sbattono.
func _gru(colore: Color) -> Node3D:
	var gru: Node3D = Node3D.new()
	var carta: StandardMaterial3D = StandardMaterial3D.new()
	carta.albedo_color = colore
	carta.cull_mode = BaseMaterial3D.CULL_DISABLED
	carta.roughness = 0.7
	carta.emission_enabled = true
	carta.emission = colore
	carta.emission_energy_multiplier = 0.35
	var piega: StandardMaterial3D = carta.duplicate() as StandardMaterial3D
	piega.albedo_color = colore.darkened(0.35)
	var corpo: MeshInstance3D = MeshInstance3D.new()
	corpo.mesh = _triangoli([Vector3(-0.22, 0.0, 0.0), Vector3(0.22, 0.0, 0.0), Vector3(0.0, 0.16, 0.0), Vector3(0.0, -0.02, 0.1), Vector3(0.0, -0.02, -0.1)], [[0, 2, 3], [1, 2, 3], [0, 2, 4], [1, 2, 4]])
	corpo.material_override = carta
	gru.add_child(corpo)
	var collo: MeshInstance3D = MeshInstance3D.new()
	collo.mesh = _triangoli([Vector3(0.2, 0.02, 0.0), Vector3(0.42, 0.32, 0.0), Vector3(0.24, 0.0, 0.02)], [[0, 1, 2]])
	collo.material_override = piega
	gru.add_child(collo)
	var coda: MeshInstance3D = MeshInstance3D.new()
	coda.mesh = _triangoli([Vector3(-0.2, 0.02, 0.0), Vector3(-0.42, 0.26, 0.0), Vector3(-0.24, 0.0, 0.02)], [[0, 1, 2]])
	coda.material_override = piega
	gru.add_child(coda)
	for lato: float in [1.0, -1.0]:
		var perno: Node3D = Node3D.new()
		perno.position = Vector3(0.0, 0.1, 0.0)
		gru.add_child(perno)
		var ala: MeshInstance3D = MeshInstance3D.new()
		ala.mesh = _triangoli([Vector3(-0.12, 0.0, 0.0), Vector3(0.12, 0.0, 0.0), Vector3(-0.05, 0.0, 0.42 * lato)], [[0, 1, 2]])
		ala.material_override = carta
		perno.add_child(ala)
		perno.set_meta("lato", lato)
		gru.set_meta("ala%d" % int(lato), perno)
	return gru


func _triangoli(punti: Array, facce: Array) -> ArrayMesh:
	var st: SurfaceTool = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for f: Array in facce:
		for i: int in f:
			st.add_vertex(punti[i])
	st.generate_normals()
	return st.commit()


func _sbatti(gru: Node3D, volte: int, durata: float) -> void:
	for lato: int in [1, -1]:
		var ala: Node3D = gru.get_meta("ala%d" % lato)
		var t: Tween = create_tween()
		for k: int in range(volte):
			t.tween_property(ala, "rotation:x", 0.9 * lato, durata * 0.5 / volte)
			t.tween_property(ala, "rotation:x", -0.5 * lato, durata * 0.5 / volte)
		t.tween_property(ala, "rotation:x", 0.15 * lato, 0.1)


func _produci_gru(da: Vector3, colore: int) -> void:
	var posto: int = -1
	for k: int in range(_filo_gru.size()):
		if _filo_gru[k]["gru"] == null:
			posto = k
			break
	if posto < 0:
		return
	var gru: Node3D = _gru(COLORI_MANA[colore])
	add_child(gru)
	gru.position = da
	gru.scale = Vector3.ONE * 0.2
	_filo_gru[posto]["gru"] = gru
	_filo_gru[posto]["colore"] = colore
	var arrivo: Vector3 = _filo_gru[posto]["pos"]
	var alto: Vector3 = (da + arrivo) * 0.5 + Vector3(0.0, 1.0, 0.4)
	_sbatti(gru, 5, 0.9)
	var t: Tween = create_tween()
	t.tween_property(gru, "scale", Vector3.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.parallel().tween_method(func(k: float) -> void:
		var p: Vector3 = da.lerp(alto, k).lerp(alto.lerp(arrivo, k), k)
		var dir: Vector3 = p - gru.position
		if dir.length() > 0.001:
			gru.rotation.y = atan2(-dir.z, dir.x)
		gru.position = p, 0.0, 1.0, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_callback(func() -> void:
		gru.rotation = Vector3.ZERO
		_gru_posate.append(gru)
		esplodi(self, arrivo, scintille(COLORI_MANA[colore], 14, 1.2, -1.5, 0.5, 0.05)))


func _spendi_gru(colore: int) -> void:
	for k: int in range(_filo_gru.size() - 1, -1, -1):
		if int(_filo_gru[k]["colore"]) == colore and _filo_gru[k]["gru"] != null:
			var gru: Node3D = _filo_gru[k]["gru"]
			_filo_gru[k]["gru"] = null
			_filo_gru[k]["colore"] = -1
			_gru_posate.erase(gru)
			var da: Vector3 = gru.position
			var arrivo: Vector3 = _truppa.position + Vector3(0.0, 1.6, 0.2)
			_sbatti(gru, 3, 0.5)
			var t: Tween = create_tween()
			t.tween_property(gru, "position", arrivo, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			t.parallel().tween_property(gru, "rotation:z", -0.8, 0.5)
			t.tween_callback(func() -> void:
				esplodi(self, arrivo, scintille(COLORI_MANA[colore], 34, 2.8, -3.0, 0.7, 0.07))
				gru.queue_free())
			return


# --- C: rosone ----------------------------------------------------------------------

func _crea_rosone() -> void:
	_rosone = Node3D.new()
	_rosone.position = Vector3(0.3, 2.75, -1.2)
	_rosone.scale = Vector3.ONE * 0.85
	add_child(_rosone)
	# Cornice di carta crema e piombo scuro.
	var fondo: MeshInstance3D = MeshInstance3D.new()
	var c: CylinderMesh = CylinderMesh.new()
	c.top_radius = 1.55
	c.bottom_radius = 1.55
	c.height = 0.06
	c.radial_segments = 48
	fondo.mesh = c
	var mf: StandardMaterial3D = StandardMaterial3D.new()
	mf.albedo_color = Color("ece2cc")
	fondo.material_override = mf
	fondo.rotation.x = PI * 0.5
	fondo.position.z = -0.04
	_rosone.add_child(fondo)
	var piombo: MeshInstance3D = MeshInstance3D.new()
	var cp: CylinderMesh = CylinderMesh.new()
	cp.top_radius = 1.42
	cp.bottom_radius = 1.42
	cp.height = 0.07
	cp.radial_segments = 48
	piombo.mesh = cp
	var mp: StandardMaterial3D = StandardMaterial3D.new()
	mp.albedo_color = Color("140f0c")
	piombo.material_override = mp
	piombo.rotation.x = PI * 0.5
	piombo.position.z = -0.02
	_rosone.add_child(piombo)
	# Cinque petali (uno per colore), ognuno in quattro spicchi dal centro verso fuori.
	for petalo: int in range(5):
		var angolo: float = -PI * 0.5 + TAU * float(petalo) / 5.0
		var fila: Array = []
		for s: int in range(4):
			var r0: float = 0.28 + s * 0.27
			var r1: float = r0 + 0.23
			var largo: float = TAU / 5.0 * 0.42
			var punti: Array = []
			for k: int in range(7):
				var a: float = angolo - largo + largo * 2.0 * float(k) / 6.0
				punti.append(Vector3(cos(a) * r0, sin(a) * r0, 0.0))
			for k: int in range(6, -1, -1):
				var a2: float = angolo - largo + largo * 2.0 * float(k) / 6.0
				punti.append(Vector3(cos(a2) * r1, sin(a2) * r1, 0.0))
			var st: SurfaceTool = SurfaceTool.new()
			st.begin(Mesh.PRIMITIVE_TRIANGLES)
			for k: int in range(6):
				var a_in: Vector3 = punti[k]
				var b_in: Vector3 = punti[k + 1]
				var a_out: Vector3 = punti[13 - k]
				var b_out: Vector3 = punti[12 - k]
				for v: Vector3 in [a_in, b_in, a_out, b_in, b_out, a_out]:
					st.set_normal(Vector3.BACK)
					st.add_vertex(v)
			var vetro: MeshInstance3D = MeshInstance3D.new()
			vetro.mesh = st.commit()
			var mv: StandardMaterial3D = StandardMaterial3D.new()
			mv.albedo_color = COLORI_MANA[petalo].darkened(0.75)
			mv.emission_enabled = true
			mv.emission = COLORI_MANA[petalo]
			mv.emission_energy_multiplier = 0.0
			mv.cull_mode = BaseMaterial3D.CULL_DISABLED
			mv.roughness = 0.2
			vetro.material_override = mv
			vetro.position.z = 0.03
			_rosone.add_child(vetro)
			fila.append({"mat": mv, "acceso": false, "nodo": vetro})
		_spicchi.append(fila)
	var cuore: MeshInstance3D = MeshInstance3D.new()
	var sc: SphereMesh = SphereMesh.new()
	sc.radius = 0.2
	sc.height = 0.12
	cuore.mesh = sc
	cuore.material_override = mf
	cuore.position.z = 0.04
	_rosone.add_child(cuore)
	_luce_rosone = OmniLight3D.new()
	_luce_rosone.position = Vector3(0.0, -0.6, 1.4)
	_luce_rosone.omni_range = 6.0
	_luce_rosone.light_energy = 0.0
	_rosone.add_child(_luce_rosone)


func _aggiorna_luce_rosone() -> void:
	var somma: Color = Color.BLACK
	var quanti: int = 0
	for petalo: int in range(_spicchi.size()):
		for s: Dictionary in _spicchi[petalo]:
			if bool(s["acceso"]):
				somma += COLORI_MANA[petalo]
				quanti += 1
	var t: Tween = create_tween()
	t.set_parallel(true)
	t.tween_property(_luce_rosone, "light_energy", minf(3.0, quanti * 0.5), 0.3)
	if quanti > 0:
		t.tween_property(_luce_rosone, "light_color", somma / float(quanti), 0.3)


func _produci_rosone(da: Vector3, colore: int) -> void:
	var fila: Array = _spicchi[colore]
	for s: Dictionary in fila:
		if not bool(s["acceso"]):
			s["acceso"] = true
			var nodo: MeshInstance3D = s["nodo"]
			var arrivo: Vector3 = nodo.global_position
			var aabb: AABB = nodo.mesh.get_aabb()
			arrivo = _rosone.to_global(aabb.get_center())
			_vola(da, arrivo, COLORI_MANA[colore], 0.6, 0.8, func() -> void:
				var mat: StandardMaterial3D = s["mat"]
				var t: Tween = create_tween()
				t.tween_property(mat, "emission_energy_multiplier", 4.5, 0.08)
				t.tween_property(mat, "emission_energy_multiplier", 2.2, 0.3)
				_aggiorna_luce_rosone()
				esplodi(self, arrivo, scintille(COLORI_MANA[colore], 18, 1.4, -1.0, 0.5, 0.05)))
			return


func _spendi_rosone(colore: int) -> void:
	var fila: Array = _spicchi[colore]
	for k: int in range(fila.size() - 1, -1, -1):
		var s: Dictionary = fila[k]
		if bool(s["acceso"]):
			s["acceso"] = false
			var mat: StandardMaterial3D = s["mat"]
			var t: Tween = create_tween()
			t.tween_property(mat, "emission_energy_multiplier", 6.0, 0.06)
			t.tween_property(mat, "emission_energy_multiplier", 0.0, 0.25)
			_aggiorna_luce_rosone()
			var nodo: MeshInstance3D = s["nodo"]
			var da: Vector3 = _rosone.to_global(nodo.mesh.get_aabb().get_center())
			# Schegge di vetro colorato verso la truppa.
			for j: int in range(5):
				var scheggia: MeshInstance3D = MeshInstance3D.new()
				var q: QuadMesh = QuadMesh.new()
				q.size = Vector2(0.09, 0.14)
				scheggia.mesh = q
				scheggia.material_override = materiale_luce(COLORI_MANA[colore], 3.0)
				add_child(scheggia)
				scheggia.position = da
				var arrivo: Vector3 = _truppa.position + Vector3(randf_range(-0.3, 0.3), 1.5 + randf_range(-0.3, 0.3), 0.2)
				var ts: Tween = create_tween()
				ts.tween_interval(j * 0.03)
				ts.tween_property(scheggia, "position", arrivo, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
				ts.parallel().tween_property(scheggia, "rotation", Vector3(randf() * 6.0, randf() * 6.0, randf() * 6.0), 0.45)
				ts.tween_callback(scheggia.queue_free)
			var finale: Tween = create_tween()
			finale.tween_interval(0.5)
			finale.tween_callback(func() -> void: esplodi(self, _truppa.position + Vector3(0.0, 1.5, 0.2), scintille(COLORI_MANA[colore], 26, 2.4, -2.0, 0.6, 0.06)))
			return
