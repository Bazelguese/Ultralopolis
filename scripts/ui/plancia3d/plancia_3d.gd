extends Node3D
## La partita sulla plancia 3D (GDD §14.2): tavolo, plancia della nazione, offerte,
## incontri, ricompense, scontri ed esito dell'anno.
## Solo presentazione: lo stato e le regole sono tutti in RunState e BattleSim.
## La scena legge lo stato, chiama le azioni di RunState e rigioca gli scontri
## passo per passo dalla simulazione (il tempo reale decide solo il ritmo di visione).

enum Lato { GIOCATORE, AVVERSARIO }
enum Modo { NORMALE, SOSTITUZIONE, SCONTRO }
enum TipoScelta { NESSUNA, OFFERTA, INCONTRO, RICOMPENSA, FANTASMA, VIA, CONSIGLIERE, OPZIONE, GOVERNO, ASCENSIONE }

## Misure delle tessere (Davide, 8 novembre 2026): edifici orizzontali 3:2, tutto il resto
## verticale 2:3. Le illustrazioni hanno le stesse proporzioni (768 × 512 e 512 × 768).
const PASSO_TRUPPE: float = 1.62
const PASSO_EDIFICI: float = 2.3
const MISURA_TRUPPA: Vector2 = Vector2(1.44, 2.16)
const MISURA_EDIFICIO: Vector2 = Vector2(2.13, 1.42)
## Le proposte del Consiglio sono più larghe, così la linguetta dei tipi sta dentro la carta (Davide).
const MISURA_AZIONE: Vector2 = Vector2(1.8, 2.7)
const SCALA_SCELTA: float = 1.3
## Le scelte con le righe di simboli si ingrandiscono così tanto al passaggio del mouse.
const INGRANDIMENTO_SIMBOLI: float = 1.7
const Z_TRUPPE: float = 1.75
## Teatro di carta: fra truppe ed edifici c'è posto per le figurine, che non coprono le carte dietro.
const Z_EDIFICI: float = 4.85
## Il cuore della nazione al centro della plancia (Davide, 9 novembre 2026): due placche, una per
## fila, con lo stendardo sulla fila delle truppe e la riserva di mana su quella degli edifici. Le
## file si dividono in due metà ai suoi lati; l'ordine resta quello di sempre, da sinistra a destra,
## e un pezzo nuovo arriva in fondo a destra (GDD §7.3).
const MEZZO_CUORE: float = 0.95
## Spazio fra il bordo del cuore e lo spazio della prima carta di ogni lato.
const STACCO_CUORE: float = 0.25
## Quota della faccia delle placche del cuore (la lastra arriva a 0.02).
const ALTEZZA_CUORE: float = 0.16
## Profondità della placca del mana: contiene la croce delle sfere.
const PROFONDITA_PLACCA_MANA: float = 2.4
const SCALA_RISERVA: float = 0.8
const OTTONE: Color = Color("c79a4a")
## Margine fra le carte più esterne e il bordo della lastra.
const MARGINE_LASTRA: float = 0.35
## Larghezza della lastra con tutti gli spazi: la plancia si ingrandisce quando è più corta.
const LARGHEZZA_LASTRA_PIENA: float = 24.35
## Con gli spazi vuoti stretti la plancia è più corta e le carte si ingrandiscono di più.
const SCALA_MASSIMA: float = 1.15
## Larghezza di uno spazio vuoto (LIBERO o DA CONQUISTARE): una sagoma stretta, non una carta.
const PASSO_SPAZIO_VUOTO: float = 0.85
const SCALA_MASSIMA_SCONTRO: float = 1.3
## La plancia piena si rimpicciolisce fino a questa scala per stare nello schermo.
const SCALA_MINIMA: float = 0.6
## Quanto torri, punte e merli sporgono in tutto oltre le carte più esterne.
const MARGINE_FORMA: float = 1.6
const DURATA_DISPOSIZIONE: float = 0.45
const SPAZI_TRUPPE: int = 12
const SPAZI_EDIFICI: int = 10
const COLORI_RISERVA: Array[StringName] = [&"rosso", &"verde", &"blu", &"viola", &"energetico"]
## Oltre questo numero di gemme in volo non se ne lanciano altre (solo effetto visivo).
const MASSIMO_GEMME_IN_VOLO: int = 24

## Altezza del telo dello stendardo della nazione.
const ALTEZZA_STENDARDO: float = 1.9
## Altezza delle figurine rispetto alla larghezza della carta: gli edifici più bassi, così le file
## stanno vicine senza che le loro figurine coprano i numeri delle truppe.
const ALTEZZA_FIGURINA_TRUPPA: float = 1.1
const ALTEZZA_FIGURINA_EDIFICIO: float = 0.7
## Larghezza del telo dello stendardo e altezza da cui parte (più in basso: Davide, 8 novembre 2026).
const LARGHEZZA_STENDARDO: float = 1.5
const BASE_TELO: float = 0.45
## L'asta dello stendardo, che fa anche da timer dello scontro.
const ALTEZZA_ASTA: float = ALTEZZA_STENDARDO + BASE_TELO + 0.1
const X_ASTA: float = -LARGHEZZA_STENDARDO * 0.5 - 0.05
## Lo stendardo steso: la base sta verso il davanti della placca, il telo si stende all'indietro
## (così il telo steso sta al centro della placca delle truppe).
const POSIZIONE_STESO_Z: float = 0.26
## In piedi, la base dello stendardo sta un po' verso il davanti della placca delle truppe.
const AVANTI_STENDARDO: float = 0.55
## Teatro di carta: il tavolo (x, z, larghezza, profondità) e il sole/luna.
const LIBRO: Rect2 = Rect2(-45.0, -35.0, 90.0, 70.0)
const POSIZIONE_ASTRO: Vector3 = Vector3(5.5, 0.0, -9.0)

const FOV_TELECAMERA: float = 30.0
const CAMERA_PARTITA: Vector3 = Vector3(-0.4, 21.5, 20.0)
const MIRA_PARTITA: Vector3 = Vector3(-0.4, 0.0, -0.2)
## Spostamento a destra della plancia, per lasciare spazio alla colonna di sinistra.
const SPOSTAMENTO_PLANCIA: float = 0.0
## Teatro di carta: nello scontro la telecamera scende, così le figurine si vedono in piedi.
const CAMERA_SCONTRO: Vector3 = Vector3(-0.4, 24.0, 23.0)
const MIRA_SCONTRO: Vector3 = Vector3(-0.4, 0.0, 1.2)
## Profondità del tavolo inquadrata nello scontro: se le plance si allontanano (forma «arco»)
## la telecamera si allarga in proporzione.
const PROFONDITA_SCONTRO: float = 13.0

var run: RunState

var _camera: Camera3D
## Teatro di carta: luci, tempo atmosferico e calendario (solo scenografia).
var _scena: ScenaTeatro
## La prima volta di una partita la scena si imposta senza animazioni.
var _scena_subito: bool = true
var _hud: HudPlancia
## Contiene i due lati: si ingrandisce e si centra in base a quanti spazi si vedono.
var _plancia: Node3D
var _radici: Array[Node3D] = [null, null]
## La plancia sagomata di ogni lato (forma del popolo o dell'incontro).
var _forme: Array[FormaPlancia] = [null, null]
## Larghezza di ogni plancia, da cui dipende quanto ingrandirla.
var _larghezze: Array[float] = [LARGHEZZA_LASTRA_PIENA, LARGHEZZA_LASTRA_PIENA]
## Inquadratura dello scontro in corso (si allarga se le plance si allontanano).
var _camera_scontro: Vector3 = CAMERA_SCONTRO
var _mira_scontro: Vector3 = MIRA_SCONTRO
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
var _materiale_anello_acceso: StandardMaterial3D
var _materiale_anello_logoramento: StandardMaterial3D
## La brace in testa alla miccia del tempo e le parti dello stendardo che spariscono quando è steso.
var _braci_miccia: Array[MeshInstance3D] = [null, null]
var _aste_stendardo: Array[Array] = [[], []]
const SEGMENTI_ANELLO: int = 48
var _barre_resistenza: Array[MeshInstance3D] = [null, null]
## Teatro di carta: lo stendardo di ogni lato (materiale del telo e numero della Resistenza).
var _teli_stendardo: Array[ShaderMaterial] = [null, null]
var _stendardi: Array[Node3D] = [null, null]
## Nome e barra della Resistenza accanto allo stendardo: si vedono solo negli scontri.
var _dati_scontro: Array[Node3D] = [null, null]
var _numeri_stendardo: Array[Label3D] = [null, null]
## Scudo e Corruzione accanto allo stemma (GDD §7.6), visibili solo se non sono zero.
var _segnalini_scudo: Array[Node3D] = [null, null]
var _scritte_scudo: Array[Label3D] = [null, null]
var _segnalini_corruzione: Array[Node3D] = [null, null]
var _scritte_corruzione: Array[Label3D] = [null, null]
var _nomi_lato: Array[Label3D] = [null, null]
var _riserve: Array[Node3D] = [null, null]  # RiservaMana
## Posizioni x degli spazi delle due file di ogni lato (pezzi e spazi vuoti), attorno al cuore.
var _xs_truppe: Array[Array] = [[], []]
var _xs_edifici: Array[Array] = [[], []]

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
## Teatro di carta: quante carte di ogni elemento c'erano nell'ultima costruzione di un lato.
## Solo le figurine dei pezzi nuovi si alzano con l'animazione pop-up.
var _gia_viste: Array[Dictionary] = [{}, {}]


