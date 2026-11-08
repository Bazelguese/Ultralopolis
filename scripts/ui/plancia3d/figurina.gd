class_name Figurina
extends Node3D
## Teatro di carta (scelta di Davide, 8 novembre 2026): la figura dell'illustrazione, ritagliata
## come una figurina di carta, che si alza dal bordo posteriore della carta come in un libro pop-up.
## Il ritaglio si fa da solo: si toglie il fondo nero che tocca i bordi dell'immagine (non le linee
## d'inchiostro dentro la figura) e si aggiunge un bordo di carta color crema.
## Solo presentazione: nessuna regola di gioco.

const COLORE_CARTA: Color = Color("ece2cc")
## Sotto questa luminosità un pixel del fondo conta come nero.
const SOGLIA_NERO: float = 0.15
## Lato dell'immagine su cui si calcola la sagoma (più piccolo = più veloce, contorno più morbido).
const LATO_MASCHERA: int = 128
## Lato dell'immagine finale della figurina.
const LATO_FIGURA: int = 256

const SHADER: String = """
shader_type spatial;
render_mode cull_disabled, depth_draw_opaque;
uniform sampler2D tex : source_color, filter_linear_mipmap;
uniform sampler2D rumore;
uniform float bruciatura = 0.0;
uniform float lampo = 0.0;
uniform float spento = 0.0;
void fragment() {
	vec4 c = texture(tex, UV);
	float n = texture(rumore, UV).r;
	float a = c.a;
	if (bruciatura > 0.001 && n < bruciatura) { a = 0.0; }
	float bordo = (bruciatura > 0.001) ? smoothstep(bruciatura + 0.07, bruciatura, n) : 0.0;
	float g = dot(c.rgb, vec3(0.3, 0.59, 0.11));
	vec3 col = mix(c.rgb, vec3(g) * 0.4, spento);
	ALBEDO = col;
	EMISSION = col * lampo * 1.2 + vec3(1.0, 0.42, 0.08) * bordo * 4.0;
	ROUGHNESS = 0.9;
	ALPHA = a;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
}
"""

## Figurine già ritagliate, per illustrazione: si ritaglia una volta sola.
static var _ritagli: Dictionary = {}
static var _shader: Shader
static var _rumore: NoiseTexture2D

var altezza: float = 1.4
var _perno: Node3D
var _materiale: ShaderMaterial
var _verso: float = -1.0
var _animazione: Tween


## Crea la figurina sopra una carta larga "larghezza" e profonda "profondita".
## verso: -1 se l'avversario è lontano dalla telecamera, +1 se è vicino.
func costruisci(illustrazione: Texture2D, larghezza: float, profondita: float, y_carta: float, verso: float) -> void:
	_verso = verso
	altezza = larghezza * 0.95
	_perno = Node3D.new()
	_perno.position = Vector3(0.0, y_carta, -profondita * 0.5 + 0.06)
	add_child(_perno)
	var forma: QuadMesh = QuadMesh.new()
	forma.size = Vector2(altezza, altezza)
	var figura: MeshInstance3D = MeshInstance3D.new()
	figura.mesh = forma
	figura.position = Vector3(0.0, altezza * 0.5, 0.0)
	_materiale = ShaderMaterial.new()
	_materiale.shader = _shader_condiviso()
	_materiale.set_shader_parameter("tex", ritaglia(illustrazione))
	_materiale.set_shader_parameter("rumore", _rumore_condiviso())
	figura.material_override = _materiale
	_perno.add_child(figura)
	# Piedino di cartone che regge la figurina.
	var piede: MeshInstance3D = MeshInstance3D.new()
	var forma_piede: BoxMesh = BoxMesh.new()
	forma_piede.size = Vector3(altezza * 0.3, 0.02, 0.1)
	piede.mesh = forma_piede
	piede.material_override = StileVisivo.materiale(COLORE_CARTA.darkened(0.6), 0.95)
	piede.position = Vector3(0.0, 0.01, 0.04)
	_perno.add_child(piede)
	# Parte piegata sulla carta, come una pagina chiusa.
	_perno.rotation.x = PI * 0.5


# --- Animazioni ------------------------------------------------------------------

func _nuova_animazione() -> Tween:
	if _animazione != null and _animazione.is_valid():
		_animazione.kill()
	_animazione = create_tween()
	return _animazione


## Si alza dalla carta come in un libro pop-up.
func alza(ritardo: float = 0.0) -> void:
	var t: Tween = _nuova_animazione()
	t.tween_interval(ritardo)
	t.tween_property(_perno, "rotation:x", 0.0, 0.55).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Già in piedi, senza animazione.
