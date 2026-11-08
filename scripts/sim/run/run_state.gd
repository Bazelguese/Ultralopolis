class_name RunState
extends RefCounted
## Stato e regole di una run (GDD §3, §4, §5, §6, §10).
##
## Logica pura: l'interfaccia legge questo stato e chiama i metodi pubblici,
## che controllano sempre se l'azione è permessa. Se un'azione non è permessa
## il metodo restituisce false e spiega il motivo in last_error.
##
## Sequenza dell'anno (GDD §3.2, §4.1):
##   INVERNO (3 round del Consiglio) -> PRIMAVERA (3 round) -> SCELTA_INCONTRO -> [RICOMPENSA_INCONTRO]
##   -> ESTATE (3 round) -> SCELTA_INCONTRO -> [RICOMPENSA_INCONTRO] -> AUTUNNO (3 round)
##   -> SCONTRO_FANTASMA -> anno successivo (v0.25). I round del Consiglio sono la fase CONSIGLIO.
## In ogni round compaiono 3 consiglieri; se ne ascolta uno e si prende una sua proposta
## (GDD §4.2). Il consigliere scelto offre anche Potenzia (GDD §6.5).
##
## Ricerca e tecnologie (GDD §10.5, v0.26): la Ricerca guadagnata va nella tecnologia in corso;
## se non ce n'è una resta in attesa nella casella RICERCA di stock, che quindi non è un Magazzino
## da spendere ma la Ricerca in attesa. Le ere si raggiungono con un numero di tecnologie.

enum Phase {
	CONSIGLIO,            ## I round del Consiglio di una stagione (GDD §3.2, v0.25).
	SCELTA_INCONTRO,
	RICOMPENSA_INCONTRO,
	SCONTRO_FANTASMA,
	FINE_RUN,
	CREAZIONE_NAZIONE,  ## Prima dell'anno 1: si sceglie l'identità (GDD §9).
	CRONACA,  ## All'inizio di una stagione la nazione vive una cronaca (GDD §9.6, v0.29).
}

enum RunEnd {
	NESSUNA,
	VITTORIA,     ## Raggiunte le vittorie necessarie.
	SCONFITTA,    ## Persa una battaglia durante l'ultima possibilità.
	FINE_PROVA,   ## Finiti gli anni della run di prova (convenzione §16.3).
}

## Tema del round: decide che cosa propongono i consiglieri (GDD §4.2).
enum RoundTheme {
	AZIONI,
	EDIFICI,
	TRUPPE,
	MISTO,
}

const THEME_NAMES: Dictionary[RoundTheme, String] = {
	RoundTheme.AZIONI: "Azioni",
	RoundTheme.EDIFICI: "Edifici",
	RoundTheme.TRUPPE: "Truppe",
	RoundTheme.MISTO: "Misto",
}

## Colori di mana di cui il Clown propone un elemento ciascuno, più un edificio neutro (GDD §4.2.2).
const CLOWN_COLORS: Array[StringName] = [&"rosso", &"verde", &"blu", &"viola"]

enum BattleKind {
	NESSUNA,
	INCONTRO,
	FANTASMA,
}

## Le quattro stagioni dell'anno, nell'ordine in cui arrivano (GDD §3.2, v0.25).
enum Season {
	INVERNO,    ## Nessuno scontro; gli edifici non producono Cibo.
	PRIMAVERA,  ## Finisce con un incontro del mondo.
	ESTATE,     ## Finisce con un incontro del mondo, più forte.
	AUTUNNO,    ## Finisce con lo scontro con il fantasma, che chiude l'anno.
}

const SEASON_NAMES: Dictionary[Season, String] = {
	Season.INVERNO: "Inverno",
	Season.PRIMAVERA: "Primavera",
	Season.ESTATE: "Estate",
	Season.AUTUNNO: "Autunno",
}

const MONTH_NAMES: PackedStringArray = ["Gennaio", "Febbraio", "Marzo", "Aprile", "Maggio", "Giugno",
		"Luglio", "Agosto", "Settembre", "Ottobre", "Novembre", "Dicembre"]

const PHASE_NAMES: Dictionary[Phase, String] = {
	Phase.CONSIGLIO: "Consiglio",
	Phase.SCELTA_INCONTRO: "Incontro del mondo",
	Phase.RICOMPENSA_INCONTRO: "Ricompensa",
	Phase.SCONTRO_FANTASMA: "Scontro con il fantasma",
	Phase.FINE_RUN: "Fine della partita",
	Phase.CREAZIONE_NAZIONE: "Creazione della nazione",
	Phase.CRONACA: "Cronaca",
}

## Momento di cronaca all'inizio di ogni stagione (GDD §9.6, v0.29).
const CHRONICLE_MOMENTS: Dictionary[Season, String] = {
	Season.INVERNO: "Solstizio d'inverno",
	Season.PRIMAVERA: "Equinozio di primavera",
	Season.ESTATE: "Solstizio d'estate",
	Season.AUTUNNO: "Equinozio d'autunno",
}

var catalog: CatalogDef
var run_rules: RunRules
var battle_rules: BattleRules
var resistance_rules: ResistanceRules

## Seme casuale della run, registrato per poterla riprodurre.
var run_seed: int = 0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

var year: int = 0
var phase: Phase = Phase.CONSIGLIO
## Stagione in corso (GDD §3.2, v0.25).
var season: Season = Season.INVERNO
var era: int = 1
var wins: int = 0
var prestige: int = 0
var last_chance: bool = false
var run_end: RunEnd = RunEnd.NESSUNA

## Magazzino (GDD §5.3): una casella per risorsa, in unità interne (il Cibo in decimi).
var stock: Array[int] = Res.empty()

var gold: int:
	get:
		return stock[Res.Type.ORO]
	set(value):
		stock[Res.Type.ORO] = value

var research: int:
	get:
		return stock[Res.Type.RICERCA]
	set(value):
		stock[Res.Type.RICERCA] = value

var board: NationBoard = NationBoard.new()
## Malus e bonus attivi (GDD §8).
var modifiers: Modifiers = Modifiers.new()

## Round in corso nella stagione (da 1 a rules.rounds_per_season).
var round_number: int = 0
## Tema del round in corso (GDD §4.2).
var round_theme: RoundTheme = RoundTheme.MISTO
## Temi dei round della stagione in corso, nell'ordine pescato a inizio stagione.
var _season_themes: Array[int] = []
## Incontri del mondo dell'anno, fissati a inizio anno: primavera ed estate (GDD §3.3, v0.25).
var _spring_encounters: Array[EncounterDef] = []
var _summer_encounters: Array[EncounterDef] = []
## I consiglieri del round in corso (GDD §4.2: 3, diversi fra loro).
var advisor_choices: Array[AdvisorDef] = []
## Il consigliere ascoltato in questo round; null finché non lo si sceglie.
var chosen_advisor: AdvisorDef
## Consigliere di corte (GDD §9.4, v0.24): il primo consigliere ordinario ascoltato nella run
## (convenzione provvisoria, §16.3). Conta solo se un elemento dell'identità lo favorisce.
var court_advisor: AdvisorDef
## Quanti dei consiglieri del round sono sempre presenti (la carta speciale non li sostituisce).
var _mandatory_count: int = 0
## Risorsa casuale chiesta da Ombra in questo round, pescata quando il consigliere compare (GDD §4.2.4).
var shadow_resource: Res.Type = Res.Type.FERRO
## true se Potenzia è già stato usato in questo round (GDD §6.5).
var upgrade_used: bool = false
## Potenzia dell'Anziano usati quest'anno (GDD §4.2.2).
var elder_upgrades_used: int = 0
## Proposte del consigliere scelto.
var offers: Array[Offer] = []
## Aumento accumulato del costo di rinnovo (GDD §4.2).
var reroll_extra: int = 0
## Evento o Fortuna fra le carte del round, al posto di un consigliere (GDD §4.2.5); null se non c'è.
var event_choice: EventDef
## Evento o Fortuna scelti in questo round.
var chosen_event: EventDef
## Eventi già comparsi nella run: un evento compare una sola volta, salvo i ripetibili.
var seen_events: Array[StringName] = []
## Visitatori e Fortune già comparsi quest'anno: non tornano nello stesso anno.
var seen_this_year: Array[StringName] = []
## Effetti dello spionaggio per il prossimo scontro con il fantasma (GDD §12):
## [effetto, indice dell'elemento del fantasma, millisecondi], come BattleSideSetup.start_timer_effects.
var spy_effects: Array[Array] = []

## Fantasma dell'anno, fissato all'inizio dell'anno (GDD §4.1, §11.2).
var current_ghost: GhostDef
## Incontri fra cui scegliere quest'anno.
var encounter_choices: Array[EncounterDef] = []
## Incontro vinto, di cui si sta scegliendo la ricompensa.
var won_encounter: EncounterDef

## Ultima battaglia combattuta (già conclusa) e suoi dati.
var last_battle: BattleSim
var last_battle_kind: BattleKind = BattleKind.NESSUNA
var last_opponent_name: String = ""
var _last_setups: Array[BattleSideSetup] = []
## Seme dell'ultimo scontro, ricavato dal seme della run, dall'anno e dal tipo di scontro (§16.3).
var last_battle_seed: int = 0

## Riepilogo di un anno della run (per la schermata finale).
class YearRecord:
	var year: int = 0
	var era: int = 1
	var encounter_name: String = ""
	var encounter_result: String = ""
	var ghost_name: String = ""
	var ghost_result: String = ""
	var prestige_after: int = 0
	var wins_after: int = 0


## Un riepilogo per ogni anno giocato, dal primo all'ultimo.
var history: Array[YearRecord] = []

## Cronaca della run per il giocatore, dal più vecchio al più recente.
var chronicle: Array[String] = []
## Motivo dell'ultima azione rifiutata.
var last_error: String = ""

## Nome scelto dal giocatore per la sua nazione.
var nation_name: String = "La tua nazione"
## Identità adottata: popolo, governo, credo, cultura, perk e vie (GDD §9, §10.4).
var identity: Array[IdentityDef] = []
## Vie proposte entrando nell'era: finché non se ne sceglie una, le altre azioni aspettano.
var way_choices: Array[IdentityDef] = []
## Malcontento della nazione (GDD §5.5, v0.24): una pressione fuori dal Magazzino e dalla battaglia.
var malcontent: int = 0
## Malcontento prodotto da ogni causa dall'ultima rivoluzione (IdentityDef.Grievance → quantità).
var malcontent_sources: Dictionary[int, int] = {}
## Governi a cui la nazione può evolvere entrando nella nuova era (GDD §9.4, v0.24): si sceglie
## uno o si rifiuta. Vuoto se non c'è nulla da decidere.
var government_choices: Array[IdentityDef] = []
## Opzioni costruite dalle regole per l'evento scelto (Riforma), seguite da quelle dei dati.
var _built_options: Array[EventOptionDef] = []

## Stato di una tecnologia, per l'interfaccia (GDD §10.5).
enum TechStatus {
	COMPLETATA,
	IN_CORSO,     ## Quella che riceve la Ricerca.
	INIZIATA,     ## Iniziata (o carta dorata) e lasciata a metà: i progressi restano.
	DISPONIBILE,  ## Si può ricercare, se compare nella mano.
	BLOCCATA,     ## Manca qualcosa: vedi tech_block_reason().
}

## Tecnologie completate, nell'ordine in cui sono state completate (GDD §10.5).
var techs_done: Array[TechDef] = []
## Tecnologia in studio: riceve la Ricerca guadagnata. null se nessuna.
var current_tech: TechDef
## Ricerca già raccolta sulle tecnologie iniziate e sulle carte dorate, per id.
## Una tecnologia è "iniziata" appena la si sceglie, anche con zero Ricerca.
var tech_progress: Dictionary[StringName, int] = {}
## Carte della mano pescata (GDD §10.5.3: 3).
var tech_hand: Array[TechDef] = []
## Carte dorate non ancora completate (GDD §10.5.6).
var golden_techs: Array[TechDef] = []
## Volte in cui ogni tecnologia è stata mostrata nella mano e non scelta (sconto sulla carta scartata).
var tech_discards: Dictionary[StringName, int] = {}
## Generatore dedicato alla mano, così le tecnologie non cambiano le altre pescate della run.
var _tech_rng: RandomNumberGenerator = RandomNumberGenerator.new()

## Passi delle vie completati (GDD §10.4.1, v0.27).
var traditions_done: Array[TraditionDef] = []
## Avanzamento delle imprese, per id del passo: quante volte è riuscito un traguardo, oppure
## la produzione più alta raccolta da quando la via è adottata.
var deed_counts: Dictionary[StringName, int] = {}
## Vie con l'albero completo, che hanno già dato la loro ascensione.
var completed_ways: Array[IdentityDef] = []
## Ascensioni da scegliere (GDD §10.4.2): finché non se ne sceglie una, le altre azioni aspettano.
var ascension_choices: Array[IdentityDef] = []
## Alberi completati di cui non si è ancora scelta l'ascensione.
var pending_ascensions: int = 0
## Doppio ascolto già usato in questa metà dell'anno.
var double_pick_used: bool = false
var _tradition_rng: RandomNumberGenerator = RandomNumberGenerator.new()

# Cronache della nazione (GDD §9.6, v0.29).
## Cronaca in corso (fase CRONACA).
var current_chronicle: ChronicleDef
## Opzioni costruite dalle regole per la cronaca in corso (la vocazione), prima di quelle dei dati.
var _chronicle_built: Array[EventOptionDef] = []
## Vocazione offerta dalla cronaca in corso.
var offered_vocation: IdentityDef
var seen_chronicles: Array[StringName] = []
## Anno in cui ogni cronaca è arrivata l'ultima volta (per non ripetere sempre le stesse).
var chronicle_last_year: Dictionary[StringName, int] = {}
## Inclinazioni: Spada, Porta, Altare, Legge (Inclination.Axis), da -limite a +limite.
var inclinations: PackedInt32Array = Inclination.empty()
## Ricordi della nazione, per le catene di cronache: nome → anno in cui è nato.
var flags: Dictionary[StringName, int] = {}
## Personaggi ricorrenti presenti nella storia.
var characters: Array[NationCharacter] = []
## Storia della nazione: le righe delle cronache, delle usanze e delle vocazioni.
var story: Array[String] = []
## Anno in cui la nazione ha preso ogni usanza o vocazione (id → anno).
var custom_years: Dictionary[StringName, int] = {}
## Vocazioni già offerte (accettate o rifiutate): non tornano.
var vocations_offered: Array[StringName] = []
## Scontri vinti (o pareggiati) di fila e risultato dell'ultimo (-1 nessuno, 0 perso, 1 vinto).
var win_streak: int = 0
var last_battle_result: int = -1
## Truppe assimilate (vocazione Assimilatori).
var assimilated: int = 0
## Profezia dell'anno (vocazione Teocrazia profetica): il nome di una truppa del fantasma.
var prophecy: String = ""
var _chronicle_rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _init(p_catalog: CatalogDef, p_run_rules: RunRules, p_battle_rules: BattleRules,
		p_resistance_rules: ResistanceRules, p_seed: int) -> void:
	catalog = p_catalog
	run_rules = p_run_rules
	battle_rules = p_battle_rules
	resistance_rules = p_resistance_rules
	run_seed = p_seed
	_rng.seed = p_seed
	_tech_rng.seed = p_seed * 1000003 + 7340033
	_tradition_rng.seed = p_seed * 1000003 + 5279
	_chronicle_rng.seed = p_seed * 1000003 + 92821

	prestige = run_rules.starting_prestige
	gold = run_rules.starting_gold
	research = run_rules.starting_research
	board.base_building_slots = run_rules.starting_building_slots
	board.base_troop_slots = run_rules.starting_troop_slots
	board.max_building_slots = run_rules.max_building_slots
	board.max_troop_slots = run_rules.max_troop_slots
	# La dotazione iniziale non è stata pagata: se venduta non rimborsa nulla.
	for def: BuildingDef in run_rules.starting_buildings:
		board.buildings.append(BoardPiece.of_building(def, 0))
	for def: TroopDef in run_rules.starting_troops:
		board.troops.append(BoardPiece.of_troop(def, 0))

	# Se il catalogo ha un'identità da scegliere, la run parte dalla creazione della nazione.
	if catalog.identities.is_empty():
		_log("Nasce una nuova nazione (seme %d)." % run_seed)
		_start_year(1)
	else:
		phase = Phase.CREAZIONE_NAZIONE


# --- Informazioni ------------------------------------------------------------

## Nome della fase; durante i round del Consiglio è il nome della stagione.
func phase_name() -> String:
	if phase == Phase.CONSIGLIO:
		return SEASON_NAMES[season]
	return PHASE_NAMES[phase]


## Temi dei round della stagione in corso, nell'ordine pescato a inizio stagione.
func season_round_themes() -> Array[int]:
	return _season_themes.duplicate()


func season_name(which: Season = season) -> String:
	return SEASON_NAMES[which]


## Mese del round in corso, da 1 (gennaio) a 12 (dicembre) (GDD §3.2, v0.25).
func month() -> int:
	return clampi(int(season) * run_rules.rounds_per_season + maxi(1, round_number), 1, MONTH_NAMES.size())


func month_name() -> String:
	return MONTH_NAMES[month() - 1]


func era_name(era_number: int = era) -> String:
	var index: int = era_number - 1
	if index >= 0 and index < catalog.eras.size():
		return catalog.eras[index].display_name
	return "Era %d" % era_number


## Tecnologie dell'era corrente necessarie per la prossima era (GDD §10.3), oppure -1 se non
## ci sono altre ere.
func next_era_techs_needed() -> int:
	if era >= catalog.eras.size():
		return -1
	return catalog.eras[era].techs_required


## Tecnologie completate di un'era (esclusive comprese).
func techs_done_in_era(era_number: int) -> int:
	var count: int = 0
	for def: TechDef in techs_done:
		if def.era == era_number:
			count += 1
	return count


## Perché non si può ancora entrare nella prossima era; vuoto se si può.
func era_block_reason() -> String:
	var needed: int = next_era_techs_needed()
	if needed < 0:
		return "Non ci sono altre ere."
	var done: int = techs_done_in_era(era)
	if done < needed:
		return "Servono %d tecnologie dell'era %s (ne hai %d)." % [needed, era_name(), done]
	return ""


## Livello del Consiglio: quello dell'era corrente (GDD §4.2.1). Un livello più alto
## aggiunge azioni (OpportunityDef.min_level).
func council_level() -> int:
	return clampi(era, 1, maxi(run_rules.council_level_names.size(), 1))


func council_level_name() -> String:
	var index: int = council_level() - 1
	if index < run_rules.council_level_names.size():
		return run_rules.council_level_names[index]
	return "Livello %d" % council_level()


func theme_name(theme: RoundTheme = round_theme) -> String:
	return THEME_NAMES[theme]


## Costo in Oro del rinnovo delle proposte (GDD §4.2).
func reroll_cost() -> int:
	return maxi(run_rules.reroll_min_cost, run_rules.reroll_base_cost + reroll_extra + modifiers.flat(ModifierDef.Effect.COSTO_RINNOVO))


## Rinnovo pagato con la risorsa del consigliere scelto, in alternativa all'Oro (GDD §4.2, v0.22):
## stessa quantità del rinnovo in Oro. Ombra usa la sua risorsa casuale del round.
## null se il consigliere non ha una risorsa (Clown e Anziano si rinnovano solo in Oro).
func reroll_resource_cost() -> ResourceAmounts:
	if chosen_advisor == null or chosen_advisor.special != AdvisorDef.Special.NESSUNO:
		return null
	var amounts: ResourceAmounts = ResourceAmounts.new()
	amounts.add(shadow_resource if chosen_advisor.random_resource else chosen_advisor.upgrade_resource, reroll_cost())
	return amounts


## Risorse che un consigliere chiede per Potenzia, es. "Ferro" oppure "Oro + Pietra" (per Ombra).
func advisor_resource_text(advisor: AdvisorDef) -> String:
	match advisor.special:
		AdvisorDef.Special.CLOWN:
			return "nessuna: il Giullare non potenzia"
		AdvisorDef.Special.ANZIANO:
			return "Oro"
		AdvisorDef.Special.VISITATORE:
			return "nessuna: i visitatori non potenziano"
	if advisor.random_resource:
		return "%s + %s" % [Res.NAMES[advisor.upgrade_resource], Res.NAMES[shadow_resource]]
	return Res.NAMES[advisor.upgrade_resource]


## Anteprima per la carta di un consigliere, prima di sceglierlo (solo lettura, non cambia nulla):
## le sue azioni che potrebbero comparire fra le proposte di questo round, una per azione,
## con il costo già scontato. Segue le stesse regole delle proposte vere (tema, livello, identità).
func advisor_action_preview(advisor: AdvisorDef) -> Array[Offer]:
	var preview: Array[Offer] = []
	if advisor.special == AdvisorDef.Special.CLOWN:
		return preview
	if advisor.special == AdvisorDef.Special.NESSUNO and round_theme != RoundTheme.AZIONI and round_theme != RoundTheme.MISTO:
		return preview
	for opportunity: OpportunityDef in advisor.actions:
		if _action_available(opportunity):
			preview.append(_action_offer(advisor, opportunity))
	return preview


## Anteprima (solo lettura): true se in questo round il consigliere può proporre edifici
## (con troops = false) o truppe (con troops = true).
func advisor_offers_elements(advisor: AdvisorDef, troops: bool) -> bool:
	if advisor.special == AdvisorDef.Special.CLOWN:
		return true
	for offer: Offer in _advisor_candidates(advisor):
		if offer.is_element() and (offer.troop != null) == troops:
			return true
	return false


## Resistenza con cui la nazione del giocatore inizia uno scontro (GDD §7.1.1).
func player_resistance() -> int:
	var base: int = ResistanceCalc.compute(resistance_rules, era, year, board.buildings.size(),
			board.troops.size(), _identity_resistance(identity))
	return maxi(1, base + modifiers.flat(ModifierDef.Effect.RESISTENZA))


