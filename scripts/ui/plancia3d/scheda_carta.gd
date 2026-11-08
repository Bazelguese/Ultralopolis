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
## Scritta sotto la carta: il prezzo di un'offerta ("3 Oro") oppure, per le carte che non si
## comprano, il verbo della scelta ("Ascolta", "Scegli", "Evolvi").
var costo: String = ""
## true solo se la scritta sotto la carta è un prezzo vero: solo allora il riquadro dice
## "Costo: …" (decisione di Davide, 8 novembre: "Costo: Ascolta" non ha senso).
var prezzo: bool = false
## Testo completo del riquadro che compare passando il mouse.
var dettagli: String = ""
var illustrazione: Texture2D
## false se l'offerta non si può pagare: la carta appare spenta.
var disponibile: bool = true
## Colore della categoria di un consigliere (solo grafica).
var colore_consigliere: StringName = &""
## Righe di simboli stampate sulla carta, come nei giochi da tavolo (consiglieri, azioni, eventi).
## Se ci sono, prendono il posto della riga di testo.
var simboli: Array[RigaSimboli] = []
## Tipi della tessera, o del consigliere (i tipi della sua categoria): medaglioni sulla linguetta sopra la carta.
var tipi: Array[StringName] = []


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

## p_livello_massimo: il livello più alto delle tessere nella partita (0 se non si conosce: allora
## il riquadro dice solo il livello).
static func da_edificio(def: BuildingDef, p_livello: int = 1, p_malus: String = "", p_livello_massimo: int = 0) -> SchedaCarta:
	return _edificio(def, p_livello, p_malus, _produzione_di_base(def), p_livello_massimo)


## p_regole: le regole cambiate dalle ascensioni del giocatore (regole_di), per le sue truppe;
## vuoto per le truppe del nemico, che seguono la regola normale.
static func da_truppa(def: TroopDef, p_livello: int = 1, p_malus: String = "", p_affamata: bool = false, p_livello_massimo: int = 0, p_regole: Array[int] = []) -> SchedaCarta:
	return _truppa(def, p_livello, p_malus, p_affamata, def.food_tenths, p_livello_massimo, p_regole)


## Le regole del gioco che le ascensioni della nazione cambiano (GDD §10.4.2): i testi le dicono
## a chi le ha (decisione di Davide, 8 novembre 2026).
static func regole_di(run: RunState) -> Array[int]:
	var regole: Array[int] = []
	if run == null:
		return regole
	for regola: int in IdentityDef.Rule.values():
		if regola != IdentityDef.Rule.NESSUNA and run.has_rule(regola as IdentityDef.Rule):
			regole.append(regola)
	return regole


## produzione: quello che l'edificio deposita a ogni stagione, in unità interne (Res).
static func _edificio(def: BuildingDef, p_livello: int, p_malus: String, produzione: Array[int], p_livello_massimo: int) -> SchedaCarta:
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
	scheda.tipi = def.types.duplicate()
	scheda.illustrazione = _carica("edifici/%s.png" % def.id)
	var righe: PackedStringArray = PackedStringArray()
	var sulla_carta: PackedStringArray = PackedStringArray()
	var nel_riquadro: PackedStringArray = PackedStringArray()
	for tipo: Res.Type in Res.NAMES:
		var quanto: int = produzione[tipo]
		if quanto == 0:
			continue
		var testo: String = "%s%s %s" % ["+" if quanto > 0 else "", Res.format(tipo, quanto), Res.NAMES[tipo]]
		sulla_carta.append(testo)
		# D'inverno gli edifici non producono Cibo (GDD §5.2).
		nel_riquadro.append(testo + (" (non d'inverno)" if tipo == Res.Type.CIBO and quanto > 0 else ""))
	scheda.riga = " · ".join(sulla_carta.slice(0, 2))
	righe.append("A ogni stagione: %s." % (", ".join(nel_riquadro) if not nel_riquadro.is_empty() else "nessuna risorsa"))
	var ciclo: String = "ogni ciclo di %s" % secondi(def.mana_interval_ms)
	if def.mana_amount > 0:
		righe.append("Nello scontro: %d mana %s %s." % [def.mana_amount, def.mana_type, ciclo])
	else:
		righe.append("Edificio neutro: non produce mana.")
	righe.append_array(_righe_effetti(def.shield, def.heal, def.corruption, 0, def.inefficiency_ms, def.inefficiency_target, def.sabotage_ms, def.sabotage_target, ciclo))
	if def.extra_building_slots > 0:
		righe.append("+%d spazio edificio." % def.extra_building_slots)
	if def.extra_troop_slots > 0:
		righe.append("+%d spazio truppa." % def.extra_troop_slots)
	if def.is_capital:
		righe.append("Non si può vendere né sostituire.")
	righe.append(_riga_tipi(def.types, p_livello, p_livello_massimo, def.is_capital))
	if p_malus != "":
		righe.append("Colpito da: %s." % p_malus)
	scheda.dettagli = "\n".join(righe)
	return scheda


