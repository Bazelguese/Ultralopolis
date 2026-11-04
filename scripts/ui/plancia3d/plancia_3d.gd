extends Node3D
## Prova visiva della plancia 3D in stile fantasy moderno (GDD §14.2).
## Mostra come potrebbe apparire la partita: il tavolo, la plancia, le offerte e la battaglia.
## IMPORTANTE: quello che si muove segue un copione dimostrativo con numeri di esempio.
## Non è la simulazione del gioco e non contiene regole: la battaglia vera userà BattleSim.

enum Vista { PARTITA, BATTAGLIA }
enum Lato { GIOCATORE, FANTASMA }

const PASSO_TRUPPE: float = 1.75
const PASSO_EDIFICI: float = 2.1
const MISURA_TRUPPA: Vector2 = Vector2(1.58, 1.95)
const MISURA_EDIFICIO: Vector2 = Vector2(1.9, 1.6)
const SCALA_OFFERTA: float = 1.45
const Z_TRUPPE: float = 1.75
const Z_EDIFICI: float = 4.4
## Centro orizzontale degli spazi: a sinistra resta la colonna con Resistenza e mana.
const X_SPAZI: float = 0.9
const SPAZI_TRUPPE: int = 12
const SPAZI_EDIFICI: int = 10
const CAPACITA_TRUPPE: int = 4
const CAPACITA_EDIFICI: int = 5
const X_MEDAGLIONE: float = -11.2
const RESISTENZA_GIOCATORE: int = 90
const RESISTENZA_FANTASMA: int = 110

## Inquadrature della telecamera: posizione e punto guardato.
const CAMERA_PARTITA: Vector3 = Vector3(-0.4, 27.0, 14.6)
const MIRA_PARTITA: Vector3 = Vector3(-0.4, 0.0, 0.9)
const CAMERA_BATTAGLIA: Vector3 = Vector3(-0.4, 28.4, 14.5)
const MIRA_BATTAGLIA: Vector3 = Vector3(-0.4, 0.0, 0.0)

var vista: Vista = Vista.PARTITA

var _camera: Camera3D
var _candela: OmniLight3D
var _hud: HudPlancia
var _plancia: Array[Node3D] = [null, null]
var _truppe: Array[Array] = [[], []]
var _edifici: Array[Array] = [[], []]
var _ricarica_truppe: Array[Array] = [[], []]
var _ricarica_edifici: Array[Array] = [[], []]
var _lampo_truppe: Array[Array] = [[], []]
var _offerte: Array[Tessera3D] = []
var _spazio_libero: Node3D
var _riserva: Array[Dictionary] = [{}, {}]
var _scritte_riserva: Array[Dictionary] = [{}, {}]
var _nodo_riserva: Array[Node3D] = [null, null]
var _posizioni_riserva: Array[Dictionary] = [{}, {}]
var _resistenza: Array[int] = [RESISTENZA_GIOCATORE, RESISTENZA_FANTASMA]
var _scritte_resistenza: Array[Label3D] = [null, null]
var _barre_resistenza: Array[MeshInstance3D] = [null, null]
var _tempo_battaglia: float = 0.0
var _velocita: float = 1.0
var _in_pausa: bool = false
var _battaglia_finita: bool = false
var _evidenziata: Tessera3D
var _scelta_in_corso: bool = false
var _tempo_candela: float = 0.0


func _ready() -> void:
	_crea_ambiente()
	_crea_tavolo()
	_plancia[Lato.GIOCATORE] = _crea_plancia(Lato.GIOCATORE)
	_plancia[Lato.FANTASMA] = _crea_plancia(Lato.FANTASMA)
	_crea_offerte()
	var livello: CanvasLayer = CanvasLayer.new()
	add_child(livello)
	_hud = HudPlancia.new()
	livello.add_child(_hud)
	_hud.cambia_vista_premuto.connect(_on_cambia_vista)
	_hud.ricomincia_premuto.connect(func() -> void: get_tree().reload_current_scene())
	_hud.rinnova_premuto.connect(_on_rinnova)
	_hud.passa_premuto.connect(_on_passa)
	_hud.velocita_scelta.connect(func(fattore: float) -> void: _velocita = fattore)
	_hud.pausa_premuta.connect(_on_pausa)
	_applica_vista(false)


# --- Ambiente ------------------------------------------------------------------

