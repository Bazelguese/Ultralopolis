class_name ScenaTeatro
extends Node3D
## Scenografia del teatro di carta: la luce del momento del giorno, il tempo atmosferico e il
## calendario pop-up sul fondo del palco.
## SOLO SCENOGRAFIA (decisione di Davide, 8 novembre 2026): non ha alcun effetto sulle regole.
## Momento e tempo cambiano a ogni mese, scelti a caso ma coerenti con la stagione; lo stesso mese
## della stessa partita ha sempre lo stesso tempo. Il caso usa un generatore suo: la simulazione
## non viene toccata.

enum Momento { ALBA, GIORNO, TRAMONTO, NOTTE }
enum Tempo { SERENO, NUVOLOSO, PIOGGIA, TEMPORALE, NEVE, NEBBIA }

## Pesi dei momenti del giorno per stagione (inverno, primavera, estate, autunno): alba, giorno, tramonto, notte.
const PESI_MOMENTO: Array = [[1, 4, 2, 3], [2, 5, 2, 1], [1, 6, 3, 1], [2, 4, 3, 2]]
## Pesi del tempo per stagione: sereno, nuvoloso, pioggia, temporale, neve, nebbia.
const PESI_TEMPO: Array = [[3, 2, 0, 0, 5, 1], [4, 3, 3, 0, 0, 1], [6, 1, 1, 2, 0, 0], [2, 3, 3, 0, 0, 3]]

## Colore della pagina (il tavolo) per momento: è il cielo stampato del libro pop-up.
const CIELO: Array[Color] = [Color("4a3848"), Color("5d7080"), Color("4a3a46"), Color("101624")]
const COLORE_SOLE: Array[Color] = [Color("ffb58a"), Color("fff1d6"), Color("ffb878"), Color("9db4ff")]
const ENERGIA_SOLE: Array[float] = [0.75, 1.15, 0.7, 0.22]
const ALTEZZA_SOLE: Array[float] = [-16.0, -58.0, -14.0, -42.0]
const DIREZIONE_SOLE: Array[float] = [-70.0, -25.0, 70.0, -30.0]
const COLORE_AMBIENTE: Array[Color] = [Color("6a5060"), Color("8f949e"), Color("5e4a52"), Color("2a2c48")]
const ENERGIA_AMBIENTE: Array[float] = [0.5, 0.7, 0.5, 0.32]
const ENERGIA_LANTERNA: Array[float] = [1.4, 0.35, 1.9, 3.4]

## Colori delle stagioni sul calendario.
const COLORE_STAGIONE: Array[Color] = [Color("8fb4d8"), Color("86c46e"), Color("e6a63c"), Color("c8643c")]
const INCHIOSTRO: Color = Color("1a1410")
const DURATA_CAMBIO: float = 1.6

var momento: Momento = Momento.NOTTE
var tempo: Tempo = Tempo.SERENO

var _ambiente: Environment
var _sole: DirectionalLight3D
var _lanterna: OmniLight3D
var _base_lanterna: Vector3 = Vector3(0.0, 12.0, 5.0)
var _energia_lanterna: float = 3.4
var _materiale_pagina: StandardMaterial3D
var _pioggia: CPUParticles3D
var _neve: CPUParticles3D
var _foglie: CPUParticles3D
var _nuvole: Array[MeshInstance3D] = []
var _materiale_nuvole: StandardMaterial3D
var _astro: Node3D
var _materiale_astro: ShaderMaterial
var _calendario: Node3D
var _pagina: Node3D
var _chiave_mese: String = ""
var _tempo_scena: float = 0.0
var _prossimo_lampo: float = 4.0
var _caso: RandomNumberGenerator = RandomNumberGenerator.new()
var _trame_astro: Dictionary = {}


# --- Costruzione ------------------------------------------------------------------

## Crea luci, pagina del tavolo, meteo, sole/luna e calendario.
## calendario: dove sta il calendario pop-up; astro: dove sorgono sole e luna.
func costruisci(calendario: Vector3, astro: Vector3) -> void:
	_crea_luci()
	_crea_pagina()
	_crea_meteo()
	_crea_astro(astro)
	_crea_calendario(calendario)


