extends GutTest
## Verifiche della ricerca e dell'albero delle tecnologie (GDD §10.3, §10.5, §17; v0.26).
## I numeri qui servono solo ai test e non sono valori di gioco.

const Aiuti = preload("res://tests/sim/aiuti_consiglio.gd")

var catalog: CatalogDef
var rules: RunRules
var resistance: ResistanceRules
var era1: EraDef
var era2: EraDef

var walls: TechDef        # rosso, Militare, altezza 1: +5 Resistenza
var carpentry: TechDef    # rosso, Opera, altezza 1: +1 spazio edificio
var drill: TechDef        # rosso, Militare, altezza 2
var fields: TechDef       # verde, Terra, altezza 1: linea di truppe
var coins: TechDef        # verde, Ricchezza, altezza 1
var deep: TechDef         # verde, Ricchezza, altezza 1, richiede coins
var faith2: TechDef       # blu, Fede, era 2
var exclusive: TechDef    # esclusiva di una via
var way: IdentityDef
var line: LineDef
var line_troop1: TroopDef
var line_troop3: TroopDef


func _modifier(effect: ModifierDef.Effect, amount: int) -> ModifierDef:
	var def: ModifierDef = ModifierDef.new()
	def.id = &"mod_%d_%d" % [effect, amount]
	def.display_name = "Prova"
	def.is_malus = false
	def.effect = effect
	def.amount = amount
	def.duration_kind = ModifierDef.Duration.PERMANENTE
	def.stacking = ModifierDef.Stacking.SOMMA_EFFETTI
	return def


func _tech(id: StringName, sphere: String, era: int, tier: int, cost: int) -> TechDef:
	var def: TechDef = TechDef.new()
	def.id = id
	def.display_name = String(id)
	def.sphere = sphere
	def.era = era
	def.tier = tier
	def.cost = cost
	return def


func before_each() -> void:
	era1 = EraDef.new()
	era1.display_name = "Prima"
	era2 = EraDef.new()
	era2.display_name = "Seconda"
	era2.techs_required = 2

	walls = _tech(&"mura", "Militare", 1, 1, 3)
	walls.permanent_modifiers = [_modifier(ModifierDef.Effect.RESISTENZA, 5)]
	carpentry = _tech(&"carpenteria", "Opera", 1, 1, 3)
	carpentry.extra_building_slots = 1
	drill = _tech(&"addestramento", "Militare", 1, 2, 4)
	line_troop1 = TroopDef.new()
	line_troop1.id = &"picchieri"
	line_troop1.display_name = "Picchieri"
	line_troop1.era = 1
	line_troop1.cost_gold = 1
	line_troop3 = TroopDef.new()
	line_troop3.id = &"lanzi"
	line_troop3.display_name = "Lanzi"
	line_troop3.era = 3
	line = LineDef.new()
	line.id = &"linea"
	line.display_name = "Linea di prova"
	line.troops = [line_troop1, line_troop3]
	fields = _tech(&"campi", "Terra", 1, 1, 3)
	fields.line = line
	coins = _tech(&"monete", "Ricchezza", 1, 1, 3)
	deep = _tech(&"banche", "Ricchezza", 1, 1, 3)
	deep.prerequisites = [coins]
	faith2 = _tech(&"fede2", "Fede", 2, 1, 5)
	way = IdentityDef.new()
	way.id = &"via"
	way.display_name = "Via di prova"
	way.dimension = IdentityDef.Dimension.VIA
	exclusive = _tech(&"esclusiva", "Stato", 1, 1, 3)
	exclusive.requires_any = [way]

	catalog = CatalogDef.new()
	catalog.eras = [era1, era2]
	catalog.technologies = [walls, carpentry, drill, fields, coins, deep, faith2, exclusive]
	var base_troop: TroopDef = TroopDef.new()
	base_troop.id = &"base"
	base_troop.era = 1
	catalog.troops = [base_troop]
	rules = RunRules.new()
	rules.prototype_years = 0
	rules.starting_gold = 0
	rules.starting_buildings = []
	rules.starting_troops = []
	Aiuti.consiglio_semplice(catalog, rules)
	resistance = ResistanceRules.new()


