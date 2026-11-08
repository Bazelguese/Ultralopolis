extends Node3D
## La partita sulla plancia 3D (GDD §14.2): tavolo, plancia della nazione, offerte,
## incontri, ricompense, scontri ed esito dell'anno.
## Solo presentazione: lo stato e le regole sono tutti in RunState e BattleSim.
## La scena legge lo stato, chiama le azioni di RunState e rigioca gli scontri
## passo per passo dalla simulazione (il tempo reale decide solo il ritmo di visione).

enum Lato { GIOCATORE, AVVERSARIO }
enum Modo { NORMALE, SOSTITUZIONE, SCONTRO }
enum TipoScelta { NESSUNA, OFFERTA, INCONTRO, RICOMPENSA, FANTASMA, VIA, CONSIGLIERE, OPZIONE, GOVERNO, ASCENSIONE }

const PASSO_TRUPPE: float = 1.75
const PASSO_EDIFICI: float = 2.1
const MISURA_TRUPPA: Vector2 = Vector2(1.58, 1.95)
const MISURA_EDIFICIO: Vector2 = Vector2(1.9, 1.6)
const MISURA_AZIONE: Vector2 = Vector2(1.7, 1.95)
const SCALA_SCELTA: float = 1.45
## Le scelte con le righe di simboli si ingrandiscono così tanto al passaggio del mouse.
const INGRANDIMENTO_SIMBOLI: float = 1.7
const Z_TRUPPE: float = 1.75
const Z_EDIFICI: float = 4.4
## Bordo sinistro del primo spazio: gli spazi si allineano a destra dello stemma.
const X_INIZIO_SPAZI: float = -9.6
## Bordo sinistro della lastra (fisso: stemma e riserva stanno qui).
const BORDO_SINISTRO_LASTRA: float = -12.605
const MARGINE_DESTRO_LASTRA: float = 0.35
const PROFONDITA_LASTRA: float = 5.0
## Larghezza della lastra con tutti gli spazi: la plancia si ingrandisce quando è più corta.
const LARGHEZZA_LASTRA_PIENA: float = 24.35
const SCALA_MASSIMA: float = 1.4
const SCALA_MASSIMA_SCONTRO: float = 1.2
const DURATA_DISPOSIZIONE: float = 0.45
const X_MEDAGLIONE: float = -11.2
const SPAZI_TRUPPE: int = 12
const SPAZI_EDIFICI: int = 10
const COLORI_RISERVA: Array[StringName] = [&"rosso", &"verde", &"blu", &"viola", &"energetico"]
## Oltre questo numero di gemme in volo non se ne lanciano altre (solo effetto visivo).
const MASSIMO_GEMME_IN_VOLO: int = 24

const CAMERA_PARTITA: Vector3 = Vector3(-0.4, 27.0, 14.6)
const MIRA_PARTITA: Vector3 = Vector3(-0.4, 0.0, 0.9)
## Spostamento a destra della plancia, per lasciare spazio alla colonna di sinistra.
const SPOSTAMENTO_PLANCIA: float = 1.2
const CAMERA_SCONTRO: Vector3 = Vector3(-0.4, 28.4, 15.6)
const MIRA_SCONTRO: Vector3 = Vector3(-0.4, 0.0, 1.1)

var run: RunState

var _camera: Camera3D
var _luce_atmosfera: OmniLight3D
var _hud: HudPlancia
## Contiene i due lati: si ingrandisce e si centra in base a quanti spazi si vedono.
var _plancia: Node3D
var _radici: Array[Node3D] = [null, null]
var _lastre: Array[MeshInstance3D] = [null, null]
var _bordi_lastre: Array[Array] = [[], []]
var _larghezze: Array[float] = [LARGHEZZA_LASTRA_PIENA, LARGHEZZA_LASTRA_PIENA]
var _nota_ordine: Label3D
var _animazione_plancia: Tween
## All'inizio di una partita la plancia compare già della misura giusta, senza animazione.
var _disponi_subito: bool = true
var _pezzi: Array[Node3D] = [null, null]
var _truppe: Array[Array] = [[], []]
var _edifici: Array[Array] = [[], []]
var _spazio_libero_edificio: Node3D
var _spazio_libero_truppa: Node3D
var _materiali_bordo: Array[StandardMaterial3D] = []
var _medaglioni: Array[Node3D] = [null, null]
## Ultima azione riuscita da annunciare e momento dell'anno già annunciato.
var _messaggio_azione: String = ""
var _firma_momento: String = ""
var _scritte_resistenza: Array[Label3D] = [null, null]
## Ritratto alla Dota (richiesta di Davide): iniziali della nazione al centro e anello del tempo
## di battaglia attorno; si riempie fino al logoramento, poi diventa rosso.
var _iniziali: Array[Label3D] = [null, null]
var _anelli: Array[Array] = [[], []]
var _stato_anelli: Array[int] = [-1, -1]
var _materiale_anello_spento: StandardMaterial3D
var _materiale_anello_acceso: StandardMaterial3D
var _materiale_anello_logoramento: StandardMaterial3D
const SEGMENTI_ANELLO: int = 48
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
## Che cosa rappresenta ogni carta sul tavolo (offerta, via, opzione, ricompensa…), stesso ordine di _scelte.
var _origini_scelte: Array[Object] = []
var _costi_scelte: Array[Label3D] = []
## Riconosce le stesse scelte di prima: in quel caso non si rifanno né la carta né l'entrata.
var _firma_scelte: String = ""
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
	_plancia = Node3D.new()
	add_child(_plancia)
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
	_hud.rinnova.connect(func() -> void: _esegui(run.reroll_offers(), "Proposte rinnovate"))
	_hud.rinnova_risorsa.connect(func() -> void: _esegui(run.reroll_offers(true), "Proposte rinnovate"))
	_hud.passa.connect(func() -> void: _esegui(run.pass_round(), "Round passato"))
	_hud.nessuna_ricompensa.connect(func() -> void: _esegui(run.skip_reward()))
	_hud.avanza_era.connect(_on_avanza_era)
	_hud.scegli_tecnologia.connect(_on_scegli_tecnologia)
	_hud.vendi_risorsa.connect(func(tipo: int) -> void: _esegui(run.sell_resource(tipo, run.market_rate())))
	_hud.ricomincia.connect(_nuova_run)
	_hud.menu.connect(func() -> void: GameSession.go(GameSession.MENU_SCENE))
	_hud.pausa.connect(_on_pausa)
	_hud.velocita.connect(func(fattore: float) -> void: _velocita = fattore)
	_hud.annulla.connect(_annulla)
	_hud.scegli_cronaca.connect(_on_scegli_cronaca)


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
	_disponi_subito = true
	_firma_scelte = ""
	_aggiorna_tutto()


