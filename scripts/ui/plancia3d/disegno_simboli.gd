class_name DisegnoSimboli
extends RefCounted
## Disegna le righe di simboli (RigaSimboli) su qualsiasi superficie 2D: la faccia delle carte
## e la legenda dei simboli usano lo stesso codice, così si vedono uguali.
## Solo presentazione.


## Una riga nella sua pastiglia. Il fondo dice quanto conta (RigaSimboli.Rilievo):
## principale = colore della carta ("accento"), normale = scuro, secondaria = solo un bordo
## sottile e un po' più bassa. Dorata se la riga è "accesa", tenue se è spenta.
static func pastiglia(tela: CanvasItem, riga: RigaSimboli, area: Rect2, accento: Color = StileVisivo.CORNICE_AZIONE) -> void:
	var dove: Rect2 = area
	var fondo: StyleBoxFlat = StyleBoxFlat.new()
	fondo.bg_color = Color(0.0, 0.0, 0.0, 0.18 if riga.spenta else 0.32)
	var bordo: int = maxi(2, int(area.size.y * 0.05))
	match riga.rilievo:
		RigaSimboli.Rilievo.PRINCIPALE:
			fondo.bg_color = Color(accento.darkened(0.45), 0.95)
			fondo.border_color = accento.lightened(0.1)
			fondo.set_border_width_all(bordo)
		RigaSimboli.Rilievo.SECONDARIA:
			dove = area.grow_individual(-area.size.y * 0.08, -area.size.y * 0.12, -area.size.y * 0.08, -area.size.y * 0.12)
			fondo.bg_color = Color(0.0, 0.0, 0.0, 0.12)
			fondo.border_color = Color(StileVisivo.TESTO_TENUE, 0.55)
			fondo.set_border_width_all(maxi(1, bordo - 1))
	if riga.accesa:
		# Una riga secondaria accesa resta più sobria della principale: bordo dorato, fondo appena dorato.
		var secondaria: bool = riga.rilievo == RigaSimboli.Rilievo.SECONDARIA
		fondo.bg_color = Color(StileVisivo.ORO.darkened(0.6), 0.55) if secondaria else Color(StileVisivo.ORO.darkened(0.35), 0.85)
		fondo.border_color = StileVisivo.ORO_LUCE
		fondo.set_border_width_all(maxi(1, bordo - 1) if secondaria else bordo)
	fondo.set_corner_radius_all(int(dove.size.y * 0.3))
	fondo.anti_aliasing = true
	tela.draw_style_box(fondo, dove)
	disegna_riga(tela, riga, dove)


## Larghezza che serve a una riga, con il margine della sua pastiglia, se è alta "altezza".
static func larghezza_pastiglia(riga: RigaSimboli, altezza: float) -> float:
	return larghezza_riga(riga, StileVisivo.FONT_TITOLI, int(altezza * 0.56), altezza * 0.8, altezza * 0.1) + altezza * 0.4


static func disegna_riga(tela: CanvasItem, riga: RigaSimboli, area: Rect2) -> void:
	var font: Font = StileVisivo.FONT_TITOLI
	var lato_icona: float = area.size.y * 0.8
	var carattere: int = int(area.size.y * 0.56)
	var stacco: float = area.size.y * 0.1
	var disponibile: float = area.size.x - area.size.y * 0.4
	var larghezza: float = larghezza_riga(riga, font, carattere, lato_icona, stacco)
	if larghezza > disponibile and larghezza > 0.0:
		var fattore: float = disponibile / larghezza
		lato_icona *= fattore
		stacco *= fattore
		carattere = maxi(8, int(carattere * fattore))
		larghezza = larghezza_riga(riga, font, carattere, lato_icona, stacco)
	var opacita: float = 0.38 if riga.spenta else 1.0
	var centro_y: float = area.get_center().y
	var x: float = area.get_center().x - larghezza * 0.5
	for i: int in range(riga.simboli.size()):
		var voce: RigaSimboli.Simbolo = riga.simboli[i]
		if i > 0:
			x += stacco
		if voce.testo != "":
			var colore: Color = colore_tono(voce.tono)
			colore.a = opacita
			var linea_base: float = centro_y + (font.get_ascent(carattere) - font.get_descent(carattere)) * 0.5
			var ombra: Color = StileVisivo.OMBRA_TESTO
			ombra.a = opacita
			tela.draw_string_outline(font, Vector2(x, linea_base), voce.testo, HORIZONTAL_ALIGNMENT_LEFT, -1.0, carattere, maxi(2, int(carattere * 0.16)), ombra)
			tela.draw_string(font, Vector2(x, linea_base), voce.testo, HORIZONTAL_ALIGNMENT_LEFT, -1.0, carattere, colore)
			x += font.get_string_size(voce.testo, HORIZONTAL_ALIGNMENT_LEFT, -1.0, carattere).x
			if voce.icona != &"" or voce.gemma != &"":
				x += stacco * 0.3
		if voce.icona != &"":
			_disegna_icona(tela, voce, Rect2(x, centro_y - lato_icona * 0.5, lato_icona, lato_icona), opacita)
			x += lato_icona
		elif voce.gemma != &"":
			var colore_gemma: Color = StileVisivo.colore_mana_nome(voce.gemma)
			colore_gemma.a = opacita
			var centro: Vector2 = Vector2(x + lato_icona * 0.5, centro_y)
			_esagono(tela, centro, lato_icona * 0.42, Color(StileVisivo.NOTTE, opacita))
			_esagono(tela, centro, lato_icona * 0.36, colore_gemma)
			x += lato_icona


