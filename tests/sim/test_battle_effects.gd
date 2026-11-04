extends GutTest
## Scudo, cura, Corruzione, assedio, Inefficienza e Sabotaggio (GDD §7.6, §7.7, §17).

func _rules() -> BattleRules:
	return BattleRules.new()


func _troop(damage: int, cooldown_ms: int = 1000) -> TroopDef:
	var def: TroopDef = TroopDef.new()
	def.damage = damage
	def.cooldown_ms = cooldown_ms
	return def


func _building(interval_ms: int = 1000) -> BuildingDef:
	var def: BuildingDef = BuildingDef.new()
	def.mana_amount = 0
	def.mana_interval_ms = interval_ms
	return def


func _side(buildings: Array[BuildingDef], troops: Array[TroopDef], resistance: int = 100) -> BattleSideSetup:
	return BattleSideSetup.new(buildings, troops, resistance)


func _advance_to(sim: BattleSim, time_ms: int) -> void:
	while sim.elapsed_ms < time_ms and sim.outcome == BattleSim.Outcome.IN_CORSO:
		sim.step()


# --- Scudo --------------------------------------------------------------------

func test_lo_scudo_parte_da_zero_e_assorbe_il_danno() -> void:
	var shield_troop: TroopDef = _troop(0)
	shield_troop.shield = 5
	var sim: BattleSim = BattleSim.new(_rules(), _side([], [shield_troop]), _side([], [_troop(3, 2000)]))
	assert_eq(sim.get_shield(BattleSim.SIDE_A), 0, "Parte da zero.")
	_advance_to(sim, 1000)
	assert_eq(sim.get_shield(BattleSim.SIDE_A), 5)
	_advance_to(sim, 2000)
	# A 2 s: +5 scudo (totale 10), poi 3 danni assorbiti.
	assert_eq(sim.get_shield(BattleSim.SIDE_A), 7)
	assert_eq(sim.get_resistance(BattleSim.SIDE_A), 100, "Nessun danno alla Resistenza.")


func test_lo_scudo_non_ha_tetto_e_il_danno_avanza_sulla_resistenza() -> void:
	var sim: BattleSim = BattleSim.new(_rules(), _side([], []), _side([], [_troop(8)]))
	var setup: BattleSideSetup = _side([], [])
	setup.start_shield = 5
	sim = BattleSim.new(_rules(), setup, _side([], [_troop(8)]))
	_advance_to(sim, 1000)
	assert_eq(sim.get_shield(BattleSim.SIDE_A), 0)
	assert_eq(sim.get_resistance(BattleSim.SIDE_A), 97, "8 danni: 5 assorbiti, 3 alla Resistenza.")


func test_il_logoramento_viene_assorbito_dallo_scudo() -> void:
	var setup: BattleSideSetup = _side([], [], 1000)
	setup.start_shield = 1
	var sim: BattleSim = BattleSim.new(_rules(), setup, _side([], [], 1000))
	_advance_to(sim, 45000)
	assert_eq(sim.get_shield(BattleSim.SIDE_A), 0)
	assert_eq(sim.get_resistance(BattleSim.SIDE_A), 1000)
	assert_eq(sim.get_resistance(BattleSim.SIDE_B), 999)


# --- Cura ---------------------------------------------------------------------

func test_la_cura_non_supera_il_massimo_e_arriva_prima_del_danno() -> void:
	var healer: TroopDef = _troop(0)
	healer.heal = 4
	var sim: BattleSim = BattleSim.new(_rules(), _side([], [healer], 50), _side([], [_troop(10)]))
	_advance_to(sim, 1000)
	# Stesso istante: la cura arriva su Resistenza piena e va persa, poi 10 danni.
	assert_eq(sim.get_resistance(BattleSim.SIDE_A), 40)
	_advance_to(sim, 2000)
	# Cura 4 (44), poi 10 danni (34).
	assert_eq(sim.get_resistance(BattleSim.SIDE_A), 34)


# --- Corruzione -----------------------------------------------------------------

func test_la_corruzione_sconfigge_anche_con_scudo_pieno() -> void:
	var corruptor: TroopDef = _troop(0)
	corruptor.corruption = 6
	var defender: BattleSideSetup = _side([], [], 10)
	defender.start_shield = 999
	var sim: BattleSim = BattleSim.new(_rules(), _side([], [corruptor]), defender)
	_advance_to(sim, 1000)
	assert_eq(sim.get_corruption(BattleSim.SIDE_B), 6)
	assert_eq(sim.get_shield(BattleSim.SIDE_B), 999, "La Corruzione non tocca lo scudo.")
	assert_eq(sim.outcome, BattleSim.Outcome.IN_CORSO)
	_advance_to(sim, 2000)
	assert_eq(sim.outcome, BattleSim.Outcome.VITTORIA_A, "12 Corruzione ≥ 10 Resistenza.")


