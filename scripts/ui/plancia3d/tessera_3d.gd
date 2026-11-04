class_name Tessera3D
extends Node3D
## Un pezzo 2D posato sulla plancia 3D: edificio, truppa o offerta (GDD §14.2).
## Ha la forma di una carta: cornice metallica del colore dell'era, illustrazione,
## nome, gemma del mana nell'angolo e "pastiglie" con i numeri principali.
## Solo presentazione: mostra quello che le viene detto, non decide nulla.

const SPESSORE: float = 0.08
const ALTEZZA_SOLLEVATA: float = 0.3

var pezzo: DatiEsempioPlancia.Pezzo
var larghezza: float = 1.6
var profondita: float = 1.9

var _corpo: Node3D
var _materiale_cornice: StandardMaterial3D
var _colore_cornice: Color
var _velo_ricarica: MeshInstance3D
var _nastro_stato: MeshInstance3D
var _materiale_nastro: StandardMaterial3D
var _scritta_stato: Label3D
var _pastiglie: Node3D
var _evidenziata: bool = false
var _animazione_sollevamento: Tween


func costruisci(dati: DatiEsempioPlancia.Pezzo, p_larghezza: float, p_profondita: float) -> void:
	pezzo = dati
	larghezza = p_larghezza
	profondita = p_profondita
	_corpo = Node3D.new()
	add_child(_corpo)
	_crea_supporto()
	_crea_illustrazione()
	_crea_nome()
	_crea_pastiglie()
	_crea_gemma()
	_crea_livello()
	_crea_ricarica()
	_crea_nastro_stato()
	if pezzo.malus != "":
		_crea_nastro_malus()
	_crea_area_mouse()


func _superficie() -> float:
	return SPESSORE + 0.006


func _piano(misura: Vector2, materiale: Material, posizione: Vector3) -> MeshInstance3D:
	var risultato: MeshInstance3D = MeshInstance3D.new()
	var forma: PlaneMesh = PlaneMesh.new()
	forma.size = misura
	risultato.mesh = forma
	risultato.material_override = materiale
	risultato.position = posizione
	_corpo.add_child(risultato)
	return risultato


# --- Costruzione -------------------------------------------------------------

func _crea_supporto() -> void:
	_colore_cornice = StileVisivo.colore_cornice(pezzo.era)
	var cornice: MeshInstance3D = MeshInstance3D.new()
	var forma_cornice: BoxMesh = BoxMesh.new()
	forma_cornice.size = Vector3(larghezza + 0.14, SPESSORE * 0.85, profondita + 0.14)
	cornice.mesh = forma_cornice
	_materiale_cornice = StileVisivo.materiale_metallo(_colore_cornice)
	cornice.material_override = _materiale_cornice
	cornice.position.y = SPESSORE * 0.42
	_corpo.add_child(cornice)

	var faccia: MeshInstance3D = MeshInstance3D.new()
	var forma_faccia: BoxMesh = BoxMesh.new()
	forma_faccia.size = Vector3(larghezza, SPESSORE, profondita)
	faccia.mesh = forma_faccia
	faccia.material_override = StileVisivo.materiale(StileVisivo.FACCIA_CARTA, 0.7)
	faccia.position.y = SPESSORE * 0.5 + 0.004
	_corpo.add_child(faccia)


## Riquadro dell'illustrazione: per ora una sfumatura del colore del mana con l'iniziale,
## segnaposto dell'immagine vera.
func _crea_illustrazione() -> void:
	var colore: Color = StileVisivo.colore_mana(pezzo.mana)
	if pezzo.mana == StileVisivo.Mana.NESSUNO:
		colore = StileVisivo.PIETRA_CHIARA
	var riquadro: MeshInstance3D = _piano(Vector2(larghezza - 0.12, profondita * 0.56), StileVisivo.materiale_illustrazione(colore), Vector3(0.0, _superficie(), -profondita * 0.16))
	var iniziale: Label3D = StileVisivo.scritta(pezzo.nome.substr(0, 1), StileVisivo.FONT_TITOLI, 170, Color(1.0, 1.0, 1.0, 0.85), 0.0, 14)
	iniziale.position = riquadro.position + Vector3(0.0, 0.004, 0.0)
	_corpo.add_child(iniziale)