func _run(run_seed: int = 1) -> RunState:
	return RunState.new(catalog, rules, BattleRules.new(), resistance, run_seed)


## Mette in mano una tecnologia precisa (la mano vera è pescata a caso).
func _in_hand(run: RunState, def: TechDef) -> void:
	if not run.tech_hand.has(def):
		run.tech_hand.append(def)


func _complete(run: RunState, def: TechDef) -> void:
	_in_hand(run, def)
	run.research += def.cost - run.tech_progress_of(def)
	assert_true(run.choose_tech(def), run.last_error)
	assert_true(run.techs_done.has(def), "%s completata." % def.display_name)


# --- La Ricerca (GDD §10.5.1) -----------------------------------------------------

func test_senza_tecnologia_in_corso_la_ricerca_resta_in_attesa() -> void:
	var run: RunState = _run()
	assert_null(run.current_tech)
	run._gain_loot(0, 2)
	assert_eq(run.research_waiting(), 2, "Ricerca in attesa.")


func test_la_ricerca_va_nella_tecnologia_in_corso_un_po_alla_volta() -> void:
	var run: RunState = _run()
	_in_hand(run, walls)
	run.research = 2
	assert_true(run.choose_tech(walls))
	assert_eq(run.tech_progress_of(walls), 2, "La Ricerca in attesa entra subito.")
	assert_eq(run.research_waiting(), 0)
	assert_false(run.techs_done.has(walls), "Non è istantanea.")
	assert_eq(run.tech_status(walls), RunState.TechStatus.IN_CORSO)
	run._gain_loot(0, 1)
	assert_true(run.techs_done.has(walls), "Si completa appena raggiunge il costo.")
	assert_null(run.current_tech)


func test_la_ricerca_in_piu_passa_alla_tecnologia_successiva() -> void:
	var run: RunState = _run()
	_in_hand(run, walls)
	run.research = 5
	assert_true(run.choose_tech(walls))
	assert_true(run.techs_done.has(walls))
	assert_eq(run.research_waiting(), 2, "L'avanzo resta in attesa.")
	_in_hand(run, coins)
	assert_true(run.choose_tech(coins))
	assert_eq(run.tech_progress_of(coins), 2, "L'avanzo passa alla tecnologia successiva.")


func test_cambiare_tecnologia_a_meta_conserva_i_progressi() -> void:
	var run: RunState = _run()
	_in_hand(run, walls)
	_in_hand(run, coins)
	run.research = 1
	assert_true(run.choose_tech(walls))
	assert_true(run.choose_tech(coins))
	assert_eq(run.tech_progress_of(walls), 1, "I progressi restano salvati.")
	assert_eq(run.tech_status(walls), RunState.TechStatus.INIZIATA)
	run.tech_hand = []
	assert_true(run.tech_hand_cards().has(walls), "La tecnologia iniziata compare sempre fra le carte.")


func test_la_ricerca_non_si_vende() -> void:
	var run: RunState = _run()
	run.research = 4
	assert_false(run.sell_resource(Res.Type.RICERCA, rules.market_units_per_gold))
	assert_eq(run.research, 4)


func test_si_sceglie_solo_fra_le_carte_della_mano() -> void:
	var run: RunState = _run()
	run.tech_hand = []
	assert_false(run.choose_tech(walls), "Non è fra le carte.")


# --- L'albero e la mano (GDD §10.5.2, §10.5.3) ----------------------------------------

func test_la_mano_ha_3_carte_della_propria_era_ed_e_riproducibile() -> void:
	var run: RunState = _run(7)
	assert_eq(run.tech_hand.size(), 3)
	for def: TechDef in run.tech_hand:
		assert_eq(def.era, 1, "Mai tecnologie di un'era futura.")
		assert_ne(def, exclusive, "Le esclusive compaiono solo a chi ha la via.")
		assert_ne(def, drill, "La seconda altezza non è ancora aperta.")
		assert_ne(def, deep, "Manca il prerequisito.")
	var again: RunState = _run(7)
	assert_eq(again.tech_hand, run.tech_hand, "Con lo stesso seme è sempre la stessa mano.")


