class_name BattleSim
extends RefCounted
## Simulazione di uno scontro automatico (GDD §7).
##
## Logica pura: nessun nodo, nessuna grafica, nessun delta del frame.
## La battaglia avanza a passi fissi (BattleRules.tick_ms) e usa solo numeri interi.
## La casualità (bersagli di Inefficienza e Sabotaggio) usa un seme registrato:
## lo stesso seme dà sempre lo stesso scontro (GDD §7.5).
##
## Ordine di ogni istante (GDD §7.6.6):
##   1. avanzano i timer; gli edifici che hanno finito l'intervallo producono
##      mana, scudo, cura, Corruzione, Inefficienza e Sabotaggio;
##   2. le truppe pronte si attivano da destra verso sinistra;
##   3. si applicano le cure, lo scudo nuovo e la Corruzione;
##   4. il danno agli scudi (attacco d'assedio) toglie scudo;
##   5. il danno normale e il logoramento colpiscono lo scudo, poi la Resistenza;
##   6. si controlla chi è caduto (Resistenza a zero o Corruzione ≥ Resistenza);
##   7. Inefficienza e Sabotaggio prodotti in questo istante valgono dal successivo (GDD §7.7.3).

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
	SABOTATA,            ## Bloccata da un Sabotaggio: non si attiva.
}

const SIDE_A: int = 0
const SIDE_B: int = 1

## Colori del mana (GDD §5.3, v0.22: quattro colori). L'energetico vale come qualsiasi colore.
const MANA_ROSSO: StringName = &"rosso"
const MANA_VERDE: StringName = &"verde"
const MANA_BLU: StringName = &"blu"
const MANA_VIOLA: StringName = &"viola"
const MANA_ENERGETICO: StringName = &"energetico"
const MANA_COLORS: Array[StringName] = [&"rosso", &"verde", &"blu", &"viola", &"energetico"]
## Gli edifici senza mana sono neutri (GDD §5.3).
const MANA_NEUTRO: StringName = &"neutro"

## Negli indici degli elementi colpiti, le truppe partono da qui (gli edifici da 0).
const TROOP_INDEX_OFFSET: int = 1000

const EFFECT_SLOW: int = 0
const EFFECT_SABOTAGE: int = 1


## Stato in battaglia di una nazione.
class SideState:
	var buildings: Array[BuildingDef] = []
	var troops: Array[TroopDef] = []
	var max_resistance: int = 0
	var resistance: int = 0
	## Riserva di scudo unica (GDD §7.6.1).
	var shield: int = 0
	## Corruzione accumulata (GDD §7.6.3).
	var corruption: int = 0
	## Riserva di mana condivisa, divisa per colore (GDD §5.3, §7.4).
	var mana: Dictionary[StringName, int] = {}
	var production_left_ms: Array[int] = []
	var cooldown_left_ms: Array[int] = []
	var waiting_for_mana: Array[bool] = []
	## Millisecondi rimasti di Inefficienza e Sabotaggio, per edificio e per truppa.
	var building_slow_ms: Array[int] = []
	var building_sabotage_ms: Array[int] = []
	var troop_slow_ms: Array[int] = []
	var troop_sabotage_ms: Array[int] = []
	## Sacchetti della rotazione dei bersagli, uno per tipo di effetto e categoria (GDD §7.7.2).
	var bags: Dictionary[String, Array] = {}

	func get_mana(mana_type: StringName) -> int:
		return mana.get(mana_type, 0)

	## Mana spendibile da una truppa di un colore: il suo colore più l'energetico.
	func spendable(mana_type: StringName) -> int:
		if mana_type == MANA_ENERGETICO:
			return get_mana(MANA_ENERGETICO)
		return get_mana(mana_type) + get_mana(MANA_ENERGETICO)

	## Paga prima con il colore richiesto, poi con l'energetico (GDD §5.3).
	func pay(mana_type: StringName, cost: int) -> void:
		var own: int = mini(get_mana(mana_type), cost)
		mana[mana_type] = get_mana(mana_type) - own
		var rest: int = cost - own
		if rest > 0:
			mana[MANA_ENERGETICO] = get_mana(MANA_ENERGETICO) - rest

	func total_mana() -> int:
		var total: int = 0
		for value: int in mana.values():
			total += value
		return total