## Resistenza del fantasma dell'anno, calcolata con la stessa formula.
func ghost_resistance() -> int:
	if current_ghost == null:
		return 0
	var identity_bonus: int = _identity_resistance(current_ghost.identity)
	var ghost_modifiers: Modifiers = _ghost_modifiers()
	var base: int = ResistanceCalc.compute(resistance_rules, current_ghost.era, year,
			current_ghost.buildings.size(), current_ghost.troops.size(), identity_bonus)
	return maxi(1, base + ghost_modifiers.flat(ModifierDef.Effect.RESISTENZA))


# --- Creazione della nazione (GDD §9) -------------------------------------------

## Elementi disponibili per una dimensione dell'identità (tutti, come in un GDR).
func identity_options(dimension: IdentityDef.Dimension) -> Array[IdentityDef]:
	return IdentityRules.options(catalog, dimension)


## Quanti perk si scelgono alla creazione (non più di quelli disponibili).
func starting_perk_count() -> int:
	return IdentityRules.starting_perk_count(catalog, run_rules)


## Crea la nazione: un elemento per ogni dimensione che ha opzioni, più i perk iniziali.
## Poi comincia l'anno 1.
func found_nation(p_name: String, choices: Array[IdentityDef]) -> bool:
	if phase != Phase.CREAZIONE_NAZIONE:
		return _fail("La nazione è già stata creata.")
	var problem: String = IdentityRules.validate(catalog, run_rules, choices)
	if problem != "":
		return _fail(problem)
	nation_name = p_name.strip_edges() if not p_name.strip_edges().is_empty() else "La tua nazione"
	_log("Nasce %s (seme %d)." % [nation_name, run_seed])
	for def: IdentityDef in choices:
		_adopt_identity(def)
	# Le inclinazioni partono dall'identità (GDD §9.6, v0.29).
	for def: IdentityDef in choices:
		for axis: int in range(mini(def.inclinations.size(), Inclination.Axis.size())):
			inclinations[axis] = clampi(inclinations[axis] + def.inclinations[axis], -run_rules.inclination_limit, run_rules.inclination_limit)
	_start_year(1)
	return true


## Testo breve dell'identità, es. "Montanari · Monarchia · ...".
func identity_summary() -> String:
	var names: PackedStringArray = PackedStringArray()
	for def: IdentityDef in identity:
		if def.dimension not in [IdentityDef.Dimension.PERK, IdentityDef.Dimension.ASCENSIONE, IdentityDef.Dimension.USANZA]:
			names.append(def.display_name)
	return " · ".join(names)


func perks() -> Array[IdentityDef]:
	var found: Array[IdentityDef] = []
	for def: IdentityDef in identity:
		if def.dimension == IdentityDef.Dimension.PERK:
			found.append(def)
	return found


## Oro e Ricerca che gli edifici depositeranno all'inizio della prossima macrofase.
func production_preview() -> Vector2i:
	var all: Array[int] = production_per_phase()
	return Vector2i(all[Res.Type.ORO], all[Res.Type.RICERCA])


## Tutte le risorse che gli edifici depositeranno all'inizio della prossima macrofase,
## in unità interne. Tiene conto di livelli e modificatori (es. Ricerca dimezzata).
func production_per_phase() -> Array[int]:
	var totals: Array[int] = Res.empty()
	for piece: BoardPiece in board.buildings:
		var produced: Array[int] = building_production(piece)
		for type: int in range(Res.COUNT):
			totals[type] += produced[type]
	for type: Res.Type in Res.NAMES:
		totals[type] = Modifiers.apply_percent(totals[type], _production_percent(type))
	return totals


## Quello che gli edifici depositeranno all'inizio della prossima stagione: se la prossima è
## l'inverno, senza Cibo (GDD §5.2, v0.25).
func next_season_production() -> Array[int]:
	var totals: Array[int] = production_per_phase()
	if season == Season.AUTUNNO:
		totals[Res.Type.CIBO] = 0
	var customs: Array[int] = _season_custom_resources()
	for type: Res.Type in Res.NAMES:
		totals[type] += customs[type]
	return totals


## Da dove arriva la produzione di una risorsa nella prossima stagione (principio P4): una riga per
## ogni edificio che la produce, con i bonus fissi e il loro nome, poi le percentuali e il totale.
func production_origin_lines(type: Res.Type) -> PackedStringArray:
	var lines: PackedStringArray = PackedStringArray()
	for piece: BoardPiece in board.buildings:
		var base: int = piece.building.production(type)
		if base > 0:
			base += run_rules.building_production_per_level * (piece.level - 1)
		var parts: PackedStringArray = PackedStringArray()
		for modifier: ActiveModifier in modifiers.active:
			var def: ModifierDef = modifier.def
			if def.effect != ModifierDef.Effect.PRODUZIONE_PER_EDIFICIO or def.resource != type:
				continue
			if modifier.target_piece != null and modifier.target_piece != piece:
				continue
			if not Modifiers._type_matches(def, piece):
				continue
			parts.append("%+d da %s" % [def.amount, modifier.origin_name])
		var total: int = maxi(0, base + modifiers.flat_production(type, piece))
		if total <= 0 and parts.is_empty():
			continue
		var line: String = "• %s +%s" % [piece.display_name(), Res.format(type, total * Res.scale(type))]
		if not parts.is_empty():
			var level_text: String = ", livello %d" % piece.level if piece.level > 1 and piece.building.production(type) > 0 else ""
			line += " (di base %d%s; %s)" % [maxi(0, base), level_text, ", ".join(parts)]
		elif piece.level > 1:
			line += " (livello %d)" % piece.level
		lines.append(line)
	for def: IdentityDef in identity:
		if def.season_resources != null and def.season_resources.internal(type) > 0:
			lines.append("• %s +%s (%s)" % [def.display_name, Res.format(type, def.season_resources.internal(type)), IdentityDef.DIMENSION_NAMES[def.dimension].to_lower()])
	var percent_effect: int = -1
	if type == Res.Type.ORO:
		percent_effect = ModifierDef.Effect.PRODUZIONE_ORO
	elif type == Res.Type.RICERCA:
		percent_effect = ModifierDef.Effect.PRODUZIONE_RICERCA
	for modifier: ActiveModifier in modifiers.active:
		var def: ModifierDef = modifier.def
		var applies: bool = (def.effect == ModifierDef.Effect.PRODUZIONE_PERCENTUALE and def.resource == type) \
				or (percent_effect >= 0 and def.effect == percent_effect and modifier.target_piece == null)
		if applies and def.amount != 0:
			lines.append("• %s %+d%% (%s)" % [def.display_name, def.amount, modifier.origin_name])
	if type == Res.Type.CIBO and season == Season.AUTUNNO:
		lines.append("• La prossima stagione è l'inverno: niente Cibo.")
	if lines.is_empty():
		lines.append("• Nessun edificio la produce.")
	return lines


# --- Mantenimento delle carte (GDD §5.6, v0.28) ----------------------------------------------

var _special_cards: Dictionary = {}
var _special_cards_ready: bool = false


## Carta speciale: esclusiva di un elemento dell'identità o di una via, oppure di una linea.
func is_special_card(def: Resource) -> bool:
	if not _special_cards_ready:
		_special_cards_ready = true
		var owners: Array[IdentityDef] = catalog.identities.duplicate()
		for era_def: EraDef in catalog.eras:
			owners.append_array(era_def.ways)
		for owner: IdentityDef in owners:
			for card: BuildingDef in owner.exclusive_buildings:
				_special_cards[card] = true
			for card: TroopDef in owner.exclusive_troops:
				_special_cards[card] = true
		for tech: TechDef in catalog.technologies:
			if tech.line != null:
				for card: BuildingDef in tech.line.buildings:
					_special_cards[card] = true
				for card: TroopDef in tech.line.troops:
					_special_cards[card] = true
	return _special_cards.has(def)


## Risorsa del mantenimento: quella della categoria del primo tipo della carta che sta in una
## categoria; per l'Ombra Oro (GDD §5.6).
func upkeep_resource(card_types: Array[StringName]) -> int:
	for card_type: StringName in card_types:
		for advisor: AdvisorDef in catalog.advisors:
			if advisor.special == AdvisorDef.Special.NESSUNO and advisor.types.has(card_type):
				return Res.Type.ORO if advisor.random_resource else advisor.upgrade_resource
	return -1


## Che cosa costa una carta prima di ogni scontro; null se non paga nulla.
func upkeep_of(piece: BoardPiece) -> ResourceAmounts:
	var def: Resource = piece.building if piece.building != null else piece.troop
	if piece.building != null and piece.building.is_capital:
		return null
	var quantity: int = run_rules.upkeep_per_level * maxi(0, piece.level - 1)
	if is_special_card(def):
		quantity += run_rules.special_upkeep
	if quantity <= 0:
		return null
	var resource: int = upkeep_resource(piece_types(piece))
	if resource < 0:
		return null
	var amounts: ResourceAmounts = ResourceAmounts.new()
	amounts.add(resource as Res.Type, quantity)
	return amounts


## Chi chiede una risorsa (principio P4): i consiglieri che la vogliono per il Potenzia o per
## le loro azioni (solo quelle che la nazione può vedere), i Visitatori e il Cibo delle truppe.
## Il mantenimento ha le sue righe (upkeep_lines).
func resource_demand_lines(type: Res.Type) -> PackedStringArray:
	var lines: PackedStringArray = PackedStringArray()
	var excluded: Array[AdvisorDef] = _excluded_advisors()
	for advisor: AdvisorDef in catalog.advisors:
		if excluded.has(advisor):
			continue
		var uses: PackedStringArray = PackedStringArray()
		if advisor.upgrade_resource == type and advisor.special == AdvisorDef.Special.NESSUNO:
			uses.append("Potenzia")
		elif advisor.random_resource and type != Res.Type.ORO and type != Res.Type.RICERCA:
			uses.append("Potenzia, quando esce questa risorsa")
		var actions: PackedStringArray = PackedStringArray()
		for action: OpportunityDef in advisor.actions:
			if action.cost_resources == null or action.cost_resources.whole(type) <= 0:
				continue
			if _is_exclusive_action(action) and not _has_exclusive_action(action):
				continue
			if action.min_level > council_level():
				continue
			var cost: ResourceAmounts = _discounted_action_cost(advisor, action)
			actions.append("%s %d" % [action.display_name, cost.whole(type) if cost != null else action.cost_resources.whole(type)])
		if not actions.is_empty():
			uses.append("azioni: %s" % ", ".join(actions))
		if not uses.is_empty():
			lines.append("• %s — %s" % [advisor.display_name, "; ".join(uses)])
	var visitors: PackedStringArray = PackedStringArray()
	for visitor: AdvisorDef in catalog.visitors:
		if visitor.extra_cost != null and visitor.extra_cost.whole(type) > 0 and _roots_ok(visitor.requires_any, 0, 0, []):
			visitors.append(visitor.display_name)
	if not visitors.is_empty():
		lines.append("• Visitatori — %s" % ", ".join(visitors))
	if type == Res.Type.CIBO and not board.troops.is_empty():
		var ration: int = 0
		for piece: BoardPiece in board.troops:
			ration += troop_ration(piece)
		lines.append("• Le truppe a inizio anno — %s" % Res.format(type, ration))
	return lines


## Carte nell'ordine in cui pagano: da destra, prima le truppe e poi gli edifici.
func _upkeep_order() -> Array[BoardPiece]:
	var order: Array[BoardPiece] = []
	for i: int in range(board.troops.size() - 1, -1, -1):
		order.append(board.troops[i])
	for i: int in range(board.buildings.size() - 1, -1, -1):
		order.append(board.buildings[i])
	return order


## Totale del mantenimento al prossimo scontro (per la barra delle risorse).
func upkeep_total() -> ResourceAmounts:
	var total: ResourceAmounts = ResourceAmounts.new()
	for piece: BoardPiece in _upkeep_order():
		var cost: ResourceAmounts = upkeep_of(piece)
		if cost != null:
			for type: Res.Type in Res.NAMES:
				total.add(type, cost.whole(type))
	return total


## Righe "Colossi di pietra: 1 Pietra" per il tooltip della risorsa indicata.
func upkeep_lines(type: Res.Type) -> PackedStringArray:
	var lines: PackedStringArray = PackedStringArray()
	for piece: BoardPiece in _upkeep_order():
		var cost: ResourceAmounts = upkeep_of(piece)
		if cost != null and cost.whole(type) > 0:
			lines.append("• %s −%d" % [piece.display_name(), cost.whole(type)])
	return lines


## Prima di ogni scontro: si paga da destra; chi non si può pagare è trascurato (×1,5) e porta
## +1 Malcontento (GDD §5.6).
func _pay_upkeep() -> void:
	var neglected_names: PackedStringArray = PackedStringArray()
	var paid: ResourceAmounts = ResourceAmounts.new()
	for piece: BoardPiece in _upkeep_order():
		piece.neglected = false
		var cost: ResourceAmounts = upkeep_of(piece)
		if cost == null:
			continue
		if can_pay(cost):
			for type: Res.Type in Res.NAMES:
				stock[type] -= cost.internal(type)
				paid.add(type, cost.whole(type))
		else:
			piece.neglected = true
			neglected_names.append(piece.display_name())
	if not paid.is_empty():
		_log("Mantenimento pagato: %s." % paid.describe())
	if not neglected_names.is_empty():
		_log("Mantenimento non pagato, tessere trascurate in questo scontro: %s." % ", ".join(neglected_names))
		_change_malcontent(neglected_names.size() * run_rules.malcontent_per_neglected, IdentityDef.Grievance.CARESTIE, "Mantenimento non pagato")


# --- Interazioni fra tipi (GDD §6.6): che cosa potenzia che cosa ---------------------------

const _EFFETTI_EDIFICI: Array[ModifierDef.Effect] = [ModifierDef.Effect.PRODUZIONE_PER_EDIFICIO,
		ModifierDef.Effect.INTERVALLO_MANA]
const _EFFETTI_TRUPPE: Array[ModifierDef.Effect] = [ModifierDef.Effect.RICARICA_TRUPPA,
		ModifierDef.Effect.DANNO_TRUPPA, ModifierDef.Effect.CIBO_TRUPPA]
const _EFFETTI_ENTRAMBI: Array[ModifierDef.Effect] = [ModifierDef.Effect.VALORE_PERCENTUALE,
		ModifierDef.Effect.VALORE_FISSO]


## true se il modificatore vale per le carte di un certo tipo (non per tutta la nazione).
static func is_type_bonus(def: ModifierDef) -> bool:
	return def.target == ModifierDef.Target.NAZIONE and (def.target_type != &"" or not def.target_types_any.is_empty())


## true se il modificatore legato a un tipo tocca una carta con questi tipi (edificio o truppa).
static func type_bonus_applies(def: ModifierDef, card_types: Array[StringName], is_building: bool) -> bool:
	if not is_type_bonus(def):
		return false
	var kind_ok: bool = _EFFETTI_ENTRAMBI.has(def.effect) or (is_building and _EFFETTI_EDIFICI.has(def.effect)) \
			or (not is_building and _EFFETTI_TRUPPE.has(def.effect))
	if not kind_ok:
		return false
	if def.target_type != &"" and not card_types.has(def.target_type):
		return false
	if not def.target_types_any.is_empty():
		for card_type: StringName in def.target_types_any:
			if card_types.has(card_type):
				return true
		return false
	return true


## Bonus già attivi che una carta riceverebbe per i suoi tipi, es. "Via del Commercio (+1 Oro...)".
func type_bonuses_for(card_types: Array[StringName], is_building: bool) -> PackedStringArray:
	var lines: PackedStringArray = PackedStringArray()
	for modifier: ActiveModifier in modifiers.active:
		if modifier.target_piece == null and type_bonus_applies(modifier.def, card_types, is_building):
			var text: String = "%s (%s)" % [modifier.origin_name, modifier.def.description if modifier.def.description != "" else modifier.def.display_name]
			if not lines.has(text):
				lines.append(text)
	return lines


## Carte della plancia che riceverebbero questi modificatori legati a un tipo (es. il tratto di
## una via, un perk, una tecnologia, l'opzione di un evento).
func pieces_boosted_by(defs: Array[ModifierDef]) -> Array[BoardPiece]:
	var found: Array[BoardPiece] = []
	for def: ModifierDef in defs:
		if def == null or not is_type_bonus(def):
			continue
		for piece: BoardPiece in board.buildings + board.troops:
			if not found.has(piece) and type_bonus_applies(def, piece_types(piece), piece.building != null):
				found.append(piece)
	return found


## Produzione per fase di un singolo edificio, in unità interne, con il suo livello
## e i modificatori che lo riguardano (GDD §6.5).
func building_production(piece: BoardPiece) -> Array[int]:
	var produced: Array[int] = Res.empty()
	for type: Res.Type in Res.NAMES:
		var amount: int = piece.building.production(type)
		if amount > 0:
			amount += run_rules.building_production_per_level * (piece.level - 1)
		amount += modifiers.flat_production(type, piece)
		produced[type] = maxi(0, amount) * Res.scale(type)
	return produced


func _production_percent(type: Res.Type) -> int:
	var total: int = modifiers.production_percent(type)
	if type == Res.Type.ORO:
		total += modifiers.percent(ModifierDef.Effect.PRODUZIONE_ORO)
	elif type == Res.Type.RICERCA:
		total += modifiers.percent(ModifierDef.Effect.PRODUZIONE_RICERCA)
	return total


## Quantità di una risorsa nel Magazzino, come la vede il giocatore (es. "3,5").
func stock_text(type: Res.Type) -> String:
	return Res.format(type, stock[type])


# --- Potenziamenti: l'opzione Potenzia del Consiglio (GDD §6.5, v0.22) -------------

## Tipi di un elemento della plancia (GDD §6.6).
static func piece_types(piece: BoardPiece) -> Array[StringName]:
	return piece.building.types if piece.building != null else piece.troop.types


## Edificio neutro: non produce mana (GDD §5.3). La Capitale produce energetico, quindi non lo è.
static func is_neutral_building(def: BuildingDef) -> bool:
	return def != null and def.mana_amount <= 0 and not def.is_capital


## Costo di Potenzia con il consigliere scelto: la quantità dipende dal livello e dall'era della
## carta, la risorsa dal consigliere (GDD §4.2.4). null se il consigliere non potenzia.
func upgrade_cost_of(piece: BoardPiece) -> ResourceAmounts:
	return upgrade_cost_for(chosen_advisor, piece)


## Costo di Potenzia di una carta con un consigliere qualsiasi, anche non ancora scelto (per
## mostrare in anticipo che cosa si potrebbe potenziare). null se quel consigliere non potenzia.
func upgrade_cost_for(advisor: AdvisorDef, piece: BoardPiece) -> ResourceAmounts:
	if advisor == null or advisor.special in [AdvisorDef.Special.CLOWN, AdvisorDef.Special.VISITATORE]:
		return null
	if piece.level >= max_level():
		return null
	var index: int = piece.level - 1
	if index < 0:
		return null
	var card_era: int = piece.building.era if piece.building != null else piece.troop.era
	# Oltre i livelli delle regole (Maestria, livello 4) il moltiplicatore è il livello da raggiungere (§16.3).
	var multiplier: int = run_rules.upgrade_cost_per_era[index] if index < run_rules.upgrade_cost_per_era.size() else index + 2
	var quantity: int = multiplier * maxi(1, card_era)
	quantity = maxi(1, quantity - _identity_int(&"upgrade_discount"))
	var amounts: ResourceAmounts = ResourceAmounts.new()
	if advisor.special == AdvisorDef.Special.ANZIANO:
		amounts.add(Res.Type.ORO, quantity)
	else:
		amounts.add(advisor.upgrade_resource, quantity)
		if advisor.random_resource:
			amounts.add(shadow_resource, quantity)
	return amounts


## Carte della plancia che questo consigliere potrebbe potenziare adesso, con le risorse che ci
## sono nel Magazzino (principio P4): servono al segnale su consiglieri e carte.
func affordable_upgrades(advisor: AdvisorDef) -> Array[BoardPiece]:
	var found: Array[BoardPiece] = []
	if advisor == null or not is_shopping_phase() or not way_choices.is_empty():
		return found
	if advisor == chosen_advisor and upgrade_used:
		return found
	for piece: BoardPiece in board.buildings + board.troops:
		if _advisor_upgrade_reason(advisor, piece) != "":
			continue
		var cost: ResourceAmounts = upgrade_cost_for(advisor, piece)
		if cost != null and can_pay(cost):
			found.append(piece)
	return found


## Perché l'elemento non si può potenziare adesso; stringa vuota se si può (principio P4).
## Non controlla le risorse: per quelle c'è can_pay().
func upgrade_block_reason(piece: BoardPiece) -> String:
	if not is_shopping_phase():
		return "Si potenzia solo durante i round del Consiglio."
	if not way_choices.is_empty():
		return "Prima scegli la via della nazione."
	if chosen_advisor == null:
		if chosen_event != null:
			return "In questo round hai scelto un evento: Potenzia è un'opzione dei consiglieri."
		return "Scegli prima un consigliere: Potenzia è una delle sue opzioni."
	var reason: String = _advisor_upgrade_reason(chosen_advisor, piece)
	if reason != "":
		return reason
	if upgrade_used:
		return "Potenzia è già stato usato in questo round."
	return ""


## La parte del motivo che dipende solo dal consigliere e dalla carta.
func _advisor_upgrade_reason(advisor: AdvisorDef, piece: BoardPiece) -> String:
	if piece.level >= max_level():
		return "Già al livello massimo."
	match advisor.special:
		AdvisorDef.Special.CLOWN:
			return "Il Giullare non potenzia."
		AdvisorDef.Special.VISITATORE:
			return "I visitatori non potenziano."
		AdvisorDef.Special.ANZIANO:
			if not is_neutral_building(piece.building):
				return "L'Anziano potenzia solo gli edifici neutri."
			if elder_upgrades_used >= run_rules.elder_upgrades_per_year:
				return "L'Anziano ha già potenziato quest'anno."
		_:
			if not advisor.covers(piece_types(piece)):
				return "%s potenzia solo tessere con tipo %s." % [advisor.display_name, ", ".join(advisor.types)]
	return ""


func can_pay(amounts: ResourceAmounts) -> bool:
	for type: Res.Type in Res.NAMES:
		if stock[type] < amounts.internal(type):
			return false
	return true


