class_name Modifiers
extends RefCounted
## Componente Modificatori (GDD §8, §16.2): il punto in cui si innestano malus,
## perk ed effetti nel tempo. Logica pura: tiene i modificatori attivi e risponde
## a domande del tipo "di quanto cambia la Ricerca prodotta?".

var active: Array[ActiveModifier] = []


## Applica un modificatore. Restituisce una frase per la cronaca della run.
## current_year: anno in cui arriva; resta attivo per duration_years anni interi successivi.
## chosen_piece: l'elemento scelto dal giocatore, per i modificatori EDIFICIO_SCELTO e TRUPPA_SCELTA.
func apply(def: ModifierDef, origin_kind: ActiveModifier.OriginKind, origin_name: String,
		current_year: int, board: NationBoard, rng: RandomNumberGenerator, chosen_piece: BoardPiece = null) -> String:
	var existing: ActiveModifier = _find(def, chosen_piece)
	if existing != null:
		match def.stacking:
			ModifierDef.Stacking.ALLUNGA_DURATA:
				existing.expires_at_year += def.duration_years
				return "%s si allunga fino alla fine dell'anno %d." % [def.display_name, existing.expires_at_year - 1]
			ModifierDef.Stacking.NESSUN_EFFETTO:
				return "%s è già attivo: nessun effetto." % def.display_name

	var modifier: ActiveModifier = ActiveModifier.new()
	modifier.def = def
	modifier.origin_kind = origin_kind
	modifier.origin_name = origin_name
	modifier.expires_at_year = current_year + 1 + def.duration_years
	match def.target:
		ModifierDef.Target.EDIFICIO_A_CASO:
			if board.buildings.is_empty():
				return "%s non ha effetto: nessun edificio da colpire." % def.display_name
			modifier.target_piece = board.buildings[rng.randi_range(0, board.buildings.size() - 1)]
		ModifierDef.Target.TRUPPA_A_CASO:
			if board.troops.is_empty():
				return "%s non ha effetto: nessuna truppa da colpire." % def.display_name
			modifier.target_piece = board.troops[rng.randi_range(0, board.troops.size() - 1)]
		ModifierDef.Target.EDIFICIO_SCELTO, ModifierDef.Target.TRUPPA_SCELTA:
			if chosen_piece == null:
				return "%s non ha effetto: nessun elemento scelto." % def.display_name
			modifier.target_piece = chosen_piece
	active.append(modifier)
	return "Nuovo effetto. %s" % modifier.describe()


## Toglie i modificatori scaduti all'inizio di un nuovo anno. Restituisce le frasi per la cronaca.
func on_new_year(year: int) -> Array[String]:
	var messages: Array[String] = []
	for modifier: ActiveModifier in active.duplicate():
		if modifier.def.duration_kind != ModifierDef.Duration.ANNI:
			continue
		if year >= modifier.expires_at_year:
			active.erase(modifier)
			messages.append("Finisce l'effetto: %s." % modifier.def.display_name)
	return messages


## Toglie i modificatori che durano fino al prossimo scontro con il fantasma.
func on_ghost_fight_done() -> Array[String]:
	var messages: Array[String] = []
	for modifier: ActiveModifier in active.duplicate():
		if modifier.def.duration_kind == ModifierDef.Duration.PROSSIMO_SCONTRO_FANTASMA:
			active.erase(modifier)
			messages.append("Finisce l'effetto: %s." % modifier.def.display_name)
	return messages


## Malus che durano un certo numero di anni (gli unici che si possono accorciare).
func year_malus() -> Array[ActiveModifier]:
	var found: Array[ActiveModifier] = []
	for modifier: ActiveModifier in active:
		if modifier.def.is_malus and modifier.def.duration_kind == ModifierDef.Duration.ANNI:
			found.append(modifier)
	return found


## Accorcia un modificatore di qualche anno; se la durata si azzera, sparisce subito.
func shorten(modifier: ActiveModifier, years: int, current_year: int) -> String:
	modifier.expires_at_year -= years
	if current_year >= modifier.expires_at_year:
		active.erase(modifier)
		return "Il malus %s sparisce." % modifier.def.display_name
	return "Il malus %s ora dura fino alla fine dell'anno %d." % [modifier.def.display_name, modifier.expires_at_year - 1]


