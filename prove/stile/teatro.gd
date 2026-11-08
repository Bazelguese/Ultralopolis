extends ProvaBase
## Prova 1: TEATRO DI CARTA. La plancia è un libro pop-up nel buio; le figure sono sagome di carta
## ritagliate che si alzano, scattano in avanti e alla fine si richiudono. Una lanterna che oscilla.

const SHADER_SAGOMA: String = """
shader_type spatial;
render_mode cull_disabled, depth_draw_opaque;
uniform sampler2D tex : source_color, filter_linear_mipmap;
uniform sampler2D rumore;
uniform float bruciatura = 0.0;
uniform float lampo = 0.0;
uniform float spento = 0.0;
uniform vec3 tinta : source_color = vec3(1.0);
void fragment() {
	vec4 c = texture(tex, UV);
	float n = texture(rumore, UV).r;
	float a = c.a;
	if (bruciatura > 0.001 && n < bruciatura) { a = 0.0; }
	float bordo = (bruciatura > 0.001) ? smoothstep(bruciatura + 0.07, bruciatura, n) : 0.0;
	vec3 col = c.rgb * tinta;
	float g = dot(col, vec3(0.3, 0.59, 0.11));
	col = mix(col, vec3(g) * 0.4, spento);
	ALBEDO = col;
	EMISSION = col * lampo * 1.2 + vec3(1.0, 0.42, 0.08) * bordo * 4.0;
	ROUGHNESS = 0.9;
	ALPHA = a;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
}
"""

var _shader: Shader
var _rumore: NoiseTexture2D
var _camera: Camera3D
var _lanterna: OmniLight3D
## Per lato: perno (cerniera) e materiale di ogni sagoma.
var _perni_truppe: Array = [[], []]
var _mat_truppe: Array = [[], []]
var _perni_edifici: Array = [[], []]
var _mat_edifici: Array = [[], []]
var _bandiere: Array = [null, null]
var _mat_bandiere: Array = [null, null]
var _numeri: Array = [null, null]
var _gemme: Array = [[], []]
var _conti: Array = [[], []]
var _cartellini: Dictionary = {}
var _sabotati: Dictionary = {}
var _bruciato: Array[float] = [0.0, 0.0]


