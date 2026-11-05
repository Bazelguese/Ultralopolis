class_name SchedaCarta
extends RefCounted
## Quello che una carta mostra: nome, numeri, colori e testo dei dettagli.
## Si costruisce dai dati veri del gioco (catalogo, plancia, offerte, incontri).
## Solo presentazione: legge i dati, non contiene regole di gioco.

enum Genere { EDIFICIO, TRUPPA, AZIONE, INCONTRO, FANTASMA, VIA, CONSIGLIERE }

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
## Altri effetti in battaglia (GDD §7.6): scudo, cura, Corruzione, attacco d'assedio.
var scudo: int = 0
var cura: int = 0
var corruzione: int = 0
var assedio: int = 0
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
## Colore della categoria di un consigliere (solo grafica).
var colore_consigliere: StringName = &""


func colore_cornice() -> Color:
	match genere:
		Genere.AZIONE:
			return StileVisivo.CORNICE_AZIONE
		Genere.VIA:
			return StileVisivo.ORO_LUCE
		Genere.INCONTRO, Genere.FANTASMA:
			return StileVisivo.CORNICE_MINACCIA
		Genere.CONSIGLIERE:
			return StileVisivo.colore_mana_nome(colore_consigliere) if colore_consigliere != &"" else StileVisivo.ORO_LUCE
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
	scheda.scudo = def.shield
	scheda.cura = def.heal
	scheda.corruzione = def.corruption
	scheda.illustrazione = _carica("edifici/%s.png" % def.id)
	var righe: PackedStringArray = PackedStringArray()
	var produzione: PackedStringArray = PackedStringArray()
	for tipo: Res.Type in Res.NAMES:
		var quanto: int = def.production(tipo)
		if quanto != 0:
			produzione.append("+%d %s" % [quanto, Res.NAMES[tipo]])
	scheda.riga = " · ".join(produzione.slice(0, 2))
	righe.append("A ogni fase: %s." % (", ".join(produzione) if not produzione.is_empty() else "nessuna risorsa"))
	if def.mana_amount > 0:
		righe.append("In battaglia: %d %s ogni %s." % [def.mana_amount, def.mana_type, secondi(def.mana_interval_ms)])
	else:
		righe.append("Edificio neutro: non produce mana.")
	righe.append_array(_righe_effetti(def.shield, def.heal, def.corruption, 0, def.inefficiency_ms, def.inefficiency_target, def.sabotage_ms, def.sabotage_target, "ogni %s" % secondi(def.mana_interval_ms)))
	if def.extra_building_slots > 0:
		righe.append("+%d spazio edificio." % def.extra_building_slots)
	if def.extra_troop_slots > 0:
		righe.append("+%d spazio truppa." % def.extra_troop_slots)
	if def.is_capital:
		righe.append("Non si può vendere né sostituire.")
	righe.append(_riga_tipi(def.types, p_livello))
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
	scheda.scudo = def.shield
	scheda.cura = def.heal
	scheda.corruzione = def.corruption
	scheda.assedio = def.siege_damage
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
	if def.damage > 0:
		righe.append("%d danni (prima allo scudo, poi alla Resistenza) · ricarica %s." % [def.damage, secondi(def.cooldown_ms)])
	else:
		righe.append("Ricarica %s." % secondi(def.cooldown_ms))
	righe.append_array(_righe_effetti(def.shield, def.heal, def.corruption, def.siege_damage, def.inefficiency_ms, def.inefficiency_target, def.sabotage_ms, def.sabotage_target, "a ogni attivazione"))
	righe.append("Mangia %s Cibo a inizio anno." % Res.format(Res.Type.CIBO, def.food_tenths))
	if p_affamata:
		righe.append("Affamata: ricarica più lenta fino al prossimo pasto.")
	righe.append(_riga_tipi(def.types, p_livello))
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
	var scheda: SchedaCarta = da_truppa(run.effective_troop(pezzo), pezzo.level, malus_testo, pezzo.hungry)
	if pezzo.enchant != null:
		scheda.dettagli += "\n%s (già compreso nei valori)." % pezzo.enchant.display_name
	return scheda


