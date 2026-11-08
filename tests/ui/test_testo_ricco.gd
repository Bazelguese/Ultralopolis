extends GutTest
## Testo colorato e suggerimenti (richiesta di Davide, 8 novembre, sul modello di The Bazaar):
## le parole chiave del lessico si colorano da sole, i numeri vanno in grassetto e accanto al
## riquadro compaiono le spiegazioni prese dal GDD (§7.6, §7.7, §19).


func before_each() -> void:
	# Sempre il lessico vero dei dati.
	TestoRicco.usa_lessico(load(TestoRicco.PERCORSO_LESSICO) as Lessico)


func _voce(nome: String) -> VoceLessico:
	for voce: VoceLessico in TestoRicco.lessico().voci:
		if voce.nome == nome:
			return voce
	return null


func _colore(nome: String) -> String:
	return _voce(nome).colore.to_html(false)


## I tratti del testo come stringhe leggibili: {parola chiave}, <numero>, testo semplice.
func _tratti(testo: String) -> PackedStringArray:
	var risultato: PackedStringArray = PackedStringArray()
	for pezzo: TestoRicco.Pezzo in TestoRicco.scomponi(testo):
		if pezzo.voce != null:
			risultato.append("{%s}" % pezzo.testo)
		elif pezzo.numero:
			risultato.append("<%s>" % pezzo.testo)
		else:
			risultato.append(pezzo.testo)
	return risultato


func test_il_lessico_si_carica_dai_dati() -> void:
	var lessico: Lessico = TestoRicco.lessico()
	assert_not_null(lessico, "data/ui/lessico.tres esiste e si carica.")
	assert_gt(lessico.voci.size(), 20)
	for nome: String in ["Oro", "Scudo", "Cura", "Corruzione", "Resistenza", "Danno d'assedio", "Malcontento", "Energetico"]:
		assert_not_null(_voce(nome), "C'è la voce %s." % nome)


func test_nessuna_forma_in_due_voci() -> void:
	var viste: Dictionary[String, String] = {}
	for voce: VoceLessico in TestoRicco.lessico().voci:
		assert_ne(voce.nome, "", "Ogni voce ha un nome.")
		assert_false(voce.forme.is_empty(), "%s ha almeno una forma." % voce.nome)
		for forma: String in voce.forme:
			assert_false(viste.has(forma), "La forma '%s' è sia in %s sia in %s." % [forma, viste.get(forma, ""), voce.nome])
			viste[forma] = voce.nome


func test_le_risorse_prendono_il_loro_colore() -> void:
	var testo: String = TestoRicco.colora("Ricevi 2 Oro e 1 Documenti.")
	assert_string_contains(testo, "[color=#%s]Oro[/color]" % _colore("Oro"))
	assert_string_contains(testo, "[color=#%s]Documenti[/color]" % _colore("Documenti"))


func test_un_numero_prende_il_colore_della_parola_che_segue() -> void:
	# "+3 scudo": anche il numero è del colore dello scudo, come in The Bazaar.
	var testo: String = TestoRicco.colora("+3 scudo ogni 4 s.")
	assert_string_contains(testo, "[b][color=#%s]+3[/color][/b]" % _colore("Scudo"))
	assert_string_contains(testo, "[color=#%s]scudo[/color]" % _colore("Scudo"))
	# Un numero da solo ha il colore dei numeri, in grassetto.
	assert_string_contains(testo, "[b][color=#%s]4 s[/color][/b]" % TestoRicco.lessico().colore_numeri.to_html(false))


func test_minuscole_e_maiuscole() -> void:
	# Una forma in minuscolo vale anche con l'iniziale maiuscola…
	assert_eq(_tratti("Scudo e scudi."), PackedStringArray(["{Scudo}", " e ", "{scudi}", "."]))
	# …una forma con l'iniziale maiuscola vale solo così: "dell'oro" non è la risorsa.
	assert_eq(_tratti("Età dell'oro, 1 Oro."), PackedStringArray(["Età dell'oro, ", "<1>", " ", "{Oro}", "."]))


func test_solo_parole_intere() -> void:
	assert_eq(_tratti("Orologio scudiero"), PackedStringArray(["Orologio scudiero"]), "Nessuna parola chiave dentro un'altra parola.")
	assert_eq(_tratti("v0.29 e anno2"), PackedStringArray(["v0.29 e anno2"]), "Nessun numero dentro una parola.")


func test_la_forma_piu_lunga_vince() -> void:
	assert_eq(_tratti("Tipi: Infrastruttura Bellica"), PackedStringArray(["{Tipi}", ": ", "{Infrastruttura Bellica}"]))
	assert_eq(_tratti("un danno d'assedio"), PackedStringArray(["un ", "{danno d'assedio}"]))


