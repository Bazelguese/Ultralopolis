extends GutTest
## Verifiche del ciclo della run (GDD §3, §4, §5, §6, §10, §17).
## I numeri qui servono solo ai test e non sono valori di gioco.


# --- Costruzione di un catalogo di prova ------------------------------------

func _building(id: StringName, era: int, cost: int, gold: int, research: int) -> BuildingDef:
	var def: BuildingDef = BuildingDef.new()
	def.id = id
	def.display_name = String(id)
	def.era = era
	def.cost_gold = cost
	def.gold_per_phase = gold
	def.research_per_phase = research
	def.mana_amount = 0
	def.mana_interval_ms = 1000
	return def


func _troop(id: StringName, era: int, cost: int, damage: int) -> TroopDef:
	var def: TroopDef = TroopDef.new()
	def.id = id
	def.display_name = String(id)
	def.era = era
	def.cost_gold = cost
	def.mana_cost = 0
	def.cooldown_ms = 100
	def.damage = damage
	def.food_tenths = 0  # Qui non si prova la fame (vedi test_resources.gd).
	return def


var farm: BuildingDef
var library: BuildingDef
var barracks: BuildingDef
var market: BuildingDef
var temple: BuildingDef
var era2_building: BuildingDef
var sword: TroopDef
var spear: TroopDef
var bow: TroopDef
var era2_troop: TroopDef
var killer: TroopDef

var catalog: CatalogDef
## Consiglio di prova: un costruttore (edifici, spazi edificio, Esattori) e un comandante
## (truppe, spazi truppa, Tributo). Con 2 consiglieri compaiono sempre entrambi.
var builder: CouncillorDef
var commander: CouncillorDef
var architects: OpportunityDef
var quartermaster: OpportunityDef
var run_rules: RunRules
var battle_rules: BattleRules
var resistance_rules: ResistanceRules


func before_each() -> void:
	farm = _building(&"fattoria", 1, 3, 2, 0)
	library = _building(&"biblioteca", 1, 4, 0, 3)
	barracks = _building(&"caserma", 1, 5, 0, 0)
	barracks.extra_troop_slots = 1
	market = _building(&"mercato", 1, 5, 3, 0)
	temple = _building(&"tempio", 1, 6, 0, 0)
	era2_building = _building(&"bottega", 2, 7, 5, 0)
	sword = _troop(&"spade", 1, 4, 0)
	spear = _troop(&"lance", 1, 4, 0)
	bow = _troop(&"archi", 1, 5, 0)
	era2_troop = _troop(&"cavalieri", 2, 7, 0)
	killer = _troop(&"distruttori", 1, 0, 1000)

	var era1: EraDef = EraDef.new()
	era1.display_name = "Prima"
	var era2: EraDef = EraDef.new()
	era2.display_name = "Seconda"
	era2.research_cost = 5
	era2.bonus_building_slots = 1
	era2.bonus_troop_slots = 1

	catalog = CatalogDef.new()
	catalog.buildings = [farm, library, barracks, market, temple, era2_building]
	catalog.troops = [sword, spear, bow, era2_troop]
	catalog.eras = [era1, era2]
	builder = CouncillorDef.new()
	builder.id = &"costruttore"
	builder.display_name = "Costruttore"
	builder.buildings = catalog.buildings.duplicate()
	commander = CouncillorDef.new()
	commander.id = &"comandante"
	commander.display_name = "Comandante"
	commander.troops = catalog.troops.duplicate()
	catalog.councillors = [builder, commander]
	architects = _opportunity(&"architetti", &"costruttore", OpportunityDef.Kind.SPAZIO_EDIFICIO, 6)
	quartermaster = _opportunity(&"quartiermastro", &"comandante", OpportunityDef.Kind.SPAZIO_TRUPPA, 5)
	var collectors: OpportunityDef = _opportunity(&"esattori", &"costruttore", OpportunityDef.Kind.SCAMBIO_RISORSE, 0)
	collectors.gain_gold = 3
	var tribute: OpportunityDef = _opportunity(&"tributo", &"comandante", OpportunityDef.Kind.SCAMBIO_RISORSE, 0)
	tribute.gain_gold = 2
	catalog.opportunities = [architects, collectors, quartermaster, tribute]

	run_rules = RunRules.new()
	run_rules.starting_gold = 5
	run_rules.starting_prestige = 20
	run_rules.wins_needed = 10
	run_rules.prototype_years = 0
	run_rules.starting_buildings = [farm]
	run_rules.starting_troops = []
	run_rules.reroll_base_cost = 1
	run_rules.reroll_cost_increase = 1
	# Nei test tutti i round sono misti, salvo dove si provano i tipi di round.
	run_rules.round_types = PackedInt32Array([3, 3, 3, 3, 3])

	battle_rules = BattleRules.new()

	resistance_rules = ResistanceRules.new()
	resistance_rules.per_era = [10, 10]
	resistance_rules.per_year = 0
	resistance_rules.per_building = 0
	resistance_rules.per_troop = 0

	# Di base: fantasmi e incontri innocui (si vincono col logoramento, Resistenza 1).
	_set_ghosts_for_years(5, [], 1)
	_set_easy_encounters(5)


