extends Node3D
## La partita sulla plancia 3D (GDD §14.2): tavolo, plancia della nazione, offerte,
## incontri, ricompense, scontri ed esito dell'anno.
## Solo presentazione: lo stato e le regole sono tutti in RunState e BattleSim.
## La scena legge lo stato, chiama le azioni di RunState e rigioca gli scontri
## passo per passo dalla simulazione (il tempo reale decide solo il ritmo di visione).

enum Lato { GIOCATORE, AVVERSARIO }
enum Modo { NORMALE, SOSTITUZIONE, SCONTRO }
enum TipoScelta { NESSUNA, OFFERTA, INCONTRO, RICOMPENSA, FANTASMA, VIA }

const PASSO_TRUPPE: float = 1.75
const PASSO_EDIFICI: float = 2.1
const MISURA_TRUPPA: Vector2 = Vector2(1.58, 1.95)
const MISURA_EDIFICIO: Vector2 = Vector2(1.9, 1.6)
const MISURA_AZIONE: Vector2 = Vector2(1.7, 1.95)
const SCALA_SCELTA: float = 1.45
const Z_TRUPPE: float = 1.75
const Z_EDIFICI: float = 4.4
const X_SPAZI: float = 0.9
const X_MEDAGLIONE: float = -11.2
const SPAZI_TRUPPE: int = 12
const SPAZI_EDIFICI: int = 10
const COLORI_RISERVA: Array[StringName] = [&"rosso", &"verde", &"blu", &"energetico"]
## Oltre questo numero di gemme in volo non se ne lanciano altre (solo effetto visivo).
const MASSIMO_GEMME_IN_VOLO: int = 24

const CAMERA_PARTITA: Vector3 = Vector3(-0.4, 27.0, 14.6)
const MIRA_PARTITA: Vector3 = Vector3(-0.4, 0.0, 0.9)
const CAMERA_SCONTRO: Vector3 = Vector3(-0.4, 28.4, 14.5)
const MIRA_SCONTRO: Vector3 = Vector3(-0.4, 0.0, 0.0)

var run: RunState

var _camera: Camera3D
var _luce_atmosfera: OmniLight3D
var _hud: HudPlancia
var _radici: Array[Node3D] = [null, null]
var _pezzi: Array[Node3D] = [null, null]
var _truppe: Array[Array] = [[], []]
var _edifici: Array[Array] = [[], []]
var _spazio_libero_edificio: Node3D
var _spazio_libero_truppa: Node3D
var _materiali_bordo: Array[StandardMaterial3D] = []
var _medaglioni: Array[Node3D] = [null, null]
var _scritte_resistenza: Array[Label3D] = [null, null]
var _barre_resistenza: Array[MeshInstance3D] = [null, null]
## Scudo e Corruzione accanto allo stemma (GDD §7.6), visibili solo se non sono zero.
var _segnalini_scudo: Array[Node3D] = [null, null]
var _scritte_scudo: Array[Label3D] = [null, null]
var _segnalini_corruzione: Array[Node3D] = [null, null]
var _scritte_corruzione: Array[Label3D] = [null, null]
var _nomi_lato: Array[Label3D] = [null, null]
var _riserve: Array[Node3D] = [null, null]
var _scritte_riserva: Array[Dictionary] = [{}, {}]
var _gemme_riserva: Array[Dictionary] = [{}, {}]

var _scelte: Array[Tessera3D] = []
var _contenitore_scelte: Node3D
var _tipo_scelta: TipoScelta = TipoScelta.NESSUNA
var _modo: Modo = Modo.NORMALE
var _sostituisce_truppa: bool = false
var _azione_sostituzione: Callable
var _evidenziata: Tessera3D
var _tempo: float = 0.0

var _sim: BattleSim
var _setups: Array[BattleSideSetup] = []
var _accumulo_ms: float = 0.0
var _velocita: float = 1.0
var _in_pausa: bool = false
var _prima: Dictionary = {}
var _esito_programmato: bool = false
var _lampi: Array[Array] = [[], []]
var _gemme_in_volo: int = 0
## Conta le scritte uscite da ogni stemma, per non sovrapporle.
var _scritte_uscite: Array[int] = [0, 0]


func _ready() -> void:
	_crea_ambiente()
	_crea_tavolo()
	for lato: int in [Lato.GIOCATORE, Lato.AVVERSARIO]:
		_crea_lato(lato)
	_contenitore_scelte = Node3D.new()
	add_child(_contenitore_scelte)
	_crea_atmosfera()
	var livello: CanvasLayer = CanvasLayer.new()
	add_child(livello)
	_hud = HudPlancia.new()
	livello.add_child(_hud)
	_collega_hud()
	_radici[Lato.AVVERSARIO].visible = false
	_camera.look_at_from_position(CAMERA_PARTITA, MIRA_PARTITA, Vector3.UP)
	_nuova_run()


func _collega_hud() -> void:
	_hud.azione_principale.connect(_on_azione_principale)
	_hud.rinnova.connect(func() -> void: _esegui(run.reroll_offers(), "Offerte rinnovate"))
	_hud.passa.connect(func() -> void: _esegui(run.pass_opportunity(), "Opportunità passata"))
	_hud.nessuna_ricompensa.connect(func() -> void: _esegui(run.skip_reward()))
	_hud.avanza_era.connect(_on_avanza_era)
	_hud.vendi_risorsa.connect(func(tipo: int) -> void: _esegui(run.sell_resource(tipo, run.run_rules.market_units_per_gold)))
	_hud.ricomincia.connect(_nuova_run)
	_hud.menu.connect(func() -> void: GameSession.go(GameSession.MENU_SCENE))
	_hud.pausa.connect(_on_pausa)
	_hud.velocita.connect(func(fattore: float) -> void: _velocita = fattore)
	_hud.annulla.connect(_annulla)


## Nuova run con la nazione scelta nel menu, o con una nazione di prova
## se la scena viene avviata da sola in Godot (come fa l'interfaccia provvisoria).
func _nuova_run() -> void:
	var catalogo: CatalogDef = GameSession.catalog()
	var regole_run: RunRules = GameSession.run_rules()
	var nazione: NationTemplate = GameSession.selected_nation
	if nazione == null or nazione.problem(catalogo, regole_run) != "":
		nazione = _nazione_di_prova(catalogo, regole_run)
	run = RunState.new(catalogo, regole_run, GameSession.battle_rules(), GameSession.resistance_rules(), randi())
	if run.phase == RunState.Phase.CREAZIONE_NAZIONE:
		run.found_nation(nazione.nation_name, nazione.resolve(catalogo))
	_modo = Modo.NORMALE
	_aggiorna_tutto()