func _ready() -> void:
	_crea_ambiente()
	_plancia = Node3D.new()
	add_child(_plancia)
	for lato: int in [Lato.GIOCATORE, Lato.AVVERSARIO]:
		_crea_lato(lato)
	_contenitore_scelte = Node3D.new()
	add_child(_contenitore_scelte)
	_crea_atmosfera()
	_crea_grana()
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
	_hud.rinnova.connect(func() -> void: _esegui(run.reroll_offers(), "Opportunità rinnovate"))
	_hud.rinnova_risorsa.connect(func() -> void: _esegui(run.reroll_offers(true), "Opportunità rinnovate"))
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
	_scena_subito = true
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
	# Teatro di carta: luci del momento del giorno, tempo atmosferico, pagina del tavolo,
	# sole/luna e calendario pop-up (solo scenografia).
	_scena = ScenaTeatro.new()
	add_child(_scena)
	_scena.costruisci(LIBRO, POSIZIONE_ASTRO)
	_camera = Camera3D.new()
	_camera.fov = FOV_TELECAMERA
	add_child(_camera)


## Grana da stampa e vignetta sopra la scena 3D, sotto l'interfaccia (che resta nitida).
func _crea_grana() -> void:
	var strato: CanvasLayer = CanvasLayer.new()
	strato.layer = 0
	add_child(strato)
	var velo: ColorRect = ColorRect.new()
	velo.set_anchors_preset(Control.PRESET_FULL_RECT)
	velo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader: Shader = Shader.new()
	shader.code = """
shader_type canvas_item;
uniform float forza = 0.045;
float caso(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
void fragment() {
	float n = caso(floor(FRAGCOORD.xy) + floor(TIME * 24.0) * vec2(17.0, 31.0));
	float v = smoothstep(0.38, 0.95, length((SCREEN_UV - 0.5) * vec2(1.25, 1.0)));
	COLOR = mix(vec4(vec3(n), forza), vec4(0.0, 0.0, 0.0, 0.85), v);
}
"""
	var materiale: ShaderMaterial = ShaderMaterial.new()
	materiale.shader = shader
	velo.material = materiale
	strato.add_child(velo)


## Pulviscolo luminoso che fluttua sopra il tavolo (solo atmosfera).
func _crea_atmosfera() -> void:
	var polvere: CPUParticles3D = CPUParticles3D.new()
	var granello: SphereMesh = SphereMesh.new()
	granello.radius = 0.018
	granello.height = 0.036
	var materiale: StandardMaterial3D = StileVisivo.materiale_velo(Color(StileVisivo.BRACE, 0.4))
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


## Parti fisse di un lato: plancia sagomata, cuore con lo stendardo e la riserva di mana.
## Il lato avversario è specchiato: truppe verso il centro, edifici dietro.
func _crea_lato(lato: int) -> void:
	var radice: Node3D = Node3D.new()
	_plancia.add_child(radice)
	_radici[lato] = radice
	var z_centro: float = (Z_TRUPPE + Z_EDIFICI) * 0.5 * _segno(lato)
	var forma: FormaPlancia = FormaPlancia.new()
	radice.add_child(forma)
	forma.costruisci(&"", _segno(lato), Z_TRUPPE, Z_EDIFICI, MEZZO_CUORE, lato == Lato.AVVERSARIO)
	_forme[lato] = forma
	_crea_cuore(radice, lato)
	_crea_medaglione(radice, lato, z_centro)
	_crea_riserva(radice, lato, z_centro)
	_pezzi[lato] = Node3D.new()
	radice.add_child(_pezzi[lato])
	var mezza: float = LARGHEZZA_LASTRA_PIENA * 0.5 - MARGINE_LASTRA
	forma.imposta(Vector4(mezza, mezza, mezza, mezza))


## Larghezze degli spazi di una fila, da sinistra a destra: prima i pezzi, poi gli spazi vuoti,
## che sono sagome strette (Davide, 8 novembre 2026).
static func _larghezze_fila(spazi: int, occupati: int, passo: float) -> Array[float]:
	var larghezze: Array[float] = []
	for i: int in range(spazi):
		larghezze.append(passo if i < occupati else PASSO_SPAZIO_VUOTO)
	return larghezze


## Posizioni (x) degli spazi di una fila attorno al cuore. La fila resta una sola, nell'ordine di
## sempre da sinistra a destra; il cuore la taglia nel punto che rende le due metà più uguali
## (a parità, la metà di sinistra è la più corta). Quando arriva un pezzo in fondo a destra le metà
## si ribilanciano e un pezzo può passare dall'altra parte del cuore.
static func _posizioni_fila(larghezze: Array[float]) -> Array[float]:
	var totale: float = 0.0
	for larghezza: float in larghezze:
		totale += larghezza
	var taglio: int = 0
	var migliore: float = INF
	var sinistra: float = 0.0
	for k: int in range(larghezze.size() + 1):
		if k > 0:
			sinistra += larghezze[k - 1]
		var differenza: float = absf(sinistra - (totale - sinistra))
		if differenza < migliore - 0.001:
			migliore = differenza
			taglio = k
	var xs: Array[float] = []
	xs.resize(larghezze.size())
	var x: float = -(MEZZO_CUORE + STACCO_CUORE)
	for i: int in range(taglio - 1, -1, -1):
		xs[i] = x - larghezze[i] * 0.5
		x -= larghezze[i]
	x = MEZZO_CUORE + STACCO_CUORE
	for i: int in range(taglio, larghezze.size()):
		xs[i] = x + larghezze[i] * 0.5
		x += larghezze[i]
	return xs


## Quanto una fila si allunga dal centro verso il lato più lungo.
static func _mezza_fila(larghezze: Array[float]) -> float:
	var xs: Array[float] = _posizioni_fila(larghezze)
	var mezza: float = MEZZO_CUORE + STACCO_CUORE
	for i: int in range(xs.size()):
		mezza = maxf(mezza, absf(xs[i]) + larghezze[i] * 0.5)
	return mezza


## Larghezza della lastra che contiene tanti spazi, simmetrica attorno al cuore (almeno un edificio
## per lato, per non farla troppo corta). Senza il numero dei pezzi, tutti gli spazi contano come occupati.
func _larghezza_per(spazi_truppe: int, spazi_edifici: int, truppe_occupate: int = -1, edifici_occupati: int = -1) -> float:
	var piene_t: int = spazi_truppe if truppe_occupate < 0 else mini(truppe_occupate, spazi_truppe)
	var piene_e: int = spazi_edifici if edifici_occupati < 0 else mini(edifici_occupati, spazi_edifici)
	var mezza: float = maxf(_mezza_fila(_larghezze_fila(spazi_truppe, piene_t, PASSO_TRUPPE)), _mezza_fila(_larghezze_fila(spazi_edifici, piene_e, PASSO_EDIFICI)))
	mezza = maxf(mezza, MEZZO_CUORE + STACCO_CUORE + PASSO_EDIFICI)
	return (mezza + MARGINE_LASTRA) * 2.0


## Quanto ingrandire la plancia perché la lastra più larga riempia lo spazio di una plancia piena.
## Quando la plancia è più larga dello schermo (plancia piena) si rimpicciolisce fino a starci
## (prima restava a 1 e la fila degli edifici usciva dai lati). Le torri e le punte delle forme
## sporgono oltre le carte: se ne tiene conto con un margine.
func _scala_per(larghezza: float, massima: float) -> float:
	return clampf(LARGHEZZA_LASTRA_PIENA / maxf(larghezza + MARGINE_FORMA, 1.0), SCALA_MINIMA, massima)


## Ingrandisce e centra la plancia. In partita la lastra del giocatore cresce attorno al suo centro,
## un po' spostata verso l'alto per non coprire i comandi; in uno scontro i due lati restano
## simmetrici rispetto al centro del tavolo.
func _disponi_plancia(scala: float, _larghezza: float, scontro: bool, durata: float) -> void:
	var z_centro: float = (Z_TRUPPE + Z_EDIFICI) * 0.5
	# La plancia sta più in basso (Davide, 9 novembre 2026): i comandi del round sono in alto a destra.
	var z: float = 0.0 if scontro else z_centro * (1.0 - scala) - (scala - 1.0) * 2.0 + 0.85
	# La lastra è centrata sul cuore della nazione: il cuore sta al centro dello schermo.
	var posizione: Vector3 = Vector3(MIRA_PARTITA.x + SPOSTAMENTO_PLANCIA, 0.0, z)
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