func _crea_nome() -> void:
	var fascia: MeshInstance3D = _piano(Vector2(larghezza, profondita * 0.17), StileVisivo.materiale(StileVisivo.FASCIA_NOME, 0.6), Vector3(0.0, _superficie() + 0.003, profondita * 0.205))
	var nome: Label3D = StileVisivo.scritta(pezzo.nome.to_upper(), StileVisivo.FONT_TITOLI, 52, StileVisivo.TESTO, 0.0, 8)
	nome.position = fascia.position + Vector3(0.0, 0.004, 0.0)
	_corpo.add_child(nome)


## Pastiglie con i numeri principali: danno e ricarica per le truppe, mana prodotto per gli edifici.
func _crea_pastiglie() -> void:
	_pastiglie = Node3D.new()
	_pastiglie.position = Vector3(0.0, _superficie() + 0.006, profondita * 0.385)
	_corpo.add_child(_pastiglie)
	var altezza: float = profondita * 0.15
	if pezzo.danno > 0:
		var meta: float = (larghezza - 0.24) * 0.5
		_pastiglia(Vector2(meta, altezza), -meta * 0.5 - 0.04, StileVisivo.PERICOLO.darkened(0.15), str(pezzo.danno))
		_pastiglia(Vector2(meta, altezza), meta * 0.5 + 0.04, Color("33415e"), _secondi(pezzo.ritmo_s))
	elif pezzo.tipo_offerta == "" or pezzo.tipo_offerta == "Costruttori":
		var testo: String = "+%d · %s" % [pezzo.mana_numero, _secondi(pezzo.ritmo_s)]
		_pastiglia(Vector2(larghezza - 0.2, altezza), 0.0, StileVisivo.colore_mana(pezzo.mana).darkened(0.3), testo)
	else:
		var riga: Label3D = StileVisivo.scritta(pezzo.riga, StileVisivo.FONT_NUMERI, 40, StileVisivo.ORO_LUCE, (larghezza - 0.12) / 0.004, 8)
		_pastiglie.add_child(riga)


func _secondi(valore: float) -> String:
	var testo: String = ("%.1f" % valore).replace(".", ",")
	return testo.trim_suffix(",0") + " s"


func _pastiglia(misura: Vector2, x: float, colore: Color, testo: String) -> void:
	var fondo: MeshInstance3D = MeshInstance3D.new()
	var forma: BoxMesh = BoxMesh.new()
	forma.size = Vector3(misura.x, 0.03, misura.y)
	fondo.mesh = forma
	fondo.material_override = StileVisivo.materiale(colore, 0.45)
	fondo.position = Vector3(x, 0.0, 0.0)
	_pastiglie.add_child(fondo)
	var scritta: Label3D = StileVisivo.scritta(testo, StileVisivo.FONT_TITOLI, 58, Color.WHITE, 0.0, 10)
	scritta.position = Vector3(x, 0.02, 0.0)
	_pastiglie.add_child(scritta)


## Gemma del mana nell'angolo: costo per le truppe, produzione per gli edifici.
func _crea_gemma() -> void:
	if pezzo.mana == StileVisivo.Mana.NESSUNO:
		return
	var gemma: MeshInstance3D = MeshInstance3D.new()
	var forma: CylinderMesh = CylinderMesh.new()
	forma.top_radius = 0.23
	forma.bottom_radius = 0.27
	forma.height = 0.1
	forma.radial_segments = 6
	gemma.mesh = forma
	gemma.material_override = StileVisivo.materiale_gemma(pezzo.mana)
	gemma.position = Vector3(-larghezza * 0.5 + 0.08, SPESSORE + 0.06, -profondita * 0.5 + 0.08)
	_corpo.add_child(gemma)
	var numero: Label3D = StileVisivo.scritta(str(pezzo.mana_numero), StileVisivo.FONT_TITOLI, 80, Color.WHITE, 0.0, 14)
	numero.position = gemma.position + Vector3(0.0, 0.06, 0.0)
	_corpo.add_child(numero)