func upgrade_troop(index: int) -> bool:
	if index < 0 or index >= board.troops.size():
		return _fail("Truppa non valida.")
	return _upgrade(board.troops[index])


func upgrade_building(index: int) -> bool:
	if index < 0 or index >= board.buildings.size():
		return _fail("Edificio non valido.")
	return _upgrade(board.buildings[index])


## Potenzia: una volta per round, con il consigliere scelto, senza consumare la scelta (GDD §6.5).
func _upgrade(piece: BoardPiece) -> bool:
	if not _require_not_over():
		return false
	var reason: String = upgrade_block_reason(piece)
	if reason != "":
		return _fail(reason)
	var cost: ResourceAmounts = upgrade_cost_of(piece)
	if cost == null:
		return _fail("%s non si può potenziare." % piece.display_name())
	if not can_pay(cost):
		return _fail("Risorse insufficienti (servono %s)." % cost.describe())
	for type: Res.Type in Res.NAMES:
		stock[type] -= cost.internal(type)
	piece.level += 1
	upgrade_used = true
	if chosen_advisor.special == AdvisorDef.Special.ANZIANO:
		elder_upgrades_used += 1
	_log("%s: %s sale al livello %d (%s)." % [chosen_advisor.display_name, piece.display_name(), piece.level, cost.describe()])
	_check_traditions()
	return true


# --- Mercato delle risorse (GDD §5.3) -------------------------------------------

## Vende risorse in cambio di Oro, a tasso fisso. units: unità intere da vendere
## (multiplo del tasso). Si può fare in Produzione e Preparazione, senza consumare l'opportunità.
## Unità da vendere al mercato per 1 Oro: la cultura può migliorare il tasso (GDD §9.2, v0.24).
func market_rate() -> int:
	return maxi(1, run_rules.market_units_per_gold - _identity_int(&"market_rate_change"))


func sell_resource(type: Res.Type, units: int) -> bool:
	if not _require_shopping():
		return false
	if type == Res.Type.ORO:
		return _fail("L'Oro non si vende.")
	if type == Res.Type.RICERCA:
		return _fail("La Ricerca non si vende: va nelle tecnologie (GDD §10.5).")
	var rate: int = market_rate()
	if units <= 0 or units % rate != 0:
		return _fail("Si vende a gruppi di %d." % rate)
	var internal_amount: int = units * Res.scale(type)
	if stock[type] < internal_amount:
		return _fail("%s insufficiente." % Res.NAMES[type])
	stock[type] -= internal_amount
	@warning_ignore("integer_division")
	var earned: int = units / rate
	gold += earned
	_log("Mercato: venduti %d %s per %d Oro." % [units, Res.NAMES[type], earned])
	return true


# --- Cibo e mantenimento (GDD §5.4) ---------------------------------------------

## Consumo di Cibo a inizio anno: mangiano prima le truppe più lente (a parità, quelle
## più a destra). Chi non riceve tutta la sua razione resta affamato fino all'anno dopo.
func _feed_troops() -> void:
	var order: Array[int] = []
	for i: int in range(board.troops.size()):
		order.append(i)
	order.sort_custom(_slower_first)
	var hungry_names: PackedStringArray = PackedStringArray()
	var eaten: int = 0
	for i: int in order:
		var piece: BoardPiece = board.troops[i]
		var ration: int = troop_ration(piece)
		if stock[Res.Type.CIBO] >= ration:
			stock[Res.Type.CIBO] -= ration
			eaten += ration
			piece.hungry = false
		else:
			piece.hungry = true
			hungry_names.append(piece.display_name())
	_log("Le truppe consumano %s Cibo." % Res.format(Res.Type.CIBO, eaten))
	if not hungry_names.is_empty():
		_log("Senza cibo (ricarica più lenta per un anno): %s." % ", ".join(hungry_names))
		_change_malcontent(hungry_names.size() * run_rules.malcontent_per_hungry_troop, IdentityDef.Grievance.CARESTIE, "Carestia")


## Ordine del pasto: ricarica più lunga prima; a parità, la truppa più a destra.
func _slower_first(a: int, b: int) -> bool:
	var cooldown_a: int = _fed_cooldown(board.troops[a])
	var cooldown_b: int = _fed_cooldown(board.troops[b])
	if cooldown_a != cooldown_b:
		return cooldown_a > cooldown_b
	return a > b


## Ricarica di una truppa senza contare la fame.
func _fed_cooldown(piece: BoardPiece) -> int:
	var change: int = modifiers.percent(ModifierDef.Effect.RICARICA_TRUPPA, piece)
	return maxi(1, Modifiers.apply_percent(piece.troop.cooldown_ms, change))


func is_shopping_phase() -> bool:
	return phase == Phase.CONSIGLIO


func is_over() -> bool:
	return phase == Phase.FINE_RUN


## true se l'offerta, per essere presa, richiede di sostituire un elemento.
func offer_needs_replacement(offer: Offer) -> bool:
	match offer.kind:
		OpportunityDef.Kind.COSTRUISCI_EDIFICIO:
			return not board.can_add_building(offer.building)
		OpportunityDef.Kind.RECLUTA_TRUPPA:
			return not board.has_free_troop_slot()
	return false


## true se il Magazzino basta a pagare l'offerta (senza contare rimborsi di sostituzione).
func can_afford(offer: Offer) -> bool:
	if offer.other_cost != null and not can_pay(offer.other_cost):
		return false
	return gold >= offer.price and research >= offer.research_price


## Le scelte interne di un'offerta (es. quale bonus dell'Assemblea, quale truppa da addestrare,
## quale malus accorciare). Vuoto se non c'è nulla da scegliere.
func offer_choices(offer: Offer) -> Array[String]:
	var labels: Array[String] = []
	match offer.kind:
		OpportunityDef.Kind.MODIFICATORE_A_SCELTA:
			var choices: Array[Array] = _modifier_choices(offer)
			if choices.size() > 1:
				for choice: Array in choices:
					var def: ModifierDef = choice[0]
					var piece: BoardPiece = choice[1]
					labels.append(def.display_name if piece == null else "%s su %s" % [def.display_name, piece.display_name()])
		OpportunityDef.Kind.ACCORCIA_MALUS:
			var malus: Array[ActiveModifier] = modifiers.year_malus()
			if malus.size() > 1:
				for modifier: ActiveModifier in malus:
					labels.append(modifier.describe())
		OpportunityDef.Kind.INCANTO:
			# Ogni voce dice come cambia il mana della truppa (GDD §4.3): +2 dello stesso colore,
			# oppure 2 del colore dell'incanto se prima non ne chiedeva.
			var troops: Array[BoardPiece] = _enchantable_troops()
			if troops.size() > 1:
				var spell: OpportunityDef = offer.opportunity
				for piece: BoardPiece in troops:
					var now: TroopDef = effective_troop(piece)
					var before: String = "nessun mana" if now.mana_cost <= 0 else "%d %s" % [now.mana_cost, now.mana_type]
					var after: String = "%d %s" % [maxi(0, now.mana_cost) + spell.enchant_mana, now.mana_type if now.mana_cost > 0 else spell.enchant_color]
					labels.append("%s · mana: %s → %s" % [piece.display_name(), before, after])
	return labels


## Truppe che si possono ancora incantare: ognuna una sola volta (GDD §4.3).
## Quantità di un effetto dell'incanto per l'era della truppa, con l'eventuale percentuale in più.
static func _enchant_amount(amounts: PackedInt32Array, troop_era: int, bonus_percent: int) -> int:
	if amounts.is_empty():
		return 0
	var amount: int = amounts[clampi(troop_era, 1, amounts.size()) - 1]
	@warning_ignore("integer_division")
	return amount + amount * bonus_percent / 100


## Con l'ascensione Seconda natura ogni truppa si incanta due volte (GDD §10.4.2).
func _enchantable_troops() -> Array[BoardPiece]:
	var found: Array[BoardPiece] = []
	var twice: bool = has_rule(IdentityDef.Rule.SECONDA_NATURA)
	for piece: BoardPiece in board.troops:
		if piece.enchant == null or (twice and piece.second_enchant == null):
			found.append(piece)
	return found


func reward_needs_replacement(reward: RewardDef) -> bool:
	match reward.kind:
		RewardDef.Kind.EDIFICIO:
			return not board.can_add_building(reward.building)
		RewardDef.Kind.TRUPPA:
			return not board.has_free_troop_slot()
	return false


## Ricompense dell'incontro vinto. Una tecnologia già completata non compare.
func reward_choices() -> Array[RewardDef]:
	if phase != Phase.RICOMPENSA_INCONTRO or won_encounter == null:
		return []
	var found: Array[RewardDef] = []
	for reward: RewardDef in won_encounter.rewards:
		if reward.kind == RewardDef.Kind.TECNOLOGIA and reward.tech != null and techs_done.has(reward.tech):
			continue
		found.append(reward)
	# Vocazione Assimilatori (GDD §9.6, v0.29): in alternativa, una truppa del nemico vinto.
	if has_rule(IdentityDef.Rule.ASSIMILATORI):
		if _assimilation_cache_for != won_encounter:
			_assimilation_cache_for = won_encounter
			_assimilation_cache = []
			for enemy: TroopDef in won_encounter.troops:
				var reward: RewardDef = RewardDef.new()
				reward.kind = RewardDef.Kind.TRUPPA
				reward.troop = _assimilated_troop(enemy)
				reward.assimilation = true
				_assimilation_cache.append(reward)
		found.append_array(_assimilation_cache)
	return found


var _assimilation_cache_for: EncounterDef
var _assimilation_cache: Array[RewardDef] = []


## Una truppa nemica che diventa della nazione: stessi valori, con il tipo "Assimilato" e il tipo
## della razza (GDD §9.6, v0.29).
func _assimilated_troop(enemy: TroopDef) -> TroopDef:
	var troop: TroopDef = enemy.duplicate() as TroopDef
	troop.id = StringName("assimilati_%s" % enemy.id)
	troop.display_name = "%s assimilati" % enemy.display_name
	var new_types: Array[StringName] = enemy.types.duplicate()
	for extra: StringName in [&"Assimilato", race_type()]:
		if extra != &"" and not new_types.has(extra):
			new_types.append(extra)
	troop.types = new_types
	return troop


## Tipo d'identità della razza della nazione, es. "Pietrosangue"; vuoto se non c'è.
func race_type() -> StringName:
	for def: IdentityDef in identity:
		if def.dimension == IdentityDef.Dimension.POPOLO:
			return def.identity_type
	return &""


## Edificio come entrerà in battaglia: livello e modificatori (GDD §6.5, §8).
func effective_building(piece: BoardPiece) -> BuildingDef:
	var neglect: int = run_rules.neglect_slowdown_percent if piece.neglected else 0
	return ElementStats.building(piece.building, piece, modifiers, piece.level, run_rules, neglect)


## Truppa come entrerà in battaglia: livello, modificatori e fame (GDD §5.4, §6.5, §8).
func effective_troop(piece: BoardPiece) -> TroopDef:
	# Con l'ascensione Esercito frugale le truppe senza Cibo non rallentano (GDD §10.4.2).
	var hunger: int = run_rules.hunger_cooldown_percent if piece.hungry and not has_rule(IdentityDef.Rule.ESERCITO_FRUGALE) else 0
	var neglect: int = run_rules.neglect_slowdown_percent if piece.neglected else 0
	return ElementStats.troop(piece.troop, piece, modifiers, piece.level, run_rules, hunger + neglect)


## Cibo consumato da una truppa a inizio anno, in decimi (GDD §5.4).
func troop_ration(piece: BoardPiece) -> int:
	return Modifiers.apply_percent(piece.troop.food_tenths, modifiers.percent(ModifierDef.Effect.CIBO_TRUPPA, piece))


## Le due nazioni dell'ultima battaglia: [giocatore, avversario].
func last_battle_setups() -> Array[BattleSideSetup]:
	return _last_setups


## Crea una copia nuova dell'ultima battaglia, da far scorrere passo per passo
## nell'interfaccia. Il risultato è identico a quello già registrato.
func make_battle_replay() -> BattleSim:
	if _last_setups.size() != 2:
		return null
	return BattleSim.new(battle_rules, _last_setups[0], _last_setups[1], last_battle_seed)


# --- Il Consiglio (GDD §4.2) ---------------------------------------------------

## Ascolta uno dei consiglieri del round: la scelta è definitiva per il round.
func choose_advisor(index: int) -> bool:
	if not _require_shopping():
		return false
	if chosen_advisor != null or chosen_event != null:
		return _fail("Hai già fatto la scelta di questo round.")
	if index < 0 or index >= advisor_choices.size():
		return _fail("Consigliere non valido.")
	chosen_advisor = advisor_choices[index]
	_log("Round %d (%s): ascolti %s." % [round_number, theme_name(), chosen_advisor.display_name])
	if court_advisor == null and chosen_advisor.special == AdvisorDef.Special.NESSUNO:
		court_advisor = chosen_advisor
		if _has_court():
			_log("%s diventa il consigliere di corte." % court_advisor.display_name)
	_draw_offers()
	return true


## Prende una proposta del consigliere scelto pagandone il prezzo e chiude il round.
## choice dipende dalla proposta:
##   - edificio o truppa con la plancia piena: l'elemento da sostituire (venduto con rimborso dimezzato);
##   - modificatore a scelta, malus da accorciare, truppa da incantare: la voce scelta fra offer_choices().
func buy_offer(offer_index: int, choice: int = -1) -> bool:
	if not _require_shopping():
		return false
	if chosen_advisor == null:
		return _fail("Scegli prima un consigliere.")
	if offer_index < 0 or offer_index >= offers.size():
		return _fail("Opportunità non valida.")
	var offer: Offer = offers[offer_index]
	var source: String = offer.opportunity.display_name if offer.opportunity != null else chosen_advisor.display_name
	# Un visitatore può chiedere, oltre all'Oro, un'altra risorsa per le sue carte (GDD §4.2.5).
	var element_extra: ResourceAmounts = offer.other_cost if offer.is_element() else null
	if element_extra != null and not can_pay(element_extra):
		return _fail("Risorse insufficienti (servono %s)." % offer.cost_text())

	match offer.kind:
		OpportunityDef.Kind.COSTRUISCI_EDIFICIO:
			if not _place_building(offer.building, offer.price, offer.price, choice):
				return false
		OpportunityDef.Kind.RECLUTA_TRUPPA:
			if not _place_troop(offer.troop, offer.price, offer.price, choice):
				return false
		OpportunityDef.Kind.SPAZIO_EDIFICIO:
			if board.building_capacity() >= board.max_building_slots:
				return _fail("La plancia ha già il massimo di spazi edificio.")
			if not _pay(offer):
				return false
			board.base_building_slots += 1
			_log("%s: nuovo spazio edificio (%s)." % [source, offer.cost_text()])
		OpportunityDef.Kind.SPAZIO_TRUPPA:
			if board.troop_capacity() >= board.max_troop_slots:
				return _fail("La plancia ha già il massimo di spazi truppa.")
			if not _pay(offer):
				return false
			board.base_troop_slots += 1
			_log("%s: nuovo spazio truppa (%s)." % [source, offer.cost_text()])
		OpportunityDef.Kind.SCAMBIO_RISORSE:
			if not _pay(offer):
				return false
			var opportunity: OpportunityDef = offer.opportunity
			gold += opportunity.gain_gold
			research += opportunity.gain_research
			if opportunity.gain_resources != null:
				for type: Res.Type in Res.NAMES:
					stock[type] += opportunity.gain_resources.internal(type)
			_log("%s: paghi %s, ricevi %s." % [source, offer.cost_text(), _gain_text(opportunity)])
		OpportunityDef.Kind.MODIFICATORE_A_SCELTA:
			var choices: Array[Array] = _modifier_choices(offer)
			if choices.is_empty():
				return _fail("Non c'è nulla su cui applicarlo.")
			if choices.size() == 1:
				choice = 0
			if choice < 0 or choice >= choices.size():
				return _fail("Scegli quale effetto prendere.")
			if not _pay(offer):
				return false
			var def: ModifierDef = choices[choice][0]
			var piece: BoardPiece = choices[choice][1]
			_log(modifiers.apply(def, ActiveModifier.OriginKind.OPPORTUNITA, source, year, board, _rng, piece))
		OpportunityDef.Kind.ACCORCIA_MALUS:
			var malus: Array[ActiveModifier] = modifiers.year_malus()
			if malus.is_empty():
				return _fail("Non ci sono malus da accorciare.")
			if malus.size() == 1:
				choice = 0
			if choice < 0 or choice >= malus.size():
				return _fail("Scegli quale malus accorciare.")
			if not _pay(offer):
				return false
			_log("%s: %s" % [source, modifiers.shorten(malus[choice], offer.opportunity.shorten_years, year)])
		OpportunityDef.Kind.SPIONAGGIO:
			if _spy_candidates(offer.opportunity).is_empty():
				return _fail("Il fantasma non ha un bersaglio adatto.")
			if not _pay(offer):
				return false
			var target: int = _spy_pick(offer.opportunity)
			var spy: OpportunityDef = offer.opportunity
			var effect: int = BattleSim.EFFECT_SABOTAGE if spy.spy_effect == OpportunityDef.SpyEffect.SABOTAGGIO else BattleSim.EFFECT_SLOW
			spy_effects.append([effect, target, spy_duration(spy)])
			_log("%s: %s parte %s per %d s nello scontro con il fantasma." % [source, _ghost_element_name(target),
					"sabotato" if effect == BattleSim.EFFECT_SABOTAGE else "inefficiente", _whole_seconds(spy_duration(spy))])
		OpportunityDef.Kind.INCANTO:
			var troops: Array[BoardPiece] = _enchantable_troops()
			if troops.is_empty():
				return _fail("Nessuna truppa da incantare.")
			if troops.size() == 1:
				choice = 0
			if choice < 0 or choice >= troops.size():
				return _fail("Scegli quale truppa incantare.")
			if not _pay(offer):
				return false
			var enchanted: BoardPiece = troops[choice]
			var spell: OpportunityDef = offer.opportunity
			var bonus: int = spell.enchant_no_mana_bonus_percent if enchanted.troop.mana_cost <= 0 else 0
			if enchanted.enchant == null:
				enchanted.enchant = spell
				enchanted.enchant_amount = _enchant_amount(spell.enchant_amounts, enchanted.troop.era, bonus)
				enchanted.enchant_amount_2 = _enchant_amount(spell.enchant_amounts_2, enchanted.troop.era, bonus)
			else:
				# Secondo incanto (Seconda natura).
				enchanted.second_enchant = spell
				enchanted.second_enchant_amount = _enchant_amount(spell.enchant_amounts, enchanted.troop.era, 0)
				enchanted.second_enchant_amount_2 = _enchant_amount(spell.enchant_amounts_2, enchanted.troop.era, 0)
			_log("%s: %s è incantata (%s)." % [source, enchanted.display_name(), spell.description])
		OpportunityDef.Kind.PERK:
			if identity.has(offer.perk):
				return _fail("Hai già questa peculiarità.")
			if not _pay(offer):
				return false
			_adopt_identity(offer.perk)
		OpportunityDef.Kind.RIPESCA_TECNOLOGIE:
			if _tech_pool().is_empty():
				return _fail("Non ci sono altre tecnologie da pescare.")
			if not _pay(offer):
				return false
			_log("%s: la mano delle tecnologie si ripesca (%s)." % [source, offer.cost_text()])
			_draw_tech_hand()
	if element_extra != null:
		for type: Res.Type in Res.NAMES:
			stock[type] -= element_extra.internal(type)
	if offer.opportunity != null and offer.opportunity.malcontent_change != 0:
		_change_malcontent(offer.opportunity.malcontent_change, IdentityDef.Grievance.EVENTI, source)
	_flow_research()
	if chosen_advisor != null:
		_note_deed(DeedDef.Kind.PROPOSTE, chosen_advisor.id)
	_check_traditions()
	# Doppio ascolto (GDD §10.4.2): una volta per stagione il round resta aperto per una seconda
	# proposta dello stesso consigliere ordinario; la proposta presa sparisce (§16.3).
	if has_rule(IdentityDef.Rule.DOPPIO_ASCOLTO) and not double_pick_used and chosen_advisor != null \
			and chosen_advisor.special == AdvisorDef.Special.NESSUNO and offers.size() > 1 and offer_index < offers.size():
		double_pick_used = true
		offers.remove_at(offer_index)
		_log("Doppio ascolto: puoi prendere un'altra opportunità da %s." % chosen_advisor.display_name)
		return true
	_next_round()
	return true


## Rinuncia al round, con o senza aver scelto un consigliere (GDD §4.2): non si riceve nulla.
func pass_round() -> bool:
	if not _require_shopping():
		return false
	if is_revolution_round():
		return _fail("La Rivoluzione non si può evitare: scegli il nuovo governo.")
	_log("Round %d lasciato passare." % round_number)
	_next_round()
	return true


# --- Eventi e Fortune (GDD §4.2.5, v0.23) ------------------------------------------

## Sceglie l'Evento o la Fortuna del round: come un consigliere, la scelta è definitiva.
func choose_event() -> bool:
	if not _require_shopping():
		return false
	if chosen_advisor != null or chosen_event != null:
		return _fail("Hai già fatto la scelta di questo round.")
	if event_choice == null:
		return _fail("In questo round non c'è nessun evento.")
	chosen_event = event_choice
	_built_options = _special_options(chosen_event)
	_log("Round %d: %s." % [round_number, chosen_event.display_name])
	return true


## Opzioni dell'evento scelto (una sola per le Fortune). Per la Riforma le prime sono costruite
## dalle regole, una per ogni governo raggiungibile.
func event_options() -> Array[EventOptionDef]:
	if chosen_event == null:
		return []
	if _built_options.is_empty():
		return chosen_event.options
	var all: Array[EventOptionDef] = _built_options.duplicate()
	all.append_array(chosen_event.options)
	return all


