extends GutTest
## Malcontento e Rivoluzione (GDD §5.5, §9.4.2; v0.24). Numeri solo di prova.

const Aiuti = preload("res://tests/sim/aiuti_consiglio.gd")

var catalog: CatalogDef
var rules: RunRules
var resistance_rules: ResistanceRules
var monarchy: IdentityDef
var dictatorship: IdentityDef
var republic: IdentityDef
var revolution: EventDef
var walls: BuildingDef
var calm: OpportunityDef


func _government(id: StringName, causes: Array[IdentityDef.Grievance]) -> IdentityDef:
	var def: IdentityDef = IdentityDef.new()
	def.id = id
	def.display_name = String(id).capitalize()
	def.dimension = IdentityDef.Dimension.GOVERNO
	def.revolution_causes = causes
	return def


func _option(label: String, change: int) -> EventOptionDef:
	var option: EventOptionDef = EventOptionDef.new()
	option.label = label
	option.malcontent_change = change
	return option


func _event(id: StringName, options: Array[EventOptionDef]) -> EventDef:
	var event: EventDef = EventDef.new()
	event.id = id
	event.display_name = String(id)
	event.repeatable = true
	event.options = options
	return event


func before_each() -> void:
	walls = BuildingDef.new()
	walls.id = &"mura"
	walls.display_name = "Mura"
	walls.types = [&"Guardiano"]
	walls.cost_gold = 2
	walls.mana_interval_ms = 1000
	monarchy = _government(&"monarchia", [IdentityDef.Grievance.MALUS])
	dictatorship = _government(&"dittatura", [IdentityDef.Grievance.SCONFITTE])
	republic = _government(&"repubblica", [IdentityDef.Grievance.CARESTIE, IdentityDef.Grievance.EVENTI])
	revolution = EventDef.new()
	revolution.id = &"rivoluzione"
	revolution.display_name = "La Rivoluzione"
	revolution.special = EventDef.Special.RIVOLUZIONE
	revolution.repeatable = true
	calm = OpportunityDef.new()
	calm.id = &"ordine_pubblico"
	calm.display_name = "Ordine pubblico"
	calm.kind = OpportunityDef.Kind.SCAMBIO_RISORSE
	calm.cost_resources = ResourceAmounts.new()
	calm.cost_resources.stabilita = 2
	calm.malcontent_change = -3
	catalog = CatalogDef.new()
	catalog.buildings = [walls]
	catalog.eras = [EraDef.new()]
	catalog.identities = [monarchy, dictatorship, republic]
	rules = RunRules.new()
	rules.starting_gold = 20
	rules.prototype_years = 0
	rules.starting_buildings = [walls]
	rules.starting_troops = []
	rules.starting_perks = 0
	rules.special_card_chance_percent = 0
	rules.malcontent_threshold = 5
	rules.malcontent_warning = 3
	Aiuti.consiglio_semplice(catalog, rules, [calm], 5)
	resistance_rules = ResistanceRules.new()
	resistance_rules.per_era = [10]
	resistance_rules.per_year = 0
	resistance_rules.per_building = 0
	resistance_rules.per_troop = 0


func _run(run_seed: int = 3) -> RunState:
	var run: RunState = RunState.new(catalog, rules, BattleRules.new(), resistance_rules, run_seed)
	assert_true(run.found_nation("Regno", [monarchy]), run.last_error)
	return run


## Prende l'evento del round e la sua opzione indicata.
func _take(run: RunState, index: int) -> void:
	assert_not_null(run.event_choice, "C'è un evento nel round.")
	assert_true(run.choose_event(), run.last_error)
	assert_true(run.take_event_option(index), run.last_error)


func test_le_opzioni_degli_eventi_fanno_salire_e_scendere_il_malcontento() -> void:
	# Un evento non torna nello stesso anno: quattro eventi uguali, con id diversi.
	catalog.events = []
	for i: int in range(4):
		catalog.events.append(_event(StringName("protesta_%d" % i), [_option("Ignora", 2), _option("Ascolta", -1)]))
	rules.special_card_chance_percent = 100
	var run: RunState = _run()
	assert_eq(run.malcontent, 0, "Si parte senza Malcontento.")
	_take(run, 0)
	assert_eq(run.malcontent, 2)
	assert_eq(run.malcontent_sources.get(IdentityDef.Grievance.EVENTI, 0), 2, "La causa resta scritta.")
	_take(run, 1)
	assert_eq(run.malcontent, 1)
	_take(run, 1)
	_take(run, 1)
	assert_eq(run.malcontent, 0, "Mai sotto zero.")


