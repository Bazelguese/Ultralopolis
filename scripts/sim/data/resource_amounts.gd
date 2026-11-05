class_name ResourceAmounts
extends Resource
## Una quantità di risorse, in unità intere come le vede il giocatore
## (es. il costo di un potenziamento: 2 Ferro e 1 Oro).

@export var oro: int = 0
@export var ricerca: int = 0
@export var cibo: int = 0
@export var legno: int = 0
@export var pietra: int = 0
@export var ferro: int = 0
@export var fede: int = 0
@export var influenza: int = 0
@export var stabilita: int = 0
@export var documenti: int = 0


## Quantità di una risorsa in unità intere.
func whole(type: Res.Type) -> int:
	match type:
		Res.Type.ORO: return oro
		Res.Type.RICERCA: return ricerca
		Res.Type.CIBO: return cibo
		Res.Type.LEGNO: return legno
		Res.Type.PIETRA: return pietra
		Res.Type.FERRO: return ferro
		Res.Type.FEDE: return fede
		Res.Type.INFLUENZA: return influenza
		Res.Type.STABILITA: return stabilita
		Res.Type.DOCUMENTI: return documenti
	return 0


## Quantità di una risorsa in unità interne (il Cibo in decimi).
func internal(type: Res.Type) -> int:
	return whole(type) * Res.scale(type)


func is_empty() -> bool:
	for type: Res.Type in Res.NAMES:
		if whole(type) != 0:
			return false
	return true


## Es. "2 Ferro + 1 Oro".
func describe() -> String:
	var parts: PackedStringArray = PackedStringArray()
	for type: Res.Type in Res.NAMES:
		if whole(type) != 0:
			parts.append("%d %s" % [whole(type), Res.NAMES[type]])
	return " + ".join(parts) if not parts.is_empty() else "gratis"
