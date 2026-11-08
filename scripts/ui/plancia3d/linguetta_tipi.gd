class_name LinguettaTipi
extends Control
## La linguetta dei tipi sopra una carta (richiesta di Davide): una striscia del colore della
## cornice che sporge dal bordo alto, come la linguetta di una cartellina, con un medaglione
## per ogni tipo della tessera o del consigliere (GDD §6.6). Solo presentazione.

## Misure in unità della plancia: diametro di un medaglione e quanto la linguetta sta sotto la carta.
const DIAMETRO: float = 0.33
const BORDO: float = DIAMETRO * 0.12
const SOTTO_LA_CARTA: float = BORDO * 1.5

var tipi: Array[StringName] = []
var colore: Color = StileVisivo.ORO
## Pixel per unità della plancia.
var scala: float = 150.0


## Misura della linguetta in unità della plancia, per un certo numero di tipi.
static func misura(quanti: int) -> Vector2:
	var lunghezza: float = BORDO * 2.0 + DIAMETRO * 0.24 + quanti * DIAMETRO * 1.12
	return Vector2(lunghezza, DIAMETRO + BORDO * 2.2 + SOTTO_LA_CARTA)


func imposta(p_tipi: Array[StringName], p_colore: Color, p_scala: float) -> void:
	tipi = p_tipi
	colore = p_colore
	scala = p_scala
	size = misura(tipi.size()) * scala
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _draw() -> void:
	var diametro: float = DIAMETRO * scala
	var bordo: float = BORDO * scala
	var raggio: int = int(diametro * 0.35)
	var fondo: StyleBoxFlat = StyleBoxFlat.new()
	fondo.bg_color = colore
	fondo.anti_aliasing = true
	fondo.corner_radius_top_left = raggio
	fondo.corner_radius_top_right = raggio
	draw_style_box(fondo, Rect2(Vector2.ZERO, size))
	var interno: StyleBoxFlat = fondo.duplicate() as StyleBoxFlat
	interno.bg_color = StileVisivo.FACCIA_CARTA
	interno.corner_radius_top_left = maxi(1, raggio - int(bordo))
	interno.corner_radius_top_right = maxi(1, raggio - int(bordo))
	draw_style_box(interno, Rect2(Vector2(bordo, bordo), size - Vector2(bordo * 2.0, bordo)))
	var centro_y: float = bordo + (size.y - SOTTO_LA_CARTA * scala - bordo) * 0.5 + bordo * 0.3
	for i: int in range(tipi.size()):
		var centro: Vector2 = Vector2(bordo + diametro * 0.62 + i * diametro * 1.12, centro_y)
		DisegnoSimboli.medaglione(self, Simboli.di_tipo(tipi[i]), centro, diametro)