## Opzioni della Riforma (GDD §9.4, v0.24): una per ramo, pagata in Influenza secondo il tier.
func _special_options(event: EventDef) -> Array[EventOptionDef]:
	var built: Array[EventOptionDef] = []
	if event.special == EventDef.Special.RIVOLUZIONE:
		for target: IdentityDef in revolution_targets():
			var choice: EventOptionDef = EventOptionDef.new()
			choice.label = "Verso: %s" % target.display_name
			choice.description = "Il popolo porta al governo %s (rango %d). %s" % [target.display_name, target.tier, target.description]
			choice.change_government = target
			built.append(choice)
		return built
	if event.special != EventDef.Special.RIFORMA:
		return built
	for target: IdentityDef in evolution_targets():
		var option: EventOptionDef = EventOptionDef.new()
		option.label = "Verso: %s" % target.display_name
		option.description = "Il governo diventa %s (rango %d). %s" % [target.display_name, target.tier, target.description]
		option.cost = ResourceAmounts.new()
		option.cost.add(Res.Type.INFLUENZA, run_rules.reform_influence_per_tier * target.tier)
		option.requires_types = target.reform_requires_types
		option.change_government = target
		built.append(option)
	return built


## Requisito di un'opzione, es. "Spirituale" o "Repubblica"; vuoto se non ne ha.
func option_requirement(option: EventOptionDef) -> String:
	if option.requirement_label != "":
		return option.requirement_label
	var parts: PackedStringArray = PackedStringArray()
	for element: Resource in option.requires_identity:
		parts.append((element as IdentityDef).display_name)
	for card_type: StringName in option.requires_types:
		parts.append(String(card_type))
	return " o ".join(parts)


## Perché l'opzione non si può scegliere adesso; stringa vuota se si può (principio P4).
func option_block_reason(option: EventOptionDef) -> String:
	if not option.requires_identity.is_empty():
		var found: bool = false
		for element: Resource in option.requires_identity:
			if identity.has(element):
				found = true
		if not found:
			return "Richiede: %s." % option_requirement(option)
	if not option.requires_types.is_empty() and _pieces_with(option.requires_types, option.requires_kind).is_empty():
		return "Serve una tessera %s sulla plancia." % option_requirement(option)
	if option.cost != null and not can_pay(option.cost):
		return "Risorse insufficienti (servono %s)." % option.cost.describe()
	if option.upgrade and _option_upgrade_candidates(option).is_empty():
		return "Nessuna tessera da potenziare."
	if _option_troop_modifier(option) and board.troops.is_empty():
		return "Nessuna truppa a cui applicarlo."
	if option.spy != null and _spy_candidates(option.spy).is_empty():
		return "Il fantasma non ha un bersaglio adatto."
	return ""


## Voci fra cui scegliere per un'opzione (la carta da potenziare o la truppa del modificatore).
func option_choices(option: EventOptionDef) -> Array[String]:
	var labels: Array[String] = []
	var pieces: Array[BoardPiece] = _option_choice_pieces(option)
	if pieces.size() > 1:
		for piece: BoardPiece in pieces:
			labels.append(piece.display_name())
	return labels


## Prende un'opzione dell'evento scelto, ne paga il costo, applica gli effetti e chiude il round.
func take_event_option(index: int, choice: int = -1) -> bool:
	if not _require_shopping():
		return false
	if chosen_event == null:
		return _fail("Scegli prima l'evento.")
	var options: Array[EventOptionDef] = event_options()
	if index < 0 or index >= options.size():
		return _fail("Opzione non valida.")
	var option: EventOptionDef = options[index]
	var reason: String = option_block_reason(option)
	if reason != "":
		return _fail(reason)
	var pieces: Array[BoardPiece] = _option_choice_pieces(option)
	if pieces.size() == 1:
		choice = 0
	if not pieces.is_empty() and (choice < 0 or choice >= pieces.size()):
		return _fail("Scegli su quale tessera applicarla.")
	var chosen_piece: BoardPiece = pieces[choice] if not pieces.is_empty() else null
	var source: String = chosen_event.display_name
	_apply_option_effects(option, source, chosen_piece, era if chosen_event.scale_with_era else 1)
	if chosen_event.special == EventDef.Special.RIVOLUZIONE:
		malcontent = 0
		malcontent_sources = {}
		_log("Dopo la Rivoluzione il Malcontento si azzera.")
	_log("%s: %s." % [source, option.label])
	_flow_research()
	if chosen_event.family == EventDef.Family.EVENTO:
		_note_deed(DeedDef.Kind.EVENTI, StringName(chosen_event.sphere))
	_check_traditions()
	_next_round()
	return true


## Costi ed effetti di un'opzione di evento o di cronaca, nel linguaggio del nucleo (P5).
## scale moltiplica le risorse ricevute (le Fortune crescono con l'era).
func _apply_option_effects(option: EventOptionDef, source: String, chosen_piece: BoardPiece, scale: int) -> void:
	if option.cost != null:
		for type: Res.Type in Res.NAMES:
			stock[type] -= option.cost.internal(type)
	if option.gain != null:
		for type: Res.Type in Res.NAMES:
			stock[type] += option.gain.internal(type) * scale
	for def: ModifierDef in option.modifiers:
		var target: BoardPiece = chosen_piece if def.target in [ModifierDef.Target.TRUPPA_SCELTA, ModifierDef.Target.EDIFICIO_SCELTO] else null
		_log(modifiers.apply(def, ActiveModifier.OriginKind.EVENTO, source, year, board, _rng, target))
	if option.give_building != null:
		_gift_building(option.give_building)
	if option.give_troop != null:
		_gift_troop(option.give_troop)
	if option.give_random:
		_gift_random(option)
	if option.upgrade and chosen_piece != null:
		chosen_piece.level += 1
		_log("%s: %s sale al livello %d." % [source, chosen_piece.display_name(), chosen_piece.level])
	if option.extra_building_slots > 0:
		board.base_building_slots += mini(option.extra_building_slots, maxi(0, board.max_building_slots - board.building_capacity()))
	if option.extra_troop_slots > 0:
		board.base_troop_slots += mini(option.extra_troop_slots, maxi(0, board.max_troop_slots - board.troop_capacity()))
	if option.spy != null:
		var effect: int = BattleSim.EFFECT_SABOTAGE if option.spy.spy_effect == OpportunityDef.SpyEffect.SABOTAGGIO else BattleSim.EFFECT_SLOW
		var spy_target: int = _spy_pick(option.spy)
		spy_effects.append([effect, spy_target, spy_duration(option.spy)])
		_log("%s: %s partirà %s nello scontro con il fantasma." % [source, _ghost_element_name(spy_target), "sabotato" if effect == BattleSim.EFFECT_SABOTAGE else "inefficiente"])
	if option.give_tech != null:
		_give_golden(option.give_tech)
	elif option.give_random_tech:
		_give_golden(_random_golden(option.give_tech_sphere))
	if option.change_government != null:
		_change_government(option.change_government as IdentityDef, source)
	if option.malcontent_change != 0:
		_change_malcontent(option.malcontent_change, IdentityDef.Grievance.EVENTI, source)


## Elementi della plancia con almeno uno di questi tipi, del genere indicato.
func _pieces_with(card_types: Array[StringName], kind: EventOptionDef.PieceKind) -> Array[BoardPiece]:
	var found: Array[BoardPiece] = []
	var pool: Array[BoardPiece] = []
	if kind != EventOptionDef.PieceKind.TRUPPA:
		pool.append_array(board.buildings)
	if kind != EventOptionDef.PieceKind.EDIFICIO:
		pool.append_array(board.troops)
	for piece: BoardPiece in pool:
		if card_types.is_empty():
			found.append(piece)
			continue
		for card_type: StringName in piece_types(piece):
			if card_types.has(card_type):
				found.append(piece)
				break
	return found


func _option_upgrade_candidates(option: EventOptionDef) -> Array[BoardPiece]:
	var found: Array[BoardPiece] = []
	for piece: BoardPiece in _pieces_with(option.upgrade_types, option.upgrade_kind):
		if piece.level < max_level():
			found.append(piece)
	return found


func _option_troop_modifier(option: EventOptionDef) -> bool:
	for def: ModifierDef in option.modifiers:
		if def.target == ModifierDef.Target.TRUPPA_SCELTA:
			return true
	return false


## Carte fra cui il giocatore sceglie per l'opzione: da potenziare, oppure la truppa del modificatore.
func _option_choice_pieces(option: EventOptionDef) -> Array[BoardPiece]:
	if option.upgrade:
		return _option_upgrade_candidates(option)
	if _option_troop_modifier(option):
		return board.troops.duplicate()
	return []


## Edificio regalato da un evento: entra solo se c'è spazio e vale il suo prezzo di catalogo (§6.4).
func _gift_building(def: BuildingDef) -> void:
	if board.can_add_building(def):
		board.buildings.append(BoardPiece.of_building(def, def.cost_gold))
		_log("Ricevuto: %s." % def.display_name)
	else:
		_log("Nessuno spazio per %s." % def.display_name)


func _gift_troop(def: TroopDef) -> void:
	if board.has_free_troop_slot():
		board.troops.append(BoardPiece.of_troop(def, def.cost_gold))
		_log("Ricevuto: %s." % def.display_name)
	else:
		_log("Nessuno spazio per %s." % def.display_name)


## Una carta a caso dell'era corrente con uno dei tipi dell'opzione.
func _gift_random(option: EventOptionDef) -> void:
	if option.give_random_kind == EventOptionDef.PieceKind.TRUPPA:
		var troops: Array[TroopDef] = []
		for def: TroopDef in _troops_of_era():
			if option.give_random_types.is_empty() or _has_any_type(def.types, option.give_random_types):
				troops.append(def)
		if not troops.is_empty():
			_gift_troop(troops[_rng.randi_range(0, troops.size() - 1)])
	else:
		var buildings: Array[BuildingDef] = []
		for def: BuildingDef in _buildings_of_era():
			if option.give_random_types.is_empty() or _has_any_type(def.types, option.give_random_types):
				buildings.append(def)
		if not buildings.is_empty():
			_gift_building(buildings[_rng.randi_range(0, buildings.size() - 1)])


static func _has_any_type(card_types: Array[StringName], wanted: Array[StringName]) -> bool:
	for card_type: StringName in card_types:
		if wanted.has(card_type):
			return true
	return false


## Ripesca le proposte del consigliere scelto. Si paga in Oro oppure, con with_resource,
## con la risorsa del consigliere (GDD §4.2, v0.22). Il costo cresce a ogni rinnovo.
func reroll_offers(with_resource: bool = false) -> bool:
	if not _require_shopping():
		return false
	if chosen_advisor == null:
		return _fail("Scegli prima un consigliere.")
	var cost: int = reroll_cost()
	if with_resource:
		var amounts: ResourceAmounts = reroll_resource_cost()
		if amounts == null:
			return _fail("%s si rinnova solo in Oro." % chosen_advisor.display_name)
		if not can_pay(amounts):
			return _fail("Risorse insufficienti per rinnovare (servono %s)." % amounts.describe())
		for type: Res.Type in Res.NAMES:
			stock[type] -= amounts.internal(type)
		_log("Opportunità rinnovate per %s." % amounts.describe())
	else:
		if gold < cost:
			return _fail("Oro insufficiente per rinnovare (servono %d)." % cost)
		gold -= cost
		_log("Opportunità rinnovate per %d Oro." % cost)
	reroll_extra += run_rules.reroll_cost_increase
	_draw_offers()
	return true


## Entra nella prossima era, se le tecnologie richieste sono completate (GDD §10.3, v0.26).
## Non è automatico, non costa Ricerca e non consuma il round.
func advance_era() -> bool:
	if not _require_shopping():
		return false
	var reason: String = era_block_reason()
	if reason != "":
		return _fail(reason)
	var needed: int = next_era_techs_needed()
	var next: EraDef = catalog.eras[era]
	era += 1
	board.base_building_slots += next.bonus_building_slots
	board.base_troop_slots += next.bonus_troop_slots
	_log("La nazione entra nell'era %s (%d tecnologie dell'era %s)." % [next.display_name, needed, era_name(era - 1)])
	# Dalla seconda era si sceglie una via fra 3 (GDD §10.4).
	way_choices = _draw_ways(next)
	if not way_choices.is_empty():
		_log("Scegli la via della nazione per l'era %s." % next.display_name)
	else:
		# Si aprono le tecnologie della nuova era: la mano si ripesca gratis (GDD §10.5.3).
		# Con una via da scegliere si ripesca dopo, perché la via può aprire tecnologie esclusive.
		_draw_tech_hand()
	# Entrando in un'era il governo può evolvere: dopo la via, e si può rifiutare (§16.3).
	government_choices = evolution_targets()
	if not government_choices.is_empty():
		_log("Il governo può evolvere: scegli la nuova forma o resta com'è.")
	# Le offerte delle ere precedenti non restano disponibili (GDD §10.3):
	# le proposte in corso vengono ripescate gratis dalla nuova era (§16.3).
	_redraw_round()
	return true


## Dopo un cambio d'era o di via: si ripescano le proposte del consigliere scelto, oppure,
## se non lo si è ancora scelto, i consiglieri del round (i loro pool sono cambiati).
func _redraw_round() -> void:
	if chosen_event != null:
		return
	if chosen_advisor != null:
		_draw_offers()
	else:
		_draw_advisors()


# --- Ricerca e tecnologie (GDD §10.5, v0.26) ----------------------------------------

## Ricerca in attesa: guadagnata senza una tecnologia in corso, passa alla prima scelta.
func research_waiting() -> int:
	return research


## Ricerca già raccolta su una tecnologia (il costo intero se è completata).
func tech_progress_of(def: TechDef) -> int:
	if techs_done.has(def):
		return def.cost
	return tech_progress.get(def.id, 0)


## Carte fra cui scegliere: le 3 della mano, più le tecnologie iniziate e le carte dorate,
## che compaiono sempre finché non sono completate (GDD §10.5.3).
func tech_hand_cards() -> Array[TechDef]:
	var cards: Array[TechDef] = tech_hand.duplicate()
	for def: TechDef in _started_techs():
		if not cards.has(def):
			cards.append(def)
	return cards


## true se la tecnologia è una carta dorata ancora da completare.
func is_golden(def: TechDef) -> bool:
	return golden_techs.has(def)


## Tecnologie dell'albero che la nazione vede: tutte quelle comuni, più le esclusive della sua
## identità e delle sue vie (GDD §10.5.2).
func tree_technologies() -> Array[TechDef]:
	var found: Array[TechDef] = []
	for def: TechDef in catalog.technologies:
		if def.is_exclusive() and not _has_any_identity(def.requires_any):
			continue
		found.append(def)
	return found


func tech_status(def: TechDef) -> TechStatus:
	if techs_done.has(def):
		return TechStatus.COMPLETATA
	if def == current_tech:
		return TechStatus.IN_CORSO
	if tech_progress.has(def.id):
		return TechStatus.INIZIATA
	if tech_block_reason(def) == "":
		return TechStatus.DISPONIBILE
	return TechStatus.BLOCCATA


## Perché la tecnologia non si può ricercare; vuoto se si può (P4).
## ignore_tier: le carte dorate ignorano l'altezza, ma mai l'era (GDD §10.5.6).
func tech_block_reason(def: TechDef, ignore_tier: bool = false) -> String:
	if techs_done.has(def):
		return "Già completata."
	if def.era > era:
		return "Si apre nell'era %s." % era_name(def.era)
	if def.is_exclusive() and not _has_any_identity(def.requires_any):
		return "Esclusiva di: %s." % _identity_names(def.requires_any)
	if not def.requires_types.is_empty() and _pieces_with(def.requires_types, EventOptionDef.PieceKind.QUALSIASI).is_empty():
		return "Serve sulla plancia una tessera %s." % ", ".join(def.requires_types)
	var missing: PackedStringArray = PackedStringArray()
	for needed: Resource in def.prerequisites:
		var prerequisite: TechDef = needed as TechDef
		if prerequisite != null and not techs_done.has(prerequisite):
			missing.append(prerequisite.display_name)
	if not missing.is_empty():
		return "Richiede: %s." % ", ".join(missing)
	if def.perk != null and identity.has(def.perk):
		return "Hai già la peculiarità %s." % def.perk.display_name
	if not ignore_tier and def.tier > 1:
		var needed_first: int = run_rules.tech_second_tier_needed
		if _first_tier_done(def.era, def.branch()) < needed_first:
			return "Si apre con %d tecnologia della prima altezza del ramo %s in quest'era." % [needed_first, TechDef.BRANCH_NAMES.get(def.branch(), "?")]
	return ""


## Sceglie la tecnologia da studiare fra le carte (GDD §10.5.1): in qualunque momento,
## senza consumare il round. La Ricerca in attesa ci entra subito.
func choose_tech(def: TechDef) -> bool:
	if not _require_not_over():
		return false
	if def == null or not tech_hand_cards().has(def):
		return _fail("Questa tecnologia non è fra le carte della mano.")
	var reason: String = tech_block_reason(def, is_golden(def))
	if reason != "":
		return _fail(reason)
	if def == current_tech:
		return _fail("La stai già studiando.")
	current_tech = def
	if not tech_progress.has(def.id):
		tech_progress[def.id] = 0
	tech_discards.erase(def.id)
	_log("Ricerca: si studia %s (%d/%d)." % [def.display_name, tech_progress_of(def), def.cost])
	_flow_research()
	return true


## La Ricerca in attesa va nella tecnologia in corso; quella in più resta in attesa (GDD §10.5.1).
func _flow_research() -> void:
	while current_tech != null:
		var progress: int = tech_progress.get(current_tech.id, 0)
		var missing: int = current_tech.cost - progress
		if missing > 0:
			if research <= 0:
				return
			var moved: int = mini(missing, research)
			research -= moved
			tech_progress[current_tech.id] = progress + moved
			if moved < missing:
				return
		_complete_tech(current_tech)


func _complete_tech(def: TechDef) -> void:
	techs_done.append(def)
	tech_progress.erase(def.id)
	tech_discards.erase(def.id)
	golden_techs.erase(def)
	if current_tech == def:
		current_tech = null
	_log("Tecnologia completata: %s. %s" % [def.display_name, def.description])
	for modifier: ModifierDef in def.permanent_modifiers:
		_log(modifiers.apply(modifier, ActiveModifier.OriginKind.TECNOLOGIA, def.display_name, year, board, _rng))
	if def.perk != null and not identity.has(def.perk):
		_adopt_identity(def.perk)
	if def.extra_building_slots > 0:
		board.base_building_slots += mini(def.extra_building_slots, maxi(0, board.max_building_slots - board.building_capacity()))
	if def.extra_troop_slots > 0:
		board.base_troop_slots += mini(def.extra_troop_slots, maxi(0, board.max_troop_slots - board.troop_capacity()))
	if def.line != null:
		_log("Nuova linea fra le opportunità del Consiglio: %s." % def.line.display_name)
	_note_deed(DeedDef.Kind.TECNOLOGIE, StringName(def.sphere))
	_draw_tech_hand()
	_check_traditions()


## Tecnologie iniziate e carte dorate, non ancora completate.
func _started_techs() -> Array[TechDef]:
	var found: Array[TechDef] = []
	for def: TechDef in catalog.technologies:
		if tech_progress.has(def.id) and not techs_done.has(def):
			found.append(def)
	for def: TechDef in golden_techs:
		if not found.has(def):
			found.append(def)
	return found


## Tecnologie che possono entrare nella mano: disponibili, non iniziate e non dorate.
func _tech_pool() -> Array[TechDef]:
	var found: Array[TechDef] = []
	for def: TechDef in catalog.technologies:
		if tech_progress.has(def.id) or golden_techs.has(def):
			continue
		if tech_block_reason(def) == "":
			found.append(def)
	return found


## Pesca la mano (GDD §10.5.3): 3 tecnologie pesate dalle radici. In ogni ramo si pesca dalla sua
## altezza più bassa ancora aperta e da quella subito sopra: un ramo finito prima degli altri
## può andare avanti (Davide, 6 novembre). Una carta scartata ha il peso dimezzato a ogni scarto.
func _draw_tech_hand() -> void:
	for def: TechDef in tech_hand:
		if not techs_done.has(def) and not tech_progress.has(def.id):
			tech_discards[def.id] = tech_discards.get(def.id, 0) + 1
	tech_hand = []
	var pool: Array[TechDef] = _tech_pool()
	if pool.is_empty():
		return
	var lowest: Dictionary[StringName, int] = {}
	for def: TechDef in pool:
		lowest[def.branch()] = mini(lowest.get(def.branch(), def.height()), def.height())
	var candidates: Array[TechDef] = []
	var weights: Array[int] = []
	for def: TechDef in pool:
		if def.height() > lowest[def.branch()] + 1:
			continue
		candidates.append(def)
		weights.append(_tech_weight(def))
	for i: int in range(mini(run_rules.tech_hand_size, candidates.size())):
		var total: int = 0
		for weight: int in weights:
			total += weight
		var roll: int = _tech_rng.randi_range(0, total - 1)
		var pick: int = 0
		while roll >= weights[pick]:
			roll -= weights[pick]
			pick += 1
		tech_hand.append(candidates[pick])
		candidates.remove_at(pick)
		weights.remove_at(pick)


## Peso di una tecnologia nella mano: 1 più 1 per radice, dimezzato a ogni scarto fino al minimo.
func _tech_weight(def: TechDef) -> int:
	var halvings_max: int = maxi(0, run_rules.tech_discard_max_halvings)
	var halvings: int = mini(tech_discards.get(def.id, 0), halvings_max)
	return maxi(1, (_roots_weight(def.favored_by) << halvings_max) >> halvings)


## Carta dorata: la tecnologia arriva già iniziata e resta nella mano finché non è completata.
func _give_golden(def: TechDef) -> void:
	if def == null:
		_log("Nessuna tecnologia da ricevere già iniziata.")
		return
	if techs_done.has(def):
		_log("%s è già completata." % def.display_name)
		return
	@warning_ignore("integer_division")
	var head_start: int = def.cost * run_rules.golden_progress_percent / 100
	tech_progress[def.id] = maxi(tech_progress.get(def.id, 0), head_start)
	if not golden_techs.has(def):
		golden_techs.append(def)
	tech_hand.erase(def)
	_log("Carta dorata: %s, già iniziata (%d/%d)." % [def.display_name, tech_progress[def.id], def.cost])
	if def == current_tech:
		_flow_research()


