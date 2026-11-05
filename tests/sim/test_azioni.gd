extends GutTest
## Verifiche delle azioni del Consiglio (GDD §4.2.3). Numeri solo di prova.
## Ogni prova usa un solo consigliere che propone solo l'azione da verificare (round Azioni).

const Aiuti = preload("res://tests/sim/aiuti_consiglio.gd")

var farm: BuildingDef
var sword: TroopDef
var spear: TroopDef
var killer: TroopDef
var catalog: CatalogDef
var run_rules: RunRules
var resistance_rules: ResistanceRules


func _opportunity(id: StringName, phase: OpportunityDef.Phase, kind: OpportunityDef.Kind) -> OpportunityDef:
	var def: OpportunityDef = OpportunityDef.new()
	def.id = id
	def.display_name = String(id)
	def.phase = phase
	def.kind = kind
	return def


func _bonus(id: StringName, effect: ModifierDef.Effect, amount: int, target: ModifierDef.Target = ModifierDef.Target.NAZIONE) -> ModifierDef:
	var def: ModifierDef = ModifierDef.new()
	def.id = id
	def.display_name = String(id)
	def.is_malus = false
	def.effect = effect
	def.amount = amount
	def.target = target
	return def


func before_each() -> void:
	farm = BuildingDef.new()
	farm.id = &"fattoria"
	farm.display_name = "Fattoria"
	farm.cost_gold = 3
	farm.gold_per_phase = 4
	farm.research_per_phase = 2
	sword = TroopDef.new()
	sword.id = &"spade"
	sword.display_name = "Spade"
	sword.cooldown_ms = 2000
	spear = TroopDef.new()
	spear.id = &"lance"
	spear.display_name = "Lance"
	spear.cooldown_ms = 2000
	killer = TroopDef.new()
	killer.id = &"distruttori"
	killer.cooldown_ms = 100
	killer.damage = 1000
	var era1: EraDef = EraDef.new()
	era1.display_name = "Prima"
	catalog = CatalogDef.new()
	catalog.buildings = [farm]
	catalog.troops = [sword]
	catalog.eras = [era1]
	run_rules = RunRules.new()
	run_rules.starting_gold = 10
	run_rules.prototype_years = 0
	run_rules.starting_buildings = [farm]
	run_rules.starting_troops = [sword, spear]
	resistance_rules = ResistanceRules.new()
	resistance_rules.per_era = [10]
	resistance_rules.per_year = 0
	resistance_rules.per_building = 0
	resistance_rules.per_troop = 0


## Un solo consigliere che propone queste azioni; tutti i round sono Azioni.
func _council(actions: Array[OpportunityDef]) -> void:
	Aiuti.consiglio_semplice(catalog, run_rules, actions)
	run_rules.half_themes = PackedInt32Array([RunState.RoundTheme.AZIONI, RunState.RoundTheme.AZIONI])


## Run in cui la prima proposta del consigliere è l'unica azione.
func _run_with(opportunity: OpportunityDef) -> RunState:
	_council([opportunity])
	var run: RunState = RunState.new(catalog, run_rules, BattleRules.new(), resistance_rules, 3)
	Aiuti.ascolta(run)
	return run


## Passa i round finché il consigliere ha qualcosa da proporre, poi lo ascolta.
func _until_advisor(run: RunState) -> void:
	while run.is_shopping_phase() and run.advisor_choices.is_empty():
		run.pass_round()
	Aiuti.ascolta(run)


# --- Pesca delle alternative -------------------------------------------------

func test_alternative_di_tipi_diversi() -> void:
	var list: Array[OpportunityDef] = []
	for i: int in range(5):
		var opportunity: OpportunityDef = _opportunity(StringName("scambio_%d" % i), OpportunityDef.Phase.PRODUZIONE, OpportunityDef.Kind.SCAMBIO_RISORSE)
		list.append(opportunity)
	_council(list)
	var run: RunState = RunState.new(catalog, run_rules, BattleRules.new(), resistance_rules, 3)
	Aiuti.ascolta(run)
	for attempt: int in range(20):
		assert_eq(run.offers.size(), 3)
		var ids: Dictionary[StringName, bool] = {}
		for offer: Offer in run.offers:
			assert_false(ids.has(offer.opportunity.id), "Nessuna azione ripetuta fra le proposte.")
			ids[offer.opportunity.id] = true
		run.gold += run.reroll_cost()
		run.reroll_offers()


