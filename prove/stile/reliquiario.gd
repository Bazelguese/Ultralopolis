extends ProvaBase
## Prova 3: RELIQUIARIO. Due altari d'oro scuro, uno di fronte all'altro come un trittico aperto.
## Ogni carta sta in una nicchia; la Resistenza è una fila di candele che si spengono.

const CANDELE: int = 10

var _camera: Camera3D
var _altari: Array = [null, null]
var _luci_altare: Array = [null, null]
var _nicchie_truppe: Array = [[], []]
var _mat_truppe: Array = [[], []]
var _nicchie_edifici: Array = [[], []]
var _mat_edifici: Array = [[], []]
var _fiamme: Array = [[], []]
var _fiamme_nicchie: Array = [[], []]
var _numeri: Array = [null, null]
var _gemme: Array = [[], []]
var _conti: Array = [[], []]
var _cartellini: Dictionary = {}
var _mat_oro: StandardMaterial3D
var _mat_cornice: StandardMaterial3D
var _mat_fiamma: StandardMaterial3D
var _raggio: MeshInstance3D
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func costruisci() -> void:
	_rng.seed = 11
	var amb: Environment = Environment.new()
	amb.background_mode = Environment.BG_COLOR
	amb.background_color = Color("050404")
	amb.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	amb.ambient_light_color = Color("2a2018")
	amb.ambient_light_energy = 0.4
	amb.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	amb.glow_enabled = true
	amb.glow_intensity = 0.9
	amb.glow_bloom = 0.12
	amb.fog_enabled = true
	amb.fog_light_color = Color("120d09")
	amb.fog_density = 0.025
	var we: WorldEnvironment = WorldEnvironment.new()
	we.environment = amb
	add_child(we)

	_camera = Camera3D.new()
	_camera.fov = 44.0
	add_child(_camera)
	_camera.look_at_from_position(Vector3(0.0, 5.0, 25.0), Vector3(0.0, 3.6, 0.0), Vector3.UP)

	var luna: DirectionalLight3D = DirectionalLight3D.new()
	luna.light_color = Color("6f86c8")
	luna.light_energy = 0.3
	luna.rotation_degrees = Vector3(-50.0, 180.0, 0.0)
	add_child(luna)

	_mat_oro = StandardMaterial3D.new()
	_mat_oro.albedo_color = Color("4d3818")
	_mat_oro.metallic = 0.85
	_mat_oro.roughness = 0.38
	var n: NoiseTexture2D = NoiseTexture2D.new()
	var fn: FastNoiseLite = FastNoiseLite.new()
	fn.frequency = 0.05
	n.noise = fn
	_mat_oro.albedo_texture = n
	_mat_cornice = StandardMaterial3D.new()
	_mat_cornice.albedo_color = Color("c9a14a")
	_mat_cornice.metallic = 0.9
	_mat_cornice.roughness = 0.25
	_mat_cornice.emission_enabled = true
	_mat_cornice.emission = Color("c9a14a")
	_mat_cornice.emission_energy_multiplier = 0.05
	_mat_fiamma = materiale_luce(Color("ffb24a"), 9.0)
	_mat_fiamma.albedo_texture = _fiamma_tex()
	_mat_fiamma.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_mat_fiamma.billboard_mode = BaseMaterial3D.BILLBOARD_FIXED_Y

	# Pavimento di pietra lucida.
	var pav: MeshInstance3D = MeshInstance3D.new()
	var pm: PlaneMesh = PlaneMesh.new()
	pm.size = Vector2(80.0, 80.0)
	pav.mesh = pm
	var mp: StandardMaterial3D = StandardMaterial3D.new()
	mp.albedo_color = Color("16120f")
	mp.roughness = 0.22
	mp.metallic_specular = 0.8
	pav.material_override = mp
	add_child(pav)

	for lato: int in [0, 1]:
		_crea_altare(lato)
	strato_grana(0.045, "Prova di stile 3 · Reliquiario — scontro finto, solo per vedere aspetto e animazioni")


