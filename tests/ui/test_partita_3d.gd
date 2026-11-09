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


## Passa i round e reagisce alle cronache (GDD §9.6) finché la run è nel Consiglio o in una cronaca.
func _fino_allo_scontro(run: RunState) -> void:
	var giri: int = 0
	while (run.phase == RunState.Phase.CONSIGLIO or run.phase == RunState.Phase.CRONACA) and giri < 50:
		giri += 1
		if run.phase == RunState.Phase.CRONACA:
			assert_true(preload("res://tests/sim/aiuti_consiglio.gd").reagisci(run), run.last_error)
		else:
			run.pass_round()


## Dal pannello della cronaca: clicca la prima reazione che non chiede di scegliere una carta.
func _reagisci_dal_pannello(run: RunState, hud: HudPlancia) -> void:
	assert_true(hud.cronaca_visibile(), "La cronaca della stagione è sul tavolo.")
	var opzioni: Array[EventOptionDef] = run.chronicle_options()
	for i: int in range(opzioni.size()):
		if run.option_block_reason(opzioni[i]) == "" and run.option_choices(opzioni[i]).is_empty():
			hud.scegli_cronaca.emit(i)
			return
	fail_test("Nessuna reazione libera nella cronaca %s." % run.current_chronicle.id)


func _carte(nome: String, lato: int) -> Array:
	var gruppi: Array = _scena.get(nome)
	return gruppi[lato]


func test_senza_nazione_scelta_usa_una_nazione_di_prova() -> void:
	var run: RunState = _run()
	assert_eq(run.phase, RunState.Phase.CONSIGLIO)
	assert_eq(run.nation_name, "Nazione di prova")


func test_la_nazione_di_test_parte_con_99_risorse_e_tutti_gli_spazi() -> void:
	GameSession.selected_nation = GameSession.test_nation()
	_apri()
	var run: RunState = _run()
	var regole: RunRules = GameSession.run_rules()
	assert_eq(run.nation_name, GameSession.test_nation_setup().nation_name)
	for tipo: Res.Type in Res.NAMES:
		if tipo != Res.Type.RICERCA:
			assert_gte(run.stock[tipo], 99 * Res.scale(tipo), Res.NAMES[tipo])
	assert_eq(run.board.building_capacity(), regole.max_building_slots, "Spazi edificio tutti liberi.")
	assert_eq(run.board.troop_capacity(), regole.max_troop_slots, "Spazi truppa tutti liberi.")


## Parte dalla nazione scelta nel menu e attraversa un anno usando solo i comandi della schermata.
func test_la_partita_parte_dalla_nazione_scelta_e_attraversa_un_anno() -> void:
	GameSession.selected_nation = _nazione("Regno di Prova")
	_apri()
	var run: RunState = _run()
	var hud: HudPlancia = _scena.get("_hud")
	assert_eq(run.phase, RunState.Phase.CONSIGLIO, "La partita comincia dall'anno 1.")
	assert_eq(run.nation_name, "Regno di Prova")
	assert_eq(run.identity.size(), GameSession.selected_nation.identity_ids.size())

	# Inverno e primavera, poi l'incontro; estate, poi il secondo incontro; autunno (GDD §3.2, v0.25).
	var stagioni: Array[RunState.Season] = []
	for incontro: int in range(2):
		while run.is_shopping_phase() or run.phase == RunState.Phase.CRONACA:
			if run.phase == RunState.Phase.CRONACA:
				_reagisci_dal_pannello(run, hud)
				continue
			if not stagioni.has(run.season):
				stagioni.append(run.season)
			hud.passa.emit()
		assert_eq(run.phase, RunState.Phase.SCELTA_INCONTRO, "Incontro %d dell'anno." % (incontro + 1))
		var scelte: Array = _scena.get("_scelte")
		_scena.call("_clic_scelta", scelte[0])
		hud.azione_principale.emit()
		_scena.call("_mostra_esito")
		hud.call("_on_continua_esito")
		if run.phase == RunState.Phase.RICOMPENSA_INCONTRO:
			hud.nessuna_ricompensa.emit()
	while run.is_shopping_phase() or run.phase == RunState.Phase.CRONACA:
		if run.phase == RunState.Phase.CRONACA:
			_reagisci_dal_pannello(run, hud)
			continue
		if not stagioni.has(run.season):
			stagioni.append(run.season)
		hud.passa.emit()
	assert_eq(stagioni, [RunState.Season.INVERNO, RunState.Season.PRIMAVERA, RunState.Season.ESTATE,
			RunState.Season.AUTUNNO] as Array[RunState.Season], "Le quattro stagioni in ordine.")
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
	_fino_allo_scontro(run)
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


