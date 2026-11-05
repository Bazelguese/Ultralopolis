extends GutTest
## Il Consiglio (GDD §4.2, §4.2.2, §4.2.4, §4.3, §6.5, §12; v0.21 e v0.22). Numeri solo di prova.

const Aiuti = preload("res://tests/sim/aiuti_consiglio.gd")

var catalog: CatalogDef
var rules: RunRules
var resistance_rules: ResistanceRules

var red_building: BuildingDef
var green_building: BuildingDef
var neutral_building: BuildingDef
var blue_troop: TroopDef
var violet_troop: TroopDef
var plain_troop: TroopDef

var soldier: AdvisorDef
var builder: AdvisorDef
var shadow: AdvisorDef
var clown: AdvisorDef
var elder: AdvisorDef


func _building(id: StringName, types: Array[StringName], color: StringName, mana: int) -> BuildingDef:
	var def: BuildingDef = BuildingDef.new()
	def.id = id
	def.display_name = String(id)
	def.types = types
	def.mana_type = color if mana > 0 else &"neutro"
	def.mana_amount = mana
	def.mana_interval_ms = 1000
	def.cost_gold = 2
	return def


func _troop(id: StringName, types: Array[StringName], color: StringName, mana: int, cooldown: int = 1000) -> TroopDef:
	var def: TroopDef = TroopDef.new()
	def.id = id
	def.display_name = String(id)
	def.types = types
	def.mana_type = color
	def.mana_cost = mana
	def.cooldown_ms = cooldown
	def.damage = 2
	def.food_tenths = 0
	def.cost_gold = 2
	return def


func _themes(theme: RunState.RoundTheme, count: int) -> PackedInt32Array:
	var themes: PackedInt32Array = PackedInt32Array()
	for i: int in range(count):
		themes.append(theme)
	return themes


func before_each() -> void:
	red_building = _building(&"caserma", [&"Bellico"], &"rosso", 1)
	green_building = _building(&"mercato", [&"Economico"], &"verde", 1)
	neutral_building = _building(&"mura", [&"Guardiano"], &"rosso", 0)
	blue_troop = _troop(&"preti", [&"Spirituale"], &"blu", 1)
	violet_troop = _troop(&"spie", [&"Criminale"], &"viola", 1)
	plain_troop = _troop(&"fanti", [&"Bellico"], &"rosso", 0, 2000)

	var income: OpportunityDef = OpportunityDef.new()
	income.id = &"esattori"
	income.display_name = "Esattori"
	income.kind = OpportunityDef.Kind.SCAMBIO_RISORSE
	income.gain_gold = 1
	soldier = Aiuti.consigliere(&"generale", [&"Bellico"], [income], Res.Type.FERRO)
	builder = Aiuti.consigliere(&"architetto", [&"Guardiano"], [], Res.Type.PIETRA)
	shadow = Aiuti.consigliere(&"spie", [&"Criminale"], [], Res.Type.ORO)
	shadow.random_resource = true
	clown = Aiuti.consigliere(&"clown", [])
	clown.special = AdvisorDef.Special.CLOWN
	elder = Aiuti.consigliere(&"anziano", [])
	elder.special = AdvisorDef.Special.ANZIANO

	catalog = CatalogDef.new()
	catalog.buildings = [red_building, green_building, neutral_building]
	catalog.troops = [blue_troop, violet_troop, plain_troop]
	catalog.eras = [EraDef.new()]
	catalog.advisors = [soldier]
	rules = RunRules.new()
	rules.starting_gold = 50
	rules.prototype_years = 0
	rules.starting_buildings = []
	rules.starting_troops = [plain_troop]
	rules.advisors_per_round = 1
	rules.rounds_per_half = 3
	rules.half_themes = _themes(RunState.RoundTheme.MISTO, 3)
	resistance_rules = ResistanceRules.new()
	resistance_rules.per_era = [10]
	resistance_rules.per_year = 0
	resistance_rules.per_building = 0
	resistance_rules.per_troop = 0


func _run(run_seed: int = 4) -> RunState:
	return RunState.new(catalog, rules, BattleRules.new(), resistance_rules, run_seed)