func _scatola(genitore: Node3D, dim: Vector3, pos: Vector3, mat: Material) -> MeshInstance3D:
	var m: MeshInstance3D = MeshInstance3D.new()
	var b: BoxMesh = BoxMesh.new()
	b.size = dim
	m.mesh = b
	m.material_override = mat
	m.position = pos
	genitore.add_child(m)
	return m


func _crea_altare(lato: int) -> void:
	var radice: Node3D = Node3D.new()
	var segno: float = -1.0 if lato == 0 else 1.0
	radice.position = Vector3(5.6 * segno, 0.0, 0.0)
	radice.rotation.y = deg_to_rad(-30.0 * segno)
	add_child(radice)
	_altari[lato] = radice
	# Pala, frontone e gradini.
	_scatola(radice, Vector3(8.6, 7.6, 0.5), Vector3(0.0, 4.6, 0.0), _mat_oro)
	var frontone: MeshInstance3D = _scatola(radice, Vector3(4.6, 4.6, 0.45), Vector3(0.0, 8.2, -0.02), _mat_oro)
	frontone.rotation.z = PI * 0.25
	frontone.scale = Vector3(1.3, 1.0, 1.0)
	_scatola(radice, Vector3(9.4, 0.8, 2.2), Vector3(0.0, 0.4, 0.6), _mat_oro)
	_scatola(radice, Vector3(9.0, 0.08, 0.12), Vector3(0.0, 0.84, 1.62), _mat_cornice)
	_scatola(radice, Vector3(8.8, 0.1, 0.5), Vector3(0.0, 1.55, 0.45), _mat_cornice)
	# Colonnine.
	for x: float in [-4.15, 4.15]:
		_scatola(radice, Vector3(0.3, 7.4, 0.3), Vector3(x, 4.6, 0.35), _mat_cornice)

	for i: int in range(4):
		var pos: Vector3 = Vector3(-3.0 + i * 2.0, 3.1, 0.26)
		var dati: Array = _nicchia(radice, String(truppe_arte[lato][i]), pos, 1.65)
		_nicchie_truppe[lato].append(dati[0])
		_mat_truppe[lato].append(dati[1])
		_fiamme_nicchie[lato].append(_candela(radice, Vector3(pos.x, 1.6, 0.55), 0.32))
	var edifici: Array = edifici_arte[lato]
	for i: int in range(edifici.size()):
		var x: float = (-2.2 + i * 2.2) if edifici.size() == 3 else (-1.1 + i * 2.2)
		var dati2: Array = _nicchia(radice, String(edifici[i]), Vector3(x, 5.85, 0.26), 1.5)
		_nicchie_edifici[lato].append(dati2[0])
		_mat_edifici[lato].append(dati2[1])
	# Le candele della Resistenza sul gradino.
	for k: int in range(CANDELE):
		_fiamme[lato].append(_candela(radice, Vector3(-3.6 + k * 0.8, 0.8, 1.15), 0.5))
	var numero: Label3D = scritta(str(resistenza[lato]), 170, Color("ecd08a"), Color("1a1206"), 12)
	numero.position = Vector3(0.0, 0.4, 1.73)
	radice.add_child(numero)
	_numeri[lato] = numero
	var nome: Label3D = scritta(nomi_lato[lato].to_upper(), 64, Color("ecd08a"), Color("1a1206"), 10)
	nome.position = Vector3(0.0, 7.35, 0.3)
	radice.add_child(nome)
	var stemma: Label3D = scritta(sigle_lato[lato], 120, Color("2f5fb8") if lato == 0 else Color("b3261e"), Color("ecd08a"), 14)
	stemma.position = Vector3(0.0, 8.4, 0.3)
	radice.add_child(stemma)
	# Riserva di mana: gemme che fluttuano davanti alla pala.
	for c: int in range(5):
		var g: MeshInstance3D = MeshInstance3D.new()
		var s: SphereMesh = SphereMesh.new()
		s.radius = 0.16
		s.height = 0.32
		g.mesh = s
		g.material_override = materiale_luce(COLORI_MANA[c], 0.3)
		g.position = Vector3(-1.6 + c * 0.8, 4.45, 0.7)
		radice.add_child(g)
		_gemme[lato].append(g)
		var cn: Label3D = scritta("0", 60, Color.WHITE, Color.BLACK, 8)
		cn.position = g.position + Vector3(0.0, -0.32, 0.05)
		radice.add_child(cn)
		_conti[lato].append(cn)
	var luce: OmniLight3D = OmniLight3D.new()
	luce.light_color = Color("ffb067")
	luce.light_energy = 0.0
	luce.omni_range = 11.0
	luce.shadow_enabled = true
	luce.position = Vector3(0.0, 2.6, 3.4)
	radice.add_child(luce)
	_luci_altare[lato] = luce


