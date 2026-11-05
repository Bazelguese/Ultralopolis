class_name OpponentGenerator
extends RefCounted
## Genera fantasmi e incontri del mondo dal catalogo, sempre più forti con gli anni
## (GDD §11.3, §3.3). Logica pura e riproducibile: lo stesso seme dà gli stessi avversari.

const SALT_GHOST: int = 17
const SALT_ENCOUNTERS: int = 31


## Generatore casuale dedicato, così la generazione non cambia le offerte pescate nella run.
static func _rng(run_seed: int, year: int, salt: int) -> RandomNumberGenerator:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = run_seed * 1000003 + year * 9176 + salt
	return rng


@warning_ignore("integer_division")
static func era_for_year(catalog: CatalogDef, rules: GeneratorRules, year: int) -> int:
	var era: int = 1 + (year - 1) / maxi(1, rules.years_per_era)
	return clampi(era, 1, maxi(1, catalog.eras.size()))


@warning_ignore("integer_division")
static func _scaled(base: int, per_year_tenths: int, year: int) -> int:
	return base + year * per_year_tenths / 10


# --- Fantasmi -----------------------------------------------------------------

static func generate_ghost(catalog: CatalogDef, rules: GeneratorRules, run_rules: RunRules, year: int, run_seed: int) -> GhostDef:
	var rng: RandomNumberGenerator = _rng(run_seed, year, SALT_GHOST)
	var ghost: GhostDef = GhostDef.new()
	ghost.year = year
	ghost.era = era_for_year(catalog, rules, year)
	ghost.display_name = "Fantasma: %s" % _nation_name(rules, rng)

	var troop_count: int = mini(run_rules.max_troop_slots, _scaled(rules.ghost_troops_base, rules.ghost_troops_per_year_tenths, year))
	var level: int = clampi(1 + (year - 1) / maxi(1, rules.ghost_level_every_years), 1, run_rules.max_level)
	var troops: Array[TroopDef] = _pick_troops(catalog, ghost.era, troop_count, rng)
	for i: int in range(troops.size()):
		troops[i] = _leveled(troops[i], level, run_rules)
	ghost.troops = troops

	var building_count: int = mini(run_rules.max_building_slots - 1, _scaled(rules.ghost_buildings_base, rules.ghost_buildings_per_year_tenths, year))
	var buildings: Array[BuildingDef] = []
	if not run_rules.starting_buildings.is_empty():
		buildings.append(run_rules.starting_buildings[0])
	buildings.append_array(_pick_buildings_for(catalog, ghost.era, building_count, troops, rng))
	ghost.buildings = buildings

	var identity: Array[IdentityDef] = []
	for dimension: IdentityDef.Dimension in IdentityDef.CREATION_DIMENSIONS:
		var options: Array[IdentityDef] = IdentityRules.options(catalog, dimension)
		var wanted: int = rules.ghost_perks if dimension == IdentityDef.Dimension.PERK else 1
		for i: int in range(mini(wanted, options.size())):
			var pick: int = rng.randi_range(0, options.size() - 1)
			identity.append(options[pick])
			options.remove_at(pick)
	# Una via per ogni era raggiunta dalla seconda in poi (GDD §10.4).
	for era_index: int in range(1, mini(ghost.era, catalog.eras.size())):
		var ways: Array[IdentityDef] = []
		for way: IdentityDef in catalog.eras[era_index].ways:
			if way.requires_any.is_empty():
				ways.append(way)
			else:
				for needed: Resource in way.requires_any:
					if identity.has(needed) and not ways.has(way):
						ways.append(way)
		if not ways.is_empty():
			identity.append(ways[rng.randi_range(0, ways.size() - 1)])
	ghost.identity = identity

	if not rules.ghost_malus_pool.is_empty():
		ghost.malus = [rules.ghost_malus_pool[rng.randi_range(0, rules.ghost_malus_pool.size() - 1)]]
	return ghost


static func _nation_name(rules: GeneratorRules, rng: RandomNumberGenerator) -> String:
	if rules.nation_name_prefixes.is_empty() or rules.nation_name_places.is_empty():
		return "Nazione straniera"
	var prefix: String = rules.nation_name_prefixes[rng.randi_range(0, rules.nation_name_prefixes.size() - 1)]
	var place: String = rules.nation_name_places[rng.randi_range(0, rules.nation_name_places.size() - 1)]
	return "%s %s" % [prefix, place]


## Copia della truppa al livello indicato (stessa regola dei potenziamenti del giocatore, GDD §6.5).
static func _leveled(def: TroopDef, level: int, run_rules: RunRules) -> TroopDef:
	if level <= 1:
		return def
	var copy: TroopDef = ElementStats.troop(def, null, null, level, run_rules)
	copy.display_name = "%s (liv. %d)" % [def.display_name, level]
	return copy


static func _pick_troops(catalog: CatalogDef, era: int, count: int, rng: RandomNumberGenerator) -> Array[TroopDef]:
	var pool: Array[TroopDef] = []
	for def: TroopDef in catalog.troops:
		if def.era <= era:
			pool.append(def)
	var picked: Array[TroopDef] = []
	if pool.is_empty():
		return picked
	for i: int in range(count):
		picked.append(pool[rng.randi_range(0, pool.size() - 1)])
	return picked