## Dopo uno scontro la plancia torna pulita: niente Scudo o Corruzione, e la riserva di mana (che
## sta sempre sul cuore della plancia) torna vuota.
func test_dopo_lo_scontro_la_plancia_si_azzera() -> void:
	var run: RunState = _run()
	_fino_allo_scontro(run)
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
	for nome: String in ["_segnalini_scudo", "_segnalini_corruzione"]:
		for segnalino: Node3D in (_scena.get(nome) as Array):
			assert_false(segnalino.visible, "%s nascosto dopo lo scontro." % nome)
	for riserva: Node3D in (_scena.get("_riserve") as Array):
		assert_true(riserva.visible, "La riserva di mana resta sul cuore della plancia.")
		var valori: Dictionary = riserva.get("_valori")
		for mana: StringName in valori:
			assert_eq(int(valori[mana]), 0, "La riserva di mana torna vuota dopo lo scontro (%s)." % mana)
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
	# Gli spazi vuoti sono sagome strette (Davide, 8 novembre 2026): contano anche i pezzi occupati.
	var attesa: float = _scena.call("_larghezza_per", run.board.troop_capacity() + 1, run.board.building_capacity() + 1,
			run.board.troops.size(), run.board.buildings.size())
	assert_almost_eq(float(larghezze[0]), attesa, 0.001)
	var plancia: Node3D = _scena.get("_plancia")
	assert_gt(plancia.scale.x, 1.0, "Con pochi spazi la plancia si ingrandisce.")


## Le tecnologie dell'era corrente richieste per la prossima era (GDD §10.3, v0.26).
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


func test_il_flusso_dell_anno_mostra_mesi_e_scontri() -> void:
	# Richiesta di Davide (6 novembre): il flusso dell'anno si vede, non solo come scritta.
	var run: RunState = _run()
	var hud: HudPlancia = _scena.get("_hud")
	var flusso: FlussoAnno = hud.get("_flusso")
	assert_not_null(flusso)
	assert_true(flusso.visible)
	var zone: Array = flusso.get("_zone")
	assert_eq(zone.size(), 15, "12 mesi e 3 scontri.")
	var primo: String = Suggerimenti.testo_di(flusso, (zone[0][0] as Rect2).get_center())
	assert_string_contains(primo, "Gennaio")
	assert_string_contains(primo, "adesso", "Il mese in corso è segnato.")
	assert_string_contains(primo, run.theme_name(), "Con il tema del round.")
	var fantasma: String = Suggerimenti.testo_di(flusso, (zone[14][0] as Rect2).get_center())
	assert_string_contains(fantasma, "fantasma")
	# Revisione n. 38: la nota dell'inverno c'è anche nel mese in corso e su tutti e tre i mesi.
	for i: int in range(3):
		assert_string_contains(Suggerimenti.testo_di(flusso, (zone[i][0] as Rect2).get_center()),
				"Inverno: a inizio stagione gli edifici non producono Cibo; nessuno scontro")
	# Revisione n. 70: incontri spiegati in primavera e in estate, con l'esito a parole.
	run.history[-1].encounter_result = "Vittoria · Sconfitta"
	flusso.aggiorna(run)
	var primavera: String = Suggerimenti.testo_di(flusso, (zone[6][0] as Rect2).get_center())
	assert_string_contains(primavera, "Ne scegli 1 fra 3; se perdi, l'Oro si dimezza.")
	assert_string_contains(primavera, "Vinto")
	var estate: String = Suggerimenti.testo_di(flusso, (zone[10][0] as Rect2).get_center())
	assert_string_contains(estate, "Ne scegli 1 fra 3; se perdi, l'Oro si dimezza.")
	assert_string_contains(estate, "Perso")


func test_senza_tecnologia_in_studio_c_e_un_avviso() -> void:
	# Richiesta di Davide (6 novembre): segnalare chiaramente quando la Ricerca è ferma.
	# Dal 9 novembre il segno è sul pulsante Ricerca (rosso, «scegli!»), con la spiegazione nel riquadro.
	var run: RunState = _run()
	var hud: HudPlancia = _scena.get("_hud")
	var pulsante: Button = hud.get("_pulsante_ricerca")
	_scena.call("_aggiorna_tutto")
	assert_null(run.current_tech, "All'inizio nessuna tecnologia è in studio.")
	assert_string_contains(pulsante.text, "scegli")
	assert_string_contains(Suggerimenti.testo_di(pulsante), "Ricerca resta ferma", "Il riquadro del pulsante spiega perché.")
	assert_false((hud.get("_avviso_ricerca") as Label).visible, "Niente scritta sopra i pulsanti.")
	var carte: Array[TechDef] = run.tech_hand_cards()
	assert_false(carte.is_empty())
	assert_true(run.choose_tech(carte[0]), run.last_error)
	_scena.call("_aggiorna_tutto")
	assert_false(pulsante.text.contains("scegli"), "Con una tecnologia in studio il segno sparisce.")