func _crea_ambiente() -> void:
	var mondo: WorldEnvironment = WorldEnvironment.new()
	var ambiente: Environment = Environment.new()
	ambiente.background_mode = Environment.BG_COLOR
	ambiente.background_color = StileVisivo.NOTTE
	ambiente.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	ambiente.ambient_light_color = Color("4a5a80")
	ambiente.ambient_light_energy = 0.45
	ambiente.tonemap_mode = Environment.TONE_MAPPER_ACES
	ambiente.glow_enabled = true
	ambiente.glow_intensity = 0.55
	ambiente.glow_bloom = 0.0
	ambiente.glow_hdr_threshold = 1.2
	mondo.environment = ambiente
	add_child(mondo)

	var sole: DirectionalLight3D = DirectionalLight3D.new()
	sole.light_color = Color("fff0d8")
	sole.light_energy = 0.9
	sole.shadow_enabled = true
	sole.rotation_degrees = Vector3(-60.0, -25.0, 0.0)
	add_child(sole)

	var controluce: DirectionalLight3D = DirectionalLight3D.new()
	controluce.light_color = Color("6a8cff")
	controluce.light_energy = 0.35
	controluce.rotation_degrees = Vector3(-30.0, 155.0, 0.0)
	add_child(controluce)

	## Luce d'atmosfera che pulsa piano (solo effetto visivo).
	_candela = OmniLight3D.new()
	_candela.light_color = Color("8a5cff")
	_candela.light_energy = 1.6
	_candela.omni_range = 22.0
	_candela.position = Vector3(-15.0, 5.0, -8.0)
	add_child(_candela)

	_camera = Camera3D.new()
	_camera.fov = 30.0
	add_child(_camera)
	_camera.look_at_from_position(CAMERA_PARTITA, MIRA_PARTITA, Vector3.UP)


func _crea_tavolo() -> void:
	var terreno: MeshInstance3D = MeshInstance3D.new()
	var forma: BoxMesh = BoxMesh.new()
	forma.size = Vector3(70.0, 0.5, 50.0)
	terreno.mesh = forma
	terreno.material_override = StileVisivo.materiale_pietra(StileVisivo.PIETRA_SCURA.darkened(0.2), 3.0)
	terreno.position.y = -0.45
	add_child(terreno)


# --- Plance --------------------------------------------------------------------

## La plancia di un lato: lastra di pietra con il bordo illuminato, spazi, edifici, truppe, stemma e mana.
## Il fantasma sta dall'altra parte del tavolo: stesse file, specchiate (truppe verso il centro).
func _crea_plancia(lato: Lato) -> Node3D:
	var radice: Node3D = Node3D.new()
	add_child(radice)
	var segno: float = 1.0 if lato == Lato.GIOCATORE else -1.0
	var z_centro: float = (Z_TRUPPE + Z_EDIFICI) * 0.5 * segno
	_crea_lastra(radice, Vector3(-0.43, 0.0, z_centro), Vector2(24.35, 5.0), _colore_lato(lato))

	var truppe: Array[DatiEsempioPlancia.Pezzo] = DatiEsempioPlancia.truppe_giocatore() if lato == Lato.GIOCATORE else DatiEsempioPlancia.truppe_fantasma()
	var edifici: Array[DatiEsempioPlancia.Pezzo] = DatiEsempioPlancia.edifici_giocatore() if lato == Lato.GIOCATORE else DatiEsempioPlancia.edifici_fantasma()
	var capacita_truppe: int = CAPACITA_TRUPPE if lato == Lato.GIOCATORE else truppe.size()
	var capacita_edifici: int = CAPACITA_EDIFICI if lato == Lato.GIOCATORE else edifici.size()

	for i: int in range(SPAZI_TRUPPE):
		var posizione: Vector3 = Vector3(X_SPAZI + (i - (SPAZI_TRUPPE - 1) * 0.5) * PASSO_TRUPPE, 0.02, Z_TRUPPE * segno)
		if i < truppe.size():
			var tessera: Tessera3D = _crea_tessera(radice, truppe[i], MISURA_TRUPPA, posizione)
			_truppe[lato].append(tessera)
			_ricarica_truppe[lato].append(0.0)
			_lampo_truppe[lato].append(0.0)
		elif lato == Lato.GIOCATORE:
			_crea_spazio(radice, posizione, MISURA_TRUPPA, i < capacita_truppe, _colore_lato(lato))
	for i: int in range(SPAZI_EDIFICI):
		var posizione: Vector3 = Vector3(X_SPAZI + (i - (SPAZI_EDIFICI - 1) * 0.5) * PASSO_EDIFICI, 0.02, Z_EDIFICI * segno)
		if i < edifici.size():
			_edifici[lato].append(_crea_tessera(radice, edifici[i], MISURA_EDIFICIO, posizione))
			_ricarica_edifici[lato].append(0.0)
		elif lato == Lato.GIOCATORE:
			var spazio: Node3D = _crea_spazio(radice, posizione, MISURA_EDIFICIO, i < capacita_edifici, _colore_lato(lato))
			if lato == Lato.GIOCATORE and i < capacita_edifici and _spazio_libero == null:
				_spazio_libero = spazio

	if lato == Lato.GIOCATORE:
		var nota: Label3D = StileVisivo.scritta("LE TRUPPE AGISCONO DA DESTRA VERSO SINISTRA  ←", StileVisivo.FONT_TESTO_FORTE, 50, StileVisivo.TESTO_TENUE)
		nota.position = Vector3(7.0, 0.02, 0.0)
		radice.add_child(nota)

	_crea_medaglione(radice, lato, z_centro)
	_crea_riserva(radice, lato, z_centro)
	return radice