## Una tecnologia a caso per una carta dorata: ricercabile nella sua era (anche di un'altezza
## più alta), della sfera indicata se c'è; null se non ce ne sono.
func _random_golden(sphere: String) -> TechDef:
	var found: Array[TechDef] = []
	for def: TechDef in catalog.technologies:
		if golden_techs.has(def) or (sphere != "" and def.sphere != sphere):
			continue
		if tech_block_reason(def, true) == "":
			found.append(def)
	if found.is_empty():
		return null
	return found[_tech_rng.randi_range(0, found.size() - 1)]


func _first_tier_done(era_number: int, branch: StringName) -> int:
	var count: int = 0
	for def: TechDef in techs_done:
		if def.era == era_number and def.tier == 1 and def.branch() == branch:
			count += 1
	return count


func _has_any_identity(elements: Array[Resource]) -> bool:
	for element: Resource in elements:
		if identity.has(element):
			return true
	return false


static func _identity_names(elements: Array[Resource]) -> String:
	var names: PackedStringArray = PackedStringArray()
	for element: Resource in elements:
		var def: IdentityDef = element as IdentityDef
		if def != null:
			names.append(def.display_name)
	return ", ".join(names)


# --- Tradizioni e ascensioni (GDD §10.4.1, §10.4.2, v0.27) --------------------------------

## true se la nazione ha un'ascensione che cambia questa regola.
func has_rule(rule: IdentityDef.Rule) -> bool:
	return _identity_has_rule(identity, rule)


static func _identity_has_rule(elements: Array[IdentityDef], rule: IdentityDef.Rule) -> bool:
	for def: IdentityDef in elements:
		if def.rule == rule:
			return true
	return false


## Livello massimo delle carte: 3, oppure 4 con l'ascensione Maestria (GDD §6.5, §10.4.2).
func max_level() -> int:
	return run_rules.max_level + (1 if has_rule(IdentityDef.Rule.MAESTRIA) else 0)


## Vie adottate, nell'ordine in cui sono state scelte.
func adopted_ways() -> Array[IdentityDef]:
	var found: Array[IdentityDef] = []
	for def: IdentityDef in identity:
		if def.dimension == IdentityDef.Dimension.VIA:
			found.append(def)
	return found


## Ascensioni prese, nell'ordine in cui sono state scelte.
func ascensions() -> Array[IdentityDef]:
	var found: Array[IdentityDef] = []
	for def: IdentityDef in identity:
		if def.dimension == IdentityDef.Dimension.ASCENSIONE:
			found.append(def)
	return found


## Avanzamento di un passo verso la sua impresa, come numero (al massimo l'obiettivo).
func tradition_progress(tradition: TraditionDef) -> int:
	var deed: DeedDef = tradition.deed
	if deed == null:
		return 0
	if traditions_done.has(tradition):
		return deed.amount
	match deed.kind:
		DeedDef.Kind.CARTE, DeedDef.Kind.CARTE_LIVELLO:
			return mini(_deed_cards(deed), deed.amount)
		DeedDef.Kind.MALCONTENTO_MASSIMO:
			return malcontent
	return mini(deed_counts.get(tradition.id, 0), deed.amount)


## Avanzamento in parole, per l'interfaccia (P4): "2/3" oppure, per il Malcontento, il valore attuale.
func tradition_progress_text(tradition: TraditionDef) -> String:
	if traditions_done.has(tradition):
		return "fatto"
	if tradition.deed == null:
		return ""
	if tradition.deed.kind == DeedDef.Kind.MALCONTENTO_MASSIMO:
		return "Malcontento ora %d" % malcontent
	return "%d/%d" % [tradition_progress(tradition), tradition.deed.amount]


## Sceglie una delle ascensioni proposte (GDD §10.4.2): diventa parte dell'identità per sempre.
func choose_ascension(index: int) -> bool:
	if index < 0 or index >= ascension_choices.size():
		return _fail("Ascensione non valida.")
	var chosen: IdentityDef = ascension_choices[index]
	ascension_choices = []
	pending_ascensions = maxi(0, pending_ascensions - 1)
	_adopt_identity(chosen)
	_offer_ascension()
	_redraw_round()
	return true


## Un traguardo riuscito: conta per i passi non ancora fatti delle vie adottate.
func _note_deed(kind: DeedDef.Kind, detail: StringName) -> void:
	for way: IdentityDef in adopted_ways():
		for tradition: TraditionDef in way.traditions:
			var deed: DeedDef = tradition.deed
			if deed == null or deed.kind != kind or traditions_done.has(tradition):
				continue
			if not _deed_matches(deed, detail):
				continue
			deed_counts[tradition.id] = deed_counts.get(tradition.id, 0) + 1


static func _deed_matches(deed: DeedDef, detail: StringName) -> bool:
	match deed.kind:
		DeedDef.Kind.VITTORIE:
			if deed.battles == DeedDef.Battles.FANTASMI:
				return detail == &"fantasma"
			if deed.battles == DeedDef.Battles.INCONTRI:
				return detail == &"incontro"
			return true
		DeedDef.Kind.TECNOLOGIE, DeedDef.Kind.EVENTI:
			return deed.spheres.is_empty() or deed.spheres.has(String(detail))
		DeedDef.Kind.PROPOSTE:
			return deed.advisor_id == detail
	return false


## Una produzione: per le imprese PRODUZIONE si ricorda la più alta da quando la via è adottata.
func _note_production(collected: Array[int]) -> void:
	for way: IdentityDef in adopted_ways():
		for tradition: TraditionDef in way.traditions:
			var deed: DeedDef = tradition.deed
			if deed == null or deed.kind != DeedDef.Kind.PRODUZIONE or traditions_done.has(tradition):
				continue
			@warning_ignore("integer_division")
			var units: int = collected[deed.resource] / Res.scale(deed.resource)
			deed_counts[tradition.id] = maxi(deed_counts.get(tradition.id, 0), units)


## Carte sulla plancia che contano per un'impresa CARTE o CARTE_LIVELLO.
func _deed_cards(deed: DeedDef) -> int:
	var kind: EventOptionDef.PieceKind = EventOptionDef.PieceKind.QUALSIASI
	if deed.pieces == DeedDef.Pieces.EDIFICI:
		kind = EventOptionDef.PieceKind.EDIFICIO
	elif deed.pieces == DeedDef.Pieces.TRUPPE:
		kind = EventOptionDef.PieceKind.TRUPPA
	var count: int = 0
	for piece: BoardPiece in _pieces_with(deed.types, kind):
		if deed.kind == DeedDef.Kind.CARTE or piece.level >= deed.min_level:
			count += 1
	return count


func _deed_done(tradition: TraditionDef, closing_year: bool) -> bool:
	var deed: DeedDef = tradition.deed
	if deed == null:
		return false
	match deed.kind:
		DeedDef.Kind.CARTE, DeedDef.Kind.CARTE_LIVELLO:
			return _deed_cards(deed) >= deed.amount
		DeedDef.Kind.MALCONTENTO_MASSIMO:
			return closing_year and malcontent <= deed.amount
	return deed_counts.get(tradition.id, 0) >= deed.amount


## Completa i passi le cui imprese sono riuscite; un albero completo dà un'ascensione.
func _check_traditions(closing_year: bool = false) -> void:
	for way: IdentityDef in adopted_ways():
		for tradition: TraditionDef in way.traditions:
			if not traditions_done.has(tradition) and _deed_done(tradition, closing_year):
				_complete_tradition(tradition)
		if not way.traditions.is_empty() and not completed_ways.has(way):
			var all_done: bool = true
			for tradition: TraditionDef in way.traditions:
				if not traditions_done.has(tradition):
					all_done = false
			if all_done:
				completed_ways.append(way)
				pending_ascensions += 1
				_log("L'albero della %s è completo: scegli un'ascensione." % way.display_name)
	_offer_ascension()


func _complete_tradition(tradition: TraditionDef) -> void:
	traditions_done.append(tradition)
	deed_counts.erase(tradition.id)
	_log("Tradizione: %s (%s). %s" % [tradition.display_name, tradition.deed.describe() if tradition.deed != null else "", tradition.description])
	for modifier: ModifierDef in tradition.permanent_modifiers:
		_log(modifiers.apply(modifier, ActiveModifier.OriginKind.TRADIZIONE, tradition.display_name, year, board, _rng))
	if tradition.extra_building_slots > 0:
		board.base_building_slots += mini(tradition.extra_building_slots, maxi(0, board.max_building_slots - board.building_capacity()))
	if tradition.extra_troop_slots > 0:
		board.base_troop_slots += mini(tradition.extra_troop_slots, maxi(0, board.max_troop_slots - board.troop_capacity()))


## Se c'è un albero completo in attesa, pesca 3 ascensioni (GDD §10.4.2, §16.3): del livello 1
## la prima, del livello 2 le successive; pesate dalle radici, senza quelle già prese.
func _offer_ascension() -> void:
	if pending_ascensions <= 0 or not ascension_choices.is_empty():
		return
	var wanted_level: int = mini(2, ascensions().size() + 1)
	var pool: Array[IdentityDef] = _ascension_pool(wanted_level)
	if pool.is_empty():
		pool = _ascension_pool(0)
	if pool.is_empty():
		pending_ascensions = 0
		_log("Nessuna ascensione disponibile.")
		return
	var weights: Array[int] = []
	for def: IdentityDef in pool:
		weights.append(_roots_weight(def.favored_by))
	for i: int in range(mini(3, pool.size())):
		var total: int = 0
		for weight: int in weights:
			total += weight
		var roll: int = _tradition_rng.randi_range(0, total - 1)
		var pick: int = 0
		while roll >= weights[pick]:
			roll -= weights[pick]
			pick += 1
		ascension_choices.append(pool[pick])
		pool.remove_at(pick)
		weights.remove_at(pick)


## Ascensioni del livello indicato (0 = qualsiasi) che la nazione può prendere.
func _ascension_pool(level: int) -> Array[IdentityDef]:
	var found: Array[IdentityDef] = []
	for def: IdentityDef in catalog.ascensions:
		if identity.has(def) or (level > 0 and def.ascension_level != level):
			continue
		if not def.requires_any.is_empty() and not _has_any_identity(def.requires_any):
			continue
		found.append(def)
	return found


## Regole della battaglia cambiate dalle ascensioni di una nazione (GDD §10.4.2).
static func _apply_battle_rules(setup: BattleSideSetup, elements: Array[IdentityDef]) -> void:
	setup.last_stand = _identity_has_rule(elements, IdentityDef.Rule.ULTIMA_TRINCEA)
	setup.first_spark = _identity_has_rule(elements, IdentityDef.Rule.PRIMA_SCINTILLA)
	setup.reserve_mana = _identity_has_rule(elements, IdentityDef.Rule.DISCIPLINA_FERREA)
	setup.any_color = _identity_has_rule(elements, IdentityDef.Rule.MANA_UNITO)


# --- Azioni sulla plancia (in qualunque momento fuori dal combattimento) -----

func sell_building(index: int) -> bool:
	if not _require_not_over():
		return false
	if index < 0 or index >= board.buildings.size():
		return _fail("Edificio non valido.")
	if board.buildings[index].building.is_capital:
		return _fail("La Capitale non si può vendere.")
	if not board.can_sell_building(index):
		return _fail("Prima libera gli spazi che questo edificio concede.")
	var piece: BoardPiece = board.buildings[index]
	board.buildings.remove_at(index)
	_refund(piece)
	_prune_modifiers()
	return true


func sell_troop(index: int) -> bool:
	if not _require_not_over():
		return false
	if index < 0 or index >= board.troops.size():
		return _fail("Truppa non valida.")
	var piece: BoardPiece = board.troops[index]
	board.troops.remove_at(index)
	_refund(piece)
	_prune_modifiers()
	return true


func move_troop(from_index: int, to_index: int) -> bool:
	if not _require_not_over():
		return false
	if not board.move_troop(from_index, to_index):
		return _fail("Spostamento non valido.")
	return true


# --- Incontri del mondo -----------------------------------------------------

## Sceglie uno dei 3 incontri e combatte subito lo scontro (GDD §3.3).
func choose_encounter(index: int) -> bool:
	if phase != Phase.SCELTA_INCONTRO:
		return _fail("Ora non è il momento dell'incontro del mondo.")
	if index < 0 or index >= encounter_choices.size():
		return _fail("Incontro non valido.")
	var encounter: EncounterDef = encounter_choices[index]
	var enemy: BattleSideSetup = BattleSideSetup.new(encounter.buildings, encounter.troops, encounter.resistance)
	_pay_upkeep()
	var outcome: BattleSim.Outcome = _fight(BattleKind.INCONTRO, encounter.display_name, enemy)
	if not history.is_empty():
		# Due incontri all'anno (v0.25): il riepilogo li elenca in ordine.
		var record: YearRecord = history[-1]
		var separator: String = " · " if record.encounter_name != "" else ""
		record.encounter_name += separator + "%s (%s)" % [encounter.display_name, encounter.difficulty_label]
		record.encounter_result += separator + _outcome_word(outcome)

	if _player_won_or_drew(outcome):
		# Il pareggio vale come vittoria (GDD §3.4).
		won_encounter = encounter
		_log("Incontro superato: %s." % encounter.display_name)
		_note_deed(DeedDef.Kind.VITTORIE, &"incontro")
		_gain_loot(encounter.loot_gold, encounter.loot_research)
		var trophies: int = _identity_int(&"win_gold")
		if trophies > 0:
			gold += trophies
			_log("Usanze: +%d Oro per la vittoria." % trophies)
		_check_traditions()
		phase = Phase.RICOMPENSA_INCONTRO
		return true

	var lost_gold: int = gold - half_down(gold)
	gold = half_down(gold)
	_log("Sconfitta contro %s: perso metà dell'Oro (%d)." % [encounter.display_name, lost_gold])
	_change_malcontent(run_rules.malcontent_per_encounter_defeat, IdentityDef.Grievance.SCONFITTE, "Sconfitta")
	if last_chance:
		_end_run(RunEnd.SCONFITTA)
		return true
	_enter_season(_next_season())
	return true


## Prende una ricompensa dell'incontro vinto (GDD §3.3).
func take_reward(index: int, replace_index: int = -1) -> bool:
	if phase != Phase.RICOMPENSA_INCONTRO:
		return _fail("Non ci sono ricompense da scegliere.")
	var rewards: Array[RewardDef] = reward_choices()
	if index < 0 or index >= rewards.size():
		return _fail("Ricompensa non valida.")
	var reward: RewardDef = rewards[index]
	match reward.kind:
		RewardDef.Kind.ORO:
			gold += reward.amount
		RewardDef.Kind.RICERCA:
			research += reward.amount
		RewardDef.Kind.RISORSA:
			stock[reward.resource] += reward.amount * Res.scale(reward.resource)
		RewardDef.Kind.EDIFICIO:
			# Gratis, ma vale come il prezzo di catalogo quando si vende (GDD §6.4).
			if not _place_building(reward.building, 0, reward.building.cost_gold, replace_index):
				return false
		RewardDef.Kind.TRUPPA:
			if not _place_troop(reward.troop, 0, reward.troop.cost_gold, replace_index):
				return false
		RewardDef.Kind.PERK:
			if identity.has(reward.perk):
				return _fail("Hai già questa peculiarità.")
			_adopt_identity(reward.perk)
		RewardDef.Kind.TECNOLOGIA:
			_give_golden(reward.tech if reward.tech != null else _random_golden(""))
	if reward.assimilation:
		assimilated += 1
		flags[&"assimilati"] = flags.get(&"assimilati", year)
		_change_malcontent(run_rules.malcontent_per_assimilation, IdentityDef.Grievance.EVENTI, "Assimilazione")
		_story("Anno %d: %s entrano nella nazione, che lo vogliano o no." % [year, reward.troop.display_name])
	_log("Ricompensa presa: %s." % reward.describe())
	_flow_research()
	_check_traditions()
	won_encounter = null
	_enter_season(_next_season())
	return true


## Rinuncia alla ricompensa (GDD §3.3: il giocatore sceglie se prenderla).
func skip_reward() -> bool:
	if phase != Phase.RICOMPENSA_INCONTRO:
		return _fail("Non ci sono ricompense da scegliere.")
	_log("Nessuna ricompensa presa.")
	won_encounter = null
	_enter_season(_next_season())
	return true


# --- Scontro con il fantasma ------------------------------------------------

func fight_ghost() -> bool:
	if phase != Phase.SCONTRO_FANTASMA:
		return _fail("Ora non è il momento dello scontro con il fantasma.")
	var ghost_name: String = current_ghost.display_name if current_ghost != null else "Fantasma"
	var enemy: BattleSideSetup = BattleSideSetup.new([], [], 0)
	if current_ghost != null:
		enemy = _ghost_setup()
		# Lo spionaggio dell'anno colpisce gli elementi scelti (GDD §12).
		enemy.start_timer_effects = spy_effects.duplicate()
	spy_effects = []
	_pay_upkeep()
	var outcome: BattleSim.Outcome = _fight(BattleKind.FANTASMA, ghost_name, enemy)
	for message: String in modifiers.on_ghost_fight_done():
		_log(message)
	if not history.is_empty():
		history[-1].ghost_name = ghost_name
		history[-1].ghost_result = _outcome_word(outcome)

	if _player_won_or_drew(outcome):
		wins += 1
		if outcome == BattleSim.Outcome.PAREGGIO:
			# Il pareggio conta come vittoria ma applica i malus del fantasma (GDD §3.4).
			_log("Pareggio contro %s: conta come vittoria (%d)." % [ghost_name, wins])
			_apply_ghost_malus(ghost_name)
		else:
			_log("Vittoria contro %s (%d)." % [ghost_name, wins])
		_note_deed(DeedDef.Kind.VITTORIE, &"fantasma")
		_gain_loot(run_rules.ghost_loot_gold, run_rules.ghost_loot_research)
		if wins >= run_rules.wins_needed:
			_end_run(RunEnd.VITTORIA)
			return true
	else:
		if last_chance:
			_log("Sconfitta contro %s durante l'ultima possibilità." % ghost_name)
			_end_run(RunEnd.SCONFITTA)
			return true
		prestige -= year
		_log("Sconfitta contro %s: perso %d Prestigio." % [ghost_name, year])
		_change_malcontent(run_rules.malcontent_per_ghost_defeat, IdentityDef.Grievance.SCONFITTE, "Sconfitta")
		_apply_ghost_malus(ghost_name)
		if prestige <= 0:
			prestige = 0
			last_chance = true
			_log("Il Prestigio è esaurito: ultima possibilità.")

	# Fine dell'anno: si controllano anche le imprese sul Malcontento (GDD §10.4.1).
	_check_traditions(true)
	if run_rules.prototype_years > 0 and year >= run_rules.prototype_years:
		_end_run(RunEnd.FINE_PROVA)
		return true
	_start_year(year + 1)
	return true


# --- Cronache della nazione (GDD §9.6, v0.29) ------------------------------------

## Nome del momento di cronaca della stagione, es. "Solstizio d'estate".
func chronicle_moment(which: Season = season) -> String:
	return CHRONICLE_MOMENTS[which]


## All'inizio di una stagione pesca la cronaca, se ce n'è una: la fase diventa CRONACA e i round
## aspettano la reazione della nazione. D'inverno solo dall'anno 2 (il primo anno parte da subito).
func _start_chronicle() -> bool:
	current_chronicle = null
	offered_vocation = null
	_chronicle_built = []
	if not run_rules.chronicles_enabled or catalog.chronicles.is_empty():
		return false
	if season == Season.INVERNO and year <= 1:
		return false
	var pick: ChronicleDef = _draw_chronicle()
	if pick == null:
		return false
	current_chronicle = pick
	if not pick.repeatable:
		seen_chronicles.append(pick.id)
	chronicle_last_year[pick.id] = year
	_chronicle_built = _chronicle_special_options(pick)
	phase = Phase.CRONACA
	offers = []
	advisor_choices = []
	chosen_advisor = null
	event_choice = null
	chosen_event = null
	round_number = 0
	_log("%s: %s." % [chronicle_moment(), pick.display_name])
	return true


## La vocazione pronta, se c'è, ha la precedenza; poi una cronaca a caso fra quelle possibili,
## più probabile se è più personale (ogni condizione soddisfatta pesa di più).
func _draw_chronicle() -> ChronicleDef:
	var vocation: IdentityDef = _ready_vocation()
	if vocation != null:
		for def: ChronicleDef in catalog.chronicles:
			if def.special == EventDef.Special.VOCAZIONE:
				offered_vocation = vocation
				vocations_offered.append(vocation.id)
				return def
	# Prima si evitano le cronache arrivate da poco; se non resta nulla, valgono anche quelle.
	for gap: int in [run_rules.chronicle_repeat_gap_years, 0]:
		var pool: Array[ChronicleDef] = []
		var weights: Array[int] = []
		for def: ChronicleDef in catalog.chronicles:
			if not _chronicle_available(def):
				continue
			if gap > 0 and chronicle_last_year.has(def.id) and year - chronicle_last_year[def.id] < gap:
				continue
			pool.append(def)
			weights.append(_roots_weight(def.favored_by) + _season_bonus(def.favored_seasons)
					+ run_rules.chronicle_specific_weight * _chronicle_specificity(def))
		if not pool.is_empty():
			return pool[_weighted_pick_with(_chronicle_rng, weights)]
	return null