## Il cuore della nazione: due placche dagli angoli smussati, una per fila, unite da due barrette
## d'ottone. Ogni placca ha la base di cartone scuro, il profilo d'ottone e il pannello del colore
## del lato con un filetto d'ottone inciso. Lo stendardo e la riserva di mana ci stanno sopra.
func _crea_cuore(radice: Node3D, lato: int) -> void:
	var cuore: Node3D = Node3D.new()
	radice.add_child(cuore)
	var segno: float = _segno(lato)
	var larghezza: float = MEZZO_CUORE * 2.0
	var misure: Array[Vector2] = [Vector2(larghezza, MISURA_TRUPPA.y + 0.1), Vector2(larghezza, PROFONDITA_PLACCA_MANA)]
	var zs: Array[float] = [Z_TRUPPE * segno, Z_EDIFICI * segno]
	var base: StandardMaterial3D = ScenaTeatro.materiale_carta(StileVisivo.CARTONCINO, 1.5)
	var ottone: StandardMaterial3D = StileVisivo.materiale(OTTONE, 0.3, 0.85)
	var filetto: StandardMaterial3D = StileVisivo.materiale(OTTONE.darkened(0.15), 0.35, 0.8)
	var pannello: StandardMaterial3D = ScenaTeatro.materiale_carta(_colore_lato(lato).darkened(0.68), 2.0)
	# Strati dal basso: [margine rispetto alla placca, smusso, quota della faccia, materiale].
	var strati: Array = [[-0.05, 0.34, ALTEZZA_CUORE - 0.06, base], [0.02, 0.3, ALTEZZA_CUORE - 0.01, ottone],
		[0.1, 0.24, ALTEZZA_CUORE, pannello], [0.17, 0.18, ALTEZZA_CUORE + 0.004, filetto], [0.2, 0.15, ALTEZZA_CUORE + 0.008, pannello]]
	for k: int in range(2):
		for strato: Array in strati:
			var rientro: float = float(strato[0])
			_crea_placca(cuore, Vector3(0.0, float(strato[2]), zs[k]), misure[k] - Vector2(rientro, rientro) * 2.0, float(strato[1]), float(strato[2]), strato[3])
	# Le due barrette che uniscono le placche.
	var z0: float = zs[0] + misure[0].y * 0.5 * segno
	var z1: float = zs[1] - misure[1].y * 0.5 * segno
	for x: float in [-0.18, 0.18]:
		var barra: MeshInstance3D = MeshInstance3D.new()
		var forma: CylinderMesh = CylinderMesh.new()
		forma.top_radius = 0.045
		forma.bottom_radius = 0.045
		forma.height = absf(z1 - z0) + 0.2
		forma.radial_segments = 12
		barra.mesh = forma
		barra.material_override = ottone
		barra.rotation.x = PI * 0.5
		barra.position = Vector3(x, 0.08, (z0 + z1) * 0.5)
		cuore.add_child(barra)


## Una placca a otto lati (angoli smussati) con la faccia a quota "cima", spessa fino alla lastra.
func _crea_placca(genitore: Node3D, centro: Vector3, misura: Vector2, smusso: float, cima: float, materiale: Material) -> void:
	var w: float = misura.x * 0.5
	var d: float = misura.y * 0.5
	var forma: CSGPolygon3D = CSGPolygon3D.new()
	forma.polygon = PackedVector2Array([Vector2(-w + smusso, -d), Vector2(w - smusso, -d), Vector2(w, -d + smusso), Vector2(w, d - smusso),
		Vector2(w - smusso, d), Vector2(-w + smusso, d), Vector2(-w, d - smusso), Vector2(-w, -d + smusso)])
	# Il poligono si estrude lungo z; ruotato, la faccia guarda in alto e lo spessore scende alla lastra.
	forma.depth = maxf(cima, 0.02)
	forma.material = materiale
	forma.rotation.x = -PI * 0.5
	forma.position = centro
	genitore.add_child(forma)


func _crea_medaglione(radice: Node3D, lato: int, z_centro: float) -> void:
	var colore: Color = _colore_lato(lato)
	var medaglione: Node3D = Node3D.new()
	# Lo stendardo sta sulla placca delle truppe del cuore.
	medaglione.position = Vector3(0.0, ALTEZZA_CUORE, (Z_TRUPPE + AVANTI_STENDARDO * _segno(lato)) * _segno(lato))
	medaglione.set_meta("base", medaglione.position)
	radice.add_child(medaglione)
	_medaglioni[lato] = medaglione
	# Teatro di carta (Davide, 8 novembre 2026): lo stendardo di carta della nazione. Fuori dagli
	# scontri sta steso piatto sulla plancia; quando comincia la battaglia si alza in piedi.
	var stendardo: Node3D = Node3D.new()
	medaglione.add_child(stendardo)
	_stendardi[lato] = stendardo
	# Porta le iniziali e la Resistenza, e brucia dal basso man mano che la Resistenza scende.
	var asta: MeshInstance3D = MeshInstance3D.new()
	var forma_asta: CylinderMesh = CylinderMesh.new()
	forma_asta.top_radius = 0.05
	forma_asta.bottom_radius = 0.07
	forma_asta.height = ALTEZZA_ASTA
	asta.mesh = forma_asta
	asta.material_override = StileVisivo.materiale(Color("1a1410"), 0.8)
	asta.position = Vector3(X_ASTA, forma_asta.height * 0.5, 0.0)
	stendardo.add_child(asta)
	var punta: MeshInstance3D = MeshInstance3D.new()
	var forma_punta: SphereMesh = SphereMesh.new()
	forma_punta.radius = 0.11
	forma_punta.height = 0.22
	punta.mesh = forma_punta
	punta.material_override = StileVisivo.materiale_metallo(StileVisivo.ORO)
	punta.position = Vector3(X_ASTA, forma_asta.height + 0.05, 0.0)
	stendardo.add_child(punta)
	_aste_stendardo[lato] = [asta, punta]
	var telo: MeshInstance3D = MeshInstance3D.new()
	var forma_telo: QuadMesh = QuadMesh.new()
	forma_telo.size = Vector2(LARGHEZZA_STENDARDO, ALTEZZA_STENDARDO)
	telo.mesh = forma_telo
	var materiale_telo: ShaderMaterial = Figurina.materiale_carta(_trama_stendardo(colore))
	materiale_telo.set_shader_parameter("dai_bordi", true)
	telo.material_override = materiale_telo
	telo.position = Vector3(0.0, BASE_TELO + ALTEZZA_STENDARDO * 0.5, 0.0)
	stendardo.add_child(telo)
	_teli_stendardo[lato] = materiale_telo
	# Al centro dello stendardo le iniziali della nazione, come lo stemma di un eroe.
	var iniziali: Label3D = StileVisivo.scritta("", StileVisivo.FONT_TITOLI, 112, Color("1a1410"), 0.0, 0)
	iniziali.position = Vector3(0.0, BASE_TELO + ALTEZZA_STENDARDO * 0.68, 0.02)
	iniziali.rotation = Vector3.ZERO
	stendardo.add_child(iniziali)
	_iniziali[lato] = iniziali
	var numero_telo: Label3D = StileVisivo.scritta("", StileVisivo.FONT_TITOLI, 140, Color("1a1410"), 0.0, 0)
	numero_telo.position = Vector3(0.0, BASE_TELO + ALTEZZA_STENDARDO * 0.36, 0.02)
	numero_telo.rotation = Vector3.ZERO
	stendardo.add_child(numero_telo)
	_numeri_stendardo[lato] = numero_telo
	_crea_anello(medaglione, lato)
	var nome: Label3D = StileVisivo.scritta("", StileVisivo.FONT_TITOLI, 40, StileVisivo.TESTO, 0.0, 8)
	nome.position = Vector3(0.0, 0.04, z_centro + 0.12)
	# Nome e barra della Resistenza servono nello scontro; fuori basta lo stendardo steso.
	var dati: Node3D = Node3D.new()
	radice.add_child(dati)
	_dati_scontro[lato] = dati
	dati.add_child(nome)
	_nomi_lato[lato] = nome
	# Sotto il nome la barra della Resistenza con i numeri sopra, come la vita di un eroe.
	var fondo_barra: MeshInstance3D = MeshInstance3D.new()
	var forma_fondo: BoxMesh = BoxMesh.new()
	forma_fondo.size = Vector3(1.95, 0.04, 0.4)
	fondo_barra.mesh = forma_fondo
	fondo_barra.material_override = StileVisivo.materiale(StileVisivo.NOTTE, 0.9)
	fondo_barra.position = Vector3(0.0, 0.04, z_centro + 0.58)
	dati.add_child(fondo_barra)
	var barra: MeshInstance3D = MeshInstance3D.new()
	var forma_barra: BoxMesh = BoxMesh.new()
	forma_barra.size = Vector3(1.85, 0.05, 0.32)
	barra.mesh = forma_barra
	barra.material_override = StileVisivo.materiale_luminoso(Color("3fae6a"), 0.7)
	barra.position = fondo_barra.position + Vector3(0.0, 0.01, 0.0)
	dati.add_child(barra)
	_barre_resistenza[lato] = barra
	var numero: Label3D = StileVisivo.scritta("0", StileVisivo.FONT_TITOLI, 60, Color.WHITE, 0.0, 12)
	numero.position = fondo_barra.position + Vector3(0.0, 0.06, 0.0)
	dati.add_child(numero)
	_scritte_resistenza[lato] = numero
	# Scudo e Corruzione (GDD §7.6) sono distintivi appuntati sul bordo destro dello stendardo,
	# così si alzano con lui negli scontri.
	var stendardo_scudo: Node3D = _stendardi[lato]
	var bordo_destro: float = LARGHEZZA_STENDARDO * 0.5 + 0.02
	var scudo: Array = _crea_segnalino(stendardo_scudo, Vector3(bordo_destro, BASE_TELO + ALTEZZA_STENDARDO * 0.78, 0.05), Color("2f6fd0"), &"scudo")
	_segnalini_scudo[lato] = scudo[0]
	_scritte_scudo[lato] = scudo[1]
	var corruzione: Array = _crea_segnalino(stendardo_scudo, Vector3(bordo_destro, BASE_TELO + ALTEZZA_STENDARDO * 0.42, 0.05), StileVisivo.COLORE_CORRUZIONE, &"corruzione")
	_segnalini_corruzione[lato] = corruzione[0]
	_scritte_corruzione[lato] = corruzione[1]