## Effetti di un istante, raccolti per nazione colpita e applicati insieme.
class Pending:
	var damage: Array[int] = [0, 0]
	var siege: Array[int] = [0, 0]
	var shield: Array[int] = [0, 0]
	var heal: Array[int] = [0, 0]
	var corruption: Array[int] = [0, 0]
	## [nazione colpita, effetto, categoria, millisecondi]
	var timer_effects: Array[Array] = []


var rules: BattleRules
var outcome: Outcome = Outcome.IN_CORSO
## Seme della casualità di questo scontro (GDD §7.5).
var battle_seed: int = 0
## Millisecondi trascorsi dall'inizio dello scontro.
var elapsed_ms: int = 0
## Tutti i fatti dello scontro, in ordine.
var events: Array[BattleEvent] = []
## Solo i fatti dell'ultimo passo (comodo per la presentazione).
var last_step_events: Array[BattleEvent] = []

var _sides: Array[SideState] = []
var _next_attrition_ms: int = 0
var _attrition_hits: int = 0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _init(p_rules: BattleRules, side_a: BattleSideSetup, side_b: BattleSideSetup, p_seed: int = 0) -> void:
	rules = p_rules
	battle_seed = p_seed
	_rng.seed = p_seed
	_validate_rules()
	_sides = [_make_side(side_a), _make_side(side_b)]
	_next_attrition_ms = rules.attrition_start_ms
	# Valori di partenza cambiati dai modificatori (GDD §8.2).
	for side_index: int in range(2):
		var setup: BattleSideSetup = side_a if side_index == SIDE_A else side_b
		if setup.start_building_sabotage_ms > 0:
			_apply_timer_effect(side_index, EFFECT_SABOTAGE, TimerTarget.Kind.EDIFICI, setup.start_building_sabotage_ms)
		for effect: Array in setup.start_timer_effects:
			_apply_timer_effect_to(side_index, effect[0], effect[1], effect[2])


## Fa avanzare lo scontro di un passo. Non fa nulla se lo scontro è finito.
func step() -> void:
	if outcome != Outcome.IN_CORSO:
		return
	last_step_events = []
	elapsed_ms += rules.tick_ms
	var pending: Pending = Pending.new()

	# 1. Timer ed edifici.
	for side_index: int in range(2):
		_advance_timers_and_produce(side_index, pending)

	# 2. Truppe, da destra verso sinistra.
	for side_index: int in range(2):
		_activate_troops(side_index, pending)

	# 3. Cure, scudo nuovo e Corruzione.
	for side_index: int in range(2):
		var state: SideState = _sides[side_index]
		if pending.heal[side_index] > 0:
			var healed: int = mini(pending.heal[side_index], state.max_resistance - state.resistance)
			if healed > 0:
				state.resistance += healed
				_record(side_index, BattleEvent.Kind.CURA, -1, healed, 0)
		if pending.shield[side_index] > 0:
			state.shield += pending.shield[side_index]
			_record(side_index, BattleEvent.Kind.SCUDO, -1, pending.shield[side_index], 0)
		if pending.corruption[side_index] > 0:
			state.corruption += pending.corruption[side_index]
			_record(side_index, BattleEvent.Kind.CORRUZIONE, -1, pending.corruption[side_index], 0)

	# 4. Attacco d'assedio: toglie solo scudo.
	for side_index: int in range(2):
		var state: SideState = _sides[side_index]
		var removed: int = mini(pending.siege[side_index], state.shield)
		if removed > 0:
			state.shield -= removed
			_record(side_index, BattleEvent.Kind.ASSEDIO, -1, removed, 0)

	# 5. Logoramento, poi danno su scudo e Resistenza.
	while elapsed_ms >= _next_attrition_ms:
		var attrition_damage: int = rules.attrition_first_damage + rules.attrition_damage_increase * _attrition_hits
		_attrition_hits += 1
		_next_attrition_ms += rules.attrition_interval_ms
		for side_index: int in range(2):
			pending.damage[side_index] += attrition_damage
			_record(side_index, BattleEvent.Kind.LOGORAMENTO, -1, attrition_damage, 0)
	for side_index: int in range(2):
		var state: SideState = _sides[side_index]
		var absorbed: int = mini(pending.damage[side_index], state.shield)
		state.shield -= absorbed
		state.resistance -= pending.damage[side_index] - absorbed

	# 6. Esito.
	_check_outcome()

	# 7. Inefficienza e Sabotaggio valgono dall'istante successivo.
	for effect: Array in pending.timer_effects:
		_apply_timer_effect(effect[0], effect[1], effect[2], effect[3])


