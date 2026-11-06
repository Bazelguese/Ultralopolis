class_name Tessera3D
extends Node3D
## Un pezzo 2D posato sulla plancia 3D: edificio, truppa, offerta, incontro (GDD §14.2).
## La faccia è disegnata in 2D (FacciaCarta) dentro un SubViewport e applicata a una
## carta sottile con spessore e ombra. Solo presentazione: mostra, non decide.

const SPESSORE: float = 0.07
const ALTEZZA_SOLLEVATA: float = 0.3
## Pixel della faccia per unità di lunghezza: più alto = carta più nitida.
const PIXEL_PER_UNITA: float = 150.0

var scheda: SchedaCarta
var larghezza: float = 1.6
var profondita: float = 1.9
## Per chi usa la tessera (es. posizione nella fila, indice dell'offerta).
var indice: int = -1

var _corpo: Node3D
var _viewport: SubViewport
var _faccia: FacciaCarta
var _materiale_alone: StandardMaterial3D
var _alone: MeshInstance3D
var _velo: MeshInstance3D
var _evidenziata: bool = false
var _colore_alone: Color = Color(0.0, 0.0, 0.0, 0.0)
var _animazione_sollevamento: Tween
var _segnale: Label3D


func costruisci(p_scheda: SchedaCarta, p_larghezza: float, p_profondita: float, nitidezza: float = 1.0) -> void:
	scheda = p_scheda
	larghezza = p_larghezza
	profondita = p_profondita
	_corpo = Node3D.new()
	add_child(_corpo)
	_crea_faccia(nitidezza)
	_crea_supporto()
	_crea_alone()
	_crea_velo()
	_crea_area_mouse()


func _crea_faccia(nitidezza: float) -> void:
	var misura: Vector2 = Vector2(larghezza, profondita) * PIXEL_PER_UNITA * nitidezza
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(int(misura.x), int(misura.y))
	_viewport.transparent_bg = true
	_viewport.disable_3d = true
	_viewport.gui_disable_input = true
	_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	add_child(_viewport)
	_faccia = FacciaCarta.new()
	_viewport.add_child(_faccia)
	_faccia.imposta(scheda, misura)

	var carta: MeshInstance3D = MeshInstance3D.new()
	var forma: PlaneMesh = PlaneMesh.new()
	forma.size = Vector2(larghezza, profondita)
	carta.mesh = forma
	var materiale: StandardMaterial3D = StandardMaterial3D.new()
	materiale.albedo_texture = _viewport.get_texture()
	materiale.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	materiale.alpha_scissor_threshold = 0.5
	materiale.roughness = 0.45
	materiale.metallic_specular = 0.6
	materiale.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
	carta.material_override = materiale
	carta.position.y = SPESSORE + 0.002
	_corpo.add_child(carta)


## Spessore scuro sotto la faccia: dà profondità e proietta l'ombra.
func _crea_supporto() -> void:
	var spessore: MeshInstance3D = MeshInstance3D.new()
	var forma: BoxMesh = BoxMesh.new()
	var rientro: float = minf(larghezza, profondita) * 0.07
	forma.size = Vector3(larghezza - rientro, SPESSORE, profondita - rientro)
	spessore.mesh = forma
	spessore.material_override = StileVisivo.materiale(scheda.colore_cornice().darkened(0.55), 0.6, 0.4)
	spessore.position.y = SPESSORE * 0.5
	_corpo.add_child(spessore)


## Alone luminoso sotto la carta: mouse sopra, selezione, bersaglio di una sostituzione.
func _crea_alone() -> void:
	_alone = MeshInstance3D.new()
	var forma: PlaneMesh = PlaneMesh.new()
	forma.size = Vector2(larghezza + 0.4, profondita + 0.4)
	_alone.mesh = forma
	_materiale_alone = StileVisivo.materiale_velo(Color(1.0, 1.0, 1.0, 0.0))
	_materiale_alone.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	_alone.material_override = _materiale_alone
	_alone.position.y = 0.012
	_alone.visible = false
	add_child(_alone)


## Velo scuro che copre la parte di ricarica ancora da compiere.
func _crea_velo() -> void:
	_velo = MeshInstance3D.new()
	var forma: PlaneMesh = PlaneMesh.new()
	var rientro: float = minf(larghezza, profondita) * 0.05
	forma.size = Vector2(larghezza - rientro, profondita - rientro)
	_velo.mesh = forma
	_velo.material_override = StileVisivo.materiale_velo(Color(0.02, 0.04, 0.09, 0.6))
	_velo.position.y = SPESSORE + 0.02
	_velo.visible = false
	_corpo.add_child(_velo)


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


func _ridisegna() -> void:
	_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE


# --- Stati e animazioni --------------------------------------------------------

## Mouse sopra la carta: si solleva e si ingrandisce un poco.
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
	_aggiorna_alone()