func _nicchia(altare: Node3D, id: String, pos: Vector3, lato_n: float) -> Array:
	var radice: Node3D = Node3D.new()
	radice.position = pos
	altare.add_child(radice)
	_scatola(radice, Vector3(lato_n + 0.3, lato_n + 0.3, 0.06), Vector3(0.0, 0.0, -0.02), _materiale_nero())
	var spessore: float = 0.12
	_scatola(radice, Vector3(lato_n + 0.36, spessore, 0.22), Vector3(0.0, lato_n * 0.5 + 0.12, 0.08), _mat_cornice)
	_scatola(radice, Vector3(lato_n + 0.36, spessore, 0.22), Vector3(0.0, -lato_n * 0.5 - 0.12, 0.08), _mat_cornice)
	_scatola(radice, Vector3(spessore, lato_n + 0.36, 0.22), Vector3(lato_n * 0.5 + 0.12, 0.0, 0.08), _mat_cornice)
	_scatola(radice, Vector3(spessore, lato_n + 0.36, 0.22), Vector3(-lato_n * 0.5 - 0.12, 0.0, 0.08), _mat_cornice)
	var q: QuadMesh = QuadMesh.new()
	q.size = Vector2(lato_n, lato_n)
	var mi: MeshInstance3D = MeshInstance3D.new()
	mi.mesh = q
	var tex: ImageTexture = immagine("arte", id)
	var m: StandardMaterial3D = StandardMaterial3D.new()
	m.albedo_texture = tex
	m.roughness = 0.7
	m.emission_enabled = true
	m.emission_texture = tex
	m.emission = Color.WHITE
	m.emission_energy_multiplier = 0.0
	mi.material_override = m
	mi.position.z = 0.02
	radice.add_child(mi)
	return [radice, m]


func _fiamma_tex() -> ImageTexture:
	var img: Image = Image.create(64, 128, false, Image.FORMAT_RGBA8)
	for y: int in range(128):
		for x: int in range(64):
			var v: float = float(y) / 127.0
			var larg: float = 0.5 * sin(clampf(v, 0.0, 1.0) * PI * 0.85 + 0.25)
			var dx: float = absf(float(x) - 31.5) / 32.0
			var a: float = clampf((larg - dx) * 6.0, 0.0, 1.0)
			var nucleo: float = clampf((larg * 0.45 - dx) * 8.0, 0.0, 1.0) * clampf(v * 2.0 - 0.6, 0.0, 1.0)
			img.set_pixel(x, y, Color(1.0, 0.7 + nucleo * 0.3, 0.35 + nucleo * 0.6, a))
	return ImageTexture.create_from_image(img)


func _materiale_nero() -> StandardMaterial3D:
	var m: StandardMaterial3D = StandardMaterial3D.new()
	m.albedo_color = Color("050404")
	return m


