extends ProvaBase
## Prove della plancia del giocatore (9 novembre 2026): tre idee da vedere.
## 0 = A · Libro a fisarmonica, 1 = B · Nazione in miniatura, 2 = C · Palcoscenico.
## Scena finta: la plancia con alcune tessere, poi si conquistano uno spazio truppa e uno edificio.

@export var variante: int = 0

const TITOLI: Array[String] = ["A · Libro a fisarmonica", "B · Nazione in miniatura", "C · Palcoscenico"]
const DESCRIZIONI: Array[String] = [
	"Ogni spazio è una pagina del libro: uno spazio nuovo è una pagina che si apre da destra.",
	"Dietro la città con gli edifici, al centro le mura, davanti il campo con le truppe. Le mura si allungano.",
	"Gli edifici sono la scenografia sul fondo, le truppe gli attori sul proscenio. Il sipario si apre di più.",
]
const DURATA_PROVA: float = 10.0
const PASSO_T: float = 1.62
const PASSO_E: float = 2.3
const Z_T: float = 1.4
const Z_E: float = -1.8
const X0: float = -5.2
const COLONNA: float = 3.2

var _camera: Camera3D
var _lanterna: OmniLight3D
var _shader: Shader
var _rumore: NoiseTexture2D
var _truppe_id: Array[String] = ["c8716e", "278014", "862b2d", "a4648d"]
var _edifici_id: Array[String] = ["d61645", "19632f", "9928f9"]
var _n_t: int = 4
var _n_e: int = 3
var _destra: float = 0.0
## Parti che si allungano con la plancia (aggiornate da _allunga).
var _da_allungare: Array = []


func _ready() -> void:
	_font = load("res://font/BarlowSemiCondensed-ExtraBold.ttf") as FontFile
	_font_testo = load("res://font/Barlow-SemiBold.ttf") as FontFile
	costruisci()
	_passi = [[1.0, "intro", []], [4.0, "nuova_truppa", []], [6.5, "nuovo_edificio", []]]


func _process(delta: float) -> void:
	tempo += delta
	while _indice < _passi.size() and float(_passi[_indice][0]) <= tempo:
		var passo: Array = _passi[_indice]
		_indice += 1
		callv(String(passo[1]), passo[2])
	_lanterna.position.x = 1.0 + sin(tempo * 0.6) * 3.0
	_lanterna.light_energy = 4.2 + sin(tempo * 13.0) * 0.1
	if tempo >= DURATA_PROVA:
		get_tree().quit()


# --- Scena comune ---------------------------------------------------------------------

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
	amb.ambient_light_energy = 0.75
	amb.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	amb.glow_enabled = true
	amb.glow_intensity = 0.5
	var we: WorldEnvironment = WorldEnvironment.new()
	we.environment = amb
	add_child(we)
	_camera = Camera3D.new()
	_camera.fov = 36.0
	add_child(_camera)
	_camera.look_at_from_position(Vector3(-0.3, 10.8, 11.2), Vector3(-0.3, 0.3, -0.3), Vector3.UP)
	_lanterna = OmniLight3D.new()
	_lanterna.light_color = Color("ffb067")
	_lanterna.light_energy = 4.2
	_lanterna.omni_range = 40.0
	_lanterna.omni_attenuation = 1.1
	_lanterna.shadow_enabled = true
	_lanterna.position = Vector3(1.0, 11.0, 6.0)
	add_child(_lanterna)
	var riempi: DirectionalLight3D = DirectionalLight3D.new()
	riempi.light_color = Color("ffe2c0")
	riempi.light_energy = 0.35
	riempi.rotation_degrees = Vector3(-60.0, -25.0, 0.0)
	add_child(riempi)
	var tavolo: MeshInstance3D = _scatola(Vector3(80.0, 0.2, 60.0), Vector3(0.0, -0.45, 0.0), Color("151019"))
	tavolo.name = "tavolo"
	_destra = X0 + COLONNA + _n_t * PASSO_T + 1.2
	match variante:
		0: _libro()
		1: _citta()
		2: _palco()
	_colonna_sinistra()
	for i: int in range(_n_t):
		_tessera(_truppe_id[i], Vector3(_x_truppa(i), _y_pezzi(), Z_T), true, 0.0)
	for i: int in range(_n_e):
		_tessera(_edifici_id[i], Vector3(_x_edificio(i), _y_pezzi(), Z_E), false, 0.0)
	_spazio_vuoto(Vector3(_x_truppa(_n_t), _y_pezzi(), Z_T), true)
	_spazio_vuoto(Vector3(_x_edificio(_n_e), _y_pezzi(), Z_E), false)
	var strato: CanvasLayer = CanvasLayer.new()
	strato.layer = 2
	add_child(strato)
	var titolo: Label = Label.new()
	titolo.text = TITOLI[variante]
	titolo.add_theme_font_override("font", _font)
	titolo.add_theme_font_size_override("font_size", 58)
	titolo.add_theme_color_override("font_color", Color("ece2cc"))
	titolo.position = Vector2(48, 30)
	strato.add_child(titolo)
	var spiega: Label = Label.new()
	spiega.text = DESCRIZIONI[variante]
	spiega.add_theme_font_override("font", _font_testo)
	spiega.add_theme_font_size_override("font_size", 26)
	spiega.add_theme_color_override("font_color", Color("cdbd9c"))
	spiega.position = Vector2(50, 104)
	spiega.size = Vector2(1820, 80)
	spiega.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	strato.add_child(spiega)
	strato_grana(0.035, "Prova della plancia del giocatore — solo aspetto, tessere e disegni messi a caso")


