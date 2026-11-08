class_name SfondoCitta
extends Node3D
## Lo sfondo del teatro di carta (richiesta di Davide, 8 novembre 2026): giù in basso, attorno al
## libro pop-up, la città di carta della nazione; sopra la città galleggia la fila dei mesi, che
## scorre a ogni nuovo mese mentre un sigillo di ceralacca timbra il mese in corso.
## Solo scenografia: legge il calendario della partita, non decide niente.

const ALTEZZA_SUOLO: float = -10.0
const NOMI_MESI: PackedStringArray = ["Gennaio", "Febbraio", "Marzo", "Aprile", "Maggio", "Giugno",
		"Luglio", "Agosto", "Settembre", "Ottobre", "Novembre", "Dicembre"]
const COLORE_STAGIONE: Array[Color] = [Color("8fb4d8"), Color("86c46e"), Color("e6a63c"), Color("c8643c")]
const INCHIOSTRO: Color = Color("140f0c")
const PASSO_MESI: float = 3.7
const MESI_VISIBILI: int = 3

const SHADER_PALAZZO: String = """
shader_type spatial;
render_mode cull_disabled, depth_draw_opaque;
uniform sampler2D forma : source_color, filter_linear_mipmap;
uniform sampler2D finestre : filter_linear_mipmap;
uniform float accese = 0.0;
void fragment() {
	vec4 f = texture(forma, UV);
	float w = texture(finestre, UV).r;
	ALBEDO = mix(f.rgb, vec3(0.95, 0.82, 0.55), w * 0.6);
	EMISSION = vec3(1.0, 0.72, 0.32) * w * accese * 3.2;
	ROUGHNESS = 0.95;
	ALPHA = f.a;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
}
"""

var _materiali_palazzi: Array[ShaderMaterial] = []
var _fila: Node3D
var _mesi: Array[Node3D] = []
var _anno: Label3D
var _sigillo: Node3D
var _lettere_sigillo: Label3D
var _mese_corrente: int = 1
var _caso: RandomNumberGenerator = RandomNumberGenerator.new()


## libro: rettangolo (x, z, larghezza, profondità) occupato dal libro, attorno a cui sorge la città.
## fila: dove galleggia il mese in corso. telecamera: verso dove si girano i ritagli.
func costruisci(libro: Rect2, fila: Vector3, telecamera: Vector3, iniziali: String) -> void:
	_caso.seed = 1789
	_crea_suolo()
	_crea_citta(libro, telecamera)
	_crea_fila(fila, iniziali)


func _crea_suolo() -> void:
	var suolo: MeshInstance3D = MeshInstance3D.new()
	var forma: PlaneMesh = PlaneMesh.new()
	forma.size = Vector2(200.0, 200.0)
	suolo.mesh = forma
	suolo.material_override = ScenaTeatro.materiale_carta(Color("1a1512"), 6.0)
	suolo.position.y = ALTEZZA_SUOLO
	add_child(suolo)


# --- La città ---------------------------------------------------------------------

func _crea_citta(libro: Rect2, telecamera: Vector3) -> void:
	var forme: Array[Array] = []
	for variante: int in range(6):
		forme.append(_disegna_palazzo(variante))
	var shader: Shader = Shader.new()
	shader.code = SHADER_PALAZZO
	var piazzati: int = 0
	var tentativi: int = 0
	while piazzati < 110 and tentativi < 4000:
		tentativi += 1
		var x: float = _caso.randf_range(-60.0, 60.0)
		var z: float = _caso.randf_range(-55.0, libro.position.y + libro.size.y + 4.0)
		var fuori_x: float = maxf(libro.position.x - x, x - (libro.position.x + libro.size.x))
		var fuori_z: float = maxf(libro.position.y - z, z - (libro.position.y + libro.size.y))
		var distanza: float = maxf(fuori_x, fuori_z)
		if distanza < 1.5:
			continue
		# Vicino al libro i palazzi restano bassi, lontano possono crescere.
		var massima: float = clampf(4.0 + distanza * 0.8, 4.0, 13.0)
		var altezza: float = _caso.randf_range(3.5, massima)
		if ALTEZZA_SUOLO + altezza > -0.6 and distanza < 8.0:
			altezza = -0.6 - ALTEZZA_SUOLO
		var variante: int = _caso.randi_range(0, forme.size() - 1)
		var materiale: ShaderMaterial = ShaderMaterial.new()
		materiale.shader = shader
		materiale.set_shader_parameter("forma", forme[variante][0])
		materiale.set_shader_parameter("finestre", forme[variante][1])
		_materiali_palazzi.append(materiale)
		var palazzo: MeshInstance3D = MeshInstance3D.new()
		var quadro: QuadMesh = QuadMesh.new()
		quadro.size = Vector2(altezza * 0.5, altezza)
		palazzo.mesh = quadro
		palazzo.material_override = materiale
		palazzo.position = Vector3(x, ALTEZZA_SUOLO + altezza * 0.5, z)
		palazzo.rotation.y = atan2(telecamera.x - x, telecamera.z - z)
		add_child(palazzo)
		piazzati += 1


