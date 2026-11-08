extends GutTest
## Simboli sulle carte: le righe devono dire esattamente quello che dicono i dati
## (costo → effetto), senza inventare niente. Si leggono come testo con RigaSimboli.come_testo().

const Aiuti = preload("res://tests/sim/aiuti_consiglio.gd")

var catalog: CatalogDef
var rules: RunRules
var farm: BuildingDef
var soldier: TroopDef


func before_each() -> void:
	farm = BuildingDef.new()
	farm.id = &"fattoria"
	farm.display_name = "Fattoria"
	farm.types = [&"Produzione"]
	farm.mana_interval_ms = 1000
	soldier = TroopDef.new()
	soldier.id = &"fanti"
	soldier.display_name = "Fanti"
	soldier.types = [&"Fante"]
	soldier.cooldown_ms = 2000
	catalog = CatalogDef.new()
	catalog.buildings = [farm]
	catalog.troops = [soldier]
	catalog.eras = [EraDef.new(), EraDef.new()]
	catalog.advisors = [Aiuti.consigliere(&"base", [&"Produzione"])]
	rules = RunRules.new()
	rules.starting_gold = 20
	rules.prototype_years = 0
	rules.starting_buildings = [farm]
	rules.starting_troops = [soldier]
	rules.special_card_chance_percent = 0
	rules.advisors_per_round = 1


func _run() -> RunState:
	var resistance: ResistanceRules = ResistanceRules.new()
	resistance.per_era = [10, 10]
	return RunState.new(catalog, rules, BattleRules.new(), resistance, 3)


## Un'azione del catalogo come la proporrebbe un consigliere, senza sconti.
func _offerta(percorso: String) -> Offer:
	var def: OpportunityDef = load(percorso) as OpportunityDef
	var offerta: Offer = Offer.new()
	offerta.opportunity = def
	offerta.kind = def.kind
	offerta.price = def.cost_gold
	offerta.research_price = def.cost_research
	offerta.other_cost = def.cost_resources
	return offerta


func _quantita(valori: Dictionary) -> ResourceAmounts:
	var quantita: ResourceAmounts = ResourceAmounts.new()
	for chiave: String in valori:
		quantita.set(chiave, valori[chiave])
	return quantita


# --- Azioni del catalogo ---------------------------------------------------------

func test_scambio_di_risorse_costo_freccia_guadagno() -> void:
	var riga: RigaSimboli = SimboliEffetti.azione(_offerta("res://data/catalog/opportunities/decreto_fiscale.tres"))
	assert_eq(riga.come_testo(), "2[stabilita] → +4[oro]")


func test_azione_gratuita_senza_freccia() -> void:
	var riga: RigaSimboli = SimboliEffetti.azione(_offerta("res://data/catalog/opportunities/esattori.tres"))
	assert_eq(riga.come_testo(), "+3[oro]")


func test_modificatori_a_scelta_con_la_stessa_durata() -> void:
	var riga: RigaSimboli = SimboliEffetti.azione(_offerta("res://data/catalog/opportunities/assemblea.tres"))
	assert_eq(riga.come_testo(), "1[anno] +50%[oro] / +50%[ricerca]")


func test_modificatore_su_una_truppa_scelta() -> void:
	var riga: RigaSimboli = SimboliEffetti.azione(_offerta("res://data/catalog/opportunities/addestramento.tres"))
	assert_eq(riga.come_testo(), "2[ferro] → 1[anno] [truppa] −25%[ricarica]")


func test_modificatore_fino_al_prossimo_fantasma() -> void:
	var riga: RigaSimboli = SimboliEffetti.azione(_offerta("res://data/catalog/opportunities/fortificazioni.tres"))
	assert_eq(riga.come_testo(), "2[pietra] → [fantasma] : +10[resistenza]")


func test_spazio_in_oro() -> void:
	var riga: RigaSimboli = SimboliEffetti.azione(_offerta("res://data/catalog/opportunities/architetti.tres"))
	assert_eq(riga.come_testo(), "6[oro] → +1[spazio edificio]")