func _crea_luci() -> void:
	var mondo: WorldEnvironment = WorldEnvironment.new()
	_ambiente = Environment.new()
	_ambiente.background_mode = Environment.BG_COLOR
	_ambiente.background_color = StileVisivo.BUIO
	_ambiente.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	_ambiente.ambient_light_color = COLORE_AMBIENTE[Momento.NOTTE]
	_ambiente.ambient_light_energy = ENERGIA_AMBIENTE[Momento.NOTTE]
	_ambiente.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	_ambiente.glow_enabled = true
	_ambiente.glow_intensity = 0.7
	_ambiente.glow_bloom = 0.06
	_ambiente.glow_hdr_threshold = 1.0
	_ambiente.fog_enabled = true
	_ambiente.fog_light_color = Color("0b0806")
	_ambiente.fog_density = 0.006
	mondo.environment = _ambiente
	add_child(mondo)

	_sole = DirectionalLight3D.new()
	_sole.shadow_enabled = true
	_sole.light_color = COLORE_SOLE[Momento.NOTTE]
	_sole.light_energy = ENERGIA_SOLE[Momento.NOTTE]
	_sole.rotation_degrees = Vector3(ALTEZZA_SOLE[Momento.NOTTE], DIREZIONE_SOLE[Momento.NOTTE], 0.0)
	add_child(_sole)

	var controluce: DirectionalLight3D = DirectionalLight3D.new()
	controluce.light_color = Color("5a78c8")
	controluce.light_energy = 0.3
	controluce.rotation_degrees = Vector3(-30.0, 155.0, 0.0)
	add_child(controluce)

	_lanterna = OmniLight3D.new()
	_lanterna.light_color = StileVisivo.LUCE_LANTERNA
	_lanterna.light_energy = _energia_lanterna
	_lanterna.omni_range = 48.0
	_lanterna.omni_attenuation = 1.1
	_lanterna.shadow_enabled = true
	_lanterna.position = _base_lanterna
	add_child(_lanterna)


## Il tavolo è la pagina di fondo del libro pop-up: il suo colore è il cielo del momento.
func _crea_pagina() -> void:
	var pagina: MeshInstance3D = MeshInstance3D.new()
	var forma: BoxMesh = BoxMesh.new()
	forma.size = Vector3(90.0, 0.5, 70.0)
	pagina.mesh = forma
	_materiale_pagina = materiale_carta(CIELO[Momento.NOTTE], 4.0)
	pagina.material_override = _materiale_pagina
	pagina.position.y = -0.45
	add_child(pagina)


func _crea_meteo() -> void:
	# Pioggia: fili sottili e chiari.
	_pioggia = CPUParticles3D.new()
	var filo: BoxMesh = BoxMesh.new()
	filo.size = Vector3(0.012, 0.34, 0.012)
	filo.material = _materiale_particella(Color(0.78, 0.86, 1.0, 0.32), false)
	_pioggia.mesh = filo
	_pioggia.amount = 1400
	_pioggia.lifetime = 0.85
	_pioggia.preprocess = 1.0
	_pioggia.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	_pioggia.emission_box_extents = Vector3(30.0, 0.5, 22.0)
	_pioggia.direction = Vector3(0.12, -1.0, 0.0)
	_pioggia.spread = 2.0
	_pioggia.initial_velocity_min = 16.0
	_pioggia.initial_velocity_max = 20.0
	_pioggia.gravity = Vector3(0.0, -10.0, 0.0)
	_pioggia.position = Vector3(0.0, 15.0, 0.0)
	_pioggia.emitting = false
	add_child(_pioggia)
	# Neve: coriandoli di carta bianca che girano piano.
	_neve = _coriandoli(600, 7.0, [Color("f4f1ea"), Color("dfe7f2")], 0.11)
	_neve.gravity = Vector3(0.25, -1.1, 0.0)
	add_child(_neve)
	# Foglie d'autunno: coriandoli rossi, arancio e bruni.
	_foglie = _coriandoli(70, 8.0, [Color("c8643c"), Color("e6a63c"), Color("8a4a24")], 0.24)
	_foglie.gravity = Vector3(0.6, -0.9, 0.0)
	add_child(_foglie)
	# Ombre delle nuvole che scivolano sul palco.
	_materiale_nuvole = StandardMaterial3D.new()
	_materiale_nuvole.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_materiale_nuvole.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_materiale_nuvole.albedo_texture = _macchia_morbida()
	_materiale_nuvole.albedo_color = Color(0.0, 0.0, 0.02, 0.0)
	_materiale_nuvole.no_depth_test = false
	for i: int in range(4):
		var nuvola: MeshInstance3D = MeshInstance3D.new()
		var forma: QuadMesh = QuadMesh.new()
		forma.size = Vector2(16.0, 10.0)
		forma.orientation = PlaneMesh.FACE_Y
		nuvola.mesh = forma
		nuvola.material_override = _materiale_nuvole
		nuvola.position = Vector3(-30.0 + i * 17.0, 6.0, -8.0 + float(i % 2) * 12.0)
		add_child(nuvola)
		_nuvole.append(nuvola)


