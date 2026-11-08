class_name SimboliEffetti
extends RefCounted
## Traduce in righe di simboli quello che fanno consiglieri, azioni ed eventi, leggendo i dati
## del gioco: costi, guadagni, modificatori, spazi, potenziamenti, spionaggio, Malcontento.
## Le righe si leggono così: quello che paghi, una freccia, quello che ottieni.
## Es. Decreto fiscale: "2[Stabilità] → +4[Oro]".
## Solo presentazione: non decide niente, descrive i dati come sono.

## Oltre questo numero di voci, l'opzione scelta va su più righe.
const VOCI_PER_RIGA: int = 7


# --- Consiglieri ---------------------------------------------------------------

## Il "menu" di un consigliere (GDD §4.2), in ordine di importanza (richiesta di Davide):
## 1. che cosa propone in questo round (riga principale, colorata): edifici, truppe;
## 2. le azioni che potrebbe proporre adesso, una per riga;
## 3. per ultimo, in disparte, il Potenzia: è un servizio in più del consigliere, non una proposta.
static func consigliere(run: RunState, def: AdvisorDef) -> Array[RigaSimboli]:
	var righe: Array[RigaSimboli] = []
	if def.special == AdvisorDef.Special.CLOWN:
		# Un elemento per ogni colore di mana e un edificio neutro (GDD §4.2.2).
		var colori: RigaSimboli = RigaSimboli.new()
		colori.etichetta = "Propone un elemento per colore di mana e un edificio neutro"
		colori.rilievo = RigaSimboli.Rilievo.PRINCIPALE
		colori.icona(&"proposta").scritta(":")
		for colore: StringName in [&"rosso", &"verde", &"blu", &"viola"]:
			colori.gemma(colore)
		colori.icona(&"edificio")
		righe.append(colori)
		return righe
	var edifici: bool = run.advisor_offers_elements(def, false)
	var truppe: bool = run.advisor_offers_elements(def, true)
	if edifici or truppe:
		var elementi: RigaSimboli = RigaSimboli.new()
		elementi.etichetta = "Propone %s" % ("edifici e truppe" if edifici and truppe else ("edifici" if edifici else "truppe"))
		if def.special == AdvisorDef.Special.ANZIANO:
			elementi.etichetta = "Propone edifici neutri"
		elementi.rilievo = RigaSimboli.Rilievo.PRINCIPALE
		elementi.icona(&"proposta").scritta(":")
		if edifici:
			elementi.icona(&"edificio")
		if edifici and truppe:
			elementi.scritta("/")
		if truppe:
			elementi.icona(&"truppa")
		if def.special == AdvisorDef.Special.VISITATORE:
			_prezzo_visitatore(elementi, def)
		righe.append(elementi)
	righe.append_array(azioni_riunite(run.advisor_action_preview(def)))
	var potenzia: RigaSimboli = RigaSimboli.new()
	potenzia.rilievo = RigaSimboli.Rilievo.SECONDARIA
	match def.special:
		AdvisorDef.Special.ANZIANO:
			potenzia.etichetta = "Potenzia un edificio neutro, una volta all'anno, in Oro"
			potenzia.icona(&"potenzia").icona(&"edificio").scritta(":").icona(&"oro", "", RigaSimboli.Tono.COSTO).scritta("1×").icona(&"anno")
		AdvisorDef.Special.VISITATORE:
			pass  # I visitatori non potenziano (GDD §4.2.5).
		_:
			potenzia.etichetta = "Potenzia con %s" % run.advisor_resource_text(def)
			potenzia.icona(&"potenzia").scritta(":").icona(Simboli.di_risorsa(def.upgrade_resource), "", RigaSimboli.Tono.COSTO)
			if def.random_resource:
				potenzia.scritta("+").icona(Simboli.di_risorsa(run.shadow_resource), "", RigaSimboli.Tono.COSTO)
	if not potenzia.vuota():
		# Con questo consigliere puoi già potenziare qualche tua carta (P4).
		potenzia.accesa = not run.affordable_upgrades(def).is_empty()
		righe.append(potenzia)
	return righe