func test_numeri_secondi_e_percentuali() -> void:
	assert_eq(_tratti("ricarica 2,5 s."), PackedStringArray(["{ricarica}", " ", "<2,5 s>", "."]))
	assert_eq(_tratti("il 10% più in fretta"), PackedStringArray(["il ", "<10%>", " più in fretta"]))
	assert_eq(_tratti("−1 anno, ×1,5"), PackedStringArray(["<−1>", " anno, ", "<×1,5>"]))
	# "2 giorni" e "10 secondi" non sono secondi abbreviati.
	assert_eq(_tratti("2 giorni"), PackedStringArray(["<2>", " giorni"]))
	assert_eq(_tratti("10 secondi"), PackedStringArray(["<10>", " secondi"]))


func test_le_parentesi_quadre_restano_testo() -> void:
	var testo: String = TestoRicco.colora("[b]prova[/b]")
	assert_false(testo.begins_with("[b]prova"), "Le parentesi del testo non diventano formattazione.")
	assert_string_contains(testo, "[lb]b[rb]prova[lb]/b[rb]")


func test_spiegazioni_delle_parole_di_battaglia() -> void:
	# GDD §7.6: danno, scudo e Corruzione hanno una spiegazione; le risorse no.
	var voci: Array[VoceLessico] = TestoRicco.voci_da_spiegare("2 Oro. 12 danni allo scudo, poi ancora scudo, e 3 Corruzione.")
	var nomi: PackedStringArray = PackedStringArray()
	for voce: VoceLessico in voci:
		nomi.append(voce.nome)
	assert_eq(nomi, PackedStringArray(["Danno", "Scudo", "Corruzione"]), "Nell'ordine, senza ripetizioni, senza le risorse.")


func test_spiegazioni_al_massimo_quante_previste() -> void:
	var testo: String = "danno, scudo, cura, Corruzione, Resistenza, mana, Sabotaggio, logoramento"
	assert_eq(TestoRicco.voci_da_spiegare(testo).size(), TestoRicco.lessico().massimo_spiegazioni)


func test_il_riquadro_mostra_testo_e_spiegazioni() -> void:
	var pannello: PannelloSuggerimento = PannelloSuggerimento.new()
	add_child_autofree(pannello)
	pannello.mostra("Arieti", "10 danni allo scudo · danno d'assedio.", Rect2(400, 400, 100, 120))
	assert_true(pannello.visible)
	assert_eq(pannello.titolo_mostrato(), "Arieti")
	var spiegazioni: PackedStringArray = pannello.spiegazioni_mostrate()
	assert_true(spiegazioni.has("Danno"))
	assert_true(spiegazioni.has("Scudo"))
	assert_true(spiegazioni.has("Danno d'assedio"))
	pannello.mostra("Granaio", "Ricevi 2 Cibo.", Rect2(400, 400, 100, 120))
	assert_true(pannello.spiegazioni_mostrate().is_empty(), "Senza parole da spiegare, niente riquadro accanto.")
	pannello.mostra("Malcontento", "Sale con le sconfitte e i malus.", Rect2(400, 400, 100, 120))
	assert_eq(pannello.spiegazioni_mostrate(), PackedStringArray(["Malus"]), "La parola del titolo non si rispiega.")
	pannello.nascondi()
	assert_false(pannello.visible)


