extends GutTest
## Cronache della nazione (GDD §9.6, v0.29): momenti di stagione, inclinazioni, usanze,
## personaggi e catene, vocazioni. Dati solo di prova.

const Aiuti = preload("res://tests/sim/aiuti_consiglio.gd")
const CATALOG_PATH: String = "res://data/catalog/catalog.tres"

var catalog: CatalogDef
var rules: RunRules
var resistance_rules: ResistanceRules
var farm: BuildingDef
var soldiers: TroopDef
var race: IdentityDef
var hero: CharacterDef


func _option(label: String, shift: Array = [0, 0, 0, 0]) -> EventOptionDef:
	var option: EventOptionDef = EventOptionDef.new()
	option.label = label
	option.inclination_shift = PackedInt32Array(shift)
	return option


func _chronicle(id: StringName, options: Array[EventOptionDef], repeatable: bool = false) -> ChronicleDef:
	var def: ChronicleDef = ChronicleDef.new()
	def.id = id
	def.display_name = String(id).capitalize()
	def.description = "Una scena di {nazione}, anno {anno}."
	def.options = options
	def.repeatable = repeatable
	return def


func _custom(id: StringName, axis: int, pole: int) -> IdentityDef:
	var def: IdentityDef = IdentityDef.new()
	def.id = id
	def.display_name = String(id).capitalize()
	def.dimension = IdentityDef.Dimension.USANZA
	def.inclination_axis = axis
	def.inclination_pole = pole
	def.story = "Dall'anno {anno} così."
	return def


func before_each() -> void:
	farm = BuildingDef.new()
	farm.id = &"fattoria"
	farm.display_name = "Fattoria"
	farm.types = [&"Materie prime"]
	farm.mana_interval_ms = 1000
	farm.gold_per_phase = 1
	soldiers = TroopDef.new()
	soldiers.id = &"fanti"
	soldiers.display_name = "Fanti"
	soldiers.types = [&"Fante"]
	soldiers.cooldown_ms = 1000
	soldiers.damage = 1
	soldiers.food_tenths = 0
	race = IdentityDef.new()
	race.id = &"razza"
	race.display_name = "Montanari"
	race.dimension = IdentityDef.Dimension.POPOLO
	race.identity_type = &"Montanaro"
	race.inclinations = PackedInt32Array([1, -1, 0, 0])
	hero = CharacterDef.new()
	hero.id = &"generale"
	hero.role = "Generale"
	hero.names = PackedStringArray(["Varo"])
	catalog = CatalogDef.new()
	catalog.buildings = [farm]
	catalog.troops = [soldiers]
	catalog.eras = [EraDef.new()]
	catalog.identities = [race]
	catalog.advisors = [Aiuti.consigliere(&"generale", [&"Fante"])]
	catalog.chronicles = [_chronicle(&"generica", [_option("Avanti")], true)]
	rules = RunRules.new()
	rules.prototype_years = 0
	rules.starting_buildings = [farm]
	rules.starting_troops = [soldiers]
	rules.starting_perks = 0
	resistance_rules = ResistanceRules.new()
	resistance_rules.per_era = [10]
	resistance_rules.per_year = 0
	resistance_rules.per_building = 0
	resistance_rules.per_troop = 0


func _run(run_seed: int = 3) -> RunState:
	var run: RunState = RunState.new(catalog, rules, BattleRules.new(), resistance_rules, run_seed)
	assert_true(run.found_nation("Prova", [race]), run.last_error)
	return run


## Passa i round finché la run non arriva a una cronaca (o a uno scontro).
func _to_chronicle(run: RunState) -> void:
	var guard: int = 0
	while run.is_shopping_phase() and guard < 50:
		guard += 1
		run.pass_round()
	if run.phase == RunState.Phase.SCONTRO_FANTASMA:
		run.fight_ghost()
		_to_chronicle(run)


