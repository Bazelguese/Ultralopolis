class_name Tessera3D
extends Node3D
## Un pezzo 2D posato sulla plancia 3D: edificio, truppa o offerta (GDD §14.2).
## È una tessera piatta di pergamena con cornice d'oro, scritte e gemma del mana.
## Solo presentazione: mostra quello che le viene detto, non decide nulla.

const SPESSORE: float = 0.06
const ALTEZZA_SOLLEVATA: float = 0.25

var pezzo: DatiEsempioPlancia.Pezzo
var larghezza: float = 1.4
var profondita: float = 1.7

var _corpo: Node3D
var _materiale_cornice: StandardMaterial3D
var _velo_ricarica: MeshInstance3D
var _nastro_stato: MeshInstance3D
var _materiale_nastro: StandardMaterial3D
var _scritta_stato: Label3D
var _riga: Label3D
var _evidenziata: bool = false
var _animazione_sollevamento: Tween


func costruisci(dati: DatiEsempioPlancia.Pezzo, p_larghezza: float, p_profondita: float) -> void:
	pezzo = dati
	larghezza = p_larghezza
	profondita = p_profondita
	_corpo = Node3D.new()
	add_child(_corpo)
	_crea_supporto()
	_crea_testa()
	_crea_miniatura()
	_crea_scritte()
	_crea_ricarica()
	_crea_nastro_stato()
	if pezzo.malus != "":
		_crea_nastro_malus()
	_crea_area_mouse()


# --- Costruzione -------------------------------------------------------------

func _crea_supporto() -> void:
	var cornice: MeshInstance3D = MeshInstance3D.new()
	var forma_cornice: BoxMesh = BoxMesh.new()
	forma_cornice.size = Vector3(larghezza + 0.1, SPESSORE * 0.8, profondita + 0.1)
	cornice.mesh = forma_cornice
	_materiale_cornice = StileCronaca.materiale_oro()
	cornice.material_override = _materiale_cornice
	cornice.position.y = SPESSORE * 0.4
	_corpo.add_child(cornice)

	var carta: MeshInstance3D = MeshInstance3D.new()
	var forma_carta: BoxMesh = BoxMesh.new()
	forma_carta.size = Vector3(larghezza, SPESSORE, profondita)
	carta.mesh = forma_carta
	carta.material_override = StileCronaca.materiale_pergamena(StileCronaca.PERGAMENA)
	carta.position.y = SPESSORE * 0.5 + 0.006
	_corpo.add_child(carta)


func _superficie() -> float:
	return SPESSORE + 0.008


func _crea_testa() -> void:
	var z: float = -profondita * 0.5 + 0.24
	var gemma: MeshInstance3D = MeshInstance3D.new()
	var forma: CylinderMesh = CylinderMesh.new()
	forma.top_radius = 0.19
	forma.bottom_radius = 0.19
	forma.height = 0.05
	gemma.mesh = forma
	gemma.material_override = StileCronaca.materiale_gemma(pezzo.mana)
	gemma.position = Vector3(-larghezza * 0.5 + 0.27, _superficie() + 0.02, z)
	_corpo.add_child(gemma)
	var testo_gemma: String = "–" if pezzo.mana_numero == 0 else str(pezzo.mana_numero)
	var colore_testo: Color = StileCronaca.INCHIOSTRO if pezzo.mana in [StileCronaca.Mana.NESSUNO, StileCronaca.Mana.ENERGETICO] else Color.WHITE
	var numero: Label3D = StileCronaca.scritta(testo_gemma, StileCronaca.FONT_NUMERI, 46, colore_testo)
	numero.position = gemma.position + Vector3(0.0, 0.03, 0.0)
	_corpo.add_child(numero)

	for i: int in range(3):
		var pallino: MeshInstance3D = MeshInstance3D.new()
		var forma_pallino: CylinderMesh = CylinderMesh.new()
		forma_pallino.top_radius = 0.06
		forma_pallino.bottom_radius = 0.06
		forma_pallino.height = 0.02
		pallino.mesh = forma_pallino
		var pieno: bool = i < pezzo.livello
		pallino.material_override = StileCronaca.materiale(StileCronaca.ORO_SCURO if pieno else StileCronaca.PERGAMENA_SCURA, 0.6)
		pallino.position = Vector3(larghezza * 0.5 - 0.42 + i * 0.16, _superficie(), z)
		_corpo.add_child(pallino)


## Riquadro dell'illustrazione: per ora un capolettera miniato, segnaposto dell'immagine vera.
func _crea_miniatura() -> void:
	var altezza: float = profondita * 0.34
	var riquadro: MeshInstance3D = MeshInstance3D.new()
	var forma: PlaneMesh = PlaneMesh.new()
	forma.size = Vector2(larghezza - 0.24, altezza)
	riquadro.mesh = forma
	var tinta: Color = StileCronaca.colore_mana(pezzo.mana).lerp(StileCronaca.PERGAMENA, 0.62)
	if pezzo.mana == StileCronaca.Mana.NESSUNO:
		tinta = StileCronaca.PERGAMENA_SCURA
	riquadro.material_override = StileCronaca.materiale(tinta, 0.9)
	riquadro.position = Vector3(0.0, _superficie(), -profondita * 0.1)
	_corpo.add_child(riquadro)
	var iniziale: Label3D = StileCronaca.scritta(pezzo.nome.substr(0, 1), StileCronaca.FONT_TITOLI, 150, StileCronaca.VERMIGLIO_SCURO)
	iniziale.position = riquadro.position + Vector3(0.0, 0.004, 0.0)
	_corpo.add_child(iniziale)