func _y_pezzi() -> float:
	return 0.12 if variante != 0 else 0.2


func _x_truppa(i: int) -> float:
	return X0 + COLONNA + (i + 0.5) * PASSO_T


func _x_edificio(i: int) -> float:
	return X0 + COLONNA + (i + 0.5) * PASSO_E


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


func _quadro(misura: Vector2, trama: Texture2D, pos: Vector3, genitore: Node3D = null) -> MeshInstance3D:
	var q: QuadMesh = QuadMesh.new()
	q.size = misura
	var m: MeshInstance3D = MeshInstance3D.new()
	m.mesh = q
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = _shader
	mat.set_shader_parameter("tex", trama)
	m.material_override = mat
	m.position = pos
	(genitore if genitore != null else self).add_child(m)
	return m


## Una tessera semplificata: cartoncino scuro con bordo e la figurina in piedi.
func _tessera(id: String, pos: Vector3, truppa: bool, ritardo: float) -> Node3D:
	var radice: Node3D = Node3D.new()
	radice.position = pos
	add_child(radice)
	var misura: Vector2 = Vector2(1.44, 2.16) if truppa else Vector2(2.13, 1.42)
	_scatola(Vector3(misura.x + 0.08, 0.06, misura.y + 0.08), Vector3(0.0, 0.03, 0.0), Color("c8834a"), radice)
	_scatola(Vector3(misura.x - 0.06, 0.07, misura.y - 0.06), Vector3(0.0, 0.035, 0.0), Color("1e1712"), radice)
	var fascia: MeshInstance3D = _scatola(Vector3(misura.x * 0.85, 0.08, 0.32), Vector3(0.0, 0.04, misura.y * 0.22), Color("a42b26") if truppa else Color("c8a032"), radice)
	fascia.name = "fascia"
	var alto: float = misura.x * (1.05 if truppa else 0.7)
	var perno: Node3D = Node3D.new()
	perno.position = Vector3(0.0, 0.07, -misura.y * 0.15)
	radice.add_child(perno)
	_quadro(Vector2(alto, alto), immagine("sagome", id), Vector3(0.0, alto * 0.5, 0.0), perno)
	if ritardo > 0.0:
		perno.rotation.x = PI * 0.5
		var t: Tween = create_tween()
		t.tween_interval(ritardo)
		t.tween_property(perno, "rotation:x", 0.0, 0.55).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return radice


func _spazio_vuoto(pos: Vector3, truppa: bool) -> void:
	var misura: Vector2 = Vector2(0.7, 2.1) if truppa else Vector2(0.7, 1.4)
	var m: MeshInstance3D = _scatola(Vector3(misura.x, 0.02, misura.y), pos + Vector3(-0.35, 0.0, 0.0), Color(0.05, 0.04, 0.03))
	var piu: Label3D = scritta("+", 120, Color("ece2cc"), Color.BLACK, 0)
	piu.rotation.x = -PI * 0.5
	piu.position = Vector3(0.0, 0.03, 0.0)
	m.add_child(piu)
	m.name = "vuoto_truppa" if truppa else "vuoto_edificio"


