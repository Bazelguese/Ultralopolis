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


func test_le_carte_corrispondono_alla_plancia_ai_consiglieri_e_alle_proposte() -> void:
	var run: RunState = _run()
	assert_not_null(run, "La scena avvia una run.")
	assert_eq(_carte("_truppe", 0).size(), run.board.troops.size(), "Una carta per ogni truppa.")
	assert_eq(_carte("_edifici", 0).size(), run.board.buildings.size(), "Una carta per ogni edificio.")
	var scelte: Array = _scena.get("_scelte")
	assert_gt(run.advisor_choices.size(), 0, "Ci sono consiglieri nel primo round.")
	assert_eq(scelte.size(), _carte_del_round(run), "Prima del round: una carta per ogni consigliere e per l'evento.")
	_scena.call("_clic_scelta", scelte[0])
	assert_not_null(run.chosen_advisor, "Cliccando la carta si ascolta il consigliere.")
	scelte = _scena.get("_scelte")
	assert_eq(scelte.size(), run.offers.size(), "Poi una carta per ogni proposta.")


func test_passare_il_round_aggiorna_le_carte() -> void:
	var run: RunState = _run()
	var numero: int = run.round_number
	var hud: HudPlancia = _scena.get("_hud")
	hud.passa.emit()
	assert_ne(run.round_number, numero, "Si passa al round successivo.")
	var scelte: Array = _scena.get("_scelte")
	assert_eq(scelte.size(), _carte_del_round(run))


func test_potenzia_dal_pannello_della_carta() -> void:
	var run: RunState = _run()
	var scelte: Array = _scena.get("_scelte")
	# Cerca un round con un consigliere che possa potenziare una carta della plancia.
	for tentativo: int in range(10):
		if not run.is_shopping_phase():
			break
		scelte = _scena.get("_scelte")
		_scena.call("_clic_scelta", scelte[0])
		for i: int in range(run.board.troops.size()):
			var pezzo: BoardPiece = run.board.troops[i]
			if run.upgrade_block_reason(pezzo) == "":
				var costo: ResourceAmounts = run.upgrade_cost_of(pezzo)
				for tipo: Res.Type in Res.NAMES:
					run.stock[tipo] += costo.internal(tipo)
				_scena.call("_potenzia", true, i)
				assert_eq(pezzo.level, 2, "Potenzia dal pannello della carta.")
				assert_true(run.upgrade_used)
				return
		var hud: HudPlancia = _scena.get("_hud")
		hud.passa.emit()
	pass_test("Nessun consigliere adatto nei primi round con questo seme.")


func test_uno_scontro_si_rigioca_fino_all_esito() -> void:
	var run: RunState = _run()
	while run.phase == RunState.Phase.PRODUZIONE:
		run.pass_round()
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
	_completa_tecnologie_dell_era(run)
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
	# Dopo la via il governo può evolvere (GDD §9.4, v0.24): una carta per ramo più "Resta com'è".
	if not run.government_choices.is_empty():
		var governo: IdentityDef = run.government()
		assert_eq(scelte.size(), run.government_choices.size() + 1, "Una carta per ramo e una per restare.")
		_scena.call("_clic_scelta", scelte[scelte.size() - 1])
		assert_true(run.government_choices.is_empty(), "L'ultima carta rifiuta l'evoluzione.")
		assert_eq(run.government(), governo, "Il governo resta com'è.")
		scelte = _scena.get("_scelte")
	assert_eq(scelte.size(), _carte_del_round(run), "Dopo la via tornano i consiglieri del round.")


func test_entrando_in_una_nuova_era_il_governo_puo_evolvere() -> void:
	var run: RunState = _run()
	_completa_tecnologie_dell_era(run)
	assert_true(run.advance_era())
	while not run.way_choices.is_empty():
		run.choose_way(0)
	_scena.call("_aggiorna_tutto")
	if run.government_choices.is_empty():
		pass_test("Il governo di prova non evolve.")
		return
	var nuovo: IdentityDef = run.government_choices[0]
	var scelte: Array = _scena.get("_scelte")
	_scena.call("_clic_scelta", scelte[0])
	assert_eq(run.government(), nuovo, "Cliccando la carta il governo evolve.")
	assert_true(run.government_choices.is_empty())


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
		run.pass_round()
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