## Toglie i modificatori il cui bersaglio non è più sulla plancia (venduto o sostituito).
func prune(board: NationBoard) -> Array[String]:
	var messages: Array[String] = []
	for modifier: ActiveModifier in active.duplicate():
		if modifier.target_piece == null:
			continue
		if board.buildings.has(modifier.target_piece) or board.troops.has(modifier.target_piece):
			continue
		active.erase(modifier)
		messages.append("Finisce l'effetto %s: %s non è più sulla plancia." % [modifier.def.display_name, modifier.target_piece.display_name()])
	return messages


## Somma degli effetti in percentuale (per la nazione o per un elemento preciso).
## Un effetto con etichetta vale solo per gli elementi che la hanno (GDD §6.6).
func percent(effect: ModifierDef.Effect, piece: BoardPiece = null) -> int:
	var total: int = 0
	for modifier: ActiveModifier in active:
		if modifier.def.effect != effect:
			continue
		if modifier.target_piece != null and modifier.target_piece != piece:
			continue
		if not _tag_matches(modifier.def, piece):
			continue
		total += modifier.def.amount
	return total


## Unità in più di una risorsa prodotte da un edificio (PRODUZIONE_PER_EDIFICIO).
func flat_production(type: Res.Type, piece: BoardPiece) -> int:
	var total: int = 0
	for modifier: ActiveModifier in active:
		var def: ModifierDef = modifier.def
		if def.effect != ModifierDef.Effect.PRODUZIONE_PER_EDIFICIO or def.resource != type:
			continue
		if modifier.target_piece != null and modifier.target_piece != piece:
			continue
		if not _tag_matches(def, piece):
			continue
		total += def.amount
	return total


## Variazione di un valore di battaglia di un elemento (VALORE_PERCENTUALE o VALORE_FISSO).
func battle_value(effect: ModifierDef.Effect, value: ModifierDef.BattleValue, piece: BoardPiece) -> int:
	var total: int = 0
	for modifier: ActiveModifier in active:
		var def: ModifierDef = modifier.def
		if def.effect != effect or def.battle_value != value:
			continue
		if modifier.target_piece != null and modifier.target_piece != piece:
			continue
		if not _tag_matches(def, piece):
			continue
		total += def.amount
	return total


## Percentuale sulla produzione totale di una risorsa (PRODUZIONE_PERCENTUALE).
func production_percent(type: Res.Type) -> int:
	var total: int = 0
	for modifier: ActiveModifier in active:
		if modifier.def.effect == ModifierDef.Effect.PRODUZIONE_PERCENTUALE and modifier.def.resource == type:
			total += modifier.def.amount
	return total


## true se il modificatore non ha etichetta, o se l'elemento la possiede.
static func _tag_matches(def: ModifierDef, piece: BoardPiece) -> bool:
	if def.target_tag == &"":
		return true
	if piece == null:
		return false
	if piece.building != null:
		return piece.building.tags.has(def.target_tag)
	if piece.troop != null:
		return piece.troop.tags.has(def.target_tag)
	return false


## Somma degli effetti a numero intero (costo di rinnovo, alternative).
func flat(effect: ModifierDef.Effect) -> int:
	var total: int = 0
	for modifier: ActiveModifier in active:
		if modifier.def.effect == effect and modifier.target_piece == null:
			total += modifier.def.amount
	return total


## Modificatori che colpiscono un elemento preciso della plancia.
func for_piece(piece: BoardPiece) -> Array[ActiveModifier]:
	var found: Array[ActiveModifier] = []
	for modifier: ActiveModifier in active:
		if modifier.target_piece == piece:
			found.append(modifier)
	return found


## Applica una percentuale a un numero intero, arrotondando per difetto e senza scendere sotto zero.
## Esempio: 7 con -50 diventa 3; 1000 con +50 diventa 1500.
@warning_ignore("integer_division")
static func apply_percent(value: int, percent_change: int) -> int:
	var factor: int = maxi(100 + percent_change, 0)
	return value * factor / 100


## Cerca lo stesso modificatore già attivo. Per quelli su un elemento scelto dal giocatore
## conta anche l'elemento: lo stesso bonus su due truppe diverse sono due effetti distinti.
func _find(def: ModifierDef, chosen_piece: BoardPiece) -> ActiveModifier:
	var chosen_target: bool = def.target == ModifierDef.Target.EDIFICIO_SCELTO or def.target == ModifierDef.Target.TRUPPA_SCELTA
	for modifier: ActiveModifier in active:
		var same_def: bool = modifier.def == def or (def.id != &"" and modifier.def.id == def.id)
		if not same_def:
			continue
		if chosen_target and modifier.target_piece != chosen_piece:
			continue
		return modifier
	return null