## Una cronaca può arrivare adesso: momento, anno, radici, ricordi, inclinazioni e personaggi.
func _chronicle_available(def: ChronicleDef) -> bool:
	if def.special == EventDef.Special.VOCAZIONE or def.options.is_empty():
		return false
	if not def.repeatable and seen_chronicles.has(def.id):
		return false
	if not def.seasons.is_empty() and not def.seasons.has(int(season)):
		return false
	if def.min_year > 0 and year < def.min_year:
		return false
	if not _roots_ok(def.requires_any, def.min_era, def.max_era, def.requires_types):
		return false
	if def.min_type_count > 1 and _pieces_with(def.requires_types, EventOptionDef.PieceKind.QUALSIASI).size() < def.min_type_count:
		return false
	if def.requires_stock != null and not can_pay(def.requires_stock):
		return false
	if def.min_malcontent > 0 and malcontent < def.min_malcontent:
		return false
	if def.requires_malus and modifiers.year_malus().is_empty():
		return false
	if def.min_win_streak > 0 and win_streak < def.min_win_streak:
		return false
	if def.last_battle == ChronicleDef.LastBattle.VINTO and last_battle_result != 1:
		return false
	if def.last_battle == ChronicleDef.LastBattle.PERSO and last_battle_result != 0:
		return false
	for flag: StringName in def.requires_flags:
		if not flags.has(flag):
			return false
	for flag: StringName in def.forbids_flags:
		if flags.has(flag):
			return false
	if def.inclination_axis >= 0 and inclinations[def.inclination_axis] * signi(def.inclination_pole) < def.inclination_steps:
		return false
	if def.requires_character != null:
		var who: NationCharacter = character_of(def.requires_character)
		if who == null or who.affinity < def.min_affinity or who.affinity > def.max_affinity:
			return false
	# I personaggi entrano nella storia solo dopo il primo fantasma, e una volta sola.
	for option: EventOptionDef in def.options:
		if option.introduce_character != null:
			if year < run_rules.characters_from_year or character_of(option.introduce_character) != null:
				return false
	return true


## Quante condizioni personali ha la cronaca: le più legate alla partita escono più spesso.
func _chronicle_specificity(def: ChronicleDef) -> int:
	var count: int = 0
	for present: bool in [not def.requires_any.is_empty(), not def.requires_types.is_empty(), def.min_malcontent > 0,
			def.min_win_streak > 0, def.last_battle != ChronicleDef.LastBattle.QUALSIASI, not def.requires_flags.is_empty(),
			def.inclination_axis >= 0, def.requires_character != null, def.requires_malus]:
		if present:
			count += 1
	return count


## Posizione pescata con questi pesi da un generatore a parte (le cronache non spostano la pesca
## dei consiglieri).
static func _weighted_pick_with(rng: RandomNumberGenerator, weights: Array[int]) -> int:
	var total: int = 0
	for weight: int in weights:
		total += weight
	var roll: int = rng.randi_range(0, total - 1)
	var pick: int = 0
	while roll >= weights[pick]:
		roll -= weights[pick]
		pick += 1
	return pick


## Per la cronaca della vocazione: l'opzione che la accetta, prima di quelle scritte nei dati.
func _chronicle_special_options(def: ChronicleDef) -> Array[EventOptionDef]:
	var built: Array[EventOptionDef] = []
	if def.special == EventDef.Special.VOCAZIONE and offered_vocation != null:
		var accept: EventOptionDef = EventOptionDef.new()
		accept.label = "Diventa: %s" % offered_vocation.display_name
		accept.description = offered_vocation.description
		accept.vocation = offered_vocation
		accept.story = offered_vocation.story
		built.append(accept)
	return built


## Opzioni della cronaca in corso: quelle costruite dalle regole, poi quelle dei dati.
func chronicle_options() -> Array[EventOptionDef]:
	if current_chronicle == null:
		return []
	var all: Array[EventOptionDef] = _chronicle_built.duplicate()
	all.append_array(current_chronicle.options)
	return all


## Testo della cronaca con i nomi della run al posto dei segnaposto.
func chronicle_text(text: String) -> String:
	var who: NationCharacter = null
	if current_chronicle != null:
		if current_chronicle.requires_character != null:
			who = character_of(current_chronicle.requires_character)
	var values: Dictionary = {
		"nazione": nation_name,
		"anno": str(year),
		"momento": chronicle_moment(),
		"razza": _identity_name(IdentityDef.Dimension.POPOLO),
		"governo": _identity_name(IdentityDef.Dimension.GOVERNO),
		"credo": _identity_name(IdentityDef.Dimension.CREDO),
		"nemico": last_opponent_name.trim_prefix("Fantasma: ") if last_opponent_name != "" else "il nemico",
		"personaggio": who.name if who != null else "",
		"ruolo": who.def.role.to_lower() if who != null else "",
		"vocazione": offered_vocation.display_name if offered_vocation != null else "",
	}
	return text.format(values)


func _identity_name(dimension: IdentityDef.Dimension) -> String:
	for def: IdentityDef in identity:
		if def.dimension == dimension:
			return def.display_name
	return ""


## La reazione della nazione: paga, applica gli effetti, sposta le inclinazioni, lascia i ricordi
## e poi comincia la stagione (con la sua produzione).
func choose_chronicle_option(index: int, choice: int = -1) -> bool:
	if phase != Phase.CRONACA or current_chronicle == null:
		return _fail("Ora non c'è nessuna cronaca.")
	var options: Array[EventOptionDef] = chronicle_options()
	if index < 0 or index >= options.size():
		return _fail("Reazione non valida.")
	var option: EventOptionDef = options[index]
	var reason: String = option_block_reason(option)
	if reason != "":
		return _fail(reason)
	var pieces: Array[BoardPiece] = _option_choice_pieces(option)
	if pieces.size() == 1:
		choice = 0
	if not pieces.is_empty() and (choice < 0 or choice >= pieces.size()):
		return _fail("Scegli su quale tessera applicarla.")
	var chosen_piece: BoardPiece = pieces[choice] if not pieces.is_empty() else null
	var source: String = current_chronicle.display_name
	var who: NationCharacter = character_of(current_chronicle.requires_character) if current_chronicle.requires_character != null else null
	# Un personaggio nuovo entra prima del testo, così la storia può chiamarlo per nome.
	if option.introduce_character != null and character_of(option.introduce_character) == null:
		var def: CharacterDef = option.introduce_character
		var picked: String = def.names[_chronicle_rng.randi_range(0, def.names.size() - 1)] if not def.names.is_empty() else def.role
		who = NationCharacter.new(def, picked, 0, year)
		characters.append(who)
		_log("Entra nella storia: %s." % who.describe())
	_apply_option_effects(option, source, chosen_piece, 1)
	if who != null and option.character_affinity != 0:
		who.affinity += option.character_affinity
		_log("%s: fiducia %+d (ora %d)." % [who.describe(), option.character_affinity, who.affinity])
	var line: String = option.story if option.story != "" else option.label
	if line != "":
		var named: String = chronicle_text(line.replace("{personaggio}", who.name if who != null else ""))
		_story("Anno %d, %s — %s: %s" % [year, chronicle_moment().to_lower(), chronicle_text(current_chronicle.display_name), named])
	if who != null and option.character_leaves:
		characters.erase(who)
		_log("Esce dalla storia: %s." % who.describe())
	for flag: StringName in option.set_flags:
		flags[flag] = year
	for flag: StringName in option.clear_flags:
		flags.erase(flag)
	if option.vocation != null:
		_take_vocation(option.vocation as IdentityDef)
	_log("%s: %s." % [source, option.label])
	for axis: int in range(mini(option.inclination_shift.size(), Inclination.Axis.size())):
		if option.inclination_shift[axis] != 0:
			shift_inclination(axis, option.inclination_shift[axis], source)
	_flow_research()
	_check_traditions()
	current_chronicle = null
	offered_vocation = null
	_chronicle_built = []
	_enter_phase(Phase.CONSIGLIO)
	return true


## Sposta un'inclinazione; all'estremo la nazione prende l'usanza di quel polo (una volta sola).
func shift_inclination(axis: int, steps: int, source: String) -> void:
	var limit: int = run_rules.inclination_limit
	var before: int = inclinations[axis]
	inclinations[axis] = clampi(before + steps, -limit, limit)
	if inclinations[axis] == before:
		return
	_log("%s: la nazione si fa più %s (%s %+d)." % [source, Inclination.pole_name(axis, steps).to_lower(),
			Inclination.AXIS_NAMES[axis as Inclination.Axis], inclinations[axis]])
	if absi(inclinations[axis]) < limit:
		return
	var custom: IdentityDef = custom_for(axis, signi(inclinations[axis]))
	if custom != null and not identity.has(custom):
		_adopt_identity(custom)
		custom_years[custom.id] = year
		_story("Anno %d — Nasce un'usanza: %s. %s" % [year, custom.display_name, custom.story.format({"anno": str(year)})])


## Usanza del catalogo legata a un polo di un asse.
func custom_for(axis: int, pole: int) -> IdentityDef:
	for def: IdentityDef in catalog.customs:
		if def.inclination_axis == axis and signi(def.inclination_pole) == pole:
			return def
	return null


## Usanze della nazione, nell'ordine in cui sono nate.
func customs() -> Array[IdentityDef]:
	var found: Array[IdentityDef] = []
	for def: IdentityDef in identity:
		if def.dimension == IdentityDef.Dimension.USANZA:
			found.append(def)
	return found


## Vocazioni della nazione.
func vocations() -> Array[IdentityDef]:
	var found: Array[IdentityDef] = []
	for def: IdentityDef in identity:
		if def.dimension == IdentityDef.Dimension.VOCAZIONE:
			found.append(def)
	return found


## Prima vocazione che la nazione può accogliere: tutte le sue usanze presenti, mai offerta prima,
## sotto il massimo della run.
func _ready_vocation() -> IdentityDef:
	if vocations().size() >= run_rules.max_vocations:
		return null
	for def: IdentityDef in catalog.vocations:
		if vocations_offered.has(def.id) or identity.has(def) or def.requires_customs.is_empty():
			continue
		var ready: bool = true
		for needed: Resource in def.requires_customs:
			if not identity.has(needed):
				ready = false
		if ready:
			return def
	return null


func _take_vocation(def: IdentityDef) -> void:
	if identity.has(def):
		return
	_adopt_identity(def)
	custom_years[def.id] = year
	_story("Anno %d — %s diventa: %s. %s" % [year, nation_name, def.display_name, def.story.format({"anno": str(year)})])
	if def.rule == IdentityDef.Rule.PROFEZIA:
		_make_prophecy()


## Personaggio presente con questa scheda, oppure null.
func character_of(def: CharacterDef) -> NationCharacter:
	for who: NationCharacter in characters:
		if who.def == def:
			return who
	return null


## Riga della storia della nazione (anche nel registro della partita).
func _story(line: String) -> void:
	story.append(line)
	_log(line)


## Vocazione Teocrazia profetica (GDD §9.6, v0.29): a inizio anno si vede una truppa del fantasma.
func _make_prophecy() -> void:
	prophecy = ""
	if not has_rule(IdentityDef.Rule.PROFEZIA) or current_ghost == null or current_ghost.troops.is_empty():
		return
	var seen: TroopDef = current_ghost.troops[_chronicle_rng.randi_range(0, current_ghost.troops.size() - 1)]
	prophecy = seen.display_name
	_log("Profezia: il fantasma dell'anno schiera %s." % prophecy)


## Risorse che le usanze danno all'inizio di ogni stagione, in unità interne.
func _season_custom_resources() -> Array[int]:
	var totals: Array[int] = Res.empty()
	for def: IdentityDef in identity:
		if def.season_resources != null:
			for type: Res.Type in Res.NAMES:
				totals[type] += def.season_resources.internal(type)
	return totals


# --- Parti interne ----------------------------------------------------------

## Bottino fisso di un nemico sconfitto: Oro e Ricerca nel Magazzino (convenzione provvisoria).
func _gain_loot(loot_gold: int, loot_research: int) -> void:
	if loot_gold <= 0 and loot_research <= 0:
		return
	gold += maxi(loot_gold, 0)
	research += maxi(loot_research, 0)
	var parts: PackedStringArray = PackedStringArray()
	if loot_gold > 0:
		parts.append("%d Oro" % loot_gold)
	if loot_research > 0:
		parts.append("%d Ricerca" % loot_research)
	_log("Bottino: %s." % " e ".join(parts))
	_flow_research()

func _start_year(new_year: int) -> void:
	_update_last_record()
	year = new_year
	if new_year == 1:
		# La prima mano delle tecnologie, con l'identità già scelta (GDD §10.5.3).
		_draw_tech_hand()
	current_ghost = _ghost_for_year(year)
	_make_prophecy()
	# Il fantasma e i due incontri dell'anno si fissano subito e non cambiano più (GDD §4.1).
	_spring_encounters = _encounters_for(year, 0)
	_summer_encounters = _encounters_for(year, 1)
	encounter_choices = []
	_log("— Anno %d —" % year)
	var record: YearRecord = YearRecord.new()
	record.year = year
	record.era = era
	record.prestige_after = prestige
	record.wins_after = wins
	history.append(record)
	for message: String in modifiers.on_new_year(year):
		_log(message)
	elder_upgrades_used = 0
	spy_effects = []
	seen_this_year = []
	# Il consumo di Cibo avviene a inizio anno, cioè a inizio inverno, dall'anno 2 (GDD §5.4).
	if year >= 2:
		_feed_troops()
	_enter_season(Season.INVERNO)


## Entra in una stagione: gli edifici producono e cominciano i suoi round (GDD §3.2, v0.25).
func _enter_season(new_season: Season) -> void:
	season = new_season
	# Prima dei round la nazione vive la cronaca della stagione (GDD §9.6, v0.29).
	if _start_chronicle():
		return
	_enter_phase(Phase.CONSIGLIO)


func _next_season() -> Season:
	return mini(int(season) + 1, int(Season.AUTUNNO)) as Season


func _enter_phase(new_phase: Phase) -> void:
	phase = new_phase
	offers = []
	advisor_choices = []
	chosen_advisor = null
	round_number = 0
	if is_shopping_phase():
		double_pick_used = false
		_collect_production()
		_season_themes = _shuffled_themes()
		_next_round()


## Ogni edificio presente deposita le sue risorse, una volta per stagione; d'inverno niente Cibo
## (GDD §5.2, v0.25).
func _collect_production() -> void:
	var collected: Array[int] = production_per_phase()
	if season == Season.INVERNO:
		collected[Res.Type.CIBO] = 0
	var customs: Array[int] = _season_custom_resources()
	for type: Res.Type in Res.NAMES:
		collected[type] += customs[type]
	var parts: PackedStringArray = PackedStringArray()
	for type: Res.Type in Res.NAMES:
		stock[type] += collected[type]
		if collected[type] != 0:
			parts.append("%s %s" % [Res.format(type, collected[type]), Res.NAMES[type]])
	_log("%s: gli edifici producono %s%s." % [season_name(), ", ".join(parts) if not parts.is_empty() else "nulla",
			" (d'inverno niente Cibo)" if season == Season.INVERNO else ""])
	_note_production(collected)
	_flow_research()
	_check_traditions()


## Temi dei round della stagione: quelli delle regole, in un ordine pescato con il seme della run.
func _shuffled_themes() -> Array[int]:
	var themes: Array[int] = []
	var all_seasons: Array[PackedInt32Array] = run_rules.season_themes
	var current: PackedInt32Array = all_seasons[mini(int(season), all_seasons.size() - 1)] if not all_seasons.is_empty() else PackedInt32Array()
	for theme: int in current:
		themes.append(clampi(theme, 0, RoundTheme.size() - 1))
	for i: int in range(themes.size() - 1, 0, -1):
		var j: int = _rng.randi_range(0, i)
		var swap: int = themes[i]
		themes[i] = themes[j]
		themes[j] = swap
	return themes


## Passa al round successivo, oppure chiude la metà dell'anno dopo l'ultimo round.
func _next_round() -> void:
	round_number += 1
	offers = []
	chosen_advisor = null
	advisor_choices = []
	event_choice = null
	chosen_event = null
	upgrade_used = false
	if round_number > run_rules.rounds_per_season:
		_end_shopping_phase()
		return
	# A ogni nuovo round l'aumento accumulato del rinnovo si dimezza (GDD §4.2).
	reroll_extra = half_down(reroll_extra)
	if _season_themes.is_empty():
		round_theme = RoundTheme.MISTO
	else:
		round_theme = _season_themes[mini(round_number - 1, _season_themes.size() - 1)] as RoundTheme
	_draw_advisors()


func _end_shopping_phase() -> void:
	offers = []
	advisor_choices = []
	chosen_advisor = null
	event_choice = null
	chosen_event = null
	# Fine della stagione (GDD §3.2, v0.25): l'inverno passa alla primavera, primavera ed estate
	# finiscono con un incontro del mondo, l'autunno con il fantasma.
	match season:
		Season.INVERNO:
			_enter_season(Season.PRIMAVERA)
		Season.PRIMAVERA, Season.ESTATE:
			encounter_choices = _spring_encounters if season == Season.PRIMAVERA else _summer_encounters
			phase = Phase.SCELTA_INCONTRO
			if encounter_choices.is_empty():
				push_warning("RunState: nessun incontro nei dati per l'anno %d (%s)." % [year, season_name()])
				_enter_season(_next_season())
		Season.AUTUNNO:
			phase = Phase.SCONTRO_FANTASMA


# --- Pesca dei consiglieri e delle proposte (GDD §4.2) -----------------------------

## Pesca i consiglieri del round: diversi fra loro, solo quelli che hanno qualcosa da proporre
## per il tema, più probabili se l'identità li favorisce (§16.3: peso 1, +1 per elemento).
func _draw_advisors() -> void:
	# Raggiunta la soglia del Malcontento il round mostra solo la Rivoluzione (GDD §5.5, §9.4).
	var revolution: EventDef = _revolution_event()
	if revolution != null and malcontent >= run_rules.malcontent_threshold and not revolution_targets().is_empty():
		advisor_choices = []
		_mandatory_count = 0
		event_choice = revolution
		_log("Il Malcontento ha raggiunto la soglia: scoppia la Rivoluzione.")
		return
	var pool: Array[AdvisorDef] = []
	var weights: Array[int] = []
	var excluded: Array[AdvisorDef] = _excluded_advisors()
	for advisor: AdvisorDef in catalog.advisors:
		if excluded.has(advisor) or not _advisor_has_proposals(advisor):
			continue
		pool.append(advisor)
		weights.append(_advisor_weight(advisor))
	advisor_choices = []
	var wanted: int = advisors_per_round()
	# Prima i consiglieri che il governo vuole sempre presenti (GDD §9.4, v0.24).
	for advisor: AdvisorDef in _mandatory_advisors():
		var at: int = pool.find(advisor)
		if at != -1 and advisor_choices.size() < wanted:
			advisor_choices.append(advisor)
			pool.remove_at(at)
			weights.remove_at(at)
	_mandatory_count = advisor_choices.size()
	while advisor_choices.size() < wanted and not pool.is_empty():
		var pick: int = _weighted_pick(weights)
		advisor_choices.append(pool[pick])
		pool.remove_at(pick)
		weights.remove_at(pick)
	_draw_special_card()
	for advisor: AdvisorDef in advisor_choices:
		if advisor.random_resource:
			shadow_resource = _draw_shadow_resource()
			break


## Con la probabilità delle regole, una delle carte del round è un Evento, un Visitatore o una
## Fortuna al posto di un consigliere: al massimo una per round (GDD §4.2.5).
func _draw_special_card() -> void:
	event_choice = null
	if catalog.events.is_empty() and catalog.visitors.is_empty():
		return
	# Vocazione Popolo errante (GDD §9.6, v0.29): nel primo round della stagione c'è sempre un Visitatore.
	var wanderers: bool = has_rule(IdentityDef.Rule.POPOLO_ERRANTE) and round_number == 1 and not _available_visitors().is_empty()
	if not wanderers and _rng.randi_range(1, 100) > run_rules.special_card_chance_percent:
		return
	var events: Array[EventDef] = []
	var fortunes: Array[EventDef] = []
	if not wanderers:
		events = _available_events(EventDef.Family.EVENTO)
		fortunes = _available_events(EventDef.Family.FORTUNA)
	var visitors: Array[AdvisorDef] = _available_visitors()
	var families: Array[int] = []
	var weights: Array[int] = []
	if not events.is_empty() and run_rules.event_weight > 0:
		families.append(0)
		weights.append(run_rules.event_weight)
	var visitor_weight: int = run_rules.visitor_weight + _identity_int(&"visitor_weight_change")
	if not visitors.is_empty() and visitor_weight > 0:
		families.append(1)
		weights.append(visitor_weight)
	if not fortunes.is_empty() and run_rules.fortune_weight > 0:
		families.append(2)
		weights.append(run_rules.fortune_weight)
	if families.is_empty():
		return
	# La carta speciale non prende il posto di un consigliere sempre presente.
	if advisor_choices.size() >= advisors_per_round() and advisor_choices.size() <= _mandatory_count:
		return
	var family: int = families[_weighted_pick(weights)]
	if advisor_choices.size() >= advisors_per_round():
		advisor_choices.pop_back()
	if family == 1:
		var visitor_weights: Array[int] = []
		for visitor: AdvisorDef in visitors:
			visitor_weights.append(_roots_weight(visitor.favored_by) + _season_bonus(visitor.favored_seasons))
		var visitor_pick: AdvisorDef = visitors[_weighted_pick(visitor_weights)]
		advisor_choices.append(visitor_pick)
		seen_this_year.append(visitor_pick.id)
		return
	var pool: Array[EventDef] = events if family == 0 else fortunes
	var event_weights: Array[int] = []
	for event: EventDef in pool:
		event_weights.append(_roots_weight(event.favored_by) + _season_bonus(event.favored_seasons))
	event_choice = pool[_weighted_pick(event_weights)]
	seen_events.append(event_choice.id)
	seen_this_year.append(event_choice.id)


## Eventi o Fortune che possono comparire adesso: radici soddisfatte, non già visti.
func _available_events(family: EventDef.Family) -> Array[EventDef]:
	var found: Array[EventDef] = []
	for event: EventDef in catalog.events:
		if event.family != family or seen_this_year.has(event.id):
			continue
		if family == EventDef.Family.EVENTO and not event.repeatable and seen_events.has(event.id):
			continue
		if not _roots_ok(event.requires_any, event.min_era, event.max_era, event.requires_types):
			continue
		if not event.seasons.is_empty() and not event.seasons.has(int(season)):
			continue
		if event.requires_stock != null and not can_pay(event.requires_stock):
			continue
		if event.requires_malus and modifiers.year_malus().is_empty():
			continue
		if event.special == EventDef.Special.RIFORMA and evolution_targets().is_empty():
			continue
		# La Rivoluzione non si pesca: arriva da sola (GDD §4.2.5).
		if event.special == EventDef.Special.RIVOLUZIONE:
			continue
		if event.min_malcontent > 0 and malcontent < event.min_malcontent:
			continue
		if event.options.is_empty():
			continue
		found.append(event)
	return found


