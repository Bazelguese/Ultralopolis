class_name BattleSim
extends RefCounted
## Simulazione di uno scontro automatico (GDD §7).
##
## Logica pura: nessun nodo, nessuna grafica, nessun delta del frame.
## La battaglia avanza a passi fissi (BattleRules.tick_ms) e usa solo numeri interi,
## così lo stesso scontro dà lo stesso risultato su qualunque computer.
##
## Ordine di ogni passo (GDD §7.5):
##   1. avanzano i tempi di ricarica e di produzione;
##   2. gli edifici che hanno finito l'intervallo producono mana;
##   3. le truppe pronte vengono valutate da destra verso sinistra e si attivano se possono pagare;
##   4. il logoramento colpisce entrambe le nazioni, se è iniziato;
##   5. i danni delle due nazioni vengono applicati insieme e si controlla l'esito.

enum Outcome {
	IN_CORSO,
	VITTORIA_A,
	VITTORIA_B,
	PAREGGIO,
	INTERROTTA,  ## Solo con dati sbagliati: superato il limite tecnico di sicurezza.
}

enum TroopState {
	IN_RICARICA,         ## Il tempo di ricarica non è finito.
	IN_ATTESA_DI_MANA,   ## Pronta, ma il mana non basta: aspetta senza nuova ricarica.
}

const SIDE_A: int = 0
const SIDE_B: int = 1


## Stato in battaglia di una nazione.
class SideState:
	var buildings: Array[BuildingDef] = []
	var troops: Array[TroopDef] = []
	var max_resistance: int = 0
	var resistance: int = 0
	## Riserva di mana condivisa, divisa per tipo (GDD §5.3, §7.4).
	var mana: Dictionary[StringName, int] = {}
	## Millisecondi che mancano alla prossima produzione di ogni edificio.
	var production_left_ms: Array[int] = []
	## Millisecondi di ricarica rimanenti per ogni truppa.
	var cooldown_left_ms: Array[int] = []
	## true se la truppa è pronta ma è rimasta senza mana all'ultima valutazione.
	var waiting_for_mana: Array[bool] = []

	func get_mana(mana_type: StringName) -> int:
		return mana.get(mana_type, 0)


var rules: BattleRules
var outcome: Outcome = Outcome.IN_CORSO
## Millisecondi trascorsi dall'inizio dello scontro.
var elapsed_ms: int = 0
## Tutti i fatti dello scontro, in ordine.
var events: Array[BattleEvent] = []
## Solo i fatti dell'ultimo passo (comodo per la presentazione).
var last_step_events: Array[BattleEvent] = []

var _sides: Array[SideState] = []
var _next_attrition_ms: int = 0
var _attrition_hits: int = 0


func _init(p_rules: BattleRules, side_a: BattleSideSetup, side_b: BattleSideSetup) -> void:
	rules = p_rules
	_validate_rules()
	_sides = [_make_side(side_a), _make_side(side_b)]
	_next_attrition_ms = rules.attrition_start_ms


## Fa avanzare lo scontro di un passo. Non fa nulla se lo scontro è finito.
func step() -> void:
	if outcome != Outcome.IN_CORSO:
		return
	last_step_events = []
	elapsed_ms += rules.tick_ms

	# 1-2. Tempi e produzione di mana, per entrambe le nazioni.
	for side_index: int in range(_sides.size()):
		_advance_timers_and_produce(side_index)

	# 3. Attivazioni. I danni vengono raccolti e applicati insieme alla fine.
	var damage_to: Array[int] = [0, 0]
	for side_index: int in range(_sides.size()):
		var dealt: int = _activate_troops(side_index)
		damage_to[_opponent(side_index)] += dealt

	# 4. Logoramento.
	while elapsed_ms >= _next_attrition_ms:
		var attrition_damage: int = rules.attrition_first_damage + rules.attrition_damage_increase * _attrition_hits
		_attrition_hits += 1
		_next_attrition_ms += rules.attrition_interval_ms
		for side_index: int in range(_sides.size()):
			damage_to[side_index] += attrition_damage
			_record(side_index, BattleEvent.Kind.LOGORAMENTO, -1, attrition_damage, 0)

	# 5. Danni simultanei ed esito.
	for side_index: int in range(_sides.size()):
		_sides[side_index].resistance -= damage_to[side_index]
	_check_outcome()


## Fa avanzare lo scontro fino alla fine e restituisce l'esito.
func run_to_end() -> Outcome:
	while outcome == Outcome.IN_CORSO:
		step()
	return outcome


func get_resistance(side: int) -> int:
	return _sides[side].resistance


func get_max_resistance(side: int) -> int:
	return _sides[side].max_resistance


func get_mana(side: int, mana_type: StringName = &"neutro") -> int:
	return _sides[side].get_mana(mana_type)


func get_troop_count(side: int) -> int:
	return _sides[side].troops.size()


func get_troop_cooldown_left_ms(side: int, troop_index: int) -> int:
	return _sides[side].cooldown_left_ms[troop_index]