func _opportunity(id: StringName, councillor_id: StringName, kind: OpportunityDef.Kind, cost: int) -> OpportunityDef:
	var def: OpportunityDef = OpportunityDef.new()
	def.id = id
	def.display_name = String(id)
	def.councillor = councillor_id
	def.kind = kind
	def.cost_gold = cost
	return def


func _set_ghosts_for_years(years: int, troops: Array[TroopDef], ghost_era: int) -> void:
	var ghosts: Array[GhostDef] = []
	for y: int in range(1, years + 1):
		var ghost: GhostDef = GhostDef.new()
		ghost.display_name = "Fantasma %d" % y
		ghost.year = y
		ghost.era = ghost_era
		ghost.troops = troops
		ghosts.append(ghost)
	catalog.ghosts = ghosts


func _encounter(year: int, troops: Array[TroopDef], resistance: int, rewards: Array[RewardDef]) -> EncounterDef:
	var encounter: EncounterDef = EncounterDef.new()
	encounter.display_name = "Incontro %d" % year
	encounter.year = year
	encounter.troops = troops
	encounter.resistance = resistance
	encounter.rewards = rewards
	return encounter


func _gold_reward(amount: int) -> RewardDef:
	var reward: RewardDef = RewardDef.new()
	reward.kind = RewardDef.Kind.ORO
	reward.amount = amount
	return reward


func _set_easy_encounters(years: int) -> void:
	var list: Array[EncounterDef] = []
	for y: int in range(1, years + 1):
		for i: int in range(3):
			list.append(_encounter(y, [], 1, [_gold_reward(4)]))
	catalog.encounters = list


func _set_strong_encounters(years: int) -> void:
	var list: Array[EncounterDef] = []
	for y: int in range(1, years + 1):
		for i: int in range(3):
			list.append(_encounter(y, [killer], 1000, []))
	catalog.encounters = list


func _new_run(run_seed: int = 42) -> RunState:
	return RunState.new(catalog, run_rules, battle_rules, resistance_rules, run_seed)


func _pass_all(run: RunState) -> void:
	while run.is_shopping_phase():
		run.pass_opportunity()


## Porta la run dalla Produzione alla Preparazione vincendo l'incontro facile.
func _to_preparation(run: RunState) -> void:
	_pass_all(run)
	assert_eq(run.phase, RunState.Phase.SCELTA_INCONTRO)
	run.choose_encounter(0)
	if run.phase == RunState.Phase.RICOMPENSA_INCONTRO:
		run.skip_reward()


## Completa l'anno in corso dalla Preparazione in poi.
func _play_year_rest(run: RunState) -> void:
	_pass_all(run)
	run.fight_ghost()


## Fa un anno intero passando tutte le opportunità e combattendo il fantasma.
func _play_year(run: RunState) -> void:
	_to_preparation(run)
	_pass_all(run)
	assert_eq(run.phase, RunState.Phase.SCONTRO_FANTASMA)
	run.fight_ghost()


func _offer_index(run: RunState, kind: OpportunityDef.Kind, def_id: StringName = &"") -> int:
	for i: int in range(run.offers.size()):
		var offer: Offer = run.offers[i]
		if offer.kind != kind:
			continue
		if def_id == &"":
			return i
		if offer.building != null and offer.building.id == def_id:
			return i
		if offer.troop != null and offer.troop.id == def_id:
			return i
	return -1


