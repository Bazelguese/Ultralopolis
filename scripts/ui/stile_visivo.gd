class_name StileVisivo
extends RefCounted
## Stile visivo della prova della plancia 3D: fantasy moderno, colori saturi,
## pezzi come carte con cornice metallica, interfaccia scura e lucida.
## Qui stanno tutti i colori, i caratteri e i materiali: cambiando questo file cambia l'aspetto.
## Solo aspetto: nessuna regola di gioco.

enum Mana { NESSUNO, ROSSO, VERDE, BLU, ENERGETICO, VIOLA }

# Ambiente e superfici.
const NOTTE: Color = Color("0b1220")
const PIETRA_SCURA: Color = Color("161f30")
const PIETRA: Color = Color("2c3a52")
const PIETRA_CHIARA: Color = Color("3f5273")
const FACCIA_CARTA: Color = Color("18213a")
const FASCIA_NOME: Color = Color("0e1526")

# Teatro di carta (scelto da Davide l'8 novembre 2026): buio, una lanterna, plance di carta.
const BUIO: Color = Color("050403")
const LUCE_LANTERNA: Color = Color("ffb067")
const LEGNO_TAVOLO: Color = Color("0c0806")
const CARTA_PLANCIA: Color = Color("3d2f22")
const CARTA_PLANCIA_NEMICO: Color = Color("30221c")
const BRACE: Color = Color("ff7a1a")

# Testi e accenti.
const TESTO: Color = Color("f4f1ea")
const TESTO_TENUE: Color = Color("9fb0cc")
const ORO: Color = Color("f2b632")
const ORO_LUCE: Color = Color("ffd76a")
const PERICOLO: Color = Color("e8423f")
const OMBRA_TESTO: Color = Color("060a12")

## Colore di ciascun lato del tavolo.
const COLORE_GIOCATORE: Color = Color("3fc8ff")
const COLORE_FANTASMA: Color = Color("ff4d6d")

## Cornice delle carte secondo l'era dell'elemento: bronzo, argento, oro (proposta visiva).
const CORNICI_ERA: Dictionary[int, Color] = {
	1: Color("c8834a"),
	2: Color("d4dcea"),
	3: Color("ffcf4a"),
}

const COLORI_MANA: Dictionary[int, Color] = {
	Mana.NESSUNO: Color("8d98ab"),
	Mana.ROSSO: Color("ff4a3d"),
	Mana.VERDE: Color("3ddc6b"),
	Mana.BLU: Color("3d8bff"),
	Mana.ENERGETICO: Color("ffcc33"),
	Mana.VIOLA: Color("b14dff"),
}
const NOMI_MANA: Dictionary[int, String] = {
	Mana.NESSUNO: "nessuno",
	Mana.ROSSO: "rosso",
	Mana.VERDE: "verde",
	Mana.BLU: "blu",
	Mana.ENERGETICO: "energetico",
	Mana.VIOLA: "viola",
}

const FONT_TITOLI: FontFile = preload("res://assets/fonts/BarlowSemiCondensed-ExtraBold.ttf")
const FONT_NUMERI: FontFile = preload("res://assets/fonts/BarlowSemiCondensed-Bold.ttf")
const FONT_TESTO: FontFile = preload("res://assets/fonts/Barlow-Regular.ttf")
const FONT_TESTO_FORTE: FontFile = preload("res://assets/fonts/Barlow-SemiBold.ttf")


static func colore_mana(mana: int) -> Color:
	return COLORI_MANA.get(mana, COLORI_MANA[Mana.NESSUNO])


static func colore_cornice(era: int) -> Color:
	return CORNICI_ERA.get(era, CORNICI_ERA[1])


## Colore del mana dal nome usato nei dati del gioco (&"rosso", &"verde", &"blu", &"viola", &"energetico").
static func colore_mana_nome(nome: StringName) -> Color:
	return colore_mana(mana_da_nome(nome))


static func mana_da_nome(nome: StringName) -> int:
	match nome:
		&"rosso": return Mana.ROSSO
		&"verde": return Mana.VERDE
		&"blu": return Mana.BLU
		&"viola": return Mana.VIOLA
		&"energetico": return Mana.ENERGETICO
	return Mana.NESSUNO


## Cornici che non dipendono dall'era: azioni (opportunità che non sono un edificio o una truppa) e minacce.
## Acciaio: un quarto metallo accanto a bronzo, argento e oro, lontano dai colori del mana
## (scelta di Davide, 8 novembre 2026).
const CORNICE_AZIONE: Color = Color("6f819b")
const CORNICE_MINACCIA: Color = Color("ff4d6d")