# --- Consiglieri del round -------------------------------------------------------

func test_tre_consiglieri_diversi_fra_quelli_che_hanno_proposte() -> void:
	catalog.advisors = [soldier, builder, shadow, clown]
	rules.advisors_per_round = 3
	var run: RunState = _run()
	for attempt: int in range(3):
		assert_eq(run.advisor_choices.size(), 3)
		var ids: Array[StringName] = []
		for advisor: AdvisorDef in run.advisor_choices:
			assert_false(ids.has(advisor.id), "Consiglieri diversi fra loro.")
			ids.append(advisor.id)
		run.pass_round()


func test_un_consigliere_senza_proposte_per_il_tema_non_compare() -> void:
	catalog.advisors = [soldier, builder]
	rules.advisors_per_round = 3
	rules.half_themes = _themes(RunState.RoundTheme.TRUPPE, 3)
	var run: RunState = _run()
	assert_eq(run.advisor_choices.size(), 1, "L'architetto non ha truppe Guardiano da proporre.")
	assert_eq(run.advisor_choices[0], soldier)


func test_la_scelta_del_consigliere_e_definitiva_e_si_puo_passare_senza() -> void:
	catalog.advisors = [soldier, builder]
	rules.advisors_per_round = 2
	var run: RunState = _run()
	assert_true(run.pass_round(), "Si può passare senza scegliere un consigliere.")
	assert_eq(run.round_number, 2)
	assert_true(run.choose_advisor(0))
	assert_false(run.choose_advisor(1), "La scelta è definitiva per il round.")
	assert_false(run.buy_offer(9), "Proposta non valida.")
	assert_true(run.pass_round(), "Si può passare anche dopo aver scelto.")


func test_il_consigliere_propone_solo_carte_con_i_suoi_tipi() -> void:
	var run: RunState = _run()
	Aiuti.ascolta(run)
	for attempt: int in range(20):
		for offer: Offer in run.offers:
			if offer.building != null:
				assert_true(soldier.covers(offer.building.types))
			if offer.troop != null:
				assert_true(soldier.covers(offer.troop.types))
		run.gold += run.reroll_cost()
		run.reroll_offers()


# --- Rinnovo con la risorsa del consigliere ----------------------------------------

func test_rinnovo_con_la_risorsa_del_consigliere() -> void:
	var run: RunState = _run()
	Aiuti.ascolta(run)
	run.stock[Res.Type.FERRO] = 1
	var gold_before: int = run.gold
	assert_eq(run.reroll_resource_cost().ferro, 1, "Stessa quantità del rinnovo in Oro.")
	assert_true(run.reroll_offers(true))
	assert_eq(run.stock[Res.Type.FERRO], 0)
	assert_eq(run.gold, gold_before, "L'Oro non viene toccato.")
	assert_eq(run.reroll_cost(), 2, "Il costo cresce come per il rinnovo in Oro.")
	assert_false(run.reroll_offers(true), "Ferro insufficiente.")
	assert_true(run.reroll_offers(), "In Oro si può ancora.")


# --- Clown e Anziano (GDD §4.2.2) ---------------------------------------------------

func test_il_clown_propone_un_elemento_per_colore_e_un_neutro() -> void:
	catalog.advisors = [clown]
	var run: RunState = _run()
	assert_eq(run.advisor_choices.size(), 1)
	Aiuti.ascolta(run)
	var colors: Array[String] = []
	var neutral: int = 0
	for offer: Offer in run.offers:
		if offer.building != null and RunState.is_neutral_building(offer.building):
			neutral += 1
		elif offer.building != null:
			colors.append(String(offer.building.mana_type))
		else:
			colors.append(String(offer.troop.mana_type))
	colors.sort()
	assert_eq(colors, ["blu", "rosso", "verde", "viola"] as Array[String], "Un elemento per ogni colore.")
	assert_eq(neutral, 1, "Più un edificio neutro.")
	assert_eq(run.offers.size(), 5)
	assert_null(run.reroll_resource_cost(), "Il Clown si rinnova solo in Oro.")
	assert_ne(run.upgrade_block_reason(run.board.troops[0]), "", "Il Clown non potenzia.")