func _colore_lato(lato: int) -> Color:
	return StileVisivo.COLORE_GIOCATORE if lato == Lato.GIOCATORE else StileVisivo.COLORE_FANTASMA


## Lastra di pietra con un bordo luminoso del colore del lato.
func _crea_lastra(radice: Node3D, centro: Vector3, misura: Vector2, colore: Color) -> void:
	var lastra: MeshInstance3D = MeshInstance3D.new()
	var forma: BoxMesh = BoxMesh.new()
	forma.size = Vector3(misura.x, 0.4, misura.y)
	lastra.mesh = forma
	lastra.material_override = StileVisivo.materiale_pietra(StileVisivo.PIETRA, 2.5)
	lastra.position = centro + Vector3(0.0, -0.18, 0.0)
	radice.add_child(lastra)
	var luce: StandardMaterial3D = StileVisivo.materiale_luminoso(colore, 1.3)
	var lati: Array[Vector3] = [
		Vector3(0.0, 0.0, -misura.y * 0.5), Vector3(0.0, 0.0, misura.y * 0.5),
		Vector3(-misura.x * 0.5, 0.0, 0.0), Vector3(misura.x * 0.5, 0.0, 0.0),
	]
	for i: int in range(lati.size()):
		var bordo: MeshInstance3D = MeshInstance3D.new()
		var forma_bordo: BoxMesh = BoxMesh.new()
		forma_bordo.size = Vector3(misura.x + 0.1, 0.07, 0.07) if i < 2 else Vector3(0.07, 0.07, misura.y + 0.1)
		bordo.mesh = forma_bordo
		bordo.material_override = luce
		bordo.position = centro + lati[i] + Vector3(0.0, 0.035, 0.0)
		radice.add_child(bordo)


func _crea_tessera(radice: Node3D, dati: DatiEsempioPlancia.Pezzo, misura: Vector2, posizione: Vector3) -> Tessera3D:
	var tessera: Tessera3D = Tessera3D.new()
	radice.add_child(tessera)
	tessera.costruisci(dati, misura.x, misura.y)
	tessera.position = posizione
	return tessera


## Spazio vuoto: velato del colore del lato se è disponibile, scuro se va ancora conquistato.
func _crea_spazio(radice: Node3D, posizione: Vector3, misura: Vector2, disponibile: bool, colore_lato: Color) -> Node3D:
	var spazio: MeshInstance3D = MeshInstance3D.new()
	var forma: PlaneMesh = PlaneMesh.new()
	forma.size = misura
	spazio.mesh = forma
	var colore: Color = Color(colore_lato, 0.16) if disponibile else Color(0.0, 0.0, 0.0, 0.28)
	spazio.material_override = StileVisivo.materiale_velo(colore)
	spazio.position = posizione + Vector3(0.0, 0.012, 0.0)
	radice.add_child(spazio)
	if disponibile:
		var scritta: Label3D = StileVisivo.scritta("LIBERO", StileVisivo.FONT_TITOLI, 46, Color(colore_lato, 0.85), 0.0, 6)
		scritta.position = Vector3(0.0, 0.004, 0.0)
		spazio.add_child(scritta)
	return spazio