# --- Scambio di risorse (Studiosi, Esattori, Mercante) ------------------------

func test_studiosi_oro_in_ricerca() -> void:
	var scholars: OpportunityDef = _opportunity(&"studiosi", OpportunityDef.Phase.PRODUZIONE, OpportunityDef.Kind.SCAMBIO_RISORSE)
	scholars.cost_gold = 3
	scholars.gain_research = 3
	var run: RunState = _run_with(scholars)
	var gold_before: int = run.gold
	var research_before: int = run.research
	assert_true(run.buy_offer(0))
	assert_eq(run.gold, gold_before - 3)
	assert_eq(run.research, research_before + 3)


func test_mercante_ricerca_in_oro_e_risorse_insufficienti() -> void:
	var merchant: OpportunityDef = _opportunity(&"mercante", OpportunityDef.Phase.PRODUZIONE, OpportunityDef.Kind.SCAMBIO_RISORSE)
	merchant.cost_research = 2
	merchant.gain_gold = 4
	var run: RunState = _run_with(merchant)
	run.research = 1
	assert_false(run.can_afford(run.offers[0]))
	assert_false(run.buy_offer(0), "Ricerca insufficiente.")
	run.research = 2
	var gold_before: int = run.gold
	assert_true(run.buy_offer(0))
	assert_eq(run.research, 0)
	assert_eq(run.gold, gold_before + 4)


# --- Modificatore a scelta (Assemblea, Addestramento, Fortificazioni) ----------

func test_assemblea_si_sceglie_il_bonus() -> void:
	var assembly: OpportunityDef = _opportunity(&"assemblea", OpportunityDef.Phase.PRODUZIONE, OpportunityDef.Kind.MODIFICATORE_A_SCELTA)
	assembly.modifiers = [_bonus(&"oro", ModifierDef.Effect.PRODUZIONE_ORO, 50), _bonus(&"ricerca", ModifierDef.Effect.PRODUZIONE_RICERCA, 50)]
	var run: RunState = _run_with(assembly)
	assert_eq(run.offer_choices(run.offers[0]).size(), 2, "Due bonus fra cui scegliere.")
	assert_false(run.buy_offer(0), "Senza scelta non si può prendere.")
	assert_true(run.buy_offer(0, 1))
	assert_eq(run.modifiers.active.size(), 1)
	assert_eq(run.modifiers.active[0].def.id, &"ricerca")
	assert_eq(run.modifiers.active[0].origin_name, "assemblea", "L'origine è l'azione.")
	assert_eq(run.production_preview().y, 3, "2 Ricerca +50%.")


func test_addestramento_sulla_truppa_scelta() -> void:
	var training: OpportunityDef = _opportunity(&"addestramento", OpportunityDef.Phase.PREPARAZIONE, OpportunityDef.Kind.MODIFICATORE_A_SCELTA)
	training.modifiers = [_bonus(&"addestramento", ModifierDef.Effect.RICARICA_TRUPPA, -25, ModifierDef.Target.TRUPPA_SCELTA)]
	var run: RunState = _run_with(training)
	assert_eq(run.offer_choices(run.offers[0]).size(), 2, "Una voce per ogni truppa.")
	assert_true(run.buy_offer(0, 1))
	assert_eq(run.effective_troop(run.board.troops[1]).cooldown_ms, 1500, "2000 ms -25%.")
	assert_eq(run.effective_troop(run.board.troops[0]).cooldown_ms, 2000, "L'altra truppa non cambia.")


func test_addestramento_non_compare_senza_truppe() -> void:
	run_rules.starting_troops = []
	var training: OpportunityDef = _opportunity(&"addestramento", OpportunityDef.Phase.PREPARAZIONE, OpportunityDef.Kind.MODIFICATORE_A_SCELTA)
	training.modifiers = [_bonus(&"addestramento", ModifierDef.Effect.RICARICA_TRUPPA, -25, ModifierDef.Target.TRUPPA_SCELTA)]
	var run: RunState = _run_with(training)
	assert_true(run.advisor_choices.is_empty(), "Un consigliere senza proposte non compare.")
	assert_eq(run.offers.size(), 0)


