class_name Figurina
extends Node3D
## Teatro di carta (scelta di Davide, 8 novembre 2026): la figura dell'illustrazione, ritagliata
## come una figurina di carta, che si alza dal centro della carta come in un libro pop-up
## (la carta le fa da base, Davide 8 novembre 2026).
## Il ritaglio si fa da solo e si aggiunge un bordo di carta color crema. Due casi, secondo il fondo:
## - fondo nero (le prime illustrazioni): si toglie il nero che tocca i bordi dell'immagine (non le
##   linee d'inchiostro dentro la figura); i vuoti chiusi dentro la sagoma restano;
## - fondo chiaro e uniforme (le illustrazioni dal 9 novembre 2026): si toglie il colore del fondo,
##   anche nei vuoti chiusi (fra un braccio e lo scudo), e il bordo di carta sta attaccato alla figura.
## Solo presentazione: nessuna regola di gioco.

const COLORE_CARTA: Color = StileVisivo.CARTA_CREMA
## Sotto questa luminosità un pixel del fondo conta come nero.
const SOGLIA_NERO: float = 0.15
## Lato dell'immagine su cui si calcola la sagoma (più piccolo = più veloce, contorno più morbido).
const LATO_MASCHERA: int = 128
## Lato della maschera per le illustrazioni su fondo chiaro: più fine, perché zampe e antenne
## sottili non spariscano.
const LATO_MASCHERA_CHIARO: int = 256
## Sopra questa luminosità (il canale più chiaro) il colore dei bordi conta come fondo chiaro.
const SOGLIA_FONDO_CHIARO: float = 0.45
## Quanto un pixel può scostarsi dal colore del fondo (per canale) ed essere ancora fondo.
const TOLLERANZA_FONDO: float = 0.10
## Un vuoto chiuso dentro la figura diventa fondo solo se è almeno così grande (parte dell'immagine):
## i puntini chiari dentro la figura (riflessi, ali) restano.
const VUOTO_MINIMO: float = 0.0015
## I pezzetti staccati più piccoli di così (parte dell'immagine) sono sporco del fondo e si tolgono.
const PEZZO_MINIMO: float = 0.0008
## Lato dell'immagine finale della figurina.
const LATO_FIGURA: int = 512
## Maschere già calcolate, ricordate fra una partita e l'altra (si possono cancellare: si rifanno).
const CARTELLA_MEMORIA: String = "user://figurine"
## Da cambiare se cambia il modo di calcolare la maschera, così le vecchie non si usano più.
const VERSIONE_MASCHERA: int = 3
## Quanto ci mette una figurina a tornare distesa nella carta a fine scontro.
const DURATA_RIPONI: float = 0.4
## Quanta parte (dall'alto) della figura fa il mezzo busto.
const QUOTA_BUSTO: float = 0.72

