class_name ProvaBase
extends Node3D
## Base comune delle prove di stile: uno scontro FINTO, scritto a mano come sequenza di fatti.
## Non usa la simulazione del gioco: serve solo a vedere aspetto e animazioni.

const ROSSO: Color = Color("ff4a3d")
const VERDE: Color = Color("3ddc6b")
const BLU: Color = Color("3d8bff")
const VIOLA: Color = Color("b14dff")
const ENERGIA: Color = Color("ffcc33")
const COLORI_MANA: Array[Color] = [ROSSO, VERDE, BLU, VIOLA, ENERGIA]
const DURATA: float = 14.5

var truppe_arte: Array = [["c8716e", "278014", "862b2d", "a4648d"], ["43a388", "ec7124", "640641", "4b4d5a"]]
var truppe_nomi: Array = [["Arcieri", "Lancieri", "Milizia", "Guardie"], ["Manticora", "Cavalieri", "Tagliagole", "Ragno d'osso"]]
var edifici_arte: Array = [["d61645", "19632f", "9928f9"], ["5066f4", "62b753"]]
var edifici_nomi: Array = [["Capitale", "Fattoria", "Caserma"], ["Miniera", "Santuario"]]
## Indice del colore del mana in COLORI_MANA.
var edifici_mana: Array = [[4, 1, 0], [2, 3]]
var nomi_lato: Array[String] = ["Nazione di prova", "Regno di Valdora"]
var sigle_lato: Array[String] = ["NP", "RV"]
var resistenza: Array[int] = [58, 22]
var resistenza_max: Array[int] = [58, 22]
var riserva: Array = [[0, 0, 0, 0, 0], [0, 0, 0, 0, 0]]
var tempo: float = 0.0

var _passi: Array = []
var _indice: int = 0
var _font: FontFile
var _font_testo: FontFile


func _ready() -> void:
	_font = load("res://font/BarlowSemiCondensed-ExtraBold.ttf") as FontFile
	_font_testo = load("res://font/Barlow-SemiBold.ttf") as FontFile
	costruisci()
	_passi = [
		[0.0, "intro", []],
		[2.0, "produci", [0, 0]],
		[2.3, "produci", [1, 0]],
		[2.6, "produci", [0, 2]],
		[2.9, "attiva", [0, 3]], [3.15, "colpisci", [1, 2]],
		[3.4, "attiva", [1, 3]], [3.65, "colpisci", [0, 3]],
		[3.9, "attesa", [0, 0, true]],
		[4.2, "produci", [0, 1]],
		[4.4, "attiva", [0, 2]], [4.65, "colpisci", [1, 2]],
		[4.9, "attiva", [1, 2]], [5.15, "colpisci", [0, 2]],
		[5.3, "produci", [0, 2]],
		[5.95, "attesa", [0, 0, false]], [5.95, "spendi", [0, 0, 0, 2]],
		[6.35, "attiva", [0, 0]], [6.6, "colpisci", [1, 4]],
		[6.85, "attiva", [0, 1]], [7.1, "colpisci", [1, 1]], [7.15, "scudo", [0, 1]],
		[7.45, "attiva", [1, 0]], [7.7, "sabotaggio", [0, 2]],
		[8.1, "produci", [1, 1]],
		[8.4, "attiva", [0, 3]], [8.65, "colpisci", [1, 6]],
		[9.0, "attiva", [1, 1]], [9.25, "colpisci", [0, 3]],
		[9.6, "produci", [0, 0]],
		[9.9, "attiva", [0, 1]], [10.15, "colpisci", [1, 1]],
		[10.5, "attiva", [0, 3]], [10.75, "colpisci", [1, 6]],
		[11.1, "vittoria", [0]],
	]


func _process(delta: float) -> void:
	tempo += delta
	while _indice < _passi.size() and float(_passi[_indice][0]) <= tempo:
		var passo: Array = _passi[_indice]
		_indice += 1
		callv(String(passo[1]), passo[2])
	aggiorna(delta)
	if tempo >= DURATA:
		get_tree().quit()


# --- Da ridefinire nelle prove ------------------------------------------------

func costruisci() -> void:
	pass


func aggiorna(_delta: float) -> void:
	pass


func intro() -> void:
	pass


func produci(_lato: int, _edificio: int) -> void:
	pass


func spendi(_lato: int, _truppa: int, _colore: int, _quanti: int) -> void:
	pass


func attiva(_lato: int, _truppa: int) -> void:
	pass