static func da_offerta(run: RunState, offerta: Offer) -> SchedaCarta:
	var scheda: SchedaCarta
	match offerta.kind:
		OpportunityDef.Kind.COSTRUISCI_EDIFICIO:
			scheda = da_edificio(offerta.building)
			scheda.sopratitolo = "Edificio"
		OpportunityDef.Kind.RECLUTA_TRUPPA:
			scheda = da_truppa(offerta.troop)
			scheda.sopratitolo = "Truppa"
		OpportunityDef.Kind.PERK:
			scheda = SchedaCarta.new()
			scheda.genere = Genere.AZIONE
			scheda.id = offerta.perk.id
			scheda.titolo = offerta.perk.display_name
			scheda.riga = "Perk"
			scheda.dettagli = "%s\n%s" % [offerta.perk.description, offerta.opportunity.description]
			scheda.illustrazione = _carica("perk/%s.png" % offerta.perk.id)
			scheda.sopratitolo = "Perk"
		_:
			scheda = SchedaCarta.new()
			scheda.genere = Genere.AZIONE
			scheda.id = offerta.opportunity.id
			scheda.titolo = offerta.opportunity.display_name
			scheda.riga = _riassunto_azione(offerta.opportunity)
			scheda.dettagli = offerta.opportunity.description
			scheda.illustrazione = _carica("azioni/%s.png" % offerta.opportunity.id)
			scheda.sopratitolo = "Azione"
	scheda.costo = offerta.cost_text()
	scheda.disponibile = run.can_afford(offerta)
	if run.offer_needs_replacement(offerta):
		scheda.dettagli += "\nPlancia piena: sceglierai quale elemento sostituire (ti torna metà del prezzo)."
	elif not run.offer_choices(offerta).is_empty():
		scheda.dettagli += "\nDopo averla presa scegli una voce."
	return scheda


## Un consigliere del round (GDD §4.2): categoria, tipi, risorsa di Potenzia e che cosa propone.
static func da_consigliere(run: RunState, consigliere: AdvisorDef) -> SchedaCarta:
	var scheda: SchedaCarta = SchedaCarta.new()
	scheda.genere = Genere.CONSIGLIERE
	scheda.id = consigliere.id
	scheda.titolo = consigliere.display_name
	scheda.colore_consigliere = consigliere.color
	scheda.sopratitolo = consigliere.category_name if consigliere.category_name != "" else "Consigliere speciale"
	scheda.sopratitolo += " · %s" % run.council_level_name()
	scheda.illustrazione = _carica("consiglieri/%s.png" % consigliere.id)
	var righe: PackedStringArray = PackedStringArray()
	righe.append(consigliere.description)
	match consigliere.special:
		AdvisorDef.Special.CLOWN:
			scheda.riga = "5 colori"
			righe.append("Ignora il tema del round. Non offre Potenzia; si rinnova solo in Oro.")
		AdvisorDef.Special.ANZIANO:
			scheda.riga = "Perk · neutri"
			righe.append("Ignora il tema del round. Potenzia: solo edifici neutri, una volta all'anno, in Oro.")
		AdvisorDef.Special.VISITATORE:
			scheda.sopratitolo = "Visitatore · %s" % consigliere.category_name
			scheda.riga = "Di passaggio"
			righe.append("Ignora il tema del round. Non potenzia; si rinnova solo in Oro.")
		_:
			scheda.riga = "Potenzia: %s" % run.advisor_resource_text(consigliere)
			righe.append("Tipi: %s." % ", ".join(consigliere.types))
			righe.append("Potenzia e rinnovo con: %s." % run.advisor_resource_text(consigliere))
	scheda.costo = "Ascolta"
	scheda.dettagli = "\n".join(righe)
	return scheda


## Un Evento o una Fortuna fra le carte del round (GDD §4.2.5).
static func da_evento(run: RunState, evento: EventDef) -> SchedaCarta:
	var scheda: SchedaCarta = SchedaCarta.new()
	scheda.genere = Genere.CONSIGLIERE
	scheda.id = evento.id
	scheda.titolo = evento.display_name
	scheda.colore_consigliere = evento.color
	var fortuna: bool = evento.family == EventDef.Family.FORTUNA
	scheda.sopratitolo = "%s · %s" % ["Fortuna" if fortuna else "Evento", evento.sphere]
	scheda.illustrazione = _carica("eventi/%s.png" % evento.id)
	scheda.riga = "Un dono" if fortuna else "%d scelte" % evento.options.size()
	var righe: PackedStringArray = PackedStringArray()
	righe.append(evento.description)
	if evento.special == EventDef.Special.RIVOLUZIONE:
		scheda.riga = "Arriva da sola"
		for governo: IdentityDef in run.revolution_targets():
			righe.append("• Verso: %s" % governo.display_name)
		righe.append("Causa principale del Malcontento: %s." % IdentityDef.GRIEVANCE_NAMES[run.main_grievance()])
	elif evento.special == EventDef.Special.RIFORMA:
		scheda.riga = "%d scelte" % (run.evolution_targets().size() + evento.options.size())
		for governo: IdentityDef in run.evolution_targets():
			righe.append("• Verso: %s" % governo.display_name)
	for opzione: EventOptionDef in evento.options:
		var requisito: String = run.option_requirement(opzione)
		righe.append("• %s%s" % ["[%s] " % requisito if requisito != "" else "", opzione.label])
	righe.append("Ignora il tema del round. Sceglierlo è la scelta del round.")
	scheda.costo = "Scegli"
	scheda.dettagli = "\n".join(righe)
	return scheda