func in_piedi() -> void:
	_nuova_animazione().kill()
	_perno.rotation.x = 0.0


## Si richiude, cadendo lontano dall'avversario (il lato ha perso).
func richiudi(ritardo: float = 0.0) -> void:
	var t: Tween = _nuova_animazione()
	t.tween_interval(ritardo)
	t.tween_property(_perno, "rotation:x", -PI * 0.5 * _verso, 0.45).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)


## Scatto verso l'avversario quando la truppa si attiva.
func scatta() -> void:
	var t: Tween = _nuova_animazione()
	t.tween_property(_perno, "rotation:x", 0.45 * _verso, 0.09).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(_perno, "rotation:x", 0.0, 0.4).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	lampeggia(0.9)


## Lampo di luce sulla figura (attivazione, produzione di mana).
func lampeggia(forza: float) -> void:
	var t: Tween = create_tween()
	t.tween_method(_imposta_lampo, forza, 0.0, 0.45)


## Figura spenta (grigia): in attesa di mana, sabotata.
func imposta_spenta(valore: float) -> void:
	_materiale.set_shader_parameter("spento", valore)


func _imposta_lampo(valore: float) -> void:
	_materiale.set_shader_parameter("lampo", valore)


# --- Ritaglio --------------------------------------------------------------------

## La figurina di un'illustrazione: fondo nero tolto, bordo di carta. Il risultato si ricorda.
static func ritaglia(illustrazione: Texture2D) -> Texture2D:
	var chiave: String = illustrazione.resource_path if illustrazione.resource_path != "" else str(illustrazione.get_instance_id())
	if _ritagli.has(chiave):
		return _ritagli[chiave]
	var img: Image = illustrazione.get_image()
	if img.is_compressed():
		img.decompress()
	img.convert(Image.FORMAT_RGBA8)
	img = _quadrata(img, LATO_FIGURA)
	var piccola: Image = img.duplicate() as Image
	piccola.resize(LATO_MASCHERA, LATO_MASCHERA, Image.INTERPOLATE_BILINEAR)
	var n: int = LATO_MASCHERA
	var scuro: PackedByteArray = PackedByteArray()
	scuro.resize(n * n)
	for y: int in range(n):
		for x: int in range(n):
			var c: Color = piccola.get_pixel(x, y)
			scuro[y * n + x] = 1 if maxf(c.r, maxf(c.g, c.b)) < SOGLIA_NERO else 0
	var fondo: PackedByteArray = _riempi_dai_bordi(scuro, n)
	# Figura = tutto ciò che non è fondo; si allarga un poco e si arrotonda, così i pezzi vicini
	# restano uniti come in una figurina tagliata a mano.
	var figura: PackedFloat32Array = PackedFloat32Array()
	figura.resize(n * n)
	for i: int in range(n * n):
		figura[i] = 0.0 if fondo[i] == 1 else 1.0
	var allargata: PackedFloat32Array = _sfoca(figura, n, 3)
	var chiusa: PackedByteArray = PackedByteArray()
	chiusa.resize(n * n)
	for i: int in range(n * n):
		chiusa[i] = 1 if allargata[i] > 0.16 or figura[i] > 0.5 else 0
	# I buchi chiusi dentro la sagoma fanno parte della figurina.
	var vuoto: PackedByteArray = PackedByteArray()
	vuoto.resize(n * n)
	for i: int in range(n * n):
		vuoto[i] = 1 - chiusa[i]
	var fuori: PackedByteArray = _riempi_dai_bordi(vuoto, n)
	var dentro: PackedFloat32Array = PackedFloat32Array()
	dentro.resize(n * n)
	for i: int in range(n * n):
		dentro[i] = 0.0 if fuori[i] == 1 else 1.0
	var con_bordo: PackedFloat32Array = _sfoca(dentro, n, 1)
	var maschera_dentro: Image = _immagine_maschera(_sfoca(dentro, n, 1), n)
	var maschera_bordo: Image = _immagine_maschera(_sfoca(con_bordo, n, 1), n)
	maschera_dentro.resize(LATO_FIGURA, LATO_FIGURA, Image.INTERPOLATE_BILINEAR)
	maschera_bordo.resize(LATO_FIGURA, LATO_FIGURA, Image.INTERPOLATE_BILINEAR)
	var colori: PackedByteArray = img.get_data()
	var dentro_dati: PackedByteArray = maschera_dentro.get_data()
	var bordo_dati: PackedByteArray = maschera_bordo.get_data()
	var carta: PackedByteArray = PackedByteArray([COLORE_CARTA.r8, COLORE_CARTA.g8, COLORE_CARTA.b8])
	var uscita: PackedByteArray = PackedByteArray()
	uscita.resize(LATO_FIGURA * LATO_FIGURA * 4)
	for i: int in range(LATO_FIGURA * LATO_FIGURA):
		if bordo_dati[i] < 77:
			continue
		var j: int = i * 4
		if dentro_dati[i] > 140:
			uscita[j] = colori[j]
			uscita[j + 1] = colori[j + 1]
			uscita[j + 2] = colori[j + 2]
		else:
			uscita[j] = carta[0]
			uscita[j + 1] = carta[1]
			uscita[j + 2] = carta[2]
		uscita[j + 3] = 255
	var risultato: Image = Image.create_from_data(LATO_FIGURA, LATO_FIGURA, false, Image.FORMAT_RGBA8, uscita)
	risultato.generate_mipmaps()
	var trama: ImageTexture = ImageTexture.create_from_image(risultato)
	_ritagli[chiave] = trama
	return trama