## Stendardo steso e sfere del mana, a sinistra come nel gioco.
func _colonna_sinistra() -> void:
	var x: float = X0 + COLONNA * 0.5
	var y: float = _y_pezzi() + (0.6 if variante == 1 else 0.0)
	var img: Image = Image.create(160, 210, false, Image.FORMAT_RGBA8)
	img.fill(Color("ece2cc"))
	img.fill_rect(Rect2i(0, 0, 160, 26), Color("2f5fb8"))
	for xx: int in range(160):
		var taglio: int = 186 + int(absf(float(xx % 40) - 20.0) * 1.2)
		for yy: int in range(taglio, 210):
			img.set_pixel(xx, yy, Color(0, 0, 0, 0))
	img.generate_mipmaps()
	var telo: MeshInstance3D = _quadro(Vector2(1.4, 1.85), ImageTexture.create_from_image(img), Vector3(x, y + 0.02, -0.4))
	telo.rotation.x = -PI * 0.5
	if variante == 1:
		# Sulla torre: lo stendardo sventola in alto.
		telo.rotation.x = 0.0
		telo.position = Vector3(x, 3.0, Z_E - 0.4)
	var np: Label3D = scritta("NP\n58", 110, Color("1a1410"), Color(0, 0, 0, 0), 0)
	np.position = telo.position + (Vector3(0.0, 0.02, 0.0) if variante != 1 else Vector3(0.0, 0.0, 0.02))
	if variante != 1:
		np.rotation.x = -PI * 0.5
	add_child(np)
	var colori: Array[Color] = [ROSSO, VERDE, BLU, VIOLA]
	for k: int in range(5):
		var s: MeshInstance3D = MeshInstance3D.new()
		var sm: SphereMesh = SphereMesh.new()
		var raggio: float = 0.26 if k == 4 else 0.2
		sm.radius = raggio
		sm.height = raggio * 2.0
		s.mesh = sm
		var colore: Color = ENERGIA if k == 4 else colori[k]
		var mat: StandardMaterial3D = materiale_luce(colore, 1.4 if k == 4 else 0.25)
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
		mat.albedo_color = colore.darkened(0.6)
		s.material_override = mat
		var angolo: float = -PI * 0.5 + TAU * float(k) / 4.0
		var off: Vector3 = Vector3.ZERO if k == 4 else Vector3(cos(angolo) * 0.6, 0.0, sin(angolo) * 0.75)
		s.position = Vector3(x, y + raggio + 0.04, 2.0) + off
		add_child(s)


func intro() -> void:
	pass


# --- A · Libro a fisarmonica -------------------------------------------------------------

var _pagine: Array[Node3D] = []


func _libro() -> void:
	# Copertina a sinistra, in pelle rossa con il bordo d'oro.
	_scatola(Vector3(COLONNA + 0.3, 0.22, 7.4), Vector3(X0 + COLONNA * 0.5, 0.0, -0.2), Color("5a1e16"))
	_scatola(Vector3(COLONNA + 0.1, 0.24, 7.2), Vector3(X0 + COLONNA * 0.5, 0.005, -0.2), Color("6e2a1e"))
	for i: int in range(_n_t + 1):
		_pagine.append(_pagina(i, i == _n_t))


