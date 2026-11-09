extends ProvaBase
## Prova 2: LASTRA DA STAMPA. Vista dall'alto: due matrici di legno inciso su un foglio.
## Le carte vengono "stampate", ogni attivazione è un colpo di timbro, il danno è inchiostro rosso
## che schizza e resta sulla lastra nemica.

var _camera: Camera3D
var _fondo: MeshInstance3D
var _mat_fondo: StandardMaterial3D
var _carte_truppe: Array = [[], []]
var _carte_edifici: Array = [[], []]
var _numeri: Array = [null, null]
var _gemme: Array = [[], []]
var _conti: Array = [[], []]
var _cartellini: Dictionary = {}
var _tex_cerchio: ImageTexture
var _tex_anello: ImageTexture
var _tex_macchie: Array[ImageTexture] = []
var _tex_tratteggio: ImageTexture
var _scossa_camera: float = 0.0
var _pos_camera: Vector3 = Vector3(0.6, 20.5, 8.6)
var _mira: Vector3 = Vector3(0.6, 0.0, 0.5)
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func costruisci() -> void:
	_rng.seed = 7
	_prepara_texture()
	var amb: Environment = Environment.new()
	amb.background_mode = Environment.BG_COLOR
	amb.background_color = Color("0c0907")
	amb.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	amb.ambient_light_color = Color("fff0d8")
	amb.ambient_light_energy = 0.55
	amb.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	amb.glow_enabled = true
	amb.glow_intensity = 0.4
	var we: WorldEnvironment = WorldEnvironment.new()
	we.environment = amb
	add_child(we)

	_camera = Camera3D.new()
	_camera.fov = 40.0
	add_child(_camera)
	_camera.look_at_from_position(_pos_camera + Vector3(0.0, 6.0, 2.0), _mira, Vector3.UP)

	var sole: DirectionalLight3D = DirectionalLight3D.new()
	sole.light_color = Color("ffe2b8")
	sole.light_energy = 1.25
	sole.shadow_enabled = true
	sole.rotation_degrees = Vector3(-58.0, -32.0, 0.0)
	add_child(sole)

	# Il foglio sotto le lastre: ocra durante il Consiglio, rosso scuro nello scontro.
	_fondo = MeshInstance3D.new()
	var piano: PlaneMesh = PlaneMesh.new()
	piano.size = Vector2(80.0, 60.0)
	_fondo.mesh = piano
	_mat_fondo = StandardMaterial3D.new()
	_mat_fondo.albedo_color = Color("c99a3e")
	_mat_fondo.albedo_texture = _carta()
	_mat_fondo.roughness = 1.0
	_fondo.material_override = _mat_fondo
	_fondo.position.y = -0.62
	add_child(_fondo)

	for lato: int in [0, 1]:
		var segno: float = 1.0 if lato == 0 else -1.0
		var blocco: MeshInstance3D = MeshInstance3D.new()
		var b: BoxMesh = BoxMesh.new()
		b.size = Vector3(17.5, 0.6, 6.6)
		blocco.mesh = b
		var mb: StandardMaterial3D = StandardMaterial3D.new()
		mb.albedo_color = Color("2a1a10") if lato == 0 else Color("21130d")
		mb.albedo_texture = _venature()
		mb.roughness = 0.32
		mb.metallic_specular = 0.7
		blocco.material_override = mb
		blocco.position = Vector3(0.6, -0.3, 3.65 * segno)
		add_child(blocco)
		# Filetto inciso attorno alla lastra.
		var filetto: MeshInstance3D = MeshInstance3D.new()
		var bf: BoxMesh = BoxMesh.new()
		bf.size = Vector3(16.9, 0.02, 6.0)
		filetto.mesh = bf
		var mf: StandardMaterial3D = StandardMaterial3D.new()
		mf.albedo_color = Color("c99a3e") if lato == 0 else Color("8e2a24")
		filetto.material_override = mf
		filetto.position = Vector3(0.6, 0.0, 3.65 * segno)
		add_child(filetto)
		var dentro: MeshInstance3D = MeshInstance3D.new()
		var bd: BoxMesh = BoxMesh.new()
		bd.size = Vector3(16.6, 0.03, 5.7)
		dentro.mesh = bd
		dentro.material_override = mb
		dentro.position = filetto.position
		add_child(dentro)

		for i: int in range(4):
			var carta: Node3D = _carta_stampata(String(truppe_arte[lato][i]), Vector3(-2.3 + i * 2.45, 0.03, 1.95 * segno), 2.05)
			_carte_truppe[lato].append(carta)
		var edifici: Array = edifici_arte[lato]
		for i: int in range(edifici.size()):
			var carta2: Node3D = _carta_stampata(String(edifici[i]), Vector3(-1.4 + i * 2.6, 0.03, 5.15 * segno), 1.6)
			_carte_edifici[lato].append(carta2)
		_crea_numero(lato)
		_crea_riserva(lato)
	strato_grana(0.06, "Prova di stile 2 · Lastra da stampa — scontro finto, solo per vedere aspetto e animazioni")