## Reazione della nazione alla cronaca (GDD §9.6): se agisce su una carta, prima si sceglie quale.
func _on_scegli_cronaca(indice: int) -> void:
	var opzioni: Array[EventOptionDef] = run.chronicle_options()
	if indice < 0 or indice >= opzioni.size():
		return
	var opzione: EventOptionDef = opzioni[indice]
	var voci: Array[String] = run.option_choices(opzione)
	var nome: String = run.chronicle_text(opzione.label)
	if not voci.is_empty():
		_hud.mostra_scelte(nome, run.chronicle_text(opzione.description), voci, func(voce: int) -> void: _esegui(run.choose_chronicle_option(indice, voce), nome))
	else:
		_esegui(run.choose_chronicle_option(indice), nome)


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
	_plancia.add_child(radice)
	_radici[lato] = radice
	var z_centro: float = (Z_TRUPPE + Z_EDIFICI) * 0.5 * _segno(lato)
	_crea_lastra(radice, lato, z_centro, _colore_lato(lato))
	_crea_medaglione(radice, lato, z_centro)
	_crea_riserva(radice, lato, z_centro)
	_pezzi[lato] = Node3D.new()
	radice.add_child(_pezzi[lato])
	if lato == Lato.GIOCATORE:
		# Fra la fila delle truppe e quella degli edifici, allineata a destra.
		_nota_ordine = StileVisivo.scritta("LE TRUPPE AGISCONO DA DESTRA VERSO SINISTRA  ←", StileVisivo.FONT_TESTO_FORTE, 42, StileVisivo.TESTO_TENUE)
		_nota_ordine.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		_nota_ordine.position = Vector3(0.0, 0.02, (Z_TRUPPE + MISURA_TRUPPA.y * 0.5 + Z_EDIFICI - MISURA_EDIFICIO.y * 0.5) * 0.5)
		radice.add_child(_nota_ordine)
	_imposta_larghezza_lastra(lato, LARGHEZZA_LASTRA_PIENA)


## Lastra con bordo luminoso. La larghezza si cambia poi con _imposta_larghezza_lastra.
func _crea_lastra(radice: Node3D, lato: int, z_centro: float, colore: Color) -> void:
	var lastra: MeshInstance3D = MeshInstance3D.new()
	var forma: BoxMesh = BoxMesh.new()
	forma.size = Vector3(LARGHEZZA_LASTRA_PIENA, 0.4, PROFONDITA_LASTRA)
	lastra.mesh = forma
	lastra.material_override = StileVisivo.materiale_pietra(StileVisivo.PIETRA, 2.5)
	lastra.position = Vector3(0.0, -0.18, z_centro)
	radice.add_child(lastra)
	_lastre[lato] = lastra
	var luce: StandardMaterial3D = StileVisivo.materiale_luminoso(colore, 1.3)
	_materiali_bordo.append(luce)
	_bordi_lastre[lato] = []
	for i: int in range(4):
		var bordo: MeshInstance3D = MeshInstance3D.new()
		var forma_bordo: BoxMesh = BoxMesh.new()
		forma_bordo.size = Vector3(LARGHEZZA_LASTRA_PIENA + 0.1, 0.07, 0.07) if i < 2 else Vector3(0.07, 0.07, PROFONDITA_LASTRA + 0.1)
		bordo.mesh = forma_bordo
		bordo.material_override = luce
		var z: float = z_centro + (PROFONDITA_LASTRA * (-0.5 if i == 0 else 0.5) if i < 2 else 0.0)
		bordo.position = Vector3(0.0, 0.035, z)
		radice.add_child(bordo)
		_bordi_lastre[lato].append(bordo)


## La lastra parte sempre dallo stemma e si allunga verso destra quanto servono gli spazi.
func _imposta_larghezza_lastra(lato: int, larghezza: float) -> void:
	_larghezze[lato] = larghezza
	var centro_x: float = BORDO_SINISTRO_LASTRA + larghezza * 0.5
	(_lastre[lato].mesh as BoxMesh).size.x = larghezza
	_lastre[lato].position.x = centro_x
	var bordi: Array = _bordi_lastre[lato]
	for i: int in range(2):
		var bordo: MeshInstance3D = bordi[i]
		(bordo.mesh as BoxMesh).size.x = larghezza + 0.1
		bordo.position.x = centro_x
	(bordi[2] as MeshInstance3D).position.x = BORDO_SINISTRO_LASTRA
	(bordi[3] as MeshInstance3D).position.x = BORDO_SINISTRO_LASTRA + larghezza
	if lato == Lato.GIOCATORE and _nota_ordine != null:
		_nota_ordine.position.x = BORDO_SINISTRO_LASTRA + larghezza - MARGINE_DESTRO_LASTRA


## Larghezza della lastra che contiene tanti spazi (almeno due edifici, per non farla troppo corta).
func _larghezza_per(spazi_truppe: int, spazi_edifici: int) -> float:
	var contenuto: float = maxf(maxf(spazi_truppe * PASSO_TRUPPE, spazi_edifici * PASSO_EDIFICI), 2.0 * PASSO_EDIFICI)
	return (X_INIZIO_SPAZI - BORDO_SINISTRO_LASTRA) + contenuto + MARGINE_DESTRO_LASTRA