func test_le_truppe_senza_cibo_fanno_salire_il_malcontento() -> void:
	var soldiers: TroopDef = TroopDef.new()
	soldiers.id = &"fanti"
	soldiers.display_name = "Fanti"
	soldiers.types = [Aiuti.TIPO_PROVA]
	soldiers.cooldown_ms = 1000
	soldiers.food_tenths = 50
	rules.starting_troops = [soldiers, soldiers]
	rules.malcontent_per_hungry_troop = 1
	var run: RunState = _run()
	run.stock[Res.Type.CIBO] = 0
	run.call("_feed_troops")
	assert_eq(run.malcontent, 2, "Due truppe affamate: carestia.")
	assert_eq(run.main_grievance(), IdentityDef.Grievance.CARESTIE)


func test_l_azione_che_calma_compare_solo_se_c_e_malcontento() -> void:
	rules.half_themes = PackedInt32Array([0, 0, 0, 0, 0])
	var run: RunState = _run()
	Aiuti.ascolta(run)
	for offer: Offer in run.offers:
		assert_ne(offer.opportunity, calm, "Senza Malcontento non serve.")
	run.malcontent = 4
	run.pass_round()
	Aiuti.ascolta(run)
	var index: int = -1
	for i: int in range(run.offers.size()):
		if run.offers[i].opportunity == calm:
			index = i
	assert_ne(index, -1, "Con il Malcontento l'azione compare.")
	run.stock[Res.Type.STABILITA] = 2
	assert_true(run.buy_offer(index), run.last_error)
	assert_eq(run.malcontent, 1, "2 Stabilità: −3 Malcontento.")
	assert_eq(run.stock[Res.Type.STABILITA], 0)


func test_alla_soglia_il_round_mostra_solo_la_rivoluzione() -> void:
	catalog.events = [revolution, _event(&"protesta", [_option("Ignora", 5)])]
	rules.special_card_chance_percent = 100
	var run: RunState = _run()
	_take(run, 0)
	assert_eq(run.malcontent, 5)
	assert_true(run.is_revolution_round(), "Raggiunta la soglia arriva la Rivoluzione.")
	assert_eq(run.event_choice, revolution)
	assert_true(run.advisor_choices.is_empty(), "Solo la Rivoluzione, nessun consigliere.")
	assert_false(run.pass_round(), "Non si può evitare.")
	assert_true(run.choose_event())
	var options: Array[EventOptionDef] = run.event_options()
	assert_eq(options.size(), 1, "Causa: le scelte degli eventi → solo la Repubblica (il governo attuale è escluso).")
	assert_eq(options[0].change_government, republic)
	assert_eq(run.option_block_reason(options[0]), "", "Le opzioni della Rivoluzione sono gratuite.")
	assert_true(run.take_event_option(0))
	assert_eq(run.government(), republic)
	assert_eq(run.malcontent, 0, "Dopo la Rivoluzione si azzera.")
	assert_true(run.malcontent_sources.is_empty())
	assert_false(run.is_revolution_round())


func test_la_rivoluzione_puo_portare_a_un_tier_piu_basso() -> void:
	var absolute: IdentityDef = _government(&"monarchia_assoluta", [])
	absolute.tier = 2
	catalog.identities.append(absolute)
	catalog.events = [revolution]
	var run: RunState = RunState.new(catalog, rules, BattleRules.new(), resistance_rules, 3)
	assert_true(run.found_nation("Regno", [monarchy]))
	run.call("_change_government", absolute, "Prova")
	run.malcontent_sources = {IdentityDef.Grievance.MALUS: 5}
	assert_eq(run.revolution_targets(), [monarchy] as Array[IdentityDef], "Dal tier 2 si torna alla Monarchia.")


func test_i_tumulti_compaiono_solo_sopra_una_soglia() -> void:
	var riots: EventDef = _event(&"tumulti", [_option("Lascia correre", 1)])
	riots.min_malcontent = 3
	catalog.events = [riots]
	rules.special_card_chance_percent = 100
	var run: RunState = _run()
	assert_null(run.event_choice, "Sotto la soglia i tumulti non compaiono.")
	run.malcontent = 3
	run.pass_round()
	assert_eq(run.event_choice, riots)
