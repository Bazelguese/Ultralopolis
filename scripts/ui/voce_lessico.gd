class_name VoceLessico
extends Resource
## Una parola chiave dei testi del gioco: come si scrive, di che colore appare e,
## se serve, che cosa vuol dire (il riquadro delle spiegazioni accanto ai suggerimenti).
## Solo presentazione: non cambia nessuna regola.

## Famiglie di parole (scelte di Davide, 8 novembre): ognuna ha una tinta di base,
## ma ogni parola può avere un colore proprio. Le nuove famiglie vanno in fondo,
## così i numeri già scritti nei dati non cambiano.
enum Famiglia { RISORSA, BATTAGLIA, MANA, TIPO, POSITIVO, NEGATIVO, CONSIGLIO, CRESCITA, PLANCIA, COSTO }

## Nome mostrato nel riquadro delle spiegazioni (es. "Scudo").
@export var nome: String = ""
@export var famiglia: Famiglia = Famiglia.BATTAGLIA
## Le forme in cui la parola compare nei testi (es. "scudo", "scudi").
## Una forma scritta in minuscolo vale anche con l'iniziale maiuscola; una forma con
## l'iniziale maiuscola vale solo così (così "Oro" non colora "dell'oro").
@export var forme: PackedStringArray = PackedStringArray()
@export var colore: Color = Color.WHITE
@export var grassetto: bool = true
## Simbolo davanti alla parola: lo stesso delle carte (GDD §14.4), cioè il nome di un file di
## assets/icone (es. &"danno", &"oro"). Vuoto: nessun simbolo.
@export var simbolo: StringName = &""
## I simboli sono bianchi come sulle carte; solo le gemme del mana prendono il colore della parola.
@export var simbolo_colorato: bool = false
## Parola di base (Mana, Danno, Scudo…): la sua spiegazione compare solo se resta posto,
## dopo quelle delle parole più rare (Corruzione, Sabotaggio…). Le spiegazioni sono al massimo 4.
@export var di_base: bool = false
## Spiegazione breve, presa dal GDD. Vuota: la parola si colora ma non si spiega.
@export_multiline var definizione: String = ""