func test_annunci_in_alto_e_calendario_a_sinistra() -> void:
	# Richiesta di Davide (6 novembre): calendario verticale a sinistra, annunci in alto al centro.
	var run: RunState = _run()
	var hud: HudPlancia = _scena.get("_hud")
	var flusso: FlussoAnno = hud.get("_flusso")
	assert_gt(flusso.custom_minimum_size.y, flusso.custom_minimum_size.x * 0.5, "Il calendario è in verticale.")
	var zone: Array = flusso.get("_zone")
	assert_gt((zone[14][0] as Rect2).position.y, (zone[0][0] as Rect2).position.y, "Il fantasma è in fondo, sotto l'inverno.")
	hud.passa.emit()
	assert_eq((hud.get("_messaggio") as Label).text, "Round passato")
	assert_string_contains((hud.get("_sotto_messaggio") as Label).text, "Nuovo round")
	assert_string_contains((hud.get("_sotto_messaggio") as Label).text, run.month_name())


func test_scheda_della_nazione_spiega_le_caratteristiche() -> void:
	# Richiesta di Davide (6 novembre): ogni caratteristica si spiega. Dall'8 novembre Ricomincia non c'è più.
	var run: RunState = _run()
	var hud: HudPlancia = _scena.get("_hud")
	var voci: HFlowContainer = hud.get("_identita")
	var testi: Array[String] = []
	for voce: Node in voci.get_children():
		testi.append(Suggerimenti.titolo_di(voce as Control) + "\n" + Suggerimenti.testo_di(voce as Control))
	var popolo: IdentityDef = run.identity[0]
	assert_true(testi.any(func(t: String) -> bool: return t.contains(popolo.display_name) and t.contains(popolo.description)),
			"Il riquadro di una caratteristica dice che cosa fa.")
	var colonna: Control = hud.get("_colonna_principale")
	for figlio: Node in colonna.get_children():
		assert_ne((figlio as Button).text if figlio is Button else "", "Ricomincia", "Ricomincia non è più in basso a destra.")


func test_il_riquadro_delle_risorse_dice_chi_le_chiede() -> void:
	# Richiesta di Davide (6 novembre): passando su una risorsa, quali consiglieri la chiederanno.
	_run()
	var hud: HudPlancia = _scena.get("_hud")
	var celle: Dictionary = hud.get("_celle_risorse")
	var pietra: String = Suggerimenti.testo_di(celle[Res.Type.PIETRA] as Control)
	assert_string_contains(pietra, "Chi la chiede")
	assert_string_contains(pietra, "Architetto")
	assert_string_contains(pietra, "Potenzia")


## Revisione n. 35, 69, 72: Malcontento, pulsante dell'era e identità dicono tutto quello che serve.
func test_riquadri_di_malcontento_era_e_identita() -> void:
	var run: RunState = _run()
	_scena.call("_aggiorna_tutto")
	var hud: HudPlancia = _scena.get("_hud")
	var malcontento: String = Suggerimenti.testo_di(hud.get("_malcontento_cella") as Control)
	assert_string_contains(malcontento, "tessere trascurate")
	assert_string_contains(malcontento, "cronache")
	assert_string_contains(malcontento, "Stabilità (Cancelliere)")
	assert_string_contains(malcontento, "Fede (Sacerdote)")
	assert_string_contains(malcontento, "Cibo (Fattore)")
	assert_string_contains(malcontento, "Quando arriva a %d, il round dopo scoppia la Rivoluzione." % run.run_rules.malcontent_threshold)
	var era: String = Suggerimenti.testo_di(hud.get("_pulsante_era") as Control)
	assert_string_contains(era, "Servono", "Il motivo del blocco resta.")
	assert_string_contains(era, "il Consiglio sale di livello", "E dice anche che cosa si ottiene.")
	var popolo: IdentityDef = IdentityDef.new()
	popolo.display_name = "Pietrosangue"
	popolo.resistance_bonus = 8
	assert_string_contains(HudPlancia.testo_identita(popolo), "Resistenza +8")
	popolo.resistance_bonus = 0
	assert_false(HudPlancia.testo_identita(popolo).contains("Resistenza"))