## Finestre accese: 0 di giorno, 1 di notte.
func imposta_finestre(accese: float, durata: float) -> void:
	for materiale: ShaderMaterial in _materiali_palazzi:
		if durata <= 0.0:
			materiale.set_shader_parameter("accese", accese)
		else:
			var t: Tween = create_tween()
			t.tween_method(func(v: float) -> void: materiale.set_shader_parameter("accese", v), float(materiale.get_shader_parameter("accese")), accese, durata)


## Un palazzo di carta ritagliata: [forma con il bordo crema, finestre].
## 0 torre merlata, 1 casa con il tetto a punta, 2 campanile, 3 cupola, 4 mura, 5 torre sottile.
func _disegna_palazzo(variante: int) -> Array:
	var w: int = 128
	var h: int = 256
	var forma: Image = Image.create(w, h, false, Image.FORMAT_RGBA8)
	var finestre: Image = Image.create(w, h, false, Image.FORMAT_L8)
	var corpo: Color = Color("2b231d").lerp(Color("3a2e26"), _caso.randf())
	var bordo: Color = StileVisivo.CARTA_CREMA
	var larghezza: int = [96, 104, 64, 100, 124, 48][variante]
	var x0: int = (w - larghezza) / 2
	var tetto: int = [40, 70, 110, 60, 30, 90][variante]
	# Corpo e bordo di carta.
	_rettangolo(forma, Rect2i(x0 - 3, tetto - 3, larghezza + 6, h - tetto + 3), bordo)
	_rettangolo(forma, Rect2i(x0, tetto, larghezza, h - tetto), corpo)
	var cx: float = w * 0.5
	for y: int in range(0, tetto + 4):
		for x: int in range(w):
			var dentro: bool = false
			var dentro_bordo: bool = false
			match variante:
				0:
					var merlo: bool = (x - x0) % 24 < 14
					dentro = y >= tetto - 14 and x >= x0 and x < x0 + larghezza and merlo
					dentro_bordo = y >= tetto - 17 and x >= x0 - 3 and x < x0 + larghezza + 3 and ((x - x0 + 3) % 24 < 20)
				1, 2:
					var pendenza: float = absf(x - cx) / (larghezza * 0.5 + 4.0)
					var cima: float = tetto * (1.0 if variante == 1 else 1.0) * pendenza + (8.0 if variante == 1 else 4.0)
					dentro = y >= cima + 3.0 and absf(x - cx) < larghezza * 0.5 + 4.0
					dentro_bordo = y >= cima and absf(x - cx) < larghezza * 0.5 + 7.0
				3:
					var r: float = larghezza * 0.5
					var d: float = Vector2(x - cx, y - tetto).length()
					dentro = d < r and y <= tetto
					dentro_bordo = d < r + 3.0 and y <= tetto + 1
				5:
					var pendenza2: float = absf(x - cx) / (larghezza * 0.5 + 2.0)
					var cima2: float = (tetto - 6.0) * pendenza2 + 4.0
					dentro = y >= cima2 + 3.0 and absf(x - cx) < larghezza * 0.5 + 2.0
					dentro_bordo = y >= cima2 and absf(x - cx) < larghezza * 0.5 + 5.0
			if dentro:
				forma.set_pixel(x, y, corpo)
			elif dentro_bordo and forma.get_pixel(x, y).a < 0.5:
				forma.set_pixel(x, y, bordo)
	# Finestre: alcune sì, alcune no.
	var passo_x: int = 16
	var passo_y: int = 24
	for fy: int in range(tetto + 12, h - 16, passo_y):
		for fx: int in range(x0 + 8, x0 + larghezza - 10, passo_x):
			if _caso.randf() < 0.45:
				finestre.fill_rect(Rect2i(fx, fy, 7, 11), Color(1.0, 1.0, 1.0))
	forma.generate_mipmaps()
	finestre.generate_mipmaps()
	return [ImageTexture.create_from_image(forma), ImageTexture.create_from_image(finestre)]