const SHADER: String = """
shader_type spatial;
render_mode cull_disabled, depth_draw_opaque;
uniform sampler2D tex : source_color, filter_linear_mipmap_anisotropic;
uniform sampler2D maschera : filter_linear;
uniform sampler2D rumore;
uniform bool con_maschera = false;
uniform vec3 carta : source_color = vec3(0.925, 0.886, 0.8);
uniform float quota = 1.0;
uniform float bruciatura = 0.0;
uniform bool dai_bordi = false;
uniform float finale = 0.0;
uniform float lampo = 0.0;
uniform float spento = 0.0;
uniform float corruzione = 0.0;
void fragment() {
	vec2 uv = vec2(UV.x, UV.y * quota);
	vec4 c = texture(tex, uv);
	float a = c.a;
	vec3 base = c.rgb;
	if (con_maschera) {
		// La maschera (fatta una volta, piccola) dice dove sta la figura (R) e il bordo di carta (G).
		vec2 m = texture(maschera, uv).rg;
		a = smoothstep(0.26, 0.34, m.g);
		base = mix(carta, c.rgb, smoothstep(0.5, 0.6, m.r));
	}
	float n = texture(rumore, uv).r;
	float bordo = 0.0;
	float bruciacchiato = 0.0;
	if (dai_bordi) {
		// Stendardo (Davide, 9 novembre 2026): brucia dai bordi verso l'interno, ma il centro con le
		// iniziali e la Resistenza resta intatto e leggibile; la carta vicino al fuoco si annerisce.
		vec2 q = abs(uv - vec2(0.5, 0.52)) / vec2(0.5, 0.48);
		float d = max(q.x, q.y) + (n - 0.5) * 0.18;
		float limite = 1.02 - bruciatura;
		if (bruciatura > 0.001 && d > limite) { a = 0.0; }
		bordo = (bruciatura > 0.001) ? smoothstep(limite - 0.05, limite, d) : 0.0;
		bruciacchiato = (bruciatura > 0.001) ? smoothstep(limite - 0.14, limite, d) : 0.0;
		if (finale > 0.001 && n < finale) { a = 0.0; }
		bordo = max(bordo, (finale > 0.001) ? smoothstep(finale + 0.07, finale, n) : 0.0);
	} else {
		if (bruciatura > 0.001 && n < bruciatura) { a = 0.0; }
		bordo = (bruciatura > 0.001) ? smoothstep(bruciatura + 0.07, bruciatura, n) : 0.0;
	}
	base = mix(base, vec3(0.16, 0.1, 0.06), bruciacchiato * 0.85);
	// Corruzione: una macchia magenta che sale dal basso, con il bordo irregolare.
	if (corruzione > 0.001) {
		float sale = 1.0 - corruzione + (n - 0.5) * 0.12;
		base = mix(base, vec3(0.76, 0.22, 0.54), smoothstep(sale, sale + 0.04, uv.y) * 0.75);
	}
	float g = dot(base, vec3(0.3, 0.59, 0.11));
	vec3 col = mix(base, vec3(g) * 0.4, spento);
	ALBEDO = col;
	// La figurina sta in piedi, ma si illumina come se guardasse in alto, come la carta sotto di
	// lei: altrimenti le luci, che vengono dall'alto, la sfiorano appena e resta scura.
	NORMAL = normalize(mix(NORMAL, (VIEW_MATRIX * vec4(0.0, 1.0, 0.0, 0.0)).xyz, 0.75));
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


## Crea la figurina sopra una carta larga "larghezza"; z_base è dove poggia (il centro della
## pedana, cioè della zona dove la carta avrebbe l'illustrazione).
## verso: -1 se l'avversario è lontano dalla telecamera, +1 se è vicino.
func costruisci(illustrazione: Texture2D, larghezza: float, z_base: float, y_carta: float, verso: float, fattore_altezza: float = 0.95) -> void:
	_verso = verso
	altezza = larghezza * fattore_altezza
	_perno = Node3D.new()
	_perno.position = Vector3(0.0, y_carta, z_base)
	add_child(_perno)
	var forma: QuadMesh = QuadMesh.new()
	forma.size = Vector2(altezza, altezza)
	var figura: MeshInstance3D = MeshInstance3D.new()
	figura.mesh = forma
	figura.position = Vector3(0.0, altezza * 0.5, 0.0)
	var ritaglio: Array = ritaglia(illustrazione)
	_materiale = materiale_carta(ritaglio[0], ritaglio[1])
	figura.material_override = _materiale
	_perno.add_child(figura)
	# Piedino di cartone che regge la figurina.
	var piede: MeshInstance3D = MeshInstance3D.new()
	var forma_piede: BoxMesh = BoxMesh.new()
	forma_piede.size = Vector3(altezza * 0.3, 0.02, 0.1)
	piede.mesh = forma_piede
	# Scuro come il fondo della carta: regge la figurina senza farsi notare (Davide, 9 novembre 2026).
	piede.material_override = StileVisivo.materiale(Color("120d0a"), 0.95)
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


## Torna distesa nella carta, come una pagina che si chiude (fine dello scontro).
func riponi() -> void:
	var t: Tween = _nuova_animazione()
	t.tween_property(_perno, "rotation:x", PI * 0.5, DURATA_RIPONI).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)


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

## La figurina di un'illustrazione: [immagine, maschera]. La maschera dice dove togliere il fondo
## e dove mettere il bordo di carta; il ritaglio lo fa lo shader. Il risultato si ricorda.
static func ritaglia(illustrazione: Texture2D) -> Array:
	var chiave: String = illustrazione.resource_path if illustrazione.resource_path != "" else str(illustrazione.get_instance_id())
	if _ritagli.has(chiave):
		return _ritagli[chiave]
	var img: Image = illustrazione.get_image()
	if img.is_compressed():
		img.decompress()
	img.convert(Image.FORMAT_RGBA8)
	var colore_fondo: Color = colore_dei_bordi(img)
	var fondo_chiaro: bool = e_fondo_chiaro(colore_fondo)
	img = _quadrata(img, LATO_FIGURA, colore_fondo if fondo_chiaro else Color.BLACK)
	img.generate_mipmaps()
	var immagine: ImageTexture = ImageTexture.create_from_image(img)
	# La maschera si calcola una volta sola e si ricorda su disco (cambia se cambia il file).
	var file_memoria: String = _file_memoria(illustrazione.resource_path)
	if file_memoria != "" and FileAccess.file_exists(file_memoria):
		var salvata: Image = Image.load_from_file(file_memoria)
		if salvata != null and not salvata.is_empty():
			salvata.convert(Image.FORMAT_RG8)
			var pronto: Array = [immagine, ImageTexture.create_from_image(salvata)]
			_ritagli[chiave] = pronto
			return pronto
	var maschera: Image = maschera_fondo_chiaro(img, colore_fondo) if fondo_chiaro else _maschera_fondo_nero(img)
	if file_memoria != "":
		DirAccess.make_dir_recursive_absolute(CARTELLA_MEMORIA)
		var da_salvare: Image = maschera.duplicate() as Image
		da_salvare.convert(Image.FORMAT_RGBA8)
		da_salvare.save_png(file_memoria)
	var risultato: Array = [immagine, ImageTexture.create_from_image(maschera)]
	_ritagli[chiave] = risultato
	return risultato


## Il colore del fondo: per ogni canale, il valore più comune (la mediana) dei pixel sul bordo
## dell'immagine.
static func colore_dei_bordi(img: Image) -> Color:
	var w: int = img.get_width()
	var h: int = img.get_height()
	var rossi: PackedFloat32Array = PackedFloat32Array()
	var verdi: PackedFloat32Array = PackedFloat32Array()
	var blu: PackedFloat32Array = PackedFloat32Array()
	var punti: Array[Vector2i] = []
	for x: int in range(w):
		punti.append(Vector2i(x, 0))
		punti.append(Vector2i(x, h - 1))
	for y: int in range(1, h - 1):
		punti.append(Vector2i(0, y))
		punti.append(Vector2i(w - 1, y))
	for p: Vector2i in punti:
		var c: Color = img.get_pixelv(p)
		rossi.append(c.r)
		verdi.append(c.g)
		blu.append(c.b)
	rossi.sort()
	verdi.sort()
	blu.sort()
	var meta: int = rossi.size() / 2
	return Color(rossi[meta], verdi[meta], blu[meta])


## Vero se il colore del fondo è chiaro: allora si ritaglia il fondo chiaro, altrimenti il nero.
static func e_fondo_chiaro(colore_fondo: Color) -> bool:
	return maxf(colore_fondo.r, maxf(colore_fondo.g, colore_fondo.b)) > SOGLIA_FONDO_CHIARO


## Maschera per le illustrazioni su fondo chiaro (R = figura, G = figura con il bordo di carta).
## È fondo il colore del fondo che tocca i bordi e, dentro la figura, ogni vuoto dello stesso colore
## abbastanza grande. La figura non si allarga: il bordo di carta le sta attaccato.
static func maschera_fondo_chiaro(img: Image, colore_fondo: Color) -> Image:
	var n: int = LATO_MASCHERA_CHIARO
	var piccola: Image = img.duplicate() as Image
	if piccola.has_mipmaps():
		piccola.clear_mipmaps()
	piccola.resize(n, n, Image.INTERPOLATE_BILINEAR)
	var simile: PackedByteArray = PackedByteArray()
	simile.resize(n * n)
	for y: int in range(n):
		for x: int in range(n):
			var c: Color = piccola.get_pixel(x, y)
			var scarto: float = maxf(absf(c.r - colore_fondo.r), maxf(absf(c.g - colore_fondo.g), absf(c.b - colore_fondo.b)))
			simile[y * n + x] = 1 if scarto < TOLLERANZA_FONDO else 0
	# Zone del colore del fondo: sono fondo se toccano i bordi o se sono abbastanza grandi.
	var vuoti: Array = _zone(simile, n)
	var etichette: PackedInt32Array = vuoti[0]
	var grandezze: PackedInt32Array = vuoti[1]
	var ai_bordi: PackedByteArray = vuoti[2]
	var minimo_vuoto: int = int(VUOTO_MINIMO * n * n)
	var figura: PackedByteArray = PackedByteArray()
	figura.resize(n * n)
	for i: int in range(n * n):
		var zona: int = etichette[i]
		var e_fondo: bool = zona >= 0 and (ai_bordi[zona] == 1 or grandezze[zona] >= minimo_vuoto)
		figura[i] = 0 if e_fondo else 1
	# Pezzetti staccati troppo piccoli: sporco del fondo, non parte della figura.
	var pezzi: Array = _zone(figura, n)
	var etichette_pezzi: PackedInt32Array = pezzi[0]
	var grandezze_pezzi: PackedInt32Array = pezzi[1]
	var minimo_pezzo: int = int(PEZZO_MINIMO * n * n)
	var dentro: PackedFloat32Array = PackedFloat32Array()
	dentro.resize(n * n)
	for i: int in range(n * n):
		var pezzo: int = etichette_pezzi[i]
		dentro[i] = 1.0 if pezzo >= 0 and grandezze_pezzi[pezzo] >= minimo_pezzo else 0.0
	# Bordo di carta: la figura allargata di poco, tutt'attorno.
	var allargata: PackedFloat32Array = _sfoca(dentro, n, 2)
	var con_bordo: PackedFloat32Array = PackedFloat32Array()
	con_bordo.resize(n * n)
	for i: int in range(n * n):
		con_bordo[i] = 1.0 if allargata[i] > 0.12 else 0.0
	return _maschera_da(_sfoca(dentro, n, 1), _sfoca(con_bordo, n, 1), n)


## Zone collegate di celle con valore 1: [etichetta per cella (-1 fuori dalle zone),
## grandezza di ogni zona, 1 se la zona tocca i bordi].
static func _zone(celle: PackedByteArray, n: int) -> Array:
	var etichette: PackedInt32Array = PackedInt32Array()
	etichette.resize(n * n)
	etichette.fill(-1)
	var grandezze: PackedInt32Array = PackedInt32Array()
	var ai_bordi: PackedByteArray = PackedByteArray()
	var coda: PackedInt32Array = PackedInt32Array()
	for inizio: int in range(n * n):
		if celle[inizio] != 1 or etichette[inizio] >= 0:
			continue
		var zona: int = grandezze.size()
		var grandezza: int = 0
		var tocca: int = 0
		coda.clear()
		coda.append(inizio)
		etichette[inizio] = zona
		var testa: int = 0
		while testa < coda.size():
			var i: int = coda[testa]
			testa += 1
			grandezza += 1
			var x: int = i % n
			var y: int = i / n
			if x == 0 or y == 0 or x == n - 1 or y == n - 1:
				tocca = 1
			for vicino: int in [i - 1 if x > 0 else -1, i + 1 if x < n - 1 else -1, i - n if y > 0 else -1, i + n if y < n - 1 else -1]:
				if vicino >= 0 and celle[vicino] == 1 and etichette[vicino] < 0:
					etichette[vicino] = zona
					coda.append(vicino)
		grandezze.append(grandezza)
		ai_bordi.append(tocca)
	return [etichette, grandezze, ai_bordi]


## Immagine della maschera per la scheda video: R = figura, G = figura con il bordo di carta.
static func _maschera_da(figura: PackedFloat32Array, bordo: PackedFloat32Array, n: int) -> Image:
	var dati: PackedByteArray = PackedByteArray()
	dati.resize(n * n * 2)
	for i: int in range(n * n):
		dati[i * 2] = int(clampf(figura[i], 0.0, 1.0) * 255.0)
		dati[i * 2 + 1] = int(clampf(bordo[i], 0.0, 1.0) * 255.0)
	return Image.create_from_data(n, n, false, Image.FORMAT_RG8, dati)


## Maschera per le illustrazioni su fondo nero (il ritaglio delle prime illustrazioni, invariato).
static func _maschera_fondo_nero(img: Image) -> Image:
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
	# La maschera va alla scheda video, che fa il ritaglio mentre disegna (bordi lisci, nessun ciclo
	# sui pixel dell'immagine grande): R = figura, G = figura con il bordo di carta.
	return _maschera_da(_sfoca(dentro, n, 1), _sfoca(con_bordo, n, 1), n)


## Dove si ricordano le maschere già calcolate: un file per illustrazione e versione del file.
static func _file_memoria(percorso: String) -> String:
	if percorso == "":
		return ""
	var firma: String = "%s|%d|%d|%d" % [percorso, FileAccess.get_modified_time(percorso), LATO_MASCHERA, VERSIONE_MASCHERA]
	return "%s/%s.png" % [CARTELLA_MEMORIA, firma.md5_text()]


## L'immagine dentro un quadrato, con le sue proporzioni (2:3 in verticale, 3:2 in orizzontale):
## il margine ha il colore del fondo e il ritaglio lo toglie insieme al fondo.
static func _quadrata(img: Image, lato: int, colore_margine: Color = Color.BLACK) -> Image:
	var massimo: int = maxi(img.get_width(), img.get_height())
	var w: int = maxi(1, int(round(float(img.get_width()) / float(massimo) * lato)))
	var h: int = maxi(1, int(round(float(img.get_height()) / float(massimo) * lato)))
	var ridotta: Image = img.duplicate() as Image
	ridotta.resize(w, h, Image.INTERPOLATE_LANCZOS)
	var quadrato: Image = Image.create(lato, lato, false, Image.FORMAT_RGBA8)
	quadrato.fill(colore_margine)
	# Le figure stanno in piedi: in un quadrato più largo che alto la figura poggia sul fondo.
	quadrato.blit_rect(ridotta, Rect2i(0, 0, w, h), Vector2i((lato - w) / 2, lato - h))
	return quadrato


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
## Con le somme scorrevoli costa uguale qualunque sia il raggio.
static func _sfoca(valori: PackedFloat32Array, n: int, raggio: int) -> PackedFloat32Array:
	var a: PackedFloat32Array = valori.duplicate()
	var b: PackedFloat32Array = PackedFloat32Array()
	b.resize(n * n)
	var finestra: float = float(raggio * 2 + 1)
	for _passata: int in range(2):
		for y: int in range(n):
			var riga: int = y * n
			var somma: float = 0.0
			for d: int in range(-raggio, raggio + 1):
				somma += a[riga + clampi(d, 0, n - 1)]
			for x: int in range(n):
				b[riga + x] = somma / finestra
				somma += a[riga + mini(x + raggio + 1, n - 1)] - a[riga + maxi(x - raggio, 0)]
		for x: int in range(n):
			var somma2: float = 0.0
			for d: int in range(-raggio, raggio + 1):
				somma2 += b[clampi(d, 0, n - 1) * n + x]
			for y: int in range(n):
				a[y * n + x] = somma2 / finestra
				somma2 += b[mini(y + raggio + 1, n - 1) * n + x] - b[maxi(y - raggio, 0) * n + x]
	return a


## Materiale di carta del teatro (figurine, stendardi): può bruciare e lampeggiare.
## Con la maschera di un ritaglio fa la figurina; quota < 1 mostra solo la parte alta (il mezzo busto).
static func materiale_carta(trama: Texture2D, maschera: Texture2D = null, quota: float = 1.0) -> ShaderMaterial:
	var materiale: ShaderMaterial = ShaderMaterial.new()
	materiale.shader = _shader_condiviso()
	materiale.set_shader_parameter("tex", trama)
	materiale.set_shader_parameter("rumore", _rumore_condiviso())
	materiale.set_shader_parameter("carta", COLORE_CARTA)
	materiale.set_shader_parameter("quota", quota)
	if maschera != null:
		materiale.set_shader_parameter("maschera", maschera)
		materiale.set_shader_parameter("con_maschera", true)
	return materiale


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