## Sceglie il consigliere con quell'id fra quelli del round. true se c'era.
func _choose(run: RunState, councillor_id: StringName) -> bool:
	for i: int in range(run.councillor_choices.size()):
		if run.councillor_choices[i].id == councillor_id:
			return run.choose_councillor(i)
	return false


## Sceglie il consigliere giusto e rinnova finché compare la proposta cercata (con Oro abbondante).
func _find_offer(run: RunState, kind: OpportunityDef.Kind, def_id: StringName = &"") -> int:
	if run.is_choosing_councillor():
		var troops: bool = kind in [OpportunityDef.Kind.RECLUTA_TRUPPA, OpportunityDef.Kind.SPAZIO_TRUPPA]
		assert_true(_choose(run, &"comandante" if troops else &"costruttore"), "Il consigliere adatto è nel round.")
	for attempt: int in range(200):
		var index: int = _offer_index(run, kind, def_id)
		if index >= 0:
			return index
		run.gold += run.reroll_cost()
		run.reroll_offers()
	fail_test("Offerta non trovata.")
	return -1


# --- Produzione per fase (GDD §5.2) -------------------------------------------

func test_ingresso_in_fase_una_sola_raccolta() -> void:
	var run: RunState = _new_run()
	assert_eq(run.phase, RunState.Phase.PRODUZIONE)
	assert_eq(run.gold, 7, "5 Oro iniziali + 2 della fattoria all'ingresso in Produzione.")
	run.pass_opportunity()
	run.pass_opportunity()
	assert_eq(run.gold, 7, "Le opportunità non producono di nuovo.")


func test_costruzione_in_produzione_produce_da_preparazione() -> void:
	var run: RunState = _new_run()
	var index: int = _find_offer(run, OpportunityDef.Kind.COSTRUISCI_EDIFICIO, &"biblioteca")
	run.gold = 10
	assert_true(run.buy_offer(index))
	assert_eq(run.research, 0, "Nessuna raccolta retroattiva.")
	_to_preparation(run)
	assert_eq(run.research, 3, "La biblioteca produce all'inizio della Preparazione.")


func test_risorse_conservate_fra_fasi_e_anni() -> void:
	var run: RunState = _new_run()
	run.research = 2
	var gold_before: int = run.gold
	_play_year(run)
	assert_eq(run.year, 2)
	# Fattoria: +2 in Preparazione e +2 nella Produzione dell'anno 2.
	assert_eq(run.gold, gold_before + 4)
	assert_eq(run.research, 2, "La Ricerca non spesa resta nel Magazzino.")


# --- Round e Consiglio (GDD §3.2, §4.2) --------------------------------------

func test_cinque_round_per_meta_poi_l_incontro() -> void:
	var run: RunState = _new_run()
	for n: int in range(1, 6):
		assert_eq(run.round_number, n)
		assert_true(run.is_choosing_councillor(), "Ogni round comincia con la scelta del consigliere.")
		run.pass_opportunity()
	assert_eq(run.phase, RunState.Phase.SCELTA_INCONTRO, "Dopo 5 round arriva l'incontro.")
	run.choose_encounter(0)
	run.skip_reward()
	assert_eq(run.phase, RunState.Phase.PREPARAZIONE)
	assert_eq(run.round_number, 1, "La seconda metà ricomincia dal round 1.")


func test_tre_consiglieri_diversi_e_tre_proposte() -> void:
	var extra: CouncillorDef = CouncillorDef.new()
	extra.id = &"terzo"
	extra.buildings = [farm]
	var fourth: CouncillorDef = CouncillorDef.new()
	fourth.id = &"quarto"
	fourth.troops = [sword]
	catalog.councillors = [builder, commander, extra, fourth]
	var run: RunState = _new_run()
	for attempt: int in range(20):
		assert_eq(run.councillor_choices.size(), 3, "3 consiglieri per round.")
		var ids: Array[StringName] = []
		for def: CouncillorDef in run.councillor_choices:
			assert_false(ids.has(def.id), "Consiglieri diversi fra loro.")
			ids.append(def.id)
		run.pass_opportunity()
		if run.phase == RunState.Phase.SCELTA_INCONTRO:
			_to_preparation(run)
		elif run.phase == RunState.Phase.SCONTRO_FANTASMA:
			run.fight_ghost()
	assert_true(_choose(run, &"costruttore") or run.choose_councillor(0))
	assert_lte(run.offers.size(), 3, "Al massimo 3 proposte.")


