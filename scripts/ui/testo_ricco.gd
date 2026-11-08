class_name TestoRicco
extends RefCounted
## Trasforma un testo semplice del gioco in testo colorato per i RichTextLabel:
## le parole chiave del lessico (risorse, effetti di battaglia, mana, tipi, bonus e malus)
## prendono il loro colore e i numeri vanno in grassetto, come in The Bazaar.
## Il riconoscimento è automatico (scelta di Davide, 8 novembre): i testi dei dati non cambiano.
## Solo presentazione: legge il lessico, non contiene regole di gioco.

const PERCORSO_LESSICO: String = "res://data/ui/lessico.tres"
## Segni che possono stare davanti a un numero (+2, −1, ×1,5).
const SEGNI: String = "+-−×"


## Un tratto del testo: semplice, una parola chiave oppure un numero.
class Pezzo:
	var testo: String = ""
	var voce: VoceLessico = null
	var numero: bool = false
	## Per un numero seguito da una parola chiave: la voce di quella parola.
	var voce_vicina: VoceLessico = null

	func _init(p_testo: String, p_voce: VoceLessico = null, p_numero: bool = false) -> void:
		testo = p_testo
		voce = p_voce
		numero = p_numero


static var _lessico: Lessico = null
## Forme delle parole chiave raggruppate per prima lettera, dalla più lunga alla più corta:
## così "Infrastruttura Bellica" vince su un'eventuale "Infrastruttura".
static var _forme_per_iniziale: Dictionary[String, Array] = {}
static var _caricato: bool = false
## Nome dato a ogni simbolo rimpicciolito, per grandezza (es. "danno@16").
static var _percorsi_simboli: Dictionary[String, String] = {}


static func lessico() -> Lessico:
	if not _caricato:
		_caricato = true
		if ResourceLoader.exists(PERCORSO_LESSICO):
			_lessico = load(PERCORSO_LESSICO) as Lessico
		usa_lessico(_lessico)
	return _lessico


## Sostituisce il lessico in uso (serve ai test e a ricaricare i dati).
static func usa_lessico(nuovo: Lessico) -> void:
	_lessico = nuovo
	_caricato = true
	_forme_per_iniziale = {}
	if nuovo == null:
		return
	for voce: VoceLessico in nuovo.voci:
		if voce == null:
			continue
		for forma: String in voce.forme:
			_aggiungi_forma(forma, voce)
			var maiuscola: String = forma.substr(0, 1).to_upper() + forma.substr(1)
			if maiuscola != forma:
				_aggiungi_forma(maiuscola, voce)
	for iniziale: String in _forme_per_iniziale:
		_forme_per_iniziale[iniziale].sort_custom(func(a: Array, b: Array) -> bool: return (a[0] as String).length() > (b[0] as String).length())


static func _aggiungi_forma(forma: String, voce: VoceLessico) -> void:
	if forma.is_empty():
		return
	var iniziale: String = forma.substr(0, 1)
	if not _forme_per_iniziale.has(iniziale):
		_forme_per_iniziale[iniziale] = []
	_forme_per_iniziale[iniziale].append([forma, voce])


## Il testo con i codici di colore del RichTextLabel (BBCode). dimensione: grandezza del
## carattere del testo, per disegnare i simboli della stessa altezza.
static func colora(testo: String, dimensione: int = 18) -> String:
	var lessico_attuale: Lessico = lessico()
	var parti: PackedStringArray = PackedStringArray()
	for pezzo: Pezzo in scomponi(testo):
		var sicuro: String = _proteggi(pezzo.testo)
		if pezzo.voce != null:
			parti.append(_simbolo(pezzo.voce, dimensione) + _stile(sicuro, pezzo.voce.colore, pezzo.voce.grassetto))
		elif pezzo.numero and lessico_attuale != null:
			var colore: Color = lessico_attuale.colore_numeri
			if pezzo.voce_vicina != null and lessico_attuale.numeri_col_colore_della_parola:
				colore = pezzo.voce_vicina.colore
			parti.append(_stile(sicuro, colore, lessico_attuale.numeri_in_grassetto))
		else:
			parti.append(sicuro)
	return "".join(parti)


## Le parole chiave con una spiegazione che compaiono nel testo, nell'ordine in cui compaiono,
## senza ripetizioni e al massimo quante ne prevede il lessico.
static func voci_da_spiegare(testo: String) -> Array[VoceLessico]:
	var risultato: Array[VoceLessico] = []
	var lessico_attuale: Lessico = lessico()
	if lessico_attuale == null:
		return risultato
	for pezzo: Pezzo in scomponi(testo):
		if pezzo.voce == null or pezzo.voce.definizione.strip_edges().is_empty() or risultato.has(pezzo.voce):
			continue
		risultato.append(pezzo.voce)
		if risultato.size() >= lessico_attuale.massimo_spiegazioni:
			break
	return risultato