# --- Texture fatte a mano ------------------------------------------------------

func _prepara_texture() -> void:
	_tex_cerchio = _disegna(128, func(img: Image) -> void:
		for y: int in range(128):
			for x: int in range(128):
				var d: float = Vector2(x - 64, y - 64).length()
				img.set_pixel(x, y, Color(1, 1, 1, clampf((60.0 - d) / 3.0, 0.0, 1.0))))
	_tex_anello = _disegna(128, func(img: Image) -> void:
		for y: int in range(128):
			for x: int in range(128):
				var d: float = Vector2(x - 64, y - 64).length()
				img.set_pixel(x, y, Color(1, 1, 1, clampf(1.0 - absf(d - 54.0) / 6.0, 0.0, 1.0))))
	for k: int in range(4):
		_tex_macchie.append(_disegna(256, func(img: Image) -> void:
			var punti: Array = []
			for n: int in range(14):
				punti.append([Vector2(128, 128) + Vector2.from_angle(_rng.randf() * TAU) * _rng.randf_range(0.0, 46.0), _rng.randf_range(22.0, 48.0)])
			for n: int in range(22):
				var dir: Vector2 = Vector2.from_angle(_rng.randf() * TAU)
				punti.append([Vector2(128, 128) + dir * _rng.randf_range(60.0, 118.0), _rng.randf_range(3.0, 11.0)])
			for y: int in range(256):
				for x: int in range(256):
					var a: float = 0.0
					for p: Array in punti:
						var d: float = Vector2(x, y).distance_to(p[0])
						a = maxf(a, clampf((float(p[1]) - d) / 2.0, 0.0, 1.0))
					img.set_pixel(x, y, Color(1, 1, 1, a))))
	_tex_tratteggio = _disegna(128, func(img: Image) -> void:
		for y: int in range(128):
			for x: int in range(128):
				var striscia: bool = ((x + y) / 12) % 2 == 0
				img.set_pixel(x, y, Color(0.05, 0.03, 0.02, 0.72 if striscia else 0.38)))


func _disegna(lato_px: int, pennello: Callable) -> ImageTexture:
	var img: Image = Image.create(lato_px, lato_px, false, Image.FORMAT_RGBA8)
	pennello.call(img)
	img.generate_mipmaps()
	return ImageTexture.create_from_image(img)


func _carta() -> NoiseTexture2D:
	var t: NoiseTexture2D = NoiseTexture2D.new()
	t.width = 512
	t.height = 512
	var n: FastNoiseLite = FastNoiseLite.new()
	n.frequency = 0.06
	n.fractal_octaves = 5
	t.noise = n
	var g: Gradient = Gradient.new()
	g.set_color(0, Color(0.8, 0.78, 0.74))
	g.set_color(1, Color(1, 1, 1))
	t.color_ramp = g
	return t


func _venature() -> NoiseTexture2D:
	var t: NoiseTexture2D = NoiseTexture2D.new()
	t.width = 512
	t.height = 512
	var n: FastNoiseLite = FastNoiseLite.new()
	n.noise_type = FastNoiseLite.TYPE_CELLULAR
	n.frequency = 0.01
	n.domain_warp_enabled = true
	n.domain_warp_amplitude = 40.0
	t.noise = n
	var g: Gradient = Gradient.new()
	g.set_color(0, Color(0.55, 0.5, 0.48))
	g.set_color(1, Color(1, 1, 1))
	t.color_ramp = g
	return t


func _piatto(tex: Texture2D, misura: Vector2, colore: Color, luce: bool = false) -> MeshInstance3D:
	var mi: MeshInstance3D = MeshInstance3D.new()
	var q: QuadMesh = QuadMesh.new()
	q.size = misura
	q.orientation = PlaneMesh.FACE_Y
	mi.mesh = q
	var m: StandardMaterial3D = StandardMaterial3D.new()
	m.albedo_texture = tex
	m.albedo_color = colore
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.roughness = 0.5
	if luce:
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mi.material_override = m
	return mi


