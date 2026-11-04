class_name Res
extends RefCounted
## Le risorse del Magazzino (GDD §5.3).
## Internamente sono numeri interi; il Cibo si conta in decimi (0,5 Cibo = 5),
## per poter avere razioni da mezzo Cibo senza usare numeri con la virgola (§16.3).

enum Type {
	ORO,
	RICERCA,
	CIBO,
	LEGNO,
	PIETRA,
	FERRO,
	FAUNA,
	FEDE,
	INFLUENZA,
}

const NAMES: Dictionary[Type, String] = {
	Type.ORO: "Oro",
	Type.RICERCA: "Ricerca",
	Type.CIBO: "Cibo",
	Type.LEGNO: "Legno",
	Type.PIETRA: "Pietra",
	Type.FERRO: "Ferro",
	Type.FAUNA: "Fauna",
	Type.FEDE: "Fede",
	Type.INFLUENZA: "Influenza",
}

const COUNT: int = 9


## Quante unità interne vale 1 unità mostrata al giocatore.
static func scale(type: Type) -> int:
	return 10 if type == Type.CIBO else 1


## Un Magazzino vuoto: una casella per risorsa, in unità interne.
static func empty() -> Array[int]:
	var values: Array[int] = []
	values.resize(COUNT)
	values.fill(0)
	return values


## Testo per il giocatore, es. "3" oppure "3,5" per il Cibo.
@warning_ignore("integer_division")
static func format(type: Type, internal_amount: int) -> String:
	var unit: int = scale(type)
	if unit == 1:
		return str(internal_amount)
	var whole: int = internal_amount / unit
	var rest: int = absi(internal_amount % unit)
	if rest == 0:
		return str(whole)
	return "%d,%d" % [whole, rest]