func test_l_anziano_propone_perk_e_potenzia_i_neutri_una_volta_all_anno() -> void:
	var perk: IdentityDef = IdentityDef.new()
	perk.id = &"perk_saggio"
	perk.display_name = "Saggio"
	perk.dimension = IdentityDef.Dimension.PERK
	perk.resistance_bonus = 5
	catalog.identities = [perk]
	var council_of_elders: OpportunityDef = OpportunityDef.new()
	council_of_elders.id = &"perk_anziano"
	council_of_elders.display_name = "Consiglio degli anziani"
	council_of_elders.kind = OpportunityDef.Kind.PERK
	elder.actions = [council_of_elders]
	catalog.advisors = [elder]
	rules.starting_buildings = [neutral_building, red_building]
	rules.starting_perks = 0
	var run: RunState = _run()
	assert_true(run.found_nation("X", []))
	Aiuti.ascolta(run)
	var perk_index: int = -1
	for i: int in range(run.offers.size()):
		assert_true(run.offers[i].kind == OpportunityDef.Kind.PERK or RunState.is_neutral_building(run.offers[i].building), "Perk o edifici neutri.")
		if run.offers[i].kind == OpportunityDef.Kind.PERK:
			perk_index = i
	assert_ne(perk_index, -1, "L'Anziano propone il perk.")
	assert_ne(run.upgrade_block_reason(run.board.buildings[1]), "", "Non potenzia gli edifici con mana.")
	assert_eq(run.upgrade_block_reason(run.board.buildings[0]), "", "Potenzia gli edifici neutri.")
	assert_true(run.upgrade_building(0))
	var before: int = run.player_resistance()
	assert_true(run.buy_offer(perk_index))
	assert_eq(run.player_resistance(), before + 5, "Il perk fa parte dell'identità.")
	Aiuti.ascolta(run)
	if run.chosen_advisor == elder:
		assert_ne(run.upgrade_block_reason(run.board.buildings[0]), "", "Una sola volta all'anno.")


# --- Ombra: Oro più una risorsa casuale (GDD §4.2.4) --------------------------------

func test_ombra_chiede_oro_e_una_risorsa_casuale() -> void:
	catalog.advisors = [soldier, builder, shadow]
	rules.advisors_per_round = 3
	rules.starting_troops = [violet_troop]
	var run: RunState = _run()
	assert_true(run.advisor_choices.has(shadow))
	var drawn: Res.Type = run.shadow_resource
	assert_true(drawn == Res.Type.FERRO or drawn == Res.Type.PIETRA, "Una risorsa delle altre categorie.")
	assert_true(run.choose_advisor(run.advisor_choices.find(shadow)))
	var cost: ResourceAmounts = run.upgrade_cost_of(run.board.troops[0])
	assert_eq(cost.oro, 2, "Oro...")
	assert_eq(cost.whole(drawn), 2, "...più la risorsa del round.")
	assert_eq(run.reroll_resource_cost().whole(drawn), run.reroll_cost(), "Si rinnova con la risorsa casuale.")
	var again: RunState = _run()
	assert_eq(again.shadow_resource, drawn, "Stesso seme, stessa risorsa.")


# --- Spionaggio (GDD §12) ------------------------------------------------------------