func test_fortificazioni_solo_per_il_prossimo_fantasma() -> void:
	var walls_bonus: ModifierDef = _bonus(&"mura", ModifierDef.Effect.RESISTENZA, 10)
	walls_bonus.duration_kind = ModifierDef.Duration.PROSSIMO_SCONTRO_FANTASMA
	var walls: OpportunityDef = _opportunity(&"fortificazioni", OpportunityDef.Phase.PREPARAZIONE, OpportunityDef.Kind.MODIFICATORE_A_SCELTA)
	walls.modifiers = [walls_bonus]
	var ghost: GhostDef = GhostDef.new()
	ghost.year = 1
	catalog.ghosts = [ghost]
	var run: RunState = _run_with(walls)
	var before: int = run.player_resistance()
	assert_true(run.buy_offer(0), "Un solo modificatore: nessuna scelta da fare.")
	assert_eq(run.player_resistance(), before + 10)
	while run.is_shopping_phase():
		run.pass_round()
	run.fight_ghost()
	assert_eq(run.last_battle.get_max_resistance(BattleSim.SIDE_A), before + 10, "Vale nello scontro con il fantasma.")
	assert_eq(run.modifiers.active.size(), 0, "Poi finisce.")


# --- Ambasciata ---------------------------------------------------------------

func _embassy() -> OpportunityDef:
	var embassy: OpportunityDef = _opportunity(&"ambasciata", OpportunityDef.Phase.PREPARAZIONE, OpportunityDef.Kind.ACCORCIA_MALUS)
	embassy.shorten_years = 1
	return embassy


func _malus(id: StringName, years: int) -> ModifierDef:
	var def: ModifierDef = ModifierDef.new()
	def.id = id
	def.display_name = String(id)
	def.effect = ModifierDef.Effect.PRODUZIONE_ORO
	def.amount = -50
	def.duration_years = years
	return def


func test_ambasciata_non_compare_senza_malus() -> void:
	var run: RunState = _run_with(_embassy())
	assert_true(run.advisor_choices.is_empty(), "Senza malus il consigliere non ha nulla da proporre.")
	assert_eq(run.offers.size(), 0)


func test_ambasciata_accorcia_e_fa_sparire() -> void:
	_council([_embassy()])
	var run: RunState = RunState.new(catalog, run_rules, BattleRules.new(), resistance_rules, 3)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	run.modifiers.apply(_malus(&"lungo", 2), ActiveModifier.OriginKind.FANTASMA, "Prova", 0, run.board, rng)
	run.modifiers.apply(_malus(&"breve", 1), ActiveModifier.OriginKind.FANTASMA, "Prova", 0, run.board, rng)
	_until_advisor(run)
	assert_eq(run.offers.size(), 1, "Ora l'Ambasciata compare.")
	assert_eq(run.offer_choices(run.offers[0]).size(), 2, "Si sceglie quale malus.")
	assert_true(run.buy_offer(0, 1), "Accorcia il malus breve: durava fino alla fine dell'anno 1.")
	assert_eq(run.modifiers.active.size(), 1, "Il malus breve sparisce.")
	assert_eq(run.modifiers.active[0].def.id, &"lungo")
	assert_eq(run.modifiers.active[0].expires_at_year, 3, "Quello lungo resta com'era.")


func test_ambasciata_accorcia_senza_far_sparire() -> void:
	_council([_embassy()])
	var run: RunState = RunState.new(catalog, run_rules, BattleRules.new(), resistance_rules, 3)
	run.modifiers.apply(_malus(&"lungo", 2), ActiveModifier.OriginKind.FANTASMA, "Prova", 0, run.board, RandomNumberGenerator.new())
	_until_advisor(run)
	assert_true(run.buy_offer(0), "Un solo malus: nessuna scelta da fare.")
	assert_eq(run.modifiers.active[0].expires_at_year, 2, "Ora dura fino alla fine dell'anno 1.")
