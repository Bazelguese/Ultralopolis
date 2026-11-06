class_name ChronicleDef
extends EventDef
## Una cronaca della nazione (GDD §9.6, v0.29): una scena che arriva da sola all'inizio di una
## stagione, costruita su quello che il giocatore ha fatto. Usa i campi dell'evento (radici,
## stagioni = momento, opzioni) e aggiunge le condizioni che la rendono personale.
## Nei testi: {nazione}, {anno}, {momento}, {razza}, {governo}, {credo}, {nemico}, {personaggio},
## {ruolo}, {vocazione} diventano i nomi della run.

## Esito dell'ultimo scontro richiesto dalla cronaca.
enum LastBattle {
	QUALSIASI,
	VINTO,
	PERSO,
}

@export_group("Condizioni della cronaca")
## Anno minimo (0 = nessun limite).
@export var min_year: int = 0
## Con requires_types: almeno tante carte sulla plancia con uno di quei tipi (0 = basta una).
@export var min_type_count: int = 0
## Scontri vinti di fila (0 = nessun limite).
@export var min_win_streak: int = 0
## Esito dell'ultimo scontro (incontro o fantasma).
@export var last_battle: LastBattle = LastBattle.QUALSIASI
## Ricordi della nazione richiesti (tutti) o vietati (nessuno): le catene di cronache.
@export var requires_flags: Array[StringName] = []
@export var forbids_flags: Array[StringName] = []
## Inclinazione richiesta: asse (Inclination.Axis, -1 = nessuna), polo (+1 o -1) e passi minimi
## verso quel polo.
@export var inclination_axis: int = -1
@export var inclination_pole: int = 1
@export var inclination_steps: int = 1
## Personaggio che deve essere presente, con la sua fiducia fra questi due valori.
@export var requires_character: CharacterDef
@export var min_affinity: int = -99
@export var max_affinity: int = 99