func _rettangolo(img: Image, area: Rect2i, colore: Color) -> void:
	img.fill_rect(area.intersection(Rect2i(0, 0, img.get_width(), img.get_height())), colore)


# --- La fila dei mesi ---------------------------------------------------------------

func _crea_fila(posizione: Vector3, iniziali: String) -> void:
	_fila = Node3D.new()
	_fila.position = posizione
	add_child(_fila)
	for m: int in range(12):
		var mese: Node3D = Node3D.new()
		var numero: Label3D = _scritta(str(m + 1), 300, Color("f4efe2"), INCHIOSTRO, 46)
		mese.add_child(numero)
		var nome: Label3D = _scritta(NOMI_MESI[m].to_upper(), 76, COLORE_STAGIONE[m / 3], INCHIOSTRO, 22)
		nome.position = Vector3(0.0, -1.0, 0.02)
		mese.add_child(nome)
		mese.scale = Vector3(0.001, 0.001, 0.001)
		_fila.add_child(mese)
		_mesi.append(mese)
	_anno = _scritta("", 110, Color("f4efe2"), INCHIOSTRO, 30)
	_anno.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_anno.position = Vector3(-PASSO_MESI * 3.4, 1.6, 0.0)
	_fila.add_child(_anno)
	_sigillo = _crea_sigillo(iniziali)
	_fila.add_child(_sigillo)


func _scritta(testo: String, dimensione: int, colore: Color, contorno: Color, spessore: int) -> Label3D:
	var s: Label3D = Label3D.new()
	s.text = testo
	s.font = StileVisivo.FONT_TITOLI
	s.font_size = dimensione
	s.pixel_size = 0.006
	s.modulate = colore
	s.outline_modulate = contorno
	s.outline_size = spessore
	s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	s.no_depth_test = false
	return s


## Il sigillo di ceralacca con le iniziali della nazione.
func _crea_sigillo(iniziali: String) -> Node3D:
	var nodo: Node3D = Node3D.new()
	var disco: Sprite3D = Sprite3D.new()
	disco.texture = _disegna_ceralacca()
	disco.pixel_size = 0.012
	disco.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	disco.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	disco.shaded = false
	nodo.add_child(disco)
	var lettere: Label3D = _scritta(iniziali, 90, Color("ffd9c8"), Color("5a0d0a"), 10)
	lettere.position = Vector3(0.0, 0.0, 0.05)
	lettere.render_priority = 1
	nodo.add_child(lettere)
	_lettere_sigillo = lettere
	nodo.scale = Vector3(0.001, 0.001, 0.001)
	return nodo


func _disegna_ceralacca() -> ImageTexture:
	var lato: int = 128
	var img: Image = Image.create(lato, lato, false, Image.FORMAT_RGBA8)
	var centro: Vector2 = Vector2(lato, lato) * 0.5
	for y: int in range(lato):
		for x: int in range(lato):
			var p: Vector2 = Vector2(x, y) - centro
			var raggio: float = 52.0 + 6.0 * sin(p.angle() * 7.0) + 3.0 * sin(p.angle() * 13.0)
			var d: float = p.length()
			if d < raggio:
				var c: Color = Color("a3201a") if d < 40.0 else Color("8a1712")
				if d > 36.0 and d < 40.0:
					c = Color("6a100c")
				img.set_pixel(x, y, c)
	img.generate_mipmaps()
	return ImageTexture.create_from_image(img)


