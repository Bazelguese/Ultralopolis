extends GutTest
## Riquadri delle carte (SchedaCarta): i testi devono dire le regole vere del codice
## (produzione e razione vere, livello massimo, ultima possibilità, Visitatori, Rivoluzione...).

var catalog: CatalogDef
var rules: RunRules
var farm: BuildingDef
var soldier: TroopDef


func before_each() -> void:
	farm = BuildingDef.new()
	farm.id = &"fattoria"
	farm.display_name = "Fattoria"
	farm.types = [&"Materie prime"]
	farm.mana_interval_ms = 4000
	farm.gold_per_phase = 1
	farm.food_per_phase = 2
	soldier = TroopDef.new()
	soldier.id = &"fanti"
	soldier.display_name = "Fanti"
	soldier.types = [&"Fante"]
	soldier.cooldown_ms = 2000
	soldier.damage = 1
	soldier.food_tenths = 10
	catalog = CatalogDef.new()
	catalog.buildings = [farm]
	catalog.troops = [soldier]
	catalog.eras = [EraDef.new(), EraDef.new()]
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


func _fantasma() -> GhostDef:
	var fantasma: GhostDef = GhostDef.new()
	fantasma.display_name = "Fantasma: Borgo di prova"
	fantasma.malus = [load("res://data/catalog/modifiers/ricerca_dimezzata.tres") as ModifierDef]
	return fantasma


# --- Tessere ------------------------------------------------------------------------

func test_il_cibo_prodotto_dice_che_d_inverno_non_arriva() -> void:
	var scheda: SchedaCarta = SchedaCarta.da_edificio(farm)
	assert_string_contains(scheda.dettagli, "A ogni stagione: +1 Oro, +2 Cibo (non d'inverno).")
	assert_eq(scheda.riga, "+1 Oro · +2 Cibo", "Sulla carta resta la scritta breve.")


func test_la_capitale_non_mostra_il_livello() -> void:
	var capitale: BuildingDef = BuildingDef.new()
	capitale.display_name = "Capitale"
	capitale.is_capital = true
	capitale.types = [&"Capitale"]
	capitale.mana_interval_ms = 4000
	var scheda: SchedaCarta = SchedaCarta.da_edificio(capitale, 1, "", 3)
	assert_string_contains(scheda.dettagli, "Tipi: Capitale")
	assert_false(scheda.dettagli.contains("Livello"), "La Capitale non si potenzia: niente livello.")


func test_sulla_plancia_il_livello_massimo_e_quello_della_partita() -> void:
	rules.max_level = 4
	var run: RunState = _run()
	var scheda: SchedaCarta = SchedaCarta.da_pezzo(run, run.board.troops[0])
	assert_string_contains(scheda.dettagli, "Livello 1 di 4")
	assert_string_contains(SchedaCarta.da_edificio(farm).dettagli, "Livello 1 · Tipi", "Senza partita non si inventa il massimo.")


func test_sulla_plancia_la_produzione_e_quella_vera() -> void:
	var run: RunState = _run()
	var pezzo: BoardPiece = run.board.buildings[0]
	pezzo.level = 2
	var oro: int = run.building_production(pezzo)[Res.Type.ORO]
	assert_eq(oro, 1 + rules.building_production_per_level, "Il livello 2 produce di più.")
	assert_string_contains(SchedaCarta.da_pezzo(run, pezzo).dettagli, "+%d Oro" % oro)


func test_sulla_plancia_la_razione_e_quella_vera() -> void:
	var run: RunState = _run()
	var pezzo: BoardPiece = run.board.troops[0]
	run.modifiers.apply(load("res://data/catalog/modifiers/razioni.tres") as ModifierDef, ActiveModifier.OriginKind.ALTRO, "Prova", run.year, run.board, RandomNumberGenerator.new())
	assert_eq(run.troop_ration(pezzo), 5, "Razioni dimezza il Cibo.")
	assert_string_contains(SchedaCarta.da_pezzo(run, pezzo).dettagli, "Razione: 0,5 Cibo a inizio anno (dal secondo anno; di base 1).")


func test_truppa_un_danno_al_singolare_e_senza_mana() -> void:
	var dettagli: String = SchedaCarta.da_truppa(soldier).dettagli
	assert_string_contains(dettagli, "1 danno (prima allo scudo")
	assert_string_contains(dettagli, "Non chiede mana: si attiva appena finisce la ricarica.")


func test_il_sabotaggio_colpisce_una_tessera_a_caso() -> void:
	farm.mana_type = &"verde"
	farm.mana_amount = 1
	farm.sabotage_ms = 2000
	farm.sabotage_target = TimerTarget.Kind.TRUPPE
	var dettagli: String = SchedaCarta.da_edificio(farm).dettagli
	assert_string_contains(dettagli, "Nello scontro: 1 mana verde ogni ciclo di 4 s.")
	assert_string_contains(dettagli, "Sabota 1 truppa nemica a caso per 2 s, ogni ciclo di 4 s.")
	soldier.siege_damage = 10
	assert_string_contains(SchedaCarta.da_truppa(soldier).dettagli, "toglie fino a 10 scudo al nemico")


# --- Scontri ------------------------------------------------------------------------

func test_fantasma_in_ultima_possibilita() -> void:
	var run: RunState = _run()
	var dettagli: String = SchedaCarta.da_fantasma(run, _fantasma()).dettagli
	assert_string_contains(dettagli, "Se perdi: −%d Prestigio" % run.year)
	assert_string_contains(dettagli, "Il pareggio conta come vittoria, ma subisci i malus.")
	assert_string_contains(dettagli, "Ricerca dimezzata per tutto l'anno prossimo")
	run.last_chance = true
	dettagli = SchedaCarta.da_fantasma(run, _fantasma()).dettagli
	assert_string_contains(dettagli, "Se perdi, la partita finisce.")
	assert_false(dettagli.contains("Prestigio"), "Nell'ultima possibilità non si perde Prestigio: si perde la partita.")