## Larghezza di una riga con queste misure: serve a centrarla e a rimpicciolirla se non entra.
static func larghezza_riga(riga: RigaSimboli, font: Font, carattere: int, lato_icona: float, stacco: float) -> float:
	var larghezza: float = 0.0
	for i: int in range(riga.simboli.size()):
		var voce: RigaSimboli.Simbolo = riga.simboli[i]
		if i > 0:
			larghezza += stacco
		if voce.testo != "":
			larghezza += font.get_string_size(voce.testo, HORIZONTAL_ALIGNMENT_LEFT, -1.0, carattere).x
			if voce.icona != &"" or voce.gemma != &"":
				larghezza += stacco * 0.3
		if voce.icona != &"" or voce.gemma != &"":
			larghezza += lato_icona
	return larghezza


## Un simbolo: l'immagine di assets/icone; se manca, un cerchio con l'iniziale del concetto.
## Gli spazi della plancia hanno una cornice tratteggiata, i potenziamenti una freccia in su.
static func _disegna_icona(tela: CanvasItem, voce: RigaSimboli.Simbolo, quadro: Rect2, opacita: float) -> void:
	var bianco: Color = Color(1.0, 1.0, 1.0, opacita)
	if voce.tipo:
		medaglione(tela, voce.icona, quadro.get_center(), quadro.size.x, opacita)
		return
	var dentro: Rect2 = quadro
	if voce.spazio:
		var tratto: Color = Color(StileVisivo.TESTO_TENUE, opacita)
		var spessore: float = maxf(1.5, quadro.size.x * 0.06)
		var trattino: float = maxf(2.0, quadro.size.x * 0.14)
		var angoli: PackedVector2Array = PackedVector2Array([quadro.position, Vector2(quadro.end.x, quadro.position.y), quadro.end, Vector2(quadro.position.x, quadro.end.y)])
		for i: int in range(4):
			tela.draw_dashed_line(angoli[i], angoli[(i + 1) % 4], tratto, spessore, trattino)
		dentro = quadro.grow(-quadro.size.x * 0.2)
	var trama: Texture2D = Simboli.trama(voce.icona, dentro.size.x)
	if trama != null:
		tela.draw_texture_rect(trama, dentro, false, bianco)
	else:
		var raggio: float = dentro.size.x * 0.45
		tela.draw_circle(dentro.get_center(), raggio, Color(StileVisivo.PIETRA_CHIARA, opacita))
		var iniziale: String = String(voce.icona).substr(0, 1).to_upper()
		var misura: int = maxi(8, int(dentro.size.y * 0.6))
		var font: Font = StileVisivo.FONT_TITOLI
		var larghezza: float = font.get_string_size(iniziale, HORIZONTAL_ALIGNMENT_LEFT, -1.0, misura).x
		var linea_base: float = dentro.get_center().y + (font.get_ascent(misura) - font.get_descent(misura)) * 0.5
		tela.draw_string(font, Vector2(dentro.get_center().x - larghezza * 0.5, linea_base), iniziale, HORIZONTAL_ALIGNMENT_LEFT, -1.0, misura, bianco)
	if voce.su:
		# Freccia del potenziamento, in alto a destra del simbolo.
		var punta: float = quadro.size.x * 0.34
		var base: Vector2 = Vector2(quadro.end.x - punta * 0.5, quadro.position.y + punta * 0.55)
		var freccia: PackedVector2Array = PackedVector2Array([base + Vector2(0.0, -punta * 0.55), base + Vector2(punta * 0.5, punta * 0.3), base + Vector2(-punta * 0.5, punta * 0.3)])
		tela.draw_colored_polygon(freccia, Color(StileVisivo.ORO_LUCE, opacita))


## Colore dei numeri secondo il loro ruolo: oro per i costi, rosso per i malus (colori riservati
## della direzione artistica), bianco per il resto, tenue per frecce e separatori.
static func colore_tono(tono: RigaSimboli.Tono) -> Color:
	match tono:
		RigaSimboli.Tono.COSTO:
			return StileVisivo.ORO_LUCE
		RigaSimboli.Tono.MALUS:
			return StileVisivo.PERICOLO.lightened(0.15)
		RigaSimboli.Tono.SEPARATORE:
			return StileVisivo.TESTO_TENUE
	return StileVisivo.TESTO


static func _esagono(tela: CanvasItem, centro: Vector2, raggio: float, colore: Color) -> void:
	var punti: PackedVector2Array = PackedVector2Array()
	for i: int in range(6):
		var angolo: float = deg_to_rad(60.0 * i - 90.0)
		punti.append(centro + Vector2(cos(angolo), sin(angolo)) * raggio)
	tela.draw_colored_polygon(punti, colore)


## Il medaglione di un tipo di tessera: tondo scuro con un bordo sottile e il simbolo bianco.
## La forma tonda distingue i tipi dalle risorse; i tipi non hanno colore (GDD §6.6).
static func medaglione(tela: CanvasItem, concetto: StringName, centro: Vector2, diametro: float, opacita: float = 1.0) -> void:
	var raggio: float = diametro * 0.5
	tela.draw_circle(centro, raggio, Color(StileVisivo.TESTO_TENUE, 0.75 * opacita))
	tela.draw_circle(centro, raggio - maxf(1.5, diametro * 0.05), Color(StileVisivo.NOTTE, 0.92 * opacita))
	var lato: float = diametro * 0.6
	var trama: Texture2D = Simboli.trama(concetto, lato)
	if trama != null:
		tela.draw_texture_rect(trama, Rect2(centro - Vector2(lato, lato) * 0.5, Vector2(lato, lato)), false, Color(1.0, 1.0, 1.0, opacita))
