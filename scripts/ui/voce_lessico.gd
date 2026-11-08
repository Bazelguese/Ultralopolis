class_name VoceLessico
extends Resource
## Una parola chiave dei testi del gioco: come si scrive, di che colore appare e,
## se serve, che cosa vuol dire (il riquadro delle spiegazioni accanto ai suggerimenti).
## Solo presentazione: non cambia nessuna regola.

## Famiglie di parole (scelte di Davide, 8 novembre): ognuna ha una tinta di base,
## ma ogni parola può avere un colore proprio. Le nuove famiglie vanno in fondo,
## così i numeri già scritti nei dati non cambiano.
enum Famiglia { RISORSA, BATTAGLIA, MANA, TIPO, POSITIVO, NEGATIVO, CONSIGLIO, CRESCITA, PLANCIA }

## Nome mostrato nel riquadro delle spiegazioni (es. "Scudo").
@export var nome: String = ""
@export var famiglia: Famiglia = Famiglia.BATTAGLIA
## Le forme in cui la parola compare nei testi (es. "scudo", "scudi").
## Una forma scritta in minuscolo vale anche con l'iniziale maiuscola; una forma con
## l'iniziale maiuscola vale solo così (così "Oro" non colora "dell'oro").
@export var forme: PackedStringArray = PackedStringArray()
@export var colore: Color = Color.WHITE
@export var grassetto: bool = true
## Simbolo davanti alla parola, lo stesso disegnato sulle carte (spada, scudo, clessidra…).
## Un'immagine bianca: nel testo prende il colore della parola. Vuoto: nessun simbolo.
@export var icona: Texture2D = null
## Spiegazione breve, presa dal GDD. Vuota: la parola si colora ma non si spiega.
@export_multiline var definizione: String = ""