func test_malcontento_che_scende() -> void:
	var riga: RigaSimboli = SimboliEffetti.azione(_offerta("res://data/catalog/opportunities/ordine_pubblico.tres"))
	assert_eq(riga.come_testo(), "2[stabilita] → −3[malcontento]")


func test_spionaggio_sul_fantasma() -> void:
	var riga: RigaSimboli = SimboliEffetti.azione(_offerta("res://data/catalog/opportunities/spia_inefficienza_caso.tres"))
	assert_eq(riga.come_testo(), "2[documenti] → [fantasma] : [caso] [edificio] / [truppa] 10s[inefficienza]")


func test_ogni_azione_del_catalogo_ha_una_riga() -> void:
	var cartella: DirAccess = DirAccess.open("res://data/catalog/opportunities/")
	assert_not_null(cartella)
	for file: String in cartella.get_files():
		if not file.ends_with(".tres"):
			continue
		var def: OpportunityDef = load("res://data/catalog/opportunities/" + file) as OpportunityDef
		if def == null or def.kind in [OpportunityDef.Kind.COSTRUISCI_EDIFICIO, OpportunityDef.Kind.RECLUTA_TRUPPA]:
			continue
		assert_false(SimboliEffetti.effetto_azione(def).vuota(), "%s deve avere almeno un simbolo di effetto." % file)


# --- Opzioni degli eventi --------------------------------------------------------

func test_opzione_costo_guadagno_e_malcontento_in_una_riga() -> void:
	var opzione: EventOptionDef = EventOptionDef.new()
	opzione.label = "Offri"
	opzione.cost = _quantita({"fede": 1})
	opzione.gain = _quantita({"oro": 2})
	opzione.malcontent_change = -1
	var righe: Array[RigaSimboli] = SimboliEffetti.opzione_righe(opzione, 1)
	assert_eq(righe.size(), 1)
	assert_eq(righe[0].come_testo(), "1[fede] → +2[oro] · −1[malcontento]")


func test_fortuna_che_cresce_con_l_era() -> void:
	var opzione: EventOptionDef = EventOptionDef.new()
	opzione.gain = _quantita({"oro": 2})
	assert_eq(SimboliEffetti.opzione_in_una_riga(opzione, 2).come_testo(), "+4[oro]")


func test_opzione_senza_effetti() -> void:
	var opzione: EventOptionDef = EventOptionDef.new()
	assert_eq(SimboliEffetti.opzione_in_una_riga(opzione, 1).come_testo(), "—")


func test_opzione_con_potenziamento_e_spazio() -> void:
	var opzione: EventOptionDef = EventOptionDef.new()
	opzione.upgrade = true
	opzione.upgrade_kind = EventOptionDef.PieceKind.TRUPPA
	opzione.extra_troop_slots = 1
	assert_eq(SimboliEffetti.opzione_in_una_riga(opzione, 1).come_testo(), "[truppa↑] · +1[spazio truppa]")


func test_opzione_bloccata_sulla_carta_dell_evento() -> void:
	var richiesta: IdentityDef = IdentityDef.new()
	richiesta.id = &"credo_mancante"
	richiesta.display_name = "Credo mancante"
	var bloccata: EventOptionDef = EventOptionDef.new()
	bloccata.requires_identity = [richiesta]
	bloccata.gain = _quantita({"fede": 2})
	var libera: EventOptionDef = EventOptionDef.new()
	libera.gain = _quantita({"oro": 1})
	var evento: EventDef = EventDef.new()
	evento.id = &"prova"
	evento.options = [bloccata, libera]
	var righe: Array[RigaSimboli] = SimboliEffetti.evento(_run(), evento)
	assert_eq(righe.size(), 2)
	assert_true(righe[0].spenta)
	assert_eq(righe[0].come_testo(), "[bloccato] +2[fede]")
	assert_false(righe[1].spenta)


