class_name ElementStats
extends RefCounted
## Come entra in battaglia un edificio o una truppa: livello (GDD §6.5) e modificatori (§8),
## per il giocatore, per i fantasmi e per il generatore. Restituisce sempre una copia:
## le schede del catalogo non vengono mai toccate.
##
## Ordine dei calcoli di un valore: livello (+50% a livello), poi percentuali, poi aggiunte fisse.
## Le aggiunte fisse valgono solo per chi ha già quel valore (es. "chi cura cura 1 in più").


static func troop(def: TroopDef, piece: BoardPiece, mods: Modifiers, level: int, rules: RunRules,
		extra_cooldown_percent: int = 0) -> TroopDef:
	var copy: TroopDef = def.duplicate() as TroopDef
	var base: TroopDef = _with_enchant(def, piece)
	var cooldown_change: int = extra_cooldown_percent
	if mods != null:
		cooldown_change += mods.percent(ModifierDef.Effect.RICARICA_TRUPPA, piece)
	copy.cooldown_ms = maxi(1, Modifiers.apply_percent(def.cooldown_ms, cooldown_change))
	var damage_extra: int = mods.percent(ModifierDef.Effect.DANNO_TRUPPA, piece) if mods != null else 0
	copy.mana_type = base.mana_type
	copy.mana_cost = base.mana_cost
	copy.inefficiency_target = base.inefficiency_target
	copy.damage = _value(base.damage, ModifierDef.BattleValue.DANNO, piece, mods, level, rules, damage_extra)
	copy.shield = _value(base.shield, ModifierDef.BattleValue.SCUDO, piece, mods, level, rules)
	copy.heal = _value(base.heal, ModifierDef.BattleValue.CURA, piece, mods, level, rules)
	copy.corruption = _value(base.corruption, ModifierDef.BattleValue.CORRUZIONE, piece, mods, level, rules)
	copy.siege_damage = _value(base.siege_damage, ModifierDef.BattleValue.ASSEDIO, piece, mods, level, rules)
	copy.inefficiency_ms = _value(base.inefficiency_ms, ModifierDef.BattleValue.INEFFICIENZA, piece, mods, level, rules)
	copy.sabotage_ms = _value(base.sabotage_ms, ModifierDef.BattleValue.SABOTAGGIO, piece, mods, level, rules)
	return copy


## La truppa con l'incanto del Sacerdote (GDD §4.3): l'effetto si aggiunge al valore di base,
## quindi cresce con i livelli come gli altri; il mana sale di enchant_mana. Una truppa che non
## chiedeva mana lo chiede del colore dell'incanto.
## Con l'ascensione Seconda natura (GDD §10.4.2) si aggiunge allo stesso modo il secondo incanto.
static func _with_enchant(def: TroopDef, piece: BoardPiece) -> TroopDef:
	if piece == null or piece.enchant == null:
		return def
	var result: TroopDef = def.duplicate() as TroopDef
	_add_spell(result, piece.enchant, piece.enchant_amount, piece.enchant_amount_2)
	if piece.second_enchant != null:
		_add_spell(result, piece.second_enchant, piece.second_enchant_amount, piece.second_enchant_amount_2)
	return result


static func _add_spell(result: TroopDef, spell: OpportunityDef, amount: int, amount_2: int) -> void:
	if result.mana_cost <= 0:
		result.mana_type = spell.enchant_color
	result.mana_cost = maxi(0, result.mana_cost) + spell.enchant_mana
	_add_enchant_value(result, spell.enchant_value, amount)
	if not spell.enchant_amounts_2.is_empty():
		_add_enchant_value(result, spell.enchant_value_2, amount_2)


static func _add_enchant_value(result: TroopDef, value: ModifierDef.BattleValue, amount: int) -> void:
	match value:
		ModifierDef.BattleValue.DANNO:
			result.damage += amount
		ModifierDef.BattleValue.SCUDO:
			result.shield += amount
		ModifierDef.BattleValue.CURA:
			result.heal += amount
		ModifierDef.BattleValue.CORRUZIONE:
			result.corruption += amount
		ModifierDef.BattleValue.INEFFICIENZA:
			if result.inefficiency_ms <= 0:
				result.inefficiency_target = TimerTarget.Kind.TRUPPE
			result.inefficiency_ms += amount
		ModifierDef.BattleValue.SABOTAGGIO:
			result.sabotage_ms += amount
		ModifierDef.BattleValue.ASSEDIO:
			result.siege_damage += amount


static func building(def: BuildingDef, piece: BoardPiece, mods: Modifiers, level: int, rules: RunRules) -> BuildingDef:
	var copy: BuildingDef = def.duplicate() as BuildingDef
	var interval_change: int = mods.percent(ModifierDef.Effect.INTERVALLO_MANA, piece) if mods != null else 0
	copy.mana_interval_ms = maxi(1, Modifiers.apply_percent(def.mana_interval_ms, interval_change))
	copy.shield = _value(def.shield, ModifierDef.BattleValue.SCUDO, piece, mods, level, rules)
	copy.heal = _value(def.heal, ModifierDef.BattleValue.CURA, piece, mods, level, rules)
	copy.corruption = _value(def.corruption, ModifierDef.BattleValue.CORRUZIONE, piece, mods, level, rules)
	copy.inefficiency_ms = _value(def.inefficiency_ms, ModifierDef.BattleValue.INEFFICIENZA, piece, mods, level, rules)
	copy.sabotage_ms = _value(def.sabotage_ms, ModifierDef.BattleValue.SABOTAGGIO, piece, mods, level, rules)
	return copy


static func _value(base: int, value: ModifierDef.BattleValue, piece: BoardPiece, mods: Modifiers,
		level: int, rules: RunRules, extra_percent: int = 0) -> int:
	if base <= 0:
		return base
	var result: int = Modifiers.apply_percent(base, rules.troop_damage_percent_per_level * (level - 1))
	if mods != null:
		result = Modifiers.apply_percent(result, extra_percent + mods.battle_value(ModifierDef.Effect.VALORE_PERCENTUALE, value, piece))
		result += mods.battle_value(ModifierDef.Effect.VALORE_FISSO, value, piece)
	return maxi(0, result)