func _candela(altare: Node3D, pos: Vector3, altezza: float) -> MeshInstance3D:
	var cera: MeshInstance3D = MeshInstance3D.new()
	var c: CylinderMesh = CylinderMesh.new()
	c.top_radius = 0.07
	c.bottom_radius = 0.08
	c.height = altezza
	cera.mesh = c
	var mc: StandardMaterial3D = StandardMaterial3D.new()
	mc.albedo_color = Color("e8dcc0")
	mc.emission_enabled = true
	mc.emission = Color("ffb067")
	mc.emission_energy_multiplier = 0.15
	cera.material_override = mc
	cera.position = pos + Vector3(0.0, altezza * 0.5, 0.0)
	altare.add_child(cera)
	var f: MeshInstance3D = MeshInstance3D.new()
	var q: QuadMesh = QuadMesh.new()
	q.size = Vector2(0.24, 0.46)
	f.mesh = q
	f.material_override = _mat_fiamma
	f.position = Vector3(0.0, altezza * 0.5 + 0.22, 0.0)
	f.scale = Vector3(0.001, 0.001, 0.001)
	cera.add_child(f)
	return f


func _pos(nodo: Node3D, spinta: Vector3 = Vector3.ZERO) -> Vector3:
	return nodo.to_global(spinta)


func aggiorna(_delta: float) -> void:
	for lato: int in [0, 1]:
		for gruppo: Array in [_fiamme[lato], _fiamme_nicchie[lato]]:
			for k: int in range(gruppo.size()):
				var f: MeshInstance3D = gruppo[k]
				if f.has_meta("accesa"):
					var v: float = 1.0 + sin(tempo * 17.0 + k * 1.7) * 0.12 + sin(tempo * 9.0 + k) * 0.08
					f.scale = Vector3(1.0, v, 1.0)
		var luce: OmniLight3D = _luci_altare[lato]
		if luce.has_meta("base"):
			luce.light_energy = float(luce.get_meta("base")) * (1.0 + sin(tempo * 11.0 + lato) * 0.05)


