class_name FlussoAnno
extends Control
## Il flusso dell'anno, in verticale a sinistra (GDD §3.2, v0.25): una riga per stagione con i
## suoi tre mesi e lo scontro che la chiude, e il mese in corso. Nei mesi della stagione in corso
## un'icona disegnata dice il tema del round. Solo presentazione: legge RunState.

const LATO_MESE: float = 38.0
const ALTEZZA_MESE: float = 34.0
const LATO_SCONTRO: float = 34.0
const SPAZIO: float = 4.0
const SPAZIO_STAGIONE: float = 10.0
## Colonna con il nome della stagione, a sinistra dei mesi.
const LARGHEZZA_NOME: float = 100.0
const INIZIALI: PackedStringArray = ["G", "F", "M", "A", "M", "G", "L", "A", "S", "O", "N", "D"]

const COLORE_AZIONI: Color = Color("9fb0c8")
const COLORE_EDIFICI: Color = Color("ffd76a")
const COLORE_TRUPPE: Color = Color("ff8a7a")
const COLORE_INVERNO: Color = Color("bfe3ff")

var _run: RunState
## Rettangoli delle caselle, per i tooltip: [Rect2, testo].
var _zone: Array[Array] = []


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	custom_minimum_size = Vector2(_larghezza_totale(), 4.0 * ALTEZZA_MESE + 3.0 * SPAZIO_STAGIONE + 2.0)
	Suggerimenti.imposta_dinamico(self, testo_suggerimento, "", casella_suggerimento)


func aggiorna(run: RunState) -> void:
	_run = run
	_prepara_zone()
	queue_redraw()


static func _larghezza_totale() -> float:
	return LARGHEZZA_NOME + 3.0 * LATO_MESE + 2.0 * SPAZIO + SPAZIO_STAGIONE + LATO_SCONTRO + 2.0


## La casella sotto il mouse: il suggerimento le si attacca (vuoto fuori dalle caselle).
func casella_suggerimento(at_position: Vector2) -> Rect2:
	for zona: Array in _zone:
		if (zona[0] as Rect2).has_point(at_position):
			return zona[0]
	return Rect2()


## Il testo del suggerimento della casella sotto il mouse (vuoto fuori dalle caselle).
func testo_suggerimento(at_position: Vector2) -> String:
	for zona: Array in _zone:
		if (zona[0] as Rect2).has_point(at_position):
			return zona[1]
	return ""


## Posizione e testo di ogni casella: [Rect2, tooltip, stagione, mese (0 = scontro), tema].
func _prepara_zone() -> void:
	_zone = []
	if _run == null:
		return
	var mese_corrente: int = _run.month() if _run.is_shopping_phase() else -1
	var temi: Array[int] = _run.season_round_themes()
	for stagione: int in range(4):
		var x: float = LARGHEZZA_NOME
		var y: float = stagione * (ALTEZZA_MESE + SPAZIO_STAGIONE)
		var attuale: bool = stagione == int(_run.season)
		for i: int in range(3):
			var mese: int = stagione * 3 + i + 1
			var tema: int = temi[i] if attuale and i < temi.size() else -1
			var testo: String = "%s · %s" % [RunState.MONTH_NAMES[mese - 1], RunState.SEASON_NAMES[stagione]]
			if tema >= 0:
				testo += " · tema %s" % RunState.THEME_NAMES[tema]
			if mese == mese_corrente:
				testo += " (adesso)"
			elif stagione == int(RunState.Season.INVERNO):
				testo += " · niente Cibo, nessuno scontro"
			_zone.append([Rect2(x, y, LATO_MESE, ALTEZZA_MESE), testo, stagione, mese, tema])
			x += LATO_MESE + (SPAZIO if i < 2 else 0.0)
		x += SPAZIO_STAGIONE
		if stagione >= int(RunState.Season.PRIMAVERA):
			_zone.append([Rect2(x, y, LATO_SCONTRO, ALTEZZA_MESE), _testo_scontro(stagione), stagione, 0, -1])