func test_lo_spionaggio_sabota_la_truppa_piu_veloce_del_fantasma() -> void:
	var spy: OpportunityDef = OpportunityDef.new()
	spy.id = &"sicari"
	spy.display_name = "Sicari"
	spy.kind = OpportunityDef.Kind.SPIONAGGIO
	spy.spy_effect = OpportunityDef.SpyEffect.SABOTAGGIO
	spy.spy_ms = 5000
	spy.spy_target = TimerTarget.Kind.TRUPPE
	spy.spy_criterion = OpportunityDef.SpyCriterion.PIU_VELOCE
	shadow.actions = [spy]
	catalog.advisors = [shadow]
	rules.half_themes = _themes(RunState.RoundTheme.AZIONI, 3)
	var slow: TroopDef = _troop(&"lenti", [&"Bellico"], &"rosso", 0, 3000)
	var fast: TroopDef = _troop(&"veloci", [&"Bellico"], &"rosso", 0, 500)
	var ghost: GhostDef = GhostDef.new()
	ghost.year = 1
	ghost.troops = [fast, slow]
	catalog.ghosts = [ghost]
	var run: RunState = _run()
	Aiuti.ascolta(run)
	assert_eq(run.offers.size(), 1)
	assert_true(run.buy_offer(0))
	assert_eq(run.spy_effects.size(), 1)
	assert_eq(run.spy_effects[0][1], BattleSim.TROOP_INDEX_OFFSET + 0, "La truppa più veloce.")
	while run.is_shopping_phase():
		run.pass_round()
	run.fight_ghost()
	var replay: BattleSim = run.make_battle_replay()
	assert_eq(replay.get_troop_state(BattleSim.SIDE_B, 0), BattleSim.TroopState.SABOTATA, "Parte sabotata.")
	assert_true(run.spy_effects.is_empty(), "Vale solo per lo scontro con il fantasma dell'anno.")


# --- Incanto (GDD §4.3) ----------------------------------------------------------------

func test_l_incanto_aggiunge_effetto_e_mana_una_sola_volta() -> void:
	var spell: OpportunityDef = OpportunityDef.new()
	spell.id = &"incanto_cura"
	spell.display_name = "Incanto: grazia"
	spell.kind = OpportunityDef.Kind.INCANTO
	spell.enchant_value = ModifierDef.BattleValue.CURA
	spell.enchant_amounts = PackedInt32Array([3, 5, 7])
	spell.enchant_color = &"blu"
	var priest: AdvisorDef = Aiuti.consigliere(&"sacerdote", [&"Spirituale"], [spell], Res.Type.FEDE)
	catalog.advisors = [priest]
	rules.half_themes = _themes(RunState.RoundTheme.AZIONI, 3)
	var run: RunState = _run()
	Aiuti.ascolta(run)
	assert_true(run.buy_offer(0), "Una sola truppa: nessuna scelta da fare.")
	var piece: BoardPiece = run.board.troops[0]
	var stats: TroopDef = run.effective_troop(piece)
	assert_eq(stats.heal, 3, "Cura dell'incanto (era 1).")
	assert_eq(stats.mana_cost, 2, "Ora chiede 2 mana...")
	assert_eq(stats.mana_type, &"blu", "...del colore dell'incanto, perché prima non ne chiedeva.")
	assert_eq(plain_troop.heal, 0, "La scheda del catalogo non cambia.")
	Aiuti.ascolta(run)
	assert_true(run.advisor_choices.is_empty() or run.offers.is_empty(), "Una truppa si incanta una sola volta.")


# --- Livelli del Consiglio (GDD §4.2.1) ----------------------------------------------

func test_le_azioni_di_livello_alto_arrivano_con_l_era() -> void:
	var small: OpportunityDef = OpportunityDef.new()
	small.id = &"esattori"
	small.kind = OpportunityDef.Kind.SCAMBIO_RISORSE
	small.gain_gold = 1
	var big: OpportunityDef = OpportunityDef.new()
	big.id = &"grandi_esattori"
	big.kind = OpportunityDef.Kind.SCAMBIO_RISORSE
	big.gain_gold = 6
	big.min_level = 2
	soldier.actions = [small, big]
	var era2: EraDef = EraDef.new()
	era2.research_cost = 1
	catalog.eras = [EraDef.new(), era2]
	rules.half_themes = _themes(RunState.RoundTheme.AZIONI, 3)
	var run: RunState = _run()
	assert_eq(run.council_level(), 1)
	assert_eq(run.council_level_name(), "Funzionari")
	Aiuti.ascolta(run)
	for offer: Offer in run.offers:
		assert_ne(offer.opportunity, big, "Al livello 1 le azioni di livello 2 non compaiono.")
	run.research = 1
	assert_true(run.advance_era())
	assert_eq(run.council_level(), 2, "Entrando nell'era 2 tutto il Consiglio sale di livello.")
	var seen: bool = false
	for offer: Offer in run.offers:
		if offer.opportunity == big:
			seen = true
	assert_true(seen, "Le proposte vengono ripescate e compare l'azione di livello 2.")
