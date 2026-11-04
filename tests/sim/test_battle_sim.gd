extends GutTest
## Verifiche della battaglia, basate sui casi del GDD §17.
## I numeri usati qui servono solo ai test e non sono valori di gioco.


func _rules() -> BattleRules:
	var rules: BattleRules = BattleRules.new()
	rules.tick_ms = 100
	rules.attrition_start_ms = 45000
	rules.attrition_interval_ms = 1000
	rules.attrition_first_damage = 1
	rules.attrition_damage_increase = 1
	return rules


func _building(mana_amount: int, interval_ms: int) -> BuildingDef:
	var building: BuildingDef = BuildingDef.new()
	building.id = &"test_edificio"
	building.mana_amount = mana_amount
	building.mana_interval_ms = interval_ms
	return building


func _troop(mana_cost: int, cooldown_ms: int, damage: int) -> TroopDef:
	var troop: TroopDef = TroopDef.new()
	troop.id = &"test_truppa"
	troop.mana_cost = mana_cost
	troop.cooldown_ms = cooldown_ms
	troop.damage = damage
	return troop


## Avversario passivo con tanta Resistenza: non attacca e non cade presto.
func _dummy(resistance: int = 100000) -> BattleSideSetup:
	return BattleSideSetup.new([], [], resistance)


## Fa avanzare la battaglia fino al momento indicato (in millisecondi).
func _advance_to(sim: BattleSim, time_ms: int) -> void:
	while sim.elapsed_ms < time_ms and sim.outcome == BattleSim.Outcome.IN_CORSO:
		sim.step()


func _activations(sim: BattleSim, side: int) -> Array[BattleEvent]:
	var found: Array[BattleEvent] = []
	for event: BattleEvent in sim.events:
		if event.side == side and event.kind == BattleEvent.Kind.ATTIVAZIONE:
			found.append(event)
	return found


# --- Inizio battaglia -------------------------------------------------------

func test_inizio_battaglia_mana_zero_e_ricariche_piene() -> void:
	var side: BattleSideSetup = BattleSideSetup.new([_building(1, 1000)], [_troop(0, 1000, 1)], 50)
	var sim: BattleSim = BattleSim.new(_rules(), side, _dummy())
	assert_eq(sim.get_mana(BattleSim.SIDE_A), 0, "Il mana parte da zero.")
	assert_eq(sim.get_troop_cooldown_left_ms(BattleSim.SIDE_A, 0), 1000, "La truppa parte con la ricarica piena.")
	assert_eq(sim.get_building_production_left_ms(BattleSim.SIDE_A, 0), 1000, "L'edificio parte con l'intervallo pieno.")
	assert_eq(sim.get_resistance(BattleSim.SIDE_A), 50, "La Resistenza parte dal massimo.")
	_advance_to(sim, 900)
	assert_eq(_activations(sim, BattleSim.SIDE_A).size(), 0, "Nessuna attivazione prima della fine della ricarica.")
	assert_eq(sim.get_mana(BattleSim.SIDE_A), 0, "Nessun mana prima della fine dell'intervallo.")


# --- Truppa a costo zero ----------------------------------------------------

func test_truppa_a_costo_zero_si_attiva_senza_mana() -> void:
	var side: BattleSideSetup = BattleSideSetup.new([], [_troop(0, 1000, 3)], 50)
	var sim: BattleSim = BattleSim.new(_rules(), side, _dummy(100))
	_advance_to(sim, 1000)
	var activations: Array[BattleEvent] = _activations(sim, BattleSim.SIDE_A)
	assert_eq(activations.size(), 1, "Si attiva al termine della ricarica.")
	assert_eq(activations[0].time_ms, 1000)
	assert_eq(sim.get_resistance(BattleSim.SIDE_B), 97, "Il danno riduce la Resistenza avversaria.")


# --- Stesso istante: prima la produzione, poi le attivazioni ---------------