## Una riga per azione; gli incanti e gli spionaggi, che spesso sono molti e si somigliano,
## si riuniscono in una riga sola con le alternative separate da "/". Così la carta resta leggibile.
static func azioni_riunite(azioni: Array[Offer]) -> Array[RigaSimboli]:
	var righe: Array[RigaSimboli] = []
	var gruppi: Dictionary[OpportunityDef.Kind, Array] = {}
	for offerta: Offer in azioni:
		if offerta.kind == OpportunityDef.Kind.INCANTO or offerta.kind == OpportunityDef.Kind.SPIONAGGIO:
			if not gruppi.has(offerta.kind):
				gruppi[offerta.kind] = []
			gruppi[offerta.kind].append(offerta)
	var fatti: Dictionary[OpportunityDef.Kind, bool] = {}
	for offerta: Offer in azioni:
		if not gruppi.has(offerta.kind) or gruppi[offerta.kind].size() < 2:
			righe.append(azione(offerta))
		elif not fatti.has(offerta.kind):
			fatti[offerta.kind] = true
			var gruppo: Array[Offer] = []
			gruppo.assign(gruppi[offerta.kind])
			righe.append_array(_righe_riunite(gruppo))
	return righe


## Più incanti o più spionaggi in una riga: costo (es. "2/3" se cambia), freccia, alternative.
## Se le alternative degli incanti sono più di 3, vanno su una seconda riga.
static func _righe_riunite(gruppo: Array[Offer]) -> Array[RigaSimboli]:
	var righe: Array[RigaSimboli] = []
	var riga: RigaSimboli = RigaSimboli.new()
	var nomi: PackedStringArray = PackedStringArray()
	for offerta: Offer in gruppo:
		nomi.append(offerta.describe())
	riga.etichetta = ", ".join(nomi)
	if _costo_riunito(riga, gruppo):
		riga.scritta("→")
	var concetti: Array[StringName] = []
	if gruppo[0].kind == OpportunityDef.Kind.INCANTO:
		riga.icona(&"incanto").icona(&"truppa")
		var mana: int = 0
		for offerta: Offer in gruppo:
			var valori: Array[ModifierDef.BattleValue] = [offerta.opportunity.enchant_value]
			if not offerta.opportunity.enchant_amounts_2.is_empty():
				valori.append(offerta.opportunity.enchant_value_2)
			for valore: ModifierDef.BattleValue in valori:
				if not concetti.has(Simboli.di_valore(valore)):
					concetti.append(Simboli.di_valore(valore))
			mana = maxi(mana, offerta.opportunity.enchant_mana)
		riga.gemma(&"qualsiasi", "+%d" % mana, RigaSimboli.Tono.MALUS)
		if concetti.size() > 3:
			var seconda: RigaSimboli = RigaSimboli.new()
			seconda.etichetta = riga.etichetta
			_alternative(seconda, concetti, "+")
			righe.append(riga)
			righe.append(seconda)
			return righe
		riga.simboli.pop_back()
		_alternative(riga, concetti, "+")
		riga.gemma(&"qualsiasi", "+%d" % mana, RigaSimboli.Tono.MALUS)
	else:
		riga.icona(&"fantasma").scritta(":")
		for offerta: Offer in gruppo:
			var concetto: StringName = &"sabotaggio" if offerta.opportunity.spy_effect == OpportunityDef.SpyEffect.SABOTAGGIO else &"inefficienza"
			if not concetti.has(concetto):
				concetti.append(concetto)
		_alternative(riga, concetti, "")
	righe.append(riga)
	return righe


## Simboli alternativi separati da "/"; il testo davanti va solo sul primo.
static func _alternative(riga: RigaSimboli, concetti: Array[StringName], testo: String) -> void:
	for i: int in range(concetti.size()):
		if i > 0:
			riga.scritta("/")
		riga.icona(concetti[i], testo if i == 0 else "", RigaSimboli.Tono.BONUS)


