class_name LegendaSimboli
extends PanelContainer
## Legenda dei simboli delle carte (GDD §14.4), richiesta di Davide: come si legge una carta,
## con esempi presi dalle carte vere, e che cosa vuol dire ogni simbolo.
## Gli esempi si costruiscono dai dati del catalogo, come sulle carte: se i dati cambiano,
## cambia anche la legenda. Solo presentazione.

const ALTEZZA_ESEMPIO: float = 40.0
const ALTEZZA_SIMBOLO: float = 34.0
const LARGHEZZA_TESTO: float = 330.0

## Gruppi di simboli, nell'ordine in cui si mostrano: [titolo, concetti].
const GRUPPI: Array = [
	["Risorse", [&"oro", &"ricerca", &"cibo", &"legno", &"pietra", &"ferro", &"fede", &"influenza", &"stabilita", &"documenti", &"malcontento"]],
	["Battaglia", [&"danno", &"scudo", &"cura", &"corruzione", &"assedio", &"inefficienza", &"sabotaggio", &"resistenza", &"ricarica"]],
	["Tessere e plancia", [&"edificio", &"truppa", &"potenzia", &"malus", &"perk", &"incanto", &"governo", &"tecnologia", &"proposta", &"azione", &"scambio"]],
	["Tempo e altro", [&"anno", &"fantasma", &"rinnovo", &"caso", &"spia", &"bloccato"]],
]

## Nome di ogni simbolo nella legenda.
const NOMI: Dictionary[StringName, String] = {
	&"oro": "Oro", &"ricerca": "Ricerca", &"cibo": "Cibo", &"legno": "Legno", &"pietra": "Pietra",
	&"ferro": "Ferro", &"fede": "Fede", &"influenza": "Influenza", &"stabilita": "Stabilità",
	&"documenti": "Documenti", &"malcontento": "Malcontento",
	&"danno": "Danno", &"scudo": "Scudo", &"cura": "Cura", &"corruzione": "Corruzione",
	&"assedio": "Danno d'assedio", &"inefficienza": "Inefficienza",
	&"sabotaggio": "Sabotaggio (ferma)", &"resistenza": "Resistenza", &"ricarica": "Ricarica, tempo",
	&"edificio": "Edificio", &"truppa": "Truppa", &"potenzia": "Potenzia", &"malus": "Malus",
	&"perk": "Peculiarità", &"incanto": "Incanto", &"governo": "Governo", &"tecnologia": "Tecnologia",
	&"proposta": "Opportunità del Consiglio",
	&"azione": "Azioni del Consiglio", &"scambio": "Scambio di risorse",
	&"anno": "Durata in anni", &"fantasma": "Prossimo scontro con il fantasma",
	&"rinnovo": "Rinnovo, ripescare", &"caso": "A caso", &"spia": "Spionaggio",
	&"bloccato": "Adesso non disponibile",
}

## Gemme di mana: [colore, nome].
const GEMME: Array = [
	[&"rosso", "Mana rosso"], [&"verde", "Mana verde"], [&"blu", "Mana blu"], [&"viola", "Mana viola"],
	[&"energetico", "Mana energetico (vale come ogni colore)"], [&"qualsiasi", "Mana in più, del colore della truppa"],
]


