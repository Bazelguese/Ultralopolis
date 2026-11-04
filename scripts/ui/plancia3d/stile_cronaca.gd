class_name StileCronaca
extends RefCounted
## Colori, caratteri e materiali dello stile "Cronaca miniata" (prova visiva della plancia 3D).
## Solo aspetto: qui non c'è nessuna regola di gioco.

enum Mana { NESSUNO, ROSSO, VERDE, BLU, ENERGETICO }

const PERGAMENA: Color = Color("f3e6c6")
const PERGAMENA_CHIARA: Color = Color("f8efd9")
const PERGAMENA_SCURA: Color = Color("dcc79a")
const PERGAMENA_FANTASMA: Color = Color("e4dccd")
const INCHIOSTRO: Color = Color("2b1d14")
const INCHIOSTRO_TENUE: Color = Color("6b5640")
const ORO_FOGLIA: Color = Color("c9a243")
const ORO_SCURO: Color = Color("8a6a1f")
const ORO_LUCE: Color = Color("f3d36b")
const VERMIGLIO_SCURO: Color = Color("7a1f12")
const SIENA: Color = Color("a0522d")
const LEGNO_SCURO: Color = Color("1f140c")
const LEGNO_CHIARO: Color = Color("4a301d")
const FOGLIO_GIOCATORE: Color = Color("d9c393")
const FOGLIO_FANTASMA: Color = Color("c9bfac")

## Colore di ogni mana: i pigmenti della miniatura (vermiglio, malachite, lapislazzuli, oro).
const COLORI_MANA: Dictionary[int, Color] = {
	Mana.NESSUNO: Color("ece0c2"),
	Mana.ROSSO: Color("b3321e"),
	Mana.VERDE: Color("2e7a4c"),
	Mana.BLU: Color("2f4f9a"),
	Mana.ENERGETICO: Color("d8a62a"),
}
const NOMI_MANA: Dictionary[int, String] = {
	Mana.NESSUNO: "nessuno",
	Mana.ROSSO: "rosso",
	Mana.VERDE: "verde",
	Mana.BLU: "blu",
	Mana.ENERGETICO: "energetico",
}

const FONT_TITOLI: FontFile = preload("res://assets/fonts/IMFellEnglishSC-Regular.ttf")
const FONT_TESTO: FontFile = preload("res://assets/fonts/Alegreya-Variable.ttf")
const FONT_NUMERI: FontFile = preload("res://assets/fonts/AlegreyaSans-Bold.ttf")
const FONT_PICCOLO: FontFile = preload("res://assets/fonts/AlegreyaSans-Regular.ttf")


static func colore_mana(mana: int) -> Color:
	return COLORI_MANA.get(mana, COLORI_MANA[Mana.NESSUNO])


static func materiale(colore: Color, ruvidezza: float = 0.85, metallo: float = 0.0) -> StandardMaterial3D:
	var risultato: StandardMaterial3D = StandardMaterial3D.new()
	risultato.albedo_color = colore
	risultato.roughness = ruvidezza
	risultato.metallic = metallo
	return risultato


## Foglia d'oro delle cornici: metallica e un po' lucida.
static func materiale_oro() -> StandardMaterial3D:
	var risultato: StandardMaterial3D = materiale(ORO_FOGLIA, 0.38, 0.75)
	return risultato


## Superficie trasparente e senza luce (velature, ombre di ricarica, spazi vuoti).
static func materiale_velo(colore: Color) -> StandardMaterial3D:
	var risultato: StandardMaterial3D = StandardMaterial3D.new()
	risultato.albedo_color = colore
	risultato.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	risultato.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return risultato


## Gemma di mana: colore pieno, leggermente luminosa.
static func materiale_gemma(mana: int) -> StandardMaterial3D:
	var colore: Color = colore_mana(mana)
	var risultato: StandardMaterial3D = materiale(colore, 0.25, 0.3 if mana == Mana.ENERGETICO else 0.0)
	if mana != Mana.NESSUNO:
		risultato.emission_enabled = true
		risultato.emission = colore
		risultato.emission_energy_multiplier = 0.35
	return risultato


