extends GutTest
## Verifiche dei modificatori (GDD §8, §13.2, §17: "Modificatore pluriennale").
## I numeri qui servono solo ai test e non sono valori di gioco.

var farm: BuildingDef
var library: BuildingDef
var sword: TroopDef
var killer: TroopDef
var twin: TroopDef
var catalog: CatalogDef
var run_rules: RunRules
var resistance_rules: ResistanceRules


func _modifier(id: StringName, effect: ModifierDef.Effect, amount: int,
		target: ModifierDef.Target = ModifierDef.Target.NAZIONE,
		stacking: ModifierDef.Stacking = ModifierDef.Stacking.ALLUNGA_DURATA) -> ModifierDef:
	var def: ModifierDef = ModifierDef.new()
	def.id = id
	def.display_name = String(id)
	def.effect = effect
	def.amount = amount
	def.target = target
	def.stacking = stacking
	def.duration_years = 1
	return def


func before_each() -> void:
	farm = BuildingDef.new()
	farm.id = &"fattoria"
	farm.display_name = "Fattoria"
	farm.cost_gold = 3
	farm.gold_per_phase = 4
	farm.mana_interval_ms = 1000
	library = BuildingDef.new()
	library.id = &"biblioteca"
	library.display_name = "Biblioteca"
	library.cost_gold = 4
	library.research_per_phase = 5
	library.mana_interval_ms = 2000
	sword = TroopDef.new()
	sword.id = &"spade"
	sword.display_name = "Spade"
	sword.cooldown_ms = 2000
	sword.food_tenths = 0  # Qui non si prova la fame.
	killer = TroopDef.new()
	killer.id = &"distruttori"
	killer.cooldown_ms = 100
	killer.damage = 1000
	twin = TroopDef.new()
	twin.id = &"gemelli"
	twin.cooldown_ms = 100
	twin.damage = 10

	var era1: EraDef = EraDef.new()
	era1.display_name = "Prima"
	catalog = CatalogDef.new()
	catalog.buildings = [farm, library]
	catalog.troops = [sword]
	catalog.eras = [era1]
	run_rules = RunRules.new()
	run_rules.starting_gold = 0
	run_rules.prototype_years = 0
	run_rules.starting_buildings = [farm, library]
	run_rules.starting_troops = [sword]
	resistance_rules = ResistanceRules.new()
	resistance_rules.per_era = [10]
	resistance_rules.per_year = 0
	resistance_rules.per_building = 0
	resistance_rules.per_troop = 0


## Fantasmi per 5 anni: tutti con le stesse truppe e gli stessi malus.
func _set_ghosts(troops: Array[TroopDef], malus: Array[ModifierDef]) -> void:
	var ghosts: Array[GhostDef] = []
	for y: int in range(1, 6):
		var ghost: GhostDef = GhostDef.new()
		ghost.display_name = "Fantasma di Prova %d" % y
		ghost.year = y
		ghost.era = 1
		ghost.troops = troops
		ghost.malus = malus
		ghosts.append(ghost)
	catalog.ghosts = ghosts


func _new_run() -> RunState:
	return RunState.new(catalog, run_rules, BattleRules.new(), resistance_rules, 99)


func _play_year(run: RunState) -> void:
	while run.is_shopping_phase() or run.phase == RunState.Phase.SCELTA_INCONTRO or run.phase == RunState.Phase.RICOMPENSA_INCONTRO:
		if run.is_shopping_phase():
			run.pass_opportunity()
		else:
			# Nessun incontro nei dati: si passa direttamente alla Preparazione.
			break
	run.fight_ghost()


# --- Origine e momento in cui arriva il malus --------------------------------

func test_sconfitta_applica_il_malus_con_il_nome_del_fantasma() -> void:
	var half_research: ModifierDef = _modifier(&"ricerca_dimezzata", ModifierDef.Effect.PRODUZIONE_RICERCA, -50)
	_set_ghosts([killer], [half_research])
	var run: RunState = _new_run()
	_play_year(run)
	assert_eq(run.modifiers.active.size(), 1)
	var modifier: ActiveModifier = run.modifiers.active[0]
	assert_eq(modifier.origin_kind, ActiveModifier.OriginKind.FANTASMA)
	assert_eq(modifier.origin_name, "Fantasma di Prova 1", "Il malus porta il nome di chi l'ha inflitto.")
	assert_string_contains(modifier.describe(), "Fantasma di Prova 1")