func _coriandoli(quanti: int, durata: float, colori: Array, lato: float) -> CPUParticles3D:
	var p: CPUParticles3D = CPUParticles3D.new()
	var foglio: QuadMesh = QuadMesh.new()
	foglio.size = Vector2(lato, lato)
	var materiale: StandardMaterial3D = _materiale_particella(Color.WHITE, true)
	materiale.vertex_color_use_as_albedo = true
	foglio.material = materiale
	p.mesh = foglio
	p.amount = quanti
	p.lifetime = durata
	p.preprocess = durata
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	p.emission_box_extents = Vector3(30.0, 0.5, 22.0)
	p.direction = Vector3.DOWN
	p.spread = 25.0
	p.initial_velocity_min = 0.2
	p.initial_velocity_max = 0.8
	p.angle_min = 0.0
	p.angle_max = 360.0
	p.angular_velocity_min = -120.0
	p.angular_velocity_max = 120.0
	p.scale_amount_min = 0.6
	p.scale_amount_max = 1.2
	var rampa: Gradient = Gradient.new()
	rampa.set_color(0, colori[0])
	rampa.set_color(1, colori[colori.size() - 1])
	if colori.size() > 2:
		rampa.add_point(0.5, colori[1])
	p.color_initial_ramp = rampa
	p.position = Vector3(0.0, 11.0, 0.0)
	p.emitting = false
	return p


func _materiale_particella(colore: Color, foglio: bool) -> StandardMaterial3D:
	var m: StandardMaterial3D = StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_color = colore
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	if foglio:
		m.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	return m


func _macchia_morbida() -> GradientTexture2D:
	var sfumatura: Gradient = Gradient.new()
	sfumatura.set_color(0, Color(1.0, 1.0, 1.0, 1.0))
	sfumatura.set_color(1, Color(1.0, 1.0, 1.0, 0.0))
	var trama: GradientTexture2D = GradientTexture2D.new()
	trama.gradient = sfumatura
	trama.fill = GradientTexture2D.FILL_RADIAL
	trama.fill_from = Vector2(0.5, 0.5)
	trama.fill_to = Vector2(0.5, 0.0)
	trama.width = 128
	trama.height = 128
	return trama


## Sole e luna: un disco di carta ritagliato che sorge dalla pagina.
func _crea_astro(posizione: Vector3) -> void:
	_astro = Node3D.new()
	_astro.position = posizione
	add_child(_astro)
	var asta: MeshInstance3D = MeshInstance3D.new()
	var forma_asta: CylinderMesh = CylinderMesh.new()
	forma_asta.top_radius = 0.04
	forma_asta.bottom_radius = 0.04
	forma_asta.height = 3.0
	asta.mesh = forma_asta
	asta.material_override = StileVisivo.materiale(Color("2a2018"), 0.9)
	asta.position.y = 1.5
	_astro.add_child(asta)
	var disco: MeshInstance3D = MeshInstance3D.new()
	var forma: QuadMesh = QuadMesh.new()
	forma.size = Vector2(3.0, 3.0)
	disco.mesh = forma
	_materiale_astro = Figurina.materiale_carta(_disegna_astro(false))
	disco.material_override = _materiale_astro
	disco.position.y = 3.4
	_astro.add_child(disco)


func _disegna_astro(luna: bool) -> ImageTexture:
	if _trame_astro.has(luna):
		return _trame_astro[luna]
	var lato: int = 192
	var img: Image = Image.create(lato, lato, false, Image.FORMAT_RGBA8)
	var centro: Vector2 = Vector2(lato, lato) * 0.5
	var carta: Color = Figurina.COLORE_CARTA
	for y: int in range(lato):
		for x: int in range(lato):
			var p: Vector2 = Vector2(x, y) - centro
			var d: float = p.length()
			if luna:
				var morso: float = (p - Vector2(22.0, -14.0)).length()
				if d < 58.0 and morso > 50.0:
					img.set_pixel(x, y, Color("e8e4d6") if d < 54.0 and morso > 54.0 else carta)
			else:
				var raggi: float = 62.0 + 18.0 * maxf(0.0, cos(p.angle() * 12.0))
				if d < 44.0:
					img.set_pixel(x, y, Color("ffcf5a"))
				elif d < 48.0:
					img.set_pixel(x, y, INCHIOSTRO)
				elif d < raggi:
					img.set_pixel(x, y, Color("f2a43a") if d < raggi - 4.0 else carta)
	img.generate_mipmaps()
	var trama: ImageTexture = ImageTexture.create_from_image(img)
	_trame_astro[luna] = trama
	return trama