func _draw() -> void:
	if _run == null:
		return
	var font: Font = StileVisivo.FONT_TITOLI
	var mese_corrente: int = _run.month() if _run.is_shopping_phase() else -1
	# Nome di ogni stagione a sinistra della sua riga; la stagione in corso ha una freccia.
	for stagione: int in range(4):
		var primo: Rect2 = _zone[_indice_primo_mese(stagione)][0]
		var attuale: bool = stagione == int(_run.season)
		var passata: bool = stagione < int(_run.season)
		var colore_testa: Color = StileVisivo.ORO_LUCE if attuale else (StileVisivo.TESTO_TENUE if not passata else Color(StileVisivo.TESTO_TENUE, 0.45))
		var y_testo: float = primo.position.y + primo.size.y * 0.5 + 5.0
		if attuale:
			draw_colored_polygon(PackedVector2Array([Vector2(2.0, y_testo - 10.0), Vector2(10.0, y_testo - 5.0), Vector2(2.0, y_testo)]), StileVisivo.ORO_LUCE)
		draw_string(font, Vector2(14.0, y_testo), RunState.SEASON_NAMES[stagione].to_upper(),
				HORIZONTAL_ALIGNMENT_LEFT, LARGHEZZA_NOME - 18.0, 14, colore_testa)
		if stagione == int(RunState.Season.INVERNO):
			_fiocco(Vector2(LARGHEZZA_NOME - 8.0, y_testo - 14.0), 5.0, Color(COLORE_INVERNO, 0.9 if not passata else 0.4))
	for zona: Array in _zone:
		if int(zona[3]) > 0:
			_casella_mese(zona[0], int(zona[3]), mese_corrente, int(zona[2]), int(zona[4]), font)
		else:
			_casella_scontro(zona[0], int(zona[2]))


## Posizione in _zone del primo mese di una stagione (dopo la primavera c'è anche uno scontro).
static func _indice_primo_mese(stagione: int) -> int:
	return stagione * 3 + maxi(0, stagione - 1)


func _casella_mese(rettangolo: Rect2, mese: int, mese_corrente: int, stagione: int, tema: int, font: Font) -> void:
	var passato: bool = stagione < int(_run.season) or (stagione == int(_run.season) and (mese_corrente < 0 or mese < mese_corrente))
	var corrente: bool = mese == mese_corrente
	var fondo: Color = StileVisivo.PIETRA_SCURA
	if stagione == int(RunState.Season.INVERNO):
		fondo = Color("1b2a40")
	if corrente:
		fondo = Color(StileVisivo.ORO, 0.28)
	elif passato:
		fondo = Color(StileVisivo.PIETRA_SCURA, 0.5)
	draw_rect(rettangolo, fondo, true)
	draw_rect(rettangolo, StileVisivo.ORO_LUCE if corrente else Color(StileVisivo.PIETRA_CHIARA, 0.5 if passato else 1.0), false, 2.0 if corrente else 1.0)
	var centro: Vector2 = rettangolo.get_center()
	if tema >= 0:
		_icona_tema(tema, centro, 11.0, 1.0 if not passato or corrente else 0.4)
	else:
		draw_string(font, Vector2(rettangolo.position.x, centro.y + 6.0), INIZIALI[mese - 1], HORIZONTAL_ALIGNMENT_CENTER,
				rettangolo.size.x, 16, Color(StileVisivo.TESTO_TENUE, 0.4 if passato else 0.85))


func _casella_scontro(rettangolo: Rect2, stagione: int) -> void:
	var adesso: bool = false
	var passato: bool = stagione < int(_run.season) or (stagione == int(_run.season) and not _run.is_shopping_phase())
	if stagione == int(_run.season):
		if stagione == int(RunState.Season.AUTUNNO):
			adesso = _run.phase == RunState.Phase.SCONTRO_FANTASMA
		else:
			adesso = _run.phase in [RunState.Phase.SCELTA_INCONTRO, RunState.Phase.RICOMPENSA_INCONTRO]
	if adesso:
		passato = false
	var colore: Color = StileVisivo.COLORE_FANTASMA
	draw_rect(rettangolo, Color(colore, 0.32 if adesso else 0.12), true)
	draw_rect(rettangolo, Color(colore, 1.0 if adesso else (0.35 if passato else 0.8)), false, 2.0 if adesso else 1.0)
	var centro: Vector2 = rettangolo.get_center()
	var alfa: float = 0.4 if passato else 1.0
	if stagione == int(RunState.Season.AUTUNNO):
		_fantasma(centro, 10.0, Color(colore, alfa))
	else:
		_spade_incrociate(centro, 11.0, Color(colore, alfa))
	# Esito dell'incontro già giocato: pallino verde (vinto) o rosso (perso).
	var esito: String = _esito_incontro(stagione)
	if esito != "":
		draw_circle(rettangolo.position + Vector2(rettangolo.size.x - 5.0, 5.0), 3.5,
				Color("3fae6a") if esito == "Vittoria" or esito == "Pareggio" else StileVisivo.PERICOLO)


func _esito_incontro(stagione: int) -> String:
	if stagione >= int(RunState.Season.AUTUNNO) or _run.history.is_empty():
		return ""
	var esiti: PackedStringArray = _run.history[-1].encounter_result.split(" · ", false)
	var indice: int = stagione - int(RunState.Season.PRIMAVERA)
	return esiti[indice] if indice < esiti.size() else ""