## Una pagina del leporello: le pagine alternano un piccolo dislivello, come una fisarmonica.
func _pagina(i: int, ripiegata: bool) -> Node3D:
	var larghezza: float = PASSO_T
	var perno: Node3D = Node3D.new()
	perno.position = Vector3(X0 + COLONNA + i * larghezza, 0.02, -0.2)
	add_child(perno)
	var foglio: MeshInstance3D = _scatola(Vector3(larghezza - 0.02, 0.06, 7.2), Vector3(larghezza * 0.5, 0.0, 0.0), Color("e9dcc0") if i % 2 == 0 else Color("ddcfb0"), perno)
	# Filetto a inchiostro e numero di pagina.
	_scatola(Vector3(larghezza - 0.3, 0.065, 0.03), Vector3(larghezza * 0.5, 0.0, 3.3), Color("2a1d12"), perno)
	_scatola(Vector3(larghezza - 0.3, 0.065, 0.03), Vector3(larghezza * 0.5, 0.0, -3.3), Color("2a1d12"), perno)
	var n: Label3D = scritta(str(i + 1), 50, Color("6a5440"), Color(0, 0, 0, 0), 0, true)
	n.rotation.x = -PI * 0.5
	n.position = Vector3(larghezza * 0.5, 0.04, 3.5)
	perno.add_child(n)
	perno.rotation.z = 0.025 * (1.0 if i % 2 == 0 else -1.0)
	if ripiegata:
		perno.rotation.z = PI * 0.92
		var sigillo: MeshInstance3D = MeshInstance3D.new()
		var c: CylinderMesh = CylinderMesh.new()
		c.top_radius = 0.28
		c.bottom_radius = 0.3
		c.height = 0.08
		sigillo.mesh = c
		sigillo.material_override = StandardMaterial3D.new()
		(sigillo.material_override as StandardMaterial3D).albedo_color = Color("a3201a")
		sigillo.position = Vector3(larghezza * 0.5, -0.07, 0.0)
		perno.add_child(sigillo)
		sigillo.name = "sigillo"
	return perno


func nuova_truppa() -> void:
	match variante:
		0:
			var pagina: Node3D = _pagine[_n_t]
			var t: Tween = create_tween()
			t.tween_property(pagina, "rotation:z", 0.025 * (1.0 if _n_t % 2 == 0 else -1.0), 0.8).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			esplodi(self, pagina.position + Vector3(0.8, 0.4, 0.0), scintille(Color("ffd27a"), 40, 2.5, -2.0, 0.8, 0.07))
			_togli("vuoto_truppa")
			_tessera("640641", Vector3(_x_truppa(_n_t), _y_pezzi(), Z_T), true, 0.7)
			_pagine.append(_pagina(_n_t + 1, true))
		1:
			_togli("vuoto_truppa")
			_tessera("640641", Vector3(_x_truppa(_n_t), _y_pezzi(), Z_T), true, 0.6)
			_allunga_citta(_x_truppa(_n_t) + PASSO_T)
		2:
			_togli("vuoto_truppa")
			_apri_sipario(_x_truppa(_n_t) + PASSO_T)
			_tessera("640641", Vector3(_x_truppa(_n_t), _y_pezzi(), Z_T), true, 0.7)
	_n_t += 1


func nuovo_edificio() -> void:
	_togli("vuoto_edificio")
	_tessera("5066f4", Vector3(_x_edificio(_n_e), _y_pezzi(), Z_E), false, 0.6)
	if variante == 1:
		_lotto(_x_edificio(_n_e), 0.5)
	_n_e += 1


func _togli(nome: String) -> void:
	var n: Node = find_child(nome, false, false)
	if n != null:
		var t: Tween = create_tween()
		t.tween_property(n, "scale", Vector3(0.01, 1.0, 0.01), 0.2)
		t.tween_callback(n.queue_free)


# --- B · Nazione in miniatura -------------------------------------------------------------

var _mura: Array[Node3D] = []
var _campo: MeshInstance3D
var _citta_suolo: MeshInstance3D


func _citta() -> void:
	var fine: float = X0 + COLONNA + _n_t * PASSO_T + 1.4
	var larghezza: float = fine - X0
	# Il campo davanti alle mura (erba bruna) e la città dietro (selciato).
	_campo = _scatola(Vector3(larghezza, 0.12, 3.6), Vector3(X0 + larghezza * 0.5, 0.0, Z_T + 0.1), Color("4a5a2a"))
	_citta_suolo = _scatola(Vector3(larghezza, 0.3, 3.2), Vector3(X0 + larghezza * 0.5, 0.09, Z_E), Color("6e6250"))
	for i: int in range(_n_e):
		_lotto(_x_edificio(i), 0.0)
	# La rocca a sinistra con la torre dello stendardo.
	_scatola(Vector3(COLONNA - 0.3, 0.7, 6.6), Vector3(X0 + COLONNA * 0.5, 0.3, -0.2), Color("4d4238"))
	_torre(Vector3(X0 + COLONNA * 0.5 - 0.9, 0.6, Z_E - 0.6), 2.4, 0.0)
	# Le mura fra città e campo, a pezzi: si allungano con la plancia.
	var x: float = X0 + COLONNA
	while x < fine - 0.01:
		_mura.append(_tratto_mura(x, 0.0))
		x += 1.6
	_torre(Vector3(fine - 0.2, 0.0, -0.35), 1.6, 0.0).name = "torre_fine"