func _nazione_di_prova(catalogo: CatalogDef, regole_run: RunRules) -> NationTemplate:
	var scelte: Array[IdentityDef] = []
	for dimensione: IdentityDef.Dimension in IdentityDef.CREATION_DIMENSIONS:
		var opzioni: Array[IdentityDef] = IdentityRules.options(catalogo, dimensione)
		var quante: int = IdentityRules.starting_perk_count(catalogo, regole_run) if dimensione == IdentityDef.Dimension.PERK else mini(1, opzioni.size())
		for i: int in range(quante):
			scelte.append(opzioni[i])
	return NationTemplate.from_choices("prova", "Nazione di prova", scelte)


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

	_luce_atmosfera = OmniLight3D.new()
	_luce_atmosfera.light_color = Color("8a5cff")
	_luce_atmosfera.light_energy = 1.6
	_luce_atmosfera.omni_range = 22.0
	_luce_atmosfera.position = Vector3(-15.0, 5.0, -8.0)
	add_child(_luce_atmosfera)

	_camera = Camera3D.new()
	_camera.fov = 30.0
	add_child(_camera)


func _crea_tavolo() -> void:
	var terreno: MeshInstance3D = MeshInstance3D.new()
	var forma: BoxMesh = BoxMesh.new()
	forma.size = Vector3(70.0, 0.5, 50.0)
	terreno.mesh = forma
	terreno.material_override = StileVisivo.materiale_pietra(StileVisivo.PIETRA_SCURA.darkened(0.2), 3.0)
	terreno.position.y = -0.45
	add_child(terreno)


## Pulviscolo luminoso che fluttua sopra il tavolo (solo atmosfera).
func _crea_atmosfera() -> void:
	var polvere: CPUParticles3D = CPUParticles3D.new()
	var granello: SphereMesh = SphereMesh.new()
	granello.radius = 0.018
	granello.height = 0.036
	var materiale: StandardMaterial3D = StileVisivo.materiale_velo(Color(0.62, 0.76, 1.0, 0.35))
	materiale.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	granello.material = materiale
	polvere.mesh = granello
	polvere.amount = 70
	polvere.lifetime = 9.0
	polvere.preprocess = 9.0
	polvere.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	polvere.emission_box_extents = Vector3(18.0, 2.5, 11.0)
	polvere.direction = Vector3.UP
	polvere.spread = 180.0
	polvere.initial_velocity_min = 0.05
	polvere.initial_velocity_max = 0.25
	polvere.gravity = Vector3(0.0, 0.03, 0.0)
	polvere.scale_amount_min = 0.5
	polvere.scale_amount_max = 1.4
	polvere.position = Vector3(-0.4, 2.0, 0.0)
	add_child(polvere)


# --- Lati del tavolo -----------------------------------------------------------

func _segno(lato: int) -> float:
	return 1.0 if lato == Lato.GIOCATORE else -1.0


func _colore_lato(lato: int) -> Color:
	return StileVisivo.COLORE_GIOCATORE if lato == Lato.GIOCATORE else StileVisivo.COLORE_FANTASMA


## Parti fisse di un lato: lastra con bordo luminoso, stemma con la Resistenza, riserva di mana.
## Il lato avversario è specchiato: truppe verso il centro, edifici dietro.
func _crea_lato(lato: int) -> void:
	var radice: Node3D = Node3D.new()
	add_child(radice)
	_radici[lato] = radice
	var z_centro: float = (Z_TRUPPE + Z_EDIFICI) * 0.5 * _segno(lato)
	_crea_lastra(radice, Vector3(-0.43, 0.0, z_centro), Vector2(24.35, 5.0), _colore_lato(lato))
	_crea_medaglione(radice, lato, z_centro)
	_crea_riserva(radice, lato, z_centro)
	_pezzi[lato] = Node3D.new()
	radice.add_child(_pezzi[lato])
	if lato == Lato.GIOCATORE:
		var nota: Label3D = StileVisivo.scritta("LE TRUPPE AGISCONO DA DESTRA VERSO SINISTRA  ←", StileVisivo.FONT_TESTO_FORTE, 50, StileVisivo.TESTO_TENUE)
		nota.position = Vector3(7.0, 0.02, 0.0)
		radice.add_child(nota)


func _crea_lastra(radice: Node3D, centro: Vector3, misura: Vector2, colore: Color) -> void:
	var lastra: MeshInstance3D = MeshInstance3D.new()
	var forma: BoxMesh = BoxMesh.new()
	forma.size = Vector3(misura.x, 0.4, misura.y)
	lastra.mesh = forma
	lastra.material_override = StileVisivo.materiale_pietra(StileVisivo.PIETRA, 2.5)
	lastra.position = centro + Vector3(0.0, -0.18, 0.0)
	radice.add_child(lastra)
	var luce: StandardMaterial3D = StileVisivo.materiale_luminoso(colore, 1.3)
	_materiali_bordo.append(luce)
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


func _crea_medaglione(radice: Node3D, lato: int, z_centro: float) -> void:
	var colore: Color = _colore_lato(lato)
	var medaglione: Node3D = Node3D.new()
	medaglione.position = Vector3(X_MEDAGLIONE, 0.0, z_centro - 1.15)
	radice.add_child(medaglione)
	_medaglioni[lato] = medaglione
	var bordo: MeshInstance3D = MeshInstance3D.new()
	var forma_bordo: CylinderMesh = CylinderMesh.new()
	forma_bordo.top_radius = 0.95
	forma_bordo.bottom_radius = 1.0
	forma_bordo.height = 0.16
	bordo.mesh = forma_bordo
	bordo.material_override = StileVisivo.materiale_metallo(StileVisivo.ORO)
	bordo.position.y = 0.08
	medaglione.add_child(bordo)
	var disco: MeshInstance3D = MeshInstance3D.new()
	var forma_disco: CylinderMesh = CylinderMesh.new()
	forma_disco.top_radius = 0.8
	forma_disco.bottom_radius = 0.8
	forma_disco.height = 0.18
	disco.mesh = forma_disco
	disco.material_override = StileVisivo.materiale(colore.darkened(0.55), 0.5)
	disco.position.y = 0.09
	medaglione.add_child(disco)
	var numero: Label3D = StileVisivo.scritta("0", StileVisivo.FONT_TITOLI, 140, Color.WHITE, 0.0, 18)
	numero.position.y = 0.2
	medaglione.add_child(numero)
	_scritte_resistenza[lato] = numero
	var nome: Label3D = StileVisivo.scritta("", StileVisivo.FONT_TITOLI, 44, StileVisivo.TESTO, 0.0, 8)
	nome.position = Vector3(X_MEDAGLIONE, 0.04, z_centro)
	radice.add_child(nome)
	_nomi_lato[lato] = nome
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
	var scudo: Array = _crea_segnalino(medaglione, Vector3(1.0, 0.0, -0.55), Color("2f6fd0"))
	_segnalini_scudo[lato] = scudo[0]
	_scritte_scudo[lato] = scudo[1]
	var corruzione: Array = _crea_segnalino(medaglione, Vector3(1.0, 0.0, 0.55), Color("8b3fc9"))
	_segnalini_corruzione[lato] = corruzione[0]
	_scritte_corruzione[lato] = corruzione[1]