## Costo di più proposte insieme: per ogni risorsa il valore, oppure "minimo/massimo" se cambia.
static func _costo_riunito(riga: RigaSimboli, gruppo: Array[Offer]) -> bool:
	var pagato: bool = false
	for tipo: Res.Type in Res.NAMES:
		var minimo: int = -1
		var massimo: int = 0
		for offerta: Offer in gruppo:
			var quanto: int = _costo_di(offerta, tipo)
			minimo = quanto if minimo < 0 else mini(minimo, quanto)
			massimo = maxi(massimo, quanto)
		if massimo <= 0:
			continue
		riga.icona(Simboli.di_risorsa(tipo), str(massimo) if minimo == massimo else "%d/%d" % [minimo, massimo], RigaSimboli.Tono.COSTO)
		pagato = true
	return pagato


static func _costo_di(offerta: Offer, tipo: Res.Type) -> int:
	var quanto: int = offerta.other_cost.whole(tipo) if offerta.other_cost != null else 0
	if tipo == Res.Type.ORO:
		quanto += offerta.price
	elif tipo == Res.Type.RICERCA:
		quanto += offerta.research_price
	return quanto


## Il visitatore cambia i prezzi (GDD §4.2.5): Oro in più o in meno e un costo aggiuntivo.
static func _prezzo_visitatore(riga: RigaSimboli, def: AdvisorDef) -> void:
	if def.price_extra != 0:
		riga.icona(&"oro", _con_segno(def.price_extra), RigaSimboli.Tono.MALUS if def.price_extra > 0 else RigaSimboli.Tono.BONUS)
	if def.extra_cost != null and not def.extra_cost.is_empty():
		riga.scritta("+")
		_risorse(riga, def.extra_cost, 1, RigaSimboli.Tono.COSTO, false)


# --- Azioni del Consiglio ------------------------------------------------------

## Una proposta di azione o di perk, con il costo già calcolato dalle regole (sconti compresi).
static func azione(offerta: Offer) -> RigaSimboli:
	var riga: RigaSimboli = RigaSimboli.new()
	riga.etichetta = offerta.describe()
	var pagato: bool = _costo(riga, offerta.price, offerta.research_price, offerta.other_cost)
	var effetto: RigaSimboli = effetto_azione(offerta.opportunity)
	if pagato and not effetto.vuota():
		riga.scritta("→")
	riga.accoda(effetto)
	return riga


## Che cosa ottiene chi prende l'azione (senza il costo).
static func effetto_azione(def: OpportunityDef) -> RigaSimboli:
	var riga: RigaSimboli = RigaSimboli.new()
	if def == null:
		return riga
	match def.kind:
		OpportunityDef.Kind.SPAZIO_EDIFICIO:
			riga.spazio(&"edificio", "+1")
		OpportunityDef.Kind.SPAZIO_TRUPPA:
			riga.spazio(&"truppa", "+1")
		OpportunityDef.Kind.SCAMBIO_RISORSE:
			if def.gain_gold > 0:
				riga.icona(&"oro", "+%d" % def.gain_gold, RigaSimboli.Tono.BONUS)
			if def.gain_research > 0:
				riga.icona(&"ricerca", "+%d" % def.gain_research, RigaSimboli.Tono.BONUS)
			if def.gain_resources != null:
				_risorse(riga, def.gain_resources, 1, RigaSimboli.Tono.BONUS, true)
		OpportunityDef.Kind.MODIFICATORE_A_SCELTA:
			riga.accoda(modificatori_a_scelta(def.modifiers))
		OpportunityDef.Kind.ACCORCIA_MALUS:
			riga.icona(&"malus").icona(&"anno", "−%d" % def.shorten_years, RigaSimboli.Tono.BONUS)
		OpportunityDef.Kind.SPIONAGGIO:
			riga.accoda(spionaggio(def, def.spy_ms))
		OpportunityDef.Kind.INCANTO:
			riga.icona(&"incanto").icona(&"truppa").icona(Simboli.di_valore(def.enchant_value), "+", RigaSimboli.Tono.BONUS)
			if not def.enchant_amounts_2.is_empty():
				riga.icona(Simboli.di_valore(def.enchant_value_2), "+", RigaSimboli.Tono.BONUS)
			riga.gemma(&"qualsiasi", "+%d" % def.enchant_mana, RigaSimboli.Tono.MALUS)
		OpportunityDef.Kind.PERK:
			riga.icona(&"perk", "+1", RigaSimboli.Tono.BONUS)
		OpportunityDef.Kind.RIPESCA_TECNOLOGIE:
			riga.icona(&"rinnovo").icona(&"tecnologia")
	if def.malcontent_change != 0:
		riga.accoda(malcontento(def.malcontent_change))
	return riga