## Le tecnologie dell'era corrente richieste per la prossima era (GDD §10.3, v0.25).
func _completa_tecnologie_dell_era(run: RunState) -> void:
	for def: TechDef in run.catalog.technologies:
		if def.era == run.era and run.techs_done_in_era(run.era) < run.next_era_techs_needed():
			run.techs_done.append(def)


## Carte attese prima di scegliere: i consiglieri del round più l'evento, se c'è (GDD §4.2.5).
func _carte_del_round(run: RunState) -> int:
	return run.advisor_choices.size() + (1 if run.event_choice != null else 0)


func test_la_rivoluzione_occupa_il_tavolo_e_non_si_puo_passare() -> void:
	# GDD §5.5, §9.4.2 (v0.24): raggiunta la soglia il round mostra solo la Rivoluzione.
	var run: RunState = _run()
	run.malcontent = run.run_rules.malcontent_threshold
	run.pass_round()
	_scena.call("_aggiorna_tutto")
	assert_true(run.is_revolution_round(), "Arriva la Rivoluzione.")
	var scelte: Array = _scena.get("_scelte")
	assert_eq(scelte.size(), 1, "Sul tavolo solo la Rivoluzione.")
	var hud: HudPlancia = _scena.get("_hud")
	assert_false((hud.get("_pulsante_passa") as Button).visible, "Non si può passare.")
	_scena.call("_clic_scelta", scelte[0])
	assert_not_null(run.chosen_event, "Cliccando si apre la Rivoluzione.")
	scelte = _scena.get("_scelte")
	assert_eq(scelte.size(), run.revolution_targets().size(), "Una carta per ogni governo possibile.")
	var nuovo: IdentityDef = run.revolution_targets()[0]
	_scena.call("_clic_scelta", scelte[0])
	assert_eq(run.government(), nuovo)
	assert_eq(run.malcontent, 0)


## La Ricerca si sceglie dal pannello (GDD §10.5, §14.3): la mano mostra le carte vere della run
## e la scelta passa dal segnale dell'interfaccia, senza consumare il round.
func test_dal_pannello_della_ricerca_si_sceglie_la_tecnologia() -> void:
	var run: RunState = _run()
	var hud: HudPlancia = _scena.get("_hud")
	var carte: Array[TechDef] = run.tech_hand_cards()
	assert_eq(carte.size(), run.run_rules.tech_hand_size, "La mano ha 3 carte.")
	var mano: HBoxContainer = hud.get("_mano_ricerca")
	assert_eq(mano.get_child_count(), carte.size(), "Una carta del pannello per ogni tecnologia della mano.")
	var round_prima: int = run.round_number
	hud.scegli_tecnologia.emit(0)
	assert_eq(run.current_tech, carte[0], "La carta scelta è in studio.")
	assert_eq(run.round_number, round_prima, "Non consuma il round.")
	var pulsante_era: Button = hud.get("_pulsante_era")
	assert_true(pulsante_era.disabled, "Senza le tecnologie richieste non si entra nell'era.")
	assert_string_contains(pulsante_era.text, "0/%d" % run.next_era_techs_needed())


## Le tradizioni si leggono dal loro pannello e l'ascensione si sceglie con le carte (GDD §10.4).
func test_ascensione_scelta_con_le_carte_e_pannello_tradizioni() -> void:
	var run: RunState = _run()
	var hud: HudPlancia = _scena.get("_hud")
	var lista: VBoxContainer = hud.get("_lista_tradizioni")
	assert_gt(lista.get_child_count(), 0, "Il pannello spiega quando cominciano le tradizioni.")
	run.ascension_choices = run.catalog.ascensions.slice(0, 3)
	run.pending_ascensions = 1
	_scena.call("_aggiorna_tutto")
	var scelte: Array = _scena.get("_scelte")
	assert_eq(scelte.size(), 3, "Una carta per ascensione.")
	var scelta: IdentityDef = run.ascension_choices[0]
	_scena.call("_clic_scelta", scelte[0])
	assert_true(run.identity.has(scelta), "Cliccando la carta l'ascensione è presa.")
	assert_true(run.ascension_choices.is_empty())
