class_name Tessera3D
extends Node3D
## Un pezzo 2D posato sulla plancia 3D: edificio, truppa, offerta, incontro (GDD §14.2).
## La faccia è disegnata in 2D (FacciaCarta) dentro un SubViewport e applicata a una
## carta sottile con spessore e ombra. Solo presentazione: mostra, non decide.

const SPESSORE: float = 0.07
const ALTEZZA_SOLLEVATA: float = 0.3
## Pixel della faccia per unità di lunghezza: più alto = carta più nitida.
const PIXEL_PER_UNITA: float = 150.0

## Prove delle tessere in rilievo (Davide, 9 novembre 2026), solo per i pezzi della plancia.
## rilievo: lastrina di cartone spessa, bordo dorato in rilievo, stemmi dei numeri che sporgono.
## diorama: il disegno a strati, con la figura staccata dallo sfondo. Provvisorie finché non si sceglie.
static var rilievo: bool = false
static var diorama: bool = false
const SPESSORE_RILIEVO: float = 0.16
## Di quanto la figura del diorama si alza dalla carta (0 = distesa, 90 = in piedi).
const INCLINAZIONE_DIORAMA: float = 40.0

var scheda: SchedaCarta
var _spessore: float = SPESSORE
var larghezza: float = 1.6
var profondita: float = 1.9
## Per chi usa la tessera (es. posizione nella fila, indice dell'offerta).
var indice: int = -1

var _corpo: Node3D
var _viewport: SubViewport
var _faccia: FacciaCarta
var _materiale_alone: StandardMaterial3D
var _materiale_faccia: StandardMaterial3D
var _alone: MeshInstance3D
var _velo: MeshInstance3D
var _evidenziata: bool = false
var _colore_alone: Color = Color(0.0, 0.0, 0.0, 0.0)
var _animazione_sollevamento: Tween
## Quanto si ingrandisce la carta con il mouse sopra. Le carte con le righe di simboli
## (consiglieri, azioni, eventi) si ingrandiscono molto, perché i simboli si leggano bene.
var ingrandimento: float = 1.06
var _segnale: Label3D
## Teatro di carta: la figura che si alza dalla carta (solo per i pezzi sulla plancia).
var figurina: Figurina
## Il punto più alto della carta (bordo o mezzo busto), in coordinate della carta.
var _alto_locale: float = 0.0


func costruisci(p_scheda: SchedaCarta, p_larghezza: float, p_profondita: float, nitidezza: float = 1.0) -> void:
	scheda = p_scheda
	larghezza = p_larghezza
	profondita = p_profondita
	var in_rilievo: bool = rilievo and scheda.sulla_plancia
	if in_rilievo:
		_spessore = SPESSORE_RILIEVO
	scheda.diorama = diorama and scheda.sulla_plancia and not scheda.come_base and scheda.illustrazione != null
	_corpo = Node3D.new()
	add_child(_corpo)
	_crea_faccia(nitidezza)
	_crea_linguetta(nitidezza)
	if in_rilievo:
		_crea_rilievo()
	else:
		_crea_supporto()
	if scheda.diorama:
		_crea_diorama()
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
	# Cartoncino opaco: niente riflessi biancastri della lanterna.
	materiale.roughness = 0.9
	materiale.metallic_specular = 0.15
	materiale.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
	carta.material_override = materiale
	_materiale_faccia = materiale
	carta.position.y = _spessore + 0.002
	_corpo.add_child(carta)