# --- Pezzi ---------------------------------------------------------------------

func _carta_stampata(id: String, pos: Vector3, lato_carta: float) -> Node3D:
	var radice: Node3D = Node3D.new()
	radice.position = pos
	add_child(radice)
	var bordo: MeshInstance3D = _piatto(null, Vector2(lato_carta + 0.22, lato_carta + 0.22), Color("efe4cc"))
	radice.add_child(bordo)
	var arte: MeshInstance3D = _piatto(immagine("arte", id), Vector2(lato_carta, lato_carta), Color.WHITE)
	arte.position.y = 0.01
	radice.add_child(arte)
	radice.visible = false
	return radice


func _crea_numero(lato: int) -> void:
	var segno: float = 1.0 if lato == 0 else -1.0
	var radice: Node3D = Node3D.new()
	radice.position = Vector3(-6.0, 0.05, 3.4 * segno)
	add_child(radice)
	var sigla: Label3D = scritta(sigle_lato[lato], 150, Color("efe4cc"), Color(0, 0, 0, 0), 0)
	sigla.rotation.x = -PI * 0.5
	sigla.position = Vector3(0.0, 0.0, -1.35)
	radice.add_child(sigla)
	var numero: Label3D = scritta(str(resistenza[lato]), 420, Color("efe4cc"), Color(0, 0, 0, 0), 0)
	numero.rotation.x = -PI * 0.5
	numero.position = Vector3(0.0, 0.0, 0.15)
	radice.add_child(numero)
	var nome: Label3D = scritta(nomi_lato[lato].to_upper(), 46, Color("c99a3e") if lato == 0 else Color("d0574c"), Color(0, 0, 0, 0), 0)
	nome.rotation.x = -PI * 0.5
	nome.position = Vector3(0.0, 0.0, 1.45)
	radice.add_child(nome)
	radice.scale = Vector3(0.001, 1.0, 0.001)
	_numeri[lato] = numero


func _crea_riserva(lato: int) -> void:
	var segno: float = 1.0 if lato == 0 else -1.0
	for c: int in range(5):
		var g: MeshInstance3D = _piatto(_tex_cerchio, Vector2(0.62, 0.62), COLORI_MANA[c], true)
		g.position = Vector3(6.9 + float(c % 3) * 0.8, 0.05, (4.6 + float(c / 3) * 0.95) * segno)
		(g.material_override as StandardMaterial3D).albedo_color = Color(COLORI_MANA[c], 0.3)
		add_child(g)
		_gemme[lato].append(g)
		var n: Label3D = scritta("0", 96, Color("efe4cc"), Color("0c0907"), 14)
		n.rotation.x = -PI * 0.5
		n.position = g.position + Vector3(0.0, 0.02, 0.0)
		add_child(n)
		_conti[lato].append(n)