func _lotto(x: float, ritardo: float) -> void:
	var l: MeshInstance3D = _scatola(Vector3(2.0, 0.03, 1.6), Vector3(x, 0.25, Z_E), Color("8a7a60"))
	if ritardo > 0.0:
		l.scale = Vector3(0.01, 1.0, 0.01)
		var t: Tween = create_tween()
		t.tween_interval(ritardo * 0.5)
		t.tween_property(l, "scale", Vector3.ONE, 0.3)


func _tratto_mura(x: float, ritardo: float) -> Node3D:
	var perno: Node3D = Node3D.new()
	perno.position = Vector3(x, 0.24, -0.35)
	add_child(perno)
	var img: Image = Image.create(128, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color("ece2cc"))
	img.fill_rect(Rect2i(3, 14, 122, 50), Color("6a5c4c"))
	for m: int in range(0, 128, 24):
		img.fill_rect(Rect2i(m, 0, 12, 14), Color(0, 0, 0, 0))
	for yy: int in range(24, 64, 12):
		img.fill_rect(Rect2i(3, yy, 122, 1), Color("4a3e32"))
	img.generate_mipmaps()
	_quadro(Vector2(1.62, 0.8), ImageTexture.create_from_image(img), Vector3(0.8, 0.4, 0.0), perno)
	if ritardo >= 0.0:
		perno.rotation.x = 0.0
	return perno