## Le iniziali della nazione sul sigillo.
func imposta_iniziali(testo: String) -> void:
	_lettere_sigillo.text = testo


## Porta la fila al mese indicato: i mesi scorrono, quello nuovo cresce al centro e il sigillo
## lo timbra.
func vai_al_mese(anno: int, mese: int, nome_stagione: String, subito: bool) -> void:
	_mese_corrente = mese
	_anno.text = "ANNO %d · %s" % [anno, nome_stagione.to_upper()]
	var durata: float = 0.0 if subito else 0.9
	for m: int in range(12):
		var k: int = (m + 1) - mese
		if k > 6:
			k -= 12
		elif k < -5:
			k += 12
		var nodo: Node3D = _mesi[m]
		var visibile: bool = absi(k) <= MESI_VISIBILI
		var scala: float = 1.0 if k == 0 else (maxf(0.3, 0.62 - 0.08 * float(absi(k) - 1)) if visibile else 0.001)
		var posizione: Vector3 = Vector3(float(k) * PASSO_MESI - signf(float(k)) * 0.6, -0.25 * float(absi(k)), -0.5 * float(absi(k)))
		if k == 0:
			posizione.y = 0.3
		if durata <= 0.0:
			nodo.position = posizione
			nodo.scale = Vector3.ONE * scala
		else:
			var t: Tween = create_tween()
			t.set_parallel(true)
			t.tween_property(nodo, "position", posizione, durata).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
			t.tween_property(nodo, "scale", Vector3.ONE * scala, durata).set_trans(Tween.TRANS_BACK if k == 0 else Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_timbra(durata)


func _timbra(ritardo: float) -> void:
	var arrivo: Vector3 = Vector3(1.25, 1.15, 0.3)
	if ritardo <= 0.0:
		_sigillo.position = arrivo
		_sigillo.scale = Vector3.ONE
		return
	var t: Tween = create_tween()
	t.tween_property(_sigillo, "scale", Vector3(0.001, 0.001, 0.001), 0.15)
	t.tween_interval(maxf(0.0, ritardo - 0.15))
	t.tween_callback(func() -> void: _sigillo.position = arrivo + Vector3(0.6, 2.4, 1.5))
	t.tween_property(_sigillo, "scale", Vector3.ONE * 1.7, 0.01)
	t.tween_property(_sigillo, "position", arrivo, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(_sigillo, "scale", Vector3.ONE * 0.85, 0.16)
	t.tween_callback(_schizzi.bind(arrivo))
	t.tween_property(_sigillo, "scale", Vector3.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Gocce di ceralacca quando il sigillo timbra il mese.
func _schizzi(dove: Vector3) -> void:
	var p: CPUParticles3D = CPUParticles3D.new()
	var goccia: SphereMesh = SphereMesh.new()
	goccia.radius = 0.06
	goccia.height = 0.12
	goccia.material = StileVisivo.materiale(Color("a3201a"), 0.4)
	p.mesh = goccia
	p.amount = 18
	p.one_shot = true
	p.explosiveness = 1.0
	p.lifetime = 0.6
	p.direction = Vector3.UP
	p.spread = 80.0
	p.initial_velocity_min = 2.0
	p.initial_velocity_max = 4.0
	p.gravity = Vector3(0.0, -9.0, 0.0)
	p.position = dove
	_fila.add_child(p)
	p.emitting = true
	var pulizia: Tween = create_tween()
	pulizia.tween_interval(1.0)
	pulizia.tween_callback(p.queue_free)


## La fila dei mesi si nasconde durante gli scontri.
func mostra_fila(visibile: bool) -> void:
	var t: Tween = create_tween()
	t.tween_property(_fila, "scale", Vector3.ONE if visibile else Vector3(0.001, 0.001, 0.001), 0.4).set_trans(Tween.TRANS_CUBIC)