## razione: il Cibo che la truppa mangia a inizio anno, in decimi (Res).
static func _truppa(def: TroopDef, p_livello: int, p_malus: String, p_affamata: bool, razione: int, p_livello_massimo: int, regole: Array[int] = []) -> SchedaCarta:
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
	scheda.tipi = def.types.duplicate()
	scheda.illustrazione = _carica("truppe/%s.png" % def.id)
	var righe: PackedStringArray = PackedStringArray()
	if def.mana_cost > 0:
		if regole.has(IdentityDef.Rule.MANA_UNITO):
			righe.append("Costa %d mana %s (se manca, usa l'energetico e poi, con Mana unito, gli altri colori)." % [def.mana_cost, def.mana_type])
		else:
			righe.append("Costa %d mana %s (se manca, usa l'energetico)." % [def.mana_cost, def.mana_type])
	else:
		righe.append("Non chiede mana: si attiva appena finisce la ricarica.")
	if def.damage > 0:
		righe.append("%d %s (prima allo scudo, poi alla Resistenza) · ricarica %s." % [def.damage, "danno" if def.damage == 1 else "danni", secondi(def.cooldown_ms)])
	else:
		righe.append("Ricarica %s." % secondi(def.cooldown_ms))
	righe.append_array(_righe_effetti(def.shield, def.heal, def.corruption, def.siege_damage, def.inefficiency_ms, def.inefficiency_target, def.sabotage_ms, def.sabotage_target, "a ogni attivazione"))
	# La razione si mangia dal secondo anno (GDD §5.4); quella vera passa per bonus e malus.
	var riga_razione: String = "Razione: %s Cibo a inizio anno (dal secondo anno" % Res.format(Res.Type.CIBO, razione)
	if razione != def.food_tenths:
		riga_razione += "; di base %s" % Res.format(Res.Type.CIBO, def.food_tenths)
	righe.append(riga_razione + ").")
	if p_affamata:
		if regole.has(IdentityDef.Rule.ESERCITO_FRUGALE):
			righe.append("Affamata, ma con Esercito frugale non rallenta.")
		else:
			righe.append("Affamata: ricarica più lenta fino al prossimo pasto.")
	righe.append(_riga_tipi(def.types, p_livello, p_livello_massimo, false))
	if p_malus != "":
		righe.append("Colpita da: %s." % p_malus)
	scheda.dettagli = "\n".join(righe)
	return scheda


## Produzione di catalogo di un edificio, al livello 1 e senza bonus, in unità interne (Res).
static func _produzione_di_base(def: BuildingDef) -> Array[int]:
	var produzione: Array[int] = Res.empty()
	for tipo: Res.Type in Res.NAMES:
		produzione[tipo] = def.production(tipo) * Res.scale(tipo)
	return produzione


## Un elemento della plancia del giocatore, con livello e modificatori che lo colpiscono.
static func da_pezzo(run: RunState, pezzo: BoardPiece) -> SchedaCarta:
	var nomi_malus: PackedStringArray = PackedStringArray()
	for modificatore: ActiveModifier in run.modifiers.for_piece(pezzo):
		if modificatore.def.is_malus:
			nomi_malus.append(modificatore.def.display_name)
	var malus_testo: String = ", ".join(nomi_malus)
	var scheda: SchedaCarta
	# Sulla plancia i numeri sono quelli veri: livello, bonus e malus, e per la Capitale anche le
	# risorse in più dell'identità (GDD §6.2); la razione passa per i suoi modificatori (§5.4).
	if pezzo.building != null:
		scheda = _edificio(run.effective_building(pezzo), pezzo.level, malus_testo, run.building_production(pezzo), run.max_level())
	else:
		scheda = _truppa(run.effective_troop(pezzo), pezzo.level, malus_testo, pezzo.hungry, run.troop_ration(pezzo), run.max_level(), regole_di(run))
	scheda.dettagli += _riga_mantenimento(run, pezzo)
	if pezzo.building != null:
		return scheda
	if pezzo.enchant != null:
		scheda.dettagli += "\n%s (già compreso nei valori)." % pezzo.enchant.display_name
	if pezzo.second_enchant != null:
		scheda.dettagli += "\nSecondo incanto, Seconda natura: %s (già compreso nei valori)." % pezzo.second_enchant.display_name
	return scheda