## Scritta sopra il bordo alto della carta, es. "POTENZIA" quando la si può potenziare (P4).
## Testo vuoto per toglierla.
func imposta_segnale(testo: String, colore: Color = StileVisivo.ORO_LUCE) -> void:
	if testo == "":
		if _segnale != null:
			_segnale.visible = false
		return
	if _segnale == null:
		_segnale = StileVisivo.scritta(testo, StileVisivo.FONT_TITOLI, 44, colore, 0.0, 14)
		# Sotto la carta: sopra ci sono già i prezzi delle offerte.
		_segnale.position = Vector3(0.0, SPESSORE + 0.03, profondita * 0.5 + 0.3)
		_corpo.add_child(_segnale)
	_segnale.text = testo
	_segnale.modulate = colore
	_segnale.visible = true


func ha_segnale() -> bool:
	return _segnale != null and _segnale.visible


## Colore dell'alone fisso (selezione, bersaglio). Trasparente per toglierlo.
func imposta_alone(colore: Color) -> void:
	_colore_alone = colore
	_aggiorna_alone()


func _aggiorna_alone() -> void:
	var colore: Color = _colore_alone
	if _evidenziata and colore.a <= 0.0:
		colore = Color(scheda.colore_cornice(), 0.35)
	_alone.visible = colore.a > 0.0
	_materiale_alone.albedo_color = colore


## La stessa carta con dati aggiornati (es. ora si può pagare): niente ricostruzione,
## si ridisegna la faccia solo se cambia la disponibilità.
func aggiorna_scheda(nuova: SchedaCarta) -> void:
	var cambiata: bool = nuova.disponibile != _faccia.scheda.disponibile
	scheda = nuova
	if cambiata:
		_faccia.imposta_disponibile(nuova.disponibile)
		_ridisegna()


## frazione: 0 = appena attivata, 1 = pronta.
func imposta_ricarica(frazione: float) -> void:
	var resto: float = clampf(1.0 - frazione, 0.0, 1.0)
	_velo.visible = resto > 0.001
	_velo.scale = Vector3(1.0, 1.0, maxf(resto, 0.001))
	_velo.position.z = -profondita * 0.475 + profondita * 0.95 * resto * 0.5


## Fascia di stato sulla parte bassa della carta (principio P4). Vuoto per toglierla.
func imposta_stato(testo: String, colore: Color) -> void:
	if testo == _faccia.stato and colore == _faccia.colore_stato:
		return
	_faccia.imposta_stato(testo, colore)
	_ridisegna()


## Attivazione in battaglia: balzo verso l'avversario e scintille del colore del mana.
## verso: -1 se l'avversario è lontano dalla telecamera, +1 se è vicino.
func attiva(verso: float) -> void:
	var animazione: Tween = create_tween()
	animazione.tween_property(_corpo, "position", Vector3(0.0, 0.55, 0.45 * verso), 0.09).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	animazione.parallel().tween_property(_corpo, "scale", Vector3.ONE * 1.12, 0.09)
	animazione.tween_property(_corpo, "position", Vector3.ZERO, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	animazione.parallel().tween_property(_corpo, "scale", Vector3.ONE, 0.28)
	var colore: Color = StileVisivo.ORO_LUCE if scheda.mana == &"" else StileVisivo.colore_mana_nome(scheda.mana)
	scintille(colore, Vector3(0.0, 0.3, 0.0))
	var lampo: Color = _colore_alone
	imposta_alone(Color(colore, 0.8))
	var spegni: Tween = create_tween()
	spegni.tween_interval(0.25)
	spegni.tween_callback(imposta_alone.bind(lampo))


## Piccola scossa (per esempio quando un edificio produce mana).
func pulsa() -> void:
	var animazione: Tween = create_tween()
	animazione.tween_property(_corpo, "scale", Vector3.ONE * 1.06, 0.07)
	animazione.tween_property(_corpo, "scale", Vector3.ONE, 0.12)


## Esplosione di scintille (usata anche dalla scena per i colpi).
func scintille(colore: Color, dove: Vector3, quante: int = 26) -> void:
	var particelle: CPUParticles3D = CPUParticles3D.new()
	var goccia: SphereMesh = SphereMesh.new()
	goccia.radius = 0.05
	goccia.height = 0.1
	goccia.material = StileVisivo.materiale_luminoso(colore, 4.0)
	particelle.mesh = goccia
	particelle.amount = quante
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
	particelle.position = dove
	add_child(particelle)
	particelle.emitting = true
	var pulizia: Tween = create_tween()
	pulizia.tween_interval(1.0)
	pulizia.tween_callback(particelle.queue_free)


## Punto da cui parte (edifici) o a cui arriva (truppe) il mana: la gemma nell'angolo.
func punto_gemma() -> Vector3:
	var lato: float = minf(larghezza, profondita)
	return to_global(Vector3(-larghezza * 0.5 + lato * 0.13, 0.25, -profondita * 0.5 + lato * 0.13))