## Piccolo disco con un numero accanto allo stemma. Restituisce [nodo, scritta].
	_stendi_stendardo(lato, true, false)


func _crea_segnalino(genitore: Node3D, posizione: Vector3, colore: Color, simbolo: StringName) -> Array:
	var nodo: Node3D = Node3D.new()
	nodo.position = posizione
	genitore.add_child(nodo)
	# Un distintivo di carta: bordo crema, tondo del colore dell'effetto, simbolo e numero.
	for strato: Array in [[0.33, StileVisivo.CARTA_CREMA, 0.0], [0.28, colore.darkened(0.15), 0.012]]:
		var disco: MeshInstance3D = MeshInstance3D.new()
		var forma: CylinderMesh = CylinderMesh.new()
		forma.top_radius = float(strato[0])
		forma.bottom_radius = float(strato[0])
		forma.height = 0.02
		forma.radial_segments = 24
		disco.mesh = forma
		disco.material_override = StileVisivo.materiale(strato[1], 0.85)
		disco.rotation.x = PI * 0.5
		disco.position.z = float(strato[2])
		nodo.add_child(disco)
	var icona: Sprite3D = Sprite3D.new()
	icona.texture = Simboli.trama(simbolo, 64.0)
	icona.pixel_size = 0.26 / 64.0
	icona.position = Vector3(-0.1, 0.0, 0.03)
	icona.modulate = Color.WHITE
	icona.shaded = false
	nodo.add_child(icona)
	var scritta: Label3D = StileVisivo.scritta("0", StileVisivo.FONT_TITOLI, 58, Color.WHITE, 0.0, 8)
	scritta.rotation = Vector3.ZERO
	scritta.outline_modulate = colore.darkened(0.6)
	scritta.position = Vector3(0.1, 0.0, 0.035)
	nodo.add_child(scritta)
	nodo.visible = false
	return [nodo, scritta]