## Livello (1-3): rombi nell'angolo opposto alla gemma.
func _crea_livello() -> void:
	for i: int in range(3):
		var rombo: MeshInstance3D = MeshInstance3D.new()
		var forma: BoxMesh = BoxMesh.new()
		forma.size = Vector3(0.11, 0.03, 0.11)
		rombo.mesh = forma
		var pieno: bool = i < pezzo.livello
		rombo.material_override = StileVisivo.materiale_luminoso(StileVisivo.ORO_LUCE, 0.6) if pieno else StileVisivo.materiale(Color("3a4560"), 0.6)
		rombo.rotation_degrees.y = 45.0
		rombo.position = Vector3(larghezza * 0.5 - 0.42 + i * 0.16, _superficie() + 0.01, -profondita * 0.5 + 0.13)
		_corpo.add_child(rombo)


## Velo scuro che copre la parte di ricarica ancora da compiere.
func _crea_ricarica() -> void:
	_velo_ricarica = _piano(Vector2(larghezza, profondita), StileVisivo.materiale_velo(Color(0.02, 0.04, 0.09, 0.62)), Vector3(0.0, _superficie() + 0.03, 0.0))
	_velo_ricarica.visible = false


## Fascia sulla parte bassa della carta che dice in parole che cosa sta facendo (principio P4).
func _crea_nastro_stato() -> void:
	_materiale_nastro = StileVisivo.materiale(StileVisivo.PERICOLO, 0.6)
	_nastro_stato = _piano(Vector2(larghezza + 0.04, profondita * 0.3), _materiale_nastro, Vector3(0.0, _superficie() + 0.04, profondita * 0.5 - profondita * 0.15))
	_nastro_stato.visible = false
	_scritta_stato = StileVisivo.scritta("", StileVisivo.FONT_NUMERI, 40, Color.WHITE, (larghezza - 0.06) / 0.004, 6)
	_scritta_stato.position = _nastro_stato.position + Vector3(0.0, 0.004, 0.0)
	_scritta_stato.visible = false
	_corpo.add_child(_scritta_stato)


func _crea_nastro_malus() -> void:
	var nastro: MeshInstance3D = _piano(Vector2(larghezza * 0.86, 0.3), StileVisivo.materiale_luminoso(StileVisivo.PERICOLO, 0.4), Vector3(0.0, _superficie() + 0.02, -profondita * 0.5 - 0.02))
	var scritta: Label3D = StileVisivo.scritta(pezzo.malus.to_upper(), StileVisivo.FONT_TITOLI, 34, Color.WHITE, 0.0, 6)
	scritta.position = nastro.position + Vector3(0.0, 0.004, 0.0)
	_corpo.add_child(scritta)


func _crea_area_mouse() -> void:
	var area: StaticBody3D = StaticBody3D.new()
	var sagoma: CollisionShape3D = CollisionShape3D.new()
	var scatola: BoxShape3D = BoxShape3D.new()
	scatola.size = Vector3(larghezza, 0.3, profondita)
	sagoma.shape = scatola
	sagoma.position.y = 0.15
	area.add_child(sagoma)
	area.set_meta("tessera", self)
	_corpo.add_child(area)


# --- Stati e animazioni --------------------------------------------------------