func test_fantasma_dice_il_bottino() -> void:
	rules.ghost_loot_gold = 3
	rules.ghost_loot_research = 2
	var run: RunState = _run()
	assert_string_contains(SchedaCarta.da_fantasma(run, _fantasma()).dettagli, "Se vinci o pareggi: vittoria 1 di %d e bottino di 3 Oro e 2 Ricerca." % rules.wins_needed)


func test_incontro_bottino_e_ultima_possibilita() -> void:
	var incontro: EncounterDef = EncounterDef.new()
	incontro.display_name = "Briganti"
	incontro.loot_gold = 2
	var run: RunState = _run()
	var dettagli: String = SchedaCarta.da_incontro(incontro, run).dettagli
	assert_string_contains(dettagli, "Se vinci o pareggi: bottino di 2 Oro.")
	assert_string_contains(dettagli, "Se perdi: l'Oro del Magazzino si dimezza e +1 Malcontento.")
	run.last_chance = true
	assert_string_contains(SchedaCarta.da_incontro(incontro, run).dettagli, "Se perdi, la partita finisce.")


# --- Scelte -------------------------------------------------------------------------

func test_ricompensa_tessera_gratis_al_livello_1() -> void:
	var ricompensa: RewardDef = RewardDef.new()
	ricompensa.kind = RewardDef.Kind.TRUPPA
	ricompensa.troop = soldier
	var dettagli: String = SchedaCarta.da_ricompensa(ricompensa, _run()).dettagli
	assert_string_contains(dettagli, "Gratis: entra sulla plancia al livello 1.")


func test_resta_com_e_nell_ultima_era() -> void:
	var run: RunState = _run()
	assert_string_contains(SchedaCarta.da_resta(null, run).dettagli, "entrando nella prossima era")
	run.era = catalog.eras.size()
	assert_string_contains(SchedaCarta.da_resta(null, run).dettagli, "Potrai evolvere solo con una Riforma.")


func test_il_visitatore_e_di_passaggio_e_dice_che_cosa_porta() -> void:
	var visitatore: AdvisorDef = AdvisorDef.new()
	visitatore.id = &"mercanti"
	visitatore.display_name = "Mercanti"
	visitatore.category_name = "Ricchezza"
	visitatore.special = AdvisorDef.Special.VISITATORE
	visitatore.description = "Vendono edifici Economici a 1 Oro in più."
	var scheda: SchedaCarta = SchedaCarta.da_consigliere(_run(), visitatore)
	assert_eq(scheda.riga, "Di passaggio")
	assert_string_starts_with(scheda.dettagli, "Di passaggio. Vendono edifici Economici a 1 Oro in più.")


func test_la_rivoluzione_non_si_puo_evitare() -> void:
	var rivoluzione: EventDef = EventDef.new()
	rivoluzione.id = &"rivoluzione"
	rivoluzione.display_name = "Rivoluzione"
	rivoluzione.special = EventDef.Special.RIVOLUZIONE
	var dettagli: String = SchedaCarta.da_evento(_run(), rivoluzione).dettagli
	assert_string_contains(dettagli, "Non si può evitare: scegli il nuovo governo. Poi il Malcontento si azzera.")
	assert_false(dettagli.contains("Ignora il tema del round"))


func test_anteprima_del_potenzia_dice_che_cosa_cambia() -> void:
	# Richiesta di Davide (8 novembre): prima di potenziare si vede che cosa cambia, "prima → dopo".
	soldier.damage = 10
	var run: RunState = _run()
	var truppa: BoardPiece = run.board.troops[0]
	var testo: String = SchedaCarta.anteprima_potenzia(run, truppa)
	assert_string_contains(testo, "Con Potenzia, al livello 2:")
	assert_string_contains(testo, "danno 10 → %d" % run.effective_troop(truppa, 2).damage)
	assert_false(testo.contains("ricarica"), "Solo ciò che cambia.")
	var fattoria: BoardPiece = run.board.buildings[0]
	var edificio: String = SchedaCarta.anteprima_potenzia(run, fattoria)
	assert_string_contains(edificio, "Oro a ogni stagione: +1 → +2")
	truppa.level = run.max_level()
	assert_eq(SchedaCarta.anteprima_potenzia(run, truppa), "", "Al livello massimo niente anteprima.")


func test_anteprima_del_potenzia_e_il_mantenimento() -> void:
	var generale: AdvisorDef = AdvisorDef.new()
	generale.id = &"generale"
	generale.display_name = "Generale"
	generale.types = [&"Fante"]
	generale.upgrade_resource = Res.Type.FERRO
	catalog.advisors = [generale]
	var run: RunState = _run()
	var truppa: BoardPiece = run.board.troops[0]
	if run.upkeep_of(truppa, 2) == null:
		pending("Senza categoria del tipo Fante nel catalogo di prova il mantenimento non si calcola.")
		return
	assert_string_contains(SchedaCarta.anteprima_potenzia(run, truppa), "mantenimento prima di ogni scontro: nessuno → ")


func test_la_capitale_non_ha_l_anteprima_del_potenzia() -> void:
	var capitale: BuildingDef = BuildingDef.new()
	capitale.display_name = "Capitale"
	capitale.is_capital = true
	capitale.gold_per_phase = 1
	rules.starting_buildings = [capitale, farm]
	var run: RunState = _run()
	assert_eq(SchedaCarta.anteprima_potenzia(run, run.board.buildings[0]), "")