## Un distintivo cambia valore: piccolo salto, così si vede che lo scudo assorbe o la Corruzione sale.
func _scuoti_segnalino(nodo: Node3D) -> void:
	var t: Tween = create_tween()
	t.tween_property(nodo, "scale", Vector3.ONE * 1.35, 0.06)
	t.tween_property(nodo, "scale", Vector3.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## La riserva di mana sulla placca degli edifici del cuore: una sfera per colore (Davide, 9 novembre
## 2026). Resta sempre in vista; fuori dagli scontri le sfere sono vuote e spente.
func _crea_riserva(radice: Node3D, lato: int, _z_centro: float) -> void:
	var riserva: RiservaMana = RiservaMana.new()
	riserva.position = Vector3(0.0, ALTEZZA_CUORE - 0.02, Z_EDIFICI * _segno(lato))
	riserva.scale = Vector3.ONE * SCALA_RISERVA
	radice.add_child(riserva)
	riserva.costruisci()
	_riserve[lato] = riserva


func _aggiorna_medaglione(lato: int, resistenza: int, massimo: int) -> void:
	_scritte_resistenza[lato].text = "%d / %d" % [maxi(resistenza, 0), maxi(massimo, 0)]
	_iniziali[lato].text = _iniziali_di(_nomi_lato[lato].text)
	var frazione: float = clampf(float(resistenza) / float(maxi(massimo, 1)), 0.0, 1.0)
	_numeri_stendardo[lato].text = str(maxi(resistenza, 0))
	# Lo stendardo brucia fino a metà; a zero brucia del tutto (a fine scontro).
	# Brucia dai bordi fino a lasciare intatto il centro, dove ci sono iniziali e Resistenza.
	_teli_stendardo[lato].set_shader_parameter("bruciatura", 0.0 if frazione >= 1.0 else 0.06 + 0.3 * (1.0 - frazione))
	var barra: MeshInstance3D = _barre_resistenza[lato]
	barra.scale.x = maxf(frazione, 0.001)
	barra.position.x = -0.925 * (1.0 - frazione)
	# Verde, poi giallo e rosso quando la Resistenza scende.
	var colore: Color = Color("3fae6a") if frazione > 0.5 else (Color("e0b23a") if frazione > 0.25 else StileVisivo.PERICOLO)
	(barra.material_override as StandardMaterial3D).albedo_color = colore
	(barra.material_override as StandardMaterial3D).emission = colore


## Lo stendardo steso piatto sulla plancia (fuori dagli scontri) oppure in piedi (in battaglia).
## Steso, mostra solo iniziali e Resistenza; in piedi compaiono anche nome, barra e anello del tempo.
func _stendi_stendardo(lato: int, steso: bool, animato: bool) -> void:
	var stendardo: Node3D = _stendardi[lato]
	# Steso a faccia in su, con l'asta verso il davanti della plancia: resta dentro la colonna.
	var angolo: float = -PI * 0.5 if steso else 0.0
	var posizione: Vector3 = Vector3(0.0, 0.05, POSIZIONE_STESO_Z + BASE_TELO) if steso else Vector3.ZERO
	var scala: Vector3 = Vector3.ONE * (0.9 if steso else 1.0)
	# La Resistenza sta solo sullo stendardo (Davide, 8 novembre 2026): niente nome e barra ripetuti.
	_dati_scontro[lato].visible = false
	for segmento: MeshInstance3D in _anelli[lato]:
		segmento.visible = not steso
	_braci_miccia[lato].visible = false
	# Steso a terra lo stendardo non ha l'asta.
	for parte: Node3D in _aste_stendardo[lato]:
		parte.visible = not steso
	if not animato:
		stendardo.rotation.x = angolo
		stendardo.position = posizione
		stendardo.scale = scala
		return
	var t: Tween = create_tween()
	t.set_parallel(true)
	t.tween_property(stendardo, "rotation:x", angolo, 0.55 if not steso else 0.4).set_trans(Tween.TRANS_BACK if not steso else Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(stendardo, "position", posizione, 0.4)
	t.tween_property(stendardo, "scale", scala, 0.4)


## Telo dello stendardo: carta color crema, fascia del colore del lato in alto, coda a punte in basso.
func _trama_stendardo(colore: Color) -> ImageTexture:
	var img: Image = Image.create(256, 336, false, Image.FORMAT_RGBA8)
	img.fill(Figurina.COLORE_CARTA)
	img.fill_rect(Rect2i(0, 0, 256, 44), colore.darkened(0.35))
	img.fill_rect(Rect2i(0, 44, 256, 6), Color("1a1410"))
	for x: int in range(256):
		var taglio: int = 296 + int(absf(float(x % 64) - 32.0) * 1.2)
		for y: int in range(taglio, 336):
			img.set_pixel(x, y, Color(0.0, 0.0, 0.0, 0.0))
	img.generate_mipmaps()
	return ImageTexture.create_from_image(img)


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
## Il tempo dello scontro sull'asta dello stendardo (Davide, 9 novembre 2026): una luce dorata sale
## lungo l'asta dal basso fino all'inizio del logoramento, con la brace in cima; da lì in poi l'asta
## è tutta rossa e pulsa. Si vede solo negli scontri.
func _crea_anello(_medaglione: Node3D, lato: int) -> void:
	if _materiale_anello_acceso == null:
		_materiale_anello_acceso = StileVisivo.materiale_luminoso(StileVisivo.ORO_LUCE, 1.6)
		_materiale_anello_logoramento = StileVisivo.materiale_luminoso(StileVisivo.PERICOLO, 2.2)
	var stendardo: Node3D = _stendardi[lato]
	var riempimento: MeshInstance3D = MeshInstance3D.new()
	var forma: CylinderMesh = CylinderMesh.new()
	forma.top_radius = 0.085
	forma.bottom_radius = 0.085
	forma.height = 1.0
	riempimento.mesh = forma
	riempimento.material_override = _materiale_anello_acceso
	riempimento.position = Vector3(X_ASTA, 0.0, 0.0)
	riempimento.scale = Vector3(1.0, 0.001, 1.0)
	stendardo.add_child(riempimento)
	_anelli[lato] = [riempimento]
	var brace: MeshInstance3D = MeshInstance3D.new()
	var forma_brace: SphereMesh = SphereMesh.new()
	forma_brace.radius = 0.12
	forma_brace.height = 0.24
	brace.mesh = forma_brace
	brace.material_override = StileVisivo.materiale_luminoso(StileVisivo.BRACE, 5.0)
	stendardo.add_child(brace)
	_braci_miccia[lato] = brace
	_stato_anelli[lato] = 0


## Fa salire la luce lungo l'asta; dall'inizio del logoramento l'asta è tutta rossa.
func _aggiorna_anello(lato: int, millisecondi: int) -> void:
	var inizio: int = maxi(1, run.battle_rules.attrition_start_ms)
	var stato: int = -2 if millisecondi >= inizio else int(float(millisecondi) / float(inizio) * SEGMENTI_ANELLO)
	var riempimento: MeshInstance3D = _anelli[lato][0]
	var brace: MeshInstance3D = _braci_miccia[lato]
	if stato == -2:
		riempimento.material_override = _materiale_anello_logoramento
		var battito: float = 1.0 + 0.04 * sin(_tempo * 8.0)
		riempimento.scale = Vector3(battito, ALTEZZA_ASTA, battito)
		riempimento.position.y = ALTEZZA_ASTA * 0.5
		brace.visible = false
		_stato_anelli[lato] = -2
		return
	if stato == _stato_anelli[lato]:
		return
	_stato_anelli[lato] = stato
	var altezza: float = ALTEZZA_ASTA * float(stato) / float(SEGMENTI_ANELLO)
	riempimento.material_override = _materiale_anello_acceso
	riempimento.scale = Vector3(1.0, maxf(altezza, 0.001), 1.0)
	riempimento.position.y = altezza * 0.5
	brace.visible = riempimento.visible and stato > 0
	brace.position = Vector3(X_ASTA, altezza, 0.0)


# --- Carte sulla plancia ---------------------------------------------------------

func _crea_tessera(genitore: Node3D, scheda: SchedaCarta, misura: Vector2, posizione: Vector3, indice: int, nitidezza: float = 1.0, base: bool = false) -> Tessera3D:
	# Teatro di carta: sulla plancia la carta fa da base alla figurina e non ripete il disegno.
	scheda.come_base = base and scheda.illustrazione != null
	var tessera: Tessera3D = Tessera3D.new()
	genitore.add_child(tessera)
	tessera.costruisci(scheda, misura.x, misura.y, nitidezza)
	tessera.position = posizione
	tessera.indice = indice
	return tessera


## Spazio vuoto: una sagoma stretta velata del colore del lato se è disponibile (con il +), scura
## con il lucchetto se va ancora conquistata. La scritta corre in verticale.
func _crea_spazio(genitore: Node3D, posizione: Vector3, misura: Vector2, disponibile: bool, colore_lato: Color) -> Node3D:
	var spazio: MeshInstance3D = MeshInstance3D.new()
	var forma: PlaneMesh = PlaneMesh.new()
	forma.size = misura
	spazio.mesh = forma
	var colore: Color = Color(StileVisivo.CARTA_CREMA, 0.06) if disponibile else Color(0.0, 0.0, 0.0, 0.3)
	spazio.material_override = StileVisivo.materiale_velo(colore)
	# Il ritaglio: una sottile cornice di carta attorno allo spazio.
	var cornice: StandardMaterial3D = StileVisivo.materiale_velo(Color(StileVisivo.CARTA_CREMA, 0.35 if disponibile else 0.12))
	for k: int in range(4):
		var striscia: MeshInstance3D = MeshInstance3D.new()
		var forma_striscia: PlaneMesh = PlaneMesh.new()
		forma_striscia.size = Vector2(misura.x, 0.035) if k < 2 else Vector2(0.035, misura.y)
		striscia.mesh = forma_striscia
		striscia.material_override = cornice
		striscia.position = Vector3(0.0, 0.002, (misura.y * 0.5 * (-1.0 if k == 0 else 1.0)) if k < 2 else 0.0)
		if k >= 2:
			striscia.position.x = misura.x * 0.5 * (-1.0 if k == 2 else 1.0)
		spazio.add_child(striscia)
	spazio.position = posizione + Vector3(0.0, 0.012, 0.0)
	genitore.add_child(spazio)
	var tinta: Color = Color(StileVisivo.CARTA_CREMA, 0.7) if disponibile else Color(StileVisivo.CARTA_CREMA, 0.3)
	var segno: Label3D = StileVisivo.scritta("+" if disponibile else "×", StileVisivo.FONT_TITOLI, 120, tinta, 0.0, 6)
	segno.position = Vector3(0.0, 0.004, -misura.y * 0.3)
	spazio.add_child(segno)
	var scritta: Label3D = StileVisivo.scritta("LIBERO" if disponibile else "DA CONQUISTARE", StileVisivo.FONT_TITOLI, 34 if disponibile else 26, tinta, 0.0, 6)
	scritta.rotation_degrees = Vector3(-90.0, 90.0, 0.0)
	scritta.position = Vector3(0.0, 0.004, misura.y * 0.12)
	spazio.add_child(scritta)
	return spazio


## Posizione dello spazio numero i di una fila (pezzo o spazio vuoto), fra quelle calcolate da
## _posizioni_fila quando si costruisce il lato. La forma della plancia decide dove sta il punto
## (nell'«arco» la fila è curva).
func _posizione_fila(lato: int, truppa: bool, i: int) -> Vector3:
	var xs: Array[float] = _xs_truppe[lato] if truppa else _xs_edifici[lato]
	var punto: Array = _forme[lato].punto(truppa, xs[i])
	return (punto[0] as Vector3) + Vector3(0.0, 0.02, 0.0)


## Rotazione dello spazio numero i di una fila: le carte seguono la curva dell'«arco».
func _rotazione_fila(lato: int, truppa: bool, i: int) -> float:
	var xs: Array[float] = _xs_truppe[lato] if truppa else _xs_edifici[lato]
	return float(_forme[lato].punto(truppa, xs[i])[1])


## Quanto ogni fila si allunga a sinistra e a destra del centro (margine compreso), per la forma.
static func _estensioni_fila(larghezze: Array[float], xs: Array[float]) -> Vector2:
	var sinistra: float = MEZZO_CUORE + STACCO_CUORE
	var destra: float = MEZZO_CUORE + STACCO_CUORE
	for i: int in range(xs.size()):
		if xs[i] < 0.0:
			sinistra = maxf(sinistra, -xs[i] + larghezze[i] * 0.5)
		else:
			destra = maxf(destra, xs[i] + larghezze[i] * 0.5)
	return Vector2(sinistra, destra) + Vector2.ONE * MARGINE_LASTRA


## Quanti spazi mostrare in una fila: quelli occupati o disponibili, più uno chiuso
## (se se ne possono ancora conquistare) per ricordare che la plancia può crescere.
func _spazi_mostrati(occupati: int, capacita: int, massimo: int, chiuso: bool) -> int:
	var quanti: int = maxi(occupati, capacita)
	if chiuso and quanti < massimo:
		quanti += 1
	return mini(quanti, massimo)


## Ricostruisce le carte di un lato e allarga la sua lastra quanto serve.
## Gli spazi vuoti si mostrano solo per il giocatore. nitidezza: risoluzione delle facce.
## Le figurine escono dalle carte solo negli scontri (Davide, 9 novembre 2026): fuori il disegno resta
## stampato nella carta, più grande e senza coprire la fila dietro. in_scontro: carte come base e
## figurine che si alzano tutte insieme.
func _costruisci_lato(lato: int, edifici: Array[SchedaCarta], truppe: Array[SchedaCarta], capacita_edifici: int, capacita_truppe: int, spazi_chiusi: bool, nitidezza: float, in_scontro: bool = false) -> void:
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
	_larghezze[lato] = _larghezza_per(spazi_truppe, spazi_edifici, truppe.size(), edifici.size())
	var larghezze_t: Array[float] = _larghezze_fila(spazi_truppe, truppe.size(), PASSO_TRUPPE)
	var larghezze_e: Array[float] = _larghezze_fila(spazi_edifici, edifici.size(), PASSO_EDIFICI)
	_xs_truppe[lato] = _posizioni_fila(larghezze_t)
	_xs_edifici[lato] = _posizioni_fila(larghezze_e)
	var fila_t: Vector2 = _estensioni_fila(larghezze_t, _xs_truppe[lato])
	var fila_e: Vector2 = _estensioni_fila(larghezze_e, _xs_edifici[lato])
	_forme[lato].imposta(Vector4(fila_t.x, fila_t.y, fila_e.x, fila_e.y))
	for i: int in range(spazi_truppe):
		if i < truppe.size():
			var truppa: Tessera3D = _crea_tessera(_pezzi[lato], truppe[i], MISURA_TRUPPA, _posizione_fila(lato, true, i), i, nitidezza, in_scontro)
			truppa.rotation.y = _rotazione_fila(lato, true, i)
			_truppe[lato].append(truppa)
			_lampi[lato].append(0.0)
		elif lato == Lato.GIOCATORE:
			var spazio: Node3D = _crea_spazio(_pezzi[lato], _posizione_fila(lato, true, i), Vector2(PASSO_SPAZIO_VUOTO - 0.18, MISURA_TRUPPA.y), i < capacita_truppe, colore)
			spazio.rotation.y = _rotazione_fila(lato, true, i)
			if i < capacita_truppe and _spazio_libero_truppa == null:
				_spazio_libero_truppa = spazio
	for i: int in range(spazi_edifici):
		if i < edifici.size():
			var edificio: Tessera3D = _crea_tessera(_pezzi[lato], edifici[i], MISURA_EDIFICIO, _posizione_fila(lato, false, i), i, nitidezza, in_scontro)
			edificio.rotation.y = _rotazione_fila(lato, false, i)
			_edifici[lato].append(edificio)
		elif lato == Lato.GIOCATORE:
			var spazio: Node3D = _crea_spazio(_pezzi[lato], _posizione_fila(lato, false, i), Vector2(PASSO_SPAZIO_VUOTO - 0.18, MISURA_EDIFICIO.y), i < capacita_edifici, colore)
			spazio.rotation.y = _rotazione_fila(lato, false, i)
			if i < capacita_edifici and _spazio_libero_edificio == null:
				_spazio_libero_edificio = spazio
	if in_scontro:
		_alza_figurine(lato, true)


## Teatro di carta: su ogni pezzo con illustrazione si alza la figurina ritagliata.
## Si animano tutte (inizio di uno scontro) oppure solo quelle dei pezzi appena arrivati.
func _alza_figurine(lato: int, tutte_animate: bool) -> void:
	var verso: float = -1.0 if lato == Lato.GIOCATORE else 1.0
	var conteggi: Dictionary = {}
	var ritardo: float = 0.1
	for gruppo: Array in [_edifici[lato], _truppe[lato]]:
		for tessera: Tessera3D in gruppo:
			var chiave: String = "%d:%s" % [tessera.scheda.genere, tessera.scheda.id]
			conteggi[chiave] = int(conteggi.get(chiave, 0)) + 1
			var nuova: bool = tutte_animate or int(conteggi[chiave]) > int(_gia_viste[lato].get(chiave, 0))
			tessera.aggiungi_figurina(verso, ritardo, nuova, ALTEZZA_FIGURINA_TRUPPA if gruppo == _truppe[lato] else ALTEZZA_FIGURINA_EDIFICIO)
			if nuova:
				ritardo += 0.07
	_gia_viste[lato] = conteggi


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
			_spazi_mostrati(edifici.size(), capacita_edifici, SPAZI_EDIFICI, true),
			truppe.size(), edifici.size())
	var scala: float = _scala_per(larghezza, SCALA_MASSIMA)
	# La forma della plancia la indica il popolo della nazione (Davide, 9 novembre 2026).
	_forme[Lato.GIOCATORE].cambia_forma(run.board_shape())
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
			schede.append(SchedaCarta.da_governo(governo, run))
			origini.append(governo)
		schede.append(SchedaCarta.da_resta(run.government(), run))
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
				schede.append(SchedaCarta.da_incontro(incontro, run))
				origini.append(incontro)
		RunState.Phase.RICOMPENSA_INCONTRO:
			tipo = TipoScelta.RICOMPENSA
			for ricompensa: RewardDef in run.reward_choices():
				schede.append(SchedaCarta.da_ricompensa(ricompensa, run))
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
		var arrivo: Vector3 = Vector3(-0.4 + (i - (schede.size() - 1) * 0.5) * 4.4, 2.3, -3.85)
		# Consiglieri e avvenimenti con un'illustrazione: mezzo busto che esce dall'alto, tipi sotto.
		var busto: bool = scheda.genere == SchedaCarta.Genere.CONSIGLIERE and scheda.illustrazione != null
		var tessera: Tessera3D = _crea_tessera(_contenitore_scelte, scheda, misura, arrivo + Vector3(0.0, 6.0, -4.0), i, 1.6, busto)
		tessera.aggiungi_busto()
		var sotto_tipi: float = LinguettaTipi.misura(scheda.tipi.size()).y - LinguettaTipi.SOTTO_LA_CARTA if not scheda.tipi.is_empty() else 0.0
		tessera.rotation_degrees = Vector3(38.0, 0.0, 0.0)
		tessera.scale = Vector3.ONE * SCALA_SCELTA
		if not scheda.simboli.is_empty():
			tessera.imposta_ingrandimento(INGRANDIMENTO_SIMBOLI)
		if scheda.sopratitolo != "":
			var sopra: Label3D = StileVisivo.scritta(scheda.sopratitolo.to_upper(), StileVisivo.FONT_TITOLI, 42, StileVisivo.TESTO, 0.0, 10)
			sopra.position = Vector3(0.0, 0.02, -misura.y * 0.5 - 0.24)
			# Con il mezzo busto sopra, la scritta passa sotto la carta, dopo i tipi e il verbo.
			if busto:
				sopra.position.z = misura.y * 0.5 + sotto_tipi + 0.55
				sopra.font_size = 34
			tessera.add_child(sopra)
		var costo: Label3D = StileVisivo.scritta(scheda.costo, StileVisivo.FONT_TITOLI, 54, StileVisivo.ORO_LUCE if scheda.disponibile else StileVisivo.PERICOLO, 0.0, 12)
		costo.position = Vector3(0.0, 0.02, misura.y * 0.5 + 0.27 + sotto_tipi)
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
	# Le spiegazioni delle parole chiave dicono le eccezioni delle ascensioni della nazione.
	TestoRicco.imposta_regole(SchedaCarta.regole_di(run))
	_annulla()
	_costruisci_plancia_giocatore()
	_costruisci_scelte()
	_aggiorna_stato_consiglieri()
	_mostra_potenziabili(run.chosen_advisor)
	_nomi_lato[Lato.GIOCATORE].text = run.nation_name.to_upper()
	_scena.imposta_iniziali(_iniziali_di(run.nation_name))
	_aggiorna_medaglione(Lato.GIOCATORE, run.player_resistance(), run.player_resistance())
	# Il mese mostrato resta dentro la stagione in corso (durante un incontro il round va oltre il terzo).
	var primo_mese: int = int(run.season) * run.run_rules.rounds_per_season + 1
	var mese: int = clampi(run.month(), primo_mese, primo_mese + run.run_rules.rounds_per_season - 1)
	_scena.imposta_mese(run.year, int(run.season), mese, RunState.MONTH_NAMES[mese - 1], run.season_name(), hash(run.nation_name), _scena_subito)
	_scena_subito = false
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
			tessera.imposta_stato("▲ Potenzia pronto · %d %s" % [quante, "tessera" if quante == 1 else "tessere"], StileVisivo.ORO_LUCE)
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
	# Che cosa cambierebbe con il Potenzia, prima di decidere (richiesta di Davide, 8 novembre).
	var anteprima: String = SchedaCarta.anteprima_potenzia(run, pezzo)
	if anteprima != "":
		dettagli += "\n\n" + anteprima
	if run.is_shopping_phase() and pezzo.level < run.max_level():
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
		edifici.append(SchedaCarta.da_edificio(_setups[0].buildings[i], run.board.buildings[i].level if stessi_edifici else 1, "", run.max_level()))
	for i: int in range(_setups[0].troops.size()):
		truppe.append(SchedaCarta.da_truppa(_setups[0].troops[i], run.board.troops[i].level if stesse_truppe else 1, "", false, run.max_level(), SchedaCarta.regole_di(run)))
	var edifici_avversari: Array[SchedaCarta] = []
	for def: BuildingDef in _setups[1].buildings:
		edifici_avversari.append(SchedaCarta.da_edificio(def))
	var truppe_avversarie: Array[SchedaCarta] = []
	for def: TroopDef in _setups[1].troops:
		truppe_avversarie.append(SchedaCarta.da_truppa(def))
	# Nello scontro si vedono solo gli elementi schierati; i due lati hanno la stessa scala.
	var larghezza: float = maxf(_larghezza_per(truppe.size(), edifici.size()), _larghezza_per(truppe_avversarie.size(), edifici_avversari.size()))
	var scala: float = _scala_per(larghezza, SCALA_MASSIMA_SCONTRO)
	_costruisci_lato(Lato.GIOCATORE, edifici, truppe, edifici.size(), truppe.size(), false, scala, true)
	# Il nemico ha la forma del popolo del fantasma o quella del suo incontro.
	_forme[Lato.AVVERSARIO].cambia_forma(run.last_opponent_board_shape)
	_costruisci_lato(Lato.AVVERSARIO, edifici_avversari, truppe_avversarie, 0, 0, false, scala, true)
	# Le estremità dell'«arco» rientrano verso il centro del tavolo: la plancia del nemico si
	# allontana di tanto, per non toccare la tua, e la telecamera si allarga quanto serve.
	var distanza: float = _forme[Lato.GIOCATORE].rientro() + _forme[Lato.AVVERSARIO].rientro()
	_mira_scontro = MIRA_SCONTRO + Vector3(0.0, 0.0, -distanza * 0.5)
	_camera_scontro = _mira_scontro + (CAMERA_SCONTRO - MIRA_SCONTRO) * (1.0 + distanza / PROFONDITA_SCONTRO)
	_disponi_plancia(scala, larghezza, true, 0.7)
	_nomi_lato[Lato.AVVERSARIO].text = run.last_opponent_name.trim_prefix("Fantasma: ").to_upper()
	_aggiorna_visuale_scontro()

	var avversario: Node3D = _radici[Lato.AVVERSARIO]
	avversario.visible = true
	avversario.position = Vector3(0.0, 0.0, -14.0)
	var arrivo: Tween = create_tween()
	arrivo.set_parallel(true)
	arrivo.tween_property(avversario, "position", Vector3(0.0, 0.0, -distanza), 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	arrivo.tween_method(_muovi_camera.bind(_camera.global_position, _camera_scontro, MIRA_PARTITA, _mira_scontro), 0.0, 1.0, 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	_hud.modalita_scontro(true, titolo)
	for lato: int in [Lato.GIOCATORE, Lato.AVVERSARIO]:
		_stendi_stendardo(lato, true, false)
		_stendi_stendardo(lato, false, true)
	_scena.mostra_fila_mesi(false)


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
	_scena.aggiorna(delta)
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
		_richiudi_sconfitto(_sim.outcome)
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
					_consuma_mana(evento.side, evento.index)
				_colpo(1 - evento.side, evento.amount, "")
			BattleEvent.Kind.LOGORAMENTO:
				_colpo(evento.side, evento.amount, "logoramento")
			BattleEvent.Kind.SCUDO:
				_scritta_volante(evento.side, "+%d scudo" % evento.amount, Color("2f6fd0"))
			BattleEvent.Kind.CURA:
				_scritta_volante(evento.side, "+%d" % evento.amount, Color("2f9e57"))
			BattleEvent.Kind.CORRUZIONE:
				_scritta_volante(evento.side, "+%d Corruzione" % evento.amount, StileVisivo.COLORE_CORRUZIONE)
			BattleEvent.Kind.ASSEDIO:
				_scritta_volante(evento.side, "−%d scudo" % evento.amount, Color("7a6a55"))
			BattleEvent.Kind.ULTIMA_TRINCEA:
				_scritta_volante(evento.side, "Ultima trincea!", StileVisivo.ORO_LUCE)
			BattleEvent.Kind.RALLENTATO, BattleEvent.Kind.SABOTATO:
				var colpita: Tessera3D = _elemento_da_indice(evento.side, evento.index)
				if colpita != null:
					colpita.scintille(Color("ff9a3d") if evento.kind == BattleEvent.Kind.RALLENTATO else StileVisivo.COLORE_SABOTATO, Vector3(0.0, 0.3, 0.0), 14)


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
		if _scritte_scudo[lato].text != str(scudo) and scudo > 0:
			_scuoti_segnalino(_segnalini_scudo[lato])
		_segnalini_scudo[lato].visible = scudo > 0
		_scritte_scudo[lato].text = str(scudo)
		var corruzione: int = _sim.get_corruption(lato)
		if _scritte_corruzione[lato].text != str(corruzione) and corruzione > 0:
			_scuoti_segnalino(_segnalini_corruzione[lato])
		_segnalini_corruzione[lato].visible = corruzione > 0
		_scritte_corruzione[lato].text = str(corruzione)
		# La Corruzione macchia lo stendardo dal basso: quando arriva alla Resistenza, il lato cade (GDD §7.6.3).
		_teli_stendardo[lato].set_shader_parameter("corruzione", clampf(float(corruzione) / float(maxi(_sim.get_resistance(lato), 1)), 0.0, 1.0))
		for i: int in range(_edifici[lato].size()):
			var edificio: Tessera3D = _edifici[lato][i]
			if _sim.get_building_sabotage_ms(lato, i) > 0:
				edificio.imposta_stato("Sabotato", StileVisivo.COLORE_SABOTATO)
			elif _sim.get_building_slow_ms(lato, i) > 0:
				edificio.imposta_stato("Inefficiente", Color("e08a2e"))
			elif _trascurata(lato, false, i):
				edificio.imposta_stato("Trascurato: mantenimento non pagato", Color("e08a2e"))
			else:
				edificio.imposta_stato("", StileVisivo.NOTTE)
		for mana: StringName in COLORI_RISERVA:
			(_riserve[lato] as RiservaMana).imposta(mana, _sim.get_mana(lato, mana))
		var mancanze: Array[StringName] = []
		for i: int in range(_truppe[lato].size()):
			if _sim.get_troop_state(lato, i) == BattleSim.TroopState.IN_ATTESA_DI_MANA:
				var richiesta: StringName = _setups[lato].troops[i].mana_type
				if not mancanze.has(richiesta):
					mancanze.append(richiesta)
		(_riserve[lato] as RiservaMana).segnala_mancanze(mancanze)
		for i: int in range(_truppe[lato].size()):
			var tessera: Tessera3D = _truppe[lato][i]
			var def: TroopDef = _setups[lato].troops[i]
			var rimasto: int = _sim.get_troop_cooldown_left_ms(lato, i)
			var stato: BattleSim.TroopState = _sim.get_troop_state(lato, i)
			var ferma: bool = stato in [BattleSim.TroopState.SABOTATA, BattleSim.TroopState.MANA_PRENOTATO, BattleSim.TroopState.IN_ATTESA_DI_MANA]
			tessera.imposta_spenta(0.85 if ferma else 0.0)
			if stato == BattleSim.TroopState.SABOTATA:
				tessera.imposta_ricarica(1.0 - float(rimasto) / float(maxi(def.cooldown_ms, 1)))
				tessera.imposta_stato("Sabotata: non può attivarsi", StileVisivo.COLORE_SABOTATO)
			elif stato == BattleSim.TroopState.MANA_PRENOTATO:
				tessera.imposta_ricarica(1.0)
				tessera.imposta_stato("Aspetta: il mana è prenotato dalla truppa più a destra", Color("e08a2e"))
			elif stato == BattleSim.TroopState.IN_ATTESA_DI_MANA:
				tessera.imposta_ricarica(1.0)
				var disponibile: int = _sim.get_mana(lato, def.mana_type) + _sim.get_mana(lato, BattleSim.MANA_ENERGETICO)
				tessera.imposta_stato("In attesa: servono %d %s, %s %d" % [def.mana_cost, def.mana_type, "ne hai" if lato == Lato.GIOCATORE else "ne ha", disponibile], StileVisivo.PERICOLO)
			else:
				tessera.imposta_ricarica(1.0 - float(rimasto) / float(maxi(def.cooldown_ms, 1)))
				# L'attivazione si vede già (scatto, scintille, alone): nessuna fascia sopra i numeri.
				if _sim.get_troop_slow_ms(lato, i) > 0:
					tessera.imposta_stato("Inefficiente", Color("e08a2e"))
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


## Il mana vola dall'edificio alla sua sfera nella riserva, lasciando una scia; all'arrivo la sfera
## si illumina e mostra "+1".
func _lancia_mana(lato: int, edificio: Tessera3D, mana: StringName) -> void:
	var riserva: RiservaMana = _riserve[lato] as RiservaMana
	if _gemme_in_volo >= MASSIMO_GEMME_IN_VOLO or not riserva.ha(mana):
		return
	_gemme_in_volo += 1
	_vola_mana(edificio.punto_gemma(), riserva.arrivo(mana).global_position, mana, 2.2, func() -> void:
		_gemme_in_volo -= 1
		riserva.pulsa(mana))


## Una truppa spende il mana: dalla sua sfera parte una scia verso la truppa.
func _consuma_mana(lato: int, indice: int) -> void:
	if indice < 0 or indice >= _setups[lato].troops.size() or indice >= _truppe[lato].size():
		return
	var def: TroopDef = _setups[lato].troops[indice]
	var riserva: RiservaMana = _riserve[lato] as RiservaMana
	if def.mana_cost <= 0 or not riserva.ha(def.mana_type) or _gemme_in_volo >= MASSIMO_GEMME_IN_VOLO:
		return
	var truppa: Tessera3D = _truppe[lato][indice]
	for k: int in range(mini(def.mana_cost, 3)):
		_gemme_in_volo += 1
		var ritardo: Tween = create_tween()
		ritardo.tween_interval(0.06 * k)
		ritardo.tween_callback(func() -> void:
			_vola_mana(riserva.arrivo(def.mana_type).global_position, truppa.punto_gemma(), def.mana_type, 1.0, func() -> void: _gemme_in_volo -= 1))


func _vola_mana(da: Vector3, a: Vector3, mana: StringName, arco: float, al_termine: Callable) -> void:
	var colore: Color = StileVisivo.colore_mana_nome(mana)
	var goccia_volante: MeshInstance3D = MeshInstance3D.new()
	var forma: SphereMesh = SphereMesh.new()
	forma.radius = 0.09
	forma.height = 0.18
	goccia_volante.mesh = forma
	goccia_volante.material_override = StileVisivo.materiale_luminoso(colore.lightened(0.3), 4.0)
	add_child(goccia_volante)
	var scia: CPUParticles3D = CPUParticles3D.new()
	var goccia: SphereMesh = SphereMesh.new()
	goccia.radius = 0.04
	goccia.height = 0.08
	goccia.material = StileVisivo.materiale_luminoso(colore, 3.0)
	scia.mesh = goccia
	scia.amount = 30
	scia.lifetime = 0.4
	scia.local_coords = false
	scia.spread = 180.0
	scia.initial_velocity_min = 0.0
	scia.initial_velocity_max = 0.25
	scia.gravity = Vector3.ZERO
	scia.scale_amount_min = 0.4
	scia.scale_amount_max = 1.0
	goccia_volante.add_child(scia)
	goccia_volante.global_position = da
	var volo: Tween = create_tween()
	volo.tween_method(func(t: float) -> void:
		goccia_volante.global_position = da.lerp(a, t) + Vector3(0.0, sin(t * PI) * arco, 0.0), 0.0, 1.0, 0.6 / maxf(_velocita, 1.0)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	volo.tween_callback(func() -> void:
		goccia_volante.queue_free()
		al_termine.call())


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
	_brace(medaglione.global_position + Vector3(0.0, BASE_TELO + ALTEZZA_STENDARDO * 0.4, 0.2), mini(60, 14 + danno * 4))
	var centro: Vector3 = medaglione.get_meta("base")
	var scossa: Tween = create_tween()
	for passo: int in range(4):
		var spostamento: Vector3 = Vector3(randf_range(-0.12, 0.12), 0.0, randf_range(-0.08, 0.08))
		scossa.tween_property(medaglione, "position", centro + spostamento, 0.035)
	scossa.tween_property(medaglione, "position", centro, 0.05)


## Teatro di carta: a fine scontro le figurine del lato sconfitto si richiudono come un libro.
func _richiudi_sconfitto(esito: BattleSim.Outcome) -> void:
	var sconfitto: int = -1
	if esito == BattleSim.Outcome.VITTORIA_A:
		sconfitto = Lato.AVVERSARIO
	elif esito == BattleSim.Outcome.VITTORIA_B:
		sconfitto = Lato.GIOCATORE
	if sconfitto < 0:
		return
	var ritardo: float = 0.0
	for gruppo: Array in [_truppe[sconfitto], _edifici[sconfitto]]:
		for tessera: Tessera3D in gruppo:
			if tessera.figurina != null:
				tessera.figurina.richiudi(ritardo)
				ritardo += 0.06
	_brace(_medaglioni[sconfitto].global_position + Vector3(0.0, BASE_TELO + ALTEZZA_STENDARDO * 0.5, 0.2), 90)
	var telo: ShaderMaterial = _teli_stendardo[sconfitto]
	var brucia: Tween = create_tween()
	brucia.tween_method(func(v: float) -> void: telo.set_shader_parameter("finale", v), 0.0, 1.05, 1.6)


## Scintille di brace che salgono (colpi sullo stemma, sconfitta).
func _brace(dove: Vector3, quante: int) -> void:
	var particelle: CPUParticles3D = CPUParticles3D.new()
	var granello: QuadMesh = QuadMesh.new()
	granello.size = Vector2(0.09, 0.09)
	var materiale: StandardMaterial3D = StileVisivo.materiale_luminoso(StileVisivo.BRACE, 4.0)
	materiale.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	materiale.vertex_color_use_as_albedo = true
	materiale.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	materiale.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	granello.material = materiale
	particelle.mesh = granello
	particelle.amount = quante
	particelle.lifetime = 1.0
	particelle.one_shot = true
	particelle.explosiveness = 0.95
	particelle.direction = Vector3.UP
	particelle.spread = 180.0
	particelle.initial_velocity_min = 1.5
	particelle.initial_velocity_max = 4.5
	particelle.gravity = Vector3(0.0, 2.0, 0.0)
	particelle.damping_min = 1.0
	particelle.damping_max = 3.0
	var rampa: Gradient = Gradient.new()
	rampa.set_color(0, Color("ffd27a"))
	rampa.set_color(1, Color(StileVisivo.BRACE, 0.0))
	particelle.color_ramp = rampa
	add_child(particelle)
	particelle.global_position = dove
	particelle.emitting = true
	var pulizia: Tween = create_tween()
	pulizia.tween_interval(1.6)
	pulizia.tween_callback(particelle.queue_free)


## Punto di partenza delle scritte sopra lo stemma: si alternano su tre posizioni.
func _punto_scritta(lato: int) -> Vector3:
	_scritte_uscite[lato] += 1
	var turno: int = _scritte_uscite[lato] % 3
	return _medaglioni[lato].global_position + Vector3(0.8 + turno * 0.6, 0.8 + ALTEZZA_STENDARDO * 0.6 + turno * 0.3, 0.3)


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
	_stendi_stendardo(Lato.GIOCATORE, true, true)
	_scena.mostra_fila_mesi(true)
	# La plancia torna com'è fuori dagli scontri: riserva di mana vuota, niente Scudo o Corruzione.
	for lato: int in [Lato.GIOCATORE, Lato.AVVERSARIO]:
		_aggiorna_anello(lato, 0)
		var riserva: RiservaMana = _riserve[lato] as RiservaMana
		for mana: StringName in COLORI_RISERVA:
			riserva.imposta(mana, 0)
		riserva.segnala_mancanze([] as Array[StringName])
		_segnalini_scudo[lato].visible = false
		_segnalini_corruzione[lato].visible = false
		_teli_stendardo[lato].set_shader_parameter("corruzione", 0.0)
		for i: int in range(_lampi[lato].size()):
			_lampi[lato][i] = 0.0
	var avversario: Node3D = _radici[Lato.AVVERSARIO]
	var uscita: Tween = create_tween()
	uscita.set_parallel(true)
	uscita.tween_property(avversario, "position", Vector3(0.0, 0.0, -14.0), 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	uscita.tween_method(_muovi_camera.bind(_camera.global_position, CAMERA_PARTITA, _mira_scontro, MIRA_PARTITA), 0.0, 1.0, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	uscita.chain().tween_callback(avversario.hide)
	# Le figurine si ripiegano nelle carte; poi le carte tornano con il disegno stampato.
	for gruppo: Array in [_truppe[Lato.GIOCATORE], _edifici[Lato.GIOCATORE]]:
		for tessera: Tessera3D in gruppo:
			if tessera.figurina != null:
				tessera.figurina.riponi()
	var ritorno: Tween = create_tween()
	ritorno.tween_interval(Figurina.DURATA_RIPONI)
	ritorno.tween_callback(_aggiorna_tutto)


# --- Mouse ---------------------------------------------------------------------

## Il testo del riquadro di una carta: i dettagli, chi ne beneficia e, se è un'offerta, il costo.
func _testo_riquadro(tessera: Tessera3D) -> String:
	var scheda: SchedaCarta = tessera.scheda
	var testo: String = scheda.dettagli
	var beneficiari: Array[BoardPiece] = _beneficiari_sotto(tessera)
	if not beneficiari.is_empty():
		testo += "\n▲ Ne beneficiano: %s." % HudPlancia.nomi_raggruppati(beneficiari)
	# Solo un prezzo vero è un costo; "Ascolta" o "Scegli" restano scritti sotto la carta.
	if scheda.prezzo and scheda.costo != "":
		testo += "\nCosto: %s%s" % [scheda.costo, "" if scheda.disponibile else " (non basta)"]
	return testo


## Il rettangolo che una carta occupa sullo schermo, ingrandita di "fattore": il riquadro dei
## dettagli le si attacca, così non copre la carta (nemmeno quando è ingrandita con i simboli).
func _area_sullo_schermo(tessera: Tessera3D, fattore: float = 1.0) -> Rect2:
	var mezza_x: float = tessera.larghezza * 0.5 * fattore
	var mezza_z: float = tessera.profondita * 0.5 * fattore
	var giu: float = tessera.spostamento_ingrandimento() if fattore > 1.0 else 0.0
	var area: Rect2 = Rect2()
	var primo: bool = true
	for angolo: Vector3 in [Vector3(-mezza_x, 0.0, -mezza_z), Vector3(mezza_x, 0.0, -mezza_z), Vector3(-mezza_x, 0.0, mezza_z), Vector3(mezza_x, 0.0, mezza_z)]:
		var punto: Vector2 = _camera.unproject_position(tessera.to_global(angolo + Vector3(0.0, 0.0, giu)))
		if primo:
			area = Rect2(punto, Vector2.ZERO)
			primo = false
		else:
			area = area.expand(punto)
	return area


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
	# Un pannello aperto sopra le carte (es. la legenda) le copre: niente carta sotto il mouse.
	if _hud.mouse_su_pannello():
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
		# Le carte che si ingrandiscono molto (con i simboli): il riquadro si attacca alla carta ingrandita.
		var fattore: float = tessera.ingrandimento if tessera.ingrandimento > 1.2 else 1.0
		_hud.mostra_suggerimento(titolo, _testo_riquadro(tessera), _area_sullo_schermo(tessera, fattore))
	else:
		_hud.nascondi_suggerimento()
