extends GutTest
## La forma della plancia (solo aspetto) la indica il popolo (Davide, 9 novembre 2026):
## Pietrosangue = mura, Maremani = arco, Cinerali = ali. Il fantasma mostra quella del suo popolo.

const CATALOG_PATH: String = "res://data/catalog/catalog.tres"
const FORME: Array[StringName] = [&"ali", &"mura", &"arco"]


func _popoli() -> Array[IdentityDef]:
	var catalogo: CatalogDef = load(CATALOG_PATH) as CatalogDef
	var popoli: Array[IdentityDef] = []
	for def: IdentityDef in catalogo.identities:
		if def.dimension == IdentityDef.Dimension.POPOLO:
			popoli.append(def)
	return popoli


func test_ogni_popolo_ha_una_forma_diversa() -> void:
	var viste: Array[StringName] = []
	for popolo: IdentityDef in _popoli():
		assert_true(FORME.has(popolo.board_shape), "%s ha una forma della plancia valida." % popolo.display_name)
		assert_false(viste.has(popolo.board_shape), "%s ha una forma tutta sua." % popolo.display_name)
		viste.append(popolo.board_shape)
	assert_gt(viste.size(), 0, "Il catalogo ha dei popoli.")


func test_la_forma_viene_dal_popolo_e_non_dagli_altri_elementi() -> void:
	var popolo: IdentityDef = IdentityDef.new()
	popolo.dimension = IdentityDef.Dimension.POPOLO
	popolo.board_shape = &"mura"
	var governo: IdentityDef = IdentityDef.new()
	governo.dimension = IdentityDef.Dimension.GOVERNO
	governo.board_shape = &"arco"
	var identita: Array[IdentityDef] = [governo, popolo]
	assert_eq(RunState.board_shape_of(identita), &"mura")
	assert_eq(RunState.board_shape_of([governo] as Array[IdentityDef]), &"", "Senza popolo nessuna forma.")


func test_ogni_incontro_ha_la_plancia_della_sua_famiglia() -> void:
	# Mare = nave, terra selvaggia = pelli, fuorilegge = barricata (Davide, 9 novembre 2026).
	var catalogo: CatalogDef = load(CATALOG_PATH) as CatalogDef
	assert_gt(catalogo.encounters.size(), 0, "Il catalogo ha degli incontri.")
	for incontro: EncounterDef in catalogo.encounters:
		assert_true([&"nave", &"pelli", &"barricata"].has(incontro.board_shape), "%s ha la plancia della sua famiglia." % incontro.display_name)