## Un'opzione dell'evento scelto: se è bloccata la carta è spenta e dice perché (principio P4).
static func da_opzione(run: RunState, opzione: EventOptionDef) -> SchedaCarta:
	var scheda: SchedaCarta = SchedaCarta.new()
	scheda.genere = Genere.AZIONE
	scheda.titolo = opzione.label
	var requisito: String = run.option_requirement(opzione)
	scheda.sopratitolo = requisito if requisito != "" else "Opzione"
	scheda.riga = opzione.description
	scheda.costo = opzione.cost.describe() if opzione.cost != null and not opzione.cost.is_empty() else "gratis"
	var motivo: String = run.option_block_reason(opzione)
	scheda.disponibile = motivo == ""
	scheda.dettagli = opzione.description if motivo == "" else "%s\nNon disponibile: %s" % [opzione.description, motivo]
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


static func da_via(via: IdentityDef) -> SchedaCarta:
	var scheda: SchedaCarta = SchedaCarta.new()
	scheda.genere = Genere.VIA
	scheda.id = via.id
	scheda.titolo = via.display_name
	scheda.sopratitolo = "Via"
	scheda.riga = "Scegli questa via"
	scheda.dettagli = via.description + "\nLa via diventa parte dell'identità: offerte, elementi esclusivi, un tratto permanente e un bonus immediato."
	scheda.illustrazione = _carica("vie/%s.png" % via.id)
	return scheda


## Un governo a cui la nazione può evolvere entrando nell'era (GDD §9.4, v0.24).
static func da_governo(governo: IdentityDef) -> SchedaCarta:
	var scheda: SchedaCarta = SchedaCarta.new()
	scheda.genere = Genere.VIA
	scheda.id = governo.id
	scheda.titolo = governo.display_name
	scheda.sopratitolo = "Governo · tier %d" % governo.tier
	scheda.riga = "Evolvi verso questo governo"
	scheda.costo = "Evolvi"
	scheda.dettagli = governo.description + "\nIl tratto del governo attuale finisce e vale questo; le carte sulla plancia restano."
	scheda.illustrazione = _carica("identita/%s.png" % governo.id)
	return scheda


## La carta per rifiutare l'evoluzione del governo.
static func da_resta(governo: IdentityDef) -> SchedaCarta:
	var scheda: SchedaCarta = SchedaCarta.new()
	scheda.genere = Genere.VIA
	scheda.titolo = "Resta com'è"
	scheda.sopratitolo = "Governo"
	scheda.riga = "Rifiuta l'evoluzione"
	scheda.costo = "Resta"
	scheda.dettagli = "Il governo resta %s. Potrai evolvere entrando nella prossima era, o con una Riforma." % (governo.display_name if governo != null else "com'è")
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


## Righe del riquadro dei dettagli per gli effetti di battaglia oltre al danno (GDD §7.6, §7.7).
static func _righe_effetti(scudo_v: int, cura_v: int, corruzione_v: int, assedio_v: int, inefficienza_ms: int, bersaglio_inefficienza: TimerTarget.Kind, sabotaggio_ms: int, bersaglio_sabotaggio: TimerTarget.Kind, quando: String) -> PackedStringArray:
	var righe: PackedStringArray = PackedStringArray()
	if scudo_v > 0:
		righe.append("+%d scudo %s." % [scudo_v, quando])
	if cura_v > 0:
		righe.append("Cura %d Resistenza %s." % [cura_v, quando])
	if corruzione_v > 0:
		righe.append("%d Corruzione all'avversario %s." % [corruzione_v, quando])
	if assedio_v > 0:
		righe.append("Assedio: toglie %d scudo all'avversario." % assedio_v)
	if inefficienza_ms > 0:
		righe.append("Rallenta %s avversari di %s." % [TimerTarget.NAMES[bersaglio_inefficienza], secondi(inefficienza_ms)])
	if sabotaggio_ms > 0:
		righe.append("Sabota %s avversari per %s." % [TimerTarget.NAMES[bersaglio_sabotaggio], secondi(sabotaggio_ms)])
	return righe


static func _riga_tipi(tipi: Array[StringName], p_livello: int) -> String:
	var nomi: PackedStringArray = PackedStringArray()
	for tipo: StringName in tipi:
		nomi.append(String(tipo))
	return "Livello %d di 3 · Tipi: %s" % [p_livello, ", ".join(nomi) if not nomi.is_empty() else "nessuno"]


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
			if opportunita.cost_resources != null and not opportunita.cost_resources.is_empty():
				dai.append(opportunita.cost_resources.describe())
			if opportunita.gain_resources != null and not opportunita.gain_resources.is_empty():
				ricevi.append(opportunita.gain_resources.describe())
			if opportunita.malcontent_change != 0:
				ricevi.append("%+d Malcontento" % opportunita.malcontent_change)
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
		OpportunityDef.Kind.SPIONAGGIO:
			return "Sabota il fantasma" if opportunita.spy_effect == OpportunityDef.SpyEffect.SABOTAGGIO else "Rallenta il fantasma"
		OpportunityDef.Kind.INCANTO:
			return "Incanta una truppa"
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