func _available_visitors() -> Array[AdvisorDef]:
	var found: Array[AdvisorDef] = []
	for visitor: AdvisorDef in catalog.visitors:
		if seen_this_year.has(visitor.id) or advisor_choices.has(visitor):
			continue
		if not _roots_ok(visitor.requires_any, visitor.min_era, visitor.max_era, visitor.requires_types):
			continue
		if not visitor.seasons.is_empty() and not visitor.seasons.has(int(season)):
			continue
		if _advisor_candidates(visitor).is_empty():
			continue
		found.append(visitor)
	return found


## Radici di una carta speciale (GDD §4.2.5): richiede almeno un elemento, ere, tipi sulla plancia.
func _roots_ok(requires_any: Array[Resource], min_era: int, max_era: int, requires_types: Array[StringName]) -> bool:
	if not requires_any.is_empty():
		var found: bool = false
		for element: Resource in requires_any:
			if identity.has(element):
				found = true
		if not found:
			return false
	if min_era > 0 and era < min_era:
		return false
	if max_era > 0 and era > max_era:
		return false
	if not requires_types.is_empty() and _pieces_with(requires_types, EventOptionDef.PieceKind.QUALSIASI).is_empty():
		return false
	return true


## Peso: 1, più 1 per ogni elemento dell'identità o via che favorisce la carta.
## +1 di peso se la stagione in corso è fra quelle che favoriscono la carta (GDD §4.2.5, v0.25).
func _season_bonus(favored: PackedInt32Array) -> int:
	return 1 if favored.has(int(season)) else 0


func _roots_weight(favored_by: Array[Resource]) -> int:
	var weight: int = 1
	for element: Resource in favored_by:
		if identity.has(element):
			weight += 1
	return weight


## Peso di un consigliere: 1, più 1 per ogni elemento dell'identità che lo favorisce
## direttamente o che favorisce una delle sue azioni.
func _advisor_weight(advisor: AdvisorDef) -> int:
	var weight: int = 1
	if advisor == court_advisor:
		weight += _identity_int(&"court_advisor_weight")
	for def: IdentityDef in identity:
		if def.favored_advisors.has(advisor):
			weight += 1
			continue
		for action: OpportunityDef in advisor.actions:
			if def.favored_opportunities.has(action):
				weight += 1
				break
	# Stagioni (GDD §4.2, v0.25): es. d'inverno più Cancelliere, meno Generale.
	weight += _season_bonus(advisor.favored_seasons)
	if advisor.disfavored_seasons.has(int(season)):
		weight = maxi(1, half_down(weight))
	return weight


## Risorsa casuale di Ombra: una di quelle delle altre categorie (GDD §4.2.4).
func _draw_shadow_resource() -> Res.Type:
	var types: Array[Res.Type] = []
	for advisor: AdvisorDef in catalog.advisors:
		if advisor.special != AdvisorDef.Special.NESSUNO or advisor.random_resource:
			continue
		if advisor.upgrade_resource == Res.Type.ORO or types.has(advisor.upgrade_resource):
			continue
		types.append(advisor.upgrade_resource)
	if types.is_empty():
		return Res.Type.FERRO
	return types[_rng.randi_range(0, types.size() - 1)]


func _advisor_has_proposals(advisor: AdvisorDef) -> bool:
	if advisor.special == AdvisorDef.Special.CLOWN:
		for color: StringName in CLOWN_COLORS:
			if not _clown_candidates(color).is_empty():
				return true
		return not _neutral_buildings_of_era().is_empty()
	return not _advisor_candidates(advisor).is_empty()


## Tutte le proposte possibili di un consigliere per il tema del round, una per elemento o azione.
## Clown e Anziano ignorano il tema (GDD §4.2.2, Proposta).
func _advisor_candidates(advisor: AdvisorDef) -> Array[Offer]:
	var candidates: Array[Offer] = []
	if advisor.special == AdvisorDef.Special.VISITATORE:
		return _visitor_candidates(advisor)
	if advisor.special == AdvisorDef.Special.ANZIANO:
		candidates.append_array(_action_candidates(advisor))
		for def: BuildingDef in _neutral_buildings_of_era():
			candidates.append(_element_offer(advisor, def, null))
		return candidates
	var actions: bool = round_theme == RoundTheme.AZIONI or round_theme == RoundTheme.MISTO
	var buildings: bool = round_theme == RoundTheme.EDIFICI or round_theme == RoundTheme.MISTO
	var troops: bool = round_theme == RoundTheme.TRUPPE or round_theme == RoundTheme.MISTO
	if actions:
		candidates.append_array(_action_candidates(advisor))
	if buildings:
		for def: BuildingDef in _buildings_of_era():
			if advisor.covers(def.types):
				candidates.append(_element_offer(advisor, def, null))
	if troops:
		for def: TroopDef in _troops_of_era():
			if advisor.covers(def.types):
				candidates.append(_element_offer(advisor, null, def))
	return candidates


## Proposte di un visitatore: le sue azioni e le carte della sua lista, anche di altre nazioni
## o di un'altra era, con i suoi prezzi. Ignora il tema del round (GDD §4.2.5).
func _visitor_candidates(visitor: AdvisorDef) -> Array[Offer]:
	var candidates: Array[Offer] = _action_candidates(visitor)
	for shift: int in range(visitor.era_shift_min, visitor.era_shift_max + 1):
		var target_era: int = era + shift
		if target_era < 1 or target_era > catalog.eras.size():
			continue
		var extra: int = visitor.price_extra if shift == 0 else visitor.next_era_extra
		if visitor.offers_buildings:
			for def: BuildingDef in _visitor_buildings(visitor, target_era):
				var offer: Offer = _element_offer(visitor, def, null)
				offer.price = maxi(0, def.cost_gold + extra)
				offer.other_cost = visitor.extra_cost
				candidates.append(offer)
		if visitor.offers_troops:
			for def: TroopDef in _visitor_troops(visitor, target_era):
				var offer: Offer = _element_offer(visitor, null, def)
				offer.price = maxi(0, def.cost_gold + extra)
				offer.other_cost = visitor.extra_cost
				candidates.append(offer)
	return candidates


func _visitor_buildings(visitor: AdvisorDef, target_era: int) -> Array[BuildingDef]:
	var own: Array[BuildingDef] = catalog.buildings.duplicate()
	for identity_def: IdentityDef in identity:
		own.append_array(identity_def.exclusive_buildings)
	var found: Array[BuildingDef] = []
	for def: BuildingDef in own:
		if def.era == target_era and (visitor.any_type or visitor.covers(def.types)) and not found.has(def):
			found.append(def)
	if visitor.foreign_exclusives != AdvisorDef.Foreign.NESSUNO:
		for element: IdentityDef in _foreign_identity_elements():
			for def: BuildingDef in element.exclusive_buildings:
				if def.era != target_era or found.has(def):
					continue
				if visitor.foreign_exclusives == AdvisorDef.Foreign.TUTTI or visitor.covers(def.types):
					found.append(def)
	return found


func _visitor_troops(visitor: AdvisorDef, target_era: int) -> Array[TroopDef]:
	var own: Array[TroopDef] = catalog.troops.duplicate()
	for identity_def: IdentityDef in identity:
		own.append_array(identity_def.exclusive_troops)
	var found: Array[TroopDef] = []
	for def: TroopDef in own:
		if def.era == target_era and (visitor.any_type or visitor.covers(def.types)) and not found.has(def):
			found.append(def)
	if visitor.foreign_exclusives != AdvisorDef.Foreign.NESSUNO:
		for element: IdentityDef in _foreign_identity_elements():
			for def: TroopDef in element.exclusive_troops:
				if def.era != target_era or found.has(def):
					continue
				if visitor.foreign_exclusives == AdvisorDef.Foreign.TUTTI or visitor.covers(def.types):
					found.append(def)
	return found


## Elementi dell'identità e vie che la nazione non ha: i loro esclusivi sono "stranieri".
func _foreign_identity_elements() -> Array[IdentityDef]:
	var found: Array[IdentityDef] = []
	var all: Array[IdentityDef] = catalog.identities.duplicate()
	for era_def: EraDef in catalog.eras:
		all.append_array(era_def.ways)
	for element: IdentityDef in all:
		if not identity.has(element) and not found.has(element):
			found.append(element)
	return found


## Pesca le proposte del consigliere scelto (GDD §4.2). In un round Misto almeno una proposta
## è un'azione, se il consigliere ne ha (§16.3).
func _draw_offers() -> void:
	offers = []
	if chosen_advisor == null:
		return
	var change: int = modifiers.flat(ModifierDef.Effect.ALTERNATIVE_OFFERTE)
	if chosen_advisor.special == AdvisorDef.Special.CLOWN:
		offers = _clown_offers()
		var wanted_clown: int = maxi(1, offers.size() + change)
		offers = offers.slice(0, wanted_clown)
		return
	var wanted: int = maxi(1, run_rules.proposals_per_advisor + change)
	var pool: Array[Offer] = _advisor_candidates(chosen_advisor)
	if round_theme == RoundTheme.MISTO and chosen_advisor.special == AdvisorDef.Special.NESSUNO:
		var actions: Array[Offer] = []
		for candidate: Offer in pool:
			if not candidate.is_element():
				actions.append(candidate)
		if not actions.is_empty() and actions.size() < pool.size():
			var first: Offer = actions[_weighted_pick(_offer_weights(actions))]
			offers.append(first)
			pool.erase(first)
	while offers.size() < wanted and not pool.is_empty():
		var pick: int = _weighted_pick(_offer_weights(pool))
		offers.append(pool[pick])
		pool.remove_at(pick)


func _offer_weights(pool: Array[Offer]) -> Array[int]:
	var weights: Array[int] = []
	for offer: Offer in pool:
		weights.append(_opportunity_weight(offer.opportunity) if offer.opportunity != null else 1)
	return weights


## Il Clown: un elemento per ogni colore di mana (edificio o truppa) e un edificio neutro.
func _clown_offers() -> Array[Offer]:
	var result: Array[Offer] = []
	for color: StringName in CLOWN_COLORS:
		var candidates: Array[Offer] = _clown_candidates(color)
		if not candidates.is_empty():
			result.append(candidates[_rng.randi_range(0, candidates.size() - 1)])
	var neutral: Array[BuildingDef] = _neutral_buildings_of_era()
	if not neutral.is_empty():
		result.append(_element_offer(chosen_advisor, neutral[_rng.randi_range(0, neutral.size() - 1)], null))
	return result


## Edifici che producono mana di quel colore e truppe che lo chiedono, dell'era corrente.
func _clown_candidates(color: StringName) -> Array[Offer]:
	var clown: AdvisorDef = chosen_advisor
	var candidates: Array[Offer] = []
	for def: BuildingDef in _buildings_of_era():
		if def.mana_amount > 0 and def.mana_type == color:
			candidates.append(_element_offer(clown, def, null))
	for def: TroopDef in _troops_of_era():
		if def.mana_cost > 0 and def.mana_type == color:
			candidates.append(_element_offer(clown, null, def))
	return candidates


func _neutral_buildings_of_era() -> Array[BuildingDef]:
	var found: Array[BuildingDef] = []
	for def: BuildingDef in _buildings_of_era():
		if is_neutral_building(def):
			found.append(def)
	return found


func _element_offer(advisor: AdvisorDef, building: BuildingDef, troop: TroopDef) -> Offer:
	var offer: Offer = Offer.new()
	offer.advisor = advisor
	if building != null:
		offer.kind = OpportunityDef.Kind.COSTRUISCI_EDIFICIO
		offer.building = building
		offer.price = building.cost_gold
	else:
		offer.kind = OpportunityDef.Kind.RECLUTA_TRUPPA
		offer.troop = troop
		offer.price = troop.cost_gold
	offer.price = maxi(0, offer.price + _identity_int(&"proposal_gold_change"))
	return offer


## Azioni del consigliere che hanno senso adesso (GDD §4.2), una proposta ciascuna;
## l'azione Perk dell'Anziano diventa una proposta per ogni perk non ancora posseduto.
func _action_candidates(advisor: AdvisorDef) -> Array[Offer]:
	var candidates: Array[Offer] = []
	for opportunity: OpportunityDef in advisor.actions:
		if not _action_available(opportunity):
			continue
		if opportunity.kind == OpportunityDef.Kind.PERK:
			for perk: IdentityDef in _available_perks():
				var perk_offer: Offer = _action_offer(advisor, opportunity)
				perk_offer.perk = perk
				candidates.append(perk_offer)
		else:
			candidates.append(_action_offer(advisor, opportunity))
	return candidates


func _action_offer(advisor: AdvisorDef, opportunity: OpportunityDef) -> Offer:
	var offer: Offer = Offer.new()
	offer.advisor = advisor
	offer.opportunity = opportunity
	offer.kind = opportunity.kind
	offer.price = opportunity.cost_gold
	if offer.price > 0:
		offer.price = maxi(0, offer.price + _identity_int(&"proposal_gold_change"))
	offer.research_price = opportunity.cost_research
	offer.other_cost = _discounted_action_cost(advisor, opportunity)
	return offer


## Costo in risorse di un'azione, con lo sconto della cultura o del governo (GDD §9.2, v0.24):
## ogni risorsa diversa dall'Oro costa le unità dello sconto in meno, ma almeno 1.
func _discounted_action_cost(advisor: AdvisorDef, opportunity: OpportunityDef) -> ResourceAmounts:
	var original: ResourceAmounts = opportunity.cost_resources
	if original == null:
		return null
	var discount: int = 0
	for def: IdentityDef in identity:
		if def.cheaper_advisors.has(advisor) or def.cheaper_actions.has(opportunity):
			discount += def.action_discount
	# Vocazione Stato di polizia (GDD §9.6, v0.29): la Stabilità delle azioni costa il doppio.
	if has_rule(IdentityDef.Rule.STATO_DI_POLIZIA) and original.whole(Res.Type.STABILITA) > 0:
		var police: ResourceAmounts = ResourceAmounts.new()
		for type: Res.Type in Res.NAMES:
			var units: int = original.whole(type)
			if units > 0 and type != Res.Type.ORO:
				units = maxi(1, units - discount)
			if type == Res.Type.STABILITA:
				units *= 2
			police.add(type, units)
		return police
	if discount <= 0:
		return original
	var cheaper: ResourceAmounts = ResourceAmounts.new()
	for type: Res.Type in Res.NAMES:
		var amount: int = original.whole(type)
		if amount > 0 and type != Res.Type.ORO:
			amount = maxi(1, amount - discount)
		cheaper.add(type, amount)
	return cheaper


## Un'azione esclusiva di un elemento dell'identità compare solo a chi lo ha; una proposta che
## in quel momento non ha senso non compare (GDD §4.2).
func _action_available(opportunity: OpportunityDef) -> bool:
	if _is_exclusive_action(opportunity) and not _has_exclusive_action(opportunity):
		return false
	if opportunity.min_level > council_level():
		return false
	if opportunity.malcontent_change < 0 and malcontent <= 0:
		return false
	match opportunity.kind:
		OpportunityDef.Kind.SPAZIO_EDIFICIO:
			return board.building_capacity() < board.max_building_slots
		OpportunityDef.Kind.SPAZIO_TRUPPA:
			return board.troop_capacity() < board.max_troop_slots
		OpportunityDef.Kind.MODIFICATORE_A_SCELTA:
			return not _modifier_choices_for(opportunity).is_empty()
		OpportunityDef.Kind.ACCORCIA_MALUS:
			return not modifiers.year_malus().is_empty()
		OpportunityDef.Kind.SPIONAGGIO:
			return not _spy_candidates(opportunity).is_empty()
		OpportunityDef.Kind.INCANTO:
			return not _enchantable_troops().is_empty()
		OpportunityDef.Kind.PERK:
			return not _available_perks().is_empty()
		OpportunityDef.Kind.RIPESCA_TECNOLOGIE:
			return not _tech_pool().is_empty()
		OpportunityDef.Kind.COSTRUISCI_EDIFICIO, OpportunityDef.Kind.RECLUTA_TRUPPA:
			return false  # Gli elementi li propongono i consiglieri dai loro tipi.
	return true


func _is_exclusive_action(opportunity: OpportunityDef) -> bool:
	for def: IdentityDef in catalog.identities:
		if def.exclusive_opportunities.has(opportunity):
			return true
	for era_def: EraDef in catalog.eras:
		for way: IdentityDef in era_def.ways:
			if way.exclusive_opportunities.has(opportunity):
				return true
	return false


func _has_exclusive_action(opportunity: OpportunityDef) -> bool:
	for def: IdentityDef in identity:
		if def.exclusive_opportunities.has(opportunity):
			return true
	return false


## Perk del catalogo non ancora posseduti (GDD §9.3).
func _available_perks() -> Array[IdentityDef]:
	var found: Array[IdentityDef] = []
	for def: IdentityDef in catalog.identities:
		if def.dimension == IdentityDef.Dimension.PERK and not identity.has(def):
			found.append(def)
	return found


## Peso di un'azione fra le proposte: 1, più 1 per ogni elemento dell'identità che la favorisce.
func _opportunity_weight(opportunity: OpportunityDef) -> int:
	var weight: int = 1
	for def: IdentityDef in identity:
		if def.favored_opportunities.has(opportunity):
			weight += 1
	return weight


## Posizione pescata a caso con questi pesi (seme della run).
func _weighted_pick(weights: Array[int]) -> int:
	var total: int = 0
	for weight: int in weights:
		total += weight
	var roll: int = _rng.randi_range(0, total - 1)
	var pick: int = 0
	while roll >= weights[pick]:
		roll -= weights[pick]
		pick += 1
	return pick


## Edifici offerti: solo quelli dell'era corrente, esclusivi compresi (GDD §10.3).
func _buildings_of_era() -> Array[BuildingDef]:
	var candidates: Array[BuildingDef] = catalog.buildings.duplicate()
	for identity_def: IdentityDef in identity:
		candidates.append_array(identity_def.exclusive_buildings)
	var found: Array[BuildingDef] = []
	for def: BuildingDef in candidates:
		if def.era == era and not found.has(def):
			found.append(def)
	# Linee sbloccate dalle tecnologie: la versione dell'era, o l'ultima precedente (GDD §10.5.5).
	for tech: TechDef in techs_done:
		if tech.line != null:
			var version: BuildingDef = tech.line.building_for_era(era)
			if version != null and not found.has(version):
				found.append(version)
	return found


func _troops_of_era() -> Array[TroopDef]:
	var candidates: Array[TroopDef] = catalog.troops.duplicate()
	for identity_def: IdentityDef in identity:
		candidates.append_array(identity_def.exclusive_troops)
	var found: Array[TroopDef] = []
	for def: TroopDef in candidates:
		if def.era == era and not found.has(def):
			found.append(def)
	for tech: TechDef in techs_done:
		if tech.line != null:
			var version: TroopDef = tech.line.troop_for_era(era)
			if version != null and not found.has(version):
				found.append(version)
	return found


## Voci fra cui scegliere per un'offerta di modificatori: [modificatore, elemento o null].
func _modifier_choices(offer: Offer) -> Array[Array]:
	return _modifier_choices_for(offer.opportunity)


func _modifier_choices_for(opportunity: OpportunityDef) -> Array[Array]:
	var choices: Array[Array] = []
	for def: ModifierDef in opportunity.modifiers:
		match def.target:
			ModifierDef.Target.TRUPPA_SCELTA:
				for piece: BoardPiece in board.troops:
					choices.append([def, piece])
			ModifierDef.Target.EDIFICIO_SCELTO:
				for piece: BoardPiece in board.buildings:
					choices.append([def, piece])
			_:
				choices.append([def, null])
	return choices


# --- Spionaggio (GDD §12) ----------------------------------------------------------

## Elementi del fantasma dell'anno che lo spionaggio può colpire, con gli indici della battaglia
## (edifici da 0, truppe da BattleSim.TROOP_INDEX_OFFSET).
func _spy_candidates(spy: OpportunityDef) -> Array[int]:
	var found: Array[int] = []
	if current_ghost == null:
		return found
	if spy.spy_target != TimerTarget.Kind.TRUPPE:
		for i: int in range(current_ghost.buildings.size()):
			found.append(i)
	if spy.spy_target != TimerTarget.Kind.EDIFICI:
		for i: int in range(current_ghost.troops.size()):
			found.append(BattleSim.TROOP_INDEX_OFFSET + i)
	return found


## Bersaglio dello spionaggio secondo il criterio della proposta. A parità, il più a destra.
func _spy_pick(spy: OpportunityDef) -> int:
	var candidates: Array[int] = _spy_candidates(spy)
	if candidates.is_empty():
		return -1
	match spy.spy_criterion:
		OpportunityDef.SpyCriterion.A_CASO:
			return candidates[_rng.randi_range(0, candidates.size() - 1)]
		OpportunityDef.SpyCriterion.ESTREMITA:
			return candidates[-1]
	var best: int = candidates[-1]
	for index: int in candidates:
		var rhythm: int = _ghost_rhythm(index)
		var best_rhythm: int = _ghost_rhythm(best)
		var better: bool = rhythm > best_rhythm if spy.spy_criterion == OpportunityDef.SpyCriterion.PIU_LENTO else rhythm < best_rhythm
		if better or (rhythm == best_rhythm and index > best):
			best = index
	return best


## Ricarica di una truppa o intervallo di un edificio del fantasma.
func _ghost_rhythm(index: int) -> int:
	if index >= BattleSim.TROOP_INDEX_OFFSET:
		return current_ghost.troops[index - BattleSim.TROOP_INDEX_OFFSET].cooldown_ms
	return current_ghost.buildings[index].mana_interval_ms


func _ghost_element_name(index: int) -> String:
	if current_ghost == null:
		return "?"
	if index >= BattleSim.TROOP_INDEX_OFFSET:
		return current_ghost.troops[index - BattleSim.TROOP_INDEX_OFFSET].display_name
	return current_ghost.buildings[index].display_name