## Mouse sopra la carta: si solleva, si ingrandisce un poco e la cornice si illumina.
func evidenzia(attiva: bool) -> void:
	if attiva == _evidenziata:
		return
	_evidenziata = attiva
	if _animazione_sollevamento != null and _animazione_sollevamento.is_valid():
		_animazione_sollevamento.kill()
	_animazione_sollevamento = create_tween()
	_animazione_sollevamento.set_parallel(true)
	_animazione_sollevamento.tween_property(_corpo, "position:y", ALTEZZA_SOLLEVATA if attiva else 0.0, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_animazione_sollevamento.tween_property(_corpo, "scale", Vector3.ONE * (1.06 if attiva else 1.0), 0.14)
	_illumina_cornice(1.2 if attiva else 0.0)


func _illumina_cornice(energia: float) -> void:
	_materiale_cornice.emission_enabled = energia > 0.0
	_materiale_cornice.emission = _colore_cornice.lightened(0.3)
	_materiale_cornice.emission_energy_multiplier = energia


## frazione: 0 = appena attivata, 1 = pronta.
func imposta_ricarica(frazione: float) -> void:
	var resto: float = clampf(1.0 - frazione, 0.0, 1.0)
	_velo_ricarica.visible = resto > 0.001
	_velo_ricarica.scale = Vector3(1.0, 1.0, maxf(resto, 0.001))
	_velo_ricarica.position.z = -profondita * 0.5 + profondita * resto * 0.5


func imposta_stato(testo: String, colore: Color) -> void:
	var visibile: bool = testo != ""
	_nastro_stato.visible = visibile
	_scritta_stato.visible = visibile
	_scritta_stato.text = testo
	_pastiglie.visible = not visibile
	_materiale_nastro.albedo_color = colore
	var chiaro: bool = colore.get_luminance() > 0.55
	_scritta_stato.modulate = StileVisivo.NOTTE if chiaro else Color.WHITE
	_scritta_stato.outline_size = 0 if chiaro else 6


## Attivazione in battaglia: balzo verso l'avversario, lampo della cornice e scintille.
## verso: -1 se l'avversario è lontano dalla telecamera, +1 se è vicino.
func attiva(verso: float) -> void:
	var animazione: Tween = create_tween()
	animazione.tween_property(_corpo, "position", Vector3(0.0, 0.5, 0.4 * verso), 0.09).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	animazione.parallel().tween_property(_corpo, "scale", Vector3.ONE * 1.12, 0.09)
	animazione.tween_property(_corpo, "position", Vector3.ZERO, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	animazione.parallel().tween_property(_corpo, "scale", Vector3.ONE, 0.25)
	_illumina_cornice(3.0)
	var spegni: Tween = create_tween()
	spegni.tween_interval(0.22)
	spegni.tween_callback(_illumina_cornice.bind(1.2 if _evidenziata else 0.0))
	var colore: Color = StileVisivo.ORO_LUCE if pezzo.mana == StileVisivo.Mana.NESSUNO else StileVisivo.colore_mana(pezzo.mana)
	_scintille(colore)


func _scintille(colore: Color) -> void:
	var particelle: CPUParticles3D = CPUParticles3D.new()
	var goccia: SphereMesh = SphereMesh.new()
	goccia.radius = 0.05
	goccia.height = 0.1
	goccia.material = StileVisivo.materiale_luminoso(colore, 4.0)
	particelle.mesh = goccia
	particelle.amount = 26
	particelle.lifetime = 0.6
	particelle.one_shot = true
	particelle.explosiveness = 1.0
	particelle.direction = Vector3.UP
	particelle.spread = 70.0
	particelle.initial_velocity_min = 2.5
	particelle.initial_velocity_max = 5.0
	particelle.gravity = Vector3(0.0, -9.0, 0.0)
	particelle.scale_amount_min = 0.6
	particelle.scale_amount_max = 1.3
	particelle.position = Vector3(0.0, 0.3, 0.0)
	add_child(particelle)
	particelle.emitting = true
	var pulizia: Tween = create_tween()
	pulizia.tween_interval(1.0)
	pulizia.tween_callback(particelle.queue_free)


## Punto da cui parte (edifici) o a cui arriva (truppe) il mana.
func punto_gemma() -> Vector3:
	return to_global(Vector3(-larghezza * 0.5 + 0.08, 0.25, -profondita * 0.5 + 0.08))