func test_caduta_simultanea_per_danno_e_corruzione_e_pareggio() -> void:
	var corruptor: TroopDef = _troop(0)
	corruptor.corruption = 10
	var sim: BattleSim = BattleSim.new(_rules(), _side([], [corruptor], 10), _side([], [_troop(10)], 10))
	_advance_to(sim, 1000)
	assert_eq(sim.outcome, BattleSim.Outcome.PAREGGIO)


# --- Assedio ----------------------------------------------------------------------

func test_l_assedio_toglie_solo_scudo_prima_del_danno() -> void:
	var ram: TroopDef = _troop(3)
	ram.siege_damage = 10
	var defender: BattleSideSetup = _side([], [], 100)
	defender.start_shield = 12
	var sim: BattleSim = BattleSim.new(_rules(), _side([], [ram]), defender)
	_advance_to(sim, 1000)
	# Assedio: 12 → 2; poi 3 danni: 2 assorbiti, 1 alla Resistenza.
	assert_eq(sim.get_shield(BattleSim.SIDE_B), 0)
	assert_eq(sim.get_resistance(BattleSim.SIDE_B), 99)


func test_l_assedio_senza_scudo_va_perso() -> void:
	var ram: TroopDef = _troop(3)
	ram.siege_damage = 10
	var sim: BattleSim = BattleSim.new(_rules(), _side([], [ram]), _side([], [], 100))
	_advance_to(sim, 1000)
	assert_eq(sim.get_resistance(BattleSim.SIDE_B), 97)


# --- Edifici --------------------------------------------------------------------

func test_un_edificio_produce_tutto_allo_scadere_del_suo_intervallo() -> void:
	var tower: BuildingDef = _building(2000)
	tower.shield = 3
	tower.corruption = 2
	var sim: BattleSim = BattleSim.new(_rules(), _side([tower], []), _side([], [], 100))
	_advance_to(sim, 1900)
	assert_eq(sim.get_shield(BattleSim.SIDE_A), 0)
	_advance_to(sim, 2000)
	assert_eq(sim.get_shield(BattleSim.SIDE_A), 3)
	assert_eq(sim.get_corruption(BattleSim.SIDE_B), 2)


# --- Inefficienza e Sabotaggio -----------------------------------------------------

func test_inefficienza_rallenta_il_timer_dall_istante_successivo() -> void:
	var slower: TroopDef = _troop(0, 1000)
	slower.inefficiency_ms = 2000
	slower.inefficiency_target = TimerTarget.Kind.TRUPPE
	var victim: TroopDef = _troop(1, 2000)
	var sim: BattleSim = BattleSim.new(_rules(), _side([], [slower]), _side([], [victim]))
	_advance_to(sim, 1000)
	assert_eq(sim.get_troop_slow_ms(BattleSim.SIDE_B, 0), 2000, "Applicata alla fine dell'istante.")
	assert_eq(sim.get_troop_cooldown_left_ms(BattleSim.SIDE_B, 0), 1000)
	_advance_to(sim, 2000)
	# Per 1 secondo a metà velocità: 1000 - 500 = 500 ms ancora da ricaricare.
	assert_eq(sim.get_troop_cooldown_left_ms(BattleSim.SIDE_B, 0), 500)


func test_sabotaggio_blocca_anche_se_pronta_e_con_mana() -> void:
	var saboteur: TroopDef = _troop(0, 1000)
	saboteur.sabotage_ms = 1500
	var victim: TroopDef = _troop(5, 1100)
	var sim: BattleSim = BattleSim.new(_rules(), _side([], [saboteur]), _side([], [victim]))
	_advance_to(sim, 1100)
	assert_eq(sim.get_troop_state(BattleSim.SIDE_B, 0), BattleSim.TroopState.SABOTATA)
	assert_eq(sim.get_resistance(BattleSim.SIDE_A), 100, "Pronta ma bloccata: non colpisce.")


func test_sabotata_nello_stesso_istante_si_attiva_comunque() -> void:
	var saboteur: TroopDef = _troop(0, 1000)
	saboteur.sabotage_ms = 3000
	var victim: TroopDef = _troop(5, 1000)
	var sim: BattleSim = BattleSim.new(_rules(), _side([], [saboteur]), _side([], [victim]))
	_advance_to(sim, 1000)
	assert_eq(sim.get_resistance(BattleSim.SIDE_A), 95, "Il blocco vale dall'istante successivo.")


func test_le_durate_si_sommano() -> void:
	var saboteur: TroopDef = _troop(0, 1000)
	saboteur.sabotage_ms = 2000
	var sim: BattleSim = BattleSim.new(_rules(), _side([], [saboteur]), _side([], [_troop(1, 50000)]))
	_advance_to(sim, 1000)
	assert_eq(sim.get_troop_sabotage_ms(BattleSim.SIDE_B, 0), 2000)
	_advance_to(sim, 2000)
	# 2000 - 1000 trascorsi + 2000 nuovi.
	assert_eq(sim.get_troop_sabotage_ms(BattleSim.SIDE_B, 0), 3000)


