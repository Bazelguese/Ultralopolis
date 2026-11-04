class_name DatiEsempioPlancia
extends RefCounted
## Contenuti di ESEMPIO per la prova visiva della plancia 3D.
## Non sono regole né bilanciamento: servono solo a riempire la scena.
## I colori del mana sono inventati: nei dati del gioco arriveranno con la v0.12 del GDD.
## Quando la v0.12 sarà nel codice, la prova leggerà il catalogo vero al posto di questo file.

## Come si comporta una truppa nel copione dimostrativo della battaglia.
enum Copione { SI_ATTIVA, ASPETTA_MANA }

class Pezzo:
	var nome: String = ""
	var etichetta: String = ""
	var mana: int = StileCronaca.Mana.NESSUNO
	## Costo in mana (truppe) oppure mana prodotto (edifici).
	var mana_numero: int = 0
	## Riga breve stampata sulla tessera.
	var riga: String = ""
	## Testo completo mostrato passando il mouse.
	var dettagli: String = ""
	## Secondi fra due attivazioni (truppe) o fra due produzioni di mana (edifici).
	var ritmo_s: float = 2.0
	var livello: int = 1
	var malus: String = ""
	var copione: int = Copione.SI_ATTIVA
	var danno: int = 0
	## Solo per le offerte.
	var tipo_offerta: String = ""
	var costo: String = ""

	func _init(p_nome: String, p_etichetta: String, p_mana: int, p_mana_numero: int, p_riga: String, p_ritmo_s: float) -> void:
		nome = p_nome
		etichetta = p_etichetta
		mana = p_mana
		mana_numero = p_mana_numero
		riga = p_riga
		ritmo_s = p_ritmo_s


static func truppe_giocatore() -> Array[Pezzo]:
	var lancieri: Pezzo = Pezzo.new("Lancieri", "Fanteria", StileCronaca.Mana.NESSUNO, 0, "4 danni · 3 s", 3.0)
	lancieri.danno = 4
	lancieri.dettagli = "Senza mana: agiscono appena finiscono di ricaricare.\n4 danni · ricarica 3 s · mangiano 0,5 Cibo"
	var frombolieri: Pezzo = Pezzo.new("Frombolieri", "Tiratori", StileCronaca.Mana.ROSSO, 3, "7 danni · 2 s", 2.0)
	frombolieri.danno = 7
	frombolieri.copione = Copione.ASPETTA_MANA
	frombolieri.dettagli = "Costano 3 mana rosso, poi energetico se il rosso manca.\n7 danni · ricarica 2 s · mangiano 0,5 Cibo"
	var milizia: Pezzo = Pezzo.new("Milizia", "Fanteria", StileCronaca.Mana.NESSUNO, 0, "3 danni · 2 s", 2.0)
	milizia.danno = 3
	milizia.livello = 2
	milizia.dettagli = "Livello II: 3 danni invece di 2.\nSenza mana · ricarica 2 s · mangia 0,5 Cibo"
	var arcieri: Pezzo = Pezzo.new("Arcieri", "Tiratori", StileCronaca.Mana.ROSSO, 2, "4 danni · 1,5 s", 1.5)
	arcieri.danno = 4
	arcieri.dettagli = "Costano 2 mana rosso, poi energetico se il rosso manca.\n4 danni · ricarica 1,5 s · mangiano 0,5 Cibo"
	return [lancieri, frombolieri, milizia, arcieri]


static func edifici_giocatore() -> Array[Pezzo]:
	var capitale: Pezzo = Pezzo.new("Capitale", "Capitale", StileCronaca.Mana.ENERGETICO, 1, "1 di ogni risorsa", 3.0)
	capitale.dettagli = "Produce 1 di ogni risorsa a ogni fase.\nIn battaglia: 1 mana energetico ogni 3 s, vale come qualsiasi colore.\nNon si può vendere."
	var fattoria: Pezzo = Pezzo.new("Fattoria", "Agricolo", StileCronaca.Mana.VERDE, 1, "+3 Oro · +2 Cibo", 3.0)
	fattoria.malus = "Inefficienza"
	fattoria.dettagli = "+3 Oro e +2 Cibo a ogni fase.\nIn battaglia: 1 verde ogni 3 s invece di 2 s.\nInefficienza, inflitta dalla Contea di Rocca Bruna: ancora 1 anno."
	var biblioteca: Pezzo = Pezzo.new("Biblioteca", "Sapere", StileCronaca.Mana.BLU, 1, "+2 Ricerca", 3.0)
	biblioteca.dettagli = "+2 Ricerca a ogni fase.\nIn battaglia: 1 blu ogni 3 s."
	var caserma: Pezzo = Pezzo.new("Caserma", "Militare", StileCronaca.Mana.ROSSO, 1, "+1 spazio truppa", 4.0)
	caserma.dettagli = "+1 Oro a ogni fase e uno spazio truppa in più.\nIn battaglia: 1 rosso ogni 4 s."
	return [capitale, fattoria, biblioteca, caserma]


