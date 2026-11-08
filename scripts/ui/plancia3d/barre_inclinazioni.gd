class_name BarreInclinazioni
extends Control
## Le quattro inclinazioni della nazione (GDD §9.6, v0.29), disegnate come barre fra due poli:
## il segno si sposta verso il polo a cui la nazione tende. Solo presentazione.

const ALTEZZA_RIGA: float = 22.0
const LARGHEZZA_NOME: float = 104.0
const COLORE_PIU: Color = Color("f2b632")
const COLORE_MENO: Color = Color("7fb4ff")

var _valori: PackedInt32Array = Inclination.empty()
var _limite: int = 5


func _init() -> void:
	custom_minimum_size = Vector2(320, ALTEZZA_RIGA * Inclination.Axis.size())
	mouse_filter = Control.MOUSE_FILTER_STOP


func aggiorna(valori: PackedInt32Array, limite: int, testo_aiuto: String) -> void:
	_valori = valori.duplicate()
	_limite = maxi(1, limite)
	Suggerimenti.imposta(self, testo_aiuto, "Inclinazioni")
	queue_redraw()


func _draw() -> void:
	var font: Font = StileVisivo.FONT_TESTO
	var larghezza_barra: float = size.x - LARGHEZZA_NOME * 2.0
	for asse: int in range(Inclination.Axis.size()):
		var y: float = asse * ALTEZZA_RIGA
		var valore: int = _valori[asse] if asse < _valori.size() else 0
		var meno: String = Inclination.MINUS_POLE[asse as Inclination.Axis]
		var piu: String = Inclination.PLUS_POLE[asse as Inclination.Axis]
		var colore_meno: Color = COLORE_MENO if valore < 0 else StileVisivo.TESTO_TENUE
		var colore_piu: Color = COLORE_PIU if valore > 0 else StileVisivo.TESTO_TENUE
		draw_string(font, Vector2(0.0, y + 16.0), meno, HORIZONTAL_ALIGNMENT_RIGHT, LARGHEZZA_NOME - 8.0, 14, colore_meno)
		draw_string(font, Vector2(LARGHEZZA_NOME + larghezza_barra + 8.0, y + 16.0), piu, HORIZONTAL_ALIGNMENT_LEFT, LARGHEZZA_NOME - 8.0, 14, colore_piu)
		var barra: Rect2 = Rect2(LARGHEZZA_NOME, y + 8.0, larghezza_barra, 6.0)
		draw_rect(barra, Color(1.0, 1.0, 1.0, 0.12))
		var centro: float = barra.position.x + barra.size.x * 0.5
		draw_line(Vector2(centro, y + 5.0), Vector2(centro, y + 17.0), Color(1.0, 1.0, 1.0, 0.35), 1.0)
		if valore != 0:
			var fine: float = centro + barra.size.x * 0.5 * float(valore) / float(_limite)
			var pieno: Rect2 = Rect2(minf(centro, fine), barra.position.y, absf(fine - centro), barra.size.y)
			draw_rect(pieno, COLORE_PIU if valore > 0 else COLORE_MENO)
			draw_circle(Vector2(fine, barra.position.y + 3.0), 5.0, COLORE_PIU if valore > 0 else COLORE_MENO)
		else:
			draw_circle(Vector2(centro, barra.position.y + 3.0), 4.0, StileVisivo.TESTO_TENUE)