func test_le_cronache_arrivano_a_inizio_stagione_ma_non_nel_primo_inverno() -> void:
	var run: RunState = _run()
	assert_eq(run.phase, RunState.Phase.CONSIGLIO, "Il primo inverno parte subito: niente Solstizio nell'anno 1.")
	var gold_before: int = run.gold
	_to_chronicle(run)
	assert_eq(run.phase, RunState.Phase.CRONACA, "Senza incontri nei dati si passa alla primavera: arriva la cronaca.")
	assert_eq(run.season, RunState.Season.PRIMAVERA)
	assert_eq(run.chronicle_moment(), "Equinozio di primavera")
	assert_eq(run.chronicle_text(run.current_chronicle.description), "Una scena di Prova, anno 1.")
	assert_eq(run.gold, gold_before, "La produzione della primavera aspetta la reazione.")
	assert_false(run.pass_round(), "La cronaca non si salta.")
	assert_true(run.choose_chronicle_option(0), run.last_error)
	assert_eq(run.phase, RunState.Phase.CONSIGLIO)
	assert_eq(run.gold, gold_before + 1, "Dopo la reazione la Fattoria produce.")
	assert_eq(run.round_number, 1)


func test_le_inclinazioni_partono_dall_identita_e_si_spostano() -> void:
	catalog.chronicles = [_chronicle(&"generica", [_option("Guerra", [2, 0, 0, -1])], true)]
	var run: RunState = _run()
	assert_eq(run.inclinations, PackedInt32Array([1, -1, 0, 0]), "Montanari: un passo verso Conquistatrice e uno verso Chiusa.")
	_to_chronicle(run)
	assert_true(run.choose_chronicle_option(0), run.last_error)
	assert_eq(run.inclinations, PackedInt32Array([3, -1, 0, -1]))
	assert_eq(run.story.size(), 1, "La reazione resta nella storia della nazione.")
	assert_string_contains(run.story[0], "Guerra")


func test_all_estremo_nasce_un_usanza_una_volta_sola() -> void:
	var trophies: IdentityDef = _custom(&"trofei", Inclination.Axis.SPADA, 1)
	trophies.season_resources = ResourceAmounts.new()
	trophies.season_resources.ferro = 1
	catalog.customs = [trophies, _custom(&"ambasciate", Inclination.Axis.SPADA, -1)]
	catalog.chronicles = [_chronicle(&"generica", [_option("Guerra", [9, 0, 0, 0])], true)]
	var run: RunState = _run()
	_to_chronicle(run)
	var iron: int = run.stock[Res.Type.FERRO]
	assert_true(run.choose_chronicle_option(0))
	assert_eq(run.inclinations[Inclination.Axis.SPADA], rules.inclination_limit, "Non si va oltre il limite.")
	assert_true(run.identity.has(trophies), "All'estremo la nazione prende l'usanza di quel polo.")
	assert_eq(run.customs(), [trophies] as Array[IdentityDef])
	assert_eq(run.stock[Res.Type.FERRO], iron + 1 * Res.scale(Res.Type.FERRO), "L'usanza dà 1 Ferro con la produzione della stagione.")
	assert_eq(run.custom_years[&"trofei"], 1)
	_to_chronicle(run)
	assert_true(run.choose_chronicle_option(0))
	assert_eq(run.customs().size(), 1, "La stessa usanza non si prende due volte.")
	assert_false(run.identity_summary().contains("Trofei"), "Le usanze hanno una riga loro, non stanno nell'identità.")