func test_produzione_prima_delle_attivazioni_nello_stesso_istante() -> void:
	var side: BattleSideSetup = BattleSideSetup.new([_building(2, 1000)], [_troop(2, 1000, 5)], 50)
	var sim: BattleSim = BattleSim.new(_rules(), side, _dummy())
	_advance_to(sim, 1000)
	var activations: Array[BattleEvent] = _activations(sim, BattleSim.SIDE_A)
	assert_eq(activations.size(), 1, "Il mana prodotto nello stesso istante è già spendibile.")
	assert_eq(sim.get_mana(BattleSim.SIDE_A), 0)


# --- Truppa pronta senza mana ----------------------------------------------

func test_truppa_senza_mana_attende_senza_nuova_ricarica() -> void:
	# L'edificio dà 1 mana al secondo; la truppa ne chiede 3 ed è pronta dopo 1 secondo.
	var side: BattleSideSetup = BattleSideSetup.new([_building(1, 1000)], [_troop(3, 1000, 5)], 50)
	var sim: BattleSim = BattleSim.new(_rules(), side, _dummy())
	_advance_to(sim, 1000)
	assert_eq(_activations(sim, BattleSim.SIDE_A).size(), 0, "Non può pagare: non si attiva.")
	assert_eq(sim.get_mana(BattleSim.SIDE_A), 1, "Nessun mana consumato.")
	assert_eq(sim.get_troop_state(BattleSim.SIDE_A, 0), BattleSim.TroopState.IN_ATTESA_DI_MANA, "Il motivo dell'attesa è leggibile.")
	assert_eq(sim.get_troop_cooldown_left_ms(BattleSim.SIDE_A, 0), 0, "Nessuna nuova ricarica.")

	var waiting_events: int = 0
	for event: BattleEvent in sim.events:
		if event.kind == BattleEvent.Kind.IN_ATTESA_MANA:
			waiting_events += 1
	assert_eq(waiting_events, 1, "L'attesa viene registrata per spiegarla al giocatore.")

	# Al terzo secondo il mana basta: si attiva subito, senza aspettare un'altra ricarica.
	_advance_to(sim, 3000)
	var activations: Array[BattleEvent] = _activations(sim, BattleSim.SIDE_A)
	assert_eq(activations.size(), 1)
	assert_eq(activations[0].time_ms, 3000, "Si attiva appena il mana è sufficiente.")
	assert_eq(sim.get_mana(BattleSim.SIDE_A), 0)
	assert_eq(sim.get_troop_state(BattleSim.SIDE_A, 0), BattleSim.TroopState.IN_RICARICA)
	assert_eq(sim.get_troop_cooldown_left_ms(BattleSim.SIDE_A, 0), 1000, "Dopo l'attivazione la ricarica riparte.")


# --- Priorità da destra verso sinistra --------------------------------------

func test_piu_truppe_pronte_valutate_da_destra_a_sinistra() -> void:
	# 2 mana al secondo, due truppe identiche da 2 mana: solo una può pagare.
	var left: TroopDef = _troop(2, 1000, 1)
	var right: TroopDef = _troop(2, 1000, 1)
	var side: BattleSideSetup = BattleSideSetup.new([_building(2, 1000)], [left, right], 50)
	var sim: BattleSim = BattleSim.new(_rules(), side, _dummy())
	_advance_to(sim, 1000)
	var activations: Array[BattleEvent] = _activations(sim, BattleSim.SIDE_A)
	assert_eq(activations.size(), 1)
	assert_eq(activations[0].index, 1, "Si attiva la truppa più a destra.")
	assert_eq(sim.get_troop_state(BattleSim.SIDE_A, 0), BattleSim.TroopState.IN_ATTESA_DI_MANA, "Quella a sinistra aspetta.")


func test_truppa_troppo_costosa_saltata_e_mana_non_prenotato() -> void:
	# 3 mana disponibili: la truppa a destra ne chiede 5 e viene saltata,
	# quella a sinistra ne chiede 1 e usa il mana residuo.
	var expensive: TroopDef = _troop(5, 1000, 10)
	var cheap: TroopDef = _troop(1, 1000, 1)
	var side: BattleSideSetup = BattleSideSetup.new([_building(3, 1000)], [cheap, expensive], 50)
	var sim: BattleSim = BattleSim.new(_rules(), side, _dummy())
	_advance_to(sim, 1000)
	var activations: Array[BattleEvent] = _activations(sim, BattleSim.SIDE_A)
	assert_eq(activations.size(), 1)
	assert_eq(activations[0].index, 0, "La truppa economica a sinistra si attiva.")
	assert_eq(sim.get_mana(BattleSim.SIDE_A), 2, "Il mana non viene prenotato per la truppa saltata.")
	assert_eq(sim.get_troop_state(BattleSim.SIDE_A, 1), BattleSim.TroopState.IN_ATTESA_DI_MANA)