func costruisci(catalogo: CatalogDef) -> void:
	var scorrimento: ScrollContainer = ScrollContainer.new()
	scorrimento.custom_minimum_size = Vector2(700, 760)
	scorrimento.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scorrimento)
	var colonna: VBoxContainer = VBoxContainer.new()
	colonna.add_theme_constant_override("separation", 10)
	colonna.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scorrimento.add_child(colonna)
	colonna.add_child(StileVisivo.etichetta("LEGENDA DEI SIMBOLI", StileVisivo.FONT_TITOLI, 26, StileVisivo.ORO_LUCE))
	colonna.add_child(_testo("Sulle opportunità e sugli avvenimenti ogni riga è una cosa che puoi fare, e si legge da sinistra a destra: prima della freccia quello che paghi, dopo quello che ottieni. Sul consigliere, invece, le righe riassumono che cosa può offrirti, senza numeri. Passa il mouse su un consigliere, un'azione o un avvenimento per ingrandirlo e leggere i dettagli.", StileVisivo.TESTO_TENUE, 0.0))

	colonna.add_child(_titolo("Come si legge una riga di simboli"))
	for esempio: Array in _esempi(catalogo):
		var riga: HBoxContainer = HBoxContainer.new()
		riga.add_theme_constant_override("separation", 14)
		var simboli: VistaRigaSimboli = VistaRigaSimboli.crea(esempio[0] as RigaSimboli, ALTEZZA_ESEMPIO)
		simboli.custom_minimum_size.x = maxf(simboli.custom_minimum_size.x, 300.0)
		riga.add_child(simboli)
		riga.add_child(_testo(esempio[1] as String, StileVisivo.TESTO, LARGHEZZA_TESTO))
		colonna.add_child(riga)

	for gruppo: Array in GRUPPI:
		colonna.add_child(_titolo(gruppo[0] as String))
		var griglia: GridContainer = _griglia()
		for concetto: StringName in gruppo[1]:
			griglia.add_child(_voce(RigaSimboli.new().icona(concetto), NOMI.get(concetto, String(concetto))))
		if gruppo[0] == "Tessere e plancia":
			griglia.add_child(_voce(RigaSimboli.new().spazio(&"edificio"), "Spazio vuoto della plancia"))
			griglia.add_child(_voce(RigaSimboli.new().potenziata(&"truppa"), "Tessera che sale di livello"))
		colonna.add_child(griglia)

	# Sulla riga del timbro del consigliere i simboli dicono il tipo di azione: stesse parole
	# del riquadro dei dettagli, prese da SimboliEffetti.
	colonna.add_child(_titolo("Tipi di azione (riga del timbro sul consigliere)"))
	var tipi: GridContainer = _griglia()
	for voce: Array in tipi_di_azione():
		tipi.add_child(_voce(voce[0] as RigaSimboli, voce[1] as String))
	colonna.add_child(tipi)

	colonna.add_child(_titolo("Mana"))
	var gemme: GridContainer = _griglia()
	for gemma: Array in GEMME:
		gemme.add_child(_voce(RigaSimboli.new().gemma(gemma[0] as StringName), gemma[1] as String))
	colonna.add_child(gemme)

	colonna.add_child(_titolo("Colori dei numeri"))
	var numeri: GridContainer = _griglia()
	numeri.add_child(_voce(RigaSimboli.new().icona(&"oro", "2", RigaSimboli.Tono.COSTO), "Oro: quello che paghi"))
	numeri.add_child(_voce(RigaSimboli.new().icona(&"oro", "+3"), "Bianco: quello che ottieni"))
	numeri.add_child(_voce(RigaSimboli.new().icona(&"oro", "−50%", RigaSimboli.Tono.MALUS), "Rosso: un peggioramento"))
	colonna.add_child(numeri)


## Un esempio per ogni tipo di azione: [simbolo, nome], come sulla riga del timbro del consigliere.
static func tipi_di_azione() -> Array:
	var tipi: Array = []
	var visti: Array[String] = []
	var ordine: Array[OpportunityDef.Kind] = [
		OpportunityDef.Kind.SCAMBIO_RISORSE, OpportunityDef.Kind.MODIFICATORE_A_SCELTA,
		OpportunityDef.Kind.SPAZIO_EDIFICIO, OpportunityDef.Kind.SPAZIO_TRUPPA, OpportunityDef.Kind.ACCORCIA_MALUS,
		OpportunityDef.Kind.SPIONAGGIO, OpportunityDef.Kind.INCANTO, OpportunityDef.Kind.PERK,
		OpportunityDef.Kind.RIPESCA_TECNOLOGIE,
	]
	for tipo: OpportunityDef.Kind in ordine:
		var esempi: Array[OpportunityDef] = []
		var def: OpportunityDef = OpportunityDef.new()
		def.kind = tipo
		if tipo == OpportunityDef.Kind.SCAMBIO_RISORSE:
			def.gain_gold = 1
			# Lo scambio che serve solo a calmare il Malcontento ha un simbolo suo.
			var calma: OpportunityDef = OpportunityDef.new()
			calma.kind = tipo
			calma.malcontent_change = -1
			esempi.append(def)
			esempi.append(calma)
		else:
			esempi.append(def)
		for esempio: OpportunityDef in esempi:
			var simbolo: RigaSimboli = SimboliEffetti.tipo_di_azione(esempio)
			if visti.has(simbolo.come_testo()):
				continue
			visti.append(simbolo.come_testo())
			var nome: String = SimboliEffetti.nome_tipo_di_azione(esempio)
			tipi.append([simbolo, nome.substr(0, 1).to_upper() + nome.substr(1)])
	return tipi