func test_rallentato_e_sabotato_il_blocco_prevale() -> void:
	var both: TroopDef = _troop(0, 1000)
	both.inefficiency_ms = 3000
	both.sabotage_ms = 1000
	var victim: TroopDef = _troop(1, 5000)
	var sim: BattleSim = BattleSim.new(_rules(), _side([], [both]), _side([], [victim]))
	_advance_to(sim, 1000)
	var before: int = sim.get_troop_cooldown_left_ms(BattleSim.SIDE_B, 0)
	sim.step()
	assert_eq(sim.get_troop_cooldown_left_ms(BattleSim.SIDE_B, 0), before, "Timer fermo: il blocco prevale.")
	assert_eq(sim.get_troop_slow_ms(BattleSim.SIDE_B, 0), 2900, "Intanto l'Inefficienza scorre.")


func test_rotazione_nessun_bersaglio_due_volte_prima_degli_altri() -> void:
	var saboteur: TroopDef = _troop(0, 1000)
	saboteur.sabotage_ms = 100
	saboteur.sabotage_target = TimerTarget.Kind.TRUPPE
	var victims: Array[TroopDef] = [_troop(0, 50000), _troop(0, 50000), _troop(0, 50000)]
	var sim: BattleSim = BattleSim.new(_rules(), _side([], [saboteur], 1000), _side([], victims, 1000), 77)
	_advance_to(sim, 6000)
	var hits: Array[int] = []
	for event: BattleEvent in sim.events:
		if event.kind == BattleEvent.Kind.SABOTATO:
			hits.append(event.index)
	assert_eq(hits.size(), 6)
	var first_round: Array[int] = hits.slice(0, 3)
	first_round.sort()
	assert_eq(first_round, [1000, 1001, 1002] as Array[int], "Tutti colpiti una volta prima di ricominciare.")


func test_su_un_edificio_ferma_tutte_le_produzioni() -> void:
	var saboteur: TroopDef = _troop(0, 1000)
	saboteur.sabotage_ms = 5000
	saboteur.sabotage_target = TimerTarget.Kind.EDIFICI
	var tower: BuildingDef = _building(1500)
	tower.shield = 4
	var sim: BattleSim = BattleSim.new(_rules(), _side([], [saboteur]), _side([tower], []))
	_advance_to(sim, 3000)
	assert_eq(sim.get_shield(BattleSim.SIDE_B), 0, "L'edificio sabotato dal secondo 1 non produce scudo.")


func test_senza_bersaglio_valido_l_effetto_va_perso() -> void:
	var saboteur: TroopDef = _troop(0, 1000)
	saboteur.sabotage_ms = 1000
	saboteur.sabotage_target = TimerTarget.Kind.EDIFICI
	var sim: BattleSim = BattleSim.new(_rules(), _side([], [saboteur]), _side([], [_troop(1)]))
	_advance_to(sim, 1000)
	for event: BattleEvent in sim.events:
		assert_ne(event.kind, BattleEvent.Kind.SABOTATO)


func test_stesso_seme_stesso_scontro() -> void:
	var logs: Array[String] = []
	for attempt: int in range(2):
		var saboteur: TroopDef = _troop(2, 700)
		saboteur.sabotage_ms = 400
		saboteur.sabotage_target = TimerTarget.Kind.QUALSIASI
		var slower: TroopDef = _troop(1, 900)
		slower.inefficiency_ms = 800
		slower.inefficiency_target = TimerTarget.Kind.QUALSIASI
		var side_a: BattleSideSetup = _side([_building(1200), _building(800)], [saboteur, slower, _troop(3, 1500)], 80)
		var side_b: BattleSideSetup = _side([_building(1000)], [_troop(2, 600), _troop(4, 1700)], 80)
		var sim: BattleSim = BattleSim.new(_rules(), side_a, side_b, 4242)
		sim.run_to_end()
		var lines: PackedStringArray = PackedStringArray()
		for event: BattleEvent in sim.events:
			lines.append(event.describe())
		logs.append("\n".join(lines))
	assert_eq(logs[0], logs[1])


func test_edificio_sabotato_a_inizio_scontro() -> void:
	var setup: BattleSideSetup = _side([_building(1000)], [])
	setup.start_building_sabotage_ms = 3000
	var sim: BattleSim = BattleSim.new(_rules(), setup, _side([], []))
	assert_eq(sim.get_building_sabotage_ms(BattleSim.SIDE_A, 0), 3000)


func test_corruzione_iniziale() -> void:
	var setup: BattleSideSetup = _side([], [], 5)
	setup.start_corruption = 5
	var sim: BattleSim = BattleSim.new(_rules(), setup, _side([], [], 100))
	sim.step()
	assert_eq(sim.outcome, BattleSim.Outcome.VITTORIA_B, "5 di Corruzione su 5 di Resistenza.")
