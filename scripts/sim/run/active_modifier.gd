class_name ActiveModifier
extends RefCounted
## Un modificatore attivo nella run, con la sua origine e la sua scadenza (GDD §8.2).

enum OriginKind {
	FANTASMA,
	INCONTRO,
	EVENTO,
	ALTRO,
}

const ORIGIN_NAMES: Dictionary[OriginKind, String] = {
	OriginKind.FANTASMA: "fantasma",
	OriginKind.INCONTRO: "incontro",
	OriginKind.EVENTO: "evento",
	OriginKind.ALTRO: "altro",
}

var def: ModifierDef
var origin_kind: OriginKind = OriginKind.ALTRO
## Nome di chi l'ha inflitto, mostrato al giocatore (GDD §8.2, scelta di Davide).
var origin_name: String = ""
## Il modificatore viene tolto all'inizio di quest'anno.
var expires_at_year: int = 0
## Elemento colpito, per i modificatori su un edificio o una truppa.
var target_piece: BoardPiece


func describe() -> String:
	var kind: String = "Malus" if def.is_malus else "Bonus"
	var text: String = "%s: %s" % [kind, def.display_name]
	if target_piece != null:
		text += " (su %s)" % target_piece.display_name()
	text += " — da %s" % origin_name
	text += " — fino alla fine dell'anno %d" % (expires_at_year - 1)
	return text