## Piccolo disco con un numero accanto allo stemma. Restituisce [nodo, scritta].
func _crea_segnalino(genitore: Node3D, posizione: Vector3, colore: Color) -> Array:
	var nodo: Node3D = Node3D.new()
	nodo.position = posizione
	genitore.add_child(nodo)
	var disco: MeshInstance3D = MeshInstance3D.new()
	var forma: CylinderMesh = CylinderMesh.new()
	forma.top_radius = 0.36
	forma.bottom_radius = 0.38
	forma.height = 0.1
	forma.radial_segments = 6
	disco.mesh = forma
	disco.material_override = StileVisivo.materiale_luminoso(colore, 0.5)
	disco.position.y = 0.05
	nodo.add_child(disco)
	var scritta: Label3D = StileVisivo.scritta("0", StileVisivo.FONT_TITOLI, 64, Color.WHITE, 0.0, 10)
	scritta.position.y = 0.12
	nodo.add_child(scritta)
	nodo.visible = false
	return [nodo, scritta]


func _crea_riserva(radice: Node3D, lato: int, z_centro: float) -> void:
	var nodo: Node3D = Node3D.new()
	nodo.position = Vector3(X_MEDAGLIONE, 0.0, z_centro + 1.05)
	radice.add_child(nodo)
	_riserve[lato] = nodo
	for i: int in range(COLORI_RISERVA.size()):
		var mana: StringName = COLORI_RISERVA[i]
		var x: float = (i - 1.5) * 0.55
		var gemma: MeshInstance3D = MeshInstance3D.new()
		var forma: CylinderMesh = CylinderMesh.new()
		forma.top_radius = 0.19
		forma.bottom_radius = 0.23
		forma.height = 0.12
		forma.radial_segments = 6
		gemma.mesh = forma
		gemma.material_override = StileVisivo.materiale_gemma(StileVisivo.mana_da_nome(mana))
		gemma.position = Vector3(x, 0.08, 0.0)
		nodo.add_child(gemma)
		var conteggio: Label3D = StileVisivo.scritta("0", StileVisivo.FONT_TITOLI, 64, Color.WHITE, 0.0, 10)
		conteggio.position = Vector3(x, 0.04, 0.5)
		nodo.add_child(conteggio)
		_scritte_riserva[lato][mana] = conteggio
		_gemme_riserva[lato][mana] = gemma
	nodo.visible = false


func _aggiorna_medaglione(lato: int, resistenza: int, massimo: int) -> void:
	_scritte_resistenza[lato].text = str(maxi(resistenza, 0))
	var frazione: float = clampf(float(resistenza) / float(maxi(massimo, 1)), 0.0, 1.0)
	var barra: MeshInstance3D = _barre_resistenza[lato]
	barra.scale.x = maxf(frazione, 0.001)
	barra.position.x = X_MEDAGLIONE - 0.95 * (1.0 - frazione)


# --- Carte sulla plancia ---------------------------------------------------------

func _crea_tessera(genitore: Node3D, scheda: SchedaCarta, misura: Vector2, posizione: Vector3, indice: int, nitidezza: float = 1.0) -> Tessera3D:
	var tessera: Tessera3D = Tessera3D.new()
	genitore.add_child(tessera)
	tessera.costruisci(scheda, misura.x, misura.y, nitidezza)
	tessera.position = posizione
	tessera.indice = indice
	return tessera


## Spazio vuoto: velato del colore del lato se è disponibile, scuro se va ancora conquistato.
func _crea_spazio(genitore: Node3D, posizione: Vector3, misura: Vector2, disponibile: bool, colore_lato: Color) -> Node3D:
	var spazio: MeshInstance3D = MeshInstance3D.new()
	var forma: PlaneMesh = PlaneMesh.new()
	forma.size = misura
	spazio.mesh = forma
	var colore: Color = Color(colore_lato, 0.16) if disponibile else Color(0.0, 0.0, 0.0, 0.28)
	spazio.material_override = StileVisivo.materiale_velo(colore)
	spazio.position = posizione + Vector3(0.0, 0.012, 0.0)
	genitore.add_child(spazio)
	if disponibile:
		var scritta: Label3D = StileVisivo.scritta("LIBERO", StileVisivo.FONT_TITOLI, 46, Color(colore_lato, 0.85), 0.0, 6)
		scritta.position = Vector3(0.0, 0.004, 0.0)
		spazio.add_child(scritta)
	return spazio


func _posizione_truppa(lato: int, i: int) -> Vector3:
	return Vector3(X_SPAZI + (i - (SPAZI_TRUPPE - 1) * 0.5) * PASSO_TRUPPE, 0.02, Z_TRUPPE * _segno(lato))


func _posizione_edificio(lato: int, i: int) -> Vector3:
	return Vector3(X_SPAZI + (i - (SPAZI_EDIFICI - 1) * 0.5) * PASSO_EDIFICI, 0.02, Z_EDIFICI * _segno(lato))


## Ricostruisce le carte di un lato. Gli spazi vuoti si mostrano solo per il giocatore.
func _costruisci_lato(lato: int, edifici: Array[SchedaCarta], truppe: Array[SchedaCarta], capacita_edifici: int, capacita_truppe: int) -> void:
	for figlio: Node in _pezzi[lato].get_children():
		figlio.queue_free()
	_truppe[lato] = []
	_edifici[lato] = []
	_lampi[lato] = []
	if lato == Lato.GIOCATORE:
		_spazio_libero_edificio = null
		_spazio_libero_truppa = null
	var colore: Color = _colore_lato(lato)
	for i: int in range(SPAZI_TRUPPE):
		if i < truppe.size():
			_truppe[lato].append(_crea_tessera(_pezzi[lato], truppe[i], MISURA_TRUPPA, _posizione_truppa(lato, i), i))
			_lampi[lato].append(0.0)
		elif lato == Lato.GIOCATORE:
			var spazio: Node3D = _crea_spazio(_pezzi[lato], _posizione_truppa(lato, i), MISURA_TRUPPA, i < capacita_truppe, colore)
			if i < capacita_truppe and _spazio_libero_truppa == null:
				_spazio_libero_truppa = spazio
	for i: int in range(SPAZI_EDIFICI):
		if i < edifici.size():
			_edifici[lato].append(_crea_tessera(_pezzi[lato], edifici[i], MISURA_EDIFICIO, _posizione_edificio(lato, i), i))
		elif lato == Lato.GIOCATORE:
			var spazio: Node3D = _crea_spazio(_pezzi[lato], _posizione_edificio(lato, i), MISURA_EDIFICIO, i < capacita_edifici, colore)
			if i < capacita_edifici and _spazio_libero_edificio == null:
				_spazio_libero_edificio = spazio


