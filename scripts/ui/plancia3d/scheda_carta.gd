class_name SchedaCarta
extends RefCounted
## Quello che una carta mostra: nome, numeri, colori e testo dei dettagli.
## Si costruisce dai dati veri del gioco (catalogo, plancia, offerte, incontri).
## Solo presentazione: legge i dati, non contiene regole di gioco.

enum Genere { EDIFICIO, TRUPPA, AZIONE, INCONTRO, FANTASMA }

## Le illustrazioni si cercano qui, con il nome dell'identificativo:
## edifici/<id>.png, truppe/<id>.png, azioni/<id>.png. Se mancano si usa il segnaposto.
const CARTELLA_ILLUSTRAZIONI: String = "res://assets/illustrazioni/"

var genere: Genere = Genere.EDIFICIO
var id: StringName = &""
var titolo: String = ""
## Riga sopra la carta (tipo di offerta, difficoltà, "Ricompensa").
var sopratitolo: String = ""
var era: int = 1
## Colore del mana come nei dati (&"rosso", ...); vuoto se non c'è.
var mana: StringName = &""
## Costo in mana (truppe) oppure mana prodotto (edifici).
var mana_numero: int = 0
var danno: int = 0
## Ricarica (truppe) o intervallo di produzione (edifici), in millisecondi.
var ritmo_ms: int = 0
var livello: int = 1
var malus: String = ""
var affamata: bool = false
## Testo breve stampato sulla carta quando non ci sono numeri da mostrare.
var riga: String = ""
## Costo dell'offerta, scritto sotto la carta.
var costo: String = ""
## Testo completo del riquadro che compare passando il mouse.
var dettagli: String = ""
var illustrazione: Texture2D
## false se l'offerta non si può pagare: la carta appare spenta.
var disponibile: bool = true


func colore_cornice() -> Color:
	match genere:
		Genere.AZIONE:
			return StileVisivo.CORNICE_AZIONE
		Genere.INCONTRO, Genere.FANTASMA:
			return StileVisivo.CORNICE_MINACCIA
	return StileVisivo.colore_cornice(era)


# --- Costruzione dai dati del gioco --------------------------------------------

static func da_edificio(def: BuildingDef, p_livello: int = 1, p_malus: String = "") -> SchedaCarta:
	var scheda: SchedaCarta = SchedaCarta.new()
	scheda.genere = Genere.EDIFICIO
	scheda.id = def.id
	scheda.titolo = def.display_name
	scheda.era = def.era
	scheda.mana = def.mana_type if def.mana_amount > 0 else &""
	scheda.mana_numero = def.mana_amount
	scheda.ritmo_ms = def.mana_interval_ms
	scheda.livello = p_livello
	scheda.malus = p_malus
	scheda.illustrazione = _carica("edifici/%s.png" % def.id)
	var righe: PackedStringArray = PackedStringArray()
	var produzione: PackedStringArray = PackedStringArray()
	for tipo: Res.Type in Res.NAMES:
		var quanto: int = def.production(tipo)
		if quanto != 0:
			produzione.append("+%d %s" % [quanto, Res.NAMES[tipo]])
	righe.append("A ogni fase: %s." % (", ".join(produzione) if not produzione.is_empty() else "nessuna risorsa"))
	if def.mana_amount > 0:
		righe.append("In battaglia: %d %s ogni %s." % [def.mana_amount, def.mana_type, secondi(def.mana_interval_ms)])
	if def.extra_building_slots > 0:
		righe.append("+%d spazio edificio." % def.extra_building_slots)
	if def.extra_troop_slots > 0:
		righe.append("+%d spazio truppa." % def.extra_troop_slots)
	if def.is_capital:
		righe.append("Non si può vendere né sostituire.")
	righe.append(_riga_etichette(def.tags, p_livello))
	if p_malus != "":
		righe.append("Colpito da: %s." % p_malus)
	scheda.dettagli = "\n".join(righe)
	return scheda