static func truppe_fantasma() -> Array[Pezzo]:
	var milizia: Pezzo = Pezzo.new("Milizia", "Fanteria", StileCronaca.Mana.NESSUNO, 0, "2 danni · 2 s", 2.0)
	milizia.danno = 2
	milizia.dettagli = "Senza mana · 2 danni · ricarica 2 s"
	var arcieri: Pezzo = Pezzo.new("Arcieri", "Tiratori", StileCronaca.Mana.ROSSO, 2, "4 danni · 1,5 s", 1.5)
	arcieri.danno = 4
	arcieri.dettagli = "Costano 2 mana rosso · 4 danni · ricarica 1,5 s"
	var cavalieri: Pezzo = Pezzo.new("Cavalieri", "Cavalleria", StileCronaca.Mana.ROSSO, 3, "9 danni · 2 s", 2.5)
	cavalieri.danno = 9
	cavalieri.dettagli = "Costano 3 mana rosso · 9 danni · ricarica 2 s"
	return [milizia, arcieri, cavalieri]


static func edifici_fantasma() -> Array[Pezzo]:
	var capitale: Pezzo = Pezzo.new("Capitale", "Capitale", StileCronaca.Mana.ENERGETICO, 1, "1 di ogni risorsa", 3.0)
	capitale.dettagli = "1 mana energetico ogni 3 s"
	var fattoria: Pezzo = Pezzo.new("Fattoria", "Agricolo", StileCronaca.Mana.VERDE, 1, "+3 Oro · +2 Cibo", 2.0)
	fattoria.dettagli = "1 verde ogni 2 s"
	var santuario: Pezzo = Pezzo.new("Santuario", "Sacro", StileCronaca.Mana.BLU, 2, "+1 Fede", 2.0)
	santuario.dettagli = "2 blu ogni 2 s"
	var tempio: Pezzo = Pezzo.new("Tempio", "Sacro", StileCronaca.Mana.ROSSO, 2, "+1 Oro · +1 Fede", 2.0)
	tempio.dettagli = "2 rosso ogni 2 s"
	var bottega: Pezzo = Pezzo.new("Bottega", "Commerciale", StileCronaca.Mana.VERDE, 1, "+5 Oro", 2.5)
	bottega.dettagli = "1 verde ogni 2,5 s"
	return [capitale, fattoria, santuario, tempio, bottega]


static func offerte() -> Array[Pezzo]:
	var mercato: Pezzo = Pezzo.new("Mercato", "Commerciale", StileCronaca.Mana.VERDE, 1, "+3 Oro · +1 Influenza", 3.0)
	mercato.tipo_offerta = "Costruttori"
	mercato.costo = "5 Oro"
	mercato.dettagli = "Costruisci un Mercato: +3 Oro e +1 Influenza a ogni fase.\nIn battaglia: 1 verde ogni 3 s."
	var studiosi: Pezzo = Pezzo.new("Studiosi", "Risorse", StileCronaca.Mana.NESSUNO, 0, "3 Oro → 3 Ricerca", 0.0)
	studiosi.tipo_offerta = "Studiosi"
	studiosi.costo = "3 Oro"
	studiosi.dettagli = "Paghi 3 Oro e ottieni subito 3 Ricerca.\nCon 10 Ricerca potresti entrare nell'era dello Sviluppo."
	var assemblea: Pezzo = Pezzo.new("Assemblea", "Per un anno", StileCronaca.Mana.NESSUNO, 0, "+50% Oro o Ricerca", 0.0)
	assemblea.tipo_offerta = "Assemblea"
	assemblea.costo = "Gratis"
	assemblea.dettagli = "Per un anno, a tua scelta: +50% Oro oppure +50% Ricerca."
	return [mercato, studiosi, assemblea]