## Quanto ingrandire la plancia perché la lastra più larga riempia lo spazio di una plancia piena.
func _scala_per(larghezza: float, massima: float) -> float:
	return clampf(LARGHEZZA_LASTRA_PIENA / maxf(larghezza, 1.0), 1.0, massima)


## Ingrandisce e centra la plancia. In partita la lastra del giocatore cresce attorno al suo centro,
## un po' spostata verso l'alto per non coprire i comandi; in uno scontro i due lati restano
## simmetrici rispetto al centro del tavolo.
func _disponi_plancia(scala: float, larghezza: float, scontro: bool, durata: float) -> void:
	var z_centro: float = (Z_TRUPPE + Z_EDIFICI) * 0.5
	var z: float = 0.0 if scontro else z_centro * (1.0 - scala) - (scala - 1.0) * 1.1
	# Un po' a destra: a sinistra c'è la colonna con la nazione e il calendario.
	var posizione: Vector3 = Vector3(MIRA_PARTITA.x + SPOSTAMENTO_PLANCIA - scala * (BORDO_SINISTRO_LASTRA + larghezza * 0.5), 0.0, z)
	if _animazione_plancia != null and _animazione_plancia.is_valid():
		_animazione_plancia.kill()
	if durata <= 0.0:
		_plancia.scale = Vector3.ONE * scala
		_plancia.position = posizione
		return
	_animazione_plancia = create_tween()
	_animazione_plancia.set_parallel(true)
	_animazione_plancia.tween_property(_plancia, "scale", Vector3.ONE * scala, durata).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	_animazione_plancia.tween_property(_plancia, "position", posizione, durata).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)


func _crea_medaglione(radice: Node3D, lato: int, z_centro: float) -> void:
	var colore: Color = _colore_lato(lato)
	var medaglione: Node3D = Node3D.new()
	medaglione.position = Vector3(X_MEDAGLIONE, 0.0, z_centro - 1.35)
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
	# Al centro del ritratto le iniziali della nazione, come lo stemma di un eroe.
	var iniziali: Label3D = StileVisivo.scritta("", StileVisivo.FONT_TITOLI, 120, Color.WHITE, 0.0, 18)
	iniziali.position.y = 0.2
	medaglione.add_child(iniziali)
	_iniziali[lato] = iniziali
	_crea_anello(medaglione, lato)
	var nome: Label3D = StileVisivo.scritta("", StileVisivo.FONT_TITOLI, 40, StileVisivo.TESTO, 0.0, 8)
	nome.position = Vector3(X_MEDAGLIONE, 0.04, z_centro + 0.12)
	radice.add_child(nome)
	_nomi_lato[lato] = nome
	# Sotto il nome la barra della Resistenza con i numeri sopra, come la vita di un eroe.
	var fondo_barra: MeshInstance3D = MeshInstance3D.new()
	var forma_fondo: BoxMesh = BoxMesh.new()
	forma_fondo.size = Vector3(2.3, 0.04, 0.4)
	fondo_barra.mesh = forma_fondo
	fondo_barra.material_override = StileVisivo.materiale(StileVisivo.NOTTE, 0.9)
	fondo_barra.position = Vector3(X_MEDAGLIONE, 0.04, z_centro + 0.58)
	radice.add_child(fondo_barra)
	var barra: MeshInstance3D = MeshInstance3D.new()
	var forma_barra: BoxMesh = BoxMesh.new()
	forma_barra.size = Vector3(2.2, 0.05, 0.32)
	barra.mesh = forma_barra
	barra.material_override = StileVisivo.materiale_luminoso(Color("3fae6a"), 0.7)
	barra.position = fondo_barra.position + Vector3(0.0, 0.01, 0.0)
	radice.add_child(barra)
	_barre_resistenza[lato] = barra
	var numero: Label3D = StileVisivo.scritta("0", StileVisivo.FONT_TITOLI, 60, Color.WHITE, 0.0, 12)
	numero.position = fondo_barra.position + Vector3(0.0, 0.06, 0.0)
	radice.add_child(numero)
	_scritte_resistenza[lato] = numero
	var scudo: Array = _crea_segnalino(medaglione, Vector3(1.5, 0.0, -0.55), Color("2f6fd0"))
	_segnalini_scudo[lato] = scudo[0]
	_scritte_scudo[lato] = scudo[1]
	var corruzione: Array = _crea_segnalino(medaglione, Vector3(1.5, 0.0, 0.55), Color("8b3fc9"))
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
		var x: float = (i - (COLORI_RISERVA.size() - 1) * 0.5) * 0.55
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
	_scritte_resistenza[lato].text = "%d / %d" % [maxi(resistenza, 0), maxi(massimo, 0)]
	_iniziali[lato].text = _iniziali_di(_nomi_lato[lato].text)
	var frazione: float = clampf(float(resistenza) / float(maxi(massimo, 1)), 0.0, 1.0)
	var barra: MeshInstance3D = _barre_resistenza[lato]
	barra.scale.x = maxf(frazione, 0.001)
	barra.position.x = X_MEDAGLIONE - 1.1 * (1.0 - frazione)
	# Verde, poi giallo e rosso quando la Resistenza scende.
	var colore: Color = Color("3fae6a") if frazione > 0.5 else (Color("e0b23a") if frazione > 0.25 else StileVisivo.PERICOLO)
	(barra.material_override as StandardMaterial3D).albedo_color = colore
	(barra.material_override as StandardMaterial3D).emission = colore


## Iniziali delle prime due parole del nome, saltando le parole brevi ("di", "del"…).
static func _iniziali_di(nome: String) -> String:
	var lettere: String = ""
	for parola: String in nome.split(" ", false):
		if parola.length() > 3 and lettere.length() < 2:
			lettere += parola.left(1).to_upper()
	if lettere == "" and nome.strip_edges() != "":
		lettere = nome.strip_edges().left(1).to_upper()
	return lettere