func _costruisci_plancia_giocatore() -> void:
	var edifici: Array[SchedaCarta] = []
	for pezzo: BoardPiece in run.board.buildings:
		edifici.append(SchedaCarta.da_pezzo(run, pezzo))
	var truppe: Array[SchedaCarta] = []
	for pezzo: BoardPiece in run.board.troops:
		truppe.append(SchedaCarta.da_pezzo(run, pezzo))
	_costruisci_lato(Lato.GIOCATORE, edifici, truppe, run.board.building_capacity(), run.board.troop_capacity())


# --- Scelte sul tavolo: offerte, incontri, ricompense, fantasma ----------------------

func _costruisci_scelte() -> void:
	for figlio: Node in _contenitore_scelte.get_children():
		figlio.queue_free()
	_scelte = []
	var schede: Array[SchedaCarta] = []
	_tipo_scelta = TipoScelta.NESSUNA
	var fase: int = run.phase
	if not run.way_choices.is_empty():
		_tipo_scelta = TipoScelta.VIA
		for via: IdentityDef in run.way_choices:
			schede.append(SchedaCarta.da_via(via))
		fase = -1
	match fase:
		RunState.Phase.PRODUZIONE, RunState.Phase.PREPARAZIONE:
			_tipo_scelta = TipoScelta.OFFERTA
			for offerta: Offer in run.offers:
				schede.append(SchedaCarta.da_offerta(run, offerta))
		RunState.Phase.SCELTA_INCONTRO:
			_tipo_scelta = TipoScelta.INCONTRO
			for incontro: EncounterDef in run.encounter_choices:
				schede.append(SchedaCarta.da_incontro(incontro))
		RunState.Phase.RICOMPENSA_INCONTRO:
			_tipo_scelta = TipoScelta.RICOMPENSA
			for ricompensa: RewardDef in run.reward_choices():
				schede.append(SchedaCarta.da_ricompensa(ricompensa))
		RunState.Phase.SCONTRO_FANTASMA:
			if run.current_ghost != null:
				_tipo_scelta = TipoScelta.FANTASMA
				schede.append(SchedaCarta.da_fantasma(run, run.current_ghost))
	for i: int in range(schede.size()):
		var scheda: SchedaCarta = schede[i]
		var misura: Vector2 = MISURA_AZIONE
		if scheda.genere == SchedaCarta.Genere.EDIFICIO:
			misura = MISURA_EDIFICIO
		elif scheda.genere == SchedaCarta.Genere.TRUPPA:
			misura = MISURA_TRUPPA
		var arrivo: Vector3 = Vector3(-0.4 + (i - (schede.size() - 1) * 0.5) * 4.4, 1.8, -2.4)
		var tessera: Tessera3D = _crea_tessera(_contenitore_scelte, scheda, misura, arrivo + Vector3(0.0, 6.0, -4.0), i, 1.6)
		tessera.rotation_degrees = Vector3(28.0, 0.0, 0.0)
		tessera.scale = Vector3.ONE * SCALA_SCELTA
		if scheda.sopratitolo != "":
			var sopra: Label3D = StileVisivo.scritta(scheda.sopratitolo.to_upper(), StileVisivo.FONT_TITOLI, 42, StileVisivo.TESTO, 0.0, 10)
			sopra.position = Vector3(0.0, 0.02, -misura.y * 0.5 - 0.24)
			tessera.add_child(sopra)
		if scheda.costo != "":
			var costo: Label3D = StileVisivo.scritta(scheda.costo, StileVisivo.FONT_TITOLI, 54, StileVisivo.ORO_LUCE if scheda.disponibile else StileVisivo.PERICOLO, 0.0, 12)
			costo.position = Vector3(0.0, 0.02, misura.y * 0.5 + 0.27)
			tessera.add_child(costo)
		_scelte.append(tessera)
		var entrata: Tween = create_tween()
		entrata.tween_interval(0.07 * i)
		entrata.tween_property(tessera, "position", arrivo, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _togli_scelte() -> void:
	for tessera: Tessera3D in _scelte:
		var uscita: Tween = create_tween()
		uscita.tween_property(tessera, "position", tessera.position + Vector3(0.0, 6.0, -4.0), 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		uscita.tween_callback(tessera.queue_free)
	_scelte = []
	_tipo_scelta = TipoScelta.NESSUNA


# --- Aggiornamento ---------------------------------------------------------------

func _aggiorna_tutto() -> void:
	_annulla()
	_costruisci_plancia_giocatore()
	_costruisci_scelte()
	_nomi_lato[Lato.GIOCATORE].text = run.nation_name.to_upper()
	_aggiorna_medaglione(Lato.GIOCATORE, run.player_resistance(), run.player_resistance())
	_hud.aggiorna_partita(run)


## Dopo un'azione di RunState: messaggio di errore se non è riuscita, poi si ridisegna tutto.
func _esegui(riuscita: bool, messaggio: String = "") -> void:
	if not riuscita:
		_hud.mostra_messaggio(run.last_error, true)
	elif messaggio != "":
		_hud.mostra_messaggio(messaggio)
	_aggiorna_tutto()


func _annulla() -> void:
	if _modo == Modo.SOSTITUZIONE:
		_modo = Modo.NORMALE
	_hud.nascondi_sostituzione()
	_hud.nascondi_pezzo()
	for tessera: Tessera3D in _truppe[Lato.GIOCATORE] + _edifici[Lato.GIOCATORE]:
		if is_instance_valid(tessera):
			tessera.imposta_alone(Color(0.0, 0.0, 0.0, 0.0))


func _on_avanza_era() -> void:
	var prossima: String = run.era_name(run.era + 1)
	_esegui(run.advance_era(), "Inizia l'era: %s" % prossima)


func _on_azione_principale() -> void:
	if _modo == Modo.SCONTRO:
		_salta_scontro()
		return
	match run.phase:
		RunState.Phase.SCONTRO_FANTASMA:
			_affronta_fantasma()
		RunState.Phase.FINE_RUN:
			_nuova_run()


# --- Clic ----------------------------------------------------------------------

func _unhandled_input(evento: InputEvent) -> void:
	var clic: InputEventMouseButton = evento as InputEventMouseButton
	if clic == null or not clic.pressed or _modo == Modo.SCONTRO or _hud.esito_visibile():
		return
	if clic.button_index == MOUSE_BUTTON_RIGHT:
		_annulla()
		return
	if clic.button_index != MOUSE_BUTTON_LEFT:
		return
	if _evidenziata == null or not is_instance_valid(_evidenziata):
		_annulla()
		return
	if _evidenziata in _scelte:
		_clic_scelta(_evidenziata)
	elif _evidenziata in _truppe[Lato.GIOCATORE]:
		_clic_pezzo(_evidenziata, true)
	elif _evidenziata in _edifici[Lato.GIOCATORE]:
		_clic_pezzo(_evidenziata, false)


func _clic_scelta(tessera: Tessera3D) -> void:
	var i: int = tessera.indice
	match _tipo_scelta:
		TipoScelta.OFFERTA:
			var offerta: Offer = run.offers[i]
			var voci: Array[String] = run.offer_choices(offerta)
			if not voci.is_empty():
				_hud.mostra_scelte(offerta.describe(), offerta.opportunity.description, voci, func(voce: int) -> void: _esegui(run.buy_offer(i, voce)))
			elif run.offer_needs_replacement(offerta):
				var truppa: bool = offerta.kind == OpportunityDef.Kind.RECLUTA_TRUPPA
				var testo: String = "Plancia piena: clicca %s da sostituire con %s." % ["la truppa" if truppa else "l'edificio", tessera.scheda.titolo]
				_inizia_sostituzione(truppa, testo, func(sostituita: int) -> bool: return run.buy_offer(i, sostituita))
			else:
				_vola_e_esegui(tessera, func() -> bool: return run.buy_offer(i))
		TipoScelta.INCONTRO:
			var nome: String = run.encounter_choices[i].display_name
			var prima: Dictionary = _istantanea()
			if run.choose_encounter(i):
				_avvia_scontro("Incontro del mondo: %s" % nome, prima)
			else:
				_esegui(false)
		TipoScelta.RICOMPENSA:
			var ricompensa: RewardDef = run.reward_choices()[i]
			if run.reward_needs_replacement(ricompensa):
				var truppa: bool = ricompensa.kind == RewardDef.Kind.TRUPPA
				var testo: String = "Plancia piena: clicca %s da sostituire." % ("la truppa" if truppa else "l'edificio")
				_inizia_sostituzione(truppa, testo, func(sostituita: int) -> bool: return run.take_reward(i, sostituita))
			else:
				_vola_e_esegui(tessera, func() -> bool: return run.take_reward(i))
		TipoScelta.FANTASMA:
			_affronta_fantasma()
		TipoScelta.VIA:
			var nome_via: String = run.way_choices[i].display_name
			_esegui(run.choose_way(i), "Via scelta: %s" % nome_via)


## Edificio o truppa presi: la carta vola nello spazio libero, poi si esegue l'azione.
func _vola_e_esegui(tessera: Tessera3D, azione: Callable) -> void:
	var arrivo: Node3D = null
	if tessera.scheda.genere == SchedaCarta.Genere.EDIFICIO:
		arrivo = _spazio_libero_edificio
	elif tessera.scheda.genere == SchedaCarta.Genere.TRUPPA:
		arrivo = _spazio_libero_truppa
	if arrivo == null:
		_esegui(azione.call())
		return
	_scelte.erase(tessera)
	var destinazione: Vector3 = arrivo.global_position
	var volo: Tween = create_tween()
	volo.set_parallel(true)
	volo.tween_property(tessera, "global_position", destinazione + Vector3(0.0, 2.0, 0.0), 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	volo.tween_property(tessera, "rotation_degrees", Vector3.ZERO, 0.3)
	volo.tween_property(tessera, "scale", Vector3.ONE, 0.3)
	volo.chain().tween_property(tessera, "global_position", destinazione, 0.18).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	volo.chain().tween_callback(func() -> void: _esegui(azione.call()))


func _inizia_sostituzione(truppa: bool, testo: String, azione: Callable) -> void:
	_annulla()
	_modo = Modo.SOSTITUZIONE
	_sostituisce_truppa = truppa
	_azione_sostituzione = azione
	var fila: Array = _truppe[Lato.GIOCATORE] if truppa else _edifici[Lato.GIOCATORE]
	for tessera: Tessera3D in fila:
		var sostituibile: bool = truppa or not run.board.buildings[tessera.indice].building.is_capital
		if sostituibile:
			tessera.imposta_alone(Color(StileVisivo.PERICOLO, 0.6))
	_hud.mostra_sostituzione(testo)


func _clic_pezzo(tessera: Tessera3D, truppa: bool) -> void:
	var i: int = tessera.indice
	if _modo == Modo.SOSTITUZIONE:
		if truppa == _sostituisce_truppa:
			var azione: Callable = _azione_sostituzione
			_modo = Modo.NORMALE
			_esegui(azione.call(i))
		return
	_seleziona(truppa, i)


## Mostra le azioni possibili su un elemento della propria plancia.
func _seleziona(truppa: bool, i: int) -> void:
	_annulla()
	var fila: Array = _truppe[Lato.GIOCATORE] if truppa else _edifici[Lato.GIOCATORE]
	if i < 0 or i >= fila.size():
		return
	var tessera: Tessera3D = fila[i]
	tessera.imposta_alone(Color(StileVisivo.ORO_LUCE, 0.55))
	var pezzo: BoardPiece = run.board.troops[i] if truppa else run.board.buildings[i]
	var azioni: Array[Dictionary] = []
	if truppa:
		azioni.append({"testo": "◀ Sposta", "attiva": i > 0, "clic": func() -> void: _sposta(i, i - 1)})
		azioni.append({"testo": "Sposta ▶", "attiva": i < run.board.troops.size() - 1, "clic": func() -> void: _sposta(i, i + 1)})
	var costo: ResourceAmounts = run.upgrade_cost_of(pezzo)
	if costo != null:
		azioni.append({"testo": "Potenzia · %s" % costo.describe(), "attiva": run.can_pay(costo), "clic": func() -> void: _potenzia(truppa, i)})
	if pezzo.building == null or not pezzo.building.is_capital:
		var vendibile: bool = truppa or run.board.can_sell_building(i)
		azioni.append({"testo": "Vendi · +%d Oro" % RunState.half_down(pezzo.paid), "attiva": vendibile, "clic": func() -> void: _vendi(truppa, i)})
	_hud.mostra_pezzo(tessera.scheda.titolo, tessera.scheda.dettagli, azioni)


func _sposta(da: int, a: int) -> void:
	var riuscita: bool = run.move_troop(da, a)
	_esegui(riuscita)
	if riuscita:
		_seleziona(true, a)


func _potenzia(truppa: bool, i: int) -> void:
	var riuscita: bool = run.upgrade_troop(i) if truppa else run.upgrade_building(i)
	_esegui(riuscita, "Livello aumentato")
	if riuscita:
		_seleziona(truppa, i)


func _vendi(truppa: bool, i: int) -> void:
	_esegui(run.sell_troop(i) if truppa else run.sell_building(i), "Venduto")


# --- Scontri ---------------------------------------------------------------------

func _affronta_fantasma() -> void:
	var prima: Dictionary = _istantanea()
	if run.fight_ghost():
		_avvia_scontro("Scontro con il fantasma", prima)
	else:
		_esegui(false)


## Ciò che serve per raccontare l'esito: si salva prima dello scontro.
func _istantanea() -> Dictionary:
	return {
		"prestigio": run.prestige,
		"vittorie": run.wins,
		"cronaca": run.chronicle.size(),
		"ultima": run.last_chance,
	}


## RunState ha già deciso l'esito; qui lo scontro si rigioca passo per passo per mostrarlo.
func _avvia_scontro(titolo: String, prima: Dictionary) -> void:
	_sim = run.make_battle_replay()
	_setups = run.last_battle_setups()
	if _sim == null or _setups.size() != 2:
		_aggiorna_tutto()
		return
	_annulla()
	_modo = Modo.SCONTRO
	_prima = prima
	_esito_programmato = false
	_accumulo_ms = 0.0
	_in_pausa = false
	_togli_scelte()
	_hud.nascondi_suggerimento()

	var edifici: Array[SchedaCarta] = []
	var truppe: Array[SchedaCarta] = []
	var stessi_edifici: bool = run.board.buildings.size() == _setups[0].buildings.size()
	var stesse_truppe: bool = run.board.troops.size() == _setups[0].troops.size()
	for i: int in range(_setups[0].buildings.size()):
		edifici.append(SchedaCarta.da_edificio(_setups[0].buildings[i], run.board.buildings[i].level if stessi_edifici else 1))
	for i: int in range(_setups[0].troops.size()):
		truppe.append(SchedaCarta.da_truppa(_setups[0].troops[i], run.board.troops[i].level if stesse_truppe else 1))
	_costruisci_lato(Lato.GIOCATORE, edifici, truppe, edifici.size(), truppe.size())
	var edifici_avversari: Array[SchedaCarta] = []
	for def: BuildingDef in _setups[1].buildings:
		edifici_avversari.append(SchedaCarta.da_edificio(def))
	var truppe_avversarie: Array[SchedaCarta] = []
	for def: TroopDef in _setups[1].troops:
		truppe_avversarie.append(SchedaCarta.da_truppa(def))
	_costruisci_lato(Lato.AVVERSARIO, edifici_avversari, truppe_avversarie, 0, 0)
	_nomi_lato[Lato.AVVERSARIO].text = run.last_opponent_name.trim_prefix("Fantasma: ").to_upper()
	for lato: int in [Lato.GIOCATORE, Lato.AVVERSARIO]:
		_riserve[lato].visible = true
	_aggiorna_visuale_scontro()

	var avversario: Node3D = _radici[Lato.AVVERSARIO]
	avversario.visible = true
	avversario.position = Vector3(0.0, 0.0, -14.0)
	var arrivo: Tween = create_tween()
	arrivo.set_parallel(true)
	arrivo.tween_property(avversario, "position", Vector3.ZERO, 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	arrivo.tween_method(_muovi_camera.bind(_camera.global_position, CAMERA_SCONTRO, MIRA_PARTITA, MIRA_SCONTRO), 0.0, 1.0, 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	_hud.modalita_scontro(true, titolo)


func _muovi_camera(t: float, da: Vector3, a: Vector3, mira_da: Vector3, mira_a: Vector3) -> void:
	_camera.look_at_from_position(da.lerp(a, t), mira_da.lerp(mira_a, t), Vector3.UP)


func _on_pausa() -> void:
	_in_pausa = not _in_pausa
	_hud.imposta_pausa(_in_pausa)


func _salta_scontro() -> void:
	if _sim == null:
		return
	while _sim.outcome == BattleSim.Outcome.IN_CORSO:
		_sim.step()
	_aggiorna_visuale_scontro()


func _process(delta: float) -> void:
	_tempo += delta
	_luce_atmosfera.light_energy = 1.6 + sin(_tempo * 1.3) * 0.25
	for materiale: StandardMaterial3D in _materiali_bordo:
		materiale.emission_energy_multiplier = 1.2 + sin(_tempo * 2.0) * 0.25
	if _modo != Modo.SCONTRO or _sim == null:
		return
	for lato: int in [Lato.GIOCATORE, Lato.AVVERSARIO]:
		for i: int in range(_lampi[lato].size()):
			_lampi[lato][i] = maxf(0.0, float(_lampi[lato][i]) - delta * _velocita)
	if not _in_pausa and _sim.outcome == BattleSim.Outcome.IN_CORSO:
		_accumulo_ms += delta * 1000.0 * _velocita
		var passo: int = _sim.rules.tick_ms
		while _accumulo_ms >= passo and _sim.outcome == BattleSim.Outcome.IN_CORSO:
			_accumulo_ms -= passo
			_sim.step()
			_mostra_eventi()
	_aggiorna_visuale_scontro()
	if _sim.outcome != BattleSim.Outcome.IN_CORSO and not _esito_programmato:
		_esito_programmato = true
		var attesa: Tween = create_tween()
		attesa.tween_interval(0.9)
		attesa.tween_callback(_mostra_esito)


## Animazioni guidate dai fatti dell'ultimo passo della simulazione.
func _mostra_eventi() -> void:
	for evento: BattleEvent in _sim.last_step_events:
		match evento.kind:
			BattleEvent.Kind.MANA_PRODOTTO:
				if evento.index >= 0 and evento.index < _edifici[evento.side].size():
					var edificio: Tessera3D = _edifici[evento.side][evento.index]
					edificio.pulsa()
					_lancia_mana(evento.side, edificio, _setups[evento.side].buildings[evento.index].mana_type)
			BattleEvent.Kind.ATTIVAZIONE:
				if evento.index >= 0 and evento.index < _truppe[evento.side].size():
					var truppa: Tessera3D = _truppe[evento.side][evento.index]
					truppa.attiva(-1.0 if evento.side == Lato.GIOCATORE else 1.0)
					_lampi[evento.side][evento.index] = 0.5
				_colpo(1 - evento.side, evento.amount, "")
			BattleEvent.Kind.LOGORAMENTO:
				_colpo(evento.side, evento.amount, "logoramento")
			BattleEvent.Kind.SCUDO:
				_scritta_volante(evento.side, "+%d scudo" % evento.amount, Color("2f6fd0"))
			BattleEvent.Kind.CURA:
				_scritta_volante(evento.side, "+%d" % evento.amount, Color("2f9e57"))
			BattleEvent.Kind.CORRUZIONE:
				_scritta_volante(evento.side, "+%d Corruzione" % evento.amount, Color("8b3fc9"))
			BattleEvent.Kind.ASSEDIO:
				_scritta_volante(evento.side, "−%d scudo" % evento.amount, Color("7a6a55"))
			BattleEvent.Kind.RALLENTATO, BattleEvent.Kind.SABOTATO:
				var colpita: Tessera3D = _elemento_da_indice(evento.side, evento.index)
				if colpita != null:
					colpita.scintille(Color("ff9a3d") if evento.kind == BattleEvent.Kind.RALLENTATO else Color("b36bff"), Vector3(0.0, 0.3, 0.0), 14)


## Negli eventi di rallentamento e sabotaggio l'indice vale 0+ per gli edifici, 1000+ per le truppe.
func _elemento_da_indice(lato: int, indice: int) -> Tessera3D:
	if indice >= 1000:
		var truppa: int = indice - 1000
		return _truppe[lato][truppa] if truppa < _truppe[lato].size() else null
	if indice >= 0 and indice < _edifici[lato].size():
		return _edifici[lato][indice]
	return null


func _aggiorna_visuale_scontro() -> void:
	_hud.imposta_tempo(_sim.elapsed_ms)
	for lato: int in [Lato.GIOCATORE, Lato.AVVERSARIO]:
		_aggiorna_medaglione(lato, _sim.get_resistance(lato), _sim.get_max_resistance(lato))
		var scudo: int = _sim.get_shield(lato)
		_segnalini_scudo[lato].visible = scudo > 0
		_scritte_scudo[lato].text = str(scudo)
		var corruzione: int = _sim.get_corruption(lato)
		_segnalini_corruzione[lato].visible = corruzione > 0
		_scritte_corruzione[lato].text = str(corruzione)
		for i: int in range(_edifici[lato].size()):
			var edificio: Tessera3D = _edifici[lato][i]
			if _sim.get_building_sabotage_ms(lato, i) > 0:
				edificio.imposta_stato("Sabotato", Color("8b3fc9"))
			elif _sim.get_building_slow_ms(lato, i) > 0:
				edificio.imposta_stato("Rallentato", Color("e08a2e"))
			else:
				edificio.imposta_stato("", StileVisivo.NOTTE)
		for mana: StringName in COLORI_RISERVA:
			var scritta: Label3D = _scritte_riserva[lato][mana]
			scritta.text = str(_sim.get_mana(lato, mana))
		for i: int in range(_truppe[lato].size()):
			var tessera: Tessera3D = _truppe[lato][i]
			var def: TroopDef = _setups[lato].troops[i]
			var rimasto: int = _sim.get_troop_cooldown_left_ms(lato, i)
			var stato: BattleSim.TroopState = _sim.get_troop_state(lato, i)
			if stato == BattleSim.TroopState.SABOTATA:
				tessera.imposta_ricarica(1.0 - float(rimasto) / float(maxi(def.cooldown_ms, 1)))
				tessera.imposta_stato("Sabotata: non può attivarsi", Color("8b3fc9"))
			elif stato == BattleSim.TroopState.IN_ATTESA_DI_MANA:
				tessera.imposta_ricarica(1.0)
				var disponibile: int = _sim.get_mana(lato, def.mana_type) + _sim.get_mana(lato, BattleSim.MANA_ENERGETICO)
				tessera.imposta_stato("In attesa: servono %d %s, %s %d" % [def.mana_cost, def.mana_type, "ne hai" if lato == Lato.GIOCATORE else "ne ha", disponibile], StileVisivo.PERICOLO)
			else:
				tessera.imposta_ricarica(1.0 - float(rimasto) / float(maxi(def.cooldown_ms, 1)))
				if float(_lampi[lato][i]) > 0.0:
					tessera.imposta_stato("Si attiva!", StileVisivo.ORO_LUCE)
				elif _sim.get_troop_slow_ms(lato, i) > 0:
					tessera.imposta_stato("Rallentata", Color("e08a2e"))
				else:
					tessera.imposta_stato("", StileVisivo.NOTTE)


## Una gemma vola dall'edificio alla riserva di mana del suo lato, lasciando una scia.
func _lancia_mana(lato: int, edificio: Tessera3D, mana: StringName) -> void:
	if _gemme_in_volo >= MASSIMO_GEMME_IN_VOLO or not _gemme_riserva[lato].has(mana):
		return
	_gemme_in_volo += 1
	var colore: Color = StileVisivo.colore_mana_nome(mana)
	var gemma: MeshInstance3D = MeshInstance3D.new()
	var forma: SphereMesh = SphereMesh.new()
	forma.radius = 0.16
	forma.height = 0.32
	gemma.mesh = forma
	gemma.material_override = StileVisivo.materiale_luminoso(colore, 2.0)
	add_child(gemma)
	var scia: CPUParticles3D = CPUParticles3D.new()
	var goccia: SphereMesh = SphereMesh.new()
	goccia.radius = 0.06
	goccia.height = 0.12
	goccia.material = StileVisivo.materiale_luminoso(colore, 2.5)
	scia.mesh = goccia
	scia.amount = 24
	scia.lifetime = 0.35
	scia.local_coords = false
	scia.spread = 180.0
	scia.initial_velocity_min = 0.0
	scia.initial_velocity_max = 0.3
	scia.gravity = Vector3.ZERO
	scia.scale_amount_min = 0.4
	scia.scale_amount_max = 1.0
	gemma.add_child(scia)
	var partenza: Vector3 = edificio.punto_gemma()
	var destinazione: Node3D = _gemme_riserva[lato][mana]
	var arrivo: Vector3 = destinazione.global_position + Vector3(0.0, 0.2, 0.0)
	gemma.global_position = partenza
	var volo: Tween = create_tween()
	volo.tween_method(_muovi_gemma.bind(gemma, partenza, arrivo), 0.0, 1.0, 0.6 / maxf(_velocita, 1.0)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	volo.tween_callback(_gemma_arrivata.bind(gemma, destinazione))


func _muovi_gemma(t: float, gemma: MeshInstance3D, da: Vector3, a: Vector3) -> void:
	gemma.global_position = da.lerp(a, t) + Vector3(0.0, sin(t * PI) * 2.2, 0.0)


func _gemma_arrivata(gemma: MeshInstance3D, destinazione: Node3D) -> void:
	_gemme_in_volo -= 1
	gemma.queue_free()
	var animazione: Tween = create_tween()
	animazione.tween_property(destinazione, "scale", Vector3.ONE * 1.35, 0.06)
	animazione.tween_property(destinazione, "scale", Vector3.ONE, 0.12)


## Colpo sulla Resistenza di un lato: numero che salta fuori e stemma che trema.
func _colpo(lato: int, danno: int, nota: String) -> void:
	if danno <= 0:
		return
	var medaglione: Node3D = _medaglioni[lato]
	var testo: String = "−%d" % danno if nota == "" else "−%d %s" % [danno, nota]
	var numero: Label3D = StileVisivo.scritta(testo, StileVisivo.FONT_TITOLI, 140 if nota == "" else 70, Color.WHITE, 0.0, 22)
	numero.outline_modulate = StileVisivo.PERICOLO.darkened(0.35)
	numero.no_depth_test = true
	add_child(numero)
	var base: Vector3 = _punto_scritta(lato)
	numero.global_position = base
	numero.scale = Vector3.ONE * 0.6
	var salto: Tween = create_tween()
	salto.set_parallel(true)
	salto.tween_property(numero, "scale", Vector3.ONE, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	salto.tween_property(numero, "global_position", base + Vector3(0.0, 1.2, 0.0), 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	salto.tween_property(numero, "modulate:a", 0.0, 0.5).set_delay(0.35)
	salto.chain().tween_callback(numero.queue_free)
	var centro: Vector3 = Vector3(X_MEDAGLIONE, 0.0, medaglione.position.z)
	var scossa: Tween = create_tween()
	for passo: int in range(4):
		var spostamento: Vector3 = Vector3(randf_range(-0.12, 0.12), 0.0, randf_range(-0.08, 0.08))
		scossa.tween_property(medaglione, "position", centro + spostamento, 0.035)
	scossa.tween_property(medaglione, "position", centro, 0.05)


## Punto di partenza delle scritte sopra lo stemma: si alternano su tre posizioni.
func _punto_scritta(lato: int) -> Vector3:
	_scritte_uscite[lato] += 1
	var turno: int = _scritte_uscite[lato] % 3
	return _medaglioni[lato].global_position + Vector3(-0.7 + turno * 0.7, 1.6 + turno * 0.25, 0.1)


## Scritta che sale dallo stemma di un lato (scudo, cura, Corruzione, assedio).
func _scritta_volante(lato: int, testo: String, colore: Color) -> void:
	var scritta: Label3D = StileVisivo.scritta(testo, StileVisivo.FONT_TITOLI, 80, Color.WHITE, 0.0, 18)
	scritta.outline_modulate = colore.darkened(0.3)
	scritta.no_depth_test = true
	add_child(scritta)
	var base: Vector3 = _punto_scritta(lato)
	scritta.global_position = base
	var salto: Tween = create_tween()
	salto.set_parallel(true)
	salto.tween_property(scritta, "global_position", base + Vector3(0.0, 1.0, 0.0), 0.9).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	salto.tween_property(scritta, "modulate:a", 0.0, 0.5).set_delay(0.4)
	salto.chain().tween_callback(scritta.queue_free)


func _mostra_esito() -> void:
	var risultato: BattleSim.Outcome = _sim.outcome
	var titolo: String = "Scontro interrotto"
	var colore: Color = StileVisivo.TESTO
	match risultato:
		BattleSim.Outcome.VITTORIA_A:
			titolo = "Vittoria"
			colore = StileVisivo.ORO_LUCE
		BattleSim.Outcome.VITTORIA_B:
			titolo = "Sconfitta"
			colore = StileVisivo.PERICOLO
		BattleSim.Outcome.PAREGGIO:
			titolo = "Pareggio"
	var sottotitolo: String = "%s %d · %s %d" % [run.nation_name, maxi(_sim.get_resistance(0), 0), run.last_opponent_name.trim_prefix("Fantasma: "), maxi(_sim.get_resistance(1), 0)]
	var righe: Array[String] = []
	var prestigio_prima: int = int(_prima.get("prestigio", run.prestige))
	if prestigio_prima != run.prestige:
		righe.append("Prestigio: %d → %d." % [prestigio_prima, run.prestige])
	if int(_prima.get("vittorie", run.wins)) != run.wins:
		righe.append("Vittorie: %d di %d." % [run.wins, run.run_rules.wins_needed])
	if run.last_chance and not bool(_prima.get("ultima", false)):
		righe.append("Il Prestigio è esaurito: ultima possibilità.")
	var inizio: int = int(_prima.get("cronaca", run.chronicle.size()))
	for riga: String in run.chronicle.slice(inizio, mini(run.chronicle.size(), inizio + 6)):
		righe.append(riga)
	_hud.mostra_esito(titolo, sottotitolo, righe, colore, _chiudi_scontro)


func _chiudi_scontro() -> void:
	_sim = null
	_modo = Modo.NORMALE
	_hud.modalita_scontro(false)
	for lato: int in [Lato.GIOCATORE, Lato.AVVERSARIO]:
		_riserve[lato].visible = false
	var avversario: Node3D = _radici[Lato.AVVERSARIO]
	var uscita: Tween = create_tween()
	uscita.set_parallel(true)
	uscita.tween_property(avversario, "position", Vector3(0.0, 0.0, -14.0), 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	uscita.tween_method(_muovi_camera.bind(_camera.global_position, CAMERA_PARTITA, MIRA_SCONTRO, MIRA_PARTITA), 0.0, 1.0, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	uscita.chain().tween_callback(avversario.hide)
	_aggiorna_tutto()


# --- Mouse ---------------------------------------------------------------------

func _physics_process(_delta: float) -> void:
	var mouse: Vector2 = get_viewport().get_mouse_position()
	var origine: Vector3 = _camera.project_ray_origin(mouse)
	var fine: Vector3 = origine + _camera.project_ray_normal(mouse) * 120.0
	var richiesta: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origine, fine)
	var colpito: Dictionary = get_world_3d().direct_space_state.intersect_ray(richiesta)
	var tessera: Tessera3D = null
	if not colpito.is_empty():
		var oggetto: Object = colpito["collider"]
		if oggetto != null and oggetto.has_meta("tessera"):
			tessera = oggetto.get_meta("tessera") as Tessera3D
	if tessera != null and (not is_instance_valid(tessera) or not tessera.is_visible_in_tree() or tessera.is_queued_for_deletion()):
		tessera = null
	if tessera != _evidenziata:
		if _evidenziata != null and is_instance_valid(_evidenziata):
			_evidenziata.evidenzia(false)
		_evidenziata = tessera
		if tessera != null:
			tessera.evidenzia(true)
	if tessera != null and not _hud.esito_visibile():
		var scheda: SchedaCarta = tessera.scheda
		var titolo: String = scheda.titolo
		if scheda.sopratitolo != "" and scheda.sopratitolo != scheda.titolo:
			titolo = "%s · %s" % [scheda.sopratitolo, scheda.titolo]
		var testo: String = scheda.dettagli
		if scheda.costo != "":
			testo += "\nCosto: %s%s" % [scheda.costo, "" if scheda.disponibile else " (non basta)"]
		_hud.mostra_suggerimento(titolo, testo, mouse)
	else:
		_hud.nascondi_suggerimento()