func test_due_usanze_aprono_una_vocazione_che_si_accetta_o_si_rifiuta() -> void:
	var trophies: IdentityDef = _custom(&"trofei", Inclination.Axis.SPADA, 1)
	var walls: IdentityDef = _custom(&"mura", Inclination.Axis.PORTA, -1)
	catalog.customs = [trophies, walls]
	var assimilators: IdentityDef = IdentityDef.new()
	assimilators.id = &"assimilatori"
	assimilators.display_name = "Assimilatori"
	assimilators.dimension = IdentityDef.Dimension.VOCAZIONE
	assimilators.rule = IdentityDef.Rule.ASSIMILATORI
	assimilators.requires_customs = [trophies, walls]
	catalog.vocations = [assimilators]
	var template: ChronicleDef = _chronicle(&"vocazione", [_option("Rifiuta")])
	template.special = EventDef.Special.VOCAZIONE
	template.description = "Pronti a diventare {vocazione}."
	catalog.chronicles = [template, _chronicle(&"generica", [_option("Estremi", [9, -9, 0, 0])], true)]
	var run: RunState = _run()
	_to_chronicle(run)
	assert_eq(run.current_chronicle.id, &"generica", "La cronaca della vocazione non si pesca da sola.")
	assert_true(run.choose_chronicle_option(0))
	assert_eq(run.customs().size(), 2)
	_to_chronicle(run)
	assert_eq(run.current_chronicle, template, "Con le due usanze arriva la vocazione.")
	assert_eq(run.chronicle_text(template.description), "Pronti a diventare Assimilatori.")
	var options: Array[EventOptionDef] = run.chronicle_options()
	assert_eq(options.size(), 2, "Accetta (costruita dalle regole) o rifiuta.")
	assert_eq(options[0].vocation, assimilators)
	assert_true(run.choose_chronicle_option(0))
	assert_true(run.has_rule(IdentityDef.Rule.ASSIMILATORI))
	assert_eq(run.vocations(), [assimilators] as Array[IdentityDef])
	_to_chronicle(run)
	assert_ne(run.current_chronicle, template, "Una vocazione si offre una volta sola.")


func test_una_vocazione_rifiutata_non_torna() -> void:
	var trophies: IdentityDef = _custom(&"trofei", Inclination.Axis.SPADA, 1)
	var walls: IdentityDef = _custom(&"mura", Inclination.Axis.PORTA, -1)
	catalog.customs = [trophies, walls]
	var vocation: IdentityDef = IdentityDef.new()
	vocation.id = &"assimilatori"
	vocation.dimension = IdentityDef.Dimension.VOCAZIONE
	vocation.requires_customs = [trophies, walls]
	catalog.vocations = [vocation]
	var template: ChronicleDef = _chronicle(&"vocazione", [_option("Rifiuta")])
	template.special = EventDef.Special.VOCAZIONE
	catalog.chronicles = [template, _chronicle(&"generica", [_option("Estremi", [9, -9, 0, 0])], true)]
	var run: RunState = _run()
	_to_chronicle(run)
	run.choose_chronicle_option(0)
	_to_chronicle(run)
	assert_eq(run.current_chronicle, template)
	assert_true(run.choose_chronicle_option(1), "Rifiuta.")
	assert_true(run.vocations().is_empty())
	for i: int in range(3):
		_to_chronicle(run)
		assert_ne(run.current_chronicle, template)
		run.choose_chronicle_option(0)


func test_i_personaggi_arrivano_dopo_il_primo_fantasma_e_ricordano() -> void:
	var meet: EventOptionDef = _option("Promuovilo")
	meet.introduce_character = hero
	meet.character_affinity = 1
	meet.story = "{personaggio} diventa generale."
	var intro: ChronicleDef = _chronicle(&"capitano", [meet, _option("No")])
	var loyal: EventOptionDef = _option("Comandi tu")
	loyal.character_affinity = -3
	var glory: ChronicleDef = _chronicle(&"gloria", [loyal])
	glory.requires_character = hero
	glory.min_affinity = 0
	var plot_leave: EventOptionDef = _option("Arrestalo")
	plot_leave.character_leaves = true
	plot_leave.set_flags = [&"generale_arrestato"]
	var plot: ChronicleDef = _chronicle(&"trama", [plot_leave])
	plot.requires_character = hero
	plot.max_affinity = -1
	var after: ChronicleDef = _chronicle(&"processo", [_option("Giudica")])
	after.requires_flags = [&"generale_arrestato"]
	catalog.chronicles = [intro, glory, plot, after, _chronicle(&"generica", [_option("Avanti")], true)]
	rules.chronicle_specific_weight = 1000
	var run: RunState = _run()
	_to_chronicle(run)
	assert_eq(run.year, 1)
	assert_ne(run.current_chronicle, intro, "Nell'anno 1 nessun personaggio.")
	# Fino al primo fantasma solo la cronaca generica.
	while run.year < 2:
		assert_true(Aiuti.reagisci(run))
		_to_chronicle(run)
	assert_eq(run.current_chronicle, intro, "Dall'anno 2 il capitano può entrare nella storia.")
	assert_true(run.choose_chronicle_option(0))
	var who: NationCharacter = run.character_of(hero)
	assert_not_null(who)
	assert_eq(who.name, "Varo")
	assert_eq(who.affinity, 1)
	assert_string_contains(run.story[-1], "Varo diventa generale.")
	_to_chronicle(run)
	assert_eq(run.current_chronicle, glory, "Con il personaggio arriva la sua cronaca (più personale, più probabile).")
	assert_eq(run.chronicle_text("{personaggio}, il tuo {ruolo}"), "Varo, il tuo generale")
	assert_true(run.choose_chronicle_option(0))
	assert_eq(who.affinity, -2)
	_to_chronicle(run)
	assert_eq(run.current_chronicle, plot, "Con la fiducia bassa il generale trama.")
	assert_true(run.choose_chronicle_option(0))
	assert_null(run.character_of(hero), "Arrestato: esce dalla storia.")
	_to_chronicle(run)
	assert_eq(run.current_chronicle, after, "La catena continua con il ricordo dell'arresto.")