## Il calendario pop-up: un foglio grande in piedi sul fondo del palco, che gira pagina a ogni mese.
func _crea_calendario(posizione: Vector3) -> void:
	_calendario = Node3D.new()
	_calendario.position = posizione
	add_child(_calendario)
	var supporto: MeshInstance3D = MeshInstance3D.new()
	var forma: BoxMesh = BoxMesh.new()
	forma.size = Vector3(3.6, 0.12, 0.6)
	supporto.mesh = forma
	supporto.material_override = StileVisivo.materiale(Color("2a2018"), 0.9)
	supporto.position = Vector3(0.0, 0.06, 0.0)
	_calendario.add_child(supporto)


func _nuova_pagina(anno: int, stagione: int, nome_mese: String, nome_stagione: String) -> Node3D:
	var pagina: Node3D = Node3D.new()
	# Il perno sta in alto: le pagine si girano all'insù, come un calendario da muro.
	pagina.position = Vector3(0.0, 4.4, 0.0)
	var foglio: MeshInstance3D = MeshInstance3D.new()
	var forma: QuadMesh = QuadMesh.new()
	forma.size = Vector2(3.4, 4.2)
	foglio.mesh = forma
	foglio.material_override = Figurina.materiale_carta(_trama_pagina(COLORE_STAGIONE[stagione]))
	foglio.position = Vector3(0.0, -2.1, 0.0)
	pagina.add_child(foglio)
	var testa: Label3D = _scritta("ANNO %d" % anno, 64, INCHIOSTRO)
	testa.position = Vector3(0.0, -0.42, 0.01)
	pagina.add_child(testa)
	# Il mese grande e inclinato, come una data di scena.
	var mese: Label3D = _scritta(nome_mese.to_upper(), 150, INCHIOSTRO)
	mese.position = Vector3(0.0, -1.75, 0.01)
	mese.rotation.z = deg_to_rad(8.0)
	mese.width = 760.0
	mese.autowrap_mode = TextServer.AUTOWRAP_OFF
	pagina.add_child(mese)
	var fascia: Label3D = _scritta(nome_stagione.to_upper(), 82, Color("f4f1ea"))
	fascia.position = Vector3(0.0, -3.35, 0.01)
	fascia.outline_size = 14
	fascia.outline_modulate = COLORE_STAGIONE[stagione].darkened(0.55)
	pagina.add_child(fascia)
	_calendario.add_child(pagina)
	return pagina


func _scritta(testo: String, dimensione: int, colore: Color) -> Label3D:
	var s: Label3D = StileVisivo.scritta(testo, StileVisivo.FONT_TITOLI, dimensione, colore, 0.0, 0)
	s.rotation = Vector3.ZERO
	s.pixel_size = 0.005
	s.double_sided = false
	return s


func _trama_pagina(colore: Color) -> ImageTexture:
	var img: Image = Image.create(170, 210, false, Image.FORMAT_RGBA8)
	img.fill(Figurina.COLORE_CARTA)
	img.fill_rect(Rect2i(0, 0, 170, 30), INCHIOSTRO)
	img.fill_rect(Rect2i(0, 150, 170, 44), colore)
	# Bordo inferiore strappato.
	for x: int in range(170):
		var strappo: int = 200 + int(absf(sin(x * 0.7) * 3.0 + sin(x * 0.23) * 4.0))
		for y: int in range(mini(strappo, 210), 210):
			img.set_pixel(x, y, Color(0.0, 0.0, 0.0, 0.0))
	# Fori degli anelli in alto.
	for foro: int in [40, 85, 130]:
		img.fill_rect(Rect2i(foro - 4, 10, 8, 8), Color(0.0, 0.0, 0.0, 0.0))
	img.generate_mipmaps()
	return ImageTexture.create_from_image(img)


# --- Il mese -----------------------------------------------------------------------