func test_il_consigliere_scelto_non_si_cambia() -> void:
	var run: RunState = _new_run()
	assert_true(run.choose_councillor(0))
	assert_false(run.choose_councillor(1), "La scelta del consigliere è definitiva.")
	assert_false(run.offers.is_empty(), "Il consigliere fa le sue proposte.")
	for offer: Offer in run.offers:
		assert_eq(offer.councillor, run.councillor)


func test_si_puo_passare_anche_dopo_aver_scelto() -> void:
	var run: RunState = _new_run()
	run.choose_councillor(0)
	assert_true(run.pass_opportunity())
	assert_eq(run.round_number, 2)
	assert_true(run.is_choosing_councillor())


func test_tipi_di_round() -> void:
	run_rules.round_types = PackedInt32Array([1, 1, 1, 1, 1])
	var run: RunState = _new_run()
	assert_eq(run.round_type, RunState.RoundType.EDIFICI)
	assert_eq(run.councillor_choices.size(), 1, "Il comandante non ha edifici: non viene pescato.")
	run.choose_councillor(0)
	for offer: Offer in run.offers:
		assert_eq(offer.kind, OpportunityDef.Kind.COSTRUISCI_EDIFICIO, "Round Edifici: solo edifici.")
	run_rules.round_types = PackedInt32Array([2, 2, 2, 2, 2])
	run = _new_run()
	run.choose_councillor(0)
	for offer: Offer in run.offers:
		assert_eq(offer.kind, OpportunityDef.Kind.RECLUTA_TRUPPA, "Round Truppe: solo truppe.")
	run_rules.round_types = PackedInt32Array([0, 0, 0, 0, 0])
	run = _new_run()
	assert_true(_choose(run, &"costruttore"))
	for offer: Offer in run.offers:
		assert_eq(offer.building, null, "Round Azioni: niente elementi.")
		assert_not_null(offer.opportunity)


func test_ogni_meta_ha_i_tipi_di_round_previsti() -> void:
	run_rules.round_types = PackedInt32Array([0, 1, 2, 3, 3])
	var run: RunState = _new_run()
	var seen: Array[int] = []
	while run.phase == RunState.Phase.PRODUZIONE:
		seen.append(run.round_type)
		run.pass_opportunity()
	seen.sort()
	assert_eq(seen, [0, 1, 2, 3, 3] as Array[int], "Un round per tipo e due misti, in ordine casuale.")


func test_proposte_dell_era_corrente() -> void:
	var run: RunState = _new_run()
	_choose(run, &"costruttore")
	for attempt: int in range(30):
		for offer: Offer in run.offers:
			if offer.building != null:
				assert_eq(offer.building.era, 1, "Solo elementi dell'era corrente.")
		run.gold += run.reroll_cost()
		run.reroll_offers()


func test_prendere_una_proposta_chiude_il_round() -> void:
	var run: RunState = _new_run()
	var index: int = _find_offer(run, OpportunityDef.Kind.COSTRUISCI_EDIFICIO, &"fattoria")
	run.gold = 20
	assert_true(run.buy_offer(index))
	assert_eq(run.gold, 17)
	assert_eq(run.board.buildings.size(), 2)
	assert_eq(run.round_number, 2)


func test_oro_insufficiente() -> void:
	var run: RunState = _new_run()
	var index: int = _find_offer(run, OpportunityDef.Kind.COSTRUISCI_EDIFICIO, &"tempio")
	run.gold = 1
	assert_false(run.buy_offer(index))
	assert_ne(run.last_error, "", "Il motivo del rifiuto è spiegato.")
	assert_eq(run.board.buildings.size(), 1)