## Fa avanzare lo scontro fino alla fine e restituisce l'esito.
func run_to_end() -> Outcome:
	while outcome == Outcome.IN_CORSO:
		step()
	return outcome


func get_resistance(side: int) -> int:
	return _sides[side].resistance


func get_max_resistance(side: int) -> int:
	return _sides[side].max_resistance


func get_shield(side: int) -> int:
	return _sides[side].shield


func get_corruption(side: int) -> int:
	return _sides[side].corruption


## Mana di un colore; senza colore restituisce il totale di tutti i colori.
func get_mana(side: int, mana_type: StringName = &"") -> int:
	if mana_type == &"":
		return _sides[side].total_mana()
	return _sides[side].get_mana(mana_type)


func get_troop_count(side: int) -> int:
	return _sides[side].troops.size()


func get_troop_cooldown_left_ms(side: int, troop_index: int) -> int:
	return _sides[side].cooldown_left_ms[troop_index]


## Perché una truppa non si sta attivando (principio P4).
func get_troop_state(side: int, troop_index: int) -> TroopState:
	if _sides[side].troop_sabotage_ms[troop_index] > 0:
		return TroopState.SABOTATA
	if _sides[side].waiting_for_mana[troop_index]:
		return TroopState.IN_ATTESA_DI_MANA
	return TroopState.IN_RICARICA


func get_troop_slow_ms(side: int, troop_index: int) -> int:
	return _sides[side].troop_slow_ms[troop_index]


func get_troop_sabotage_ms(side: int, troop_index: int) -> int:
	return _sides[side].troop_sabotage_ms[troop_index]


func get_building_production_left_ms(side: int, building_index: int) -> int:
	return _sides[side].production_left_ms[building_index]


func get_building_slow_ms(side: int, building_index: int) -> int:
	return _sides[side].building_slow_ms[building_index]


func get_building_sabotage_ms(side: int, building_index: int) -> int:
	return _sides[side].building_sabotage_ms[building_index]


# --- Parti interne ---------------------------------------------------------

func _make_side(setup: BattleSideSetup) -> SideState:
	var state: SideState = SideState.new()
	state.buildings = setup.buildings.duplicate()
	state.troops = setup.troops.duplicate()
	state.max_resistance = setup.max_resistance
	state.resistance = setup.max_resistance
	state.shield = setup.start_shield
	state.corruption = setup.start_corruption
	for building: BuildingDef in state.buildings:
		if building.mana_interval_ms <= 0:
			push_error("Edificio '%s': intervallo di produzione non valido (%d ms)." % [building.id, building.mana_interval_ms])
		# Gli edifici partono con l'intervallo pieno (GDD §7.4).
		state.production_left_ms.append(building.mana_interval_ms)
		state.building_slow_ms.append(0)
		state.building_sabotage_ms.append(0)
	for troop: TroopDef in state.troops:
		if troop.cooldown_ms <= 0:
			push_error("Truppa '%s': ricarica non valida (%d ms)." % [troop.id, troop.cooldown_ms])
		# Le truppe partono con la ricarica piena (GDD §7.5).
		state.cooldown_left_ms.append(troop.cooldown_ms)
		state.waiting_for_mana.append(false)
		state.troop_slow_ms.append(0)
		state.troop_sabotage_ms.append(0)
	return state