func test_condizioni_personali_vittorie_e_sconfitte() -> void:
	var streak: ChronicleDef = _chronicle(&"tre_vittorie", [_option("Festa")])
	streak.min_win_streak = 1
	var lost: ChronicleDef = _chronicle(&"sconfitta", [_option("Lutto")])
	lost.last_battle = ChronicleDef.LastBattle.PERSO
	catalog.chronicles = [streak, lost, _chronicle(&"generica", [_option("Avanti")], true)]
	var run: RunState = _run()
	_to_chronicle(run)
	assert_eq(run.current_chronicle.id, &"generica", "Prima di ogni scontro valgono solo le generiche.")
	run.win_streak = 1
	run.last_battle_result = 1
	assert_true(run.call("_chronicle_available", streak))
	assert_false(run.call("_chronicle_available", lost))
	run.win_streak = 0
	run.last_battle_result = 0
	assert_false(run.call("_chronicle_available", streak))
	assert_true(run.call("_chronicle_available", lost))


func test_una_reazione_puo_costare_e_dare_risorse() -> void:
	var feast: EventOptionDef = _option("Festa")
	feast.cost = ResourceAmounts.new()
	feast.cost.oro = 100
	feast.malcontent_change = -1
	catalog.chronicles = [_chronicle(&"generica", [feast, _option("Niente")], true)]
	var run: RunState = _run()
	_to_chronicle(run)
	assert_false(run.choose_chronicle_option(0), "Senza Oro la festa non si fa.")
	assert_ne(run.option_block_reason(run.chronicle_options()[0]), "", "Il motivo si vede (P4).")
	run.gold = 100
	run.malcontent = 2
	assert_true(run.choose_chronicle_option(0))
	assert_eq(run.gold, 1, "Pagati 100 Oro, poi la produzione della stagione.")
	assert_eq(run.malcontent, 1)


