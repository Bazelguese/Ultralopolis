class_name RiservaMana
extends Node3D
## La riserva di mana di un lato, sulla plancia sotto lo stendardo (teatro di carta, Davide
## 9 novembre 2026): una sfera di vetro per colore, disposte in cerchio. Vuota è scura; quando
## arriva il mana si illumina, e dentro girano tante scintille quanto è il mana (fino a
## MASSIMO_SCINTILLE), con il numero sotto. Arrivo: lampo, salto e "+1". Spesa: la sfera si abbassa.
## Solo presentazione: legge i numeri dalla simulazione, non decide niente.

const COLORI: Array[StringName] = [&"rosso", &"verde", &"blu", &"viola", &"energetico"]
## Il mana energetico (giallo) sta al centro ed è più grande; gli altri quattro attorno, a croce
## (Davide, 9 novembre 2026).
const RAGGIO_CERCHIO: float = 0.78
## In prospettiva la profondità si accorcia: la croce è più lunga verso la telecamera.
const PROFONDITA_CROCE: float = 1.3
const RAGGIO_SFERA: float = 0.25
const RAGGIO_CENTRO: float = 0.32
const MASSIMO_SCINTILLE: int = 8
## Quanta luce dà la sfera a seconda del mana: piena a questo numero.
const PIENA: int = 6

const SHADER: String = """
shader_type spatial;
render_mode blend_mix, cull_back, depth_draw_always;
uniform vec3 colore : source_color = vec3(1.0);
uniform float carica = 0.0;
uniform float lampo = 0.0;
uniform float piena = 0.0;
uniform float manca = 0.0;
void fragment() {
	float bordo = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 2.5);
	vec2 p = UV * vec2(6.2831, 3.1416);
	float vortice = 0.5 + 0.5 * sin(p.x * 3.0 + TIME * 2.2 + sin(p.y * 4.0 - TIME * 1.7) * 1.8);
	float nucleo = pow(clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
	float accesa = step(0.001, carica);
	ALBEDO = mix(vec3(0.012, 0.01, 0.01), colore * 0.2, accesa);
	float battito = 0.5 + 0.5 * sin(TIME * 5.0);
	EMISSION = colore * (carica * (0.8 + 2.2 * vortice * nucleo) + bordo * (0.45 + 1.6 * carica + piena * 1.2 * battito) + lampo * 3.5)
		+ vec3(1.0, 0.12, 0.08) * bordo * manca * (0.6 + 2.4 * step(0.5, fract(TIME * 2.5)));
	ROUGHNESS = 0.25;
	SPECULAR = 0.3;
	ALPHA = clamp(0.8 + 0.2 * bordo, 0.0, 1.0);
}
"""

static var _shader: Shader

var _sfere: Dictionary = {}
var _materiali: Dictionary = {}
var _luci: Dictionary = {}
var _numeri: Dictionary = {}
var _scintille: Dictionary = {}
var _valori: Dictionary = {}
var _cariche: Dictionary = {}
var _tempo: float = 0.0


func costruisci() -> void:
	if _shader == null:
		_shader = Shader.new()
		_shader.code = SHADER
	var attorno: Array[StringName] = [&"rosso", &"verde", &"blu", &"viola"]
	for i: int in range(attorno.size()):
		# A croce: rosso in alto (lontano dalla telecamera), poi in senso orario.
		var angolo: float = -PI * 0.5 + TAU * float(i) / float(attorno.size())
		_crea_sfera(attorno[i], Vector3(cos(angolo) * RAGGIO_CERCHIO, 0.0, sin(angolo) * RAGGIO_CERCHIO * PROFONDITA_CROCE), RAGGIO_SFERA)
	_crea_sfera(&"energetico", Vector3.ZERO, RAGGIO_CENTRO)
	for mana: StringName in COLORI:
		imposta(mana, 0)


func _crea_sfera(mana: StringName, posizione: Vector3, raggio: float) -> void:
	var colore: Color = StileVisivo.colore_mana_nome(mana)
	var nodo: Node3D = Node3D.new()
	nodo.position = posizione
	add_child(nodo)
	# Base: un anello di carta crema su cui la sfera poggia.
	var base: MeshInstance3D = MeshInstance3D.new()
	var forma_base: CylinderMesh = CylinderMesh.new()
	forma_base.top_radius = raggio * 0.95
	forma_base.bottom_radius = raggio * 1.15
	forma_base.height = 0.06
	forma_base.radial_segments = 24
	base.mesh = forma_base
	base.material_override = StileVisivo.materiale(StileVisivo.CARTA_CREMA.darkened(0.15), 0.9)
	base.position.y = 0.03
	nodo.add_child(base)
	var sfera: MeshInstance3D = MeshInstance3D.new()
	var forma: SphereMesh = SphereMesh.new()
	forma.radius = raggio
	forma.height = raggio * 2.0
	forma.radial_segments = 32
	forma.rings = 16
	sfera.mesh = forma
	var materiale: ShaderMaterial = ShaderMaterial.new()
	materiale.shader = _shader
	materiale.set_shader_parameter("colore", colore)
	sfera.material_override = materiale
	sfera.position.y = 0.06 + raggio
	nodo.add_child(sfera)
	var luce: OmniLight3D = OmniLight3D.new()
	luce.light_color = colore
	luce.omni_range = 1.4
	luce.light_energy = 0.0
	luce.position.y = sfera.position.y
	nodo.add_child(luce)
	# Le scintille che girano dentro la sfera: tante quanto è il mana.
	var gruppo: Array[MeshInstance3D] = []
	var punto: SphereMesh = SphereMesh.new()
	punto.radius = 0.022
	punto.height = 0.044
	punto.material = StileVisivo.materiale_luminoso(colore.lightened(0.6), 5.0)
	for k: int in range(MASSIMO_SCINTILLE):
		var s: MeshInstance3D = MeshInstance3D.new()
		s.mesh = punto
		s.visible = false
		s.set_meta("fase", float(k) * TAU / float(MASSIMO_SCINTILLE))
		s.set_meta("velocita", 1.6 + float(k % 3) * 0.7)
		s.set_meta("piega", 0.5 + float(k % 4) * 0.35)
		sfera.add_child(s)
		gruppo.append(s)
	var numero: Label3D = StileVisivo.scritta("", StileVisivo.FONT_TITOLI, 50, StileVisivo.CARTA_CREMA, 0.0, 10)
	numero.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	numero.outline_modulate = colore.darkened(0.75)
	numero.no_depth_test = true
	numero.position = Vector3(0.0, sfera.position.y + raggio + 0.16, 0.0)
	nodo.add_child(numero)
	sfera.set_meta("raggio", raggio)
	_sfere[mana] = sfera
	_materiali[mana] = materiale
	_luci[mana] = luce
	_numeri[mana] = numero
	_scintille[mana] = gruppo