## Divide il testo in tratti semplici, parole chiave e numeri.
static func scomponi(testo: String) -> Array[Pezzo]:
	lessico()
	var pezzi: Array[Pezzo] = []
	var semplice: String = ""
	var i: int = 0
	var lunghezza: int = testo.length()
	while i < lunghezza:
		if _inizio_di_parola(testo, i):
			var fine_numero: int = _fine_numero(testo, i)
			if fine_numero > i:
				if semplice != "":
					pezzi.append(Pezzo.new(semplice))
					semplice = ""
				var numero: Pezzo = Pezzo.new(testo.substr(i, fine_numero - i), null, true)
				var dopo: int = fine_numero + 1 if fine_numero < lunghezza and testo[fine_numero] == " " else fine_numero
				var vicina: Array = _parola_in(testo, dopo)
				if not vicina.is_empty():
					numero.voce_vicina = vicina[1]
				pezzi.append(numero)
				i = fine_numero
				continue
			var trovata: Array = _parola_in(testo, i)
			if not trovata.is_empty():
				if semplice != "":
					pezzi.append(Pezzo.new(semplice))
					semplice = ""
				var forma: String = trovata[0]
				pezzi.append(Pezzo.new(forma, trovata[1]))
				i += forma.length()
				continue
		semplice += testo[i]
		i += 1
	if semplice != "":
		pezzi.append(Pezzo.new(semplice))
	return pezzi


## [forma, voce] della parola chiave che inizia in quel punto, oppure [] se non ce n'è.
static func _parola_in(testo: String, inizio: int) -> Array:
	if inizio >= testo.length():
		return []
	var candidate: Array = _forme_per_iniziale.get(testo[inizio], [])
	for candidata: Array in candidate:
		var forma: String = candidata[0]
		var fine: int = inizio + forma.length()
		if fine > testo.length() or testo.substr(inizio, forma.length()) != forma:
			continue
		if fine < testo.length() and _fa_parte_di_parola(testo[fine]):
			continue
		return candidata
	return []


## Fine di un numero che inizia in quel punto (segno, cifre, decimali, % o secondi);
## uguale a inizio se lì non c'è un numero.
static func _fine_numero(testo: String, inizio: int) -> int:
	var lunghezza: int = testo.length()
	var i: int = inizio
	if i < lunghezza and SEGNI.contains(testo[i]):
		i += 1
	var prima_cifra: int = i
	while i < lunghezza and _cifra(testo[i]):
		i += 1
	if i == prima_cifra:
		return inizio
	if i + 1 < lunghezza and (testo[i] == "," or testo[i] == ".") and _cifra(testo[i + 1]):
		i += 1
		while i < lunghezza and _cifra(testo[i]):
			i += 1
	if i < lunghezza and testo[i] == "%":
		return i + 1
	# Secondi: "10 s" oppure "10s", ma non "10 secondi" né "2 spazi".
	var unita: int = i + 1 if i < lunghezza and testo[i] == " " else i
	if unita < lunghezza and testo[unita] == "s" and (unita + 1 >= lunghezza or not _fa_parte_di_parola(testo[unita + 1])):
		return unita + 1
	if i < lunghezza and _fa_parte_di_parola(testo[i]):
		return inizio
	return i


## Una parola chiave o un numero possono cominciare solo all'inizio di una parola:
## non dentro "scudiero" né dopo "0." in "v0.29".
static func _inizio_di_parola(testo: String, i: int) -> bool:
	if i == 0:
		return true
	var prima: String = testo[i - 1]
	if _fa_parte_di_parola(prima):
		return false
	return not ((prima == "." or prima == ",") and i >= 2 and _cifra(testo[i - 2]))


static func _cifra(carattere: String) -> bool:
	return carattere >= "0" and carattere <= "9"


## Lettere (anche accentate) e cifre: separano le parole chiave dal resto.
static func _fa_parte_di_parola(carattere: String) -> bool:
	return _cifra(carattere) or carattere.to_lower() != carattere.to_upper()


## Il simbolo della carta davanti alla parola (vuoto se non ne ha): bianco come sulle carte
## (GDD §14.4), colorato solo per le gemme del mana.
static func _simbolo(voce: VoceLessico, dimensione: int) -> String:
	if voce.simbolo == &"" or _lessico == null or not _lessico.simboli_nel_testo:
		return ""
	var lato: int = maxi(8, roundi(dimensione * 0.9))
	var percorso: String = _percorso_simbolo(voce.simbolo, lato)
	if percorso == "":
		return ""
	var colore: Color = voce.colore if voce.simbolo_colorato else Color.WHITE
	# Dopo il simbolo uno spazio sottilissimo, per staccarlo dalla parola.
	return "[img width=%d height=%d color=#%s]%s[/img]\u200a" % [lato, lato, colore.to_html(false), percorso]


## Il RichTextLabel trova le immagini per nome: al simbolo già rimpicciolito da Simboli (lo stesso
## delle carte, nitido anche piccolo) si dà un nome tutto suo, una volta sola per grandezza.
static func _percorso_simbolo(concetto: StringName, lato: int) -> String:
	var chiave: String = "%s@%d" % [concetto, lato]
	if _percorsi_simboli.has(chiave):
		return _percorsi_simboli[chiave]
	var trama: Texture2D = Simboli.trama(concetto, lato)
	var percorso: String = ""
	if trama != null:
		percorso = trama.resource_path
		if percorso.is_empty():
			percorso = "%s%s@%d.testo" % [Simboli.CARTELLA, concetto, lato]
			trama.take_over_path(percorso)
	_percorsi_simboli[chiave] = percorso
	return percorso


static func _stile(testo: String, colore: Color, grassetto: bool) -> String:
	var colorato: String = "[color=#%s]%s[/color]" % [colore.to_html(false), testo]
	return "[b]%s[/b]" % colorato if grassetto else colorato


## Le parentesi quadre del testo originale non devono diventare codici di formattazione.
static func _proteggi(testo: String) -> String:
	# In due passi, altrimenti la "]" di "[lb]" verrebbe sostituita a sua volta.
	return testo.replace("[", "\u0001").replace("]", "[rb]").replace("\u0001", "[lb]")
