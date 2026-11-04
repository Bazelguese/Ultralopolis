extends GutTest
## Partita sulla plancia 3D: la presentazione mostra lo stato vero della run
## e rigioca gli scontri fino all'esito (GDD §14.2, principio P4).

var _scena: Node3D


func before_each() -> void:
	GameSession.navigation_enabled = false
	GameSession.selected_nation = null
	_scena = (load("res://scenes/partita_3d.tscn") as PackedScene).instantiate() as Node3D
	add_child_autofree(_scena)


func after_each() -> void:
	GameSession.navigation_enabled = true


func _run() -> RunState:
	return _scena.get("run") as RunState


func _carte(nome: String, lato: int) -> Array:
	var gruppi: Array = _scena.get(nome)
	return gruppi[lato]


func test_le_carte_corrispondono_alla_plancia_e_alle_offerte() -> void:
	var run: RunState = _run()
	assert_not_null(run, "La scena avvia una run.")
	assert_eq(_carte("_truppe", 0).size(), run.board.troops.size(), "Una carta per ogni truppa.")
	assert_eq(_carte("_edifici", 0).size(), run.board.buildings.size(), "Una carta per ogni edificio.")
	var scelte: Array = _scena.get("_scelte")
	assert_eq(scelte.size(), run.offers.size(), "Una carta per ogni offerta.")


func test_passare_l_opportunita_aggiorna_le_carte() -> void:
	var run: RunState = _run()
	var numero: int = run.opportunity_number
	var hud: HudPlancia = _scena.get("_hud")
	hud.passa.emit()
	assert_ne(run.opportunity_number, numero, "Si passa all'opportunità successiva.")
	var scelte: Array = _scena.get("_scelte")
	assert_eq(scelte.size(), run.offers.size())


func test_uno_scontro_si_rigioca_fino_all_esito() -> void:
	var run: RunState = _run()
	while run.phase == RunState.Phase.PRODUZIONE:
		run.pass_opportunity()
	_scena.call("_aggiorna_tutto")
	assert_eq(run.phase, RunState.Phase.SCELTA_INCONTRO)
	var scelte: Array = _scena.get("_scelte")
	assert_eq(scelte.size(), run.encounter_choices.size(), "Una carta per ogni incontro.")
	_scena.call("_clic_scelta", scelte[0])
	var sim: BattleSim = _scena.get("_sim")
	assert_not_null(sim, "Lo scontro viene rigiocato.")
	assert_eq(_carte("_truppe", 1).size(), sim.get_troop_count(1), "Si vedono le truppe dell'avversario.")
	_scena.call("_salta_scontro")
	assert_ne(sim.outcome, BattleSim.Outcome.IN_CORSO, "Saltare porta alla fine dello scontro.")
	_scena.call("_mostra_esito")
	var hud: HudPlancia = _scena.get("_hud")
	assert_true(hud.esito_visibile(), "L'esito viene mostrato.")
	hud.call("_on_continua_esito")
	assert_eq(_scena.get("_modo"), 0, "Dopo l'esito si torna alla partita.")


func test_entrando_in_una_nuova_era_si_sceglie_la_via() -> void:
	var run: RunState = _run()
	run.stock[Res.Type.RICERCA] += run.next_era_cost()
	assert_true(run.advance_era(), "Si può avanzare di era.")
	_scena.call("_aggiorna_tutto")
	if run.way_choices.is_empty():
		pass_test("Questa era non propone vie.")
		return
	var scelte: Array = _scena.get("_scelte")
	assert_eq(scelte.size(), run.way_choices.size(), "Una carta per ogni via.")
	_scena.call("_clic_scelta", scelte[0])
	assert_true(run.way_choices.is_empty(), "Cliccando la carta la via viene scelta.")
	scelte = _scena.get("_scelte")
	assert_eq(scelte.size(), run.offers.size(), "Dopo la via tornano le offerte.")