func _accendi(f: MeshInstance3D, ritardo: float) -> void:
	var t: Tween = create_tween()
	t.tween_interval(ritardo)
	t.tween_property(f, "scale", Vector3.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_callback(func() -> void: f.set_meta("accesa", true))


func _spegni(f: MeshInstance3D) -> void:
	if not f.has_meta("accesa"):
		return
	f.remove_meta("accesa")
	var t: Tween = create_tween()
	t.tween_property(f, "scale", Vector3(0.001, 0.001, 0.001), 0.18)
	var fumo: CPUParticles3D = scintille(Color(0.55, 0.52, 0.5, 0.6), 14, 0.3, 1.4, 1.4, 0.12)
	fumo.explosiveness = 0.3
	(fumo.mesh.material as StandardMaterial3D).blend_mode = BaseMaterial3D.BLEND_MODE_MIX
	esplodi(self, f.global_position, fumo)


func _imposta_luce(lato: int, valore: float, durata: float) -> void:
	var luce: OmniLight3D = _luci_altare[lato]
	luce.set_meta("base", valore)
	var t: Tween = create_tween()
	t.tween_property(luce, "light_energy", valore, durata)


func intro() -> void:
	var cam: Tween = create_tween()
	cam.tween_method(func(k: float) -> void:
		_camera.look_at_from_position(Vector3(0.0, 5.0, 25.0).lerp(Vector3(0.0, 4.2, 15.5), k), Vector3(0.0, 3.6, 0.0), Vector3.UP), 0.0, 1.0, 2.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	cam.tween_method(func(k: float) -> void:
		_camera.look_at_from_position(Vector3(0.0, 4.2, 15.5).lerp(Vector3(-0.8, 4.0, 14.0), k), Vector3(0.0, 3.6, 0.0), Vector3.UP), 0.0, 1.0, 9.0)
	for lato: int in [0, 1]:
		_imposta_luce(lato, 2.6, 1.6)
		var r: float = 0.2 + lato * 0.15
		for f: MeshInstance3D in _fiamme[lato]:
			_accendi(f, r)
			r += 0.06
		for f2: MeshInstance3D in _fiamme_nicchie[lato]:
			_accendi(f2, r)
			r += 0.06
		for gruppo: Array in [_mat_truppe[lato], _mat_edifici[lato]]:
			for m: StandardMaterial3D in gruppo:
				var t: Tween = create_tween()
				t.tween_interval(r)
				t.tween_property(m, "emission_energy_multiplier", 0.6, 0.15)
				t.tween_property(m, "emission_energy_multiplier", 0.12, 0.6)
				r += 0.05


func _bagliore(m: StandardMaterial3D, forza: float) -> void:
	var t: Tween = create_tween()
	t.tween_property(m, "emission_energy_multiplier", forza, 0.07)
	t.tween_property(m, "emission_energy_multiplier", 0.12, 0.5)


func _lume(da: Vector3, a: Vector3, colore: Color, durata: float, all_arrivo: Callable) -> void:
	var palla: MeshInstance3D = MeshInstance3D.new()
	var s: SphereMesh = SphereMesh.new()
	s.radius = 0.1
	s.height = 0.2
	palla.mesh = s
	palla.material_override = materiale_luce(colore, 7.0)
	add_child(palla)
	palla.position = da
	var scia: CPUParticles3D = scintille(colore, 50, 0.3, 0.5, 0.6, 0.07)
	scia.one_shot = false
	scia.explosiveness = 0.0
	scia.local_coords = false
	palla.add_child(scia)
	scia.emitting = true
	var alto: Vector3 = (da + a) * 0.5 + Vector3(0.0, 1.0, 0.8)
	var t: Tween = create_tween()
	t.tween_method(func(k: float) -> void:
		palla.position = da.lerp(alto, k).lerp(alto.lerp(a, k), k), 0.0, 1.0, durata).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_callback(func() -> void:
		scia.emitting = false
		palla.mesh = null
		all_arrivo.call())
	t.tween_interval(0.7)
	t.tween_callback(palla.queue_free)


func _aggiorna_gemma(lato: int, c: int) -> void:
	var g: MeshInstance3D = _gemme[lato][c]
	(g.material_override as StandardMaterial3D).emission_energy_multiplier = 0.3 if riserva[lato][c] == 0 else 4.0
	(_conti[lato][c] as Label3D).text = str(riserva[lato][c])
	g.scale = Vector3(1.8, 1.8, 1.8)
	var t: Tween = create_tween()
	t.tween_property(g, "scale", Vector3.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func produci(lato: int, edificio: int) -> void:
	var c: int = int(edifici_mana[lato][edificio])
	_bagliore(_mat_edifici[lato][edificio], 0.6)
	var da: Vector3 = _pos(_nicchie_edifici[lato][edificio], Vector3(0.0, -0.5, 0.3))
	_lume(da, (_gemme[lato][c] as MeshInstance3D).global_position, COLORI_MANA[c], 0.6, func() -> void:
		riserva[lato][c] += 1
		_aggiorna_gemma(lato, c))


func spendi(lato: int, truppa: int, colore: int, quanti: int) -> void:
	for k: int in range(quanti):
		var t: Tween = create_tween()
		t.tween_interval(k * 0.12)
		t.tween_callback(func() -> void:
			riserva[lato][colore] -= 1
			_aggiorna_gemma(lato, colore)
			_lume((_gemme[lato][colore] as MeshInstance3D).global_position, _pos(_nicchie_truppe[lato][truppa], Vector3(0.0, 0.0, 0.3)), COLORI_MANA[colore], 0.35, func() -> void:
				_bagliore(_mat_truppe[lato][truppa], 0.5)))


func attiva(lato: int, truppa: int) -> void:
	_bagliore(_mat_truppe[lato][truppa], 0.75)
	var nicchia: Node3D = _nicchie_truppe[lato][truppa]
	var da: Vector3 = _pos(nicchia, Vector3(0.0, 0.0, 0.4))
	var a: Vector3 = _pos(_altari[1 - lato], Vector3(0.0, 3.3, 0.8))
	# Raggio d'oro fra i due altari.
	var raggio: MeshInstance3D = MeshInstance3D.new()
	var c: CylinderMesh = CylinderMesh.new()
	c.top_radius = 0.035
	c.bottom_radius = 0.035
	c.height = 1.0
	raggio.mesh = c
	var mr: StandardMaterial3D = materiale_luce(Color("ffd27a"), 8.0)
	mr.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	raggio.material_override = mr
	add_child(raggio)
	var lung: float = da.distance_to(a)
	var t: Tween = create_tween()
	t.tween_method(func(k: float) -> void:
		var fine: Vector3 = da.lerp(a, k)
		raggio.global_position = (da + fine) * 0.5
		raggio.look_at(fine, Vector3.UP)
		raggio.rotate_object_local(Vector3.RIGHT, PI * 0.5)
		raggio.scale = Vector3(1.0, maxf(lung * k, 0.01), 1.0), 0.02, 1.0, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.tween_callback(func() -> void: esplodi(self, a, scintille(Color("ffd27a"), 40, 4.0, -3.0, 0.7, 0.07)))
	t.tween_property(mr, "albedo_color:a", 0.0, 0.25)
	t.tween_callback(raggio.queue_free)


func colpisci(lato: int, danno: int) -> void:
	togli_resistenza(lato, danno)
	var altare: Node3D = _altari[lato]
	(_numeri[lato] as Label3D).text = str(resistenza[lato])
	var accese: int = ceili(float(CANDELE) * float(resistenza[lato]) / float(resistenza_max[lato]))
	for k: int in range(CANDELE - 1, accese - 1, -1):
		_spegni(_fiamme[lato][k])
	_imposta_luce(lato, 0.6 + 2.0 * float(accese) / float(CANDELE), 0.4)
	# Lampo rosso sull'altare colpito.
	var rosso: OmniLight3D = OmniLight3D.new()
	rosso.light_color = Color("ff3a2a")
	rosso.light_energy = 6.0
	rosso.omni_range = 9.0
	rosso.position = Vector3(0.0, 3.5, 2.0)
	altare.add_child(rosso)
	var t: Tween = create_tween()
	t.tween_property(rosso, "light_energy", 0.0, 0.45)
	t.tween_callback(rosso.queue_free)
	var base: Vector3 = altare.position
	var ts: Tween = create_tween()
	for k: int in range(5):
		ts.tween_property(altare, "position", base + Vector3(_rng.randf_range(-0.08, 0.08), 0.0, _rng.randf_range(-0.05, 0.05)), 0.035)
	ts.tween_property(altare, "position", base, 0.05)
	var n: Label3D = scritta("−%d" % danno, 230, Color("ff4a3d"), Color("1a0505"), 26)
	n.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(n)
	n.global_position = _pos(altare, Vector3(0.0, 3.4, 2.8))
	var t2: Tween = create_tween()
	n.scale = Vector3(0.3, 0.3, 0.3)
	t2.tween_property(n, "scale", Vector3.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t2.parallel().tween_property(n, "position:y", n.position.y + 1.3, 1.0)
	t2.parallel().tween_property(n, "modulate:a", 0.0, 0.35).set_delay(0.65)
	t2.parallel().tween_property(n, "outline_modulate:a", 0.0, 0.35).set_delay(0.65)
	t2.tween_callback(n.queue_free)


func scudo(lato: int, quanto: int) -> void:
	var n: Label3D = scritta("+%d scudo" % quanto, 110, Color("8fc0ff"), Color("06122a"), 18)
	n.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(n)
	n.global_position = _pos(_altari[lato], Vector3(2.2, 1.6, 1.8))
	var t: Tween = create_tween()
	t.tween_property(n, "position:y", n.position.y + 1.0, 1.1)
	t.parallel().tween_property(n, "modulate:a", 0.0, 0.4).set_delay(0.7)
	t.parallel().tween_property(n, "outline_modulate:a", 0.0, 0.4).set_delay(0.7)
	t.tween_callback(n.queue_free)


func attesa(lato: int, truppa: int, attiva_ora: bool) -> void:
	var m: StandardMaterial3D = _mat_truppe[lato][truppa]
	var chiave: String = "%d_%d" % [lato, truppa]
	var t: Tween = create_tween()
	t.tween_property(m, "albedo_color", Color(0.3, 0.3, 0.32) if attiva_ora else Color.WHITE, 0.25)
	if attiva_ora:
		_spegni(_fiamme_nicchie[lato][truppa])
		var c: Label3D = scritta("IN ATTESA\nmanca 1 mana rosso", 52, Color("ffd9d0"), Color("6e0f0a"), 18)
		c.position = Vector3(0.0, -1.25, 0.5)
		(_nicchie_truppe[lato][truppa] as Node3D).add_child(c)
		c.scale = Vector3(0.01, 0.01, 0.01)
		var tc: Tween = create_tween()
		tc.tween_property(c, "scale", Vector3.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_cartellini[chiave] = c
	elif _cartellini.has(chiave):
		var vecchio: Label3D = _cartellini[chiave]
		_cartellini.erase(chiave)
		_accendi(_fiamme_nicchie[lato][truppa], 0.0)
		var tc2: Tween = create_tween()
		tc2.tween_property(vecchio, "scale", Vector3(0.01, 0.01, 0.01), 0.15)
		tc2.tween_callback(vecchio.queue_free)


func sabotaggio(lato: int, truppa: int) -> void:
	var nicchia: Node3D = _nicchie_truppe[lato][truppa]
	var velo: MeshInstance3D = MeshInstance3D.new()
	var q: QuadMesh = QuadMesh.new()
	q.size = Vector2(1.7, 1.7)
	velo.mesh = q
	var m: StandardMaterial3D = materiale_luce(Color(0.89, 0.93, 0.97, 0.55), 1.0)
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	velo.material_override = m
	velo.position.z = 0.12
	nicchia.add_child(velo)
	var l: Label3D = scritta("SABOTATO", 64, Color("1b2333"), Color("e3ecf7"), 14)
	l.position = Vector3(0.0, 0.0, 0.16)
	nicchia.add_child(l)
	_spegni(_fiamme_nicchie[lato][truppa])
	velo.scale = Vector3(0.01, 0.01, 1.0)
	var t: Tween = create_tween()
	t.tween_property(velo, "scale", Vector3.ONE, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	esplodi(self, _pos(nicchia, Vector3(0.0, 0.0, 0.3)), scintille(Color("e3ecf7"), 36, 2.5, -1.0, 0.8, 0.06))


func vittoria(lato: int) -> void:
	var vinto: int = 1 - lato
	for f: MeshInstance3D in _fiamme_nicchie[vinto]:
		_spegni(f)
	_imposta_luce(vinto, 0.0, 1.2)
	for gruppo: Array in [_mat_truppe[vinto], _mat_edifici[vinto]]:
		for m: StandardMaterial3D in gruppo:
			var t: Tween = create_tween()
			t.tween_property(m, "albedo_color", Color(0.12, 0.1, 0.1), 1.2)
	_imposta_luce(lato, 4.2, 1.2)
	var titolo: Label3D = scritta("VITTORIA", 380, Color("ecd08a"), Color("1a1206"), 30)
	titolo.position = Vector3(0.0, 8.4, 2.0)
	titolo.modulate.a = 0.0
	titolo.outline_modulate.a = 0.0
	add_child(titolo)
	var tt: Tween = create_tween()
	tt.tween_interval(0.8)
	tt.tween_property(titolo, "position:y", 7.6, 0.9).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tt.parallel().tween_property(titolo, "modulate:a", 1.0, 0.6)
	tt.parallel().tween_property(titolo, "outline_modulate:a", 1.0, 0.6)
	for k: int in range(6):
		var te: Tween = create_tween()
		te.tween_interval(0.9 + k * 0.15)
		te.tween_callback(func() -> void: esplodi(self, Vector3(_rng.randf_range(-4.0, 4.0), 7.6 + _rng.randf_range(-0.5, 0.8), 2.0), scintille(Color("ffd27a"), 30, 2.0, -1.5, 1.2, 0.06)))