# --- Consiglieri ----------------------------------------------------------------

func test_consigliere_in_un_round_di_azioni() -> void:
	var decreto: OpportunityDef = load("res://data/catalog/opportunities/decreto_fiscale.tres") as OpportunityDef
	var cancelliere: AdvisorDef = Aiuti.consigliere(&"cancelliere", [&"Produzione", &"Fante"], [decreto], Res.Type.STABILITA)
	catalog.advisors = [cancelliere]
	var run: RunState = _run()
	run.round_theme = RunState.RoundTheme.AZIONI
	var righe: Array[RigaSimboli] = SimboliEffetti.consigliere(run, cancelliere)
	assert_eq(righe.size(), 2, "Potenzia e l'unica azione: niente edifici o truppe in un round di Azioni.")
	assert_eq(righe[0].come_testo(), "[azione] : [scambio]", "Una riga sola con i tipi di azione, senza numeri.")
	assert_eq(righe[1].come_testo(), "[potenzia] : [stabilita]", "Il Potenzia va in fondo: è un extra.")
	assert_eq(righe[1].rilievo, RigaSimboli.Rilievo.SECONDARIA)


func test_consigliere_in_un_round_misto_propone_anche_carte() -> void:
	var decreto: OpportunityDef = load("res://data/catalog/opportunities/decreto_fiscale.tres") as OpportunityDef
	var cancelliere: AdvisorDef = Aiuti.consigliere(&"cancelliere", [&"Produzione", &"Fante"], [decreto], Res.Type.STABILITA)
	catalog.advisors = [cancelliere]
	var run: RunState = _run()
	run.round_theme = RunState.RoundTheme.MISTO
	var righe: Array[RigaSimboli] = SimboliEffetti.consigliere(run, cancelliere)
	assert_eq(righe.size(), 3)
	assert_eq(righe[0].come_testo(), "[proposta] : [edificio] / [truppa]", "Prima ciò che propone.")
	assert_eq(righe[0].rilievo, RigaSimboli.Rilievo.PRINCIPALE)
	assert_eq(righe[1].come_testo(), "[azione] : [scambio]")
	assert_eq(righe[2].come_testo(), "[potenzia] : [stabilita]")


func test_consigliere_in_un_round_di_edifici_non_mostra_azioni() -> void:
	var decreto: OpportunityDef = load("res://data/catalog/opportunities/decreto_fiscale.tres") as OpportunityDef
	var cancelliere: AdvisorDef = Aiuti.consigliere(&"cancelliere", [&"Produzione", &"Fante"], [decreto], Res.Type.STABILITA)
	catalog.advisors = [cancelliere]
	var run: RunState = _run()
	run.round_theme = RunState.RoundTheme.EDIFICI
	var righe: Array[RigaSimboli] = SimboliEffetti.consigliere(run, cancelliere)
	assert_eq(righe.size(), 2)
	assert_eq(righe[0].come_testo(), "[proposta] : [edificio]")
	assert_eq(righe[1].come_testo(), "[potenzia] : [stabilita]")


func test_la_riga_azioni_mostra_ogni_tipo_una_volta() -> void:
	var azioni: Array[Offer] = []
	for nome: String in ["incanto_danno", "incanto_scudo", "spia_sabotaggio_veloce", "veleno_nei_pozzi", "decreto_fiscale", "studiosi", "assemblea", "quartiermastro", "ordine_pubblico"]:
		azioni.append(_offerta("res://data/catalog/opportunities/%s.tres" % nome))
	var riga: RigaSimboli = SimboliEffetti.riga_azioni(azioni)
	assert_eq(riga.come_testo(), "[azione] : [incanto] [spia] [scambio] [anno] [spazio truppa] [malcontento]")
	assert_true(SimboliEffetti.riga_azioni([]).vuota(), "Senza azioni possibili la riga non c'è.")