func test_rinnovo_costo_crescente_e_dimezzamento() -> void:
	var run: RunState = _new_run()
	run.gold = 100
	assert_false(run.reroll_offers(), "Si rinnovano le proposte del consigliere scelto.")
	run.choose_councillor(0)
	var paid: Array[int] = []
	for i: int in range(4):
		paid.append(run.reroll_cost())
		assert_true(run.reroll_offers())
	assert_eq(paid, [1, 2, 3, 4] as Array[int], "Il costo cresce a ogni rinnovo.")
	assert_eq(run.reroll_cost(), 5)
	assert_eq(run.gold, 90)
	run.pass_opportunity()
	assert_eq(run.reroll_cost(), 3, "Nuovo round: l'aumento +4 diventa +2.")
	run.pass_opportunity()
	assert_eq(run.reroll_cost(), 2, "+2 diventa +1.")
	run.pass_opportunity()
	assert_eq(run.reroll_cost(), 1, "+1 diventa +0: costo iniziale.")
	_play_year(run)
	assert_eq(run.reroll_cost(), 1, "Mai sotto il costo iniziale.")


func test_stesso_seme_stesse_offerte() -> void:
	var first: Array[String] = []
	var second: Array[String] = []
	for target: Array[String] in [first, second]:
		var run: RunState = _new_run(1234)
		run.gold = 100
		for def: CouncillorDef in run.councillor_choices:
			target.append(def.id)
		run.choose_councillor(0)
		for i: int in range(5):
			for offer: Offer in run.offers:
				target.append(offer.describe())
			run.reroll_offers()
	assert_eq(first, second, "Lo stesso seme pesca gli stessi consiglieri e le stesse proposte.")


# --- Plancia, vendita e spazi (GDD §6) ---------------------------------------

func test_vendita_rimborsa_meta_del_prezzo() -> void:
	var run: RunState = _new_run()
	var index: int = _find_offer(run, OpportunityDef.Kind.COSTRUISCI_EDIFICIO, &"mercato")
	run.gold = 5
	assert_true(run.buy_offer(index))
	assert_eq(run.gold, 0)
	assert_true(run.sell_building(1))
	assert_eq(run.gold, 2, "Metà di 5, per difetto.")


func test_ricompensa_venduta_rende_meta_del_prezzo_di_catalogo() -> void:
	var reward: RewardDef = RewardDef.new()
	reward.kind = RewardDef.Kind.EDIFICIO
	reward.building = market
	var list: Array[EncounterDef] = [_encounter(1, [], 1, [reward])]
	catalog.encounters = list
	var run: RunState = _new_run()
	_pass_all(run)
	run.choose_encounter(0)
	var gold_before: int = run.gold
	assert_true(run.take_reward(0))
	assert_eq(run.gold, gold_before + 5, "La ricompensa è gratis; in Preparazione producono fattoria (2) e mercato (3).")
	var gold_after_reward: int = run.gold
	assert_true(run.sell_building(1))
	assert_eq(run.gold, gold_after_reward + 2, "Vale metà dei 5 Oro di catalogo.")


func test_dotazione_iniziale_non_rimborsa() -> void:
	var run: RunState = _new_run()
	var gold_before: int = run.gold
	assert_true(run.sell_building(0))
	assert_eq(run.gold, gold_before)


func test_plancia_piena_richiede_sostituzione() -> void:
	var run: RunState = _new_run()
	for def: BuildingDef in [market, market, market]:
		run.board.buildings.append(BoardPiece.of_building(def, 6))
	assert_false(run.board.has_free_building_slot(), "4 spazi edificio occupati.")
	var index: int = _find_offer(run, OpportunityDef.Kind.COSTRUISCI_EDIFICIO, &"biblioteca")
	run.gold = 4
	assert_true(run.offer_needs_replacement(run.offers[index]))
	assert_false(run.buy_offer(index), "Senza indicare cosa sostituire non si può.")
	assert_true(run.buy_offer(index, 1), "Sostituisce il mercato in posizione 1.")
	assert_eq(run.board.buildings[1].building.id, &"biblioteca")
	assert_eq(run.gold, 3, "4 - 4 di prezzo + 3 di rimborso.")