func _aggiorna_gemma(lato: int, c: int) -> void:
	var g: MeshInstance3D = _gemme[lato][c]
	(g.material_override as StandardMaterial3D).albedo_color = Color(COLORI_MANA[c], 0.3 if riserva[lato][c] == 0 else 1.0)
	(_conti[lato][c] as Label3D).text = str(riserva[lato][c])
	var t: Tween = create_tween()
	g.scale = Vector3(1.7, 1.0, 1.7)
	t.tween_property(g, "scale", Vector3.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


# --- Movimento -----------------------------------------------------------------

func aggiorna(delta: float) -> void:
	_scossa_camera = maxf(0.0, _scossa_camera - delta * 2.5)
	var s: Vector3 = Vector3(_rng.randf_range(-1, 1), 0.0, _rng.randf_range(-1, 1)) * _scossa_camera * 0.35
	if tempo > 1.6:
		var k: float = clampf((tempo - 1.6) / 10.0, 0.0, 1.0)
		var p: Vector3 = _pos_camera.lerp(_pos_camera + Vector3(0.4, -1.6, -0.6), k)
		_camera.look_at_from_position(p + s, _mira + s * 0.5, Vector3.UP)


func intro() -> void:
	var cam: Tween = create_tween()
	cam.tween_method(func(t: float) -> void:
		_camera.look_at_from_position((_pos_camera + Vector3(0.0, 6.0, 2.0)).lerp(_pos_camera, t), _mira, Vector3.UP), 0.0, 1.0, 1.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	# Nuovo passaggio di stampa: il foglio passa dall'ocra al rosso scuro.
	var f: Tween = create_tween()
	f.tween_interval(0.2)
	f.tween_property(_mat_fondo, "albedo_color", Color("2b0d0b"), 0.5)
	var ritardo: float = 0.35
	for lato: int in [0, 1]:
		var tn: Tween = create_tween()
		tn.tween_interval(0.3 + lato * 0.15)
		tn.tween_property(_numeri[lato].get_parent(), "scale", Vector3.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		for gruppo: Array in [_carte_truppe[lato], _carte_edifici[lato]]:
			for carta: Node3D in gruppo:
				_stampa(carta, ritardo)
				ritardo += 0.07


## Un foglio cala sulla carta, la "stampa" e si stacca rivelandola.
func _stampa(carta: Node3D, ritardo: float) -> void:
	var perno: Node3D = Node3D.new()
	var misura: float = 2.6
	perno.position = carta.position + Vector3(0.0, 2.2, -misura * 0.5)
	add_child(perno)
	var foglio: MeshInstance3D = _piatto(null, Vector2(misura, misura), Color("f3e9d2"))
	foglio.position = Vector3(0.0, 0.0, misura * 0.5)
	perno.add_child(foglio)
	perno.visible = false
	var t: Tween = create_tween()
	t.tween_interval(ritardo)
	t.tween_callback(func() -> void: perno.visible = true)
	t.tween_property(perno, "position:y", carta.position.y + 0.06, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.tween_callback(func() -> void:
		carta.visible = true
		_scossa_camera = maxf(_scossa_camera, 0.25))
	t.tween_interval(0.06)
	t.tween_property(perno, "rotation:x", 2.4, 0.32).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(foglio.material_override, "albedo_color:a", 0.0, 0.32)
	t.tween_callback(perno.queue_free)


func _goccia(da: Vector3, a: Vector3, colore: Color, durata: float, all_arrivo: Callable) -> void:
	var g: MeshInstance3D = _piatto(_tex_cerchio, Vector2(0.38, 0.38), colore, true)
	g.position = da + Vector3(0.0, 0.12, 0.0)
	add_child(g)
	var ultimo: Array = [0.0]
	var t: Tween = create_tween()
	t.tween_method(func(k: float) -> void:
		var curva: Vector3 = da.lerp(a, k) + Vector3(0.0, 0.12, sin(k * PI) * -0.8)
		g.position = curva
		if k - float(ultimo[0]) > 0.06:
			ultimo[0] = k
			var punto: MeshInstance3D = _piatto(_tex_cerchio, Vector2(0.16, 0.16), colore, true)
			punto.position = curva - Vector3(0.0, 0.01, 0.0)
			add_child(punto)
			var tp: Tween = create_tween()
			tp.tween_property(punto.material_override, "albedo_color:a", 0.0, 0.6)
			tp.tween_callback(punto.queue_free), 0.0, 1.0, durata).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_callback(func() -> void:
		g.queue_free()
		all_arrivo.call())


func _timbro(carta: Node3D, forza: float) -> void:
	var y0: float = 0.03
	var t: Tween = create_tween()
	t.tween_property(carta, "position:y", y0 + 0.7 * forza, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(carta, "scale", Vector3(1.08, 1.0, 1.08), 0.08)
	t.tween_property(carta, "position:y", y0, 0.06).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(carta, "scale", Vector3.ONE, 0.06)
	t.tween_callback(func() -> void:
		_scossa_camera = maxf(_scossa_camera, 0.35 * forza)
		var anello: MeshInstance3D = _piatto(_tex_anello, Vector2(2.4, 2.4), Color("efe4cc"), true)
		anello.position = carta.position + Vector3(0.0, 0.04, 0.0)
		add_child(anello)
		var ta: Tween = create_tween()
		ta.tween_property(anello, "scale", Vector3(1.6, 1.0, 1.6), 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		ta.parallel().tween_property(anello.material_override, "albedo_color:a", 0.0, 0.35)
		ta.tween_callback(anello.queue_free))


func produci(lato: int, edificio: int) -> void:
	var c: int = int(edifici_mana[lato][edificio])
	var carta: Node3D = _carte_edifici[lato][edificio]
	_timbro(carta, 0.4)
	_goccia(carta.position, (_gemme[lato][c] as MeshInstance3D).position, COLORI_MANA[c], 0.6, func() -> void:
		riserva[lato][c] += 1
		_aggiorna_gemma(lato, c))


func spendi(lato: int, truppa: int, colore: int, quanti: int) -> void:
	for k: int in range(quanti):
		var t: Tween = create_tween()
		t.tween_interval(k * 0.12)
		t.tween_callback(func() -> void:
			riserva[lato][colore] -= 1
			_aggiorna_gemma(lato, colore)
			_goccia((_gemme[lato][colore] as MeshInstance3D).position, (_carte_truppe[lato][truppa] as Node3D).position, COLORI_MANA[colore], 0.35, func() -> void: pass))


func attiva(lato: int, truppa: int) -> void:
	var carta: Node3D = _carte_truppe[lato][truppa]
	_timbro(carta, 1.0)
	# Tratto d'inchiostro verso il numero nemico.
	var da: Vector3 = carta.position
	var a: Vector3 = (_numeri[1 - lato] as Label3D).get_parent().position
	var tratto: MeshInstance3D = _piatto(null, Vector2(1.0, 0.16), Color("efe4cc"), true)
	add_child(tratto)
	var dir: Vector3 = a - da
	tratto.position = da + Vector3(0.0, 0.25, 0.0)
	tratto.rotation.y = -atan2(dir.z, dir.x)
	tratto.scale = Vector3(0.01, 1.0, 1.0)
	var t: Tween = create_tween()
	t.tween_interval(0.14)
	t.tween_method(func(k: float) -> void:
		tratto.position = da.lerp(a, k * 0.5) + Vector3(0.0, 0.25, 0.0)
		tratto.scale = Vector3(dir.length() * k, 1.0, 1.0), 0.0, 1.0, 0.12)
	t.tween_property(tratto.material_override, "albedo_color:a", 0.0, 0.2)
	t.tween_callback(tratto.queue_free)


func colpisci(lato: int, danno: int) -> void:
	togli_resistenza(lato, danno)
	var radice: Node3D = (_numeri[lato] as Label3D).get_parent()
	# Schizzo d'inchiostro rosso che resta sulla lastra.
	for k: int in range(2 + danno / 3):
		var m: MeshInstance3D = _piatto(_tex_macchie[_rng.randi() % _tex_macchie.size()], Vector2.ONE * _rng.randf_range(1.1, 2.0) * (0.8 + danno * 0.08), Color("c41f18"), true)
		m.position = radice.position + Vector3(_rng.randf_range(-1.6, 1.6), 0.06 + k * 0.002, _rng.randf_range(-1.2, 1.2))
		m.rotation.y = _rng.randf() * TAU
		m.scale = Vector3(0.05, 1.0, 0.05)
		add_child(m)
		var t: Tween = create_tween()
		t.tween_interval(k * 0.03)
		t.tween_property(m, "scale", Vector3.ONE, 0.09).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		# Colatura.
		var cola: MeshInstance3D = _piatto(_tex_cerchio, Vector2(0.14, 0.14), Color("c41f18"), true)
		cola.position = m.position + Vector3(0.0, 0.003, 0.0)
		add_child(cola)
		var tc: Tween = create_tween()
		tc.tween_interval(0.15)
		var lung: float = _rng.randf_range(2.0, 7.0)
		tc.tween_property(cola, "scale", Vector3(1.0, 1.0, lung), 1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tc.parallel().tween_property(cola, "position:z", cola.position.z + lung * 0.07, 1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	var numero: Label3D = _numeri[lato]
	numero.text = str(resistenza[lato])
	numero.scale = Vector3(1.5, 1.5, 1.5)
	var tn: Tween = create_tween()
	tn.tween_property(numero, "scale", Vector3.ONE, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_scossa_camera = maxf(_scossa_camera, 0.6)
	var n: Label3D = scritta("−%d" % danno, 260, Color("ff4a3d"), Color("140505"), 28)
	n.rotation.x = -PI * 0.5
	n.position = radice.position + Vector3(2.2, 0.4, -0.6)
	add_child(n)
	var t2: Tween = create_tween()
	t2.tween_property(n, "position:z", n.position.z - 1.2, 0.9)
	t2.parallel().tween_property(n, "modulate:a", 0.0, 0.35).set_delay(0.55)
	t2.parallel().tween_property(n, "outline_modulate:a", 0.0, 0.35).set_delay(0.55)
	t2.tween_callback(n.queue_free)


func scudo(lato: int, quanto: int) -> void:
	var radice: Node3D = (_numeri[lato] as Label3D).get_parent()
	var n: Label3D = scritta("+%d scudo" % quanto, 120, Color("8fc0ff"), Color("06122a"), 18)
	n.rotation.x = -PI * 0.5
	n.position = radice.position + Vector3(2.3, 0.4, 0.8)
	add_child(n)
	var t: Tween = create_tween()
	t.tween_property(n, "position:z", n.position.z - 1.0, 1.1)
	t.parallel().tween_property(n, "modulate:a", 0.0, 0.4).set_delay(0.7)
	t.parallel().tween_property(n, "outline_modulate:a", 0.0, 0.4).set_delay(0.7)
	t.tween_callback(n.queue_free)


func attesa(lato: int, truppa: int, attiva_ora: bool) -> void:
	var carta: Node3D = _carte_truppe[lato][truppa]
	var chiave: String = "%d_%d" % [lato, truppa]
	if attiva_ora:
		var gruppo: Node3D = Node3D.new()
		carta.add_child(gruppo)
		var tr: MeshInstance3D = _piatto(_tex_tratteggio, Vector2(2.05, 2.05), Color.WHITE, true)
		tr.position.y = 0.03
		gruppo.add_child(tr)
		var nastro: MeshInstance3D = _piatto(null, Vector2(2.7, 0.5), Color("c41f18"), true)
		nastro.position = Vector3(0.0, 0.05, 1.35)
		gruppo.add_child(nastro)
		var l: Label3D = scritta("IN ATTESA · manca 1 mana rosso", 48, Color("fff2e6"), Color(0, 0, 0, 0), 0)
		l.rotation.x = -PI * 0.5
		l.position = Vector3(0.0, 0.07, 1.35)
		gruppo.add_child(l)
		gruppo.scale = Vector3(1.4, 1.0, 1.4)
		var t: Tween = create_tween()
		t.tween_property(gruppo, "scale", Vector3.ONE, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		_cartellini[chiave] = gruppo
	elif _cartellini.has(chiave):
		var g: Node3D = _cartellini[chiave]
		_cartellini.erase(chiave)
		var t2: Tween = create_tween()
		t2.tween_property(g, "scale", Vector3(0.01, 1.0, 0.01), 0.12)
		t2.tween_callback(g.queue_free)


func sabotaggio(lato: int, truppa: int) -> void:
	var carta: Node3D = _carte_truppe[lato][truppa]
	var striscia: MeshInstance3D = _piatto(null, Vector2(2.9, 0.55), Color("e3ecf7"), true)
	striscia.position = Vector3(0.0, 0.06, 0.0)
	striscia.rotation.y = 0.45
	carta.add_child(striscia)
	var l: Label3D = scritta("SABOTATO", 64, Color("1b2333"), Color(0, 0, 0, 0), 0)
	l.rotation.x = -PI * 0.5
	l.position = Vector3(0.0, 0.01, 0.0)
	striscia.add_child(l)
	striscia.scale = Vector3(1.6, 1.0, 1.6)
	var t: Tween = create_tween()
	t.tween_property(striscia, "scale", Vector3.ONE, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.tween_callback(func() -> void: _scossa_camera = maxf(_scossa_camera, 0.3))


func vittoria(lato: int) -> void:
	var vinto: int = 1 - lato
	var radice: Node3D = (_numeri[vinto] as Label3D).get_parent()
	for k: int in range(9):
		var m: MeshInstance3D = _piatto(_tex_macchie[k % _tex_macchie.size()], Vector2.ONE * _rng.randf_range(3.5, 6.0), Color("b0170f"), true)
		m.position = Vector3(radice.position.x + 1.0 + k * 1.6 + _rng.randf_range(-0.6, 0.6), 0.09 + k * 0.002, radice.position.z + _rng.randf_range(-1.6, 1.6))
		m.rotation.y = _rng.randf() * TAU
		m.scale = Vector3(0.02, 1.0, 0.02)
		add_child(m)
		var t: Tween = create_tween()
		t.tween_interval(0.1 + k * 0.07)
		t.tween_property(m, "scale", Vector3.ONE, 0.16).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	var titolo: Label3D = scritta("VITTORIA", 560, Color("efe4cc"), Color("0c0907"), 40)
	titolo.rotation.x = -PI * 0.5
	titolo.position = Vector3(1.4, 0.2, -3.4)
	titolo.scale = Vector3(2.4, 2.4, 2.4)
	titolo.modulate.a = 0.0
	add_child(titolo)
	var tt: Tween = create_tween()
	tt.tween_interval(1.0)
	tt.tween_property(titolo, "modulate:a", 1.0, 0.01)
	tt.tween_property(titolo, "scale", Vector3.ONE, 0.13).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tt.tween_callback(func() -> void: _scossa_camera = 1.2)