static func _quadrata(img: Image, lato: int) -> Image:
	var minimo: int = mini(img.get_width(), img.get_height())
	var ritaglio: Image = img.get_region(Rect2i((img.get_width() - minimo) / 2, (img.get_height() - minimo) / 2, minimo, minimo))
	ritaglio.resize(lato, lato, Image.INTERPOLATE_BILINEAR)
	return ritaglio


## Celle "libere" (valore 1) raggiungibili dai bordi dell'immagine passando solo per celle libere.
static func _riempi_dai_bordi(libero: PackedByteArray, n: int) -> PackedByteArray:
	var raggiunto: PackedByteArray = PackedByteArray()
	raggiunto.resize(n * n)
	var coda: PackedInt32Array = PackedInt32Array()
	for k: int in range(n):
		for i: int in [k, (n - 1) * n + k, k * n, k * n + n - 1]:
			if libero[i] == 1 and raggiunto[i] == 0:
				raggiunto[i] = 1
				coda.append(i)
	var testa: int = 0
	while testa < coda.size():
		var i: int = coda[testa]
		testa += 1
		var x: int = i % n
		var y: int = i / n
		for vicino: int in [i - 1 if x > 0 else -1, i + 1 if x < n - 1 else -1, i - n if y > 0 else -1, i + n if y < n - 1 else -1]:
			if vicino >= 0 and libero[vicino] == 1 and raggiunto[vicino] == 0:
				raggiunto[vicino] = 1
				coda.append(vicino)
	return raggiunto


## Sfocatura a scatola (orizzontale poi verticale), ripetuta due volte: quasi una gaussiana.
static func _sfoca(valori: PackedFloat32Array, n: int, raggio: int) -> PackedFloat32Array:
	var a: PackedFloat32Array = valori.duplicate()
	for _passata: int in range(2):
		var b: PackedFloat32Array = PackedFloat32Array()
		b.resize(n * n)
		for y: int in range(n):
			for x: int in range(n):
				var somma: float = 0.0
				for d: int in range(-raggio, raggio + 1):
					somma += a[y * n + clampi(x + d, 0, n - 1)]
				b[y * n + x] = somma / float(raggio * 2 + 1)
		for y: int in range(n):
			for x: int in range(n):
				var somma2: float = 0.0
				for d: int in range(-raggio, raggio + 1):
					somma2 += b[clampi(y + d, 0, n - 1) * n + x]
				a[y * n + x] = somma2 / float(raggio * 2 + 1)
	return a


static func _immagine_maschera(valori: PackedFloat32Array, n: int) -> Image:
	var dati: PackedByteArray = PackedByteArray()
	dati.resize(n * n)
	for i: int in range(n * n):
		dati[i] = int(clampf(valori[i], 0.0, 1.0) * 255.0)
	return Image.create_from_data(n, n, false, Image.FORMAT_L8, dati)


static func _shader_condiviso() -> Shader:
	if _shader == null:
		_shader = Shader.new()
		_shader.code = SHADER
	return _shader


static func _rumore_condiviso() -> NoiseTexture2D:
	if _rumore == null:
		_rumore = NoiseTexture2D.new()
		_rumore.width = 256
		_rumore.height = 256
		var fonte: FastNoiseLite = FastNoiseLite.new()
		fonte.frequency = 0.02
		fonte.fractal_octaves = 4
		_rumore.noise = fonte
	return _rumore