## Colonna a sinistra della plancia: stemma con la Resistenza, nome, barra e riserva di mana.
func _crea_medaglione(radice: Node3D, lato: Lato, z_centro: float) -> void:
	var colore: Color = _colore_lato(lato)
	var centro_stemma: Vector3 = Vector3(X_MEDAGLIONE, 0.0, z_centro - 1.15)
	var bordo: MeshInstance3D = MeshInstance3D.new()
	var forma_bordo: CylinderMesh = CylinderMesh.new()
	forma_bordo.top_radius = 0.95
	forma_bordo.bottom_radius = 1.0
	forma_bordo.height = 0.16
	bordo.mesh = forma_bordo
	bordo.material_override = StileVisivo.materiale_metallo(StileVisivo.ORO)
	bordo.position = centro_stemma + Vector3(0.0, 0.08, 0.0)
	radice.add_child(bordo)
	var disco: MeshInstance3D = MeshInstance3D.new()
	var forma_disco: CylinderMesh = CylinderMesh.new()
	forma_disco.top_radius = 0.8
	forma_disco.bottom_radius = 0.8
	forma_disco.height = 0.18
	disco.mesh = forma_disco
	disco.material_override = StileVisivo.materiale(colore.darkened(0.55), 0.5)
	disco.position = centro_stemma + Vector3(0.0, 0.09, 0.0)
	radice.add_child(disco)
	var numero: Label3D = StileVisivo.scritta(str(_resistenza[lato]), StileVisivo.FONT_TITOLI, 140, Color.WHITE, 0.0, 18)
	numero.position = centro_stemma + Vector3(0.0, 0.2, 0.0)
	radice.add_child(numero)
	_scritte_resistenza[lato] = numero
	var nome: String = "VALFIUME" if lato == Lato.GIOCATORE else "REGNO DI ALTAMURA"
	var titolo: Label3D = StileVisivo.scritta(nome, StileVisivo.FONT_TITOLI, 44, StileVisivo.TESTO, 0.0, 8)
	titolo.position = Vector3(X_MEDAGLIONE, 0.04, z_centro + 0.0)
	radice.add_child(titolo)
	var fondo_barra: MeshInstance3D = MeshInstance3D.new()
	var forma_fondo: BoxMesh = BoxMesh.new()
	forma_fondo.size = Vector3(1.9, 0.04, 0.2)
	fondo_barra.mesh = forma_fondo
	fondo_barra.material_override = StileVisivo.materiale(StileVisivo.NOTTE, 0.9)
	fondo_barra.position = Vector3(X_MEDAGLIONE, 0.04, z_centro + 0.36)
	radice.add_child(fondo_barra)
	var barra: MeshInstance3D = MeshInstance3D.new()
	var forma_barra: BoxMesh = BoxMesh.new()
	forma_barra.size = Vector3(1.9, 0.05, 0.14)
	barra.mesh = forma_barra
	barra.material_override = StileVisivo.materiale_luminoso(colore, 0.9)
	barra.position = fondo_barra.position + Vector3(0.0, 0.01, 0.0)
	radice.add_child(barra)
	_barre_resistenza[lato] = barra


## Riserva di mana sotto lo stemma: una gemma per colore con il conteggio.
func _crea_riserva(radice: Node3D, lato: Lato, z_centro: float) -> void:
	var nodo: Node3D = Node3D.new()
	nodo.position = Vector3(X_MEDAGLIONE, 0.0, z_centro + 1.05)
	radice.add_child(nodo)
	_nodo_riserva[lato] = nodo
	var colori: Array[int] = [StileVisivo.Mana.ROSSO, StileVisivo.Mana.VERDE, StileVisivo.Mana.BLU, StileVisivo.Mana.ENERGETICO]
	for i: int in range(colori.size()):
		var mana: int = colori[i]
		var x: float = (i - 1.5) * 0.55
		var gemma: MeshInstance3D = MeshInstance3D.new()
		var forma: CylinderMesh = CylinderMesh.new()
		forma.top_radius = 0.19
		forma.bottom_radius = 0.23
		forma.height = 0.12
		forma.radial_segments = 6
		gemma.mesh = forma
		gemma.material_override = StileVisivo.materiale_gemma(mana)
		gemma.position = Vector3(x, 0.08, 0.0)
		nodo.add_child(gemma)
		var conteggio: Label3D = StileVisivo.scritta("0", StileVisivo.FONT_TITOLI, 64, Color.WHITE, 0.0, 10)
		conteggio.position = Vector3(x, 0.04, 0.5)
		nodo.add_child(conteggio)
		_riserva[lato][mana] = 0
		_scritte_riserva[lato][mana] = conteggio
		_posizioni_riserva[lato][mana] = gemma


# --- Offerte -------------------------------------------------------------------