static func da_offerta(run: RunState, offerta: Offer) -> SchedaCarta:
	var scheda: SchedaCarta
	match offerta.kind:
		OpportunityDef.Kind.COSTRUISCI_EDIFICIO:
			scheda = da_edificio(offerta.building, 1, "", run.max_level())
			scheda.sopratitolo = "Edificio"
		OpportunityDef.Kind.RECLUTA_TRUPPA:
			scheda = da_truppa(offerta.troop, 1, "", false, run.max_level(), regole_di(run))
			scheda.sopratitolo = "Truppa"
		OpportunityDef.Kind.PERK:
			scheda = SchedaCarta.new()
			scheda.genere = Genere.AZIONE
			scheda.id = offerta.perk.id
			scheda.titolo = offerta.perk.display_name
			scheda.riga = "Peculiarità"
			scheda.dettagli = "%s\n%s" % [offerta.perk.description, offerta.opportunity.description]
			scheda.illustrazione = _carica("perk/%s.png" % offerta.perk.id)
			scheda.sopratitolo = "Peculiarità"
			scheda.simboli.append(SimboliEffetti.azione(offerta))
		_:
			scheda = SchedaCarta.new()
			scheda.genere = Genere.AZIONE
			scheda.id = offerta.opportunity.id
			scheda.titolo = offerta.opportunity.display_name
			scheda.riga = _riassunto_azione(offerta.opportunity)
			scheda.dettagli = offerta.opportunity.description
			scheda.illustrazione = _carica("azioni/%s.png" % offerta.opportunity.id)
			scheda.sopratitolo = "Azione"
			scheda.simboli.append(SimboliEffetti.azione(offerta))
	# Mantenimento delle carte speciali (GDD §5.6), da sapere prima di comprarle.
	if offerta.is_element():
		var prova: BoardPiece = BoardPiece.of_building(offerta.building, 0) if offerta.building != null else BoardPiece.of_troop(offerta.troop, 0)
		var costo_mantenimento: ResourceAmounts = run.upkeep_of(prova)
		if costo_mantenimento != null:
			scheda.dettagli += "\nTessera speciale: mantenimento %s prima di ogni scontro (di più se la potenzi)." % costo_mantenimento.describe()
	# Bonus già attivi che la carta riceverebbe per i suoi tipi (GDD §6.6): si vedono prima di comprarla.
	if offerta.is_element():
		var tipi: Array[StringName] = offerta.building.types if offerta.building != null else offerta.troop.types
		var bonus: PackedStringArray = run.type_bonuses_for(tipi, offerta.building != null)
		if not bonus.is_empty():
			scheda.sopratitolo += " · ▲ %d bonus" % bonus.size()
			scheda.dettagli += "\nNe beneficia: " + "; ".join(bonus) + "."
	scheda.costo = offerta.cost_text()
	scheda.prezzo = true
	scheda.disponibile = run.can_afford(offerta)
	if run.offer_needs_replacement(offerta):
		scheda.dettagli += "\nPlancia piena: sceglierai quale tessera sostituire (ti torna metà del prezzo)."
	elif not run.offer_choices(offerta).is_empty():
		scheda.dettagli += "\n" + _frase_scelta(offerta)
	return scheda


## Che cosa si sceglie dopo aver preso un'opportunità con più voci (RunState.offer_choices).
static func _frase_scelta(offerta: Offer) -> String:
	match offerta.kind:
		OpportunityDef.Kind.INCANTO:
			return "Dopo averla presa scegli la truppa da incantare."
		OpportunityDef.Kind.ACCORCIA_MALUS:
			return "Dopo averla presa scegli il malus da accorciare."
		OpportunityDef.Kind.MODIFICATORE_A_SCELTA:
			var su_truppa: bool = false
			var su_edificio: bool = false
			for modificatore: ModifierDef in offerta.opportunity.modifiers:
				su_truppa = su_truppa or modificatore.target == ModifierDef.Target.TRUPPA_SCELTA
				su_edificio = su_edificio or modificatore.target == ModifierDef.Target.EDIFICIO_SCELTO
			var piu_bonus: bool = offerta.opportunity.modifiers.size() > 1
			if piu_bonus and (su_truppa or su_edificio):
				return "Dopo averla presa scegli il bonus e la tessera che lo riceve."
			if su_truppa:
				return "Dopo averla presa scegli la truppa che riceve il bonus."
			if su_edificio:
				return "Dopo averla presa scegli l'edificio che riceve il bonus."
			return "Dopo averla presa scegli il bonus."
	return "Dopo averla presa scegli fra le sue voci."


