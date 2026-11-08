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
	assert_eq(righe[0].come_testo(), "[potenzia] : [stabilita]")
	assert_eq(righe[1].come_testo(), "2[stabilita] → +4[oro]")


func test_consigliere_in_un_round_misto_propone_anche_carte() -> void:
	var decreto: OpportunityDef = load("res://data/catalog/opportunities/decreto_fiscale.tres") as OpportunityDef
	var cancelliere: AdvisorDef = Aiuti.consigliere(&"cancelliere", [&"Produzione", &"Fante"], [decreto], Res.Type.STABILITA)
	catalog.advisors = [cancelliere]
	var run: RunState = _run()
	run.round_theme = RunState.RoundTheme.MISTO
	var righe: Array[RigaSimboli] = SimboliEffetti.consigliere(run, cancelliere)
	assert_eq(righe.size(), 3)
	assert_eq(righe[1].come_testo(), "[edificio] / [truppa]")


func test_consigliere_in_un_round_di_edifici_non_mostra_azioni() -> void:
	var decreto: OpportunityDef = load("res://data/catalog/opportunities/decreto_fiscale.tres") as OpportunityDef
	var cancelliere: AdvisorDef = Aiuti.consigliere(&"cancelliere", [&"Produzione", &"Fante"], [decreto], Res.Type.STABILITA)
	catalog.advisors = [cancelliere]
	var run: RunState = _run()
	run.round_theme = RunState.RoundTheme.EDIFICI
	var righe: Array[RigaSimboli] = SimboliEffetti.consigliere(run, cancelliere)
	assert_eq(righe.size(), 2)
	assert_eq(righe[1].come_testo(), "[edificio]")


func test_incanti_e_spionaggi_si_riuniscono_in_una_riga() -> void:
	var azioni: Array[Offer] = []
	for nome: String in ["incanto_danno", "incanto_scudo", "spia_sabotaggio_veloce", "rete_di_sabotatori", "veleno_nei_pozzi", "decreto_fiscale"]:
		azioni.append(_offerta("res://data/catalog/opportunities/%s.tres" % nome))
	var righe: Array[RigaSimboli] = SimboliEffetti.azioni_riunite(azioni)
	assert_eq(righe.size(), 3, "Incanti in una riga, spionaggi in una riga, decreto da solo.")
	assert_eq(righe[0].come_testo(), "2[fede] → [incanto] [truppa] +[danno] / [scudo] +2[gemma qualsiasi]")
	assert_eq(righe[1].come_testo(), "2/3[documenti] → [fantasma] : [sabotaggio] / [inefficienza]")
	assert_eq(righe[2].come_testo(), "2[stabilita] → +4[oro]")


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
	assert_true(SimboliEffetti.consigliere(run, cancelliere)[0].accesa, "La riga del Potenzia si accende.")