func test_la_seconda_altezza_si_apre_con_una_tecnologia_della_prima_nello_stesso_ramo() -> void:
	var run: RunState = _run()
	assert_ne(run.tech_block_reason(drill), "", "Bloccata: manca una tecnologia della prima altezza.")
	_complete(run, coins)
	assert_ne(run.tech_block_reason(drill), "", "Una tecnologia di un altro ramo non basta.")
	_complete(run, carpentry)
	assert_eq(run.tech_block_reason(drill), "", "Aperta da Carpenteria, dello stesso ramo rosso.")


func test_prerequisito_preciso() -> void:
	var run: RunState = _run()
	assert_string_contains(run.tech_block_reason(deep), "monete")
	_complete(run, coins)
	assert_eq(run.tech_block_reason(deep), "")


func test_mano_dall_altezza_piu_bassa_aperta_e_da_quella_sopra() -> void:
	catalog.technologies = [walls, drill, faith2]
	era2.techs_required = 1
	var run: RunState = _run()
	_complete(run, walls)
	assert_true(run.tech_hand.has(drill), "Dopo Mura resta la seconda altezza dell'era 1.")
	run.advance_era()
	assert_true(run.tech_hand_cards().has(drill) and run.tech_hand_cards().has(faith2), "Altezze 2 e 3 insieme.")


func test_sconto_sulla_carta_scartata() -> void:
	var run: RunState = _run()
	var shown: Array[TechDef] = run.tech_hand.duplicate()
	var full: int = run._tech_weight(shown[0])
	assert_eq(full, 8, "Peso pieno: 1 × 8.")
	run._draw_tech_hand()
	assert_eq(run.tech_discards.get(shown[0].id, 0), 1, "Mostrata e non scelta: uno scarto.")
	assert_eq(run._tech_weight(shown[0]), 4, "Peso dimezzato.")
	run._draw_tech_hand()
	run._draw_tech_hand()
	run._draw_tech_hand()
	assert_eq(run._tech_weight(shown[0]), 1, "Mai sotto 1/8 del peso pieno.")
	_in_hand(run, shown[0])
	assert_true(run.choose_tech(shown[0]))
	assert_false(run.tech_discards.has(shown[0].id), "Scelta: lo sconto si azzera.")


func test_le_esclusive_compaiono_solo_con_la_via() -> void:
	var run: RunState = _run()
	assert_false(run.tree_technologies().has(exclusive))
	assert_ne(run.tech_block_reason(exclusive), "")
	run.identity.append(way)
	assert_true(run.tree_technologies().has(exclusive))
	assert_eq(run.tech_block_reason(exclusive), "")


# --- Effetti (GDD §10.5.4, §10.5.5) ---------------------------------------------------

func test_gli_effetti_valgono_per_sempre() -> void:
	var run: RunState = _run()
	var resistance_before: int = run.player_resistance()
	var slots_before: int = run.board.building_capacity()
	_complete(run, walls)
	_complete(run, carpentry)
	assert_eq(run.player_resistance(), resistance_before + 5, "Modificatore permanente.")
	assert_eq(run.board.building_capacity(), slots_before + 1, "Spazio edificio.")
	for modifier: ActiveModifier in run.modifiers.active:
		assert_eq(modifier.origin_kind, ActiveModifier.OriginKind.TECNOLOGIA)


func test_una_tecnologia_puo_dare_un_perk() -> void:
	var perk: IdentityDef = IdentityDef.new()
	perk.id = &"perk"
	perk.display_name = "Perk di prova"
	perk.dimension = IdentityDef.Dimension.PERK
	coins.perk = perk
	var run: RunState = _run()
	_complete(run, coins)
	assert_true(run.identity.has(perk))