## Mantenimento di una carta (GDD §5.6): che cosa paga prima di ogni scontro e se l'ultima volta
## è rimasta trascurata.
static func _riga_mantenimento(run: RunState, pezzo: BoardPiece) -> String:
	var costo: ResourceAmounts = run.upkeep_of(pezzo)
	var testo: String = ""
	if costo != null:
		testo = "\nMantenimento: %s prima di ogni scontro%s." % [costo.describe(), " (tessera speciale)" if run.is_special_card(pezzo.building if pezzo.building != null else pezzo.troop) else ""]
	if pezzo.neglected:
		testo += "\nTrascurata all'ultimo scontro: non pagata, ha lavorato più piano."
	return testo


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
	scheda.tipi = consigliere.types.duplicate()
	# Sotto la carta: "Ascolta" (scegli questo consigliere); se con lui puoi già potenziare
	# qualche tua carta, anche quante.
	scheda.costo = "Ascolta"
	var visitatore: bool = consigliere.special == AdvisorDef.Special.VISITATORE
	if visitatore:
		scheda.sopratitolo = "Visitatore · %s" % consigliere.category_name
		# Nel gioco il Visitatore si presenta come "Di passaggio", la Fortuna come "Un dono" (Glossario).
		scheda.riga = "Di passaggio"
	var pronte: int = run.affordable_upgrades(consigliere).size() if consigliere.special == AdvisorDef.Special.NESSUNO else 0
	if pronte > 0:
		scheda.costo = "Ascolta · ▲ Potenzia %d" % pronte
	# Il riquadro dei dettagli dice solo ciò che si vede sulla carta (richiesta di Davide):
	# una frase per ogni riga di simboli, nello stesso ordine.
	scheda.simboli = SimboliEffetti.consigliere(run, consigliere)
	var righe: PackedStringArray = PackedStringArray()
	# La linguetta sopra mostra i tipi della sua categoria: la prima frase li nomina.
	if not scheda.tipi.is_empty():
		righe.append("Tipi: %s." % ", ".join(PackedStringArray(scheda.tipi)))
	# Il Visitatore dice anche chi è, che tessere porta e a che prezzi: è scritto nei suoi dati.
	if visitatore:
		righe.append("Di passaggio. %s" % consigliere.description if consigliere.description != "" else "Di passaggio.")
	for riga: RigaSimboli in scheda.simboli:
		if riga.etichetta != "":
			righe.append(riga.etichetta)
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
	if evento.special == EventDef.Special.RIVOLUZIONE:
		# Arriva da sola e non si può lasciar passare il round (RunState.pass_round).
		righe.append("Non si può evitare: scegli il nuovo governo. Poi il Malcontento si azzera.")
	else:
		righe.append("Ignora il tema del round. Sceglierlo è la scelta del round.")
	scheda.simboli = SimboliEffetti.evento(run, evento)
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
	scheda.prezzo = true
	var motivo: String = run.option_block_reason(opzione)
	scheda.disponibile = motivo == ""
	var scala: int = run.era if run.chosen_event != null and run.chosen_event.scale_with_era else 1
	scheda.simboli = SimboliEffetti.opzione_righe(opzione, scala)
	scheda.dettagli = opzione.description if motivo == "" else "%s\nNon disponibile: %s" % [opzione.description, motivo]
	return scheda


