extends GutTest
## Prova di funzionamento dell'interfaccia provvisoria: si apre e reagisce alle azioni.


func test_la_schermata_si_apre_e_attraversa_un_anno() -> void:
	var main: Control = (load("res://scenes/main.tscn") as PackedScene).instantiate() as Control
	add_child_autofree(main)
	await wait_physics_frames(2)
	var run: RunState = main.get("run")
	assert_not_null(run, "La run parte all'apertura.")
	assert_eq(run.phase, RunState.Phase.PRODUZIONE)

	while run.is_shopping_phase():
		main.call("_on_pass")
	assert_eq(run.phase, RunState.Phase.SCELTA_INCONTRO)

	main.call("_on_encounter", 0)
	var layer: Control = main.get("_battle_layer")
	assert_true(layer.visible, "Si apre la visione della battaglia.")
	var view: BattleView = layer.get_child(0) as BattleView
	assert_not_null(view)
	view.call("_on_skip")
	view.call("_on_continue")
	assert_false(layer.visible, "La battaglia si chiude con Continua.")

	if run.phase == RunState.Phase.RICOMPENSA_INCONTRO:
		main.call("_on_skip_reward")
	while run.is_shopping_phase():
		main.call("_on_pass")
	assert_eq(run.phase, RunState.Phase.SCONTRO_FANTASMA)
	main.call("_on_fight_ghost")
	assert_true(layer.visible)
	(layer.get_child(0) as BattleView).call("_on_continue")
	assert_eq(run.year, 2, "Dopo il fantasma inizia l'anno 2.")
