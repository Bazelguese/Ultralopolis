extends RefCounted
## Aiuti per i test: un Consiglio semplice con un solo consigliere che propone tutto.
## Serve ai test che non verificano il Consiglio in sé (GDD §4.2), ma devono comprare edifici,
## truppe e azioni.

const TIPO_PROVA: StringName = &"Prova"


## Un consigliere ordinario con questi tipi, queste azioni e questa risorsa di Potenzia.
static func consigliere(id: StringName, tipi: Array[StringName], azioni: Array[OpportunityDef] = [],
		risorsa: Res.Type = Res.Type.FERRO) -> AdvisorDef:
	var def: AdvisorDef = AdvisorDef.new()
	def.id = id
	def.display_name = String(id).capitalize()
	def.category_name = String(id).capitalize()
	def.types = tipi
	def.actions = azioni
	def.upgrade_resource = risorsa
	return def


## Dà il tipo di prova alle carte che non hanno tipi e mette nel catalogo un solo consigliere,
## sempre presente, che propone tutte le carte e queste azioni. I round sono tutti Misti.
static func consiglio_semplice(catalogo: CatalogDef, regole: RunRules, azioni: Array[OpportunityDef] = [],
		round_per_meta: int = 2) -> AdvisorDef:
	var tipi: Array[StringName] = [TIPO_PROVA]
	var edifici: Array[BuildingDef] = catalogo.buildings.duplicate()
	var truppe: Array[TroopDef] = catalogo.troops.duplicate()
	for elemento: IdentityDef in catalogo.identities:
		edifici.append_array(elemento.exclusive_buildings)
		truppe.append_array(elemento.exclusive_troops)
	for def: BuildingDef in edifici:
		if def.types.is_empty():
			def.types = [TIPO_PROVA]
		for tipo: StringName in def.types:
			if not tipi.has(tipo):
				tipi.append(tipo)
	for def: TroopDef in truppe:
		if def.types.is_empty():
			def.types = [TIPO_PROVA]
		for tipo: StringName in def.types:
			if not tipi.has(tipo):
				tipi.append(tipo)
	var tutto: AdvisorDef = consigliere(&"tutto", tipi, azioni)
	catalogo.advisors = [tutto]
	regole.advisors_per_round = 1
	regole.rounds_per_season = round_per_meta
	var temi: PackedInt32Array = PackedInt32Array()
	for i: int in range(round_per_meta):
		temi.append(RunState.RoundTheme.MISTO)
	regole.set_all_season_themes(temi)
	return tutto


## Sceglie il primo consigliere del round, se non è già stato scelto.
static func ascolta(run: RunState) -> void:
	if run.is_shopping_phase() and run.chosen_advisor == null and not run.advisor_choices.is_empty():
		run.choose_advisor(0)