## Il nodo verso cui vola il mana di quel colore (e da cui parte quando una truppa lo spende).
func arrivo(mana: StringName) -> Node3D:
	return _sfere.get(mana)


func ha(mana: StringName) -> bool:
	return _sfere.has(mana)


## Quanto mana di quel colore c'è ora.
func imposta(mana: StringName, quanti: int) -> void:
	if not _sfere.has(mana):
		return
	var prima: int = int(_valori.get(mana, -1))
	if prima == quanti:
		return
	_valori[mana] = quanti
	(_numeri[mana] as Label3D).text = str(quanti) if quanti > 0 else ""
	var carica: float = clampf(float(quanti) / float(PIENA), 0.0, 1.0)
	if quanti > 0:
		carica = maxf(carica, 0.3)
	var t: Tween = create_tween()
	t.set_parallel(true)
	var materiale: ShaderMaterial = _materiali[mana]
	var da: float = float(_cariche.get(mana, 0.0))
	_cariche[mana] = carica
	t.tween_method(func(v: float) -> void: materiale.set_shader_parameter("carica", v), da, carica, 0.25)
	t.tween_property(_luci[mana], "light_energy", carica * 1.6, 0.25)
	materiale.set_shader_parameter("piena", 1.0 if quanti >= PIENA else 0.0)
	var gruppo: Array = _scintille[mana]
	for k: int in range(gruppo.size()):
		(gruppo[k] as MeshInstance3D).visible = k < quanti
	if prima >= 0 and quanti < prima:
		_spegni_un_poco(mana)


## Le sfere dei colori che mancano a una truppa in attesa lampeggiano di rosso (principio P4).
func segnala_mancanze(colori: Array[StringName]) -> void:
	for mana: StringName in _materiali:
		(_materiali[mana] as ShaderMaterial).set_shader_parameter("manca", 1.0 if colori.has(mana) else 0.0)


## Un mana è appena arrivato: lampo, salto e "+1" che sale.
func pulsa(mana: StringName) -> void:
	var sfera: Node3D = _sfere.get(mana)
	if sfera == null:
		return
	var materiale: ShaderMaterial = _materiali[mana]
	var lampo: Tween = create_tween()
	lampo.tween_method(func(v: float) -> void: materiale.set_shader_parameter("lampo", v), 1.0, 0.0, 0.4)
	var salto: Tween = create_tween()
	salto.tween_property(sfera, "scale", Vector3.ONE * 1.3, 0.06)
	salto.tween_property(sfera, "scale", Vector3.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var piu: Label3D = StileVisivo.scritta("+1", StileVisivo.FONT_TITOLI, 46, StileVisivo.colore_mana_nome(mana).lightened(0.4), 0.0, 10)
	piu.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	piu.no_depth_test = true
	piu.outline_modulate = Color("120d0a")
	piu.position = sfera.position + Vector3(float(sfera.get_meta("raggio")) + 0.12, 0.1, 0.0)
	(sfera.get_parent() as Node3D).add_child(piu)
	var sale: Tween = create_tween()
	sale.set_parallel(true)
	sale.tween_property(piu, "position:y", piu.position.y + 0.55, 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	sale.tween_property(piu, "modulate:a", 0.0, 0.3).set_delay(0.4)
	sale.tween_property(piu, "outline_modulate:a", 0.0, 0.3).set_delay(0.4)
	sale.chain().tween_callback(piu.queue_free)


## Quando il mana viene speso la sfera si stringe un attimo.
func _spegni_un_poco(mana: StringName) -> void:
	var sfera: Node3D = _sfere[mana]
	var t: Tween = create_tween()
	t.tween_property(sfera, "scale", Vector3.ONE * 0.82, 0.07)
	t.tween_property(sfera, "scale", Vector3.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	_tempo += delta
	for mana: StringName in _scintille:
		var r: float = float((_sfere[mana] as Node3D).get_meta("raggio")) * 0.55
		for s: MeshInstance3D in _scintille[mana]:
			if not s.visible:
				continue
			var a: float = float(s.get_meta("fase")) + _tempo * float(s.get_meta("velocita"))
			var piega: float = float(s.get_meta("piega"))
			s.position = Vector3(cos(a) * r, sin(a * piega) * r * 0.6, sin(a) * r)