func costruisci() -> void:
	_shader = Shader.new()
	_shader.code = SHADER_SAGOMA
	_rumore = NoiseTexture2D.new()
	_rumore.width = 256
	_rumore.height = 256
	var fn: FastNoiseLite = FastNoiseLite.new()
	fn.frequency = 0.02
	fn.fractal_octaves = 4
	_rumore.noise = fn

	var amb: Environment = Environment.new()
	amb.background_mode = Environment.BG_COLOR
	amb.background_color = Color("040302")
	amb.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	amb.ambient_light_color = Color("3a2c3c")
	amb.ambient_light_energy = 0.55
	amb.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	amb.glow_enabled = true
	amb.glow_intensity = 0.7
	amb.glow_bloom = 0.08
	amb.fog_enabled = true
	amb.fog_light_color = Color("0b0806")
	amb.fog_density = 0.018
	var we: WorldEnvironment = WorldEnvironment.new()
	we.environment = amb
	add_child(we)

	_camera = Camera3D.new()
	_camera.fov = 36.0
	add_child(_camera)
	_camera.look_at_from_position(Vector3(-2.0, 15.0, 19.0), Vector3(0.6, 0.0, -0.5), Vector3.UP)

	_lanterna = OmniLight3D.new()
	_lanterna.light_color = Color("ffb067")
	_lanterna.light_energy = 4.6
	_lanterna.omni_range = 34.0
	_lanterna.omni_attenuation = 0.9
	_lanterna.shadow_enabled = true
	_lanterna.position = Vector3(1.0, 8.0, 8.5)
	add_child(_lanterna)
	var riempi: OmniLight3D = OmniLight3D.new()
	riempi.light_color = Color("ffd9a8")
	riempi.light_energy = 0.9
	riempi.omni_range = 30.0
	riempi.position = Vector3(0.0, 4.0, 14.0)
	add_child(riempi)
	var fredda: DirectionalLight3D = DirectionalLight3D.new()
	fredda.light_color = Color("5a78c8")
	fredda.light_energy = 0.35
	fredda.rotation_degrees = Vector3(-35.0, 160.0, 0.0)
	add_child(fredda)

	# Il tavolo e le due pagine del libro.
	_scatola(Vector3(70.0, 0.2, 50.0), Vector3(0.0, -0.1, 0.0), Color("120d0a"), 0.95)
	_scatola(Vector3(16.0, 0.08, 7.4), Vector3(0.8, 0.04, 3.4), Color("4a3a2a"), 0.9)
	_scatola(Vector3(16.0, 0.08, 7.4), Vector3(0.8, 0.04, -3.4), Color("3a2a22"), 0.9)
	_scatola(Vector3(16.0, 1.0, 2.6), Vector3(0.8, 0.5, -5.6), Color("2e2019"), 0.9)
	# Solchi della brace: dagli edifici alla riserva.
	for lato: int in [0, 1]:
		var z: float = 5.6 if lato == 0 else -5.6
		var y: float = 0.09 if lato == 0 else 1.01
		var solco: MeshInstance3D = MeshInstance3D.new()
		var b: BoxMesh = BoxMesh.new()
		b.size = Vector3(11.5, 0.02, 0.06)
		solco.mesh = b
		solco.material_override = materiale_luce(Color("ff6a1a"), 0.6)
		solco.position = Vector3(-0.6, y, z + (0.9 if lato == 0 else -0.9))
		add_child(solco)

	for lato: int in [0, 1]:
		var segno: float = 1.0 if lato == 0 else -1.0
		for i: int in range(4):
			var pos: Vector3 = Vector3(-2.6 + i * 2.55, 0.08, 1.9 * segno)
			var dati: Array = _sagoma(String(truppe_arte[lato][i]), pos, 2.5)
			_perni_truppe[lato].append(dati[0])
			_mat_truppe[lato].append(dati[1])
		var edifici: Array = edifici_arte[lato]
		for i: int in range(edifici.size()):
			var y: float = 0.08 if lato == 0 else 1.0
			var pos2: Vector3 = Vector3(-1.6 + i * 2.9, y, 5.0 * segno)
			var dati2: Array = _sagoma(String(edifici[i]), pos2, 1.7 if lato == 0 else 2.0)
			_perni_edifici[lato].append(dati2[0])
			_mat_edifici[lato].append(dati2[1])
		_crea_bandiera(lato)
		_crea_riserva(lato)
	strato_grana(0.045, "Prova di stile 1 · Teatro di carta — scontro finto, solo per vedere aspetto e animazioni")


func _scatola(dim: Vector3, pos: Vector3, colore: Color, ruvido: float) -> MeshInstance3D:
	var m: MeshInstance3D = MeshInstance3D.new()
	var b: BoxMesh = BoxMesh.new()
	b.size = dim
	m.mesh = b
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = colore
	mat.roughness = ruvido
	mat.albedo_texture = _rumore
	m.material_override = mat
	m.position = pos
	add_child(m)
	return m


## Una sagoma di carta con la cerniera alla base. Restituisce [perno, materiale].
func _sagoma(id: String, pos: Vector3, altezza: float) -> Array:
	var perno: Node3D = Node3D.new()
	perno.position = pos
	add_child(perno)
	var q: QuadMesh = QuadMesh.new()
	q.size = Vector2(altezza, altezza)
	var mi: MeshInstance3D = MeshInstance3D.new()
	mi.mesh = q
	mi.position = Vector3(0.0, altezza * 0.5, 0.0)
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = _shader
	mat.set_shader_parameter("tex", immagine("sagome", id))
	mat.set_shader_parameter("rumore", _rumore)
	mi.material_override = mat
	perno.add_child(mi)
	# Piedino di cartone.
	var piede: MeshInstance3D = MeshInstance3D.new()
	var b: BoxMesh = BoxMesh.new()
	b.size = Vector3(altezza * 0.45, 0.05, 0.5)
	piede.mesh = b
	var mp: StandardMaterial3D = StandardMaterial3D.new()
	mp.albedo_color = Color("d9c9a6")
	piede.material_override = mp
	piede.position = Vector3(0.0, 0.025, 0.0)
	perno.add_child(piede)
	perno.rotation.x = PI * 0.5
	return [perno, mat]