static func da_truppa(def: TroopDef, p_livello: int = 1, p_malus: String = "", p_affamata: bool = false) -> SchedaCarta:
	var scheda: SchedaCarta = SchedaCarta.new()
	scheda.genere = Genere.TRUPPA
	scheda.id = def.id
	scheda.titolo = def.display_name
	scheda.era = def.era
	scheda.mana = def.mana_type if def.mana_cost > 0 else &""
	scheda.mana_numero = def.mana_cost
	scheda.danno = def.damage
	scheda.ritmo_ms = def.cooldown_ms
	scheda.livello = p_livello
	scheda.malus = p_malus
	scheda.affamata = p_affamata
	scheda.illustrazione = _carica("truppe/%s.png" % def.id)
	var righe: PackedStringArray = PackedStringArray()
	if def.mana_cost > 0:
		righe.append("Costa %d mana %s (se manca, usa l'energetico)." % [def.mana_cost, def.mana_type])
	else:
		righe.append("Senza mana: agisce appena finisce la ricarica.")
	righe.append("%d danni · ricarica %s." % [def.damage, secondi(def.cooldown_ms)])
	righe.append("Mangia %s Cibo a inizio anno." % Res.format(Res.Type.CIBO, def.food_tenths))
	if p_affamata:
		righe.append("Affamata: ricarica più lenta fino al prossimo pasto.")
	righe.append(_riga_etichette(def.tags, p_livello))
	if p_malus != "":
		righe.append("Colpita da: %s." % p_malus)
	scheda.dettagli = "\n".join(righe)
	return scheda


## Un elemento della plancia del giocatore, con livello e modificatori che lo colpiscono.
static func da_pezzo(run: RunState, pezzo: BoardPiece) -> SchedaCarta:
	var nomi_malus: PackedStringArray = PackedStringArray()
	for modificatore: ActiveModifier in run.modifiers.for_piece(pezzo):
		if modificatore.def.is_malus:
			nomi_malus.append(modificatore.def.display_name)
	var malus_testo: String = ", ".join(nomi_malus)
	if pezzo.building != null:
		return da_edificio(run.effective_building(pezzo), pezzo.level, malus_testo)
	return da_truppa(run.effective_troop(pezzo), pezzo.level, malus_testo, pezzo.hungry)


static func da_offerta(run: RunState, offerta: Offer) -> SchedaCarta:
	var scheda: SchedaCarta
	match offerta.kind:
		OpportunityDef.Kind.COSTRUISCI_EDIFICIO:
			scheda = da_edificio(offerta.building)
		OpportunityDef.Kind.RECLUTA_TRUPPA:
			scheda = da_truppa(offerta.troop)
		_:
			scheda = SchedaCarta.new()
			scheda.genere = Genere.AZIONE
			scheda.id = offerta.opportunity.id
			scheda.titolo = offerta.opportunity.display_name
			scheda.riga = _riassunto_azione(offerta.opportunity)
			scheda.dettagli = offerta.opportunity.description
			scheda.illustrazione = _carica("azioni/%s.png" % offerta.opportunity.id)
	scheda.sopratitolo = offerta.opportunity.display_name
	scheda.costo = offerta.cost_text()
	scheda.disponibile = run.can_afford(offerta)
	if run.offer_needs_replacement(offerta):
		scheda.dettagli += "\nPlancia piena: sceglierai quale elemento sostituire (ti torna metà del prezzo)."
	elif not run.offer_choices(offerta).is_empty():
		scheda.dettagli += "\nDopo averla presa scegli una voce."
	return scheda


static func da_incontro(incontro: EncounterDef) -> SchedaCarta:
	var scheda: SchedaCarta = SchedaCarta.new()
	scheda.genere = Genere.INCONTRO
	scheda.titolo = incontro.display_name
	scheda.sopratitolo = incontro.difficulty_label
	scheda.riga = "Resistenza %d" % incontro.resistance
	scheda.illustrazione = _carica("incontri/%s.png" % incontro.resource_path.get_file().get_basename())
	var ricompense: PackedStringArray = PackedStringArray()
	for ricompensa: RewardDef in incontro.rewards:
		ricompense.append(ricompensa.describe())
	scheda.dettagli = "%s\nEdifici: %s.\nTruppe: %s.\nSe vinci scegli fra: %s.\nSe perdi, l'Oro del Magazzino si dimezza." % [
		incontro.description, _nomi_edifici(incontro.buildings), _nomi_truppe(incontro.troops), ", ".join(ricompense)]
	return scheda