func test_un_controllo_con_suggerimento_non_usa_il_tooltip_di_sistema() -> void:
	var etichetta: Label = Label.new()
	add_child_autofree(etichetta)
	etichetta.tooltip_text = "vecchio"
	assert_eq(etichetta.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	Suggerimenti.imposta(etichetta, "Ricevi 2 Oro.", "Mercato")
	assert_eq(etichetta.tooltip_text, "", "Niente doppio riquadro.")
	assert_ne(etichetta.mouse_filter, Control.MOUSE_FILTER_IGNORE, "Il controllo sente il mouse.")
	assert_eq(Suggerimenti.testo_di(etichetta), "Ricevi 2 Oro.")
	assert_eq(Suggerimenti.titolo_di(etichetta), "Mercato")
	Suggerimenti.imposta_dinamico(etichetta, func(punto: Vector2) -> String: return "x=%d" % int(punto.x))
	assert_eq(Suggerimenti.testo_di(etichetta, Vector2(7, 0)), "x=7", "Testo diverso in ogni punto.")


func test_il_riquadro_si_attacca_all_elemento() -> void:
	# Scelta di Davide (8 novembre): il riquadro compare attaccato alla carta, come in The Bazaar.
	var schermo: Vector2 = Vector2(1920, 1080)
	var misura: Vector2 = Vector2(400, 200)
	# Con spazio sopra: sopra, centrato sulla carta.
	var carta: Rect2 = Rect2(800, 500, 120, 150)
	var sopra: Rect2 = PannelloSuggerimento.posizione_attaccata(carta, misura, schermo)
	assert_almost_eq(sopra.end.y, carta.position.y - PannelloSuggerimento.DISTANZA, 0.01, "Appena sopra la carta.")
	assert_almost_eq(sopra.get_center().x, carta.get_center().x, 0.01, "Centrato sulla carta.")
	# Vicino al bordo in alto: sotto.
	var in_alto: Rect2 = Rect2(800, 40, 120, 60)
	var sotto: Rect2 = PannelloSuggerimento.posizione_attaccata(in_alto, misura, schermo)
	assert_almost_eq(sotto.position.y, in_alto.end.y + PannelloSuggerimento.DISTANZA, 0.01, "Appena sotto.")
	# Senza spazio né sopra né sotto: di lato.
	var alta: Rect2 = Rect2(800, 100, 120, 900)
	var lato: Rect2 = PannelloSuggerimento.posizione_attaccata(alta, misura, schermo)
	assert_almost_eq(lato.position.x, alta.end.x + PannelloSuggerimento.DISTANZA, 0.01, "A destra.")
	# Sul bordo destro dello schermo resta dentro.
	var a_destra: Rect2 = PannelloSuggerimento.posizione_attaccata(Rect2(1850, 500, 60, 60), misura, schermo)
	assert_lte(a_destra.end.x, schermo.x - PannelloSuggerimento.MARGINE_SCHERMO + 0.01)


func test_la_stessa_carta_ha_il_riquadro_sempre_nello_stesso_punto() -> void:
	# Da qualunque punto della carta entri il mouse, il riquadro non cambia posto.
	var pannello: PannelloSuggerimento = PannelloSuggerimento.new()
	add_child_autofree(pannello)
	var carta: Rect2 = Rect2(800, 500, 120, 150)
	pannello.mostra("Arieti", "10 danni allo scudo.", carta)
	await wait_process_frames(3)
	var prima: Rect2 = pannello.rettangolo_principale()
	assert_lte(prima.end.y, carta.position.y, "Il riquadro sta sopra la carta.")
	var spiegazioni: Rect2 = pannello.rettangolo_spiegazioni()
	assert_false(spiegazioni.intersects(prima), "Le spiegazioni affiancano il riquadro senza coprirlo.")
	pannello.nascondi()
	pannello.mostra("Arieti", "10 danni allo scudo.", carta)
	await wait_process_frames(3)
	assert_eq(pannello.rettangolo_principale(), prima)


func test_simboli_delle_carte_davanti_alle_parole() -> void:
	# Scelta di Davide (8 novembre): lo stesso simbolo delle carte; bianco come sulle carte (GDD §14.4).
	var testo: String = TestoRicco.colora("2 danni ogni 3 s, ricarica 1,8 s. Ricevi 2 Oro.", 18)
	assert_eq(_voce("Danno").simbolo, &"danno")
	assert_string_contains(testo, "[img width=16 height=16 color=#ffffff]")
	for concetto: String in ["danno", "ricarica", "oro"]:
		assert_string_contains(testo, "%s%s" % [Simboli.CARTELLA, concetto], "C'è il simbolo %s." % concetto)
	# Le gemme del mana hanno il colore del mana.
	assert_string_contains(TestoRicco.colora("mana rosso", 18), "color=#%s" % _voce("Rosso").colore.to_html(false))
	# Ogni simbolo del lessico ha il suo file, come quelli delle carte.
	for voce: VoceLessico in TestoRicco.lessico().voci:
		if voce.simbolo != &"":
			assert_not_null(Simboli.trama(voce.simbolo, 16), "Manca il simbolo %s di %s." % [voce.simbolo, voce.nome])


func test_parole_del_consiglio_della_crescita_e_della_plancia() -> void:
	# Richiesta di Davide (8 novembre): anche Propone, Potenzia e le altre parole base.
	assert_eq(_tratti("Propone edifici; Potenzia: Ferro."), PackedStringArray(["{Propone}", " edifici; ", "{Potenzia}", ": ", "{Ferro}", "."]))
	assert_eq(_tratti("Carta esclusiva: Foro (era 2)."), PackedStringArray(["Carta ", "{esclusiva}", ": Foro (", "{era 2}", ")."]))
	assert_eq(_tratti("c'era una volta"), PackedStringArray(["c'era una volta"]), "Il verbo \"era\" non è l'era.")
	assert_eq(_tratti("la via del porto"), PackedStringArray(["la via del porto"]), "\"via\" minuscola non è la Via.")
	assert_eq(_tratti("Ricevi 2 Oro, paghi 1 Fede."), PackedStringArray(["{Ricevi}", " ", "<2>", " ", "{Oro}", ", ", "{paghi}", " ", "<1>", " ", "{Fede}", "."]))
	for nome: String in ["Opportunità", "Potenzia", "Livello", "Era", "Capitale", "Spazio", "Fantasma", "Peculiarità"]:
		assert_ne(_voce(nome).definizione, "", "%s ha una spiegazione." % nome)
	assert_eq(_voce("Ricevi").definizione, "", "Ricevi e Paghi si colorano senza spiegazione.")