## Sabotaggio nello scontro (nastro “Sabotato” sulla tessera e scintille): bianco ghiaccio, “fermo”.
const COLORE_SABOTATO: Color = Color("e3ecf7")
## Corruzione (simbolo sulle tessere, segnalino accanto alla Resistenza, scritte nello scontro):
## magenta scuro, diverso dal mana viola e dal cremisi dei nemici.
const COLORE_CORRUZIONE: Color = Color("c2378a")


# --- Materiali ------------------------------------------------------------------

static func materiale(colore: Color, ruvidezza: float = 0.8, metallo: float = 0.0) -> StandardMaterial3D:
	var risultato: StandardMaterial3D = StandardMaterial3D.new()
	risultato.albedo_color = colore
	risultato.roughness = ruvidezza
	risultato.metallic = metallo
	return risultato


## Metallo lucido delle cornici.
static func materiale_metallo(colore: Color) -> StandardMaterial3D:
	var risultato: StandardMaterial3D = materiale(colore, 0.28, 0.85)
	risultato.metallic_specular = 0.8
	return risultato


## Superficie che emette luce propria (bordi illuminati, barre, gemme).
static func materiale_luminoso(colore: Color, energia: float = 1.5) -> StandardMaterial3D:
	var risultato: StandardMaterial3D = materiale(colore, 0.4)
	risultato.emission_enabled = true
	risultato.emission = colore
	risultato.emission_energy_multiplier = energia
	return risultato


## Superficie trasparente e senza luce (velature, spazi vuoti).
static func materiale_velo(colore: Color) -> StandardMaterial3D:
	var risultato: StandardMaterial3D = StandardMaterial3D.new()
	risultato.albedo_color = colore
	risultato.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	risultato.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return risultato


## Gemma del mana: colore pieno e luminoso.
static func materiale_gemma(mana: int) -> StandardMaterial3D:
	if mana == Mana.NESSUNO:
		return materiale(colore_mana(mana), 0.5)
	var risultato: StandardMaterial3D = materiale_luminoso(colore_mana(mana), 0.35)
	risultato.roughness = 0.2
	risultato.metallic = 0.2
	return risultato


## Pietra: colore con venature leggere ottenute da un rumore (nessuna immagine esterna).
static func materiale_pietra(colore: Color, scala: float = 1.0) -> StandardMaterial3D:
	var rumore: FastNoiseLite = FastNoiseLite.new()
	rumore.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	rumore.frequency = 0.03
	rumore.fractal_octaves = 5
	var sfumatura: Gradient = Gradient.new()
	sfumatura.set_color(0, colore.darkened(0.25))
	sfumatura.set_color(1, colore.lightened(0.04))
	var trama: NoiseTexture2D = NoiseTexture2D.new()
	trama.width = 512
	trama.height = 512
	trama.seamless = true
	trama.noise = rumore
	trama.color_ramp = sfumatura
	var risultato: StandardMaterial3D = materiale(Color.WHITE, 0.75)
	risultato.albedo_texture = trama
	risultato.uv1_scale = Vector3(scala, scala, 1.0)
	return risultato


## Sfumatura verticale per il riquadro dell'illustrazione (segnaposto dell'immagine vera).
static func materiale_illustrazione(colore: Color) -> StandardMaterial3D:
	var sfumatura: Gradient = Gradient.new()
	sfumatura.set_color(0, colore.darkened(0.12))
	sfumatura.set_color(1, colore.darkened(0.72))
	var trama: GradientTexture2D = GradientTexture2D.new()
	trama.gradient = sfumatura
	trama.fill = GradientTexture2D.FILL_RADIAL
	trama.fill_from = Vector2(0.5, 0.35)
	trama.fill_to = Vector2(1.1, 1.0)
	var risultato: StandardMaterial3D = materiale(Color.WHITE, 0.6)
	risultato.albedo_texture = trama
	return risultato


# --- Scritte --------------------------------------------------------------------

## Scritta posata su una superficie piana (rivolta verso l'alto), con contorno scuro.
static func scritta(testo: String, font: Font, dimensione: int, colore: Color, larghezza_px: float = 0.0, contorno: int = 10) -> Label3D:
	var risultato: Label3D = Label3D.new()
	risultato.text = testo
	risultato.font = font
	risultato.font_size = dimensione
	risultato.pixel_size = 0.004
	risultato.modulate = colore
	risultato.outline_size = contorno
	risultato.outline_modulate = OMBRA_TESTO
	risultato.double_sided = false
	risultato.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	risultato.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	risultato.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if larghezza_px > 0.0:
		risultato.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		risultato.width = larghezza_px
	return risultato


# --- Interfaccia 2D -------------------------------------------------------------