func test_pareggio_applica_il_malus() -> void:
	run_rules.starting_troops = [twin]
	run_rules.starting_buildings = []
	_set_ghosts([twin], [_modifier(&"m", ModifierDef.Effect.PRODUZIONE_ORO, -50)])
	var run: RunState = _new_run()
	_play_year(run)
	assert_eq(run.last_battle.outcome, BattleSim.Outcome.PAREGGIO)
	assert_eq(run.wins, 1, "Il pareggio conta come vittoria...")
	assert_eq(run.modifiers.active.size(), 1, "...ma applica il malus del fantasma.")


func test_vittoria_non_applica_malus() -> void:
	run_rules.starting_troops = [killer]
	_set_ghosts([], [_modifier(&"m", ModifierDef.Effect.PRODUZIONE_ORO, -50)])
	var run: RunState = _new_run()
	_play_year(run)
	assert_eq(run.modifiers.active.size(), 0)


# --- Durata (GDD §17: applicato per la durata prevista e poi rimosso) --------

func test_ricerca_dimezzata_per_un_anno_e_poi_rimossa() -> void:
	_set_ghosts([killer], [_modifier(&"ricerca_dimezzata", ModifierDef.Effect.PRODUZIONE_RICERCA, -50)])
	var run: RunState = _new_run()
	assert_eq(run.production_preview().y, 5, "Anno 1: Ricerca piena.")
	_play_year(run)
	assert_eq(run.year, 2)
	assert_eq(run.production_preview().y, 2, "Anno 2: Ricerca dimezzata (5 diventa 2).")
	assert_eq(run.modifiers.active[0].expires_at_year, 3)
	# Nell'anno 2 il fantasma (già fissato a inizio anno) viene reso innocuo: si vince e non arriva un nuovo malus.
	run.board.troops.append(BoardPiece.of_troop(killer, 0))
	run.current_ghost.troops = []
	run.current_ghost.malus = []
	_play_year(run)
	assert_eq(run.year, 3)
	assert_eq(run.modifiers.active.size(), 0, "All'inizio dell'anno 3 il malus è finito.")
	assert_eq(run.production_preview().y, 5)


func test_la_produzione_dimezzata_si_vede_nella_raccolta() -> void:
	_set_ghosts([killer], [_modifier(&"oro_dimezzato", ModifierDef.Effect.PRODUZIONE_ORO, -50)])
	var run: RunState = _new_run()
	assert_eq(run.gold, 4, "Anno 1: 4 Oro dalla fattoria.")
	_play_year(run)
	# Preparazione dell'anno 1 (+4) e Produzione dell'anno 2 con malus (+2).
	assert_eq(run.gold, 4 + 4 + 2)


# --- Cumulabilità -----------------------------------------------------------

func test_stesso_malus_allunga_solo_la_durata() -> void:
	var half: ModifierDef = _modifier(&"ricerca_dimezzata", ModifierDef.Effect.PRODUZIONE_RICERCA, -50)
	_set_ghosts([killer], [half])
	var run: RunState = _new_run()
	_play_year(run)
	_play_year(run)
	assert_eq(run.modifiers.active.size(), 1, "Resta un solo malus.")
	assert_eq(run.modifiers.active[0].expires_at_year, 4, "La durata si allunga di un anno.")
	assert_eq(run.production_preview().y, 2, "L'effetto non raddoppia.")


func test_cumulabilita_somma_effetti() -> void:
	var stacking: ModifierDef = _modifier(&"somma", ModifierDef.Effect.PRODUZIONE_RICERCA, -20,
			ModifierDef.Target.NAZIONE, ModifierDef.Stacking.SOMMA_EFFETTI)
	var mods: Modifiers = Modifiers.new()
	var board: NationBoard = NationBoard.new()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	mods.apply(stacking, ActiveModifier.OriginKind.ALTRO, "Prova", 1, board, rng)
	mods.apply(stacking, ActiveModifier.OriginKind.ALTRO, "Prova", 1, board, rng)
	assert_eq(mods.percent(ModifierDef.Effect.PRODUZIONE_RICERCA), -40)


func test_cumulabilita_nessun_effetto() -> void:
	var single: ModifierDef = _modifier(&"singolo", ModifierDef.Effect.PRODUZIONE_ORO, -50,
			ModifierDef.Target.NAZIONE, ModifierDef.Stacking.NESSUN_EFFETTO)
	var mods: Modifiers = Modifiers.new()
	var board: NationBoard = NationBoard.new()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	mods.apply(single, ActiveModifier.OriginKind.ALTRO, "Prova", 1, board, rng)
	mods.apply(single, ActiveModifier.OriginKind.ALTRO, "Prova", 1, board, rng)
	assert_eq(mods.active.size(), 1)
	assert_eq(mods.active[0].expires_at_year, 3, "Durata invariata.")