func _crea_scritte() -> void:
	var larghezza_px: float = (larghezza - 0.14) / 0.004
	var nome: Label3D = StileCronaca.scritta(pezzo.nome, StileCronaca.FONT_TITOLI, 56, StileCronaca.INCHIOSTRO)
	nome.position = Vector3(0.0, _superficie(), profondita * 0.17)
	_corpo.add_child(nome)
	var riga: Label3D = StileCronaca.scritta(pezzo.riga, StileCronaca.FONT_NUMERI, 40, StileCronaca.INCHIOSTRO, larghezza_px)
	riga.position = Vector3(0.0, _superficie(), profondita * 0.36)
	_corpo.add_child(riga)
	_riga = riga


## Velo scuro che copre la parte di ricarica ancora da compiere.
func _crea_ricarica() -> void:
	_velo_ricarica = MeshInstance3D.new()
	var forma: PlaneMesh = PlaneMesh.new()
	forma.size = Vector2(larghezza, profondita)
	_velo_ricarica.mesh = forma
	_velo_ricarica.material_override = StileCronaca.materiale_velo(Color(0.12, 0.07, 0.03, 0.5))
	_velo_ricarica.position.y = _superficie() + 0.012
	_velo_ricarica.visible = false
	_corpo.add_child(_velo_ricarica)


## Fascia sulla parte bassa della tessera che dice in parole che cosa sta facendo (principio P4).
func _crea_nastro_stato() -> void:
	_nastro_stato = MeshInstance3D.new()
	var forma: PlaneMesh = PlaneMesh.new()
	forma.size = Vector2(larghezza + 0.06, profondita * 0.34)
	_nastro_stato.mesh = forma
	_materiale_nastro = StileCronaca.materiale(StileCronaca.VERMIGLIO_SCURO, 0.8)
	_nastro_stato.material_override = _materiale_nastro
	_nastro_stato.position = Vector3(0.0, _superficie() + 0.02, profondita * 0.5 - profondita * 0.17)
	_nastro_stato.visible = false
	_corpo.add_child(_nastro_stato)
	_scritta_stato = StileCronaca.scritta("", StileCronaca.FONT_NUMERI, 40, Color.WHITE, (larghezza - 0.04) / 0.004)
	_scritta_stato.position = _nastro_stato.position + Vector3(0.0, 0.004, 0.0)
	_scritta_stato.visible = false
	_corpo.add_child(_scritta_stato)


func _crea_nastro_malus() -> void:
	var nastro: MeshInstance3D = MeshInstance3D.new()
	var forma: PlaneMesh = PlaneMesh.new()
	forma.size = Vector2(larghezza * 0.85, 0.28)
	nastro.mesh = forma
	nastro.material_override = StileCronaca.materiale(StileCronaca.VERMIGLIO_SCURO, 0.8)
	nastro.position = Vector3(0.0, _superficie() + 0.006, -profondita * 0.5 - 0.02)
	_corpo.add_child(nastro)
	var scritta: Label3D = StileCronaca.scritta(pezzo.malus.to_upper(), StileCronaca.FONT_NUMERI, 28, StileCronaca.PERGAMENA_CHIARA)
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

## Mouse sopra la tessera: si solleva e la cornice si illumina.
func evidenzia(attiva: bool) -> void:
	if attiva == _evidenziata:
		return
	_evidenziata = attiva
	if _animazione_sollevamento != null and _animazione_sollevamento.is_valid():
		_animazione_sollevamento.kill()
	_animazione_sollevamento = create_tween()
	_animazione_sollevamento.tween_property(_corpo, "position:y", ALTEZZA_SOLLEVATA if attiva else 0.0, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_materiale_cornice.emission_enabled = attiva
	_materiale_cornice.emission = StileCronaca.ORO_LUCE
	_materiale_cornice.emission_energy_multiplier = 0.9


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
	_riga.visible = not visibile
	_materiale_nastro.albedo_color = colore
	_scritta_stato.modulate = StileCronaca.INCHIOSTRO if colore.get_luminance() > 0.55 else Color.WHITE


## Attivazione in battaglia: balzo verso l'avversario e lampo dorato.
## verso: -1 se l'avversario è lontano dalla telecamera, +1 se è vicino.
func attiva(verso: float) -> void:
	var animazione: Tween = create_tween()
	animazione.tween_property(_corpo, "position", Vector3(0.0, 0.45, 0.35 * verso), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	animazione.parallel().tween_property(_corpo, "rotation:z", deg_to_rad(5.0), 0.1)
	animazione.tween_property(_corpo, "rotation:z", deg_to_rad(-5.0), 0.08)
	animazione.tween_property(_corpo, "position", Vector3.ZERO, 0.22).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	animazione.parallel().tween_property(_corpo, "rotation:z", 0.0, 0.22)
	_materiale_cornice.emission_enabled = true
	_materiale_cornice.emission = StileCronaca.ORO_LUCE
	_materiale_cornice.emission_energy_multiplier = 2.5
	var spegni: Tween = create_tween()
	spegni.tween_interval(0.25)
	spegni.tween_callback(_spegni_lampo)


func _spegni_lampo() -> void:
	_materiale_cornice.emission_enabled = _evidenziata
	_materiale_cornice.emission_energy_multiplier = 0.9


## Punto da cui parte (edifici) o a cui arriva (truppe) il mana.
func punto_gemma() -> Vector3:
	return to_global(Vector3(-larghezza * 0.5 + 0.27, 0.2, -profondita * 0.5 + 0.24))