func test_assimilatori_prendono_una_truppa_nemica() -> void:
	var enemy: TroopDef = TroopDef.new()
	enemy.id = &"predoni"
	enemy.display_name = "Predoni"
	enemy.types = [&"Criminale"]
	enemy.cooldown_ms = 1000
	var reward: RewardDef = RewardDef.new()
	reward.kind = RewardDef.Kind.ORO
	reward.amount = 1
	var encounter: EncounterDef = EncounterDef.new()
	encounter.year = 1
	encounter.resistance = 1
	encounter.troops = [enemy]
	encounter.rewards = [reward]
	catalog.encounters = [encounter, encounter, encounter]
	var vocation: IdentityDef = IdentityDef.new()
	vocation.id = &"assimilatori"
	vocation.dimension = IdentityDef.Dimension.VOCAZIONE
	vocation.rule = IdentityDef.Rule.ASSIMILATORI
	rules.chronicles_enabled = false
	var run: RunState = _run()
	run.call("_adopt_identity", vocation)
	while run.is_shopping_phase():
		run.pass_round()
	assert_true(run.choose_encounter(0), run.last_error)
	assert_eq(run.phase, RunState.Phase.RICOMPENSA_INCONTRO)
	var choices: Array[RewardDef] = run.reward_choices()
	assert_eq(choices.size(), 2, "La ricompensa, oppure una truppa del nemico.")
	assert_true(choices[1].assimilation)
	assert_eq(choices[1].troop.types, [&"Criminale", &"Assimilato", &"Montanaro"] as Array[StringName])
	assert_eq(choices[1].describe(), "Assimila: Predoni assimilati")
	assert_true(run.take_reward(1), run.last_error)
	assert_eq(run.board.troops[-1].troop.display_name, "Predoni assimilati")
	assert_eq(run.malcontent, 1, "Ogni assimilazione porta Malcontento.")
	assert_true(run.flags.has(&"assimilati"), "Apre le cronache sugli assimilati.")
	assert_eq(enemy.types, [&"Criminale"] as Array[StringName], "La truppa del nemico resta com'era.")


func test_stato_di_polizia_ferma_il_malcontento_e_raddoppia_la_stabilita() -> void:
	var police: IdentityDef = IdentityDef.new()
	police.id = &"polizia"
	police.dimension = IdentityDef.Dimension.VOCAZIONE
	police.rule = IdentityDef.Rule.STATO_DI_POLIZIA
	var calm: OpportunityDef = OpportunityDef.new()
	calm.id = &"ordine"
	calm.cost_resources = ResourceAmounts.new()
	calm.cost_resources.stabilita = 2
	calm.cost_resources.oro = 1
	var run: RunState = _run()
	run.call("_adopt_identity", police)
	run.call("_change_malcontent", 50, IdentityDef.Grievance.EVENTI, "Prova")
	assert_eq(run.malcontent, rules.malcontent_warning, "Non oltre la soglia di avviso.")
	var cost: ResourceAmounts = run.call("_discounted_action_cost", catalog.advisors[0], calm)
	assert_eq(cost.whole(Res.Type.STABILITA), 4, "Stabilità ×2.")
	assert_eq(cost.whole(Res.Type.ORO), 1, "L'Oro resta uguale.")


func test_popolo_errante_e_profezia() -> void:
	var visitor: AdvisorDef = Aiuti.consigliere(&"viandante", [&"Materie prime"])
	visitor.special = AdvisorDef.Special.VISITATORE
	catalog.visitors = [visitor]
	rules.special_card_chance_percent = 0
	var wanderers: IdentityDef = IdentityDef.new()
	wanderers.id = &"erranti"
	wanderers.dimension = IdentityDef.Dimension.VOCAZIONE
	wanderers.rule = IdentityDef.Rule.POPOLO_ERRANTE
	var ghost: GhostDef = GhostDef.new()
	ghost.display_name = "Fantasma"
	ghost.year = 1
	ghost.troops = [soldiers]
	catalog.ghosts = [ghost]
	var run: RunState = _run()
	assert_false(run.advisor_choices.has(visitor), "Senza la vocazione nessun Visitatore (probabilità 0).")
	run.call("_adopt_identity", wanderers)
	_to_chronicle(run)
	run.choose_chronicle_option(0)
	assert_eq(run.round_number, 1)
	assert_true(run.advisor_choices.has(visitor), "Nel primo round della stagione c'è sempre un Visitatore.")
	var prophets: IdentityDef = IdentityDef.new()
	prophets.id = &"profeti"
	prophets.dimension = IdentityDef.Dimension.VOCAZIONE
	prophets.rule = IdentityDef.Rule.PROFEZIA
	run.call("_take_vocation", prophets)
	assert_eq(run.prophecy, "Fanti", "La profezia rivela una truppa del fantasma dell'anno.")