# --- Logoramento ------------------------------------------------------------

func test_logoramento_inizia_a_45_secondi_e_cresce() -> void:
	var sim: BattleSim = BattleSim.new(_rules(), _dummy(1000), _dummy(1000))
	_advance_to(sim, 44900)
	assert_eq(sim.get_resistance(BattleSim.SIDE_A), 1000, "Nessun danno prima di 45 secondi.")
	_advance_to(sim, 45000)
	assert_eq(sim.get_resistance(BattleSim.SIDE_A), 999, "Primo colpo: 1 danno.")
	assert_eq(sim.get_resistance(BattleSim.SIDE_B), 999, "Colpisce entrambe le nazioni.")
	_advance_to(sim, 46000)
	assert_eq(sim.get_resistance(BattleSim.SIDE_A), 997, "Secondo colpo: 2 danni.")
	_advance_to(sim, 47000)
	assert_eq(sim.get_resistance(BattleSim.SIDE_A), 994, "Terzo colpo: 3 danni.")


# --- Esito ------------------------------------------------------------------

func test_doppio_azzeramento_e_pareggio() -> void:
	var side_a: BattleSideSetup = BattleSideSetup.new([], [_troop(0, 1000, 10)], 30)
	var side_b: BattleSideSetup = BattleSideSetup.new([], [_troop(0, 1000, 10)], 30)
	var sim: BattleSim = BattleSim.new(_rules(), side_a, side_b)
	assert_eq(sim.run_to_end(), BattleSim.Outcome.PAREGGIO)
	assert_eq(sim.elapsed_ms, 3000, "Entrambe cadono nello stesso istante.")


func test_vince_chi_azzera_per_primo() -> void:
	var side_a: BattleSideSetup = BattleSideSetup.new([], [_troop(0, 1000, 10)], 30)
	var side_b: BattleSideSetup = BattleSideSetup.new([], [_troop(0, 1000, 5)], 30)
	var sim: BattleSim = BattleSim.new(_rules(), side_a, side_b)
	assert_eq(sim.run_to_end(), BattleSim.Outcome.VITTORIA_A)
	assert_eq(sim.get_resistance(BattleSim.SIDE_A), 15)


func test_lo_scontro_finisce_sempre_grazie_al_logoramento() -> void:
	var sim: BattleSim = BattleSim.new(_rules(), _dummy(500), _dummy(500))
	assert_eq(sim.run_to_end(), BattleSim.Outcome.PAREGGIO, "Senza truppe il logoramento chiude lo scontro.")


# --- Riproducibilità --------------------------------------------------------

func test_stesso_scontro_stesso_risultato() -> void:
	var results: Array[String] = []
	for attempt: int in range(2):
		var side_a: BattleSideSetup = BattleSideSetup.new(
			[_building(2, 1300), _building(1, 700)],
			[_troop(0, 1500, 2), _troop(3, 2000, 7), _troop(1, 900, 1)], 120)
		var side_b: BattleSideSetup = BattleSideSetup.new(
			[_building(3, 1800)],
			[_troop(2, 1200, 4), _troop(0, 2500, 3)], 130)
		var sim: BattleSim = BattleSim.new(_rules(), side_a, side_b)
		sim.run_to_end()
		var lines: PackedStringArray = PackedStringArray()
		for event: BattleEvent in sim.events:
			lines.append(event.describe())
		results.append("%d|%d|%s" % [sim.outcome, sim.elapsed_ms, "\n".join(lines)])
	assert_eq(results[0], results[1], "Due scontri identici producono la stessa cronaca.")
