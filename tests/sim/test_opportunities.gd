extends GutTest
## Verifiche delle azioni del Consiglio (GDD §4.2, §4.3, §12). Numeri solo di prova.

var farm: BuildingDef
var sword: TroopDef
var spear: TroopDef
var killer: TroopDef
var catalog: CatalogDef
var run_rules: RunRules
var resistance_rules: ResistanceRules


var council: CouncillorDef


func _opportunity(id: StringName, kind: OpportunityDef.Kind) -> OpportunityDef:
	var def: OpportunityDef = OpportunityDef.new()
	def.id = id
	def.display_name = String(id)
	def.councillor = &"consigliere"
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
	# Un solo consigliere, che propone solo azioni: così le proposte sono le azioni del test.
	council = CouncillorDef.new()
	council.id = &"consigliere"
	council.display_name = "Consigliere"
	catalog.councillors = [council]
	run_rules.round_types = PackedInt32Array([0, 0, 0, 0, 0])


## Run in cui il consigliere è già scelto e l'azione indicata è la sua unica proposta.
## Se l'azione non ha senso il consigliere non compare e non ci sono proposte.
func _run_with(opportunity: OpportunityDef) -> RunState:
	catalog.opportunities = [opportunity]
	var run: RunState = RunState.new(catalog, run_rules, BattleRules.new(), resistance_rules, 3)
	_listen(run)
	return run


func _listen(run: RunState) -> void:
	if run.is_choosing_councillor() and not run.councillor_choices.is_empty():
		run.choose_councillor(0)


## Passa i round fino alla Preparazione e sceglie il consigliere.
func _to_preparation(run: RunState) -> void:
	while run.phase == RunState.Phase.PRODUZIONE:
		run.pass_opportunity()
	# Nessun incontro nei dati: si arriva subito in Preparazione.
	_listen(run)


# --- Pesca delle proposte -------------------------------------------------

func test_proposte_diverse_fra_loro() -> void:
	var list: Array[OpportunityDef] = []
	for i: int in range(5):
		var opportunity: OpportunityDef = _opportunity(StringName("scambio_%d" % i), OpportunityDef.Kind.SCAMBIO_RISORSE)
		list.append(opportunity)
	catalog.opportunities = list
	var run: RunState = RunState.new(catalog, run_rules, BattleRules.new(), resistance_rules, 3)
	_listen(run)
	for attempt: int in range(20):
		assert_eq(run.offers.size(), 3)
		var ids: Dictionary[StringName, bool] = {}
		for offer: Offer in run.offers:
			assert_false(ids.has(offer.opportunity.id), "Nessuna proposta ripetuta.")
			ids[offer.opportunity.id] = true
		run.gold += run.reroll_cost()
		run.reroll_offers()


# --- Scambio di risorse (Studiosi, Esattori, Mercante) ------------------------

func test_studiosi_oro_in_ricerca() -> void:
	var scholars: OpportunityDef = _opportunity(&"studiosi", OpportunityDef.Kind.SCAMBIO_RISORSE)
	scholars.cost_gold = 3
	scholars.gain_research = 3
	var run: RunState = _run_with(scholars)
	var gold_before: int = run.gold
	var research_before: int = run.research
	assert_true(run.buy_offer(0))
	assert_eq(run.gold, gold_before - 3)
	assert_eq(run.research, research_before + 3)


func test_mercante_ricerca_in_oro_e_risorse_insufficienti() -> void:
	var merchant: OpportunityDef = _opportunity(&"mercante", OpportunityDef.Kind.SCAMBIO_RISORSE)
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
	var assembly: OpportunityDef = _opportunity(&"assemblea", OpportunityDef.Kind.MODIFICATORE_A_SCELTA)
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
	var training: OpportunityDef = _opportunity(&"addestramento", OpportunityDef.Kind.MODIFICATORE_A_SCELTA)
	training.modifiers = [_bonus(&"addestramento", ModifierDef.Effect.RICARICA_TRUPPA, -25, ModifierDef.Target.TRUPPA_SCELTA)]
	var run: RunState = _run_with(training)
	assert_eq(run.offer_choices(run.offers[0]).size(), 2, "Una voce per ogni truppa.")
	assert_true(run.buy_offer(0, 1))
	assert_eq(run.effective_troop(run.board.troops[1]).cooldown_ms, 1500, "2000 ms -25%.")
	assert_eq(run.effective_troop(run.board.troops[0]).cooldown_ms, 2000, "L'altra truppa non cambia.")