## Pannello scuro e semitrasparente con bordo sottile e angoli arrotondati.
static func riquadro(sfondo: Color = Color(0.05, 0.08, 0.14, 0.88), bordo: Color = Color(1.0, 1.0, 1.0, 0.14)) -> StyleBoxFlat:
	var stile: StyleBoxFlat = StyleBoxFlat.new()
	stile.bg_color = sfondo
	stile.border_color = bordo
	stile.set_border_width_all(2)
	stile.set_corner_radius_all(12)
	stile.set_content_margin_all(14)
	stile.shadow_color = Color(0.0, 0.0, 0.0, 0.5)
	stile.shadow_size = 10
	stile.shadow_offset = Vector2(0.0, 4.0)
	stile.anti_aliasing = true
	return stile


static func tema_interfaccia() -> Theme:
	var tema: Theme = Theme.new()
	tema.default_font = FONT_TESTO
	tema.default_font_size = 20
	tema.set_stylebox("panel", "PanelContainer", riquadro())
	tema.set_color("font_color", "Label", TESTO)
	var stati: Dictionary[String, Color] = {
		"normal": Color("1d2840"),
		"hover": Color("2a3a5c"),
		"pressed": Color("141c2e"),
		"focus": Color("1d2840"),
		"disabled": Color("151b28"),
	}
	for stato: String in stati:
		var stile: StyleBoxFlat = riquadro(stati[stato], Color(1.0, 1.0, 1.0, 0.18))
		stile.set_content_margin_all(10)
		stile.content_margin_left = 20
		stile.content_margin_right = 20
		stile.shadow_size = 4
		if stato == "hover":
			stile.border_color = COLORE_GIOCATORE
		if stato == "focus":
			stile.draw_center = false
		tema.set_stylebox(stato, "Button", stile)
	tema.set_color("font_color", "Button", TESTO)
	tema.set_color("font_hover_color", "Button", Color.WHITE)
	tema.set_color("font_pressed_color", "Button", TESTO)
	tema.set_color("font_disabled_color", "Button", TESTO_TENUE)
	tema.set_font("font", "Button", FONT_NUMERI)
	tema.set_font_size("font_size", "Button", 21)
	return tema


## Pulsante che chiede attenzione (es. nessuna tecnologia in studio): rosso, bordo chiaro.
## Con attiva = false torna allo stile normale.
static func rendi_allarme(pulsante: Button, attiva: bool) -> void:
	var nomi: Array[String] = ["normal", "hover", "pressed", "focus"]
	if not attiva:
		for nome: String in nomi:
			pulsante.remove_theme_stylebox_override(nome)
		pulsante.remove_theme_color_override("font_color")
		return
	var normale: StyleBoxFlat = riquadro(PERICOLO.darkened(0.25), ORO_LUCE)
	normale.set_content_margin_all(10)
	var sopra: StyleBoxFlat = riquadro(PERICOLO, Color.WHITE)
	sopra.set_content_margin_all(10)
	pulsante.add_theme_stylebox_override("normal", normale)
	pulsante.add_theme_stylebox_override("hover", sopra)
	pulsante.add_theme_stylebox_override("pressed", normale)
	pulsante.add_theme_stylebox_override("focus", normale)
	pulsante.add_theme_color_override("font_color", Color.WHITE)


## Pulsante principale dorato (azione più importante dello schermo).
static func rendi_principale(pulsante: Button) -> void:
	var normale: StyleBoxFlat = riquadro(ORO, ORO_LUCE)
	normale.set_content_margin_all(12)
	var sopra: StyleBoxFlat = riquadro(ORO_LUCE, Color.WHITE)
	sopra.set_content_margin_all(12)
	var premuto: StyleBoxFlat = riquadro(ORO.darkened(0.15), ORO)
	premuto.set_content_margin_all(12)
	pulsante.add_theme_stylebox_override("normal", normale)
	pulsante.add_theme_stylebox_override("hover", sopra)
	pulsante.add_theme_stylebox_override("pressed", premuto)
	pulsante.add_theme_stylebox_override("focus", normale)
	for nome: String in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		pulsante.add_theme_color_override(nome, NOTTE)
	pulsante.add_theme_font_override("font", FONT_TITOLI)
	pulsante.add_theme_font_size_override("font_size", 30)


static func etichetta(testo: String, font: Font, dimensione: int, colore: Color = TESTO) -> Label:
	var risultato: Label = Label.new()
	risultato.text = testo
	risultato.add_theme_font_override("font", font)
	risultato.add_theme_font_size_override("font_size", dimensione)
	risultato.add_theme_color_override("font_color", colore)
	return risultato