## Legno del tavolo: venatura ottenuta da un rumore allungato (nessuna immagine esterna).
static func materiale_legno() -> StandardMaterial3D:
	var rumore: FastNoiseLite = FastNoiseLite.new()
	rumore.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	rumore.frequency = 0.02
	rumore.fractal_octaves = 3
	var sfumatura: Gradient = Gradient.new()
	sfumatura.set_color(0, LEGNO_SCURO)
	sfumatura.set_color(1, LEGNO_CHIARO)
	var trama: NoiseTexture2D = NoiseTexture2D.new()
	trama.width = 512
	trama.height = 512
	trama.seamless = true
	trama.noise = rumore
	trama.color_ramp = sfumatura
	var risultato: StandardMaterial3D = materiale(Color.WHITE, 0.7)
	risultato.albedo_texture = trama
	risultato.uv1_scale = Vector3(0.6, 7.0, 1.0)
	return risultato


## Pergamena: colore caldo con macchie leggere.
static func materiale_pergamena(colore: Color) -> StandardMaterial3D:
	var rumore: FastNoiseLite = FastNoiseLite.new()
	rumore.noise_type = FastNoiseLite.TYPE_CELLULAR
	rumore.frequency = 0.03
	var sfumatura: Gradient = Gradient.new()
	sfumatura.set_color(0, colore.darkened(0.08))
	sfumatura.set_color(1, colore.lightened(0.04))
	var trama: NoiseTexture2D = NoiseTexture2D.new()
	trama.width = 256
	trama.height = 256
	trama.seamless = true
	trama.noise = rumore
	trama.color_ramp = sfumatura
	var risultato: StandardMaterial3D = materiale(Color.WHITE, 0.95)
	risultato.albedo_texture = trama
	return risultato


## Scritta posata su una superficie piana (rivolta verso l'alto).
static func scritta(testo: String, font: Font, dimensione: int, colore: Color, larghezza_px: float = 0.0) -> Label3D:
	var risultato: Label3D = Label3D.new()
	risultato.text = testo
	risultato.font = font
	risultato.font_size = dimensione
	risultato.pixel_size = 0.004
	risultato.modulate = colore
	risultato.outline_size = 0
	risultato.double_sided = false
	risultato.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	risultato.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	risultato.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if larghezza_px > 0.0:
		risultato.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		risultato.width = larghezza_px
	return risultato


## Tema dell'interfaccia 2D: pergamena, inchiostro, bordo d'oro.
static func tema_interfaccia() -> Theme:
	var tema: Theme = Theme.new()
	tema.default_font = FONT_TESTO
	tema.default_font_size = 20
	tema.set_stylebox("panel", "PanelContainer", riquadro(PERGAMENA))
	tema.set_color("font_color", "Label", INCHIOSTRO)
	var stati: Dictionary[String, Color] = {
		"normal": PERGAMENA_CHIARA,
		"hover": Color("fff6dd"),
		"pressed": PERGAMENA_SCURA,
		"focus": PERGAMENA_CHIARA,
		"disabled": PERGAMENA_SCURA,
	}
	for stato: String in stati:
		var stile: StyleBoxFlat = riquadro(stati[stato])
		stile.set_content_margin_all(10)
		stile.content_margin_left = 18
		stile.content_margin_right = 18
		if stato == "hover":
			stile.border_color = ORO_LUCE
		if stato == "focus":
			stile.draw_center = false
		tema.set_stylebox(stato, "Button", stile)
	tema.set_color("font_color", "Button", INCHIOSTRO)
	tema.set_color("font_hover_color", "Button", INCHIOSTRO)
	tema.set_color("font_pressed_color", "Button", INCHIOSTRO)
	tema.set_color("font_disabled_color", "Button", INCHIOSTRO_TENUE)
	tema.set_font("font", "Button", FONT_NUMERI)
	tema.set_font_size("font_size", "Button", 19)
	return tema


static func riquadro(sfondo: Color) -> StyleBoxFlat:
	var stile: StyleBoxFlat = StyleBoxFlat.new()
	stile.bg_color = sfondo
	stile.border_color = ORO_FOGLIA
	stile.set_border_width_all(2)
	stile.set_corner_radius_all(3)
	stile.set_content_margin_all(12)
	stile.shadow_color = Color(0.0, 0.0, 0.0, 0.45)
	stile.shadow_size = 8
	stile.shadow_offset = Vector2(0.0, 3.0)
	return stile


static func etichetta(testo: String, font: Font, dimensione: int, colore: Color = INCHIOSTRO) -> Label:
	var risultato: Label = Label.new()
	risultato.text = testo
	risultato.add_theme_font_override("font", font)
	risultato.add_theme_font_size_override("font_size", dimensione)
	risultato.add_theme_color_override("font_color", colore)
	return risultato