## Anello di segmenti attorno al ritratto: il tempo della battaglia.
func _crea_anello(medaglione: Node3D, lato: int) -> void:
	if _materiale_anello_spento == null:
		_materiale_anello_spento = StileVisivo.materiale(Color("26304a"), 0.9)
		_materiale_anello_acceso = StileVisivo.materiale_luminoso(StileVisivo.ORO, 0.7)
		_materiale_anello_logoramento = StileVisivo.materiale_luminoso(StileVisivo.PERICOLO, 1.4)
	var raggio: float = 1.13
	var forma: BoxMesh = BoxMesh.new()
	forma.size = Vector3(0.11, 0.06, 0.13)
	_anelli[lato] = []
	for i: int in range(SEGMENTI_ANELLO):
		# Dall'alto, in senso orario come una lancetta.
		var angolo: float = -PI / 2.0 + TAU * float(i) / float(SEGMENTI_ANELLO)
		var segmento: MeshInstance3D = MeshInstance3D.new()
		segmento.mesh = forma
		segmento.material_override = _materiale_anello_spento
		segmento.position = Vector3(cos(angolo) * raggio, 0.05, sin(angolo) * raggio)
		segmento.rotation.y = -angolo + PI / 2.0
		medaglione.add_child(segmento)
		_anelli[lato].append(segmento)
	_stato_anelli[lato] = 0


## Riempie l'anello fino all'inizio del logoramento; da lì in poi è tutto rosso.
func _aggiorna_anello(lato: int, millisecondi: int) -> void:
	var inizio: int = maxi(1, run.battle_rules.attrition_start_ms)
	var stato: int = -2 if millisecondi >= inizio else int(float(millisecondi) / float(inizio) * SEGMENTI_ANELLO)
	if stato == _stato_anelli[lato]:
		return
	_stato_anelli[lato] = stato
	for i: int in range(_anelli[lato].size()):
		var segmento: MeshInstance3D = _anelli[lato][i]
		if stato == -2:
			segmento.material_override = _materiale_anello_logoramento
		else:
			segmento.material_override = _materiale_anello_acceso if i < stato else _materiale_anello_spento


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
	var scritta: Label3D = StileVisivo.scritta("LIBERO" if disponibile else "DA CONQUISTARE", StileVisivo.FONT_TITOLI, 46 if disponibile else 34, Color(colore_lato, 0.85) if disponibile else Color(StileVisivo.TESTO_TENUE, 0.6), 0.0, 6)
	scritta.position = Vector3(0.0, 0.004, 0.0)
	spazio.add_child(scritta)
	return spazio


func _posizione_truppa(lato: int, i: int) -> Vector3:
	return Vector3(X_INIZIO_SPAZI + (i + 0.5) * PASSO_TRUPPE, 0.02, Z_TRUPPE * _segno(lato))


func _posizione_edificio(lato: int, i: int) -> Vector3:
	return Vector3(X_INIZIO_SPAZI + (i + 0.5) * PASSO_EDIFICI, 0.02, Z_EDIFICI * _segno(lato))


## Quanti spazi mostrare in una fila: quelli occupati o disponibili, più uno chiuso
## (se se ne possono ancora conquistare) per ricordare che la plancia può crescere.
func _spazi_mostrati(occupati: int, capacita: int, massimo: int, chiuso: bool) -> int:
	var quanti: int = maxi(occupati, capacita)
	if chiuso and quanti < massimo:
		quanti += 1
	return mini(quanti, massimo)


## Ricostruisce le carte di un lato e allarga la sua lastra quanto serve.
## Gli spazi vuoti si mostrano solo per il giocatore. nitidezza: risoluzione delle facce.
func _costruisci_lato(lato: int, edifici: Array[SchedaCarta], truppe: Array[SchedaCarta], capacita_edifici: int, capacita_truppe: int, spazi_chiusi: bool, nitidezza: float) -> void:
	for figlio: Node in _pezzi[lato].get_children():
		figlio.queue_free()
	_truppe[lato] = []
	_edifici[lato] = []
	_lampi[lato] = []
	if lato == Lato.GIOCATORE:
		_spazio_libero_edificio = null
		_spazio_libero_truppa = null
	var colore: Color = _colore_lato(lato)
	var spazi_truppe: int = _spazi_mostrati(truppe.size(), capacita_truppe, SPAZI_TRUPPE, spazi_chiusi)
	var spazi_edifici: int = _spazi_mostrati(edifici.size(), capacita_edifici, SPAZI_EDIFICI, spazi_chiusi)
	_imposta_larghezza_lastra(lato, _larghezza_per(spazi_truppe, spazi_edifici))
	for i: int in range(spazi_truppe):
		if i < truppe.size():
			_truppe[lato].append(_crea_tessera(_pezzi[lato], truppe[i], MISURA_TRUPPA, _posizione_truppa(lato, i), i, nitidezza))
			_lampi[lato].append(0.0)
		elif lato == Lato.GIOCATORE:
			var spazio: Node3D = _crea_spazio(_pezzi[lato], _posizione_truppa(lato, i), MISURA_TRUPPA, i < capacita_truppe, colore)
			if i < capacita_truppe and _spazio_libero_truppa == null:
				_spazio_libero_truppa = spazio
	for i: int in range(spazi_edifici):
		if i < edifici.size():
			_edifici[lato].append(_crea_tessera(_pezzi[lato], edifici[i], MISURA_EDIFICIO, _posizione_edificio(lato, i), i, nitidezza))
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
	var capacita_edifici: int = run.board.building_capacity()
	var capacita_truppe: int = run.board.troop_capacity()
	var larghezza: float = _larghezza_per(
			_spazi_mostrati(truppe.size(), capacita_truppe, SPAZI_TRUPPE, true),
			_spazi_mostrati(edifici.size(), capacita_edifici, SPAZI_EDIFICI, true))
	var scala: float = _scala_per(larghezza, SCALA_MASSIMA)
	_costruisci_lato(Lato.GIOCATORE, edifici, truppe, capacita_edifici, capacita_truppe, true, scala)
	var animata: bool = not _disponi_subito and (_plancia.scale.x != scala or _modo == Modo.SCONTRO)
	_disponi_subito = false
	_disponi_plancia(scala, larghezza, false, DURATA_DISPOSIZIONE if animata else 0.0)


# --- Scelte sul tavolo: offerte, incontri, ricompense, fantasma ----------------------

