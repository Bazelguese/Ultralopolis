class_name Inclination
extends RefCounted
## Le quattro inclinazioni della nazione (GDD §9.6, v0.29): coppie di tendenze opposte che le
## cronache spostano. Ogni asse va da -limite (secondo polo) a +limite (primo polo); il limite
## sta nelle regole della run (RunRules.inclination_limit).

enum Axis {
	SPADA,   ## Conquistatrice (+) / Pacifica (-).
	PORTA,   ## Aperta (+) / Chiusa (-).
	ALTARE,  ## Devota (+) / Profana (-).
	LEGGE,   ## Ordinata (+) / Libera (-).
}

const AXIS_NAMES: Dictionary[Axis, String] = {
	Axis.SPADA: "Spada",
	Axis.PORTA: "Porta",
	Axis.ALTARE: "Altare",
	Axis.LEGGE: "Legge",
}

## Nome del polo positivo di ogni asse.
const PLUS_POLE: Dictionary[Axis, String] = {
	Axis.SPADA: "Conquistatrice",
	Axis.PORTA: "Aperta",
	Axis.ALTARE: "Devota",
	Axis.LEGGE: "Ordinata",
}

## Nome del polo negativo di ogni asse.
const MINUS_POLE: Dictionary[Axis, String] = {
	Axis.SPADA: "Pacifica",
	Axis.PORTA: "Chiusa",
	Axis.ALTARE: "Profana",
	Axis.LEGGE: "Libera",
}


## Nome del polo verso cui spinge un numero (positivo o negativo) su un asse.
static func pole_name(axis: int, sign_value: int) -> String:
	return PLUS_POLE[axis as Axis] if sign_value > 0 else MINUS_POLE[axis as Axis]


## Valori di partenza: quattro zeri.
static func empty() -> PackedInt32Array:
	return PackedInt32Array([0, 0, 0, 0])


## Testo breve di uno spostamento, es. "→ Conquistatrice, → Chiusa"; vuoto se non sposta nulla.
static func describe_shift(shift: PackedInt32Array) -> String:
	var parts: PackedStringArray = PackedStringArray()
	for axis: int in range(mini(shift.size(), Axis.size())):
		if shift[axis] != 0:
			parts.append("→ %s%s" % [pole_name(axis, shift[axis]), "" if absi(shift[axis]) == 1 else " ×%d" % absi(shift[axis])])
	return ", ".join(parts)