## Il mese della partita: sceglie momento e tempo e, se il mese è cambiato, gira la pagina
## del calendario. seme: diverso per ogni partita, ma fisso dentro la stessa partita.
func imposta_mese(anno: int, stagione: int, mese: int, nome_mese: String, nome_stagione: String, seme: int, subito: bool) -> void:
	var chiave: String = "%d-%d-%d" % [anno, stagione, mese]
	if chiave == _chiave_mese:
		return
	_chiave_mese = chiave
	_caso.seed = hash("%d|%d|%d" % [seme, anno, mese])
	momento = _pesca(PESI_MOMENTO[stagione]) as Momento
	tempo = _pesca(PESI_TEMPO[stagione]) as Tempo
	_applica_luce(0.0 if subito else DURATA_CAMBIO)
	_applica_meteo(stagione)
	_gira_pagina(anno, stagione, nome_mese, nome_stagione, subito)


func _pesca(pesi: Array) -> int:
	var totale: int = 0
	for p: int in pesi:
		totale += p
	var tiro: int = _caso.randi_range(1, maxi(totale, 1))
	for i: int in range(pesi.size()):
		tiro -= int(pesi[i])
		if tiro <= 0:
			return i
	return 0


func _applica_luce(durata: float) -> void:
	var m: int = momento
	var coperto: bool = tempo in [Tempo.NUVOLOSO, Tempo.PIOGGIA, Tempo.TEMPORALE, Tempo.NEBBIA]
	var forza_sole: float = ENERGIA_SOLE[m] * (0.35 if tempo in [Tempo.PIOGGIA, Tempo.TEMPORALE] else (0.5 if coperto else 1.0))
	var ambiente_colore: Color = COLORE_AMBIENTE[m]
	var cielo: Color = CIELO[m]
	if coperto:
		ambiente_colore = ambiente_colore.lerp(Color("70747c"), 0.4)
		cielo = cielo.lerp(Color("3c4048"), 0.35)
	if tempo == Tempo.NEVE:
		ambiente_colore = ambiente_colore.lerp(Color("c8d6ea"), 0.35)
		cielo = cielo.lerp(Color("c8d0dc"), 0.3)
	var nebbia: float = 0.03 if tempo == Tempo.NEBBIA else (0.012 if coperto else 0.006)
	_energia_lanterna = ENERGIA_LANTERNA[m] * (1.2 if coperto and m != Momento.GIORNO else 1.0)
	var rotazione: Vector3 = Vector3(ALTEZZA_SOLE[m], DIREZIONE_SOLE[m], 0.0)
	if durata <= 0.0:
		_sole.light_color = COLORE_SOLE[m]
		_sole.light_energy = forza_sole
		_sole.rotation_degrees = rotazione
		_ambiente.ambient_light_color = ambiente_colore
		_ambiente.ambient_light_energy = ENERGIA_AMBIENTE[m]
		_ambiente.fog_density = nebbia
		_ambiente.fog_light_color = cielo.darkened(0.6)
		_materiale_pagina.albedo_color = cielo
	else:
		var t: Tween = create_tween()
		t.set_parallel(true)
		t.tween_property(_sole, "light_color", COLORE_SOLE[m], durata)
		t.tween_property(_sole, "light_energy", forza_sole, durata)
		t.tween_property(_sole, "rotation_degrees", rotazione, durata).set_trans(Tween.TRANS_SINE)
		t.tween_property(_ambiente, "ambient_light_color", ambiente_colore, durata)
		t.tween_property(_ambiente, "ambient_light_energy", ENERGIA_AMBIENTE[m], durata)
		t.tween_property(_ambiente, "fog_density", nebbia, durata)
		t.tween_property(_ambiente, "fog_light_color", cielo.darkened(0.6), durata)
		t.tween_property(_materiale_pagina, "albedo_color", cielo, durata)
	_cambia_astro(m, durata)


func _applica_meteo(stagione: int) -> void:
	_pioggia.emitting = tempo in [Tempo.PIOGGIA, Tempo.TEMPORALE]
	_pioggia.amount = 1800 if tempo == Tempo.TEMPORALE else 1300
	_neve.emitting = tempo == Tempo.NEVE
	_foglie.emitting = stagione == 3 and tempo in [Tempo.SERENO, Tempo.NUVOLOSO]
	var coperto: bool = tempo in [Tempo.NUVOLOSO, Tempo.PIOGGIA, Tempo.TEMPORALE]
	var t: Tween = create_tween()
	t.tween_property(_materiale_nuvole, "albedo_color:a", 0.22 if coperto else 0.0, DURATA_CAMBIO)


