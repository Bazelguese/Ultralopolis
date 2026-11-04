extends GutTest
## Partita sulla plancia 3D: la presentazione mostra lo stato vero della run
## e rigioca gli scontri fino all'esito (GDD §14.2, principio P4).

var _scena: Node3D


func before_each() -> void:
	GameSession.navigation_enabled = false
	GameSession.selected_nation = null
	_apri()


func after_each() -> void:
	GameSession.navigation_enabled = true
	GameSession.selected_nation = null


func _apri() -> void:
	if _scena != null and is_instance_valid(_scena):
		_scena.queue_free()
	_scena = (load("res://scenes/partita_3d.tscn") as PackedScene).instantiate() as Node3D
	add_child_autofree(_scena)


## Una nazione completa: l'ultimo elemento di ogni dimensione della creazione.
func _nazione(nome: String) -> NationTemplate:
	var catalogo: CatalogDef = GameSession.catalog()
	var regole: RunRules = GameSession.run_rules()
	var scelte: Array[IdentityDef] = []
	for dimensione: IdentityDef.Dimension in IdentityDef.CREATION_DIMENSIONS:
		var opzioni: Array[IdentityDef] = IdentityRules.options(catalogo, dimensione)
		var quante: int = IdentityRules.starting_perk_count(catalogo, regole) if dimensione == IdentityDef.Dimension.PERK else 1
		for i: int in range(quante):
			scelte.append(opzioni[opzioni.size() - 1 - i])
	return NationTemplate.from_choices("prova_3d", nome, scelte)


func _run() -> RunState:
	return _scena.get("run") as RunState


func _carte(nome: String, lato: int) -> Array:
	var gruppi: Array = _scena.get(nome)
	return gruppi[lato]


func test_senza_nazione_scelta_usa_una_nazione_di_prova() -> void:
	var run: RunState = _run()
	assert_eq(run.phase, RunState.Phase.PRODUZIONE)
	assert_eq(run.nation_name, "Nazione di prova")


## Parte dalla nazione scelta nel menu e attraversa un anno usando solo i comandi della schermata.
func test_la_partita_parte_dalla_nazione_scelta_e_attraversa_un_anno() -> void:
	GameSession.selected_nation = _nazione("Regno di Prova")
	_apri()
	var run: RunState = _run()
	var hud: HudPlancia = _scena.get("_hud")
	assert_eq(run.phase, RunState.Phase.PRODUZIONE, "La partita comincia dall'anno 1.")
	assert_eq(run.nation_name, "Regno di Prova")
	assert_eq(run.identity.size(), GameSession.selected_nation.identity_ids.size())

	while run.is_shopping_phase():
		hud.passa.emit()
	var scelte: Array = _scena.get("_scelte")
	_scena.call("_clic_scelta", scelte[0])
	hud.azione_principale.emit()
	_scena.call("_mostra_esito")
	hud.call("_on_continua_esito")
	if run.phase == RunState.Phase.RICOMPENSA_INCONTRO:
		hud.nessuna_ricompensa.emit()
	while run.is_shopping_phase():
		hud.passa.emit()
	assert_eq(run.phase, RunState.Phase.SCONTRO_FANTASMA)
	hud.azione_principale.emit()
	assert_not_null(_scena.get("_sim"), "Si rigioca lo scontro con il fantasma.")
	hud.azione_principale.emit()
	_scena.call("_mostra_esito")
	hud.call("_on_continua_esito")
	assert_eq(run.year, 2, "Dopo il fantasma inizia l'anno 2.")

	hud.menu.emit()
	assert_eq(GameSession.last_scene_request, GameSession.MENU_SCENE, "Il pulsante porta al menu.")


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


## Cambiare qualcosa sulla plancia non rifà le offerte: restano le stesse carte, senza nuova entrata.
func test_le_offerte_restano_ferme_se_cambia_solo_la_plancia() -> void:
	var run: RunState = _run()
	var prima: Array = (_scena.get("_scelte") as Array).duplicate()
	assert_true(run.move_troop(0, 1), "Si sposta una truppa.")
	_scena.call("_aggiorna_tutto")
	var dopo: Array = _scena.get("_scelte")
	assert_eq(dopo.size(), prima.size())
	for i: int in range(dopo.size()):
		assert_same(dopo[i], prima[i], "La carta %d è la stessa di prima." % i)
	var hud: HudPlancia = _scena.get("_hud")
	hud.passa.emit()
	dopo = _scena.get("_scelte")
	assert_false(dopo.is_empty() or dopo[0] == prima[0], "Passando arrivano carte nuove.")


## Dopo uno scontro la plancia torna pulita: niente Scudo, Corruzione o riserva di mana rimasti.
func test_dopo_lo_scontro_la_plancia_si_azzera() -> void:
	var run: RunState = _run()
	while run.phase == RunState.Phase.PRODUZIONE:
		run.pass_opportunity()
	_scena.call("_aggiorna_tutto")
	var scelte: Array = _scena.get("_scelte")
	_scena.call("_clic_scelta", scelte[0])
	_scena.call("_salta_scontro")
	# Come se lo scontro fosse finito con Scudo e Corruzione ancora in gioco.
	for nome: String in ["_segnalini_scudo", "_segnalini_corruzione", "_riserve"]:
		for segnalino: Node3D in (_scena.get(nome) as Array):
			segnalino.visible = true
	_scena.call("_mostra_esito")
	var hud: HudPlancia = _scena.get("_hud")
	hud.call("_on_continua_esito")
	for nome: String in ["_segnalini_scudo", "_segnalini_corruzione", "_riserve"]:
		for segnalino: Node3D in (_scena.get(nome) as Array):
			assert_false(segnalino.visible, "%s nascosto dopo lo scontro." % nome)
	assert_eq(_carte("_truppe", 0).size(), run.board.troops.size(), "Le carte tornano quelle della plancia.")
	assert_eq(_scena.get("_modo"), 0)


func test_le_risorse_sono_tutte_sempre_visibili() -> void:
	var run: RunState = _run()
	var hud: HudPlancia = _scena.get("_hud")
	var valori: Dictionary = hud.get("_valori_risorse")
	assert_eq(valori.size(), Res.COUNT, "Una casella per ogni risorsa.")
	for tipo: int in valori:
		var etichetta: Label = valori[tipo]
		assert_true(etichetta.is_visible_in_tree(), "%s visibile." % Res.NAMES[tipo])
	assert_eq((valori[Res.Type.LEGNO] as Label).text, run.stock_text(Res.Type.LEGNO))
	hud.modalita_scontro(true, "Prova")
	assert_true((valori[Res.Type.ORO] as Label).is_visible_in_tree(), "Anche durante gli scontri.")


## La plancia mostra gli spazi disponibili più uno da conquistare, non tutti i 12.
func test_la_plancia_mostra_solo_gli_spazi_utili() -> void:
	var run: RunState = _run()
	var larghezze: Array = _scena.get("_larghezze")
	var attesa: float = _scena.call("_larghezza_per", run.board.troop_capacity() + 1, run.board.building_capacity() + 1)
	assert_almost_eq(float(larghezze[0]), attesa, 0.001)
	var plancia: Node3D = _scena.get("_plancia")
	assert_gt(plancia.scale.x, 1.0, "Con pochi spazi la plancia si ingrandisce.")
