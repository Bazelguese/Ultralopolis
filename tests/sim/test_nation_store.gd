extends GutTest
## Salvataggio delle nazioni create e loro validità rispetto al catalogo.

const TEST_STORE: String = "user://test_nazioni_store.json"


func after_each() -> void:
	if FileAccess.file_exists(TEST_STORE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_STORE))


func _catalog() -> CatalogDef:
	var catalog: CatalogDef = CatalogDef.new()
	for entry: Array in [[&"popolo", IdentityDef.Dimension.POPOLO], [&"perk_a", IdentityDef.Dimension.PERK], [&"perk_b", IdentityDef.Dimension.PERK]]:
		var def: IdentityDef = IdentityDef.new()
		def.id = entry[0]
		def.dimension = entry[1]
		catalog.identities.append(def)
	return catalog


func test_salva_e_ricarica() -> void:
	var catalog: CatalogDef = _catalog()
	var nation: NationTemplate = NationTemplate.from_choices("n1", "Regno", catalog.identities)
	assert_true(NationStore.upsert(nation, TEST_STORE))
	var loaded: Array[NationTemplate] = NationStore.load_all(TEST_STORE)
	assert_eq(loaded.size(), 1)
	assert_eq(loaded[0].nation_name, "Regno")
	assert_eq(loaded[0].identity_ids, [&"popolo", &"perk_a", &"perk_b"] as Array[StringName])
	assert_eq(loaded[0].resolve(catalog), catalog.identities)


func test_upsert_sostituisce_e_remove_elimina() -> void:
	var catalog: CatalogDef = _catalog()
	NationStore.upsert(NationTemplate.from_choices("n1", "Primo", catalog.identities), TEST_STORE)
	NationStore.upsert(NationTemplate.from_choices("n2", "Secondo", catalog.identities), TEST_STORE)
	NationStore.upsert(NationTemplate.from_choices("n1", "Primo bis", catalog.identities), TEST_STORE)
	var loaded: Array[NationTemplate] = NationStore.load_all(TEST_STORE)
	assert_eq(loaded.size(), 2)
	assert_eq(loaded[0].nation_name, "Primo bis")
	NationStore.remove("n1", TEST_STORE)
	loaded = NationStore.load_all(TEST_STORE)
	assert_eq(loaded.size(), 1)
	assert_eq(loaded[0].id, "n2")


func test_file_assente_o_rovinato() -> void:
	assert_eq(NationStore.load_all(TEST_STORE).size(), 0, "Nessun file: nessuna nazione.")
	var file: FileAccess = FileAccess.open(TEST_STORE, FileAccess.WRITE)
	file.store_string("non è JSON")
	file.close()
	assert_eq(NationStore.load_all(TEST_STORE).size(), 0, "File rovinato: nessuna nazione, nessun blocco.")


func test_nazione_con_elementi_spariti_dal_catalogo() -> void:
	var catalog: CatalogDef = _catalog()
	var rules: RunRules = RunRules.new()
	var nation: NationTemplate = NationTemplate.from_choices("n1", "Regno", catalog.identities)
	assert_eq(nation.problem(catalog, rules), "")
	nation.identity_ids.append(&"sparito")
	assert_ne(nation.problem(catalog, rules), "", "Va modificata prima di giocarla.")


func test_nome_vuoto() -> void:
	var nation: NationTemplate = NationTemplate.from_choices("n1", "   ", [])
	assert_eq(nation.nation_name, "Nazione senza nome")