## La linguetta dei tipi sotto la carta (GDD §14.4, Davide 8 novembre 2026): un pezzo attaccato alla
## carta, che si solleva e si ingrandisce con lei. Allineata a sinistra se c'è posto, altrimenti centrata.
func _crea_linguetta(nitidezza: float) -> void:
	if scheda.tipi.is_empty():
		return
	var misura: Vector2 = LinguettaTipi.misura(scheda.tipi.size())
	var scala: float = PIXEL_PER_UNITA * nitidezza
	var viewport: SubViewport = SubViewport.new()
	viewport.size = Vector2i(int(misura.x * scala), int(misura.y * scala))
	viewport.transparent_bg = true
	viewport.disable_3d = true
	viewport.gui_disable_input = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	add_child(viewport)
	var linguetta: LinguettaTipi = LinguettaTipi.new()
	viewport.add_child(linguetta)
	linguetta.imposta(scheda.tipi, scheda.colore_cornice(), scala, true)
	var piano: MeshInstance3D = MeshInstance3D.new()
	var forma: PlaneMesh = PlaneMesh.new()
	forma.size = misura
	piano.mesh = forma
	var materiale: StandardMaterial3D = StandardMaterial3D.new()
	materiale.albedo_texture = viewport.get_texture()
	materiale.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	materiale.alpha_scissor_threshold = 0.5
	materiale.roughness = 1.0
	materiale.metallic_specular = 0.05
	materiale.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
	piano.material_override = materiale
	var rientro: float = minf(larghezza * 0.08, maxf(0.0, (larghezza - misura.x) * 0.5))
	# I tipi stanno sotto la carta (Davide, 8 novembre 2026): sopra c'è la figura.
	var z_linguetta: float = profondita * 0.5 + misura.y * 0.5 - LinguettaTipi.SOTTO_LA_CARTA
	piano.position = Vector3(-larghezza * 0.5 + rientro + misura.x * 0.5, _spessore * 0.6, z_linguetta)
	_corpo.add_child(piano)


## Spessore scuro sotto la faccia: dà profondità e proietta l'ombra.
func _crea_supporto() -> void:
	var spessore: MeshInstance3D = MeshInstance3D.new()
	var forma: BoxMesh = BoxMesh.new()
	var rientro: float = minf(larghezza, profondita) * 0.07
	forma.size = Vector3(larghezza - rientro, _spessore, profondita - rientro)
	spessore.mesh = forma
	spessore.material_override = StileVisivo.materiale(scheda.colore_cornice().darkened(0.55), 0.6, 0.4)
	spessore.position.y = _spessore * 0.5
	_corpo.add_child(spessore)