func test_caserma_concede_uno_spazio_truppa() -> void:
	var run: RunState = _new_run()
	assert_eq(run.board.troop_capacity(), 3)
	run.board.buildings.append(BoardPiece.of_building(barracks, 5))
	assert_eq(run.board.troop_capacity(), 4)
	for i: int in range(4):
		run.board.troops.append(BoardPiece.of_troop(sword, 4))
	assert_false(run.sell_building(1), "Venderla lascerebbe una truppa senza spazio.")
	assert_true(run.sell_troop(0))
	assert_true(run.sell_building(1))


func test_acquisto_di_uno_spazio() -> void:
	var run: RunState = _new_run()
	var index: int = _find_offer(run, OpportunityDef.Kind.SPAZIO_EDIFICIO)
	run.gold = architects.cost_gold
	assert_true(run.buy_offer(index))
	assert_eq(run.board.building_capacity(), 5)


func test_spazi_mai_oltre_il_massimo() -> void:
	var run: RunState = _new_run()
	run.board.base_building_slots = 10
	_choose(run, &"costruttore")
	for attempt: int in range(30):
		run.gold += run.reroll_cost()
		run.reroll_offers()
		assert_eq(_offer_index(run, OpportunityDef.Kind.SPAZIO_EDIFICIO), -1, "Niente spazi in offerta al massimo.")
	run.board.base_building_slots = 50
	assert_eq(run.board.building_capacity(), 10)


func test_riordino_truppe() -> void:
	var run: RunState = _new_run()
	run.board.troops.append(BoardPiece.of_troop(sword, 4))
	run.board.troops.append(BoardPiece.of_troop(spear, 4))
	run.board.troops.append(BoardPiece.of_troop(bow, 5))
	assert_true(run.move_troop(0, 2))
	assert_eq(run.board.troops[2].troop.id, &"spade")
	assert_eq(run.board.troops[0].troop.id, &"lance")


# --- Ere (GDD §10) ------------------------------------------------------------

func test_passaggio_di_era() -> void:
	var run: RunState = _new_run()
	run.research = 7
	assert_true(run.advance_era())
	assert_eq(run.era, 2)
	assert_eq(run.research, 2, "Ricerca pagata una volta, resto conservato.")
	assert_eq(run.round_number, 1, "Non consuma il round.")
	assert_eq(run.board.building_capacity(), 5, "L'era concede uno spazio edificio.")
	assert_eq(run.board.troop_capacity(), 4, "L'era concede uno spazio truppa.")
	_choose(run, &"costruttore")
	for offer: Offer in run.offers:
		if offer.building != null:
			assert_eq(offer.building.era, 2, "Offerte coerenti con la nuova era.")
	assert_false(run.advance_era(), "Non ci sono altre ere.")


func test_era_senza_ricerca_sufficiente() -> void:
	var run: RunState = _new_run()
	run.research = 4
	assert_false(run.advance_era())
	assert_eq(run.era, 1)
	assert_eq(run.research, 4)


# --- Incontri del mondo (GDD §3.3) ------------------------------------------

func test_fantasma_e_incontri_fissati_a_inizio_anno() -> void:
	var run: RunState = _new_run()
	assert_eq(run.current_ghost.year, 1)
	assert_eq(run.encounter_choices.size(), 3, "Si sceglie fra 3 incontri.")


func test_vittoria_incontro_ricompensa_a_scelta() -> void:
	var run: RunState = _new_run()
	_pass_all(run)
	assert_true(run.choose_encounter(0))
	assert_eq(run.phase, RunState.Phase.RICOMPENSA_INCONTRO)
	var gold_before: int = run.gold
	assert_true(run.take_reward(0))
	assert_eq(run.phase, RunState.Phase.PREPARAZIONE)
	assert_eq(run.gold, gold_before + 4 + 2, "Ricompensa + produzione della Preparazione.")


func test_ricompensa_si_puo_rifiutare() -> void:
	var run: RunState = _new_run()
	_pass_all(run)
	run.choose_encounter(0)
	assert_true(run.skip_reward())
	assert_eq(run.phase, RunState.Phase.PREPARAZIONE)