func _crea_bandiera(lato: int) -> void:
	var segno: float = 1.0 if lato == 0 else -1.0
	var radice: Node3D = Node3D.new()
	radice.position = Vector3(-5.7, 0.08, 3.0 * segno)
	add_child(radice)
	var asta: MeshInstance3D = MeshInstance3D.new()
	var c: CylinderMesh = CylinderMesh.new()
	c.top_radius = 0.05
	c.bottom_radius = 0.07
	c.height = 4.2
	asta.mesh = c
	var ma: StandardMaterial3D = StandardMaterial3D.new()
	ma.albedo_color = Color("1a1410")
	asta.material_override = ma
	asta.position = Vector3(-1.0, 2.1, 0.0)
	radice.add_child(asta)
	# Stendardo: carta color crema con una fascia del colore del lato.
	var img: Image = Image.create(256, 320, false, Image.FORMAT_RGBA8)
	img.fill(Color("e9dcc0"))
	var fascia: Color = Color("2f5fb8") if lato == 0 else Color("a3241e")
	img.fill_rect(Rect2i(0, 0, 256, 54), fascia)
	for x: int in range(256):
		var taglio: int = 300 + int(absf(float(x % 64) - 32.0) * 0.6)
		for y: int in range(taglio, 320):
			img.set_pixel(x, y, Color(0, 0, 0, 0))
	var tex: ImageTexture = ImageTexture.create_from_image(img)
	var q: QuadMesh = QuadMesh.new()
	q.size = Vector2(2.0, 2.5)
	var mi: MeshInstance3D = MeshInstance3D.new()
	mi.mesh = q
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = _shader
	mat.set_shader_parameter("tex", tex)
	mat.set_shader_parameter("rumore", _rumore)
	mi.material_override = mat
	mi.position = Vector3(0.0, 2.75, 0.0)
	radice.add_child(mi)
	var sigla: Label3D = scritta(sigle_lato[lato], 150, Color("1a1410"), Color(0, 0, 0, 0), 0)
	sigla.position = Vector3(0.0, 3.25, 0.02)
	radice.add_child(sigla)
	var numero: Label3D = scritta(str(resistenza[lato]), 190, Color("1a1410"), Color(0, 0, 0, 0), 0)
	numero.position = Vector3(0.0, 2.35, 0.02)
	radice.add_child(numero)
	var nome: Label3D = scritta(nomi_lato[lato].to_upper(), 60, Color("e9dcc0"), Color("000000"), 10)
	nome.position = Vector3(0.0, 0.9, 0.3)
	radice.add_child(nome)
	radice.scale = Vector3(1.0, 0.001, 1.0)
	_bandiere[lato] = radice
	_mat_bandiere[lato] = mat
	_numeri[lato] = numero


func _crea_riserva(lato: int) -> void:
	for c: int in range(5):
		var g: MeshInstance3D = MeshInstance3D.new()
		var cil: CylinderMesh = CylinderMesh.new()
		cil.radial_segments = 6
		cil.top_radius = 0.2
		cil.bottom_radius = 0.2
		cil.height = 0.16
		g.mesh = cil
		g.material_override = materiale_luce(COLORI_MANA[c], 0.25)
		var y: float = 0.16 if lato == 0 else 1.08
		var z: float = 6.4 if lato == 0 else -5.0
		g.position = Vector3(-6.4 + c * 0.62, y, z)
		add_child(g)
		_gemme[lato].append(g)
		var n: Label3D = scritta("0", 70, Color.WHITE, Color.BLACK, 10)
		n.position = g.position + Vector3(0.0, 0.42, 0.0)
		n.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		add_child(n)
		_conti[lato].append(n)