## Perché una truppa non si sta attivando (principio P4).
func get_troop_state(side: int, troop_index: int) -> TroopState:
	if _sides[side].waiting_for_mana[troop_index]:
		return TroopState.IN_ATTESA_DI_MANA
	return TroopState.IN_RICARICA


func get_building_production_left_ms(side: int, building_index: int) -> int:
	return _sides[side].production_left_ms[building_index]


# --- Parti interne ---------------------------------------------------------

func _make_side(setup: BattleSideSetup) -> SideState:
	var state: SideState = SideState.new()
	state.buildings = setup.buildings.duplicate()
	state.troops = setup.troops.duplicate()
	state.max_resistance = setup.max_resistance
	state.resistance = setup.max_resistance
	for building: BuildingDef in state.buildings:
		if building.mana_interval_ms <= 0:
			push_error("Edificio '%s': intervallo di produzione non valido (%d ms)." % [building.id, building.mana_interval_ms])
		# Gli edifici partono con l'intervallo pieno (GDD §7.4).
		state.production_left_ms.append(building.mana_interval_ms)
	for troop: TroopDef in state.troops:
		if troop.cooldown_ms <= 0:
			push_error("Truppa '%s': ricarica non valida (%d ms)." % [troop.id, troop.cooldown_ms])
		# Le truppe partono con la ricarica piena (GDD §7.5).
		state.cooldown_left_ms.append(troop.cooldown_ms)
		state.waiting_for_mana.append(false)
	return state


func _advance_timers_and_produce(side_index: int) -> void:
	var state: SideState = _sides[side_index]
	for i: int in range(state.buildings.size()):
		var building: BuildingDef = state.buildings[i]
		if building.mana_interval_ms <= 0:
			continue
		state.production_left_ms[i] -= rules.tick_ms
		while state.production_left_ms[i] <= 0:
			state.production_left_ms[i] += building.mana_interval_ms
			if building.mana_amount > 0:
				state.mana[building.mana_type] = state.get_mana(building.mana_type) + building.mana_amount
				_record(side_index, BattleEvent.Kind.MANA_PRODOTTO, i, building.mana_amount, state.get_mana(building.mana_type))
	for i: int in range(state.troops.size()):
		state.cooldown_left_ms[i] = maxi(0, state.cooldown_left_ms[i] - rules.tick_ms)


## Valuta le truppe pronte da destra verso sinistra (GDD §7.3).
## Restituisce il danno totale inflitto in questo passo.
func _activate_troops(side_index: int) -> int:
	var state: SideState = _sides[side_index]
	var total_damage: int = 0
	for i: int in range(state.troops.size() - 1, -1, -1):
		if state.cooldown_left_ms[i] > 0:
			continue
		var troop: TroopDef = state.troops[i]
		var available: int = state.get_mana(troop.mana_type)
		if available < troop.mana_cost:
			# Saltata: niente consumo, niente nuova ricarica, nessun mana prenotato.
			if not state.waiting_for_mana[i]:
				state.waiting_for_mana[i] = true
				_record(side_index, BattleEvent.Kind.IN_ATTESA_MANA, i, 0, available)
			continue
		if troop.mana_cost > 0:
			state.mana[troop.mana_type] = available - troop.mana_cost
		state.waiting_for_mana[i] = false
		state.cooldown_left_ms[i] = troop.cooldown_ms
		total_damage += troop.damage
		_record(side_index, BattleEvent.Kind.ATTIVAZIONE, i, troop.damage, state.get_mana(troop.mana_type))
	return total_damage


func _check_outcome() -> void:
	var a_down: bool = _sides[SIDE_A].resistance <= 0
	var b_down: bool = _sides[SIDE_B].resistance <= 0
	if a_down and b_down:
		outcome = Outcome.PAREGGIO
	elif b_down:
		outcome = Outcome.VITTORIA_A
	elif a_down:
		outcome = Outcome.VITTORIA_B
	elif elapsed_ms >= rules.safety_limit_ms:
		push_warning("BattleSim: superato il limite di sicurezza, scontro interrotto. Controllare i dati.")
		outcome = Outcome.INTERROTTA


func _record(side_index: int, kind: BattleEvent.Kind, index: int, amount: int, mana_after: int) -> void:
	var event: BattleEvent = BattleEvent.new(elapsed_ms, side_index, kind, index, amount, mana_after)
	events.append(event)
	last_step_events.append(event)


func _opponent(side_index: int) -> int:
	return SIDE_B if side_index == SIDE_A else SIDE_A


func _validate_rules() -> void:
	if rules.tick_ms <= 0:
		push_error("BattleRules: tick_ms deve essere maggiore di zero.")
	if rules.attrition_interval_ms <= 0:
		push_error("BattleRules: attrition_interval_ms deve essere maggiore di zero.")
	if rules.attrition_first_damage <= 0 and rules.attrition_damage_increase <= 0:
		push_warning("BattleRules: il logoramento non infligge danni, uno scontro potrebbe non finire.")