func test_sconfitta_incontro_dimezza_oro() -> void:
	_set_strong_encounters(5)
	var run: RunState = _new_run()
	_pass_all(run)
	run.gold = 7
	var prestige_before: int = run.prestige
	assert_true(run.choose_encounter(0))
	assert_eq(run.gold, 3 + 2, "7 diventa 3, poi +2 dalla Preparazione.")
	assert_eq(run.prestige, prestige_before, "Il Prestigio non cambia.")
	assert_eq(run.wins, 0, "Le vittorie non cambiano.")
	assert_eq(run.phase, RunState.Phase.PREPARAZIONE)


func test_sconfitta_incontro_in_ultima_possibilita_termina_la_run() -> void:
	_set_strong_encounters(5)
	var run: RunState = _new_run()
	run.last_chance = true
	_pass_all(run)
	run.choose_encounter(0)
	assert_true(run.is_over())
	assert_eq(run.run_end, RunState.RunEnd.SCONFITTA)


# --- Scontro con il fantasma, Prestigio e fine della run (GDD §3.4) ----------

func test_sconfitta_anno_n_perde_n_prestigio_e_ultima_possibilita() -> void:
	run_rules.starting_prestige = 3
	_set_ghosts_for_years(5, [killer], 1)
	var run: RunState = _new_run()
	_play_year(run)
	assert_eq(run.prestige, 2, "Anno 1: perso 1 Prestigio.")
	assert_false(run.last_chance)
	_play_year(run)
	assert_eq(run.prestige, 0, "Anno 2: persi 2 Prestigio.")
	assert_true(run.last_chance, "Prima discesa a zero: ultima possibilità.")
	assert_false(run.is_over(), "La run continua.")
	_play_year(run)
	assert_true(run.is_over(), "Ulteriore sconfitta: fine della run.")
	assert_eq(run.run_end, RunState.RunEnd.SCONFITTA)


func test_pareggio_conta_come_vittoria() -> void:
	# Stessa Resistenza (10) e stessa truppa: cadono insieme.
	var twin: TroopDef = _troop(&"gemelli", 1, 0, 10)
	run_rules.starting_troops = [twin]
	_set_ghosts_for_years(5, [twin], 1)
	var run: RunState = _new_run()
	var prestige_before: int = run.prestige
	_play_year(run)
	assert_eq(run.last_battle.outcome, BattleSim.Outcome.PAREGGIO)
	assert_eq(run.wins, 1, "Il pareggio aggiunge una vittoria.")
	assert_eq(run.prestige, prestige_before, "Nessuna perdita di Prestigio.")


func test_decima_vittoria_vince_la_run() -> void:
	run_rules.wins_needed = 2
	run_rules.starting_troops = [killer]
	var run: RunState = _new_run()
	_play_year(run)
	assert_eq(run.wins, 1)
	assert_false(run.is_over())
	_play_year(run)
	assert_true(run.is_over())
	assert_eq(run.run_end, RunState.RunEnd.VITTORIA)


func test_run_di_prova_finisce_dopo_tre_anni() -> void:
	run_rules.prototype_years = 3
	run_rules.starting_troops = [killer]
	var run: RunState = _new_run()
	for i: int in range(3):
		_play_year(run)
	assert_true(run.is_over())
	assert_eq(run.run_end, RunState.RunEnd.FINE_PROVA)
	assert_eq(run.wins, 3)


func test_resistenza_del_giocatore_e_ripristinata_a_ogni_scontro() -> void:
	resistance_rules.per_era = [50, 50]
	var weak: TroopDef = _troop(&"deboli", 1, 0, 5)
	_set_ghosts_for_years(5, [weak], 1)
	run_rules.starting_troops = [killer]
	var run: RunState = _new_run()
	_play_year(run)
	_play_year(run)
	# In ogni scontro il fantasma colpisce una volta (5 danni) nello stesso istante del giocatore.
	assert_eq(run.last_battle.get_max_resistance(BattleSim.SIDE_A), 50)
	assert_eq(run.last_battle.get_resistance(BattleSim.SIDE_A), 45, "I danni del primo scontro non si sommano al secondo.")
	assert_eq(run.make_battle_replay().get_resistance(BattleSim.SIDE_A), 50, "Lo scontro parte dalla Resistenza piena.")