## run: la partita, per dire che cosa succede davvero se perdi (Malcontento, ultima possibilità).
## Facoltativa solo perché chi chiama può non averla: senza, il riquadro resta generico.
static func da_incontro(incontro: EncounterDef, run: RunState = null) -> SchedaCarta:
	var scheda: SchedaCarta = SchedaCarta.new()
	scheda.genere = Genere.INCONTRO
	scheda.titolo = incontro.display_name
	scheda.sopratitolo = incontro.difficulty_label
	scheda.riga = "Resistenza %d" % incontro.resistance
	scheda.illustrazione = _carica("incontri/%s.png" % incontro.resource_path.get_file().get_basename())
	var ricompense: PackedStringArray = PackedStringArray()
	for ricompensa: RewardDef in incontro.rewards:
		ricompense.append(ricompensa.describe())
	var righe: PackedStringArray = PackedStringArray()
	righe.append(incontro.description)
	righe.append("Edifici: %s." % _nomi_edifici(incontro.buildings))
	righe.append("Truppe: %s." % _nomi_truppe(incontro.troops))
	# Vittoria o pareggio (GDD §3.3, §3.4): il bottino arriva sempre, poi si sceglie la ricompensa.
	var vinci: PackedStringArray = PackedStringArray()
	var bottino: String = _testo_bottino(incontro.loot_gold, incontro.loot_research)
	if bottino != "":
		vinci.append("bottino di %s" % bottino)
	if not ricompense.is_empty():
		vinci.append("scegli una ricompensa fra: %s" % ", ".join(ricompense))
	if not vinci.is_empty():
		righe.append("Se vinci o pareggi: %s." % ", poi ".join(vinci))
	righe.append("Il pareggio conta come vittoria.")
	if run != null and run.last_chance:
		# Ultima possibilità (GDD §3.3, §3.4): perdere un incontro chiude la partita.
		righe.append("Se perdi, la partita finisce.")
	elif run != null:
		righe.append("Se perdi: l'Oro del Magazzino si dimezza e %+d Malcontento." % run.run_rules.malcontent_per_encounter_defeat)
	else:
		righe.append("Se perdi: l'Oro del Magazzino si dimezza e cresce il Malcontento.")
	scheda.dettagli = "\n".join(righe)
	return scheda


## run: la partita, per sapere se la plancia è piena e il livello massimo. Facoltativa solo perché
## chi chiama può non averla: senza, il riquadro lo dice in generale.
static func da_ricompensa(ricompensa: RewardDef, run: RunState = null) -> SchedaCarta:
	var scheda: SchedaCarta
	var livello_massimo: int = run.max_level() if run != null else 0
	match ricompensa.kind:
		RewardDef.Kind.EDIFICIO:
			scheda = da_edificio(ricompensa.building, 1, "", livello_massimo)
			scheda.dettagli += _righe_tessera_in_regalo(ricompensa, run)
		RewardDef.Kind.TRUPPA:
			scheda = da_truppa(ricompensa.troop, 1, "", false, livello_massimo, regole_di(run))
			scheda.dettagli += _righe_tessera_in_regalo(ricompensa, run)
			if ricompensa.assimilation:
				scheda.dettagli += "\nAssimilati (vocazione): una truppa del nemico vinto diventa tua, al posto della ricompensa. +1 Malcontento."
		_:
			scheda = SchedaCarta.new()
			scheda.genere = Genere.AZIONE
			scheda.titolo = ricompensa.describe()
			scheda.riga = ricompensa.describe()
			scheda.dettagli = ricompensa.perk.description if ricompensa.kind == RewardDef.Kind.PERK and ricompensa.perk != null else ricompensa.describe()
			if ricompensa.kind == RewardDef.Kind.TECNOLOGIA:
				scheda.dettagli = "Carta dorata: una tecnologia %s arriva già iniziata a metà e resta fra le carte della Ricerca finché non la completi." % ("(%s)" % ricompensa.tech.display_name if ricompensa.tech != null else "a caso della tua era")
	scheda.sopratitolo = "Ricompensa"
	return scheda


## Una tessera presa come ricompensa (RunState.take_reward): è gratis, entra al livello 1 e, se la
## plancia è piena, ne sostituisce una (con il rimborso di metà del suo prezzo, GDD §6.4).
static func _righe_tessera_in_regalo(ricompensa: RewardDef, run: RunState) -> String:
	var testo: String = "\nGratis: entra sulla plancia al livello 1. Se poi la vendi, ti torna metà del suo prezzo."
	var sostituzione: String = "sceglierai quale %s sostituire (ti torna metà di quanto l'avevi pagata%s)" % [
		"edificio" if ricompensa.kind == RewardDef.Kind.EDIFICIO else "truppa",
		"; la Capitale no" if ricompensa.kind == RewardDef.Kind.EDIFICIO else ""]
	if run == null:
		testo += "\nSe la plancia è piena, %s." % sostituzione
	elif run.reward_needs_replacement(ricompensa):
		testo += "\nPlancia piena: %s." % sostituzione
	return testo


