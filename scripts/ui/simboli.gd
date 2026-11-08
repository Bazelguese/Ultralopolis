class_name Simboli
extends RefCounted
## I simboli delle carte, come nei giochi da tavolo: un'immagine per ogni concetto del gioco
## (risorse, effetti di battaglia, edificio, truppa, durata...).
## Le immagini stanno in assets/icone/<concetto>.svg (o .png) e sono bianche: il colore lo
## decide chi le disegna. Per cambiare un simbolo basta sostituire il file.
## Solo presentazione: nessuna regola di gioco.

const CARTELLA: String = "res://assets/icone/"

## Simboli già pronti, per nome e lato in pixel.
static var _cache: Dictionary[String, Texture2D] = {}
## Concetti di cui si è già visto che manca l'immagine.
static var _mancanti: Dictionary[StringName, bool] = {}


## Il concetto del simbolo di una risorsa del Magazzino, es. &"stabilita".
static func di_risorsa(tipo: Res.Type) -> StringName:
	match tipo:
		Res.Type.ORO: return &"oro"
		Res.Type.RICERCA: return &"ricerca"
		Res.Type.CIBO: return &"cibo"
		Res.Type.LEGNO: return &"legno"
		Res.Type.PIETRA: return &"pietra"
		Res.Type.FERRO: return &"ferro"
		Res.Type.FEDE: return &"fede"
		Res.Type.INFLUENZA: return &"influenza"
		Res.Type.STABILITA: return &"stabilita"
		Res.Type.DOCUMENTI: return &"documenti"
	return &"oro"


## Il concetto del simbolo di un valore di battaglia (danno, scudo, cura...).
static func di_valore(valore: ModifierDef.BattleValue) -> StringName:
	match valore:
		ModifierDef.BattleValue.DANNO: return &"danno"
		ModifierDef.BattleValue.SCUDO: return &"scudo"
		ModifierDef.BattleValue.CURA: return &"cura"
		ModifierDef.BattleValue.CORRUZIONE: return &"corruzione"
		ModifierDef.BattleValue.ASSEDIO: return &"assedio"
		ModifierDef.BattleValue.INEFFICIENZA: return &"inefficienza"
		ModifierDef.BattleValue.SABOTAGGIO: return &"sabotaggio"
	return &"danno"


## Il concetto del simbolo di un tipo di tessera (GDD §6.6), es. "Infrastruttura Bellica" →
## &"tipo_infrastruttura_bellica". Il simbolo è il file assets/icone/tipo_<nome>.svg: per dare un
## simbolo a un tipo nuovo basta aggiungere il file. I tipi senza file, come i tipi d'identità
## (Pietrosangue, Monarchico...), hanno tutti lo stesso vessillo (scelta di Davide).
static func di_tipo(tipo: StringName) -> StringName:
	var nome: String = String(tipo).to_lower().strip_edges()
	for coppia: Array in [["à", "a"], ["è", "e"], ["é", "e"], ["ì", "i"], ["ò", "o"], ["ù", "u"], ["'", ""], [" ", "_"]]:
		nome = nome.replace(coppia[0] as String, coppia[1] as String)
	var concetto: StringName = StringName("tipo_" + nome)
	return concetto if esiste(concetto) else TIPO_IDENTITA


## Il vessillo dei tipi d'identità.
const TIPO_IDENTITA: StringName = &"tipo_identita"


## true se c'è un'immagine per questo concetto in assets/icone.
static func esiste(concetto: StringName) -> bool:
	if concetto == &"" or _mancanti.has(concetto):
		return false
	if _carica(concetto) == null:
		_mancanti[concetto] = true
		return false
	return true


## Il simbolo pronto per essere disegnato a circa "lato" pixel; null se l'immagine manca.
## L'immagine originale è grande: la si rimpicciolisce una volta sola con un buon filtro,
## così anche i simboli piccoli restano puliti.
static func trama(concetto: StringName, lato: float) -> Texture2D:
	if concetto == &"" or _mancanti.has(concetto):
		return null
	var pixel: int = 16
	while pixel < int(ceil(lato)) and pixel < 256:
		pixel *= 2
	var chiave: String = "%s@%d" % [concetto, pixel]
	if _cache.has(chiave):
		return _cache[chiave]
	var originale: Texture2D = _carica(concetto)
	if originale == null:
		_mancanti[concetto] = true
		return null
	var immagine: Image = originale.get_image()
	if immagine == null:
		_cache[chiave] = originale
		return originale
	if immagine.is_compressed():
		immagine.decompress()
	if immagine.get_width() > pixel:
		immagine.resize(pixel, pixel, Image.INTERPOLATE_LANCZOS)
	var pronta: ImageTexture = ImageTexture.create_from_image(immagine)
	_cache[chiave] = pronta
	return pronta


static func _carica(concetto: StringName) -> Texture2D:
	for estensione: String in ["svg", "png"]:
		var percorso: String = "%s%s.%s" % [CARTELLA, concetto, estensione]
		if ResourceLoader.exists(percorso):
			return load(percorso) as Texture2D
	return null