## Spionaggio sul fantasma dell'anno (GDD §12): quale elemento colpisce, con che cosa e per quanto.
static func spionaggio(def: OpportunityDef, durata_ms: int) -> RigaSimboli:
	var riga: RigaSimboli = RigaSimboli.new()
	riga.icona(&"fantasma").scritta(":")
	if def.spy_criterion == OpportunityDef.SpyCriterion.A_CASO:
		riga.icona(&"caso")
	match def.spy_target:
		TimerTarget.Kind.TRUPPE:
			riga.icona(&"truppa")
		TimerTarget.Kind.EDIFICI:
			riga.icona(&"edificio")
		_:
			riga.icona(&"edificio").scritta("/").icona(&"truppa")
	var concetto: StringName = &"sabotaggio" if def.spy_effect == OpportunityDef.SpyEffect.SABOTAGGIO else &"inefficienza"
	riga.icona(concetto, SchedaCarta.secondi(durata_ms).replace(" ", ""), RigaSimboli.Tono.BONUS)
	return riga


static func malcontento(variazione: int) -> RigaSimboli:
	var riga: RigaSimboli = RigaSimboli.new()
	riga.icona(&"malcontento", _con_segno(variazione), RigaSimboli.Tono.BONUS if variazione < 0 else RigaSimboli.Tono.MALUS)
	return riga


# --- Modificatori (GDD §8) ----------------------------------------------------

## Più modificatori fra cui scegliere (es. Assemblea): la durata, se è la stessa per tutti,
## si scrive una volta sola davanti; le alternative sono separate da "/".
static func modificatori_a_scelta(lista: Array[ModifierDef]) -> RigaSimboli:
	var riga: RigaSimboli = RigaSimboli.new()
	if lista.is_empty():
		return riga
	var stessa_durata: bool = true
	for def: ModifierDef in lista:
		if _chiave_durata(def) != _chiave_durata(lista[0]):
			stessa_durata = false
	if stessa_durata:
		riga.accoda(durata(lista[0]))
	for i: int in range(lista.size()):
		if i > 0:
			riga.scritta("/")
		riga.accoda(modificatore(lista[i], not stessa_durata))
	return riga