static func da_via(via: IdentityDef) -> SchedaCarta:
	var scheda: SchedaCarta = SchedaCarta.new()
	scheda.genere = Genere.VIA
	scheda.id = via.id
	scheda.titolo = via.display_name
	scheda.sopratitolo = "Via"
	scheda.riga = "Scegli questa via"
	# Adozione della via (GDD §10.4, §10.4.1).
	scheda.dettagli = via.description + "\nLa via diventa parte dell'identità: le sue opportunità diventano più frequenti, apre tessere e tecnologie esclusive, dà un tratto permanente e un bonus immediato."
	if not via.traditions.is_empty():
		# Le imprese si vedono prima di scegliere la via (GDD §10.4.1, v0.27).
		scheda.dettagli += "\nTradizioni (completale tutte per un'ascensione). Le imprese contano da quando scegli la via:"
		for passo: TraditionDef in via.traditions:
			scheda.dettagli += "\n• %s: %s → %s" % [passo.display_name, passo.deed.describe() if passo.deed != null else "", passo.description]
	scheda.illustrazione = _carica("vie/%s.png" % via.id)
	return scheda


## Un'ascensione da scegliere completando l'albero di una via (GDD §10.4.2, v0.27).
static func da_ascensione(ascensione: IdentityDef) -> SchedaCarta:
	var scheda: SchedaCarta = SchedaCarta.new()
	scheda.genere = Genere.VIA
	scheda.id = ascensione.id
	scheda.titolo = ascensione.display_name
	scheda.sopratitolo = "Ascensione · livello %d" % ascensione.ascension_level
	scheda.riga = ascensione.description
	scheda.costo = "Scegli"
	scheda.dettagli = ascensione.description + "\nÈ permanente." + ("\nCambia una regola del gioco." if ascensione.rule != IdentityDef.Rule.NESSUNA else "")
	scheda.illustrazione = _carica("ascensioni/%s.png" % ascensione.id)
	return scheda


## Un governo a cui la nazione può evolvere entrando nell'era (GDD §9.4, v0.24).
static func da_governo(governo: IdentityDef) -> SchedaCarta:
	var scheda: SchedaCarta = SchedaCarta.new()
	scheda.genere = Genere.VIA
	scheda.id = governo.id
	scheda.titolo = governo.display_name
	scheda.sopratitolo = "Governo · rango %d" % governo.tier
	scheda.riga = "Evolvi verso questo governo"
	scheda.costo = "Evolvi"
	scheda.dettagli = governo.description + "\nIl tratto del governo attuale finisce e vale questo; le tessere sulla plancia restano."
	scheda.illustrazione = _carica("identita/%s.png" % governo.id)
	return scheda


## La carta per rifiutare l'evoluzione del governo.
## run: la partita, per sapere se questa è l'ultima era. Facoltativa solo perché chi chiama può non
## averla: senza, si scrive il testo delle ere che non sono l'ultima.
static func da_resta(governo: IdentityDef, run: RunState = null) -> SchedaCarta:
	var scheda: SchedaCarta = SchedaCarta.new()
	scheda.genere = Genere.VIA
	scheda.titolo = "Resta com'è"
	scheda.sopratitolo = "Governo"
	scheda.riga = "Rifiuta l'evoluzione"
	scheda.costo = "Resta"
	var ultima_era: bool = run != null and run.era >= run.catalog.eras.size()
	scheda.dettagli = "Il governo resta %s. %s" % [governo.display_name if governo != null else "com'è",
			"Potrai evolvere solo con una Riforma." if ultima_era else "Potrai evolvere entrando nella prossima era, o con una Riforma."]
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
	# Vittoria o pareggio (GDD §3.4): una vittoria in più e il bottino.
	var vinci: String = "Se vinci o pareggi: vittoria %d di %d" % [run.wins + 1, run.run_rules.wins_needed]
	var bottino: String = _testo_bottino(run.run_rules.ghost_loot_gold, run.run_rules.ghost_loot_research)
	if bottino != "":
		vinci += " e bottino di %s" % bottino
	righe.append(vinci + ".")
	righe.append("Il pareggio conta come vittoria, ma subisci i malus." if not fantasma.malus.is_empty() else "Il pareggio conta come vittoria.")
	if run.last_chance:
		# Ultima possibilità (GDD §3.4): la prossima sconfitta chiude la partita.
		righe.append("Se perdi, la partita finisce.")
	else:
		var perdi: String = "Se perdi: −%d Prestigio e %+d Malcontento" % [run.year, run.run_rules.malcontent_per_ghost_defeat]
		if not fantasma.malus.is_empty():
			perdi += ", più i malus"
		perdi += "."
		if run.prestige - run.year <= 0:
			perdi += " Il Prestigio finirebbe: comincerebbe l'ultima possibilità."
		righe.append(perdi)
	if run.prophecy != "":
		righe.append("Profezia: schiera %s." % run.prophecy)
	# I malus del fantasma arrivano a fine anno (GDD §11.1), ognuno con il suo Malcontento.
	var quando: String = "Se pareggi" if run.last_chance else "Se perdi o pareggi"
	for malus_def: ModifierDef in fantasma.malus:
		righe.append("%s subisci %s %s (%+d Malcontento): %s" % [quando, malus_def.display_name, _durata_malus(malus_def), run.run_rules.malcontent_per_malus, malus_def.description])
	righe.append("Puoi ancora riordinare o vendere le truppe prima di combattere.")
	scheda.dettagli = "\n".join(righe)
	return scheda