## Mette sul tavolo le scelte del momento. Se sono le stesse di prima (es. dopo una vendita
## o uno spostamento) le carte restano dove sono: cambiano solo il prezzo e se si può pagare.
func _costruisci_scelte() -> void:
	var schede: Array[SchedaCarta] = []
	var origini: Array[Object] = []
	var tipo: TipoScelta = TipoScelta.NESSUNA
	var fase: int = run.phase
	if not run.way_choices.is_empty():
		tipo = TipoScelta.VIA
		for via: IdentityDef in run.way_choices:
			schede.append(SchedaCarta.da_via(via))
			origini.append(via)
		fase = -1
	elif not run.ascension_choices.is_empty():
		# Albero di una via completo (GDD §10.4.2): si sceglie un'ascensione.
		tipo = TipoScelta.ASCENSIONE
		for ascensione: IdentityDef in run.ascension_choices:
			schede.append(SchedaCarta.da_ascensione(ascensione))
			origini.append(ascensione)
		fase = -1
	elif not run.government_choices.is_empty():
		# Evoluzione del governo entrando nell'era (GDD §9.4): l'ultima carta la rifiuta.
		tipo = TipoScelta.GOVERNO
		for governo: IdentityDef in run.government_choices:
			schede.append(SchedaCarta.da_governo(governo))
			origini.append(governo)
		schede.append(SchedaCarta.da_resta(run.government()))
		origini.append(run.government())
		fase = -1
	match fase:
		RunState.Phase.CONSIGLIO:
			if run.chosen_event != null:
				tipo = TipoScelta.OPZIONE
				for opzione: EventOptionDef in run.event_options():
					schede.append(SchedaCarta.da_opzione(run, opzione))
					origini.append(opzione)
			elif run.chosen_advisor == null:
				tipo = TipoScelta.CONSIGLIERE
				for consigliere: AdvisorDef in run.advisor_choices:
					schede.append(SchedaCarta.da_consigliere(run, consigliere))
					origini.append(consigliere)
				if run.event_choice != null:
					schede.append(SchedaCarta.da_evento(run, run.event_choice))
					origini.append(run.event_choice)
			else:
				tipo = TipoScelta.OFFERTA
				for offerta: Offer in run.offers:
					schede.append(SchedaCarta.da_offerta(run, offerta))
					origini.append(offerta)
		RunState.Phase.SCELTA_INCONTRO:
			tipo = TipoScelta.INCONTRO
			for incontro: EncounterDef in run.encounter_choices:
				schede.append(SchedaCarta.da_incontro(incontro))
				origini.append(incontro)
		RunState.Phase.RICOMPENSA_INCONTRO:
			tipo = TipoScelta.RICOMPENSA
			for ricompensa: RewardDef in run.reward_choices():
				schede.append(SchedaCarta.da_ricompensa(ricompensa))
				origini.append(ricompensa)
		RunState.Phase.SCONTRO_FANTASMA:
			if run.current_ghost != null:
				tipo = TipoScelta.FANTASMA
				schede.append(SchedaCarta.da_fantasma(run, run.current_ghost))
				origini.append(run.current_ghost)
	var firma: String = "%d|%d|%d|%d" % [tipo, run.year, run.phase, run.round_number]
	for origine: Object in origini:
		firma += "|%d" % origine.get_instance_id()
	if run.chosen_advisor != null:
		firma += "|%s" % run.chosen_advisor.id
	if run.chosen_event != null:
		firma += "|evento:%s" % run.chosen_event.id
	if firma == _firma_scelte and _scelte.size() == schede.size():
		_aggiorna_scelte(schede)
		return
	_firma_scelte = firma
	_tipo_scelta = tipo
	_origini_scelte = origini
	for figlio: Node in _contenitore_scelte.get_children():
		figlio.queue_free()
	_scelte = []
	_costi_scelte = []
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
		if not scheda.simboli.is_empty():
			tessera.imposta_ingrandimento(INGRANDIMENTO_SIMBOLI)
		if scheda.sopratitolo != "":
			var sopra: Label3D = StileVisivo.scritta(scheda.sopratitolo.to_upper(), StileVisivo.FONT_TITOLI, 42, StileVisivo.TESTO, 0.0, 10)
			sopra.position = Vector3(0.0, 0.02, -misura.y * 0.5 - 0.24)
			tessera.add_child(sopra)
		var costo: Label3D = StileVisivo.scritta(scheda.costo, StileVisivo.FONT_TITOLI, 54, StileVisivo.ORO_LUCE if scheda.disponibile else StileVisivo.PERICOLO, 0.0, 12)
		costo.position = Vector3(0.0, 0.02, misura.y * 0.5 + 0.27)
		tessera.add_child(costo)
		_costi_scelte.append(costo)
		_scelte.append(tessera)
		var entrata: Tween = create_tween()
		entrata.tween_interval(0.07 * i)
		entrata.tween_property(tessera, "position", arrivo, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Stesse scelte di prima: si aggiornano prezzo, colore del prezzo e velo, senza animazioni.
func _aggiorna_scelte(schede: Array[SchedaCarta]) -> void:
	for i: int in range(schede.size()):
		var scheda: SchedaCarta = schede[i]
		_scelte[i].aggiorna_scheda(scheda)
		_costi_scelte[i].text = scheda.costo
		_costi_scelte[i].modulate = StileVisivo.ORO_LUCE if scheda.disponibile else StileVisivo.PERICOLO


func _togli_scelte() -> void:
	for tessera: Tessera3D in _scelte:
		var uscita: Tween = create_tween()
		uscita.tween_property(tessera, "position", tessera.position + Vector3(0.0, 6.0, -4.0), 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		uscita.tween_callback(tessera.queue_free)
	_scelte = []
	_costi_scelte = []
	_firma_scelte = ""
	_tipo_scelta = TipoScelta.NESSUNA


# --- Aggiornamento ---------------------------------------------------------------

func _aggiorna_tutto() -> void:
	_annulla()
	_costruisci_plancia_giocatore()
	_costruisci_scelte()
	_aggiorna_stato_consiglieri()
	_mostra_potenziabili(run.chosen_advisor)
	_nomi_lato[Lato.GIOCATORE].text = run.nation_name.to_upper()
	_aggiorna_medaglione(Lato.GIOCATORE, run.player_resistance(), run.player_resistance())
	_hud.aggiorna_partita(run)
	# Annuncio in alto al centro: l'azione appena fatta e, sotto, che cosa è cambiato.
	var novita: String = _novita_momento()
	if _messaggio_azione != "":
		_hud.mostra_messaggio(_messaggio_azione, false, novita)
	elif novita != "":
		_hud.mostra_messaggio(novita)
	_messaggio_azione = ""


## Dopo un'azione di RunState: messaggio di errore se non è riuscita, poi si ridisegna tutto.
func _esegui(riuscita: bool, messaggio: String = "") -> void:
	if not riuscita:
		_hud.mostra_messaggio(run.last_error, true)
	_messaggio_azione = messaggio if riuscita else ""
	_aggiorna_tutto()


## Che cosa è cambiato nell'anno dall'ultima volta: nuovo round, nuova stagione, cronaca, scontro.
## Vuoto se si è ancora nello stesso momento.
func _novita_momento() -> String:
	var firma: String = "%d|%d|%d|%d" % [run.year, run.season, run.phase, run.round_number]
	if firma == _firma_momento:
		return ""
	var prima: String = _firma_momento
	_firma_momento = firma
	match run.phase:
		RunState.Phase.CONSIGLIO:
			var stagione_nuova: bool = prima == "" or not prima.begins_with("%d|%d|" % [run.year, run.season])
			if stagione_nuova and run.round_number == 1:
				return "Inizia %s · anno %d · %s" % [("l'" if run.season == RunState.Season.INVERNO or run.season == RunState.Season.ESTATE or run.season == RunState.Season.AUTUNNO else "la ") + run.season_name().to_lower(), run.year, run.month_name()]
			return "Nuovo round · %s · tema %s" % [run.month_name(), run.theme_name()]
		RunState.Phase.CRONACA:
			return "%s · anno %d" % [run.chronicle_moment(), run.year]
		RunState.Phase.SCELTA_INCONTRO:
			return "Incontro del mondo"
		RunState.Phase.SCONTRO_FANTASMA:
			return "Il fantasma è arrivato"
	return ""


## Il consigliere della carta sotto il mouse, se è una carta consigliere del round.
func _consigliere_sotto(tessera: Tessera3D) -> AdvisorDef:
	if tessera == null or _tipo_scelta != TipoScelta.CONSIGLIERE or not (tessera in _scelte):
		return null
	if tessera.indice < 0 or tessera.indice >= run.advisor_choices.size():
		return null
	return run.advisor_choices[tessera.indice]


## Le tue carte che riceverebbero il bonus della carta sotto il mouse (perk, via, opzione…).
func _beneficiari_sotto(tessera: Tessera3D) -> Array[BoardPiece]:
	var vuoto: Array[BoardPiece] = []
	if tessera == null or not (tessera in _scelte) or run == null:
		return vuoto
	var indice: int = _scelte.find(tessera)
	if indice < 0 or indice >= _origini_scelte.size():
		return vuoto
	return run.pieces_boosted_by(_modificatori_di(_origini_scelte[indice]))


## I modificatori che una carta sul tavolo darebbe alla nazione.
static func _modificatori_di(origine: Object) -> Array[ModifierDef]:
	var vuoto: Array[ModifierDef] = []
	if origine is Offer:
		var offerta: Offer = origine
		if offerta.perk != null:
			return offerta.perk.permanent_modifiers
		if offerta.opportunity != null:
			return offerta.opportunity.modifiers
	elif origine is IdentityDef:
		return (origine as IdentityDef).permanent_modifiers
	elif origine is EventOptionDef:
		return (origine as EventOptionDef).modifiers
	elif origine is RewardDef:
		var ricompensa: RewardDef = origine
		if ricompensa.perk != null:
			return ricompensa.perk.permanent_modifiers
	return vuoto


## Segna le carte che ne beneficerebbero: alone azzurro e "◆ NE BENEFICIA" sotto la carta.
func _mostra_beneficiari(pezzi: Array[BoardPiece]) -> void:
	for coppia: Array in [[_truppe[Lato.GIOCATORE], run.board.troops], [_edifici[Lato.GIOCATORE], run.board.buildings]]:
		var tessere: Array = coppia[0]
		var lista: Array = coppia[1]
		for i: int in range(mini(tessere.size(), lista.size())):
			var tessera: Tessera3D = tessere[i]
			if not is_instance_valid(tessera):
				continue
			if pezzi.has(lista[i]):
				tessera.imposta_segnale("◆ NE BENEFICIA", StileVisivo.COLORE_GIOCATORE)
				tessera.imposta_alone(Color(StileVisivo.COLORE_GIOCATORE, 0.35))
			elif tessera.ha_segnale():
				tessera.imposta_segnale("")
				tessera.imposta_alone(Color(0.0, 0.0, 0.0, 0.0))


## Segna sulla plancia le carte che il consigliere potrebbe potenziare con le risorse che ci sono:
## alone dorato e scritta "Potenzia" sopra la carta. Senza consigliere toglie i segnali.
func _mostra_potenziabili(consigliere: AdvisorDef) -> void:
	if run == null:
		return
	var potenziabili: Array[BoardPiece] = run.affordable_upgrades(consigliere)
	for coppia: Array in [[_truppe[Lato.GIOCATORE], run.board.troops], [_edifici[Lato.GIOCATORE], run.board.buildings]]:
		var tessere: Array = coppia[0]
		var pezzi: Array = coppia[1]
		for i: int in range(mini(tessere.size(), pezzi.size())):
			var tessera: Tessera3D = tessere[i]
			if not is_instance_valid(tessera):
				continue
			if potenziabili.has(pezzi[i]):
				var costo: ResourceAmounts = run.upgrade_cost_for(consigliere, pezzi[i])
				tessera.imposta_segnale("▲ POTENZIA\n%s" % costo.describe())
				tessera.imposta_alone(Color(StileVisivo.ORO_LUCE, 0.35))
			elif tessera.ha_segnale():
				# Si spegne solo l'alone messo dal segnale: la carta selezionata resta evidenziata.
				tessera.imposta_segnale("")
				tessera.imposta_alone(Color(0.0, 0.0, 0.0, 0.0))


## Sulle carte dei consiglieri del round: quante tue carte potrebbero potenziare adesso.
func _aggiorna_stato_consiglieri() -> void:
	if _tipo_scelta != TipoScelta.CONSIGLIERE:
		return
	for tessera: Tessera3D in _scelte:
		if not is_instance_valid(tessera) or tessera.indice < 0 or tessera.indice >= run.advisor_choices.size():
			continue
		var quante: int = run.affordable_upgrades(run.advisor_choices[tessera.indice]).size()
		# Le carte con i simboli lo mostrano già con la riga del Potenzia dorata e con
		# "Ascolta · ▲ Potenzia N" sotto la carta: la fascia coprirebbe i simboli.
		if not tessera.scheda.simboli.is_empty():
			tessera.imposta_stato("", StileVisivo.NOTTE)
		elif quante > 0:
			tessera.imposta_stato("▲ Potenzia pronto · %d %s" % [quante, "carta" if quante == 1 else "carte"], StileVisivo.ORO_LUCE)
		else:
			tessera.imposta_stato("", StileVisivo.NOTTE)


func _annulla() -> void:
	if _modo == Modo.SOSTITUZIONE:
		_modo = Modo.NORMALE
	_hud.nascondi_sostituzione()
	_hud.nascondi_pezzo()
	for tessera: Tessera3D in _truppe[Lato.GIOCATORE] + _edifici[Lato.GIOCATORE]:
		if is_instance_valid(tessera):
			tessera.imposta_alone(Color(0.0, 0.0, 0.0, 0.0))


## Sceglie la tecnologia da studiare fra le carte della mano (GDD §10.5.3).
func _on_scegli_tecnologia(indice: int) -> void:
	var carte: Array[TechDef] = run.tech_hand_cards()
	if indice < 0 or indice >= carte.size():
		return
	var scelta: TechDef = carte[indice]
	var gia_fatte: int = run.techs_done.size()
	var riuscita: bool = run.choose_tech(scelta)
	var messaggio: String = "Si studia: %s" % scelta.display_name
	if riuscita and run.techs_done.size() > gia_fatte:
		messaggio = "Tecnologia completata: %s" % scelta.display_name
	_esegui(riuscita, messaggio)


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
	if clic == null or not clic.pressed or _modo == Modo.SCONTRO or _hud.esito_visibile() or _hud.cronaca_visibile():
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
		TipoScelta.CONSIGLIERE:
			if i >= run.advisor_choices.size():
				_esegui(run.choose_event(), run.event_choice.display_name if run.event_choice != null else "")
				return
			var nome_consigliere: String = run.advisor_choices[i].display_name
			_esegui(run.choose_advisor(i), "Ascolti: %s" % nome_consigliere)
		TipoScelta.OPZIONE:
			var opzione: EventOptionDef = run.event_options()[i]
			var motivo: String = run.option_block_reason(opzione)
			if motivo != "":
				_hud.mostra_messaggio(motivo, true)
				return
			var voci_opzione: Array[String] = run.option_choices(opzione)
			if not voci_opzione.is_empty():
				_hud.mostra_scelte(opzione.label, opzione.description, voci_opzione, func(voce: int) -> void: _esegui(run.take_event_option(i, voce)))
			else:
				_esegui(run.take_event_option(i), opzione.label)
		TipoScelta.OFFERTA:
			var offerta: Offer = run.offers[i]
			var voci: Array[String] = run.offer_choices(offerta)
			if not voci.is_empty():
				_hud.mostra_scelte(offerta.describe(), offerta.description(), voci, func(voce: int) -> void: _esegui(run.buy_offer(i, voce)))
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
		TipoScelta.ASCENSIONE:
			var nome_ascensione: String = run.ascension_choices[i].display_name
			_esegui(run.choose_ascension(i), "Ascensione: %s" % nome_ascensione)
		TipoScelta.GOVERNO:
			if i < run.government_choices.size():
				var nome_governo: String = run.government_choices[i].display_name
				_esegui(run.choose_government(i), "Nuovo governo: %s" % nome_governo)
			else:
				_esegui(run.refuse_evolution(), "Il governo resta com'è")


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
	volo.tween_property(tessera, "scale", _plancia.scale, 0.3)
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
	var dettagli: String = tessera.scheda.dettagli
	if truppa:
		azioni.append({"testo": "◀ Sposta", "attiva": i > 0, "clic": func() -> void: _sposta(i, i - 1)})
		azioni.append({"testo": "Sposta ▶", "attiva": i < run.board.troops.size() - 1, "clic": func() -> void: _sposta(i, i + 1)})
	# Potenzia è un'opzione del consigliere scelto (GDD §6.5): se non si può, si dice perché (P4).
	if run.is_shopping_phase() and pezzo.level < run.run_rules.max_level:
		var motivo: String = run.upgrade_block_reason(pezzo)
		var costo: ResourceAmounts = run.upgrade_cost_of(pezzo)
		if motivo == "" and costo != null:
			azioni.append({"testo": "Potenzia · %s" % costo.describe(), "attiva": run.can_pay(costo), "clic": func() -> void: _potenzia(truppa, i)})
		else:
			# Il motivo va nel testo, non sul pulsante: una frase lunga allargava il pannello.
			azioni.append({"testo": "Potenzia", "attiva": false, "clic": func() -> void: pass})
			dettagli += "\nPotenzia non disponibile: %s" % motivo
	if pezzo.building == null or not pezzo.building.is_capital:
		var vendibile: bool = truppa or run.board.can_sell_building(i)
		azioni.append({"testo": "Vendi · +%d Oro" % RunState.half_down(pezzo.paid), "attiva": vendibile, "clic": func() -> void: _vendi(truppa, i)})
	_hud.mostra_pezzo(tessera.scheda.titolo, dettagli, azioni)


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
	var edifici_avversari: Array[SchedaCarta] = []
	for def: BuildingDef in _setups[1].buildings:
		edifici_avversari.append(SchedaCarta.da_edificio(def))
	var truppe_avversarie: Array[SchedaCarta] = []
	for def: TroopDef in _setups[1].troops:
		truppe_avversarie.append(SchedaCarta.da_truppa(def))
	# Nello scontro si vedono solo gli elementi schierati; i due lati hanno la stessa scala.
	var larghezza: float = maxf(_larghezza_per(truppe.size(), edifici.size()), _larghezza_per(truppe_avversarie.size(), edifici_avversari.size()))
	var scala: float = _scala_per(larghezza, SCALA_MASSIMA_SCONTRO)
	_costruisci_lato(Lato.GIOCATORE, edifici, truppe, edifici.size(), truppe.size(), false, scala)
	_costruisci_lato(Lato.AVVERSARIO, edifici_avversari, truppe_avversarie, 0, 0, false, scala)
	_disponi_plancia(scala, larghezza, true, 0.7)
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
			BattleEvent.Kind.ULTIMA_TRINCEA:
				_scritta_volante(evento.side, "Ultima trincea!", StileVisivo.ORO_LUCE)
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
		_aggiorna_anello(lato, _sim.elapsed_ms)
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
			elif _trascurata(lato, false, i):
				edificio.imposta_stato("Trascurato: mantenimento non pagato", Color("e08a2e"))
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
			elif stato == BattleSim.TroopState.MANA_PRENOTATO:
				tessera.imposta_ricarica(1.0)
				tessera.imposta_stato("Aspetta: il mana è prenotato dalla truppa più a destra", Color("e08a2e"))
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
				elif _trascurata(lato, true, i):
					tessera.imposta_stato("Trascurata: mantenimento non pagato", Color("e08a2e"))
				else:
					tessera.imposta_stato("", StileVisivo.NOTTE)


## Carta del giocatore che in questo scontro lavora più piano perché non è stata pagata (GDD §5.6).
func _trascurata(lato: int, truppa: bool, i: int) -> bool:
	if lato != Lato.GIOCATORE or run == null:
		return false
	var fila: Array[BoardPiece] = run.board.troops if truppa else run.board.buildings
	return i >= 0 and i < fila.size() and fila[i].neglected


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
	# La plancia torna com'è fuori dagli scontri: niente riserva di mana, Scudo o Corruzione.
	for lato: int in [Lato.GIOCATORE, Lato.AVVERSARIO]:
		_aggiorna_anello(lato, 0)
		_riserve[lato].visible = false
		_segnalini_scudo[lato].visible = false
		_segnalini_corruzione[lato].visible = false
		for i: int in range(_lampi[lato].size()):
			_lampi[lato][i] = 0.0
	var avversario: Node3D = _radici[Lato.AVVERSARIO]
	var uscita: Tween = create_tween()
	uscita.set_parallel(true)
	uscita.tween_property(avversario, "position", Vector3(0.0, 0.0, -14.0), 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	uscita.tween_method(_muovi_camera.bind(_camera.global_position, CAMERA_PARTITA, MIRA_SCONTRO, MIRA_PARTITA), 0.0, 1.0, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	uscita.chain().tween_callback(avversario.hide)
	_aggiorna_tutto()


# --- Mouse ---------------------------------------------------------------------

## Dove sta sullo schermo una carta ingrandita di "fattore": il rettangolo dei suoi quattro angoli.
func _rettangolo_sullo_schermo(tessera: Tessera3D, fattore: float) -> Rect2:
	var mezza: Vector2 = Vector2(tessera.larghezza, tessera.profondita) * 0.5 * fattore
	var angoli: Array[Vector2] = [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]
	var rettangolo: Rect2 = Rect2()
	for i: int in range(angoli.size()):
		var punto: Vector2 = _camera.unproject_position(tessera.to_global(Vector3(mezza.x * angoli[i].x, 0.0, mezza.y * angoli[i].y)))
		rettangolo = Rect2(punto, Vector2.ZERO) if i == 0 else rettangolo.expand(punto)
	return rettangolo


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
		# Mouse su una carta che dà un bonus a un tipo: si accendono le tue carte che ne beneficiano.
		# Mouse su un consigliere: si accendono le carte che potrebbe potenziare (P4).
		var beneficiari: Array[BoardPiece] = _beneficiari_sotto(tessera)
		if not beneficiari.is_empty():
			_mostra_beneficiari(beneficiari)
		else:
			_mostra_potenziabili(_consigliere_sotto(tessera) if _consigliere_sotto(tessera) != null else run.chosen_advisor)
	if tessera != null and not _hud.esito_visibile() and not _hud.cronaca_visibile():
		var scheda: SchedaCarta = tessera.scheda
		var titolo: String = scheda.titolo
		if scheda.sopratitolo != "" and scheda.sopratitolo != scheda.titolo:
			titolo = "%s · %s" % [scheda.sopratitolo, scheda.titolo]
		var testo: String = scheda.dettagli
		var beneficiari_testo: Array[BoardPiece] = _beneficiari_sotto(tessera)
		if not beneficiari_testo.is_empty():
			var nomi: PackedStringArray = PackedStringArray()
			for pezzo: BoardPiece in beneficiari_testo:
				nomi.append(pezzo.display_name())
			testo += "\n▲ Ne beneficiano: %s." % ", ".join(nomi)
		if scheda.costo != "":
			testo += "\nCosto: %s%s" % [scheda.costo, "" if scheda.disponibile else " (non basta)"]
		# Le carte che si ingrandiscono molto (con i simboli) non vanno coperte dal testo.
		var carta: Rect2 = Rect2()
		if tessera.ingrandimento > 1.2:
			carta = _rettangolo_sullo_schermo(tessera, tessera.ingrandimento)
		_hud.mostra_suggerimento(titolo, testo, mouse, carta)
	else:
		_hud.nascondi_suggerimento()