func test_addestramento_non_compare_senza_truppe() -> void:
	run_rules.starting_troops = []
	var training: OpportunityDef = _opportunity(&"addestramento", OpportunityDef.Kind.MODIFICATORE_A_SCELTA)
	training.modifiers = [_bonus(&"addestramento", ModifierDef.Effect.RICARICA_TRUPPA, -25, ModifierDef.Target.TRUPPA_SCELTA)]
	var run: RunState = _run_with(training)
	assert_eq(run.offers.size(), 0)


func test_fortificazioni_solo_per_il_prossimo_fantasma() -> void:
	var walls_bonus: ModifierDef = _bonus(&"mura", ModifierDef.Effect.RESISTENZA, 10)
	walls_bonus.duration_kind = ModifierDef.Duration.PROSSIMO_SCONTRO_FANTASMA
	var walls: OpportunityDef = _opportunity(&"fortificazioni", OpportunityDef.Kind.MODIFICATORE_A_SCELTA)
	walls.modifiers = [walls_bonus]
	var ghost: GhostDef = GhostDef.new()
	ghost.year = 1
	catalog.ghosts = [ghost]
	var run: RunState = _run_with(walls)
	var before: int = run.player_resistance()
	assert_true(run.buy_offer(0), "Un solo modificatore: nessuna scelta da fare.")
	assert_eq(run.player_resistance(), before + 10)
	while run.is_shopping_phase():
		run.pass_opportunity()
	run.fight_ghost()
	assert_eq(run.last_battle.get_max_resistance(BattleSim.SIDE_A), before + 10, "Vale nello scontro con il fantasma.")
	assert_eq(run.modifiers.active.size(), 0, "Poi finisce.")


# --- Ambasciata ---------------------------------------------------------------

func _embassy() -> OpportunityDef:
	var embassy: OpportunityDef = _opportunity(&"ambasciata", OpportunityDef.Kind.ACCORCIA_MALUS)
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
	assert_eq(run.offers.size(), 0)


func test_ambasciata_accorcia_e_fa_sparire() -> void:
	catalog.opportunities = [_embassy()]
	var run: RunState = RunState.new(catalog, run_rules, BattleRules.new(), resistance_rules, 3)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	run.modifiers.apply(_malus(&"lungo", 2), ActiveModifier.OriginKind.FANTASMA, "Prova", 0, run.board, rng)
	run.modifiers.apply(_malus(&"breve", 1), ActiveModifier.OriginKind.FANTASMA, "Prova", 0, run.board, rng)
	_to_preparation(run)
	assert_eq(run.phase, RunState.Phase.PREPARAZIONE)
	assert_eq(run.offers.size(), 1, "Ora l'Ambasciata compare.")
	assert_eq(run.offer_choices(run.offers[0]).size(), 2, "Si sceglie quale malus.")
	assert_true(run.buy_offer(0, 1), "Accorcia il malus breve: durava fino alla fine dell'anno 1.")
	assert_eq(run.modifiers.active.size(), 1, "Il malus breve sparisce.")
	assert_eq(run.modifiers.active[0].def.id, &"lungo")
	assert_eq(run.modifiers.active[0].expires_at_year, 3, "Quello lungo resta com'era.")


func test_ambasciata_accorcia_senza_far_sparire() -> void:
	catalog.opportunities = [_embassy()]
	var run: RunState = RunState.new(catalog, run_rules, BattleRules.new(), resistance_rules, 3)
	run.modifiers.apply(_malus(&"lungo", 2), ActiveModifier.OriginKind.FANTASMA, "Prova", 0, run.board, RandomNumberGenerator.new())
	_to_preparation(run)
	assert_true(run.buy_offer(0), "Un solo malus: nessuna scelta da fare.")
	assert_eq(run.modifiers.active[0].expires_at_year, 2, "Ora dura fino alla fine dell'anno 1.")