func _aggiorna_gemma(lato: int, c: int) -> void:
	var g: MeshInstance3D = _gemme[lato][c]
	(g.material_override as StandardMaterial3D).emission_energy_multiplier = 0.25 if riserva[lato][c] == 0 else 3.0
	(_conti[lato][c] as Label3D).text = str(riserva[lato][c])
	var t: Tween = create_tween()
	g.scale = Vector3(1.6, 1.6, 1.6)
	t.tween_property(g, "scale", Vector3.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func aggiorna(_delta: float) -> void:
	_lanterna.position.x = 1.0 + sin(tempo * 0.9) * 3.2
	_lanterna.position.z = 8.5 + cos(tempo * 0.7) * 1.0
	_lanterna.light_energy = 4.6 + sin(tempo * 13.0) * 0.12 + sin(tempo * 7.3) * 0.1


func intro() -> void:
	var cam: Tween = create_tween()
	cam.tween_method(func(t: float) -> void:
		var da: Vector3 = Vector3(-2.0, 15.0, 19.0)
		var a: Vector3 = Vector3(-0.6, 10.2, 13.2)
		_camera.look_at_from_position(da.lerp(a, t), Vector3(-0.3, 0.6, 0.1), Vector3.UP), 0.0, 1.0, 2.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	cam.tween_method(func(t: float) -> void:
		var da: Vector3 = Vector3(-0.6, 10.2, 13.2)
		var a: Vector3 = Vector3(0.2, 9.6, 12.4)
		_camera.look_at_from_position(da.lerp(a, t), Vector3(-0.3, 0.6, 0.1), Vector3.UP), 0.0, 1.0, 9.0)
	var ritardo: float = 0.15
	for lato: int in [0, 1]:
		var tb: Tween = create_tween()
		tb.tween_interval(0.1 + lato * 0.2)
		tb.tween_property(_bandiere[lato], "scale", Vector3.ONE, 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		for gruppo: Array in [_perni_edifici[lato], _perni_truppe[lato]]:
			for perno: Node3D in gruppo:
				var t: Tween = create_tween()
				t.tween_interval(ritardo)
				t.tween_property(perno, "rotation:x", 0.0, 0.55).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
				ritardo += 0.07


func _brace(lato_da: int, da: Vector3, a: Vector3, colore: Color, durata: float, all_arrivo: Callable) -> void:
	var palla: MeshInstance3D = MeshInstance3D.new()
	var s: SphereMesh = SphereMesh.new()
	s.radius = 0.13
	s.height = 0.26
	palla.mesh = s
	palla.material_override = materiale_luce(colore, 6.0)
	add_child(palla)
	palla.position = da
	var scia: CPUParticles3D = scintille(colore, 40, 0.4, 0.6, 0.5, 0.09)
	scia.one_shot = false
	scia.explosiveness = 0.0
	scia.local_coords = false
	palla.add_child(scia)
	scia.emitting = true
	var luce: OmniLight3D = OmniLight3D.new()
	luce.light_color = colore
	luce.light_energy = 1.5
	luce.omni_range = 3.0
	palla.add_child(luce)
	var alto: Vector3 = (da + a) * 0.5 + Vector3(0.0, 2.2, 0.0)
	var t: Tween = create_tween()
	t.tween_method(func(k: float) -> void:
		var p1: Vector3 = da.lerp(alto, k)
		var p2: Vector3 = alto.lerp(a, k)
		palla.position = p1.lerp(p2, k), 0.0, 1.0, durata).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_callback(func() -> void:
		scia.emitting = false
		palla.mesh = null
		luce.visible = false
		all_arrivo.call())
	t.tween_interval(0.6)
	t.tween_callback(palla.queue_free)
	var _x: int = lato_da


func _cima(perno: Node3D, altezza: float) -> Vector3:
	return perno.position + Vector3(0.0, altezza * 0.8, 0.0)


func produci(lato: int, edificio: int) -> void:
	var c: int = int(edifici_mana[lato][edificio])
	var perno: Node3D = _perni_edifici[lato][edificio]
	_lampo(_mat_edifici[lato][edificio], 0.4)
	_scossa(perno, 0.06)
	var arrivo: Vector3 = (_gemme[lato][c] as MeshInstance3D).position
	_brace(lato, _cima(perno, 1.8), arrivo, COLORI_MANA[c], 0.65, func() -> void:
		riserva[lato][c] += 1
		_aggiorna_gemma(lato, c))


func spendi(lato: int, truppa: int, colore: int, quanti: int) -> void:
	for k: int in range(quanti):
		var t: Tween = create_tween()
		t.tween_interval(k * 0.12)
		t.tween_callback(func() -> void:
			riserva[lato][colore] -= 1
			_aggiorna_gemma(lato, colore)
			var da: Vector3 = (_gemme[lato][colore] as MeshInstance3D).position
			_brace(lato, da, _cima(_perni_truppe[lato][truppa], 2.5), COLORI_MANA[colore], 0.35, func() -> void:
				_lampo(_mat_truppe[lato][truppa], 0.5)))


func attiva(lato: int, truppa: int) -> void:
	var perno: Node3D = _perni_truppe[lato][truppa]
	var segno: float = -1.0 if lato == 0 else 1.0
	var z0: float = perno.position.z
	var t: Tween = create_tween()
	t.set_parallel(true)
	t.tween_property(perno, "rotation:x", -0.42 if lato == 0 else 0.42, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(perno, "position:z", z0 + 0.9 * segno, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.chain().tween_property(perno, "rotation:x", 0.0, 0.35).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	t.tween_property(perno, "position:z", z0, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_lampo(_mat_truppe[lato][truppa], 0.9)
	var bersaglio: Node3D = _bandiere[1 - lato]
	_brace(lato, _cima(perno, 2.5), bersaglio.position + Vector3(0.0, 2.6, 0.0), Color("ffd27a"), 0.25, func() -> void: pass)


func colpisci(lato: int, danno: int) -> void:
	togli_resistenza(lato, danno)
	var bandiera: Node3D = _bandiere[lato]
	(_numeri[lato] as Label3D).text = str(resistenza[lato])
	_scossa(bandiera, 0.22)
	var centro: Vector3 = bandiera.position + Vector3(0.0, 2.7, 0.2)
	esplodi(self, centro, scintille(Color("ff8a2a"), 50, 4.5, 2.0, 0.9, 0.08))
	esplodi(self, centro, scintille(Color("e9dcc0"), 18, 3.5, -7.0, 1.1, 0.16))
	var mat: ShaderMaterial = _mat_bandiere[lato]
	var bruc: float = 0.42 * (1.0 - float(resistenza[lato]) / float(resistenza_max[lato]))
	var tb: Tween = create_tween()
	tb.tween_method(func(v: float) -> void: mat.set_shader_parameter("bruciatura", v), _bruciato[lato], bruc, 0.4)
	_bruciato[lato] = bruc
	var n: Label3D = scritta("−%d" % danno, 220, Color("ff4a3d"), Color("1a0505"), 26)
	n.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	n.position = centro + Vector3(0.9, 0.2, 0.6)
	add_child(n)
	var t: Tween = create_tween()
	t.set_parallel(true)
	n.scale = Vector3(0.3, 0.3, 0.3)
	t.tween_property(n, "scale", Vector3.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(n, "position:y", n.position.y + 1.4, 1.0)
	t.tween_property(n, "modulate:a", 0.0, 0.4).set_delay(0.6)
	t.tween_property(n, "outline_modulate:a", 0.0, 0.4).set_delay(0.6)
	t.chain().tween_callback(n.queue_free)


func scudo(lato: int, quanto: int) -> void:
	var n: Label3D = scritta("+%d scudo" % quanto, 110, Color("8fc0ff"), Color("06122a"), 18)
	n.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	n.position = (_bandiere[lato] as Node3D).position + Vector3(1.4, 1.4, 0.6)
	add_child(n)
	var t: Tween = create_tween()
	t.tween_property(n, "position:y", n.position.y + 1.0, 1.2)
	t.parallel().tween_property(n, "modulate:a", 0.0, 0.5).set_delay(0.7)
	t.parallel().tween_property(n, "outline_modulate:a", 0.0, 0.5).set_delay(0.7)
	t.tween_callback(n.queue_free)


func attesa(lato: int, truppa: int, attiva_ora: bool) -> void:
	var mat: ShaderMaterial = _mat_truppe[lato][truppa]
	var chiave: String = "%d_%d" % [lato, truppa]
	var t: Tween = create_tween()
	t.tween_method(func(v: float) -> void: mat.set_shader_parameter("spento", v), 1.0 if not attiva_ora else 0.0, 0.0 if not attiva_ora else 0.85, 0.25)
	if attiva_ora:
		var perno: Node3D = _perni_truppe[lato][truppa]
		var c: Label3D = scritta("IN ATTESA · manca 1 mana rosso", 64, Color("ffd9d0"), Color("6e0f0a"), 22)
		c.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		c.position = perno.position + Vector3(0.0, 3.0, 0.3)
		add_child(c)
		c.scale = Vector3(0.01, 0.01, 0.01)
		var tc: Tween = create_tween()
		tc.tween_property(c, "scale", Vector3.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_cartellini[chiave] = c
	elif _cartellini.has(chiave):
		var vecchio: Label3D = _cartellini[chiave]
		_cartellini.erase(chiave)
		var tc2: Tween = create_tween()
		tc2.tween_property(vecchio, "scale", Vector3(0.01, 0.01, 0.01), 0.15)
		tc2.tween_callback(vecchio.queue_free)


func sabotaggio(lato: int, truppa: int) -> void:
	var perno: Node3D = _perni_truppe[lato][truppa]
	var mat: ShaderMaterial = _mat_truppe[lato][truppa]
	mat.set_shader_parameter("spento", 0.6)
	_scossa(perno, 0.12)
	var nastro: MeshInstance3D = MeshInstance3D.new()
	var q: QuadMesh = QuadMesh.new()
	q.size = Vector2(2.9, 0.42)
	nastro.mesh = q
	var m: StandardMaterial3D = StandardMaterial3D.new()
	m.albedo_color = Color("e3ecf7")
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	nastro.material_override = m
	nastro.position = Vector3(0.0, 1.25, 0.06)
	nastro.rotation.z = -0.32
	perno.add_child(nastro)
	var l: Label3D = scritta("SABOTATO", 70, Color("1b2333"), Color(0, 0, 0, 0), 0)
	l.position = Vector3(0.0, 0.0, 0.01)
	nastro.add_child(l)
	nastro.scale = Vector3(0.01, 1.0, 1.0)
	var t: Tween = create_tween()
	t.tween_property(nastro, "scale", Vector3.ONE, 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	esplodi(self, perno.position + Vector3(0.0, 1.3, 0.2), scintille(Color("e3ecf7"), 30, 3.0, -2.0, 0.7, 0.07))


func vittoria(lato: int) -> void:
	var vinto: int = 1 - lato
	var ritardo: float = 0.0
	for gruppo: Array in [_perni_truppe[vinto], _perni_edifici[vinto]]:
		for perno: Node3D in gruppo:
			var t: Tween = create_tween()
			t.tween_interval(ritardo)
			t.tween_property(perno, "rotation:x", -PI * 0.5, 0.45).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
			ritardo += 0.08
	var mat: ShaderMaterial = _mat_bandiere[vinto]
	var tb: Tween = create_tween()
	tb.tween_method(func(v: float) -> void: mat.set_shader_parameter("bruciatura", v), 0.42, 1.05, 1.8)
	var bandiera: Node3D = _bandiere[vinto]
	for k: int in range(5):
		var te: Tween = create_tween()
		te.tween_interval(k * 0.3)
		te.tween_callback(func() -> void: esplodi(self, bandiera.position + Vector3(randf_range(-0.8, 0.8), 2.2 + randf() * 1.2, 0.2), scintille(Color("ff7a1a"), 40, 2.5, 3.0, 1.2, 0.09)))
	for c: Label3D in (_numeri[vinto] as Label3D).get_parent().get_children().filter(func(n: Node) -> bool: return n is Label3D):
		var tl: Tween = create_tween()
		tl.tween_property(c, "modulate:a", 0.0, 1.0).set_delay(0.6)
	var titolo: Label3D = scritta("VITTORIA", 420, Color("efe2c4"), Color("140d08"), 40)
	titolo.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	titolo.position = Vector3(1.0, 3.6, -1.0)
	titolo.scale = Vector3(0.01, 0.01, 0.01)
	add_child(titolo)
	var tt: Tween = create_tween()
	tt.tween_interval(0.9)
	tt.tween_property(titolo, "scale", Vector3.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var luce: Tween = create_tween()
	luce.tween_property(_lanterna, "light_color", Color("ffd38a"), 1.0)


func _lampo(mat: ShaderMaterial, forza: float) -> void:
	var t: Tween = create_tween()
	t.tween_method(func(v: float) -> void: mat.set_shader_parameter("lampo", v), forza, 0.0, 0.45)


func _scossa(nodo: Node3D, forza: float) -> void:
	var base: Vector3 = nodo.position
	var t: Tween = create_tween()
	for k: int in range(6):
		var spinta: Vector3 = Vector3(randf_range(-forza, forza), 0.0, randf_range(-forza, forza) * 0.5)
		t.tween_property(nodo, "position", base + spinta, 0.035)
	t.tween_property(nodo, "position", base, 0.05)