## Edifici: prima uno per ogni colore di mana chiesto dalle truppe, poi a caso.
static func _pick_buildings_for(catalog: CatalogDef, era: int, count: int, troops: Array[TroopDef], rng: RandomNumberGenerator) -> Array[BuildingDef]:
	var pool: Array[BuildingDef] = []
	for def: BuildingDef in catalog.buildings:
		if def.era <= era:
			pool.append(def)
	var picked: Array[BuildingDef] = []
	if pool.is_empty() or count <= 0:
		return picked
	var needed_colors: Array[StringName] = []
	for troop: TroopDef in troops:
		if troop.mana_cost > 0 and not needed_colors.has(troop.mana_type):
			needed_colors.append(troop.mana_type)
	for color: StringName in needed_colors:
		if picked.size() >= count:
			break
		var matching: Array[BuildingDef] = []
		for def: BuildingDef in pool:
			if def.mana_type == color:
				matching.append(def)
		if not matching.is_empty():
			picked.append(matching[rng.randi_range(0, matching.size() - 1)])
	while picked.size() < count:
		picked.append(pool[rng.randi_range(0, pool.size() - 1)])
	return picked


# --- Incontri del mondo -------------------------------------------------------

## Genera "count" incontri per l'anno, partendo dalla difficoltà "first_difficulty"
## (0 facile, 1 media, 2 difficile).
static func generate_encounters(catalog: CatalogDef, rules: GeneratorRules, run_rules: RunRules,
		year: int, run_seed: int, count: int, first_difficulty: int = 0) -> Array[EncounterDef]:
	var rng: RandomNumberGenerator = _rng(run_seed, year, SALT_ENCOUNTERS)
	var era: int = era_for_year(catalog, rules, year)
	var names: Array[int] = []
	for i: int in range(rules.encounter_names.size()):
		names.append(i)
	var result: Array[EncounterDef] = []
	for i: int in range(count):
		var difficulty: int = clampi(first_difficulty + i, 0, rules.difficulty_percents.size() - 1)
		var strength: int = rules.difficulty_percents[difficulty]
		var encounter: EncounterDef = EncounterDef.new()
		encounter.year = year
		encounter.difficulty_label = rules.difficulty_labels[difficulty] if difficulty < rules.difficulty_labels.size() else ""
		if not names.is_empty():
			var pick: int = rng.randi_range(0, names.size() - 1)
			var name_index: int = names[pick]
			names.remove_at(pick)
			encounter.display_name = rules.encounter_names[name_index]
			if name_index < rules.encounter_descriptions.size():
				encounter.description = rules.encounter_descriptions[name_index]
		else:
			encounter.display_name = "Minaccia"
		var base_resistance: int = rules.encounter_resistance_base + rules.encounter_resistance_per_year * year
		encounter.resistance = maxi(1, Modifiers.apply_percent(base_resistance, strength - 100))
		var troop_count: int = _scaled(rules.encounter_troops_base, rules.encounter_troops_per_year_tenths, year) + difficulty
		encounter.troops = _pick_troops(catalog, era, mini(troop_count, run_rules.max_troop_slots), rng)
		encounter.buildings = _pick_buildings_for(catalog, era, mini(1 + difficulty + _scaled(0, 2, year), run_rules.max_building_slots), encounter.troops, rng)
		encounter.rewards = _rewards(catalog, rules, era, year, difficulty, strength, rng)
		encounter.loot_gold = rules.encounter_loot_gold[mini(difficulty, rules.encounter_loot_gold.size() - 1)] if not rules.encounter_loot_gold.is_empty() else 0
		encounter.loot_research = rules.encounter_loot_research[mini(difficulty, rules.encounter_loot_research.size() - 1)] if not rules.encounter_loot_research.is_empty() else 0
		result.append(encounter)
	return result


static func _rewards(catalog: CatalogDef, rules: GeneratorRules, era: int, year: int, difficulty: int,
		strength: int, rng: RandomNumberGenerator) -> Array[RewardDef]:
	var rewards: Array[RewardDef] = []
	var gold: RewardDef = RewardDef.new()
	gold.kind = RewardDef.Kind.ORO
	gold.amount = maxi(1, Modifiers.apply_percent(rules.reward_gold_base + rules.reward_gold_per_year * year, strength - 100))
	rewards.append(gold)

	var resource: RewardDef = RewardDef.new()
	resource.kind = RewardDef.Kind.RISORSA
	var types: Array[Res.Type] = [Res.Type.RICERCA, Res.Type.CIBO, Res.Type.LEGNO, Res.Type.PIETRA, Res.Type.FERRO, Res.Type.FEDE, Res.Type.INFLUENZA, Res.Type.STABILITA, Res.Type.DOCUMENTI]
	resource.resource = types[rng.randi_range(0, types.size() - 1)]
	resource.amount = maxi(1, Modifiers.apply_percent(_scaled(rules.reward_resource_base, rules.reward_resource_per_year_tenths, year), strength - 100))
	rewards.append(resource)

	if difficulty >= 1:
		var troops: Array[TroopDef] = []
		for def: TroopDef in catalog.troops:
			if def.era == era:
				troops.append(def)
		if not troops.is_empty():
			var troop: RewardDef = RewardDef.new()
			troop.kind = RewardDef.Kind.TRUPPA
			troop.troop = troops[rng.randi_range(0, troops.size() - 1)]
			rewards.append(troop)
	if difficulty >= 2:
		var buildings: Array[BuildingDef] = []
		for def: BuildingDef in catalog.buildings:
			if def.era == era:
				buildings.append(def)
		if not buildings.is_empty():
			var building: RewardDef = RewardDef.new()
			building.kind = RewardDef.Kind.EDIFICIO
			building.building = buildings[rng.randi_range(0, buildings.size() - 1)]
			rewards.append(building)
		var perks: Array[IdentityDef] = IdentityRules.options(catalog, IdentityDef.Dimension.PERK)
		if not perks.is_empty():
			var perk: RewardDef = RewardDef.new()
			perk.kind = RewardDef.Kind.PERK
			perk.perk = perks[rng.randi_range(0, perks.size() - 1)]
			rewards.append(perk)
	return rewards
