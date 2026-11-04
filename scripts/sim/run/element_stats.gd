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
	var cooldown_change: int = extra_cooldown_percent
	if mods != null:
		cooldown_change += mods.percent(ModifierDef.Effect.RICARICA_TRUPPA, piece)
	copy.cooldown_ms = maxi(1, Modifiers.apply_percent(def.cooldown_ms, cooldown_change))
	var damage_extra: int = mods.percent(ModifierDef.Effect.DANNO_TRUPPA, piece) if mods != null else 0
	copy.damage = _value(def.damage, ModifierDef.BattleValue.DANNO, piece, mods, level, rules, damage_extra)
	copy.shield = _value(def.shield, ModifierDef.BattleValue.SCUDO, piece, mods, level, rules)
	copy.heal = _value(def.heal, ModifierDef.BattleValue.CURA, piece, mods, level, rules)
	copy.corruption = _value(def.corruption, ModifierDef.BattleValue.CORRUZIONE, piece, mods, level, rules)
	copy.siege_damage = _value(def.siege_damage, ModifierDef.BattleValue.ASSEDIO, piece, mods, level, rules)
	copy.inefficiency_ms = _value(def.inefficiency_ms, ModifierDef.BattleValue.INEFFICIENZA, piece, mods, level, rules)
	copy.sabotage_ms = _value(def.sabotage_ms, ModifierDef.BattleValue.SABOTAGGIO, piece, mods, level, rules)
	return copy


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