## Quanto avanza in questo istante il timer di un elemento: fermo se sabotato,
## a velocità ridotta se rallentato (il blocco prevale, GDD §7.7.3).
func _timer_step(slow_ms: int, sabotage_ms: int) -> int:
	if sabotage_ms > 0:
		return 0
	if slow_ms > 0:
		@warning_ignore("integer_division")
		var slowed: int = rules.tick_ms * rules.inefficiency_speed_percent / 100
		return slowed
	return rules.tick_ms


func _advance_timers_and_produce(side_index: int, pending: Pending) -> void:
	var state: SideState = _sides[side_index]
	var enemy: int = _opponent(side_index)
	for i: int in range(state.buildings.size()):
		var building: BuildingDef = state.buildings[i]
		var advance: int = _timer_step(state.building_slow_ms[i], state.building_sabotage_ms[i])
		state.building_slow_ms[i] = maxi(0, state.building_slow_ms[i] - rules.tick_ms)
		state.building_sabotage_ms[i] = maxi(0, state.building_sabotage_ms[i] - rules.tick_ms)
		if building.mana_interval_ms <= 0:
			continue
		state.production_left_ms[i] -= advance
		while state.production_left_ms[i] <= 0:
			state.production_left_ms[i] += building.mana_interval_ms
			if building.mana_amount > 0:
				state.mana[building.mana_type] = state.get_mana(building.mana_type) + building.mana_amount
				_record(side_index, BattleEvent.Kind.MANA_PRODOTTO, i, building.mana_amount, state.get_mana(building.mana_type))
			pending.shield[side_index] += building.shield
			pending.heal[side_index] += building.heal
			pending.corruption[enemy] += building.corruption
			if building.inefficiency_ms > 0:
				pending.timer_effects.append([enemy, EFFECT_SLOW, building.inefficiency_target, building.inefficiency_ms])
			if building.sabotage_ms > 0:
				pending.timer_effects.append([enemy, EFFECT_SABOTAGE, building.sabotage_target, building.sabotage_ms])
	for i: int in range(state.troops.size()):
		var advance: int = _timer_step(state.troop_slow_ms[i], state.troop_sabotage_ms[i])
		state.troop_slow_ms[i] = maxi(0, state.troop_slow_ms[i] - rules.tick_ms)
		state.cooldown_left_ms[i] = maxi(0, state.cooldown_left_ms[i] - advance)


## Valuta le truppe pronte da destra verso sinistra (GDD §7.3).
func _activate_troops(side_index: int, pending: Pending) -> void:
	var state: SideState = _sides[side_index]
	var enemy: int = _opponent(side_index)
	for i: int in range(state.troops.size() - 1, -1, -1):
		var sabotaged: bool = state.troop_sabotage_ms[i] > 0
		state.troop_sabotage_ms[i] = maxi(0, state.troop_sabotage_ms[i] - rules.tick_ms)
		if state.cooldown_left_ms[i] > 0:
			continue
		if sabotaged:
			# Bloccata: non si attiva nemmeno se pronta e con mana (GDD §7.7).
			# Il motivo si legge dallo stato della truppa (get_troop_state).
			continue
		var troop: TroopDef = state.troops[i]
		var available: int = state.spendable(troop.mana_type)
		if available < troop.mana_cost:
			# Saltata: niente consumo, niente nuova ricarica, nessun mana prenotato.
			if not state.waiting_for_mana[i]:
				state.waiting_for_mana[i] = true
				_record(side_index, BattleEvent.Kind.IN_ATTESA_MANA, i, 0, available)
			continue
		if troop.mana_cost > 0:
			state.pay(troop.mana_type, troop.mana_cost)
		state.waiting_for_mana[i] = false
		state.cooldown_left_ms[i] = troop.cooldown_ms
		pending.damage[enemy] += troop.damage
		pending.siege[enemy] += troop.siege_damage
		pending.shield[side_index] += troop.shield
		pending.heal[side_index] += troop.heal
		pending.corruption[enemy] += troop.corruption
		if troop.inefficiency_ms > 0:
			pending.timer_effects.append([enemy, EFFECT_SLOW, troop.inefficiency_target, troop.inefficiency_ms])
		if troop.sabotage_ms > 0:
			pending.timer_effects.append([enemy, EFFECT_SABOTAGE, troop.sabotage_target, troop.sabotage_ms])
		_record(side_index, BattleEvent.Kind.ATTIVAZIONE, i, troop.damage, state.spendable(troop.mana_type))