# --- Effetti in battaglia -----------------------------------------------------

func test_inefficienza_rallenta_un_edificio_in_battaglia() -> void:
	_set_ghosts([killer], [_modifier(&"inefficienza", ModifierDef.Effect.INTERVALLO_MANA, 50, ModifierDef.Target.EDIFICIO_A_CASO)])
	var run: RunState = _new_run()
	_play_year(run)
	var modifier: ActiveModifier = run.modifiers.active[0]
	assert_not_null(modifier.target_piece, "Colpisce un edificio preciso.")
	var target_index: int = run.board.buildings.find(modifier.target_piece)
	var original: int = modifier.target_piece.building.mana_interval_ms
	_play_year(run)
	var used: BuildingDef = run.last_battle_setups()[0].buildings[target_index]
	assert_eq(used.mana_interval_ms, original + original / 2, "Intervallo +50% in battaglia.")
	assert_eq(modifier.target_piece.building.mana_interval_ms, original, "La scheda del catalogo non cambia.")


func test_ricarica_piu_lunga_per_una_truppa() -> void:
	_set_ghosts([killer], [_modifier(&"ricarica_lenta", ModifierDef.Effect.RICARICA_TRUPPA, 50, ModifierDef.Target.TRUPPA_A_CASO)])
	var run: RunState = _new_run()
	_play_year(run)
	_play_year(run)
	assert_eq(run.last_battle_setups()[0].troops[0].cooldown_ms, 3000, "2000 ms +50%.")


func test_vendere_il_bersaglio_toglie_il_malus() -> void:
	_set_ghosts([killer], [_modifier(&"inefficienza", ModifierDef.Effect.INTERVALLO_MANA, 50, ModifierDef.Target.EDIFICIO_A_CASO)])
	var run: RunState = _new_run()
	_play_year(run)
	var target_index: int = run.board.buildings.find(run.modifiers.active[0].target_piece)
	assert_true(run.sell_building(target_index))
	assert_eq(run.modifiers.active.size(), 0)


func test_malus_su_bersaglio_assente_non_ha_effetto() -> void:
	run_rules.starting_buildings = []
	_set_ghosts([killer], [_modifier(&"inefficienza", ModifierDef.Effect.INTERVALLO_MANA, 50, ModifierDef.Target.EDIFICIO_A_CASO)])
	var run: RunState = _new_run()
	_play_year(run)
	assert_eq(run.modifiers.active.size(), 0)


# --- Effetti sulle offerte ----------------------------------------------------

func test_rinnovo_piu_caro() -> void:
	_set_ghosts([killer], [_modifier(&"rinnovo_caro", ModifierDef.Effect.COSTO_RINNOVO, 2)])
	var run: RunState = _new_run()
	var before: int = run.reroll_cost()
	_play_year(run)
	assert_eq(run.reroll_cost(), before + 2)


func test_una_alternativa_in_meno() -> void:
	var list: Array[OpportunityDef] = []
	for i: int in range(4):
		var opportunity: OpportunityDef = OpportunityDef.new()
		opportunity.id = StringName("scambio_%d" % i)
		opportunity.kind = OpportunityDef.Kind.SCAMBIO_RISORSE
		opportunity.gain_gold = 1
		list.append(opportunity)
	catalog.opportunities = list
	_set_ghosts([killer], [_modifier(&"meno_offerte", ModifierDef.Effect.ALTERNATIVE_OFFERTE, -1)])
	var run: RunState = _new_run()
	assert_eq(run.offers.size(), 3)
	_play_year(run)
	assert_eq(run.offers.size(), 2)


# --- Bonus ------------------------------------------------------------------

func test_lo_stesso_sistema_regge_i_bonus() -> void:
	var bonus: ModifierDef = _modifier(&"oro_extra", ModifierDef.Effect.PRODUZIONE_ORO, 50)
	bonus.is_malus = false
	var run: RunState = _new_run()
	run.modifiers.apply(bonus, ActiveModifier.OriginKind.ALTRO, "Prova", run.year, run.board, RandomNumberGenerator.new())
	assert_eq(run.production_preview().x, 6, "4 Oro +50%.")
	assert_string_contains(run.modifiers.active[0].describe(), "Bonus")


func test_percentuali_intere() -> void:
	assert_eq(Modifiers.apply_percent(7, -50), 3, "Per difetto.")
	assert_eq(Modifiers.apply_percent(1000, 50), 1500)
	assert_eq(Modifiers.apply_percent(10, -150), 0, "Mai sotto zero.")
