class_name RiservaMana
extends Node3D
## La riserva di mana di un lato, sulla plancia sotto lo stendardo (teatro di carta).
## Tre stili da provare (proposte dell'8 novembre 2026, da scegliere con Davide):
## LANTERNE: una lanterna di carta per colore, accesa tanto più quanto mana ha, con il numero sopra.
## ROSONE: un rosone di vetro colorato, un petalo per colore che si accende a spicchi.
## GRU: una gru di carta per colore su un paletto; con il mana apre le ali, il numero è sul cartellino.
## Solo presentazione: legge i numeri dalla simulazione, non decide niente.

enum Stile { LANTERNE, ROSONE, GRU }

const COLORI: Array[StringName] = [&"rosso", &"verde", &"blu", &"viola", &"energetico"]
const SPAZIO: float = 0.44
const SPICCHI: int = 4

var stile: Stile = Stile.LANTERNE
## Lo stile usato dalla plancia (finché Davide non sceglie: si cambia qui).
static var stile_predefinito: Stile = Stile.LANTERNE
## Per ogni colore: il punto d'arrivo del mana (dove vola la gemma) e le parti da animare.
var _arrivi: Dictionary = {}
var _numeri: Dictionary = {}
var _materiali: Dictionary = {}
var _luci: Dictionary = {}
var _spicchi: Dictionary = {}
var _ali: Dictionary = {}
var _valori: Dictionary = {}


func costruisci(p_stile: Stile) -> void:
	stile = p_stile
	match stile:
		Stile.LANTERNE: _crea_lanterne()
		Stile.ROSONE: _crea_rosone()
		Stile.GRU: _crea_gru()
	for mana: StringName in COLORI:
		_valori[mana] = 0
		imposta(mana, 0)


## Il nodo verso cui vola il mana di quel colore.
func arrivo(mana: StringName) -> Node3D:
	return _arrivi.get(mana)


func ha(mana: StringName) -> bool:
	return _arrivi.has(mana)