## Revisione n. 18, 36, 48, 73: l'elenco di chi chiede una risorsa è completo e senza voci false.
func test_chi_chiede_una_risorsa_elenco_completo() -> void:
	var run: RunState = _run()
	var pietra: String = "\n".join(run.resource_demand_lines(Res.Type.PIETRA))
	assert_string_contains(pietra, "Architetto — Potenzia e rinnovo", "Il rinnovo si paga anche con la risorsa del consigliere.")
	var oro: String = "\n".join(run.resource_demand_lines(Res.Type.ORO))
	assert_string_contains(oro, "Tessere, spazi e rinnovi")
	assert_string_contains(oro, "Anziano — Potenzia")
	# La risorsa del round del Maestro delle spie si pesca solo fra quelle di Potenzia: mai il Cibo.
	var cibo: String = "\n".join(run.resource_demand_lines(Res.Type.CIBO))
	assert_false(cibo.contains("Maestro delle spie"), cibo)
	assert_string_contains(cibo, "Razioni delle truppe, a inizio del prossimo anno")
	var ferro: String = "\n".join(run.resource_demand_lines(Res.Type.FERRO))
	assert_string_contains(ferro, "Maestro delle spie — Potenzia e rinnovo")
	for tipo: Res.Type in Res.NAMES:
		assert_false("\n".join(run.resource_demand_lines(tipo)).contains("Visitatori —"), "Il visitatore si scrive \"Nome (Visitatore)\".")


func test_suggerimenti_colorati_e_nessun_tooltip_di_sistema() -> void:
	# Richiesta di Davide (8 novembre): tutti i suggerimenti con il riquadro nuovo, come in The Bazaar.
	_run()
	_scena.call("_aggiorna_tutto")
	var hud: HudPlancia = _scena.get("_hud")
	var da_visitare: Array[Node] = [hud]
	while not da_visitare.is_empty():
		var nodo: Node = da_visitare.pop_back()
		if nodo is Control:
			assert_eq((nodo as Control).tooltip_text, "", "%s usa ancora il tooltip grigio di Godot." % nodo.name)
		da_visitare.append_array(nodo.get_children())
	# Il riquadro delle carte della plancia spiega le parole chiave che contiene.
	hud.mostra_suggerimento("Prova", "12 danni allo scudo.", Rect2(500, 500, 120, 150))
	var pannello: PannelloSuggerimento = hud.get("_suggerimento")
	assert_true(pannello.visible)
	assert_true(pannello.spiegazioni_mostrate().has("Scudo"))
	hud.nascondi_suggerimento()
	assert_false(pannello.visible)


func test_esito_e_cronaca_con_le_parole_colorate() -> void:
	# Richiesta di Davide (8 novembre): anche esito e cronache con le parole chiave colorate.
	var run: RunState = _run()
	var hud: HudPlancia = _scena.get("_hud")
	var righe: Array[String] = ["Prestigio: 20 → 17.", "Subisci il malus Carestia."]
	hud.mostra_esito("Sconfitta", "Regno 0 · Fantasma 12", righe, StileVisivo.PERICOLO, func() -> void: pass)
	var testi: PackedStringArray = PackedStringArray()
	for riga: Node in (hud.get("_righe_esito") as VBoxContainer).get_children():
		if riga is RichTextLabel and not riga.is_queued_for_deletion():
			testi.append((riga as RichTextLabel).text)
	assert_eq(testi.size(), 2)
	assert_string_contains(testi[0], "Prestigio[/color]", "Il Prestigio è colorato.")
	assert_string_contains(testi[1], "malus[/color]", "Il malus è colorato.")
	assert_string_contains((hud.get("_sotto_esito") as RichTextLabel).text, "12[/color]", "I numeri risaltano.")
	hud.call("_on_continua_esito")
	# Il registro della Cronaca colora le parole chiave delle voci.
	run.chronicle.append("Anno 1: ricevi 2 Oro.")
	_scena.call("_aggiorna_tutto")
	assert_string_contains((hud.get("_testo_cronaca") as RichTextLabel).text, "Oro[/color]")


func test_costo_solo_per_i_prezzi_veri() -> void:
	# Decisione di Davide (8 novembre): "Costo: Ascolta" non ha senso; il costo è solo un prezzo.
	var run: RunState = _run()
	var scelte: Array = _scena.get("_scelte")
	for tessera: Variant in scelte:
		var testo: String = _scena.call("_testo_riquadro", tessera)
		assert_false(testo.contains("Costo:"), "Un consigliere o un evento non ha un costo.")
	_scena.call("_clic_scelta", scelte[0])
	assert_gt(run.offers.size(), 0, "Il consigliere ha delle proposte.")
	scelte = _scena.get("_scelte")
	var con_prezzo: int = 0
	for tessera: Variant in scelte:
		if (tessera as Tessera3D).scheda.prezzo:
			con_prezzo += 1
			assert_string_contains(_scena.call("_testo_riquadro", tessera), "Costo:", "Un'offerta dice quanto costa.")
	assert_gt(con_prezzo, 0, "Le proposte hanno un prezzo.")