static func da_ricompensa(ricompensa: RewardDef) -> SchedaCarta:
	var scheda: SchedaCarta
	match ricompensa.kind:
		RewardDef.Kind.EDIFICIO:
			scheda = da_edificio(ricompensa.building)
		RewardDef.Kind.TRUPPA:
			scheda = da_truppa(ricompensa.troop)
		_:
			scheda = SchedaCarta.new()
			scheda.genere = Genere.AZIONE
			scheda.titolo = ricompensa.describe()
			scheda.riga = ricompensa.describe()
			scheda.dettagli = ricompensa.perk.description if ricompensa.kind == RewardDef.Kind.PERK and ricompensa.perk != null else ricompensa.describe()
	scheda.sopratitolo = "Ricompensa"
	return scheda


static func da_fantasma(run: RunState, fantasma: GhostDef) -> SchedaCarta:
	var scheda: SchedaCarta = SchedaCarta.new()
	scheda.genere = Genere.FANTASMA
	scheda.titolo = fantasma.display_name.trim_prefix("Fantasma: ")
	scheda.sopratitolo = "Fantasma · era %s" % run.era_name(fantasma.era)
	scheda.riga = "Resistenza %d" % run.ghost_resistance()
	var identita: PackedStringArray = PackedStringArray()
	for elemento: IdentityDef in fantasma.identity:
		identita.append(elemento.display_name)
	var righe: PackedStringArray = PackedStringArray()
	if not identita.is_empty():
		righe.append(" · ".join(identita))
	righe.append("Se perdi: −%d Prestigio." % run.year)
	for malus_def: ModifierDef in fantasma.malus:
		righe.append("Se perdi o pareggi subisci %s: %s" % [malus_def.display_name, malus_def.description])
	righe.append("Puoi ancora riordinare o vendere le truppe prima di combattere.")
	scheda.dettagli = "\n".join(righe)
	return scheda


# --- Aiuti ---------------------------------------------------------------------

static func secondi(millisecondi: int) -> String:
	var testo: String = ("%.1f" % (millisecondi / 1000.0)).replace(".", ",")
	return testo.trim_suffix(",0") + " s"


static func _carica(percorso: String) -> Texture2D:
	var completo: String = CARTELLA_ILLUSTRAZIONI + percorso
	if ResourceLoader.exists(completo):
		return load(completo) as Texture2D
	return null


static func _riga_etichette(etichette: Array[StringName], p_livello: int) -> String:
	var nomi: PackedStringArray = PackedStringArray()
	for etichetta: StringName in etichette:
		nomi.append(String(etichetta))
	return "Livello %d di 3 · %s" % [p_livello, ", ".join(nomi) if not nomi.is_empty() else "nessuna etichetta"]


static func _riassunto_azione(opportunita: OpportunityDef) -> String:
	match opportunita.kind:
		OpportunityDef.Kind.SPAZIO_EDIFICIO:
			return "+1 spazio edificio"
		OpportunityDef.Kind.SPAZIO_TRUPPA:
			return "+1 spazio truppa"
		OpportunityDef.Kind.SCAMBIO_RISORSE:
			var dai: PackedStringArray = PackedStringArray()
			var ricevi: PackedStringArray = PackedStringArray()
			if opportunita.cost_gold > 0:
				dai.append("%d Oro" % opportunita.cost_gold)
			if opportunita.cost_research > 0:
				dai.append("%d Ricerca" % opportunita.cost_research)
			if opportunita.gain_gold > 0:
				ricevi.append("%d Oro" % opportunita.gain_gold)
			if opportunita.gain_research > 0:
				ricevi.append("%d Ricerca" % opportunita.gain_research)
			if dai.is_empty():
				return "+" + " +".join(ricevi)
			return "%s → %s" % [" + ".join(dai), " + ".join(ricevi)]
		OpportunityDef.Kind.MODIFICATORE_A_SCELTA:
			var nomi: PackedStringArray = PackedStringArray()
			for modificatore: ModifierDef in opportunita.modifiers:
				nomi.append(modificatore.display_name)
			return " o ".join(nomi)
		OpportunityDef.Kind.ACCORCIA_MALUS:
			return "−%d anno a un malus" % opportunita.shorten_years
	return ""


static func _nomi_edifici(lista: Array[BuildingDef]) -> String:
	var nomi: PackedStringArray = PackedStringArray()
	for def: BuildingDef in lista:
		nomi.append(def.display_name)
	return ", ".join(nomi) if not nomi.is_empty() else "nessuno"


static func _nomi_truppe(lista: Array[TroopDef]) -> String:
	var nomi: PackedStringArray = PackedStringArray()
	for def: TroopDef in lista:
		nomi.append(def.display_name)
	return ", ".join(nomi) if not nomi.is_empty() else "nessuna"