## Quanto mana di quel colore c'è ora.
func imposta(mana: StringName, quanti: int) -> void:
	if not _arrivi.has(mana):
		return
	var prima: int = int(_valori.get(mana, -1))
	_valori[mana] = quanti
	(_numeri[mana] as Label3D).text = str(quanti) if quanti > 0 else ""
	if prima == quanti:
		return
	match stile:
		Stile.LANTERNE:
			var mat: StandardMaterial3D = _materiali[mana]
			mat.emission_energy_multiplier = 0.0 if quanti == 0 else 1.2 + minf(quanti, 6) * 0.35
			(_luci[mana] as OmniLight3D).light_energy = 0.0 if quanti == 0 else 0.6 + minf(quanti, 6) * 0.15
		Stile.ROSONE:
			var fila: Array = _spicchi[mana]
			for k: int in range(fila.size()):
				(fila[k] as StandardMaterial3D).emission_energy_multiplier = 2.2 if k < quanti else 0.0
		Stile.GRU:
			var aperte: bool = quanti > 0
			for ala: Node3D in _ali[mana]:
				var lato: float = float(ala.get_meta("lato"))
				var t: Tween = create_tween()
				t.tween_property(ala, "rotation:x", (0.55 if aperte else -1.2) * lato, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			(_materiali[mana] as StandardMaterial3D).emission_energy_multiplier = 0.0 if not aperte else 0.6


## Un mana è appena arrivato: piccolo salto del suo pezzo.
func pulsa(mana: StringName) -> void:
	var nodo: Node3D = _arrivi.get(mana)
	if nodo == null:
		return
	var t: Tween = create_tween()
	t.tween_property(nodo, "scale", Vector3.ONE * 1.35, 0.06)
	t.tween_property(nodo, "scale", Vector3.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _numero(dove: Node3D, altezza: float, colore: Color) -> Label3D:
	var n: Label3D = StileVisivo.scritta("", StileVisivo.FONT_TITOLI, 56, StileVisivo.CARTA_CREMA, 0.0, 10)
	n.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	n.outline_modulate = colore.darkened(0.7)
	n.position = Vector3(0.0, altezza, 0.0)
	n.no_depth_test = true
	dove.add_child(n)
	return n


# --- Lanterne ------------------------------------------------------------------------

func _crea_lanterne() -> void:
	for i: int in range(COLORI.size()):
		var mana: StringName = COLORI[i]
		var colore: Color = StileVisivo.colore_mana_nome(mana)
		var nodo: Node3D = Node3D.new()
		nodo.position = Vector3((i - 2) * SPAZIO, 0.0, 0.0)
		add_child(nodo)
		var corpo: MeshInstance3D = MeshInstance3D.new()
		var forma: CylinderMesh = CylinderMesh.new()
		forma.top_radius = 0.13
		forma.bottom_radius = 0.15
		forma.height = 0.34
		forma.radial_segments = 12
		corpo.mesh = forma
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.albedo_color = StileVisivo.CARTA_CREMA.lerp(colore, 0.35)
		mat.emission_enabled = true
		mat.emission = colore
		mat.roughness = 0.9
		corpo.material_override = mat
		corpo.position.y = 0.2
		nodo.add_child(corpo)
		for y: float in [0.03, 0.37]:
			var anello: MeshInstance3D = MeshInstance3D.new()
			var fa: CylinderMesh = CylinderMesh.new()
			fa.top_radius = 0.155
			fa.bottom_radius = 0.155
			fa.height = 0.04
			anello.mesh = fa
			anello.material_override = StileVisivo.materiale(Color("120d0a"), 0.9)
			anello.position.y = y
			nodo.add_child(anello)
		var luce: OmniLight3D = OmniLight3D.new()
		luce.light_color = colore
		luce.omni_range = 1.3
		luce.position.y = 0.25
		nodo.add_child(luce)
		_arrivi[mana] = nodo
		_materiali[mana] = mat
		_luci[mana] = luce
		_numeri[mana] = _numero(nodo, 0.62, colore)


# --- Rosone -----------------------------------------------------------------------

func _crea_rosone() -> void:
	var disco: Node3D = Node3D.new()
	# In piedi e un po' inclinato verso la telecamera, come un rosone di carta ritagliata.
	disco.rotation.x = deg_to_rad(-55.0)
	disco.position = Vector3(0.0, 0.05, 0.0)
	add_child(disco)
	var fondo: MeshInstance3D = MeshInstance3D.new()
	var cf: CylinderMesh = CylinderMesh.new()
	cf.top_radius = 0.95
	cf.bottom_radius = 0.95
	cf.height = 0.04
	cf.radial_segments = 40
	fondo.mesh = cf
	fondo.material_override = StileVisivo.materiale(StileVisivo.CARTA_CREMA, 0.9)
	disco.add_child(fondo)
	var piombo: MeshInstance3D = MeshInstance3D.new()
	var cp: CylinderMesh = CylinderMesh.new()
	cp.top_radius = 0.87
	cp.bottom_radius = 0.87
	cp.height = 0.05
	cp.radial_segments = 40
	piombo.mesh = cp
	piombo.material_override = StileVisivo.materiale(Color("120d0a"), 0.9)
	disco.add_child(piombo)
	for i: int in range(COLORI.size()):
		var mana: StringName = COLORI[i]
		var colore: Color = StileVisivo.colore_mana_nome(mana)
		var angolo: float = -PI * 0.5 + TAU * float(i) / float(COLORI.size())
		var fila: Array[StandardMaterial3D] = []
		for s: int in range(SPICCHI):
			var r0: float = 0.15 + s * 0.17
			var r1: float = r0 + 0.14
			var largo: float = TAU / float(COLORI.size()) * 0.42
			var st: SurfaceTool = SurfaceTool.new()
			st.begin(Mesh.PRIMITIVE_TRIANGLES)
			for k: int in range(6):
				var a0: float = angolo - largo + largo * 2.0 * float(k) / 6.0
				var a1: float = angolo - largo + largo * 2.0 * float(k + 1) / 6.0
				var p: Array[Vector3] = [Vector3(cos(a0) * r0, 0.0, sin(a0) * r0), Vector3(cos(a1) * r0, 0.0, sin(a1) * r0), Vector3(cos(a0) * r1, 0.0, sin(a0) * r1), Vector3(cos(a1) * r1, 0.0, sin(a1) * r1)]
				for v: Vector3 in [p[0], p[2], p[1], p[1], p[2], p[3]]:
					st.set_normal(Vector3.UP)
					st.add_vertex(v)
			var vetro: MeshInstance3D = MeshInstance3D.new()
			vetro.mesh = st.commit()
			var mat: StandardMaterial3D = StandardMaterial3D.new()
			mat.albedo_color = colore.darkened(0.7)
			mat.emission_enabled = true
			mat.emission = colore
			mat.cull_mode = BaseMaterial3D.CULL_DISABLED
			mat.roughness = 0.2
			vetro.material_override = mat
			vetro.position.y = 0.035
			disco.add_child(vetro)
			fila.append(mat)
		_spicchi[mana] = fila
		var punta: Node3D = Node3D.new()
		punta.position = Vector3(cos(angolo) * 1.12, 0.03, sin(angolo) * 1.12)
		disco.add_child(punta)
		_arrivi[mana] = punta
		_numeri[mana] = _numero(punta, 0.0, colore)


# --- Gru di carta ---------------------------------------------------------------------

func _crea_gru() -> void:
	for i: int in range(COLORI.size()):
		var mana: StringName = COLORI[i]
		var colore: Color = StileVisivo.colore_mana_nome(mana)
		var nodo: Node3D = Node3D.new()
		nodo.position = Vector3((i - 2) * SPAZIO, 0.0, 0.0)
		add_child(nodo)
		var palo: MeshInstance3D = MeshInstance3D.new()
		var fp: CylinderMesh = CylinderMesh.new()
		fp.top_radius = 0.02
		fp.bottom_radius = 0.03
		fp.height = 0.22
		palo.mesh = fp
		palo.material_override = StileVisivo.materiale(Color("2a1d12"), 0.9)
		palo.position.y = 0.11
		nodo.add_child(palo)
		var gru: Node3D = Node3D.new()
		gru.position.y = 0.26
		gru.rotation.y = PI * 0.5
		gru.scale = Vector3.ONE * 0.75
		nodo.add_child(gru)
		var carta: StandardMaterial3D = StandardMaterial3D.new()
		carta.albedo_color = colore
		carta.cull_mode = BaseMaterial3D.CULL_DISABLED
		carta.roughness = 0.7
		carta.emission_enabled = true
		carta.emission = colore
		var piega: StandardMaterial3D = carta.duplicate() as StandardMaterial3D
		piega.albedo_color = colore.darkened(0.35)
		gru.add_child(_pezzo([Vector3(-0.22, 0.0, 0.0), Vector3(0.22, 0.0, 0.0), Vector3(0.0, 0.16, 0.0), Vector3(0.0, -0.02, 0.1), Vector3(0.0, -0.02, -0.1)], [[0, 2, 3], [1, 2, 3], [0, 2, 4], [1, 2, 4]], carta))
		gru.add_child(_pezzo([Vector3(0.2, 0.02, 0.0), Vector3(0.42, 0.32, 0.0), Vector3(0.24, 0.0, 0.02)], [[0, 1, 2]], piega))
		gru.add_child(_pezzo([Vector3(-0.2, 0.02, 0.0), Vector3(-0.42, 0.26, 0.0), Vector3(-0.24, 0.0, 0.02)], [[0, 1, 2]], piega))
		var ali: Array[Node3D] = []
		for lato: float in [1.0, -1.0]:
			var perno: Node3D = Node3D.new()
			perno.position = Vector3(0.0, 0.1, 0.0)
			perno.set_meta("lato", lato)
			perno.add_child(_pezzo([Vector3(-0.12, 0.0, 0.0), Vector3(0.12, 0.0, 0.0), Vector3(-0.05, 0.0, 0.42 * lato)], [[0, 1, 2]], carta))
			gru.add_child(perno)
			ali.append(perno)
		_ali[mana] = ali
		_arrivi[mana] = nodo
		_materiali[mana] = carta
		_numeri[mana] = _numero(nodo, 0.72, colore)


func _pezzo(punti: Array, facce: Array, materiale: Material) -> MeshInstance3D:
	var st: SurfaceTool = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for f: Array in facce:
		for i: int in f:
			st.add_vertex(punti[i])
	st.generate_normals()
	var m: MeshInstance3D = MeshInstance3D.new()
	m.mesh = st.commit()
	m.material_override = materiale
	return m