## Tessera in rilievo: una lastrina di cartone spessa dagli angoli tondi, un bordo dorato che
## sporge sopra la faccia e gli stemmi dei numeri rialzati come medaglie.
func _crea_rilievo() -> void:
	var lato: float = minf(larghezza, profondita)
	var raggio: float = lato * 0.08
	var cornice: Color = scheda.colore_cornice()
	# Il corpo di cartone, con una fascia più chiara in cima (gli strati della carta).
	var corpo: CSGPolygon3D = CSGPolygon3D.new()
	corpo.polygon = _rettangolo_tondo(larghezza, profondita, raggio)
	corpo.depth = _spessore - 0.03
	corpo.rotation.x = -PI * 0.5
	# (CSGPolygon3D ruotato così si estrude verso il basso: la posizione è la faccia di sopra.)
	corpo.position.y = _spessore - 0.03
	corpo.material = StileVisivo.materiale(cornice.darkened(0.62), 0.85)
	_corpo.add_child(corpo)
	var labbro: CSGPolygon3D = CSGPolygon3D.new()
	labbro.polygon = _rettangolo_tondo(larghezza, profondita, raggio)
	labbro.depth = 0.03
	labbro.rotation.x = -PI * 0.5
	labbro.position.y = _spessore
	labbro.material = StileVisivo.materiale(cornice.darkened(0.3), 0.6, 0.5)
	_corpo.add_child(labbro)
	# Il bordo dorato in rilievo: un anello sopra la cornice disegnata.
	var bordo: float = lato * 0.06
	var anello: CSGPolygon3D = CSGPolygon3D.new()
	anello.polygon = _rettangolo_tondo(larghezza, profondita, raggio)
	anello.depth = 0.035
	anello.rotation.x = -PI * 0.5
	anello.position.y = _spessore + 0.035
	anello.material = StileVisivo.materiale(cornice.lightened(0.25), 0.25, 0.9)
	var vuoto: CSGPolygon3D = CSGPolygon3D.new()
	vuoto.operation = CSGShape3D.OPERATION_SUBTRACTION
	vuoto.polygon = _rettangolo_tondo(larghezza - bordo * 2.0, profondita - bordo * 2.0, maxf(raggio - bordo, 0.01))
	vuoto.depth = 0.2
	vuoto.position.z = 0.05
	anello.add_child(vuoto)
	_corpo.add_child(anello)
	# Gli stemmi dei numeri: un pezzo della faccia, rialzato su una basetta scura.
	for area: Rect2 in _faccia.aree_stemmi():
		var w: float = area.size.x * larghezza
		var d: float = area.size.y * profondita
		var centro: Vector3 = Vector3((area.get_center().x - 0.5) * larghezza, 0.0, (area.get_center().y - 0.5) * profondita)
		var base: CSGPolygon3D = CSGPolygon3D.new()
		base.polygon = _rettangolo_tondo(w, d, d * 0.38)
		base.depth = 0.08
		base.rotation.x = -PI * 0.5
		base.position = centro + Vector3(0.0, _spessore + 0.08, 0.0)
		base.material = StileVisivo.materiale(Color("0b0806"), 0.7)
		_corpo.add_child(base)
		var stemma: MeshInstance3D = MeshInstance3D.new()
		var piano: PlaneMesh = PlaneMesh.new()
		piano.size = Vector2(w, d)
		stemma.mesh = piano
		var materiale: StandardMaterial3D = _materiale_faccia.duplicate() as StandardMaterial3D
		materiale.uv1_scale = Vector3(area.size.x, area.size.y, 1.0)
		materiale.uv1_offset = Vector3(area.position.x, area.position.y, 0.0)
		materiale.roughness = 0.45
		materiale.metallic_specular = 0.5
		stemma.material_override = materiale
		stemma.position = centro + Vector3(0.0, _spessore + 0.082, 0.0)
		_corpo.add_child(stemma)


## Diorama: sulla faccia resta lo sfondo sfocato del disegno; la figura ritagliata si alza dal
## fondo della scena inclinata all'indietro, come in un libro pop-up socchiuso, e proietta la sua
## ombra sullo sfondo.
func _crea_diorama() -> void:
	var area: Rect2 = _faccia.area_arte_normalizzata()
	var ritaglio: Array = Figurina.ritaglia(scheda.illustrazione)
	# Il ritaglio è un quadrato con dentro il disegno (3:2 o 2:3) appoggiato in basso.
	var dimensioni: Vector2 = Vector2(scheda.illustrazione.get_size())
	var quota: Vector2 = dimensioni / maxf(dimensioni.x, dimensioni.y)
	var lato_figura: float = minf(area.size.x * larghezza / quota.x, profondita * 1.15 / quota.y)
	var fondo_z: float = (area.end.y - 0.5) * profondita - 0.04
	var perno: Node3D = Node3D.new()
	perno.position = Vector3((area.get_center().x - 0.5) * larghezza, _spessore + 0.01, fondo_z)
	perno.rotation.x = deg_to_rad(INCLINAZIONE_DIORAMA)
	_corpo.add_child(perno)
	var figura: MeshInstance3D = MeshInstance3D.new()
	var piano: PlaneMesh = PlaneMesh.new()
	piano.size = Vector2(lato_figura, lato_figura)
	figura.mesh = piano
	figura.material_override = Figurina.materiale_carta(ritaglio[0], ritaglio[1])
	figura.position = Vector3(0.0, 0.0, -lato_figura * 0.5)
	perno.add_child(figura)
	# La piega di carta alla base della figura.
	var piega: MeshInstance3D = MeshInstance3D.new()
	var scatola: BoxMesh = BoxMesh.new()
	scatola.size = Vector3(lato_figura * quota.x * 0.5, 0.02, 0.08)
	piega.mesh = scatola
	piega.material_override = StileVisivo.materiale(Color("120d0a"), 0.9)
	piega.position = Vector3(perno.position.x, _spessore + 0.012, fondo_z + 0.02)
	_corpo.add_child(piega)