## Applica Inefficienza o Sabotaggio a un bersaglio scelto a caso, a rotazione (GDD §7.7.2).
## Se un elemento è già colpito dallo stesso effetto, le durate si sommano (§7.7.3).
func _apply_timer_effect(side_index: int, effect: int, category: TimerTarget.Kind, duration_ms: int) -> void:
	var state: SideState = _sides[side_index]
	var valid: Array[int] = []
	if category != TimerTarget.Kind.TRUPPE:
		for i: int in range(state.buildings.size()):
			valid.append(i)
	if category != TimerTarget.Kind.EDIFICI:
		for i: int in range(state.troops.size()):
			valid.append(TROOP_INDEX_OFFSET + i)
	if valid.is_empty():
		return  # Nessun bersaglio valido: l'effetto va perso.
	var key: String = "%d_%d" % [effect, category]
	var bag: Array = state.bags.get(key, [])
	if bag.is_empty():
		bag = valid.duplicate()
	var pick: int = _rng.randi_range(0, bag.size() - 1)
	var target: int = bag[pick]
	bag.remove_at(pick)
	state.bags[key] = bag
	if target >= TROOP_INDEX_OFFSET:
		var troop_index: int = target - TROOP_INDEX_OFFSET
		if effect == EFFECT_SLOW:
			state.troop_slow_ms[troop_index] += duration_ms
		else:
			state.troop_sabotage_ms[troop_index] += duration_ms
	else:
		if effect == EFFECT_SLOW:
			state.building_slow_ms[target] += duration_ms
		else:
			state.building_sabotage_ms[target] += duration_ms
	var kind: BattleEvent.Kind = BattleEvent.Kind.RALLENTATO if effect == EFFECT_SLOW else BattleEvent.Kind.SABOTATO
	_record(side_index, kind, target, duration_ms, 0)


## Applica Inefficienza o Sabotaggio a un elemento preciso (es. lo spionaggio, GDD §12).
## Un indice che non esiste viene ignorato.
func _apply_timer_effect_to(side_index: int, effect: int, target: int, duration_ms: int) -> void:
	var state: SideState = _sides[side_index]
	if target >= TROOP_INDEX_OFFSET:
		var troop_index: int = target - TROOP_INDEX_OFFSET
		if troop_index < 0 or troop_index >= state.troops.size():
			return
		if effect == EFFECT_SLOW:
			state.troop_slow_ms[troop_index] += duration_ms
		else:
			state.troop_sabotage_ms[troop_index] += duration_ms
	else:
		if target < 0 or target >= state.buildings.size():
			return
		if effect == EFFECT_SLOW:
			state.building_slow_ms[target] += duration_ms
		else:
			state.building_sabotage_ms[target] += duration_ms
	var kind: BattleEvent.Kind = BattleEvent.Kind.RALLENTATO if effect == EFFECT_SLOW else BattleEvent.Kind.SABOTATO
	_record(side_index, kind, target, duration_ms, 0)


## Una nazione cade con la Resistenza a zero o con la Corruzione pari o superiore alla Resistenza.
func _is_down(state: SideState) -> bool:
	return state.resistance <= 0 or state.corruption >= state.resistance


func _check_outcome() -> void:
	var a_down: bool = _is_down(_sides[SIDE_A])
	var b_down: bool = _is_down(_sides[SIDE_B])
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