## Le tre alternative dell'opportunità, posate sopra il tavolo di fronte alla plancia.
func _crea_offerte() -> void:
	var dati: Array[DatiEsempioPlancia.Pezzo] = DatiEsempioPlancia.offerte()
	for i: int in range(dati.size()):
		var tessera: Tessera3D = Tessera3D.new()
		add_child(tessera)
		tessera.costruisci(dati[i], MISURA_EDIFICIO.x, MISURA_EDIFICIO.y)
		var tipo: Label3D = StileVisivo.scritta(dati[i].tipo_offerta.to_upper(), StileVisivo.FONT_TITOLI, 44, StileVisivo.TESTO, 0.0, 10)
		tipo.position = Vector3(0.0, 0.02, -MISURA_EDIFICIO.y * 0.5 - 0.22)
		tipo.set_meta("solo_offerta", true)
		tessera.add_child(tipo)
		var costo: Label3D = StileVisivo.scritta(dati[i].costo, StileVisivo.FONT_TITOLI, 54, StileVisivo.ORO_LUCE, 0.0, 12)
		costo.position = Vector3(0.0, 0.02, MISURA_EDIFICIO.y * 0.5 + 0.25)
		costo.set_meta("solo_offerta", true)
		tessera.add_child(costo)
		tessera.position = _posizione_offerta(i)
		tessera.rotation_degrees = Vector3(28.0, 0.0, 0.0)
		tessera.scale = Vector3.ONE * SCALA_OFFERTA
		_offerte.append(tessera)


func _posizione_offerta(indice: int) -> Vector3:
	return Vector3(-0.4 + (indice - 1) * 4.4, 1.8, -2.4)