func _cambia_astro(m: int, durata: float) -> void:
	var luna: bool = m == Momento.NOTTE
	var altezza: float = 0.0 if m == Momento.GIORNO or m == Momento.NOTTE else -1.6
	if durata <= 0.0:
		_materiale_astro.set_shader_parameter("tex", _disegna_astro(luna))
		_astro.position.y = altezza
		return
	var t: Tween = create_tween()
	t.tween_property(_astro, "position:y", -6.0, durata * 0.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	t.tween_callback(func() -> void: _materiale_astro.set_shader_parameter("tex", _disegna_astro(luna)))
	t.tween_property(_astro, "position:y", altezza, durata * 0.55).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## La pagina vecchia si solleva e vola via; sotto c'è già quella nuova.
func _gira_pagina(anno: int, stagione: int, nome_mese: String, nome_stagione: String, subito: bool) -> void:
	var vecchia: Node3D = _pagina
	_pagina = _nuova_pagina(anno, stagione, nome_mese, nome_stagione)
	if vecchia == null or subito:
		if vecchia != null:
			vecchia.queue_free()
		return
	# La nuova sta appena dietro, la vecchia davanti finché non si gira.
	_pagina.position.z = -0.02
	var t: Tween = create_tween()
	t.tween_property(vecchia, "rotation:x", -PI * 0.95, 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	t.parallel().tween_property(vecchia, "position:y", vecchia.position.y + 0.6, 0.7)
	t.tween_property(vecchia, "position:z", vecchia.position.z - 2.0, 0.25)
	t.parallel().tween_property(vecchia, "scale", Vector3(0.01, 0.01, 0.01), 0.25)
	t.tween_callback(vecchia.queue_free)
	var nuova: Node3D = _pagina
	t.tween_callback(func() -> void: nuova.position.z = 0.0)
	# Il calendario fa un piccolo salto quando cambia il mese.
	var salto: Tween = create_tween()
	salto.tween_interval(0.5)
	salto.tween_property(_calendario, "scale", Vector3(1.08, 1.08, 1.08), 0.12)
	salto.tween_property(_calendario, "scale", Vector3.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


# --- Ogni fotogramma ---------------------------------------------------------------

func aggiorna(delta: float) -> void:
	_tempo_scena += delta
	# La lanterna oscilla piano e la fiamma tremola.
	_lanterna.position = _base_lanterna + Vector3(sin(_tempo_scena * 0.6) * 4.0, 0.0, cos(_tempo_scena * 0.45) * 1.2)
	_lanterna.light_energy = _energia_lanterna + (sin(_tempo_scena * 13.0) * 0.12 + sin(_tempo_scena * 7.3) * 0.1) * minf(_energia_lanterna, 1.0)
	for nuvola: MeshInstance3D in _nuvole:
		nuvola.position.x += delta * 1.2
		if nuvola.position.x > 36.0:
			nuvola.position.x -= 72.0
	_calendario.rotation.y = sin(_tempo_scena * 0.5) * 0.04
	if tempo == Tempo.TEMPORALE:
		_prossimo_lampo -= delta
		if _prossimo_lampo <= 0.0:
			_prossimo_lampo = _caso.randf_range(3.0, 7.0)
			_lampo()


## Lampo del temporale: due bagliori bianchi rapidissimi.
func _lampo() -> void:
	var base: float = _sole.light_energy
	var t: Tween = create_tween()
	t.tween_property(_sole, "light_energy", 3.5, 0.04)
	t.tween_property(_sole, "light_energy", base, 0.08)
	t.tween_interval(0.08)
	t.tween_property(_sole, "light_energy", 2.6, 0.03)
	t.tween_property(_sole, "light_energy", base, 0.2)


## Carta spessa con la grana: pagina del tavolo e plance del teatro di carta.
static func materiale_carta(colore: Color, scala: float) -> StandardMaterial3D:
	var materiale: StandardMaterial3D = StileVisivo.materiale(colore, 0.95)
	var grana: NoiseTexture2D = NoiseTexture2D.new()
	grana.width = 256
	grana.height = 256
	grana.seamless = true
	var rumore: FastNoiseLite = FastNoiseLite.new()
	rumore.frequency = 0.03
	rumore.fractal_octaves = 4
	grana.noise = rumore
	var rampa: Gradient = Gradient.new()
	rampa.set_color(0, Color(0.72, 0.68, 0.64))
	rampa.set_color(1, Color(1.0, 1.0, 1.0))
	grana.color_ramp = rampa
	materiale.albedo_texture = grana
	materiale.uv1_scale = Vector3(scala, scala, scala)
	materiale.uv1_triplanar = true
	return materiale