# --- Aiuti ---------------------------------------------------------------------

## Che cosa cambierebbe con il Potenzia (richiesta di Davide, 8 novembre): solo i valori che
## cambiano, "prima → dopo", compreso il mantenimento. Vuoto se la tessera è al livello massimo.
## Legge i valori dalle regole (RunState): qui non si calcola nulla.
static func anteprima_potenzia(run: RunState, pezzo: BoardPiece) -> String:
	# La Capitale non si potenzia: nessun consigliere ha il suo tipo.
	if pezzo.level >= run.max_level() or (pezzo.building != null and pezzo.building.is_capital):
		return ""
	var dopo: int = pezzo.level + 1
	var righe: PackedStringArray = PackedStringArray()
	if pezzo.building != null:
		var ora_e: BuildingDef = run.effective_building(pezzo)
		var poi_e: BuildingDef = run.effective_building(pezzo, dopo)
		var produzione_ora: Array[int] = run.building_production(pezzo)
		var produzione_poi: Array[int] = run.building_production(pezzo, dopo)
		for tipo: Res.Type in Res.NAMES:
			if produzione_ora[tipo] != produzione_poi[tipo]:
				righe.append("%s a ogni stagione: +%s → +%s" % [Res.NAMES[tipo], Res.format(tipo, produzione_ora[tipo]), Res.format(tipo, produzione_poi[tipo])])
		_confronta(righe, "scudo", ora_e.shield, poi_e.shield)
		_confronta(righe, "cura", ora_e.heal, poi_e.heal)
		_confronta(righe, "Corruzione", ora_e.corruption, poi_e.corruption)
		_confronta_secondi(righe, "Inefficienza", ora_e.inefficiency_ms, poi_e.inefficiency_ms)
		_confronta_secondi(righe, "Sabotaggio", ora_e.sabotage_ms, poi_e.sabotage_ms)
		_confronta_secondi(righe, "ciclo", ora_e.mana_interval_ms, poi_e.mana_interval_ms)
	else:
		var ora_t: TroopDef = run.effective_troop(pezzo)
		var poi_t: TroopDef = run.effective_troop(pezzo, dopo)
		_confronta(righe, "danno", ora_t.damage, poi_t.damage)
		_confronta(righe, "scudo", ora_t.shield, poi_t.shield)
		_confronta(righe, "cura", ora_t.heal, poi_t.heal)
		_confronta(righe, "Corruzione", ora_t.corruption, poi_t.corruption)
		_confronta(righe, "danno d'assedio", ora_t.siege_damage, poi_t.siege_damage)
		_confronta_secondi(righe, "Inefficienza", ora_t.inefficiency_ms, poi_t.inefficiency_ms)
		_confronta_secondi(righe, "Sabotaggio", ora_t.sabotage_ms, poi_t.sabotage_ms)
		_confronta_secondi(righe, "ricarica", ora_t.cooldown_ms, poi_t.cooldown_ms)
	var mantenimento_ora: ResourceAmounts = run.upkeep_of(pezzo)
	var mantenimento_poi: ResourceAmounts = run.upkeep_of(pezzo, dopo)
	var testo_ora: String = mantenimento_ora.describe() if mantenimento_ora != null else "nessuno"
	var testo_poi: String = mantenimento_poi.describe() if mantenimento_poi != null else "nessuno"
	if testo_ora != testo_poi:
		righe.append("mantenimento prima di ogni scontro: %s → %s" % [testo_ora, testo_poi])
	if righe.is_empty():
		return "Con Potenzia sale al livello %d." % dopo
	return "Con Potenzia, al livello %d:\n• %s" % [dopo, "\n• ".join(righe)]