func test_stesso_seme_stesse_cronache() -> void:
	catalog.chronicles = []
	for i: int in range(6):
		catalog.chronicles.append(_chronicle(StringName("scena_%d" % i), [_option("Avanti")], true))
	var a: RunState = _run(11)
	var b: RunState = _run(11)
	for i: int in range(4):
		_to_chronicle(a)
		_to_chronicle(b)
		assert_eq(a.current_chronicle.id, b.current_chronicle.id)
		a.choose_chronicle_option(0)
		b.choose_chronicle_option(0)


# --- Dati veri -----------------------------------------------------------------

func test_i_dati_delle_cronache_sono_completi() -> void:
	var real: CatalogDef = load(CATALOG_PATH) as CatalogDef
	assert_gt(real.chronicles.size(), 20)
	var known: PackedStringArray = ["nazione", "anno", "momento", "razza", "governo", "credo", "nemico", "personaggio", "ruolo", "vocazione"]
	var fallback: Dictionary[int, bool] = {}
	var ids: Array[StringName] = []
	var regex: RegEx = RegEx.create_from_string("\\{([a-z_]+)\\}")
	for def: ChronicleDef in real.chronicles:
		assert_false(ids.has(def.id), "Id unico: %s." % def.id)
		ids.append(def.id)
		var free: bool = def.special == EventDef.Special.VOCAZIONE
		var texts: PackedStringArray = [def.display_name, def.description]
		for option: EventOptionDef in def.options:
			texts.append_array([option.label, option.description, option.story])
			if option.cost == null and option.requires_identity.is_empty() and option.requires_types.is_empty() \
					and not option.upgrade and option.spy == null:
				free = true
			assert_true(option.inclination_shift.is_empty() or option.inclination_shift.size() == 4, "%s: quattro assi." % def.id)
		assert_true(free, "%s: c'è sempre una reazione gratuita e senza requisiti." % def.id)
		for text: String in texts:
			for found: RegExMatch in regex.search_all(text):
				assert_true(known.has(found.get_string(1)), "%s: segnaposto sconosciuto {%s}." % [def.id, found.get_string(1)])
		var generic: bool = def.repeatable and def.special == EventDef.Special.NESSUNO and def.min_year <= 2 \
				and def.requires_flags.is_empty() and def.requires_character == null and def.inclination_axis < 0 \
				and def.min_malcontent == 0 and def.requires_types.is_empty() and def.last_battle == ChronicleDef.LastBattle.QUALSIASI
		if generic:
			for season: int in (def.seasons if not def.seasons.is_empty() else PackedInt32Array([0, 1, 2, 3])):
				fallback[season] = true
	for season: int in range(4):
		assert_true(fallback.has(season), "Stagione %d: c'è sempre una cronaca generica." % season)
	var templates: int = 0
	for def: ChronicleDef in real.chronicles:
		if def.special == EventDef.Special.VOCAZIONE:
			templates += 1
	assert_eq(templates, 1, "Una cronaca per offrire le vocazioni.")
	# Un'usanza per ogni polo di ogni asse.
	assert_eq(real.customs.size(), 8)
	var poles: Dictionary[String, bool] = {}
	for custom: IdentityDef in real.customs:
		assert_eq(custom.dimension, IdentityDef.Dimension.USANZA)
		poles["%d|%d" % [custom.inclination_axis, custom.inclination_pole]] = true
	assert_eq(poles.size(), 8, "Otto poli, otto usanze diverse.")
	for vocation: IdentityDef in real.vocations:
		assert_eq(vocation.dimension, IdentityDef.Dimension.VOCAZIONE)
		assert_eq(vocation.requires_customs.size(), 2, "%s nasce da due usanze." % vocation.id)
		for needed: Resource in vocation.requires_customs:
			assert_true(real.customs.has(needed), "%s: usanza del catalogo." % vocation.id)
	for who: CharacterDef in real.characters:
		assert_false(who.names.is_empty(), "%s ha dei nomi." % who.id)
	for def: IdentityDef in real.identities:
		if def.dimension in [IdentityDef.Dimension.POPOLO, IdentityDef.Dimension.GOVERNO, IdentityDef.Dimension.CREDO, IdentityDef.Dimension.CULTURA]:
			assert_eq(def.inclinations.size(), 4, "%s: spinta iniziale sulle quattro inclinazioni." % def.id)