static func _rettangolo_tondo(w: float, d: float, raggio: float) -> PackedVector2Array:
	var punti: PackedVector2Array = PackedVector2Array()
	var r: float = minf(raggio, minf(w, d) * 0.5)
	var angoli: Array[Vector2] = [Vector2(w * 0.5 - r, d * 0.5 - r), Vector2(-w * 0.5 + r, d * 0.5 - r), Vector2(-w * 0.5 + r, -d * 0.5 + r), Vector2(w * 0.5 - r, -d * 0.5 + r)]
	for k: int in range(4):
		for passo: int in range(7):
			var a: float = PI * 0.5 * k + PI * 0.5 * float(passo) / 6.0
			punti.append(angoli[k] + Vector2(cos(a), sin(a)) * r)
	return punti


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
	_velo.position.y = _spessore + 0.02
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

## Carta con le righe di simboli: con il mouse sopra si ingrandisce di "valore".
## Il riflesso della luce la farebbe sembrare sbiadita, quindi la sua faccia è opaca:
## così i simboli restano netti.
func imposta_ingrandimento(valore: float) -> void:
	ingrandimento = valore
	_materiale_faccia.metallic_specular = 0.05
	_materiale_faccia.roughness = 1.0


## Mouse sopra la carta: si solleva e si ingrandisce un poco.
func evidenzia(attiva: bool) -> void:
	if attiva == _evidenziata:
		return
	_evidenziata = attiva
	if _animazione_sollevamento != null and _animazione_sollevamento.is_valid():
		_animazione_sollevamento.kill()
	_animazione_sollevamento = create_tween()
	_animazione_sollevamento.set_parallel(true)
	# Più la carta si ingrandisce, più si alza: così passa sopra alle vicine.
	var altezza: float = ALTEZZA_SOLLEVATA * maxf(1.0, ingrandimento * 2.0 - 1.0)
	_animazione_sollevamento.tween_property(_corpo, "position:y", altezza if attiva else 0.0, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_animazione_sollevamento.tween_property(_corpo, "scale", Vector3.ONE * (ingrandimento if attiva else 1.0), 0.14)
	# Le carte che si ingrandiscono molto crescono verso il basso: il bordo alto (o il mezzo busto)
	# resta dov'era e non esce dallo schermo (Davide, 9 novembre 2026).
	_animazione_sollevamento.tween_property(_corpo, "position:z", spostamento_ingrandimento() if attiva else 0.0, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	_aggiorna_alone()


## Di quanto si sposta la carta ingrandita perché il suo bordo alto resti fermo.
func spostamento_ingrandimento() -> float:
	if ingrandimento <= 1.2:
		return 0.0
	var alto: float = minf(-profondita * 0.5, _alto_locale)
	return -alto * (ingrandimento - 1.0)


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
		var sotto_tipi: float = 0.0 if scheda.tipi.is_empty() else LinguettaTipi.misura(scheda.tipi.size()).y - LinguettaTipi.SOTTO_LA_CARTA
		_segnale.position = Vector3(0.0, _spessore + 0.03, profondita * 0.5 + 0.3 + sotto_tipi)
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
	# Le righe di simboli possono cambiare anche senza cambiare carta (es. un'opzione che
	# diventa pagabile dopo una vendita al mercato): si ridisegnano senza ricostruire la carta.
	var simboli_cambiati: bool = _testo_simboli(nuova) != _testo_simboli(_faccia.scheda)
	scheda = nuova
	if simboli_cambiati:
		_faccia.imposta_simboli(nuova.simboli)
	if cambiata:
		_faccia.imposta_disponibile(nuova.disponibile)
	if cambiata or simboli_cambiati:
		_ridisegna()


static func _testo_simboli(p_scheda: SchedaCarta) -> String:
	var testo: String = ""
	for riga: RigaSimboli in p_scheda.simboli:
		testo += "%s%s%s\n" % ["(spenta) " if riga.spenta else "", "(accesa) " if riga.accesa else "", riga.come_testo()]
	return testo


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
	if figurina != null:
		figurina.scatta()
	var lampo: Color = _colore_alone
	imposta_alone(Color(colore, 0.8))
	var spegni: Tween = create_tween()
	spegni.tween_interval(0.25)
	spegni.tween_callback(imposta_alone.bind(lampo))


## Consiglieri e avvenimenti con un'illustrazione: il mezzo busto esce dall'alto della carta, come
## i ritratti nei dialoghi dei giochi di ruolo (Davide, 8 novembre 2026).
func con_busto() -> bool:
	return scheda.genere == SchedaCarta.Genere.CONSIGLIERE and scheda.illustrazione != null


## Il mezzo busto ritagliato: poggia sul fondo della finestra del disegno e sporge oltre il bordo alto.
func aggiungi_busto() -> void:
	if not con_busto():
		return
	var larghezza_busto: float = larghezza * 1.08
	var altezza_busto: float = larghezza_busto * Figurina.QUOTA_BUSTO
	var busto: MeshInstance3D = MeshInstance3D.new()
	var forma: QuadMesh = QuadMesh.new()
	forma.size = Vector2(larghezza_busto, altezza_busto)
	forma.orientation = PlaneMesh.FACE_Y
	busto.mesh = forma
	var ritaglio: Array = Figurina.ritaglia(scheda.illustrazione)
	busto.material_override = Figurina.materiale_carta(ritaglio[0], ritaglio[1], Figurina.QUOTA_BUSTO)
	var fondo: float = -profondita * 0.5 + profondita * _faccia.fondo_arte()
	busto.position = Vector3(0.0, _spessore + 0.014, fondo - altezza_busto * 0.5)
	_alto_locale = minf(_alto_locale, fondo - altezza_busto)
	_corpo.add_child(busto)
	# Esce dalla finestra con un piccolo salto.
	busto.scale = Vector3(0.85, 1.0, 0.6)
	var t: Tween = create_tween()
	t.tween_interval(0.25)
	t.tween_property(busto, "scale", Vector3.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Teatro di carta: la figurina ritagliata dall'illustrazione si alza dal bordo della carta.
## verso: -1 se l'avversario è lontano dalla telecamera, +1 se è vicino.
## Senza illustrazione non c'è figurina.
func aggiungi_figurina(verso: float, ritardo: float, animata: bool, fattore_altezza: float = 0.95) -> void:
	if scheda.illustrazione == null or figurina != null:
		return
	figurina = Figurina.new()
	_corpo.add_child(figurina)
	var z_base: float = -profondita * 0.5 + profondita * _faccia.centro_arte()
	figurina.costruisci(scheda.illustrazione, larghezza, z_base, _spessore, verso, fattore_altezza)
	if animata:
		figurina.alza(ritardo)
	else:
		figurina.in_piedi()


## Figurina grigia: la truppa aspetta il mana o è sabotata (principio P4). 0 = normale, 1 = spenta.
func imposta_spenta(valore: float) -> void:
	if figurina != null:
		figurina.imposta_spenta(valore)


## Piccola scossa (per esempio quando un edificio produce mana).
func pulsa() -> void:
	var animazione: Tween = create_tween()
	animazione.tween_property(_corpo, "scale", Vector3.ONE * 1.06, 0.07)
	animazione.tween_property(_corpo, "scale", Vector3.ONE, 0.12)
	if figurina != null:
		figurina.lampeggia(0.5)


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