func _testo_scontro(stagione: int) -> String:
	match stagione:
		int(RunState.Season.PRIMAVERA):
			return "Fine primavera: incontro del mondo, 1 fra 3."
		int(RunState.Season.ESTATE):
			return "Fine estate: incontro del mondo, più forte di quello di primavera."
	return "Fine autunno: scontro con il fantasma, che chiude l'anno."


# --- Icone disegnate (niente emoji) -----------------------------------------------------

func _icona_tema(tema: int, centro: Vector2, r: float, alfa: float) -> void:
	match tema:
		RunState.RoundTheme.AZIONI:
			_stella(centro, r, Color(COLORE_AZIONI, alfa))
		RunState.RoundTheme.EDIFICI:
			_casa(centro, r, Color(COLORE_EDIFICI, alfa))
		RunState.RoundTheme.TRUPPE:
			_spada(centro, r, Color(COLORE_TRUPPE, alfa))
		_:
			_casa(centro + Vector2(-r * 0.55, 0.0), r * 0.62, Color(COLORE_EDIFICI, alfa))
			_spada(centro + Vector2(r * 0.6, 0.0), r * 0.62, Color(COLORE_TRUPPE, alfa))


func _stella(centro: Vector2, r: float, colore: Color) -> void:
	var punti: PackedVector2Array = PackedVector2Array()
	for i: int in range(10):
		var raggio: float = r if i % 2 == 0 else r * 0.45
		var angolo: float = -PI / 2.0 + i * PI / 5.0
		punti.append(centro + Vector2(cos(angolo), sin(angolo)) * raggio)
	draw_colored_polygon(punti, colore)


func _casa(centro: Vector2, r: float, colore: Color) -> void:
	var tetto: PackedVector2Array = PackedVector2Array([centro + Vector2(-r, -r * 0.05), centro + Vector2(0.0, -r), centro + Vector2(r, -r * 0.05)])
	draw_colored_polygon(tetto, colore)
	draw_rect(Rect2(centro + Vector2(-r * 0.72, -r * 0.05), Vector2(r * 1.44, r * 0.95)), colore, true)
	draw_rect(Rect2(centro + Vector2(-r * 0.2, r * 0.35), Vector2(r * 0.4, r * 0.55)), StileVisivo.NOTTE, true)


func _spada(centro: Vector2, r: float, colore: Color, angolo: float = 0.0) -> void:
	draw_set_transform(centro, angolo)
	draw_colored_polygon(PackedVector2Array([Vector2(-r * 0.16, r * 0.35), Vector2(-r * 0.16, -r * 0.75), Vector2(0.0, -r),
			Vector2(r * 0.16, -r * 0.75), Vector2(r * 0.16, r * 0.35)]), colore)
	draw_rect(Rect2(Vector2(-r * 0.5, r * 0.32), Vector2(r, r * 0.16)), colore, true)
	draw_rect(Rect2(Vector2(-r * 0.1, r * 0.48), Vector2(r * 0.2, r * 0.38)), colore, true)
	draw_circle(Vector2(0.0, r * 0.92), r * 0.14, colore)
	draw_set_transform(Vector2.ZERO, 0.0)


func _spade_incrociate(centro: Vector2, r: float, colore: Color) -> void:
	_spada(centro, r, colore, deg_to_rad(40.0))
	_spada(centro, r, colore, deg_to_rad(-40.0))


func _fantasma(centro: Vector2, r: float, colore: Color) -> void:
	draw_circle(centro + Vector2(0.0, -r * 0.25), r * 0.75, colore)
	draw_rect(Rect2(centro + Vector2(-r * 0.75, -r * 0.25), Vector2(r * 1.5, r * 0.9)), colore, true)
	for i: int in range(3):
		var x: float = -r * 0.75 + r * 0.5 * i
		draw_colored_polygon(PackedVector2Array([centro + Vector2(x, r * 0.64), centro + Vector2(x + r * 0.5, r * 0.64),
				centro + Vector2(x + r * 0.25, r)]), colore)
	draw_circle(centro + Vector2(-r * 0.28, -r * 0.3), r * 0.15, StileVisivo.NOTTE)
	draw_circle(centro + Vector2(r * 0.28, -r * 0.3), r * 0.15, StileVisivo.NOTTE)


func _fiocco(centro: Vector2, r: float, colore: Color) -> void:
	for i: int in range(3):
		var angolo: float = i * PI / 3.0
		var verso: Vector2 = Vector2(cos(angolo), sin(angolo)) * r
		draw_line(centro - verso, centro + verso, colore, 1.5)
