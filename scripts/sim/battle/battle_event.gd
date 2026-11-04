class_name BattleEvent
extends RefCounted
## Un fatto accaduto in battaglia, registrato per la presentazione e per spiegare
## lo scontro al giocatore (principio P4).

enum Kind {
	MANA_PRODOTTO,     ## Un edificio ha prodotto mana.
	ATTIVAZIONE,       ## Una truppa si è attivata e ha inflitto danno.
	IN_ATTESA_MANA,    ## Una truppa è pronta ma non c'è abbastanza mana.
	LOGORAMENTO,       ## Il logoramento ha colpito questa nazione.
	SCUDO,             ## Scudo aggiunto alla riserva di questa nazione.
	CURA,              ## Resistenza recuperata da questa nazione.
	CORRUZIONE,        ## Corruzione inflitta a questa nazione.
	ASSEDIO,           ## Scudo tolto a questa nazione da un attacco d'assedio.
	RALLENTATO,        ## Un elemento di questa nazione è stato rallentato (index: 0+ edificio, 1000+ truppa).
	SABOTATO,          ## Un elemento di questa nazione è stato sabotato (index come sopra).
	IN_SABOTAGGIO,     ## Una truppa pronta non si attiva perché sabotata.
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
		Kind.SCUDO:
			return "%d ms [%s] +%d scudo" % [time_ms, who, amount]
		Kind.CURA:
			return "%d ms [%s] cura %d" % [time_ms, who, amount]
		Kind.CORRUZIONE:
			return "%d ms [%s] subisce %d Corruzione" % [time_ms, who, amount]
		Kind.ASSEDIO:
			return "%d ms [%s] perde %d scudo per l'assedio" % [time_ms, who, amount]
		Kind.RALLENTATO:
			return "%d ms [%s] elemento %d rallentato per %d ms" % [time_ms, who, index, amount]
		Kind.SABOTATO:
			return "%d ms [%s] elemento %d sabotato per %d ms" % [time_ms, who, index, amount]
		Kind.IN_SABOTAGGIO:
			return "%d ms [%s] truppa %d sabotata, non si attiva" % [time_ms, who, index]
	return "%d ms evento sconosciuto" % time_ms