func test_la_linea_propone_la_versione_dell_era_o_l_ultima_precedente() -> void:
	era2.techs_required = 0
	var run: RunState = _run()
	assert_false(run._troops_of_era().has(line_troop1), "Gli elementi delle linee non sono nel catalogo base.")
	_complete(run, fields)
	assert_true(run._troops_of_era().has(line_troop1), "Versione dell'era 1.")
	assert_true(run.advance_era())
	assert_true(run._troops_of_era().has(line_troop1), "Nessuna versione per l'era 2: resta quella dell'era 1.")
	assert_false(run._troops_of_era().has(line_troop3))
	assert_eq(line.troop_for_era(3), line_troop3, "Nell'era 3 la versione dell'era 3.")


# --- Ere (GDD §10.3) -----------------------------------------------------------------

func test_l_era_si_raggiunge_con_le_tecnologie_dell_era_corrente() -> void:
	var run: RunState = _run()
	run.research = 0
	assert_false(run.advance_era(), "Servono 2 tecnologie dell'era 1.")
	assert_string_contains(run.era_block_reason(), "2")
	_complete(run, walls)
	assert_false(run.advance_era())
	_complete(run, coins)
	assert_eq(run.era, 1, "Il passaggio non è automatico.")
	run.research = 3
	assert_true(run.advance_era(), run.last_error)
	assert_eq(run.era, 2)
	assert_eq(run.research, 3, "Nessuna Ricerca spesa per l'era.")
	assert_eq(run.tech_block_reason(faith2), "", "Si aprono le tecnologie della nuova era.")
	assert_false(run.tech_hand.is_empty(), "La mano si ripesca entrando nell'era.")


# --- Carte dorate (GDD §10.5.6) ---------------------------------------------------

func test_carta_dorata_gia_iniziata_e_sempre_nella_mano() -> void:
	var run: RunState = _run()
	run.tech_hand = []
	run._give_golden(drill)
	assert_eq(run.tech_progress_of(drill), 2, "Metà del costo già pagata.")
	assert_true(run.is_golden(drill))
	assert_true(run.tech_hand_cards().has(drill))
	run.research = 2
	assert_true(run.choose_tech(drill), "La carta dorata ignora l'altezza.")
	assert_true(run.techs_done.has(drill))
	assert_false(run.is_golden(drill))


func test_la_carta_dorata_non_e_mai_di_un_era_futura() -> void:
	var run: RunState = _run()
	for i: int in range(20):
		var pick: TechDef = run._random_golden("")
		if pick != null:
			assert_eq(pick.era, 1)


func test_ricompensa_tecnologia_dell_incontro() -> void:
	var run: RunState = _run()
	var reward: RewardDef = RewardDef.new()
	reward.kind = RewardDef.Kind.TECNOLOGIA
	reward.tech = walls
	var encounter: EncounterDef = EncounterDef.new()
	encounter.rewards = [reward]
	run.won_encounter = encounter
	run.phase = RunState.Phase.RICOMPENSA_INCONTRO
	assert_true(run.take_reward(0), run.last_error)
	assert_true(run.is_golden(walls))


# --- Studioso (GDD §4.2.3) --------------------------------------------------------

func test_revisione_dei_piani_ripesca_la_mano() -> void:
	var redraw: OpportunityDef = OpportunityDef.new()
	redraw.id = &"revisione"
	redraw.display_name = "Revisione"
	redraw.kind = OpportunityDef.Kind.RIPESCA_TECNOLOGIE
	Aiuti.consiglio_semplice(catalog, rules, [redraw])
	rules.half_themes = PackedInt32Array([RunState.RoundTheme.AZIONI, RunState.RoundTheme.AZIONI])
	var run: RunState = _run()
	Aiuti.ascolta(run)
	var shown: Array[TechDef] = run.tech_hand.duplicate()
	var index: int = -1
	for i: int in range(run.offers.size()):
		if run.offers[i].kind == OpportunityDef.Kind.RIPESCA_TECNOLOGIE:
			index = i
	assert_ne(index, -1, "L'azione compare.")
	assert_true(run.buy_offer(index), run.last_error)
	for def: TechDef in shown:
		assert_eq(run.tech_discards.get(def.id, 0), 1, "Le carte di prima contano come scartate.")