func test_ogni_azione_del_catalogo_ha_un_tipo() -> void:
	var cartella: DirAccess = DirAccess.open("res://data/catalog/opportunities/")
	for file: String in cartella.get_files():
		if not file.ends_with(".tres"):
			continue
		var def: OpportunityDef = load("res://data/catalog/opportunities/" + file) as OpportunityDef
		if def == null or def.kind in [OpportunityDef.Kind.COSTRUISCI_EDIFICIO, OpportunityDef.Kind.RECLUTA_TRUPPA]:
			continue
		assert_ne(SimboliEffetti.tipo_di_azione(def).come_testo(), "[azione]", "%s deve avere il simbolo del suo tipo." % file)


# --- Sotto la carta del consigliere -----------------------------------------------

func test_sotto_il_consigliere_si_vede_quante_carte_puoi_potenziare() -> void:
	var cancelliere: AdvisorDef = Aiuti.consigliere(&"cancelliere", [&"Produzione", &"Fante"], [], Res.Type.STABILITA)
	catalog.advisors = [cancelliere]
	var run: RunState = _run()
	assert_eq(SchedaCarta.da_consigliere(run, cancelliere).costo, "Ascolta", "Senza Stabilità non si può potenziare nulla.")
	run.stock[Res.Type.STABILITA] = 100
	var pronte: int = run.affordable_upgrades(cancelliere).size()
	assert_gt(pronte, 0, "La Fattoria e i Fanti sono dei tipi del consigliere.")
	assert_eq(SchedaCarta.da_consigliere(run, cancelliere).costo, "Ascolta · ▲ Potenzia %d" % pronte)
	var righe: Array[RigaSimboli] = SimboliEffetti.consigliere(run, cancelliere)
	assert_true(righe[righe.size() - 1].accesa, "La riga del Potenzia si accende.")


# --- Legenda ----------------------------------------------------------------------

func test_la_legenda_trova_gli_esempi_nel_catalogo() -> void:
	var legenda: LegendaSimboli = LegendaSimboli.new()
	add_child_autofree(legenda)
	var catalogo: CatalogDef = load("res://data/catalog/catalog.tres") as CatalogDef
	assert_eq(legenda._esempi(catalogo).size(), 11, "5 esempi dalle carte vere e 6 scritti apposta.")
	legenda.costruisci(catalogo)
	assert_eq(legenda.get_child_count(), 1)


func test_ogni_simbolo_della_legenda_ha_un_nome_e_un_file() -> void:
	for gruppo: Array in LegendaSimboli.GRUPPI:
		for concetto: StringName in gruppo[1]:
			assert_true(LegendaSimboli.NOMI.has(concetto), "Manca il nome di %s." % concetto)
			assert_true(ResourceLoader.exists("res://assets/icone/%s.svg" % concetto), "Manca l'icona di %s." % concetto)


func test_i_dettagli_del_consigliere_dicono_solo_cio_che_si_vede() -> void:
	var decreto: OpportunityDef = load("res://data/catalog/opportunities/decreto_fiscale.tres") as OpportunityDef
	var cancelliere: AdvisorDef = Aiuti.consigliere(&"cancelliere", [&"Produzione", &"Fante"], [decreto], Res.Type.STABILITA)
	catalog.advisors = [cancelliere]
	var run: RunState = _run()
	run.round_theme = RunState.RoundTheme.MISTO
	var scheda: SchedaCarta = SchedaCarta.da_consigliere(run, cancelliere)
	var righe: PackedStringArray = scheda.dettagli.split("\n")
	assert_eq(righe.size(), scheda.simboli.size(), "Una frase per ogni riga di simboli.")
	assert_eq(righe[0], "Propone: edifici e truppe.")
	assert_eq(righe[1], "Azioni possibili: scambi di risorse.")
	assert_string_starts_with(righe[2], "Potenzia: fa salire di livello una tua carta dei suoi tipi, pagando Stabilità.")
	assert_false(scheda.dettagli.contains("Decreto fiscale"), "Niente elenco delle singole azioni: non si vedono sulla carta.")
