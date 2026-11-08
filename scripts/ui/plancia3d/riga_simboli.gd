class_name RigaSimboli
extends RefCounted
## Una riga di simboli su una carta, come nei giochi da tavolo: per esempio
## "2 [Stabilità] → 4 [Oro]" oppure "[anno] 1: +50% [Oro] / +50% [Ricerca]".
## Ogni riga è una cosa che la carta può fare; si legge da sinistra a destra.
## Solo presentazione: viene costruita dai dati del gioco (SimboliEffetti).

## Come si colora una voce della riga.
enum Tono {
	NORMALE,     ## Bianco.
	COSTO,       ## Quello che si paga: numero dorato.
	BONUS,       ## Un guadagno o un miglioramento: numero verde chiaro.
	MALUS,       ## Un peggioramento: numero rosso.
	SEPARATORE,  ## Freccia "→", barra "/" e simili: tenue.
}


## Una voce della riga: un numero o una scritta breve, seguiti da un simbolo o da una gemma di mana.
class Simbolo:
	extends RefCounted
	## Concetto del simbolo (nome del file in assets/icone), es. &"oro". Vuoto = solo testo.
	var icona: StringName = &""
	## Testo prima del simbolo, es. "2", "+50%", "−1"; oppure tutta la voce se non c'è simbolo.
	var testo: String = ""
	## Colore del mana, se la voce è una gemma (&"rosso", ...). &"qualsiasi" = gemma grigia.
	var gemma: StringName = &""
	var tono: RigaSimboli.Tono = RigaSimboli.Tono.NORMALE
	## Il simbolo sta in una cornice tratteggiata: uno spazio vuoto della plancia.
	var spazio: bool = false
	## Il simbolo ha una piccola freccia in su: si potenzia (sale di livello).
	var su: bool = false


## Le voci, da sinistra a destra.
var simboli: Array[Simbolo] = []
## Nome di ciò che la riga rappresenta (es. "Esattori"): serve al riquadro dei dettagli.
var etichetta: String = ""
## La riga non si può usare adesso (es. opzione con un requisito mancante): appare spenta.
var spenta: bool = false
## Quanto conta la riga sulla carta: decide il fondo della pastiglia (gerarchia, richiesta di Davide).
enum Rilievo {
	NORMALE,     ## Fondo scuro: un'azione, un'opzione.
	PRINCIPALE,  ## Fondo del colore della carta: ciò che il consigliere propone nel round.
	SECONDARIA,  ## Solo un bordo sottile, più bassa, sempre su una linea sua: un extra (Potenzia).
}

var rilievo: Rilievo = Rilievo.NORMALE
## La riga si può già usare con vantaggio (es. Potenzia, con carte potenziabili): fondo dorato.
var accesa: bool = false


func vuota() -> bool:
	return simboli.is_empty()


## Aggiunge un simbolo con un testo davanti (es. "3" e &"oro") e restituisce la riga.
func icona(concetto: StringName, testo: String = "", tono: Tono = Tono.NORMALE) -> RigaSimboli:
	var voce: Simbolo = Simbolo.new()
	voce.icona = concetto
	voce.testo = testo
	voce.tono = tono
	simboli.append(voce)
	return self


## Aggiunge una scritta breve senza simbolo (es. "→", "/", "5 s").
func scritta(testo: String, tono: Tono = Tono.SEPARATORE) -> RigaSimboli:
	var voce: Simbolo = Simbolo.new()
	voce.testo = testo
	voce.tono = tono
	simboli.append(voce)
	return self


## Aggiunge una gemma di mana del colore indicato, con un numero davanti.
func gemma(colore: StringName, testo: String = "", tono: Tono = Tono.NORMALE) -> RigaSimboli:
	var voce: Simbolo = Simbolo.new()
	voce.gemma = colore
	voce.testo = testo
	voce.tono = tono
	simboli.append(voce)
	return self


## Aggiunge uno spazio vuoto della plancia (edificio o truppa), con un numero davanti.
func spazio(concetto: StringName, testo: String = "", tono: Tono = Tono.BONUS) -> RigaSimboli:
	icona(concetto, testo, tono)
	simboli[simboli.size() - 1].spazio = true
	return self


## Aggiunge un simbolo con la freccia del potenziamento (la carta sale di un livello).
func potenziata(concetto: StringName, testo: String = "") -> RigaSimboli:
	icona(concetto, testo, Tono.BONUS)
	simboli[simboli.size() - 1].su = true
	return self


## Accoda tutte le voci di un'altra riga.
func accoda(altra: RigaSimboli) -> RigaSimboli:
	simboli.append_array(altra.simboli)
	return self


## Testo semplice della riga, utile per i test e per controllare che cosa mostra la carta.
## Es. "2[stabilita] → 4[oro]".
func come_testo() -> String:
	var parti: PackedStringArray = PackedStringArray()
	for voce: Simbolo in simboli:
		var parte: String = voce.testo
		if voce.icona != &"":
			parte += "[%s%s%s]" % ["spazio " if voce.spazio else "", String(voce.icona), "↑" if voce.su else ""]
		elif voce.gemma != &"":
			parte += "[gemma %s]" % voce.gemma
		parti.append(parte)
	return " ".join(parti)