func test_replay_della_battaglia_identico() -> void:
	run_rules.starting_troops = [killer]
	var run: RunState = _new_run()
	_play_year(run)
	var replay: BattleSim = run.make_battle_replay()
	assert_eq(replay.run_to_end(), run.last_battle.outcome)
	assert_eq(replay.elapsed_ms, run.last_battle.elapsed_ms)


# --- Costi in altre risorse e rinnovo minimo ---------------------------------------

func test_il_rinnovo_costa_almeno_1_oro() -> void:
	var discount: ModifierDef = ModifierDef.new()
	discount.id = &"sconto"
	discount.effect = ModifierDef.Effect.COSTO_RINNOVO
	discount.amount = -3
	discount.duration_kind = ModifierDef.Duration.PERMANENTE
	var run: RunState = _new_run()
	run.modifiers.apply(discount, ActiveModifier.OriginKind.ALTRO, "Prova", 1, run.board, RandomNumberGenerator.new())
	assert_eq(run.reroll_cost(), 1)


func test_azione_pagata_con_altre_risorse() -> void:
	var training: OpportunityDef = OpportunityDef.new()
	training.id = &"addestramento"
	training.councillor = &"costruttore"
	training.kind = OpportunityDef.Kind.SCAMBIO_RISORSE
	training.gain_research = 1
	var iron: ResourceAmounts = ResourceAmounts.new()
	iron.ferro = 2
	training.cost_resources = iron
	catalog.opportunities = [training]
	run_rules.round_types = PackedInt32Array([0, 0, 0, 0, 0])
	var run: RunState = _new_run()
	assert_true(_choose(run, &"costruttore"))
	assert_false(run.can_afford(run.offers[0]), "Serve Ferro, non Oro.")
	run.stock[Res.Type.FERRO] = 2
	var gold_before: int = run.gold
	assert_true(run.buy_offer(0))
	assert_eq(run.stock[Res.Type.FERRO], 0)
	assert_eq(run.gold, gold_before, "L'Oro non viene toccato.")


# --- Bottino dei nemici sconfitti (convenzione provvisoria) -------------------------

func test_vittoria_incontro_da_il_bottino_oltre_alla_ricompensa() -> void:
	for encounter: EncounterDef in catalog.encounters:
		encounter.loot_gold = 2
		encounter.loot_research = 1
	var run: RunState = _new_run()
	_pass_all(run)
	var gold_before: int = run.gold
	var research_before: int = run.research
	assert_true(run.choose_encounter(0))
	assert_eq(run.gold, gold_before + 2, "Bottino: 2 Oro.")
	assert_eq(run.research, research_before + 1, "Bottino: 1 Ricerca.")
	assert_eq(run.phase, RunState.Phase.RICOMPENSA_INCONTRO, "La ricompensa a scelta resta.")
	assert_true(run.chronicle.has("Bottino: 2 Oro e 1 Ricerca."))


func test_vittoria_contro_il_fantasma_da_il_bottino() -> void:
	run_rules.ghost_loot_gold = 3
	run_rules.ghost_loot_research = 2
	run_rules.starting_troops = [killer]
	var run: RunState = _new_run()
	_to_preparation(run)
	_pass_all(run)
	var gold_before: int = run.gold
	var research_before: int = run.research
	assert_true(run.fight_ghost())
	assert_eq(run.wins, 1)
	var produced: Array[int] = run.production_per_phase()
	assert_eq(run.gold - produced[Res.Type.ORO], gold_before + 3, "Bottino: 3 Oro (oltre alla produzione del nuovo anno).")
	assert_eq(run.research - produced[Res.Type.RICERCA], research_before + 2, "Bottino: 2 Ricerca.")


func test_la_sconfitta_non_da_bottino() -> void:
	run_rules.ghost_loot_gold = 3
	run_rules.ghost_loot_research = 2
	_set_ghosts_for_years(5, [killer], 1)
	for encounter: EncounterDef in catalog.encounters:
		encounter.loot_gold = 2
	var run: RunState = _new_run()
	_play_year(run)
	assert_eq(run.wins, 0, "Il fantasma ha vinto.")
	var bottini: int = 0
	for riga: String in run.chronicle:
		if riga.begins_with("Bottino"):
			bottini += 1
	assert_eq(bottini, 1, "Solo l'incontro vinto dà bottino, il fantasma che ha vinto no.")