## Un modificatore: durata (se richiesta), su chi agisce e che cosa cambia.
static func modificatore(def: ModifierDef, con_durata: bool = true) -> RigaSimboli:
	var riga: RigaSimboli = RigaSimboli.new()
	if con_durata:
		riga.accoda(durata(def))
	var tono: RigaSimboli.Tono = RigaSimboli.Tono.MALUS if def.is_malus else RigaSimboli.Tono.BONUS
	var bersaglio: StringName = &""
	match def.target:
		ModifierDef.Target.TRUPPA_SCELTA:
			bersaglio = &"truppa"
		ModifierDef.Target.EDIFICIO_SCELTO:
			bersaglio = &"edificio"
		ModifierDef.Target.TRUPPA_A_CASO:
			riga.icona(&"caso")
			bersaglio = &"truppa"
		ModifierDef.Target.EDIFICIO_A_CASO:
			riga.icona(&"caso")
			bersaglio = &"edificio"
	# Gli effetti che riguardano per forza truppe o edifici mostrano il bersaglio anche se è tutta la nazione.
	if bersaglio == &"":
		match def.effect:
			ModifierDef.Effect.RICARICA_TRUPPA, ModifierDef.Effect.DANNO_TRUPPA, ModifierDef.Effect.CIBO_TRUPPA:
				bersaglio = &"truppa"
			ModifierDef.Effect.INTERVALLO_MANA:
				bersaglio = &"edificio"
	if bersaglio != &"":
		riga.icona(bersaglio)
	if def.target_type != &"":
		riga.scritta(String(def.target_type))
	elif not def.target_types_any.is_empty():
		riga.scritta(_nomi(def.target_types_any))
	var percento: String = _con_segno(def.amount) + "%"
	match def.effect:
		ModifierDef.Effect.PRODUZIONE_ORO:
			riga.icona(&"oro", percento, tono)
		ModifierDef.Effect.PRODUZIONE_RICERCA:
			riga.icona(&"ricerca", percento, tono)
		ModifierDef.Effect.PRODUZIONE_PERCENTUALE:
			riga.icona(Simboli.di_risorsa(def.resource), percento, tono)
		ModifierDef.Effect.PRODUZIONE_PER_EDIFICIO:
			riga.icona(Simboli.di_risorsa(def.resource), _con_segno(def.amount), tono)
			if bersaglio == &"":
				riga.scritta("/").icona(&"edificio")
		ModifierDef.Effect.INTERVALLO_MANA, ModifierDef.Effect.RICARICA_TRUPPA:
			riga.icona(&"ricarica", percento, tono)
		ModifierDef.Effect.COSTO_RINNOVO:
			riga.icona(&"rinnovo").icona(&"oro", _con_segno(def.amount), tono)
		ModifierDef.Effect.ALTERNATIVE_OFFERTE:
			riga.icona(&"proposta", _con_segno(def.amount), tono)
		ModifierDef.Effect.RESISTENZA:
			riga.icona(&"resistenza", _con_segno(def.amount), tono)
		ModifierDef.Effect.DANNO_TRUPPA:
			riga.icona(&"danno", percento, tono)
		ModifierDef.Effect.VALORE_PERCENTUALE:
			riga.icona(Simboli.di_valore(def.battle_value), percento, tono)
		ModifierDef.Effect.VALORE_FISSO:
			riga.icona(Simboli.di_valore(def.battle_value), _con_segno(def.amount), tono)
		ModifierDef.Effect.SCUDO_INIZIALE:
			riga.icona(&"scudo", _con_segno(def.amount), tono)
		ModifierDef.Effect.CORRUZIONE_INIZIALE:
			riga.icona(&"corruzione", _con_segno(def.amount), tono)
		ModifierDef.Effect.SABOTAGGIO_INIZIALE:
			if bersaglio == &"":
				riga.icona(&"caso").icona(&"edificio")
			riga.icona(&"sabotaggio", SchedaCarta.secondi(def.amount).replace(" ", ""), tono)
		ModifierDef.Effect.CIBO_TRUPPA:
			riga.icona(&"cibo", percento, tono)
	return riga


## Quanto dura un modificatore: anni (calendario con il numero), fino al prossimo fantasma, o sempre.
static func durata(def: ModifierDef) -> RigaSimboli:
	var riga: RigaSimboli = RigaSimboli.new()
	match def.duration_kind:
		ModifierDef.Duration.ANNI:
			riga.icona(&"anno", str(def.duration_years))
		ModifierDef.Duration.PROSSIMO_SCONTRO_FANTASMA:
			riga.icona(&"fantasma").scritta(":")
		ModifierDef.Duration.PERMANENTE:
			riga.scritta("sempre:")
	return riga


static func _chiave_durata(def: ModifierDef) -> String:
	return "%d|%d" % [def.duration_kind, def.duration_years]


# --- Eventi, Fortune e opzioni (GDD §4.2.5) ------------------------------------

## La carta di un Evento o di una Fortuna fra le carte del round: una riga per opzione,
## spenta e con il lucchetto se adesso non si può scegliere (principio P4).
static func evento(run: RunState, def: EventDef) -> Array[RigaSimboli]:
	var righe: Array[RigaSimboli] = []
	var scala: int = run.era if def.scale_with_era else 1
	if def.special == EventDef.Special.RIVOLUZIONE or def.special == EventDef.Special.RIFORMA:
		var governi: Array[IdentityDef] = run.revolution_targets() if def.special == EventDef.Special.RIVOLUZIONE else run.evolution_targets()
		for governo: IdentityDef in governi:
			var riga: RigaSimboli = RigaSimboli.new()
			riga.etichetta = "Verso: %s" % governo.display_name
			if def.special == EventDef.Special.RIFORMA:
				riga.icona(&"influenza", str(run.run_rules.reform_influence_per_tier * governo.tier), RigaSimboli.Tono.COSTO).scritta("→")
			riga.icona(&"governo").scritta(governo.display_name, RigaSimboli.Tono.NORMALE)
			righe.append(riga)
	for opzione: EventOptionDef in def.options:
		var riga: RigaSimboli = opzione_in_una_riga(opzione, scala)
		riga.spenta = run.option_block_reason(opzione) != ""
		if riga.spenta:
			riga.simboli.push_front(RigaSimboli.new().icona(&"bloccato").simboli[0])
		righe.append(riga)
	return righe


