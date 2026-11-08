class_name Lessico
extends Resource
## Le parole chiave che i testi del gioco colorano da sole (come in The Bazaar),
## con le loro spiegazioni. I dati stanno in data/ui/lessico.tres: per cambiare un colore,
## aggiungere una parola o correggere una spiegazione non serve toccare il codice.
## Solo presentazione.

@export var voci: Array[VoceLessico] = []
## Numeri, percentuali e secondi (es. +2, 25%, 10 s).
@export var colore_numeri: Color = Color.WHITE
@export var numeri_in_grassetto: bool = true
## Un numero seguito da una parola chiave (es. "+3 scudo") prende il colore della parola.
@export var numeri_col_colore_della_parola: bool = true
## Simboli delle carte davanti alle parole che ne hanno uno (scelta di Davide, 8 novembre).
@export var simboli_nel_testo: bool = true
## Quante spiegazioni al massimo compaiono accanto a un suggerimento.
@export var massimo_spiegazioni: int = 4