## Esempi: [riga, spiegazione]. Quelli presi dalle carte vere usano i dati del catalogo
## (se un'azione non c'è più, l'esempio si salta).
func _esempi(catalogo: CatalogDef) -> Array:
	var esempi: Array = []
	var azioni: Dictionary[StringName, OpportunityDef] = {}
	for consigliere: AdvisorDef in catalogo.advisors:
		for azione: OpportunityDef in consigliere.actions:
			azioni[azione.id] = azione
	var spiegazioni: Array = [
		[&"decreto_fiscale", "prima della freccia quello che paghi (numeri in oro), dopo quello che ottieni."],
		[&"assemblea", "il calendario con il numero dice quanti anni dura. La barra «/» vuol dire «oppure»: scegli una delle due."],
		[&"addestramento", "la truppa davanti all'effetto è una truppa a tua scelta; la clessidra è la ricarica, che si accorcia."],
		[&"fortificazioni", "il fantasma vuol dire «nel prossimo scontro con il fantasma»."],
		[&"architetti", "la cornice tratteggiata è uno spazio vuoto in più sulla plancia."],
	]
	for voce: Array in spiegazioni:
		var def: OpportunityDef = azioni.get(voce[0] as StringName) as OpportunityDef
		if def == null:
			continue
		var offerta: Offer = Offer.new()
		offerta.opportunity = def
		offerta.kind = def.kind
		offerta.price = def.cost_gold
		offerta.research_price = def.cost_research
		offerta.other_cost = def.cost_resources
		esempi.append([SimboliEffetti.azione(offerta), "%s: %s" % [def.display_name, voce[1]]])
	var proposte: RigaSimboli = RigaSimboli.new().icona(&"proposta").scritta(":").icona(&"edificio").scritta("/").icona(&"truppa")
	proposte.rilievo = RigaSimboli.Rilievo.PRINCIPALE
	esempi.append([proposte, "Riga colorata, in alto sul consigliere: che cosa ti propone in questo round (qui edifici e truppe dei suoi tipi)."])
	var tipi_azione: RigaSimboli = RigaSimboli.new().icona(&"azione").scritta(":").icona(&"scambio").icona(&"anno").icona(&"spia")
	esempi.append([tipi_azione, "Sotto, il timbro e i tipi di azione che può proporre: qui scambi di risorse, bonus per un tempo e spionaggio. Costi ed effetti esatti li vedi sulle opportunità, dopo averlo scelto."])
	var potenzia: RigaSimboli = RigaSimboli.new().icona(&"potenzia").scritta(":").icona(&"ferro", "", RigaSimboli.Tono.COSTO)
	potenzia.rilievo = RigaSimboli.Rilievo.SECONDARIA
	esempi.append([potenzia, "Riga con il solo bordo, in fondo al consigliere: un servizio in più, non un'opportunità. Dopo averlo scelto puoi anche potenziare una tua tessera dei suoi tipi, pagando Ferro, senza perdere la scelta del round."])
	var pronto: RigaSimboli = RigaSimboli.new().icona(&"potenzia").scritta(":").icona(&"ferro", "", RigaSimboli.Tono.COSTO)
	pronto.rilievo = RigaSimboli.Rilievo.SECONDARIA
	pronto.accesa = true
	esempi.append([pronto, "Potenzia dorato: puoi già potenziare qualche tessera. Sotto il consigliere leggi quante: «Ascolta · ▲ Potenzia 2»."])
	var due_effetti: RigaSimboli = RigaSimboli.new().icona(&"ricerca", "+2").scritta("·").icona(&"tecnologia", "+1")
	esempi.append([due_effetti, "Il punto «·» separa due effetti della stessa scelta: li ottieni tutti e due."])
	var bloccata: RigaSimboli = RigaSimboli.new().icona(&"bloccato").icona(&"documenti", "2", RigaSimboli.Tono.COSTO).scritta("→").icona(&"influenza", "+3")
	bloccata.spenta = true
	esempi.append([bloccata, "Lucchetto e riga spenta: adesso non puoi sceglierla (ti manca un requisito o una risorsa). Il motivo è nei dettagli."])
	return esempi


func _griglia() -> GridContainer:
	var griglia: GridContainer = GridContainer.new()
	griglia.columns = 2
	griglia.add_theme_constant_override("h_separation", 18)
	griglia.add_theme_constant_override("v_separation", 6)
	return griglia


func _voce(riga: RigaSimboli, nome: String) -> HBoxContainer:
	var voce: HBoxContainer = HBoxContainer.new()
	voce.add_theme_constant_override("separation", 8)
	voce.custom_minimum_size = Vector2(330, 0)
	var simbolo: VistaRigaSimboli = VistaRigaSimboli.crea(riga, ALTEZZA_SIMBOLO, false)
	simbolo.custom_minimum_size.x = maxf(simbolo.custom_minimum_size.x, 62.0)
	voce.add_child(simbolo)
	voce.add_child(_testo(nome, StileVisivo.TESTO, 250.0))
	return voce


func _titolo(testo: String) -> Label:
	var titolo: Label = StileVisivo.etichetta(testo.to_upper(), StileVisivo.FONT_TITOLI, 19, StileVisivo.ORO_LUCE)
	return titolo


func _testo(testo: String, colore: Color, larghezza: float) -> Label:
	var etichetta: Label = StileVisivo.etichetta(testo, StileVisivo.FONT_TESTO, 16, colore)
	etichetta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	etichetta.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	if larghezza > 0.0:
		etichetta.custom_minimum_size = Vector2(larghezza, 0)
	else:
		etichetta.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return etichetta