## Un'opzione in una sola riga: costo, freccia, effetti.
static func opzione_in_una_riga(opzione: EventOptionDef, scala: int) -> RigaSimboli:
	var righe: Array[RigaSimboli] = opzione_righe(opzione, scala, 0)
	return righe[0]


## Un'opzione su una o più righe: la prima ha il costo e la freccia; se le voci sono più di
## "voci_per_riga" (0 = nessun limite), ogni effetto successivo va su una riga sua.
static func opzione_righe(opzione: EventOptionDef, scala: int, voci_per_riga: int = VOCI_PER_RIGA) -> Array[RigaSimboli]:
	var prima: RigaSimboli = RigaSimboli.new()
	prima.etichetta = opzione.label
	var pagato: bool = false
	if opzione.cost != null and not opzione.cost.is_empty():
		pagato = _risorse(prima, opzione.cost, 1, RigaSimboli.Tono.COSTO, false)
	var gruppi: Array[RigaSimboli] = _effetti_opzione(opzione, scala)
	if pagato and not gruppi.is_empty():
		prima.scritta("→")
	if gruppi.is_empty():
		if not pagato:
			prima.scritta("—")
		var unica: Array[RigaSimboli] = [prima]
		return unica
	var totale: int = prima.simboli.size()
	for gruppo: RigaSimboli in gruppi:
		totale += gruppo.simboli.size()
	var righe: Array[RigaSimboli] = [prima]
	prima.accoda(gruppi[0])
	for i: int in range(1, gruppi.size()):
		if voci_per_riga <= 0 or totale <= voci_per_riga or righe.size() >= 3:
			righe[righe.size() - 1].scritta("·").accoda(gruppi[i])
		else:
			var nuova: RigaSimboli = RigaSimboli.new()
			nuova.etichetta = opzione.label
			nuova.accoda(gruppi[i])
			righe.append(nuova)
	return righe