# --- Potenziamenti del Consiglio (GDD §4.2.3) ----------------------------------------

func test_veterani_potenziano_la_truppa_scelta() -> void:
	var veterans: OpportunityDef = _opportunity(&"veterani", OpportunityDef.Kind.POTENZIA_TRUPPA)
	var iron: ResourceAmounts = ResourceAmounts.new()
	iron.ferro = 3
	veterans.cost_resources = iron
	var run: RunState = _run_with(veterans)
	run.stock[Res.Type.FERRO] = 3
	assert_eq(run.offer_choices(run.offers[0]).size(), 2, "Una voce per ogni truppa.")
	assert_true(run.buy_offer(0, 1))
	assert_eq(run.board.troops[1].level, 2)
	assert_eq(run.board.troops[0].level, 1)
	assert_eq(run.stock[Res.Type.FERRO], 0, "Si paga il costo della proposta, non quello del potenziamento.")


func test_niente_potenziamento_al_livello_massimo() -> void:
	var masters: OpportunityDef = _opportunity(&"maestri", OpportunityDef.Kind.POTENZIA_EDIFICIO)
	run_rules.max_level = 3
	var run: RunState = RunState.new(catalog, run_rules, BattleRules.new(), resistance_rules, 3)
	run.board.buildings[0].level = 3
	catalog.opportunities = [masters]
	run.pass_opportunity()
	assert_true(run.councillor_choices.is_empty(), "Nessun edificio da potenziare: il consigliere non ha proposte.")


# --- Incanto (GDD §4.3) ---------------------------------------------------------

func _enchant(effect: OpportunityDef.Enchant, value: int) -> OpportunityDef:
	var def: OpportunityDef = _opportunity(&"incanto", OpportunityDef.Kind.INCANTA)
	def.enchant_effect = effect
	def.enchant_value = value
	def.enchant_mana_cost = 2
	def.enchant_mana_type = &"blu"
	return def


func test_incanto_aggiunge_effetto_e_mana() -> void:
	sword.damage = 3
	var run: RunState = _run_with(_enchant(OpportunityDef.Enchant.SCUDO, 2))
	assert_true(run.buy_offer(0, 0))
	var troop: TroopDef = run.effective_troop(run.board.troops[0])
	assert_eq(troop.shield, 2, "La truppa ottiene lo scudo che non aveva.")
	assert_eq(troop.damage, 3, "Il resto non cambia.")
	assert_eq(troop.mana_cost, 2, "Senza mana prima: ora ne chiede 2.")
	assert_eq(troop.mana_type, &"blu", "Del colore dell'incanto.")
	assert_eq(run.effective_troop(run.board.troops[1]).shield, 0, "L'altra truppa non è incantata.")


func test_incanto_somma_il_mana_della_truppa_e_cresce_con_il_livello() -> void:
	sword.mana_cost = 1
	sword.mana_type = &"rosso"
	sword.damage = 2
	var run: RunState = _run_with(_enchant(OpportunityDef.Enchant.DANNO, 2))
	assert_true(run.buy_offer(0, 0))
	run.board.troops[0].level = 2
	var troop: TroopDef = run.effective_troop(run.board.troops[0])
	assert_eq(troop.mana_cost, 3, "1 + 2 mana.")
	assert_eq(troop.mana_type, &"rosso", "Resta il colore della truppa.")
	assert_eq(troop.damage, 6, "(2 + 2) al livello 2: +50%.")


func test_una_truppa_si_incanta_una_volta_sola() -> void:
	run_rules.starting_troops = [sword]
	var run: RunState = _run_with(_enchant(OpportunityDef.Enchant.CURA, 1))
	assert_true(run.buy_offer(0), "Una sola truppa: nessuna scelta.")
	assert_not_null(run.board.troops[0].enchantment)
	assert_true(run.councillor_choices.is_empty(), "Nessuna truppa da incantare: il consigliere non compare.")