static func _confronta(righe: PackedStringArray, nome: String, ora: int, poi: int) -> void:
	if ora != poi:
		righe.append("%s %d → %d" % [nome, ora, poi])


static func _confronta_secondi(righe: PackedStringArray, nome: String, ora: int, poi: int) -> void:
	if ora != poi:
		righe.append("%s %s → %s" % [nome, secondi(ora), secondi(poi)])


static func secondi(millisecondi: int) -> String:
	var testo: String = ("%.1f" % (millisecondi / 1000.0)).replace(".", ",")
	return testo.trim_suffix(",0") + " s"


## "3 Oro e 2 Ricerca"; vuoto se il bottino non c'è.
static func _testo_bottino(oro: int, ricerca: int) -> String:
	var parti: PackedStringArray = PackedStringArray()
	if oro > 0:
		parti.append("%d Oro" % oro)
	if ricerca > 0:
		parti.append("%d Ricerca" % ricerca)
	return " e ".join(parti)


## Quanto dura un malus del fantasma, che arriva a fine anno: un malus a durata vale per gli anni
## interi successivi (scripts/sim/run/modifiers.gd, GDD §8.2.1).
static func _durata_malus(def: ModifierDef) -> String:
	match def.duration_kind:
		ModifierDef.Duration.PERMANENTE:
			return "per tutta la partita"
		ModifierDef.Duration.PROSSIMO_SCONTRO_FANTASMA:
			return "fino al prossimo scontro con un fantasma"
	if def.duration_years <= 1:
		return "per tutto l'anno prossimo"
	return "per i prossimi %d anni" % def.duration_years


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
		righe.append("%d Corruzione al nemico %s." % [corruzione_v, quando])
	if assedio_v > 0:
		righe.append("Danno d'assedio: toglie fino a %d scudo al nemico." % assedio_v)
	# Inefficienza e Sabotaggio colpiscono una sola tessera nemica, a caso e a turno (GDD §7.7.2).
	if inefficienza_ms > 0:
		righe.append("Rende Inefficiente %s per %s, %s." % [_bersaglio_a_caso(bersaglio_inefficienza), secondi(inefficienza_ms), quando])
	if sabotaggio_ms > 0:
		righe.append("Sabota %s per %s, %s." % [_bersaglio_a_caso(bersaglio_sabotaggio), secondi(sabotaggio_ms), quando])
	return righe


## "1 truppa nemica a caso", secondo i bersagli ammessi (GDD §7.7.1).
static func _bersaglio_a_caso(bersaglio: TimerTarget.Kind) -> String:
	match bersaglio:
		TimerTarget.Kind.TRUPPE:
			return "1 truppa nemica a caso"
		TimerTarget.Kind.EDIFICI:
			return "1 edificio nemico a caso"
	return "1 tessera nemica a caso"


## Livello e tipi. La Capitale non ha livelli (nessun consigliere la potenzia): solo i tipi.
## livello_massimo 0: non si conosce (nessuna partita), si scrive solo il livello.
static func _riga_tipi(tipi: Array[StringName], p_livello: int, livello_massimo: int = 0, capitale: bool = false) -> String:
	var nomi: PackedStringArray = PackedStringArray()
	for tipo: StringName in tipi:
		nomi.append(String(tipo))
	var testo_tipi: String = "Tipi: %s" % (", ".join(nomi) if not nomi.is_empty() else "nessuno")
	if capitale:
		return testo_tipi
	var testo_livello: String = "Livello %d" % p_livello
	if livello_massimo > 0:
		testo_livello += " di %d" % livello_massimo
	return "%s · %s" % [testo_livello, testo_tipi]


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
			return "Sabota il fantasma" if opportunita.spy_effect == OpportunityDef.SpyEffect.SABOTAGGIO else "Inefficienza sul fantasma"
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