func _mostra_offerte(visibili: bool) -> void:
	for i: int in range(_offerte.size()):
		var tessera: Tessera3D = _offerte[i]
		var animazione: Tween = create_tween()
		if visibili:
			tessera.visible = true
			tessera.position = _posizione_offerta(i) + Vector3(0.0, 6.0, -4.0)
			animazione.tween_interval(0.08 * i)
			animazione.tween_property(tessera, "position", _posizione_offerta(i), 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		else:
			animazione.tween_property(tessera, "position", tessera.position + Vector3(0.0, 6.0, -4.0), 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			animazione.tween_callback(tessera.hide)


## Scelta di un'offerta: la tessera vola nello spazio libero della plancia (solo dimostrazione).
func _scegli_offerta(tessera: Tessera3D) -> void:
	if _scelta_in_corso:
		return
	if tessera.pezzo.tipo_offerta != "Costruttori" or _spazio_libero == null:
		_hud.mostra_messaggio("%s scelta" % tessera.pezzo.tipo_offerta)
		_mostra_offerte(false)
		return
	_scelta_in_corso = true
	_offerte.erase(tessera)
	_mostra_offerte(false)
	for figlio: Node in tessera.get_children():
		if figlio.has_meta("solo_offerta"):
			figlio.queue_free()
	var arrivo: Vector3 = _spazio_libero.global_position + Vector3(0.0, 0.01, 0.0)
	var animazione: Tween = create_tween()
	animazione.set_parallel(true)
	animazione.tween_property(tessera, "global_position", arrivo + Vector3(0.0, 2.0, 0.0), 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	animazione.tween_property(tessera, "rotation_degrees", Vector3.ZERO, 0.35)
	animazione.tween_property(tessera, "scale", Vector3.ONE, 0.35)
	animazione.chain().tween_property(tessera, "global_position", arrivo, 0.25).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	animazione.chain().tween_callback(_offerta_posata.bind(tessera))


func _offerta_posata(tessera: Tessera3D) -> void:
	_spazio_libero.visible = false
	tessera.reparent(_plancia[Lato.GIOCATORE])
	_edifici[Lato.GIOCATORE].append(tessera)
	_ricarica_edifici[Lato.GIOCATORE].append(0.0)
	_spazio_libero = null
	_scelta_in_corso = false
	_hud.mostra_messaggio("Il Mercato è costruito")


func _on_rinnova() -> void:
	_hud.mostra_messaggio("Offerte rinnovate")
	_mostra_offerte(false)
	var attesa: Tween = create_tween()
	attesa.tween_interval(0.45)
	attesa.tween_callback(_mostra_offerte.bind(true))


func _on_passa() -> void:
	_hud.mostra_messaggio("Opportunità passata")
	_mostra_offerte(false)


# --- Viste ---------------------------------------------------------------------

func _on_cambia_vista() -> void:
	vista = Vista.BATTAGLIA if vista == Vista.PARTITA else Vista.PARTITA
	_applica_vista(true)


## Partita: solo la tua plancia e le offerte. Battaglia: arriva la plancia del fantasma.
func _applica_vista(animata: bool) -> void:
	var battaglia: bool = vista == Vista.BATTAGLIA
	_hud.mostra_vista(int(vista))
	_hud.nascondi_suggerimento()
	var fantasma: Node3D = _plancia[Lato.FANTASMA]
	var arrivo_camera: Vector3 = CAMERA_BATTAGLIA if battaglia else CAMERA_PARTITA
	var arrivo_mira: Vector3 = MIRA_BATTAGLIA if battaglia else MIRA_PARTITA
	_nodo_riserva[Lato.GIOCATORE].visible = battaglia
	if battaglia:
		_avvia_battaglia()
	if not animata:
		fantasma.visible = battaglia
		fantasma.position = Vector3.ZERO
		_camera.look_at_from_position(arrivo_camera, arrivo_mira, Vector3.UP)
		for tessera: Tessera3D in _offerte:
			tessera.visible = not battaglia
		return
	_mostra_offerte(not battaglia)
	var partenza_camera: Vector3 = _camera.global_position
	var partenza_mira: Vector3 = MIRA_PARTITA if battaglia else MIRA_BATTAGLIA
	var animazione: Tween = create_tween()
	animazione.set_parallel(true)
	animazione.tween_method(_muovi_camera.bind(partenza_camera, arrivo_camera, partenza_mira, arrivo_mira), 0.0, 1.0, 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	if battaglia:
		fantasma.visible = true
		fantasma.position = Vector3(0.0, 0.0, -14.0)
		animazione.tween_property(fantasma, "position", Vector3.ZERO, 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	else:
		animazione.tween_property(fantasma, "position", Vector3(0.0, 0.0, -14.0), 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		animazione.chain().tween_callback(fantasma.hide)


func _muovi_camera(t: float, da: Vector3, a: Vector3, mira_da: Vector3, mira_a: Vector3) -> void:
	_camera.look_at_from_position(da.lerp(a, t), mira_da.lerp(mira_a, t), Vector3.UP)


# --- Battaglia dimostrativa (copione) -------------------------------------------

func _avvia_battaglia() -> void:
	_tempo_battaglia = 0.0
	_battaglia_finita = false
	_resistenza = [RESISTENZA_GIOCATORE, RESISTENZA_FANTASMA]
	for lato: int in [Lato.GIOCATORE, Lato.FANTASMA]:
		_aggiorna_resistenza(lato)
		for mana: int in _riserva[lato]:
			_riserva[lato][mana] = 0
			_aggiorna_riserva(lato, mana)
		for i: int in range(_ricarica_truppe[lato].size()):
			_ricarica_truppe[lato][i] = 0.0
			_lampo_truppe[lato][i] = 0.0
		for i: int in range(_ricarica_edifici[lato].size()):
			_ricarica_edifici[lato][i] = 0.0


func _on_pausa() -> void:
	_in_pausa = not _in_pausa
	_hud.imposta_pausa(_in_pausa)


func _process(delta: float) -> void:
	_tempo_candela += delta
	_candela.light_energy = 1.6 + sin(_tempo_candela * 7.0) * 0.15 + sin(_tempo_candela * 13.0) * 0.1
	if vista != Vista.BATTAGLIA or _in_pausa or _battaglia_finita:
		_aggiorna_stati_fermi()
		return
	var passo: float = delta * _velocita
	_tempo_battaglia += passo
	_hud.imposta_tempo(_tempo_battaglia)
	for lato: int in [Lato.GIOCATORE, Lato.FANTASMA]:
		_avanza_edifici(lato, passo)
		_avanza_truppe(lato, passo)


func _avanza_edifici(lato: int, passo: float) -> void:
	for i: int in range(_edifici[lato].size()):
		var tessera: Tessera3D = _edifici[lato][i]
		_ricarica_edifici[lato][i] += passo
		if _ricarica_edifici[lato][i] >= tessera.pezzo.ritmo_s:
			_ricarica_edifici[lato][i] = 0.0
			_lancia_mana(lato, tessera)


## Le truppe del copione: chi "si attiva" lo fa a ogni fine ricarica; chi "aspetta" resta in attesa.
## Si scorrono da destra verso sinistra solo per mostrare l'ordine; non si calcola nessuna regola.
func _avanza_truppe(lato: int, passo: float) -> void:
	var verso: float = -1.0 if lato == Lato.GIOCATORE else 1.0
	for i: int in range(_truppe[lato].size() - 1, -1, -1):
		var tessera: Tessera3D = _truppe[lato][i]
		var pezzo: DatiEsempioPlancia.Pezzo = tessera.pezzo
		_lampo_truppe[lato][i] = maxf(0.0, _lampo_truppe[lato][i] - passo)
		_ricarica_truppe[lato][i] = minf(1.0, _ricarica_truppe[lato][i] + passo / pezzo.ritmo_s)
		tessera.imposta_ricarica(_ricarica_truppe[lato][i])
		if _ricarica_truppe[lato][i] < 1.0:
			if _lampo_truppe[lato][i] <= 0.0:
				tessera.imposta_stato("", StileVisivo.NOTTE)
			continue
		if pezzo.copione == DatiEsempioPlancia.Copione.ASPETTA_MANA:
			var nome_mana: String = StileVisivo.NOMI_MANA[pezzo.mana]
			var disponibile: int = int(_riserva[lato].get(pezzo.mana, 0)) + int(_riserva[lato].get(StileVisivo.Mana.ENERGETICO, 0))
			tessera.imposta_stato("In attesa: servono %d %s, %s %d" % [pezzo.mana_numero, nome_mana, "ne hai" if lato == Lato.GIOCATORE else "ne ha", mini(disponibile, pezzo.mana_numero - 1)], StileVisivo.PERICOLO)
			continue
		_ricarica_truppe[lato][i] = 0.0
		_lampo_truppe[lato][i] = 0.6
		tessera.attiva(verso)
		var spesa: String = "senza mana" if pezzo.mana == StileVisivo.Mana.NESSUNO else "−%d %s" % [pezzo.mana_numero, StileVisivo.NOMI_MANA[pezzo.mana]]
		tessera.imposta_stato("Si attiva · %s" % spesa, StileVisivo.ORO_LUCE)
		if pezzo.mana != StileVisivo.Mana.NESSUNO:
			_togli_mana(lato, pezzo.mana, pezzo.mana_numero)
		_infliggi(1 - lato, pezzo.danno)


## Fuori dalla battaglia le truppe non mostrano stati né ricariche.
func _aggiorna_stati_fermi() -> void:
	if vista == Vista.BATTAGLIA:
		return
	for lato: int in [Lato.GIOCATORE, Lato.FANTASMA]:
		for tessera: Tessera3D in _truppe[lato]:
			tessera.imposta_ricarica(1.0)
			tessera.imposta_stato("", StileVisivo.NOTTE)


## Una gemma vola dall'edificio alla riserva di mana del suo lato.
func _lancia_mana(lato: int, edificio: Tessera3D) -> void:
	var gemma: MeshInstance3D = MeshInstance3D.new()
	var forma: SphereMesh = SphereMesh.new()
	forma.radius = 0.16
	forma.height = 0.32
	gemma.mesh = forma
	gemma.material_override = StileVisivo.materiale_gemma(edificio.pezzo.mana)
	add_child(gemma)
	var partenza: Vector3 = edificio.punto_gemma()
	var destinazione: Node3D = _posizioni_riserva[lato][edificio.pezzo.mana]
	var arrivo: Vector3 = destinazione.global_position + Vector3(0.0, 0.2, 0.0)
	gemma.global_position = partenza
	var animazione: Tween = create_tween()
	animazione.tween_method(_muovi_gemma.bind(gemma, partenza, arrivo), 0.0, 1.0, 0.65 / _velocita).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	animazione.tween_callback(_gemma_arrivata.bind(gemma, lato, edificio.pezzo.mana, edificio.pezzo.mana_numero))


func _muovi_gemma(t: float, gemma: MeshInstance3D, da: Vector3, a: Vector3) -> void:
	gemma.global_position = da.lerp(a, t) + Vector3(0.0, sin(t * PI) * 2.2, 0.0)


func _gemma_arrivata(gemma: MeshInstance3D, lato: int, mana: int, quanto: int) -> void:
	gemma.queue_free()
	if vista != Vista.BATTAGLIA:
		return
	_riserva[lato][mana] = int(_riserva[lato].get(mana, 0)) + quanto
	_aggiorna_riserva(lato, mana)


## Contabilità del copione: si toglie prima il colore della truppa, poi l'energetico.
func _togli_mana(lato: int, mana: int, quanto: int) -> void:
	var dal_colore: int = mini(quanto, int(_riserva[lato].get(mana, 0)))
	_riserva[lato][mana] = int(_riserva[lato].get(mana, 0)) - dal_colore
	_aggiorna_riserva(lato, mana)
	var resto: int = quanto - dal_colore
	if resto > 0:
		var energetico: int = StileVisivo.Mana.ENERGETICO
		_riserva[lato][energetico] = maxi(0, int(_riserva[lato].get(energetico, 0)) - resto)
		_aggiorna_riserva(lato, energetico)


func _aggiorna_riserva(lato: int, mana: int) -> void:
	var scritta: Label3D = _scritte_riserva[lato][mana]
	scritta.text = str(_riserva[lato][mana])


func _infliggi(lato: int, danno: int) -> void:
	_resistenza[lato] = maxi(0, _resistenza[lato] - danno)
	_aggiorna_resistenza(lato)
	var colpo: Label3D = StileVisivo.scritta("−%d" % danno, StileVisivo.FONT_TITOLI, 140, Color.WHITE, 0.0, 22)
	colpo.outline_modulate = StileVisivo.PERICOLO.darkened(0.35)
	colpo.no_depth_test = true
	add_child(colpo)
	var segno: float = 1.0 if lato == Lato.GIOCATORE else -1.0
	var base: Vector3 = Vector3(X_MEDAGLIONE + 1.3, 0.6, (Z_TRUPPE + Z_EDIFICI) * 0.5 * segno - 1.3)
	colpo.global_position = base
	var animazione: Tween = create_tween()
	animazione.set_parallel(true)
	animazione.tween_property(colpo, "global_position", base + Vector3(0.4, 0.9, -0.3), 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	animazione.tween_property(colpo, "modulate:a", 0.0, 0.8).set_delay(0.3)
	animazione.chain().tween_callback(colpo.queue_free)
	if _resistenza[lato] == 0:
		_battaglia_finita = true
		_hud.mostra_messaggio("Vittoria!" if lato == Lato.FANTASMA else "Sconfitta")
		var nuova: Tween = create_tween()
		nuova.tween_interval(2.5)
		nuova.tween_callback(_avvia_battaglia)


func _aggiorna_resistenza(lato: int) -> void:
	var massimo: int = RESISTENZA_GIOCATORE if lato == Lato.GIOCATORE else RESISTENZA_FANTASMA
	_scritte_resistenza[lato].text = str(_resistenza[lato])
	var frazione: float = float(_resistenza[lato]) / float(massimo)
	var barra: MeshInstance3D = _barre_resistenza[lato]
	barra.scale.x = maxf(frazione, 0.001)
	var z: float = barra.position.z
	barra.position = Vector3(X_MEDAGLIONE - 0.95 * (1.0 - frazione), barra.position.y, z)


# --- Mouse ---------------------------------------------------------------------

func _physics_process(_delta: float) -> void:
	var mouse: Vector2 = get_viewport().get_mouse_position()
	var origine: Vector3 = _camera.project_ray_origin(mouse)
	var fine: Vector3 = origine + _camera.project_ray_normal(mouse) * 100.0
	var richiesta: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origine, fine)
	var colpito: Dictionary = get_world_3d().direct_space_state.intersect_ray(richiesta)
	var tessera: Tessera3D = null
	if not colpito.is_empty():
		var oggetto: Object = colpito["collider"]
		if oggetto != null and oggetto.has_meta("tessera"):
			tessera = oggetto.get_meta("tessera") as Tessera3D
	if tessera != null and not tessera.is_visible_in_tree():
		tessera = null
	if tessera != _evidenziata:
		if _evidenziata != null and is_instance_valid(_evidenziata):
			_evidenziata.evidenzia(false)
		_evidenziata = tessera
		if tessera != null:
			tessera.evidenzia(true)
	if tessera != null:
		var titolo: String = tessera.pezzo.nome
		if tessera.pezzo.tipo_offerta != "" and tessera.pezzo.tipo_offerta != tessera.pezzo.nome:
			titolo = "%s · %s" % [tessera.pezzo.tipo_offerta, tessera.pezzo.nome]
		_hud.mostra_suggerimento(titolo, tessera.pezzo.dettagli, mouse)
	else:
		_hud.nascondi_suggerimento()


func _unhandled_input(evento: InputEvent) -> void:
	var clic: InputEventMouseButton = evento as InputEventMouseButton
	if clic == null or not clic.pressed or clic.button_index != MOUSE_BUTTON_LEFT:
		return
	if _evidenziata != null and _evidenziata in _offerte and vista == Vista.PARTITA:
		_scegli_offerta(_evidenziata)