func test_incanto_del_rallentamento() -> void:
	var slow: OpportunityDef = _enchant(OpportunityDef.Enchant.RALLENTAMENTO, 1500)
	slow.enchant_slow_target = TimerTarget.Kind.EDIFICI
	var run: RunState = _run_with(slow)
	assert_true(run.buy_offer(0, 0))
	var troop: TroopDef = run.effective_troop(run.board.troops[0])
	assert_eq(troop.inefficiency_ms, 1500)
	assert_eq(troop.inefficiency_target, TimerTarget.Kind.EDIFICI)


# --- Spionaggio (GDD §12) -------------------------------------------------------

func _spy(sabotage: bool, target: TimerTarget.Kind, criterion: TimerTarget.Criterion) -> OpportunityDef:
	var def: OpportunityDef = _opportunity(&"spie", OpportunityDef.Kind.SPIONAGGIO)
	def.spy_sabotage = sabotage
	def.spy_duration_ms = 5000
	def.spy_target = target
	def.spy_criterion = criterion
	return def


func _ghost_with(troops: Array[TroopDef]) -> void:
	var ghost: GhostDef = GhostDef.new()
	ghost.year = 1
	ghost.troops = troops
	catalog.ghosts = [ghost]


func _fight_after_shopping(run: RunState) -> void:
	while run.is_shopping_phase():
		run.pass_opportunity()
	assert_true(run.fight_ghost())


func _troop(id: StringName, cooldown: int) -> TroopDef:
	var def: TroopDef = TroopDef.new()
	def.id = id
	def.cooldown_ms = cooldown
	return def


func test_spionaggio_sabota_la_truppa_piu_a_destra() -> void:
	_ghost_with([_troop(&"a", 1000), _troop(&"b", 2000), _troop(&"c", 3000)])
	var run: RunState = _run_with(_spy(true, TimerTarget.Kind.TRUPPE, TimerTarget.Criterion.PIU_A_DESTRA))
	assert_true(run.buy_offer(0))
	_fight_after_shopping(run)
	var sabotage: BattleEvent = _first_event(run.make_battle_replay(), BattleEvent.Kind.SABOTATO)
	assert_not_null(sabotage, "Lo scontro parte con un sabotaggio.")
	assert_eq(sabotage.side, BattleSim.SIDE_B, "Colpisce il fantasma.")
	assert_eq(sabotage.index, BattleSim.TROOP_INDEX_OFFSET + 2, "La truppa più a destra.")
	assert_eq(run.spy_actions.size(), 0, "Dopo lo scontro lo spionaggio è consumato.")


func test_spionaggio_rallenta_la_truppa_piu_veloce_o_piu_lenta() -> void:
	for criterion: TimerTarget.Criterion in [TimerTarget.Criterion.PIU_VELOCE, TimerTarget.Criterion.PIU_LENTO]:
		_ghost_with([_troop(&"a", 2000), _troop(&"b", 1000), _troop(&"c", 3000)])
		var run: RunState = _run_with(_spy(false, TimerTarget.Kind.TRUPPE, criterion))
		assert_true(run.buy_offer(0))
		_fight_after_shopping(run)
		var slow: BattleEvent = _first_event(run.make_battle_replay(), BattleEvent.Kind.RALLENTATO)
		var expected: int = 1 if criterion == TimerTarget.Criterion.PIU_VELOCE else 2
		assert_eq(slow.index, BattleSim.TROOP_INDEX_OFFSET + expected, "Criterio %s." % TimerTarget.CRITERION_NAMES[criterion])


func test_spionaggio_solo_se_c_e_un_fantasma() -> void:
	catalog.ghosts = []
	var run: RunState = _run_with(_spy(true, TimerTarget.Kind.TRUPPE, TimerTarget.Criterion.A_CASO))
	assert_eq(run.offers.size(), 0)