func colpisci(_lato: int, _danno: int) -> void:
	pass


func scudo(_lato: int, _quanto: int) -> void:
	pass


func attesa(_lato: int, _truppa: int, _attiva: bool) -> void:
	pass


func sabotaggio(_lato: int, _truppa: int) -> void:
	pass


func vittoria(_lato: int) -> void:
	pass


# --- Aiuti ---------------------------------------------------------------------

func togli_resistenza(lato: int, danno: int) -> void:
	resistenza[lato] = maxi(0, resistenza[lato] - danno)


func immagine(cartella: String, id: String) -> ImageTexture:
	var img: Image = Image.load_from_file("res://%s/%s.png" % [cartella, id])
	img.generate_mipmaps()
	return ImageTexture.create_from_image(img)


func scritta(testo: String, dimensione: int, colore: Color, contorno: Color = Color.BLACK, spessore: int = 12, testo_normale: bool = false) -> Label3D:
	var l: Label3D = Label3D.new()
	l.text = testo
	l.font = _font_testo if testo_normale else _font
	l.font_size = dimensione
	l.pixel_size = 0.005
	l.modulate = colore
	l.outline_modulate = contorno
	l.outline_size = spessore
	l.double_sided = true
	return l


func materiale_luce(colore: Color, forza: float) -> StandardMaterial3D:
	var m: StandardMaterial3D = StandardMaterial3D.new()
	m.albedo_color = colore
	m.emission_enabled = true
	m.emission = colore
	m.emission_energy_multiplier = forza
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return m


func scintille(colore: Color, quante: int, velocita: float, gravita: float, durata: float, dimensione: float = 0.07) -> CPUParticles3D:
	var p: CPUParticles3D = CPUParticles3D.new()
	p.amount = quante
	p.one_shot = true
	p.explosiveness = 0.95
	p.lifetime = durata
	p.direction = Vector3.UP
	p.spread = 180.0
	p.initial_velocity_min = velocita * 0.4
	p.initial_velocity_max = velocita
	p.gravity = Vector3(0.0, gravita, 0.0)
	p.damping_min = 1.0
	p.damping_max = 3.0
	p.scale_amount_min = 0.5
	p.scale_amount_max = 1.3
	var rampa: Gradient = Gradient.new()
	rampa.set_color(0, colore)
	rampa.set_color(1, Color(colore, 0.0))
	p.color_ramp = rampa
	var q: QuadMesh = QuadMesh.new()
	q.size = Vector2(dimensione, dimensione)
	var m: StandardMaterial3D = StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	m.vertex_color_use_as_albedo = true
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	q.material = m
	p.mesh = q
	p.emitting = false
	return p


func esplodi(genitore: Node3D, posizione: Vector3, p: CPUParticles3D) -> void:
	genitore.add_child(p)
	p.global_position = posizione
	p.restart()
	p.emitting = true
	var t: Tween = create_tween()
	t.tween_interval(p.lifetime + 0.5)
	t.tween_callback(p.queue_free)


## Grana da stampa e vignetta su tutto lo schermo, più una didascalia piccola.
func strato_grana(forza: float, didascalia: String) -> void:
	var strato: CanvasLayer = CanvasLayer.new()
	add_child(strato)
	var r: ColorRect = ColorRect.new()
	r.set_anchors_preset(Control.PRESET_FULL_RECT)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var s: Shader = Shader.new()
	s.code = """
shader_type canvas_item;
uniform float forza = 0.07;
float caso(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
void fragment() {
	float n = caso(floor(FRAGCOORD.xy) + floor(TIME * 24.0) * vec2(17.0, 31.0));
	float v = smoothstep(0.42, 0.95, length((SCREEN_UV - 0.5) * vec2(1.25, 1.0)));
	vec4 grana = vec4(vec3(n), forza);
	COLOR = mix(grana, vec4(0.0, 0.0, 0.0, 0.8), v);
}
"""
	var m: ShaderMaterial = ShaderMaterial.new()
	m.shader = s
	m.set_shader_parameter("forza", forza)
	r.material = m
	strato.add_child(r)
	var l: Label = Label.new()
	l.text = didascalia
	l.add_theme_font_override("font", _font_testo)
	l.add_theme_font_size_override("font_size", 22)
	l.add_theme_color_override("font_color", Color(1, 1, 1, 0.55))
	l.position = Vector2(32, 1036)
	strato.add_child(l)
