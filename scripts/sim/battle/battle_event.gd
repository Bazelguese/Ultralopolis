class_name BattleEvent
extends RefCounted
## Un fatto accaduto in battaglia, registrato per la presentazione e per spiegare
## lo scontro al giocatore (principio P4).

enum Kind {
	MANA_PRODOTTO,     ## Un edificio ha prodotto mana.
	ATTIVAZIONE,       ## Una truppa si è attivata e ha inflitto danno.
	IN_ATTESA_MANA,    ## Una truppa è pronta ma non c'è abbastanza mana.
	LOGORAMENTO,       ## Il logoramento ha colpito questa nazione.
}

## Momento dello scontro, in millisecondi dall'inizio.
var time_ms: int = 0
## Nazione coinvolta: 0 = lato A, 1 = lato B.
var side: int = 0
var kind: Kind = Kind.MANA_PRODOTTO
## Posizione dell'edificio o della truppa nella sua fila (-1 se non serve).
var index: int = -1
## Quantità: mana prodotto, danno inflitto o danno subito.
var amount: int = 0
## Mana posseduto subito dopo il fatto (utile per spiegare le attese).
var mana_after: int = 0


func _init(p_time_ms: int, p_side: int, p_kind: Kind, p_index: int, p_amount: int, p_mana_after: int) -> void:
	time_ms = p_time_ms
	side = p_side
	kind = p_kind
	index = p_index
	amount = p_amount
	mana_after = p_mana_after


func describe() -> String:
	var who: String = "A" if side == 0 else "B"
	match kind:
		Kind.MANA_PRODOTTO:
			return "%d ms [%s] edificio %d produce %d mana (riserva %d)" % [time_ms, who, index, amount, mana_after]
		Kind.ATTIVAZIONE:
			return "%d ms [%s] truppa %d si attiva: %d danni (riserva %d)" % [time_ms, who, index, amount, mana_after]
		Kind.IN_ATTESA_MANA:
			return "%d ms [%s] truppa %d pronta, in attesa di mana (riserva %d)" % [time_ms, who, index, mana_after]
		Kind.LOGORAMENTO:
			return "%d ms [%s] logoramento: %d danni" % [time_ms, who, amount]
	return "%d ms evento sconosciuto" % time_ms