# --- Fantasmi generati (§16.3) -----------------------------------------------------

func test_i_fantasmi_generati_hanno_le_tecnologie_delle_ere_passate() -> void:
	var generator: GeneratorRules = GeneratorRules.new()
	generator.years_per_era = 1
	catalog.generator = generator
	var ghost: GhostDef = OpponentGenerator.generate_ghost(catalog, generator, rules, 2, 5)
	assert_eq(ghost.era, 2)
	assert_eq(ghost.technologies.size(), era2.techs_required, "Le tecnologie che servivano per l'era 2.")
	for def: TechDef in ghost.technologies:
		assert_eq(def.era, 1)
		assert_ne(def, exclusive, "Le esclusive solo con la via giusta.")
	var again: GhostDef = OpponentGenerator.generate_ghost(catalog, generator, rules, 2, 5)
	assert_eq(again.technologies, ghost.technologies, "Uguali a parità di seme.")


# --- I dati veri del catalogo (Catalogo §6 quinquies) --------------------------------------

func test_il_catalogo_delle_tecnologie_rispetta_le_regole() -> void:
	var real: CatalogDef = load("res://data/catalog/catalog.tres")
	var real_rules: RunRules = load("res://data/rules/run_rules.tres")
	assert_eq(real.eras[1].techs_required, 4, "§16.3: 4 tecnologie dell'era 1 per l'era 2.")
	assert_eq(real.eras[2].techs_required, 5, "§16.3: 5 tecnologie dell'era 2 per l'era 3.")
	assert_eq(real_rules.tech_hand_size, 3)
	var ids: Array[StringName] = []
	var base_count: Dictionary = {}
	for def: TechDef in real.technologies:
		assert_false(ids.has(def.id), "Id unico: %s" % def.id)
		ids.append(def.id)
		assert_ne(def.branch(), &"", "Sfera valida: %s" % def.display_name)
		assert_ne(def.description, "", "Effetto scritto: %s" % def.display_name)
		var expected_cost: int = [3, 5, 7][def.era - 1] + def.tier - 1
		assert_eq(def.cost, expected_cost, "Costo di prova di %s." % def.display_name)
		var effects: int = def.permanent_modifiers.size() + (1 if def.perk != null else 0) + (1 if def.line != null else 0)
		effects += 1 if def.extra_building_slots + def.extra_troop_slots > 0 else 0
		assert_eq(effects, 1, "Un solo effetto principale: %s." % def.display_name)
		for needed: Resource in def.prerequisites:
			var prerequisite: TechDef = needed as TechDef
			assert_true(prerequisite != null and prerequisite.height() <= def.height(), "Prerequisito non più alto: %s." % def.display_name)
		if def.is_exclusive():
			assert_eq(def.tier, 1, "Le esclusive stanno alla prima altezza.")
		else:
			var key: String = "%d-%s-%d" % [def.era, def.branch(), def.tier]
			base_count[key] = base_count.get(key, 0) + 1
		if def.line != null:
			for version: TroopDef in def.line.troops:
				assert_false(real.troops.has(version), "%s non è nel catalogo base." % version.display_name)
			for version: BuildingDef in def.line.buildings:
				assert_false(real.buildings.has(version), "%s non è nel catalogo base." % version.display_name)
	for era_number: int in [1, 2, 3]:
		for color: StringName in TechDef.BRANCHES:
			assert_eq(base_count.get("%d-%s-1" % [era_number, color], 0), 2, "Era %d, ramo %s: 2 alla prima altezza." % [era_number, color])
			assert_eq(base_count.get("%d-%s-2" % [era_number, color], 0), 1, "Era %d, ramo %s: 1 alla seconda." % [era_number, color])
	assert_eq(real.technologies.size(), 58, "36 di base, 13 delle vie e 9 dei popoli.")
	for advisor: AdvisorDef in real.advisors:
		for action: OpportunityDef in advisor.actions:
			assert_eq(action.cost_research, 0, "La Ricerca non paga azioni: %s." % action.display_name)
