class_name IdentityRules
extends RefCounted
## Regole di composizione dell'identità (GDD §9.1): un elemento per ogni dimensione
## che ha opzioni nel catalogo, più il numero previsto di perk iniziali.


## Elementi del catalogo per una dimensione.
static func options(catalog: CatalogDef, dimension: IdentityDef.Dimension) -> Array[IdentityDef]:
	var found: Array[IdentityDef] = []
	for def: IdentityDef in catalog.identities:
		if def.dimension == dimension:
			found.append(def)
	return found


## Quanti perk si scelgono alla creazione (non più di quelli disponibili).
static func starting_perk_count(catalog: CatalogDef, rules: RunRules) -> int:
	return mini(rules.starting_perks, options(catalog, IdentityDef.Dimension.PERK).size())


## Restituisce "" se la scelta è valida, altrimenti il motivo per il giocatore.
static func validate(catalog: CatalogDef, rules: RunRules, choices: Array[IdentityDef]) -> String:
	for def: IdentityDef in choices:
		if def == null or not catalog.identities.has(def):
			return "Un elemento dell'identità non esiste più nel catalogo."
		if choices.count(def) > 1:
			return "Ogni elemento si sceglie una volta sola."
	for dimension: IdentityDef.Dimension in IdentityDef.CREATION_DIMENSIONS:
		var wanted: int = 1
		if dimension == IdentityDef.Dimension.PERK:
			wanted = starting_perk_count(catalog, rules)
		elif options(catalog, dimension).is_empty():
			wanted = 0
		var chosen: int = 0
		for def: IdentityDef in choices:
			if def.dimension == dimension:
				chosen += 1
		if chosen != wanted:
			if dimension == IdentityDef.Dimension.PERK:
				return "Scegli %d perk." % wanted
			return "Scegli un elemento per: %s." % IdentityDef.DIMENSION_NAMES[dimension]
	return ""
