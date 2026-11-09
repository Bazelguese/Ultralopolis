extends GutTest
## Ritaglio delle figurine del teatro di carta (Figurina): con un fondo chiaro si toglie il colore
## del fondo, anche nei vuoti chiusi dentro la figura, e il bordo di carta sta attaccato alla figura.

const CREMA: Color = Color(0.92, 0.89, 0.74)
const INCHIOSTRO: Color = Color(0.08, 0.06, 0.05)


## Immagine di prova: fondo crema, una cornice scura (la "figura") con un grande vuoto crema al
## centro e un puntino crema piccolo dentro la parte scura.
func _immagine_di_prova() -> Image:
	var img: Image = Image.create(512, 512, false, Image.FORMAT_RGBA8)
	img.fill(CREMA)
	img.fill_rect(Rect2i(100, 100, 300, 300), INCHIOSTRO)
	img.fill_rect(Rect2i(180, 180, 140, 140), CREMA)
	img.fill_rect(Rect2i(130, 130, 3, 3), CREMA)
	return img


## Valori della maschera (R = figura, G = figura con il bordo) nel punto dell'immagine da 512.
func _maschera_in(maschera: Image, x: int, y: int) -> Color:
	var scala: float = float(maschera.get_width()) / 512.0
	return maschera.get_pixel(int(x * scala), int(y * scala))


func test_il_colore_del_fondo_si_legge_dai_bordi() -> void:
	var colore: Color = Figurina.colore_dei_bordi(_immagine_di_prova())
	assert_almost_eq(colore.r, CREMA.r, 0.01)
	assert_almost_eq(colore.g, CREMA.g, 0.01)
	assert_almost_eq(colore.b, CREMA.b, 0.01)


func test_fondo_chiaro_e_fondo_nero() -> void:
	assert_true(Figurina.e_fondo_chiaro(CREMA))
	assert_false(Figurina.e_fondo_chiaro(Color.BLACK))
	assert_false(Figurina.e_fondo_chiaro(Color(0.1, 0.1, 0.1)))


func test_fondo_chiaro_via_anche_dai_vuoti_chiusi() -> void:
	var maschera: Image = Figurina.maschera_fondo_chiaro(_immagine_di_prova(), CREMA)
	# La parte scura è figura.
	assert_gt(_maschera_in(maschera, 140, 250).r, 0.9, "la cornice scura è figura")
	# Il grande vuoto crema chiuso dentro la figura è fondo: niente figura e niente carta.
	assert_lt(_maschera_in(maschera, 250, 250).r, 0.1, "il vuoto chiuso non è figura")
	assert_lt(_maschera_in(maschera, 250, 250).g, 0.1, "il vuoto chiuso non ha carta")
	# Fuori, lontano dalla figura, è fondo.
	assert_lt(_maschera_in(maschera, 20, 20).g, 0.1, "il fondo esterno è tolto")
	# Il puntino crema piccolo dentro la parte scura resta figura.
	assert_gt(_maschera_in(maschera, 131, 131).r, 0.5, "i puntini chiari piccoli restano")


func test_il_bordo_di_carta_sta_attaccato_alla_figura() -> void:
	var maschera: Image = Figurina.maschera_fondo_chiaro(_immagine_di_prova(), CREMA)
	# Appena fuori dalla figura c'è carta (G) ma non figura (R).
	var appena_fuori: Color = _maschera_in(maschera, 96, 250)
	assert_gt(appena_fuori.g, 0.3, "appena fuori c'è il bordo di carta")
	assert_lt(appena_fuori.r, 0.5, "il bordo di carta non è figura")
	# Poco più in là non c'è più niente: il bordo è sottile.
	assert_lt(_maschera_in(maschera, 80, 250).g, 0.1, "il bordo di carta è sottile")


func test_le_truppe_insettoidi_hanno_il_fondo_chiaro() -> void:
	for nome: String in ["milizia", "arcieri", "lancieri", "esploratori"]:
		var percorso: String = "res://assets/illustrazioni/truppe/%s.png" % nome
		assert_true(ResourceLoader.exists(percorso), "%s c'è" % percorso)
		var trama: Texture2D = load(percorso) as Texture2D
		var img: Image = trama.get_image()
		if img.is_compressed():
			img.decompress()
		img.convert(Image.FORMAT_RGBA8)
		assert_true(Figurina.e_fondo_chiaro(Figurina.colore_dei_bordi(img)), "%s ha il fondo chiaro" % nome)
