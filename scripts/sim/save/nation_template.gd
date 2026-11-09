class_name NationTemplate
extends RefCounted
## Una nazione creata dal giocatore e salvata: nome e identità scelta (GDD §9.1).
## Da una nazione salvata si possono iniziare tante run.

## Identificativo unico, non mostrato al giocatore.
var id: String = ""
var nation_name: String = ""
## Identificativi degli elementi dell'identità (popolo, governo, credo, cultura, perk).
var identity_ids: Array[StringName] = []
## Nazione di test (TestNationDef): sempre nella lista, non si salva nel file delle nazioni.
var is_test: bool = false


## Un'identità completa senza scegliere: il primo elemento di ogni colonna della creazione
## e le prime peculiarità.
static func first_choices(catalog: CatalogDef, rules: RunRules) -> Array[IdentityDef]:
	var choices: Array[IdentityDef] = []
	for dimension: IdentityDef.Dimension in IdentityDef.CREATION_DIMENSIONS:
		var options: Array[IdentityDef] = IdentityRules.options(catalog, dimension)
		var count: int = IdentityRules.starting_perk_count(catalog, rules) if dimension == IdentityDef.Dimension.PERK else 1
		for i: int in range(mini(count, options.size())):
			choices.append(options[i])
	return choices


static func from_choices(p_id: String, p_name: String, choices: Array[IdentityDef]) -> NationTemplate:
	var template: NationTemplate = NationTemplate.new()
	template.id = p_id
	template.nation_name = p_name.strip_edges() if not p_name.strip_edges().is_empty() else "Nazione senza nome"
	for def: IdentityDef in choices:
		template.identity_ids.append(def.id)
	return template


## Trova nel catalogo gli elementi dell'identità. Quelli che non esistono più restano fuori:
## in quel caso is_valid() segnala che la nazione va modificata.
func resolve(catalog: CatalogDef) -> Array[IdentityDef]:
	var found: Array[IdentityDef] = []
	for identity_id: StringName in identity_ids:
		for def: IdentityDef in catalog.identities:
			if def.id == identity_id:
				found.append(def)
				break
	return found


## Restituisce "" se la nazione si può giocare con il catalogo attuale, altrimenti il motivo.
func problem(catalog: CatalogDef, rules: RunRules) -> String:
	var resolved: Array[IdentityDef] = resolve(catalog)
	if resolved.size() != identity_ids.size():
		return "Alcuni elementi dell'identità non esistono più: modifica la nazione."
	return IdentityRules.validate(catalog, rules, resolved)


func to_dict() -> Dictionary:
	var ids: Array[String] = []
	for identity_id: StringName in identity_ids:
		ids.append(String(identity_id))
	return {"id": id, "nome": nation_name, "identita": ids}


static func from_dict(data: Dictionary) -> NationTemplate:
	var template: NationTemplate = NationTemplate.new()
	template.id = str(data.get("id", ""))
	template.nation_name = str(data.get("nome", ""))
	var ids: Variant = data.get("identita", [])
	if ids is Array:
		for value: Variant in ids:
			template.identity_ids.append(StringName(str(value)))
	return template