func _first_event(sim: BattleSim, kind: BattleEvent.Kind) -> BattleEvent:
	for event: BattleEvent in sim.events:
		if event.kind == kind:
			return event
	return null


# --- Perk dell'Anziano, scorte, Clown (GDD §4.2.2) ------------------------------------

func _perk(id: StringName) -> IdentityDef:
	var def: IdentityDef = IdentityDef.new()
	def.id = id
	def.display_name = String(id)
	def.dimension = IdentityDef.Dimension.PERK
	return def


func test_l_anziano_propone_perk_non_posseduti_ed_edifici_neutri() -> void:
	var elder: CouncillorDef = CouncillorDef.new()
	elder.id = &"anziano"
	elder.special = CouncillorDef.Special.ANZIANO
	catalog.councillors = [elder]
	var wisdom: OpportunityDef = _opportunity(&"saggezza", OpportunityDef.Kind.PERK)
	wisdom.councillor = &"anziano"
	catalog.opportunities = [wisdom]
	var neutral: BuildingDef = BuildingDef.new()
	neutral.id = &"mura"
	neutral.mana_amount = 0
	farm.mana_amount = 1
	catalog.buildings = [farm, neutral]
	var run: RunState = RunState.new(catalog, run_rules, BattleRules.new(), resistance_rules, 3)
	catalog.identities = [_perk(&"uno"), _perk(&"due")]
	run.pass_opportunity()
	assert_true(run.choose_councillor(0))
	var perks: int = 0
	for offer: Offer in run.offers:
		if offer.perk != null:
			perks += 1
		else:
			assert_eq(offer.building, neutral, "Solo edifici neutri.")
	assert_eq(perks, 2, "Un perk per proposta, diversi fra loro.")
	for i: int in range(run.offers.size()):
		if run.offers[i].perk != null:
			var perk: IdentityDef = run.offers[i].perk
			assert_true(run.buy_offer(i))
			assert_true(run.identity.has(perk), "Il perk entra nell'identità.")
			break


func test_scorte_danno_altre_risorse() -> void:
	var supplies: OpportunityDef = _opportunity(&"scorte", OpportunityDef.Kind.SCAMBIO_RISORSE)
	var gain: ResourceAmounts = ResourceAmounts.new()
	gain.cibo = 2
	gain.fauna = 2
	supplies.gain_resources = gain
	var run: RunState = _run_with(supplies)
	var food: int = run.stock[Res.Type.CIBO]
	assert_true(run.buy_offer(0))
	assert_eq(run.stock[Res.Type.CIBO], food + 20, "2 Cibo (in decimi).")
	assert_eq(run.stock[Res.Type.FAUNA], 2)


func test_il_clown_propone_elementi_di_mana_diverso() -> void:
	var clown: CouncillorDef = CouncillorDef.new()
	clown.id = &"clown"
	clown.special = CouncillorDef.Special.CLOWN
	catalog.councillors = [clown]
	var colors: Array[StringName] = [&"rosso", &"verde", &"blu"]
	var buildings: Array[BuildingDef] = []
	for color: StringName in colors:
		for i: int in range(2):
			var def: BuildingDef = BuildingDef.new()
			def.id = StringName("%s_%d" % [color, i])
			def.mana_type = color
			def.mana_amount = 1
			buildings.append(def)
	var neutral: BuildingDef = BuildingDef.new()
	neutral.id = &"neutro"
	neutral.mana_amount = 0
	buildings.append(neutral)
	catalog.buildings = buildings
	catalog.troops = [sword]
	var run: RunState = RunState.new(catalog, run_rules, BattleRules.new(), resistance_rules, 3)
	assert_true(run.choose_councillor(0))
	assert_eq(run.offers.size(), 4, "Il Clown propone 4 elementi.")
	var seen: Array[StringName] = []
	for offer: Offer in run.offers:
		var mana: StringName = RunState._offer_mana(offer)
		assert_false(seen.has(mana), "Ognuno di un mana diverso.")
		seen.append(mana)