## Testo di ciò che si riceve da uno scambio, es. "3 Oro e 2 Cibo".
static func _gain_text(opportunity: OpportunityDef) -> String:
	var parts: PackedStringArray = PackedStringArray()
	if opportunity.gain_gold > 0:
		parts.append("%d Oro" % opportunity.gain_gold)
	if opportunity.gain_research > 0:
		parts.append("%d Ricerca" % opportunity.gain_research)
	if opportunity.gain_resources != null and not opportunity.gain_resources.is_empty():
		parts.append(opportunity.gain_resources.describe())
	if opportunity.malcontent_change != 0:
		parts.append("%+d Malcontento" % opportunity.malcontent_change)
	return " e ".join(parts) if not parts.is_empty() else "nulla"


@warning_ignore("integer_division")
static func _whole_seconds(milliseconds: int) -> int:
	return milliseconds / 1000


## Paga Oro e Ricerca di un'offerta, se bastano.
func _pay(offer: Offer) -> bool:
	if not can_afford(offer):
		return _fail("Risorse insufficienti (servono %s)." % offer.cost_text())
	gold -= offer.price
	research -= offer.research_price
	if offer.other_cost != null:
		for type: Res.Type in Res.NAMES:
			stock[type] -= offer.other_cost.internal(type)
	return true


## Mette un edificio sulla plancia, in uno spazio libero o al posto di un altro.
## price: Oro da pagare adesso. value: valore su cui si calcolerà il rimborso della vendita.
## La sostituzione equivale a vendere e costruire (GDD §6.4): il rimborso conta per il pagamento.
func _place_building(def: BuildingDef, price: int, value: int, replace_index: int) -> bool:
	if board.can_add_building(def) and replace_index < 0:
		if gold < price:
			return _fail("Oro insufficiente.")
		gold -= price
		board.buildings.append(BoardPiece.of_building(def, value))
		_log("Costruito: %s." % def.display_name)
		return true
	if replace_index < 0:
		return _fail("Plancia piena: scegli un edificio da sostituire.")
	if replace_index < board.buildings.size() and board.buildings[replace_index].building.is_capital:
		return _fail("La Capitale non si può sostituire.")
	if not board.can_replace_building(replace_index, def):
		return _fail("Sostituzione non possibile: lascerebbe tessere senza spazio.")
	var old_piece: BoardPiece = board.buildings[replace_index]
	var refund: int = half_down(old_piece.paid)
	if gold + refund < price:
		return _fail("Oro insufficiente.")
	gold += refund - price
	board.buildings[replace_index] = BoardPiece.of_building(def, value)
	_prune_modifiers()
	_log("%s sostituisce %s (rimborso %d Oro)." % [def.display_name, old_piece.display_name(), refund])
	return true


func _place_troop(def: TroopDef, price: int, value: int, replace_index: int) -> bool:
	if board.has_free_troop_slot() and replace_index < 0:
		if gold < price:
			return _fail("Oro insufficiente.")
		gold -= price
		board.troops.append(BoardPiece.of_troop(def, value))
		_log("Reclutato: %s." % def.display_name)
		return true
	if replace_index < 0:
		return _fail("Plancia piena: scegli una truppa da sostituire.")
	if replace_index >= board.troops.size():
		return _fail("Truppa da sostituire non valida.")
	var old_piece: BoardPiece = board.troops[replace_index]
	var refund: int = half_down(old_piece.paid)
	if gold + refund < price:
		return _fail("Oro insufficiente.")
	gold += refund - price
	board.troops[replace_index] = BoardPiece.of_troop(def, value)
	_prune_modifiers()
	_log("%s sostituisce %s (rimborso %d Oro)." % [def.display_name, old_piece.display_name(), refund])
	return true


## Rimborso della vendita: metà del prezzo pagato, per difetto (GDD §6.4).
func _refund(piece: BoardPiece) -> void:
	var refund: int = half_down(piece.paid)
	gold += refund
	_log("Venduto: %s (rimborso %d Oro)." % [piece.display_name(), refund])


func _fight(kind: BattleKind, opponent_name: String, enemy: BattleSideSetup) -> BattleSim.Outcome:
	var player: BattleSideSetup = BattleSideSetup.new(_battle_buildings(), _battle_troops(), player_resistance())
	_apply_start_values(player, modifiers)
	_apply_battle_rules(player, identity)
	_last_setups = [player, enemy]
	last_battle_seed = run_seed * 7919 + year * 104729 + int(season) * 31 + int(kind)
	last_battle = BattleSim.new(battle_rules, player, enemy, last_battle_seed)
	last_battle_kind = kind
	last_opponent_name = opponent_name
	var outcome: BattleSim.Outcome = last_battle.run_to_end()
	if outcome == BattleSim.Outcome.INTERROTTA:
		push_warning("RunState: scontro interrotto per il limite di sicurezza, trattato come pareggio.")
	# Per le cronache (GDD §9.6): vittorie di fila ed esito dell'ultimo scontro.
	if _player_won_or_drew(outcome):
		win_streak += 1
		last_battle_result = 1
	else:
		win_streak = 0
		last_battle_result = 0
	return outcome


## Malus del fantasma dopo una sconfitta o un pareggio (GDD §11.1), con il suo nome come origine.
func _apply_ghost_malus(ghost_name: String) -> void:
	if current_ghost == null:
		return
	for def: ModifierDef in current_ghost.malus:
		_log(modifiers.apply(def, ActiveModifier.OriginKind.FANTASMA, ghost_name, year, board, _rng))
		_change_malcontent(run_rules.malcontent_per_malus, IdentityDef.Grievance.MALUS, def.display_name)


## Toglie i modificatori di elementi che non sono più sulla plancia.
func _prune_modifiers() -> void:
	for message: String in modifiers.prune(board):
		_log(message)


func _battle_buildings() -> Array[BuildingDef]:
	var defs: Array[BuildingDef] = []
	for piece: BoardPiece in board.buildings:
		defs.append(effective_building(piece))
	return defs


func _battle_troops() -> Array[TroopDef]:
	var defs: Array[TroopDef] = []
	for piece: BoardPiece in board.troops:
		defs.append(effective_troop(piece))
	return defs


## Aggiorna Prestigio, vittorie ed era dell'ultimo anno registrato.
func _update_last_record() -> void:
	if history.is_empty():
		return
	history[-1].prestige_after = prestige
	history[-1].wins_after = wins
	history[-1].era = era


static func _outcome_word(outcome: BattleSim.Outcome) -> String:
	match outcome:
		BattleSim.Outcome.VITTORIA_A:
			return "Vittoria"
		BattleSim.Outcome.VITTORIA_B:
			return "Sconfitta"
		BattleSim.Outcome.PAREGGIO:
			return "Pareggio"
	return "Interrotto"


func _player_won_or_drew(outcome: BattleSim.Outcome) -> bool:
	return outcome == BattleSim.Outcome.VITTORIA_A \
		or outcome == BattleSim.Outcome.PAREGGIO \
		or outcome == BattleSim.Outcome.INTERROTTA


## Fantasma dell'anno: quello scritto nei dati, altrimenti uno generato (GDD §11.3).
func _ghost_for_year(target_year: int) -> GhostDef:
	var best: GhostDef = null
	for ghost: GhostDef in catalog.ghosts:
		if ghost.year == target_year:
			return ghost
		if ghost.year < target_year and (best == null or ghost.year > best.year):
			best = ghost
	if catalog.generator != null:
		return OpponentGenerator.generate_ghost(catalog, catalog.generator, run_rules, target_year, run_seed)
	if best != null:
		push_warning("RunState: nessun fantasma per l'anno %d, uso quello dell'anno %d." % [target_year, best.year])
	return best


## Incontri dell'anno: quelli scritti nei dati, completati fino a 3 con incontri generati (GDD §3.3).
## I 3 incontri fra cui scegliere a fine primavera (season_index 0) o a fine estate (1): quelli scritti
## nei dati per quell'anno e quella stagione, completati dal generatore. Quelli d'estate sono
## generati più forti, a metà strada fra quest'anno e il prossimo (GDD §3.3, §16.3).
func _encounters_for(target_year: int, season_index: int) -> Array[EncounterDef]:
	var found: Array[EncounterDef] = []
	for encounter: EncounterDef in catalog.encounters:
		if encounter.year == target_year and encounter.season == season_index and found.size() < 3:
			found.append(encounter)
	if found.size() < 3 and catalog.generator != null:
		found.append_array(OpponentGenerator.generate_encounters(catalog, catalog.generator, run_rules,
				target_year, run_seed, 3 - found.size(), found.size(), season_index == 1))
	return found


func _end_run(result: RunEnd) -> void:
	run_end = result
	_update_last_record()
	phase = Phase.FINE_RUN
	offers = []
	match result:
		RunEnd.VITTORIA:
			_log("La nazione ha raggiunto %d vittorie: partita vinta!" % wins)
		RunEnd.SCONFITTA:
			_log("La partita è finita con una sconfitta.")
		RunEnd.FINE_PROVA:
			_log("Fine della partita di prova dopo %d anni." % year)


func _require_shopping() -> bool:
	if not is_shopping_phase():
		return _fail("Questa azione è possibile solo durante i round del Consiglio.")
	if not way_choices.is_empty():
		return _fail("Prima scegli la via della nazione.")
	if not government_choices.is_empty():
		return _fail("Prima decidi se far evolvere il governo.")
	if not ascension_choices.is_empty():
		return _fail("Prima scegli l'ascensione della nazione.")
	return true


# --- Vie delle ere (GDD §10.4) -----------------------------------------------------

## Sceglie una delle vie proposte: diventa parte dell'identità, con il suo bonus immediato.
func choose_way(index: int) -> bool:
	if index < 0 or index >= way_choices.size():
		return _fail("Via non valida.")
	var way: IdentityDef = way_choices[index]
	way_choices = []
	_adopt_identity(way)
	# La via arriva entrando in un'era: la mano si ripesca gratis con le nuove tecnologie.
	_draw_tech_hand()
	# Le imprese di stato già vere si completano subito (GDD §10.4.1).
	_check_traditions()
	# Le proposte in corso tengono conto della via appena scelta.
	_redraw_round()
	return true


# --- Malcontento e Rivoluzione (GDD §5.5, §9.4.2; v0.24) ----------------------------

## Il Malcontento sale (amount > 0) per una causa, o scende (amount < 0); mai sotto zero.
func _change_malcontent(amount: int, cause: IdentityDef.Grievance, reason: String) -> void:
	if amount == 0:
		return
	var before: int = malcontent
	malcontent = maxi(0, malcontent + amount)
	# Vocazione Stato di polizia (GDD §9.6, v0.29): il Malcontento non supera la soglia di avviso.
	if has_rule(IdentityDef.Rule.STATO_DI_POLIZIA):
		malcontent = mini(malcontent, maxi(before, run_rules.malcontent_warning))
	if amount > 0:
		malcontent_sources[cause] = malcontent_sources.get(cause, 0) + amount
	_log("%s: Malcontento %s %d (ora %d su %d)." % [reason, "+" if amount > 0 else "−", absi(malcontent - before), malcontent, run_rules.malcontent_threshold])
	if amount > 0 and malcontent >= run_rules.malcontent_warning and before < run_rules.malcontent_warning:
		_log("Attenzione: la rivoluzione si avvicina.")


## Causa che ha prodotto più Malcontento dall'ultima rivoluzione (a parità, la prima dell'elenco).
func main_grievance() -> IdentityDef.Grievance:
	var best: IdentityDef.Grievance = IdentityDef.Grievance.SCONFITTE
	var best_amount: int = -1
	for cause: IdentityDef.Grievance in IdentityDef.GRIEVANCE_NAMES:
		var amount: int = malcontent_sources.get(cause, 0)
		if amount > best_amount:
			best = cause
			best_amount = amount
	return best


## Vero se questo round mostra solo la Rivoluzione.
func is_revolution_round() -> bool:
	return event_choice != null and event_choice.special == EventDef.Special.RIVOLUZIONE


## Governi a cui può portare la Rivoluzione (GDD §9.4.2): quelli legati alla causa principale,
## di qualunque tier, tranne quello attuale. Se nessuno è legato alla causa, i governi del tier 1.
func revolution_targets() -> Array[IdentityDef]:
	var cause: IdentityDef.Grievance = main_grievance()
	var current: IdentityDef = government()
	var found: Array[IdentityDef] = []
	for def: IdentityDef in catalog.identities:
		if def.dimension == IdentityDef.Dimension.GOVERNO and def != current and def.revolution_causes.has(cause):
			found.append(def)
	if found.is_empty():
		for def: IdentityDef in catalog.identities:
			if def.dimension == IdentityDef.Dimension.GOVERNO and def != current and def.tier == 1:
				found.append(def)
	return found


func _revolution_event() -> EventDef:
	for event: EventDef in catalog.events:
		if event.special == EventDef.Special.RIVOLUZIONE:
			return event
	return null


# --- Governi a tier (GDD §9.4, v0.24) ------------------------------------------------

## Il governo attuale della nazione (null prima della creazione).
func government() -> IdentityDef:
	for def: IdentityDef in identity:
		if def.dimension == IdentityDef.Dimension.GOVERNO:
			return def
	return null


## Governi del tier successivo a cui il governo attuale può evolvere.
func evolution_targets() -> Array[IdentityDef]:
	var found: Array[IdentityDef] = []
	var current: IdentityDef = government()
	if current == null:
		return found
	for target: Resource in current.evolves_to:
		if target is IdentityDef:
			found.append(target as IdentityDef)
	return found


## Evolve al governo proposto entrando nell'era (si può scegliere anche durante la scelta della via).
func choose_government(index: int) -> bool:
	if index < 0 or index >= government_choices.size():
		return _fail("Governo non valido.")
	var target: IdentityDef = government_choices[index]
	government_choices = []
	_change_government(target, "Evoluzione")
	_redraw_round()
	return true


## Rifiuta l'evoluzione proposta: il governo resta com'è.
func refuse_evolution() -> bool:
	if government_choices.is_empty():
		return _fail("Non c'è nessuna evoluzione da rifiutare.")
	government_choices = []
	_log("Il governo resta %s." % government().display_name)
	return true


## Cambia il governo: finisce il tratto del vecchio e vale quello nuovo, con i suoi effetti sul
## Consiglio e la sua risorsa della Capitale. Gli elementi sulla plancia restano (GDD §9.4).
func _change_government(target: IdentityDef, source: String) -> void:
	var old: IdentityDef = government()
	if old == target:
		return
	if old != null:
		identity.erase(old)
		for active_modifier: ActiveModifier in modifiers.active.duplicate():
			if active_modifier.origin_kind == ActiveModifier.OriginKind.IDENTITA and active_modifier.origin_name == old.display_name \
					and old.permanent_modifiers.has(active_modifier.def):
				modifiers.active.erase(active_modifier)
	_log("%s: il governo passa da %s a %s." % [source, old.display_name if old != null else "nessuno", target.display_name])
	_adopt_identity(target)


## Durata di uno spionaggio, con quella in più data dal governo (GDD §9.4, v0.24).
func spy_duration(spy: OpportunityDef) -> int:
	return maxi(0, spy.spy_ms + _identity_int(&"spy_ms_change"))


## Tre vie pescate dal pool dell'era, pesate da identità e vie già scelte (§16.3).
func _draw_ways(era_def: EraDef) -> Array[IdentityDef]:
	var pool: Array[IdentityDef] = []
	var weights: Array[int] = []
	for way: IdentityDef in era_def.ways:
		if identity.has(way):
			continue
		if not way.requires_any.is_empty():
			var allowed: bool = false
			for needed: Resource in way.requires_any:
				if identity.has(needed):
					allowed = true
			if not allowed:
				continue
		var weight: int = 1
		for element: IdentityDef in identity:
			if way.favored_by.has(element):
				weight += 1
		pool.append(way)
		weights.append(weight)
	var picked: Array[IdentityDef] = []
	for i: int in range(mini(3, pool.size())):
		var total: int = 0
		for weight: int in weights:
			total += weight
		var roll: int = _rng.randi_range(0, total - 1)
		var pick: int = 0
		while roll >= weights[pick]:
			roll -= weights[pick]
			pick += 1
		picked.append(pool[pick])
		pool.remove_at(pick)
		weights.remove_at(pick)
	return picked


func _require_not_over() -> bool:
	if is_over():
		return _fail("La partita è finita.")
	if phase == Phase.CREAZIONE_NAZIONE:
		return _fail("Prima crea la nazione.")
	return true


## Adotta un elemento dell'identità: dotazione, tratto permanente e, implicitamente,
## Resistenza, opportunità ed elementi esclusivi (letti da identity quando servono).
func _adopt_identity(def: IdentityDef) -> void:
	identity.append(def)
	_log("%s: %s." % [IdentityDef.DIMENSION_NAMES[def.dimension], def.display_name])
	gold += def.extra_gold
	research += def.extra_research
	if def.extra_resources != null:
		for type: Res.Type in Res.NAMES:
			stock[type] += def.extra_resources.internal(type)
	board.base_building_slots += def.extra_building_slots
	board.base_troop_slots += def.extra_troop_slots
	for building: BuildingDef in def.extra_buildings:
		if board.can_add_building(building):
			board.buildings.append(BoardPiece.of_building(building, 0))
		else:
			_log("Nessuno spazio per %s." % building.display_name)
	for troop: TroopDef in def.extra_troops:
		if board.has_free_troop_slot():
			board.troops.append(BoardPiece.of_troop(troop, 0))
		else:
			_log("Nessuno spazio per %s." % troop.display_name)
	for modifier: ModifierDef in def.permanent_modifiers:
		_log(modifiers.apply(modifier, ActiveModifier.OriginKind.IDENTITA, def.display_name, year, board, _rng))
	_flow_research()


## Somma di un effetto numerico della scheda fra tutti gli elementi dell'identità (GDD §9.2).
func _identity_int(property: StringName) -> int:
	var total: int = 0
	for def: IdentityDef in identity:
		total += int(def.get(property))
	return total


## Consiglieri per round: quelli delle regole, più o meno quelli del governo (almeno 1).
func advisors_per_round() -> int:
	return maxi(1, run_rules.advisors_per_round + _identity_int(&"advisors_change"))


func _has_court() -> bool:
	if _identity_int(&"court_advisor_weight") > 0:
		return true
	for def: IdentityDef in identity:
		if def.court_advisor_always:
			return true
	return false


## Consiglieri che compaiono sempre: quelli indicati dall'identità e il consigliere di corte,
## se il governo lo vuole sempre presente.
func _mandatory_advisors() -> Array[AdvisorDef]:
	var found: Array[AdvisorDef] = []
	for def: IdentityDef in identity:
		if def.always_present_advisor != null and not found.has(def.always_present_advisor):
			found.append(def.always_present_advisor)
		if def.court_advisor_always and court_advisor != null and not found.has(court_advisor):
			found.append(court_advisor)
	return found


func _excluded_advisors() -> Array[AdvisorDef]:
	var found: Array[AdvisorDef] = []
	for def: IdentityDef in identity:
		found.append_array(def.excluded_advisors)
	return found


static func _identity_resistance(elements: Array[IdentityDef]) -> int:
	var total: int = 0
	for def: IdentityDef in elements:
		total += def.resistance_bonus
	return total


## Modificatori permanenti di un'identità, per una nazione che non è il giocatore (es. un fantasma).
func _identity_modifiers(elements: Array[IdentityDef]) -> Modifiers:
	var result: Modifiers = Modifiers.new()
	var empty_board: NationBoard = NationBoard.new()
	for def: IdentityDef in elements:
		for modifier: ModifierDef in def.permanent_modifiers:
			if modifier.target == ModifierDef.Target.NAZIONE:
				result.apply(modifier, ActiveModifier.OriginKind.IDENTITA, def.display_name, year, empty_board, _rng)
	return result


## Tratti del fantasma: quelli della sua identità più le sue tecnologie, solo su tutta la nazione.
func _ghost_modifiers() -> Modifiers:
	var result: Modifiers = _identity_modifiers(current_ghost.identity)
	var empty_board: NationBoard = NationBoard.new()
	for tradition: TraditionDef in current_ghost.traditions:
		for modifier: ModifierDef in tradition.permanent_modifiers:
			if modifier.target == ModifierDef.Target.NAZIONE:
				result.apply(modifier, ActiveModifier.OriginKind.TRADIZIONE, tradition.display_name, year, empty_board, _rng)
	for tech: TechDef in current_ghost.technologies:
		var mods: Array[ModifierDef] = tech.permanent_modifiers.duplicate()
		if tech.perk != null:
			mods.append_array(tech.perk.permanent_modifiers)
		for modifier: ModifierDef in mods:
			if modifier.target == ModifierDef.Target.NAZIONE:
				result.apply(modifier, ActiveModifier.OriginKind.TECNOLOGIA, tech.display_name, year, empty_board, _rng)
	return result


## Il fantasma come entra in battaglia: con la Resistenza e i tratti della sua identità.
func _ghost_setup() -> BattleSideSetup:
	var ghost_modifiers: Modifiers = _ghost_modifiers()
	var buildings: Array[BuildingDef] = []
	for def: BuildingDef in current_ghost.buildings:
		buildings.append(ElementStats.building(def, BoardPiece.of_building(def, 0), ghost_modifiers, 1, run_rules))
	var troops: Array[TroopDef] = []
	for def: TroopDef in current_ghost.troops:
		troops.append(ElementStats.troop(def, BoardPiece.of_troop(def, 0), ghost_modifiers, 1, run_rules))
	var setup: BattleSideSetup = BattleSideSetup.new(buildings, troops, ghost_resistance())
	_apply_battle_rules(setup, current_ghost.identity)
	_apply_start_values(setup, ghost_modifiers)
	return setup


## Valori di partenza dello scontro cambiati dai modificatori (GDD §8.2, v0.16).
static func _apply_start_values(setup: BattleSideSetup, mods: Modifiers) -> void:
	setup.start_shield = maxi(0, mods.flat(ModifierDef.Effect.SCUDO_INIZIALE))
	setup.start_corruption = maxi(0, mods.flat(ModifierDef.Effect.CORRUZIONE_INIZIALE))
	setup.start_building_sabotage_ms = maxi(0, mods.flat(ModifierDef.Effect.SABOTAGGIO_INIZIALE))


## Metà di un numero intero, arrotondata per difetto (per numeri non negativi).
@warning_ignore("integer_division")
static func half_down(value: int) -> int:
	return value / 2


func _fail(message: String) -> bool:
	last_error = message
	return false


func _log(message: String) -> void:
	chronicle.append(message)