## Gli effetti di un'opzione, uno per gruppo, nell'ordine in cui le regole li applicano.
static func _effetti_opzione(opzione: EventOptionDef, scala: int) -> Array[RigaSimboli]:
	var gruppi: Array[RigaSimboli] = []
	if opzione.gain != null and not opzione.gain.is_empty():
		var guadagno: RigaSimboli = RigaSimboli.new()
		_risorse(guadagno, opzione.gain, scala, RigaSimboli.Tono.BONUS, true)
		gruppi.append(guadagno)
	if not opzione.modifiers.is_empty():
		var stessa_durata: bool = true
		for def: ModifierDef in opzione.modifiers:
			if _chiave_durata(def) != _chiave_durata(opzione.modifiers[0]):
				stessa_durata = false
		var modificatori: RigaSimboli = RigaSimboli.new()
		if stessa_durata:
			modificatori.accoda(durata(opzione.modifiers[0]))
		for def: ModifierDef in opzione.modifiers:
			modificatori.accoda(modificatore(def, not stessa_durata))
		gruppi.append(modificatori)
	if opzione.give_building != null:
		gruppi.append(RigaSimboli.new().icona(&"edificio", "+1", RigaSimboli.Tono.BONUS))
	if opzione.give_troop != null:
		gruppi.append(RigaSimboli.new().icona(&"truppa", "+1", RigaSimboli.Tono.BONUS))
	if opzione.give_random:
		var regalo: RigaSimboli = RigaSimboli.new().icona(&"caso")
		regalo.icona(&"truppa" if opzione.give_random_kind == EventOptionDef.PieceKind.TRUPPA else &"edificio", "+1", RigaSimboli.Tono.BONUS)
		gruppi.append(regalo)
	if opzione.upgrade:
		var potenzia: RigaSimboli = RigaSimboli.new()
		if opzione.upgrade_kind != EventOptionDef.PieceKind.TRUPPA:
			potenzia.potenziata(&"edificio")
		if opzione.upgrade_kind == EventOptionDef.PieceKind.QUALSIASI:
			potenzia.scritta("/")
		if opzione.upgrade_kind != EventOptionDef.PieceKind.EDIFICIO:
			potenzia.potenziata(&"truppa")
		if not opzione.upgrade_types.is_empty():
			potenzia.scritta(_nomi(opzione.upgrade_types))
		gruppi.append(potenzia)
	if opzione.extra_building_slots > 0:
		gruppi.append(RigaSimboli.new().spazio(&"edificio", "+%d" % opzione.extra_building_slots))
	if opzione.extra_troop_slots > 0:
		gruppi.append(RigaSimboli.new().spazio(&"truppa", "+%d" % opzione.extra_troop_slots))
	if opzione.spy != null:
		gruppi.append(spionaggio(opzione.spy, opzione.spy.spy_ms))
	if opzione.give_tech != null or opzione.give_random_tech:
		gruppi.append(RigaSimboli.new().icona(&"tecnologia", "+1", RigaSimboli.Tono.BONUS))
	if opzione.change_government != null:
		gruppi.append(RigaSimboli.new().icona(&"governo"))
	if opzione.malcontent_change != 0:
		gruppi.append(malcontento(opzione.malcontent_change))
	# Cronache (GDD §9.6): verso quali poli spinge la nazione. Per ora in parole: i poli sono otto.
	var spinta: RigaSimboli = RigaSimboli.new()
	for asse: int in range(mini(opzione.inclination_shift.size(), Inclination.Axis.size())):
		var passi: int = opzione.inclination_shift[asse]
		if passi != 0:
			spinta.scritta("%s%s" % [Inclination.pole_name(asse, passi), "" if absi(passi) == 1 else " ×%d" % absi(passi)], RigaSimboli.Tono.NORMALE)
	if not spinta.vuota():
		gruppi.append(spinta)
	return gruppi


# --- Aiuti ---------------------------------------------------------------------

## Aggiunge il costo (Oro, Ricerca e altre risorse) e restituisce true se c'è qualcosa da pagare.
static func _costo(riga: RigaSimboli, oro: int, ricerca: int, altre: ResourceAmounts) -> bool:
	var pagato: bool = false
	if oro > 0:
		riga.icona(&"oro", str(oro), RigaSimboli.Tono.COSTO)
		pagato = true
	if ricerca > 0:
		riga.icona(&"ricerca", str(ricerca), RigaSimboli.Tono.COSTO)
		pagato = true
	if altre != null and _risorse(riga, altre, 1, RigaSimboli.Tono.COSTO, false):
		pagato = true
	return pagato


## Aggiunge una voce per ogni risorsa presente; con "segno" scrive "+3" invece di "3".
## Restituisce true se ha aggiunto qualcosa.
static func _risorse(riga: RigaSimboli, quantita: ResourceAmounts, scala: int, tono: RigaSimboli.Tono, segno: bool) -> bool:
	var aggiunte: bool = false
	for tipo: Res.Type in Res.NAMES:
		var unita: int = quantita.whole(tipo) * scala
		if unita == 0:
			continue
		riga.icona(Simboli.di_risorsa(tipo), _con_segno(unita) if segno else str(unita), tono)
		aggiunte = true
	return aggiunte


## Nomi dei tipi separati da "/", es. "Spirituale / Patriota".
static func _nomi(tipi: Array[StringName]) -> String:
	var nomi: PackedStringArray = PackedStringArray()
	for tipo: StringName in tipi:
		nomi.append(String(tipo))
	return " / ".join(nomi)


## "+3", "−2" (con il vero segno meno), "0".
static func _con_segno(valore: int) -> String:
	if valore > 0:
		return "+%d" % valore
	if valore < 0:
		return "−%d" % absi(valore)
	return "0"