func _torre(pos: Vector3, alta: float, ritardo: float) -> Node3D:
	var perno: Node3D = Node3D.new()
	perno.position = pos
	add_child(perno)
	var img: Image = Image.create(64, 160, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	img.fill_rect(Rect2i(4, 18, 56, 142), Color("ece2cc"))
	img.fill_rect(Rect2i(8, 22, 48, 138), Color("5c4e40"))
	for m: int in range(4, 60, 16):
		img.fill_rect(Rect2i(m, 6, 10, 14), Color("ece2cc"))
	img.fill_rect(Rect2i(26, 60, 12, 18), Color("ffb067"))
	img.generate_mipmaps()
	_quadro(Vector2(alta * 0.4, alta), ImageTexture.create_from_image(img), Vector3(0.0, alta * 0.5, 0.0), perno)
	if ritardo > 0.0:
		perno.rotation.x = PI * 0.5
		var t: Tween = create_tween()
		t.tween_interval(ritardo)
		t.tween_property(perno, "rotation:x", 0.0, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return perno


func _allunga_citta(nuova_fine: float) -> void:
	var fine_vecchia: float = X0 + (_campo.mesh as BoxMesh).size.x
	var nuova_larghezza: float = nuova_fine + 1.4 - X0
	for parte: MeshInstance3D in [_campo, _citta_suolo]:
		var b: BoxMesh = parte.mesh as BoxMesh
		var t: Tween = create_tween()
		t.set_parallel(true)
		t.tween_method(func(v: float) -> void: b.size.x = v, b.size.x, nuova_larghezza, 0.6).set_trans(Tween.TRANS_CUBIC)
		t.tween_property(parte, "position:x", X0 + nuova_larghezza * 0.5, 0.6).set_trans(Tween.TRANS_CUBIC)
	var torre: Node3D = find_child("torre_fine", false, false)
	if torre != null:
		var tt: Tween = create_tween()
		tt.tween_property(torre, "position:x", X0 + nuova_larghezza - 0.2, 0.6).set_trans(Tween.TRANS_CUBIC)
	var nuovo: Node3D = _tratto_mura(fine_vecchia - 1.6, 0.0)
	nuovo.rotation.x = -PI * 0.5
	var tn: Tween = create_tween()
	tn.tween_interval(0.3)
	tn.tween_property(nuovo, "rotation:x", 0.0, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	esplodi(self, Vector3(fine_vecchia, 0.8, -0.35), scintille(Color("ece2cc"), 30, 2.0, -3.0, 0.7, 0.08))


# --- C · Palcoscenico -------------------------------------------------------------------

var _tenda_destra: Node3D
var _assi: MeshInstance3D
var _fondale: MeshInstance3D


func _palco() -> void:
	var fine: float = X0 + COLONNA + _n_t * PASSO_T + 1.4
	var larghezza: float = fine - X0
	_assi = _scatola(Vector3(larghezza, 0.35, 7.2), Vector3(X0 + larghezza * 0.5, -0.1, -0.2), Color("6a4528"))
	for z: float in [-3.0, -2.0, -1.0, 0.0, 1.0, 2.0, 3.0]:
		_scatola(Vector3(30.0, 0.36, 0.03), Vector3(5.0, -0.1, z), Color("3e2716"))
	# Fondale dipinto dietro gli edifici.
	var img: Image = Image.create(256, 96, false, Image.FORMAT_RGBA8)
	for yy: int in range(96):
		img.fill_rect(Rect2i(0, yy, 256, 1), Color("2a3450").lerp(Color("c8834a"), float(yy) / 96.0))
	for xx: int in range(0, 256, 2):
		var h: int = 70 + int(sin(xx * 0.05) * 8.0 + sin(xx * 0.13) * 5.0)
		img.fill_rect(Rect2i(xx, h, 2, 96 - h), Color("1e1712"))
	img.generate_mipmaps()
	_fondale = _quadro(Vector2(larghezza, 2.6), ImageTexture.create_from_image(img), Vector3(X0 + larghezza * 0.5, 1.3, -3.6))
	# Arco del proscenio in alto e tende ai lati.
	_tenda(Vector3(X0 - 0.2, 0.0, 2.6), false)
	_tenda_destra = _tenda(Vector3(fine + 0.2, 0.0, 2.6), true)
	# Luci della ribalta sul bordo davanti.
	for k: int in range(10):
		var lume: MeshInstance3D = MeshInstance3D.new()
		var s: SphereMesh = SphereMesh.new()
		s.radius = 0.07
		s.height = 0.14
		lume.mesh = s
		lume.material_override = materiale_luce(Color("ffd27a"), 4.0)
		lume.position = Vector3(X0 + 0.6 + k * larghezza / 10.0, 0.12, 3.35)
		add_child(lume)


func _tenda(pos: Vector3, destra: bool) -> Node3D:
	var perno: Node3D = Node3D.new()
	perno.position = pos
	add_child(perno)
	var img: Image = Image.create(64, 160, false, Image.FORMAT_RGBA8)
	for xx: int in range(64):
		var c: Color = Color("8e1e1a").lerp(Color("4a0c0a"), 0.5 + 0.5 * sin(xx * 0.4))
		img.fill_rect(Rect2i(xx, 0, 1, 160), c)
	img.fill_rect(Rect2i(0, 0, 64, 10), Color("c8a032"))
	img.generate_mipmaps()
	_quadro(Vector2(1.6, 4.4), ImageTexture.create_from_image(img), Vector3(0.6 if destra else -0.6, 2.2, 0.0), perno)
	return perno


func _apri_sipario(nuova_fine: float) -> void:
	var nuova_larghezza: float = nuova_fine + 1.4 - X0
	var b: BoxMesh = _assi.mesh as BoxMesh
	var t: Tween = create_tween()
	t.set_parallel(true)
	t.tween_method(func(v: float) -> void: b.size.x = v, b.size.x, nuova_larghezza, 0.8).set_trans(Tween.TRANS_CUBIC)
	t.tween_property(_assi, "position:x", X0 + nuova_larghezza * 0.5, 0.8).set_trans(Tween.TRANS_CUBIC)
	t.tween_property(_tenda_destra, "position:x", X0 + nuova_larghezza + 0.2, 0.8).set_trans(Tween.TRANS_CUBIC)
	var q: QuadMesh = _fondale.mesh as QuadMesh
	t.tween_method(func(v: float) -> void: q.size.x = v, q.size.x, nuova_larghezza, 0.8).set_trans(Tween.TRANS_CUBIC)
	t.tween_property(_fondale, "position:x", X0 + nuova_larghezza * 0.5, 0.8).set_trans(Tween.TRANS_CUBIC)
