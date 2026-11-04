# ULTRALOPOLIS — Catalogo placeholder

**Versione:** bozza 1 — 4 novembre 2026
**Riferimento:** Game Design Document v0.15 (`docs/Ultralopolis_GDD.md`)
**Stato:** **tutto placeholder.** Nomi, numeri ed effetti servono a provare le regole, non sono bilanciamento approvato. Questo catalogo **non è ancora nel gioco**: i file dati (`data/catalog/`) contengono la versione precedente e verranno aggiornati quando si deciderà di implementarlo.

Il GDD resta la fonte di verità per le regole. Questo documento contiene solo **contenuti**; dove un contenuto richiederebbe una regola nuova è segnalato in §7.

---

## 1. Regola di budget

Ogni elemento ha un valore in **punti** che dipende dalla sua era. Gli effetti costano punti. Così i numeri restano placeholder ma coerenti fra loro: per ritoccare il bilanciamento basta cambiare i valori di questa sezione.

### 1.1 Moltiplicatore d’era

| Era | Moltiplicatore | Budget di un edificio | Costo in Oro (edifici e truppe) |
|---|---:|---:|---:|
| 1 | ×1 | 4 punti | 4 |
| 2 | ×1,5 | 6 punti | 7 |
| 3 | ×2 | 8 punti | 10 |

Il moltiplicatore cresce con l’era: è il principio P2a (gli effetti più forti nelle ere avanzate).

### 1.2 Valore degli effetti

| Effetto | Punti |
|---|---:|
| Danno | 1 per punto |
| Scudo | 1 per punto |
| Cura | 1 per punto |
| Corruzione | 1,5 per punto (ignora lo scudo) |
| Danno agli scudi (solo Assedio) | 0,5 per punto (colpisce solo lo scudo) |
| Inefficienza | 1 per secondo |
| Sabotaggio | 2 per secondo |

### 1.3 Truppe

**Budget di un’attivazione = moltiplicatore d’era × (ricarica in secondi + 1,5 × mana richiesto)**, arrotondato per difetto.

Il budget si spende in effetti (§1.2). Una truppa lenta o costosa in mana fa di più a ogni attivazione; una truppa senza mana è economica da far funzionare ma vale poco.

Esempio: Frombolieri, era 1, ricarica 2 s, 3 mana → 1 × (2 + 4,5) = 6,5 → **6 punti** → 6 di danno.

**Cibo:** 0,5 per tutte; 1 per Cavalleria e Assedio.

### 1.4 Edifici

**Punti = economia + battaglia + spazi**, entro il budget dell’era con una tolleranza di ±0,5.

| Voce | Punti |
|---|---|
| Economia, per fase | Oro 1, Ricerca 1, altre risorse 0,5 per unità |
| Battaglia, a ogni intervallo | (4 × mana + 3 × punti effetto) ÷ intervallo in secondi |
| Spazio concesso | 2 per spazio |

Esempio: Fattoria, era 1 → Oro 1 + Cibo 2 = 2 punti; 1 mana ogni 2 s = 4 ÷ 2 = 2 punti; totale **4**.

Spendere il budget in economia o in battaglia è la scelta di doppia funzione (P3).

### 1.5 Elementi esclusivi

Gli esclusivi (delle vie e dell’identità) hanno **+1 punto** di budget rispetto agli elementi base della stessa era: sono la ricompensa per aver scelto quella strada. Costano come gli altri.

### 1.6 Potenziamenti

Costi: livello 2 = 2 × era, livello 3 = 3 × era unità della risorsa di famiglia (edifici: Legno, Pietra se Difensivi; truppe: Ferro, Fauna se Cavalleria o Fauna, Fede se Sacre). Effetti: vedi §7, questione F.

### 1.7 Colori del mana

Il colore segue la famiglia (§5.3 del GDD): **rosso** Militare, Estrattivo, Difensivo; **verde** Commerciale, Agricolo, Fauna; **blu** Sapere, Sacro. Ogni era ha truppe di tutti e tre i colori, così ogni famiglia di edifici serve anche in battaglia.

---

## 2. Edifici

Legenda della colonna “In battaglia”: ciò che l’edificio produce allo scadere del suo unico intervallo (§7.4 del GDD).

### 2.1 Era 1 — budget 4, costo 4 Oro

| Edificio | Etichette | Colore | Per fase | In battaglia | Extra | Punti |
|---|---|---|---|---|---|---:|
| Fattoria | Agricolo | verde | Oro 1, Cibo 2 | 1 mana ogni 2 s | — | 4 |
| Segheria | Estrattivo | verde | Oro 1, Legno 2 | 1 mana ogni 2 s | — | 4 |
| Miniera | Estrattivo | rosso | Pietra 1, Ferro 2 | 1 mana ogni 1,5 s | — | 4,2 |
| Mercato | Commerciale | verde | Oro 2, Influenza 1 | 1 mana ogni 3 s | — | 3,8 |
| Biblioteca | Sapere | blu | Ricerca 2 | 1 mana ogni 2 s | — | 4 |
| Santuario | Sacro | blu | Fede 2 | 1 mana + 1 cura ogni 2 s | — | 4,5 |
| Caserma | Militare | rosso | Ferro 1 | 1 mana ogni 3 s | +1 spazio truppa | 3,8 |
| Palizzata | Difensivo | rosso | Pietra 1, Legno 1 | 3 scudo ogni 3 s (nessun mana) | — | 4 |

### 2.2 Era 2 — budget 6, costo 7 Oro

| Edificio | Etichette | Colore | Per fase | In battaglia | Extra | Punti |
|---|---|---|---|---|---|---:|
| Accademia | Sapere | blu | Ricerca 4 | 1 mana ogni 2 s | — | 6 |
| Bottega | Commerciale | verde | Oro 4 | 1 mana ogni 2 s | — | 6 |
| Cantiere | Estrattivo | verde | Legno 2, Pietra 2 | 1 mana ogni 2 s | +1 spazio edificio | 6 |
| Fortezza | Difensivo, Militare | rosso | Pietra 1 | 1 mana + 2 scudo ogni 3 s | +1 spazio truppa | 5,8 |
| Tempio | Sacro | blu | Fede 2 | 1 mana + 2 cura ogni 2 s | — | 6 |
| Stalle | Fauna, Agricolo | verde | Cibo 1, Fauna 3 | 1 mana ogni 1 s | — | 6 |
| Consolato | Commerciale | blu | Oro 2, Influenza 3 | 1 mana ogni 1,5 s | — | 6,2 |
| Loggia segreta | Sapere | blu | Ricerca 1, Influenza 1 | 1 mana + 2 Corruzione ogni 3 s | — | 5,8 |

### 2.3 Era 3 — budget 8, costo 10 Oro

| Edificio | Etichette | Colore | Per fase | In battaglia | Extra | Punti |
|---|---|---|---|---|---|---:|
| Università | Sapere | blu | Ricerca 6 | 1 mana ogni 2 s | — | 8 |
| Banca | Commerciale | verde | Oro 5, Influenza 1 | 1 mana ogni 1,5 s | — | 8,2 |
| Cattedrale | Sacro | blu | Fede 4 | 3 mana ogni 2 s | — | 8 |
| Cittadella | Difensivo, Militare | rosso | Ferro 1 | 1 mana + 1 scudo ogni 2 s | +2 spazi truppa | 8 |
| Arsenale | Militare | rosso | Oro 1, Ferro 2 | 3 mana ogni 2 s | — | 8 |
| Bastioni | Difensivo | rosso | Pietra 2 | 7 scudo ogni 3 s (nessun mana) | — | 8 |
| Ospedale | Sapere | blu | Ricerca 1 | 1 mana + 3 cura ogni 2 s | — | 7,5 |
| Rete di informatori | Commerciale | verde | Oro 2, Influenza 3 | 1 mana + Sabotaggio 2 s (truppe) ogni 4 s | — | 7,5 |

### 2.4 Capitale

Invariata (§6.2 del GDD): 1 di ogni risorsa a ogni fase, 1 mana energetico ogni 2 s. È fuori dalla regola di budget.

---

## 3. Truppe

Legenda: “Mana” indica colore e quantità richiesti a ogni attivazione; “Effetti” è ciò che la truppa fa quando si attiva. Inefficienza e Sabotaggio indicano tra parentesi la categoria di bersaglio (§7.7 del GDD).

### 3.1 Era 1 — moltiplicatore ×1, costo 4 Oro

| Truppa | Etichette | Mana | Ricarica | Effetti | Cibo | Punti |
|---|---|---|---:|---|---:|---:|
| Milizia | Fanteria | nessuno | 2 s | Danno 2 | 0,5 | 2 |
| Lancieri | Fanteria | nessuno | 3 s | Danno 2, Scudo 1 | 0,5 | 3 |
| Arcieri | Tiratori | rosso 2 | 1,5 s | Danno 4 | 0,5 | 4 |
| Scudieri | Fanteria | rosso 2 | 2,5 s | Scudo 5 | 0,5 | 5 |
| Frombolieri | Tiratori | verde 3 | 2 s | Danno 6 | 0,5 | 6 |
| Esploratori | Cavalleria, Fauna | verde 1 | 1 s | Danno 2 | 1 | 2 |
| Erboristi | Sacro | blu 2 | 2 s | Cura 5 | 0,5 | 5 |
| Sobillatori | Fanteria | blu 2 | 3 s | Corruzione 4 | 0,5 | 6 |

### 3.2 Era 2 — moltiplicatore ×1,5, costo 7 Oro

| Truppa | Etichette | Mana | Ricarica | Effetti | Cibo | Punti |
|---|---|---|---:|---|---:|---:|
| Guardie | Fanteria | nessuno | 2,5 s | Scudo 3 | 0,5 | 3 |
| Balestrieri | Tiratori | rosso 2 | 1,5 s | Danno 6 | 0,5 | 6 |
| Arieti | Assedio | rosso 4 | 3 s | Danno agli scudi 10, Danno 8 | 1 | 13 |
| Guastatori | Fanteria | rosso 3 | 3 s | Danno 7, Inefficienza 4 s (edifici) | 0,5 | 11 |
| Cavalieri | Cavalleria, Fauna | verde 3 | 2 s | Danno 9 | 1 | 9 |
| Arcieri a cavallo | Cavalleria, Tiratori, Fauna | verde 2 | 1,5 s | Danno 4, Inefficienza 2 s (truppe) | 1 | 6 |
| Confraternita | Sacro | blu 3 | 2,5 s | Cura 6, Scudo 4 | 0,5 | 10 |
| Predicatori | Sacro | blu 3 | 3 s | Corruzione 6, Danno 2 | 0,5 | 11 |

### 3.3 Era 3 — moltiplicatore ×2, costo 10 Oro

| Truppa | Etichette | Mana | Ricarica | Effetti | Cibo | Punti |
|---|---|---|---:|---|---:|---:|
| Moschettieri | Tiratori | nessuno | 2,5 s | Danno 5 | 0,5 | 5 |
| Granatieri | Fanteria, Assedio | rosso 5 | 3 s | Danno 15, Danno agli scudi 12 | 1 | 21 |
| Catapulte | Assedio | rosso 6 | 3,5 s | Danno agli scudi 16, Danno 17 | 1 | 25 |
| Bombarde | Assedio | rosso 8 | 4 s | Danno agli scudi 12, Danno 26 | 1 | 32 |
| Corazzieri | Cavalleria, Fauna | verde 4 | 2,5 s | Danno 12, Scudo 5 | 1 | 17 |
| Spie | Fanteria | verde 4 | 4 s | Sabotaggio 4 s (truppe), Corruzione 8 | 0,5 | 20 |
| Paladini | Fanteria, Sacro | blu 4 | 2 s | Danno 10, Cura 6 | 0,5 | 16 |
| Inquisitori | Sacro | blu 4 | 3 s | Corruzione 12 | 0,5 | 18 |

### 3.4 Quando compaiono gli effetti (proposta, §7 questione B)

| Effetto | Prima era |
|---|---|
| Danno, Scudo, Cura | 1 (Confermato nel GDD per scudo e cura) |
| Corruzione | 1, debole (Sobillatori, Corruzione 4); piena dall’era 2 |
| Danno agli scudi, Inefficienza | 2 |
| Sabotaggio | 3 |

---

## 4. Vie

Pool di **4 vie per era** (se ne mostrano 3, §10.4 del GDD), più vie esclusive di certe identità. Ogni via ha **un elemento esclusivo per ogni era** dalla sua in poi. Gli esclusivi seguono la regola di §1.5.

“Favorita da” indica gli elementi dell’identità o le vie precedenti che aumentano la probabilità che la via compaia (peso +1 ciascuno, §16.3 del GDD).

### 4.1 Vie dell’era 2

| Via | Favorita da | Offerte più frequenti | Tratto permanente | Bonus immediato |
|---|---|---|---|---|
| Via del Commercio | Cultura mercantile, Popolo del delta, Repubblica | Costruttori, Mercante | +1 Oro per fase da ogni edificio Commerciale | +6 Oro |
| Via della Guerra | Cultura guerriera, Montanari, Monarchia | Reclutatori, Addestramento | Le truppe Fanteria ricaricano il 10% più in fretta | +1 spazio truppa |
| Via della Fede | Teocrazia, Culto del Sole, Antichi spiriti | Ambasciata, Fortificazioni | +1 Fede per fase da ogni edificio Sacro | +4 Fede |
| Via del Sapere | Cultura erudita, Ordine della Ragione | Studiosi | +1 Ricerca per fase da ogni edificio Sapere | +5 Ricerca |

**Esclusivi delle vie dell’era 2**

| Via | Era 2 | Era 3 |
|---|---|---|
| Commercio | **Fondaco** (edificio) | **Compagnia commerciale** (edificio) |
| Guerra | **Veterani** (truppa) | **Guardia d’élite** (truppa) |
| Fede | **Monastero** (edificio) | **Crociati** (truppa) |
| Sapere | **Osservatorio** (edificio) | **Ingegneri militari** (truppa) |

### 4.2 Vie dell’era 3

| Via | Favorita da | Offerte più frequenti | Tratto permanente | Bonus immediato |
|---|---|---|---|---|
| Via dell’Impero | Via della Guerra, Monarchia | Quartiermastro, Reclutatori | +10 Resistenza in ogni scontro | +1 spazio truppa, +1 spazio edificio |
| Via dell’Oro | Via del Commercio, Repubblica, Popolo del delta | Esattori, Mercante | Rinnovare le offerte costa 1 Oro in meno | +10 Oro |
| Via della Rivelazione | Via della Fede, Teocrazia, Culto del Sole | Ambasciata | Gli edifici Sacri producono il 10% più in fretta | +6 Fede |
| Via dell’Ombra | Via del Sapere, Ordine della Ragione, Repubblica | Studiosi, Ambasciata | Inefficienza e Sabotaggio inflitti durano 1 s in più (§7 questione D) | +5 Influenza |
| Via degli Spiriti *(esclusiva: solo con Antichi spiriti)* | Popolo delle foreste | Esattori | +1 Cibo per fase da ogni edificio Fauna o Agricolo | +4 Fauna |

**Esclusivi delle vie dell’era 3**

| Via | Era 3 |
|---|---|
| Impero | **Legione** (truppa) |
| Oro | **Borsa** (edificio) |
| Rivelazione | **Reliquiario** (edificio) |
| Ombra | **Assassini** (truppa) |
| Spiriti | **Totem degli antenati** (edificio) |

### 4.3 Schede degli esclusivi

**Edifici** (budget dell’era +1)

| Edificio | Via | Era | Etichette | Colore | Per fase | In battaglia | Punti |
|---|---|---:|---|---|---|---|---:|
| Fondaco | Commercio | 2 | Commerciale | verde | Oro 4, Influenza 1 | 1 mana ogni 1,5 s | 7,2 |
| Monastero | Fede | 2 | Sacro | blu | Fede 2, Ricerca 1 | 1 mana + 2 cura ogni 2 s | 7 |
| Osservatorio | Sapere | 2 | Sapere | blu | Ricerca 5 | 1 mana ogni 2 s | 7 |
| Compagnia commerciale | Commercio | 3 | Commerciale | verde | Oro 5 | 2 mana ogni 2 s | 9 |
| Borsa | Oro | 3 | Commerciale | verde | Oro 7 | 1 mana ogni 2 s | 9 |
| Reliquiario | Rivelazione | 3 | Sacro | blu | Fede 2 | 2 cura + 2 Corruzione ogni 2 s (nessun mana) | 8,5 |
| Totem degli antenati | Spiriti | 3 | Sacro, Fauna | verde | Fauna 2 | 2 mana + 2 scudo + 1 cura ogni 2 s | 9,5 |

**Truppe** (budget dell’era +1)

| Truppa | Via | Era | Etichette | Mana | Ricarica | Effetti | Cibo | Punti |
|---|---|---:|---|---|---:|---|---:|---:|
| Veterani | Guerra | 2 | Fanteria | rosso 3 | 2 s | Danno 7, Scudo 3 | 0,5 | 10 |
| Guardia d’élite | Guerra | 3 | Fanteria | rosso 4 | 2 s | Danno 12, Scudo 5 | 0,5 | 17 |
| Crociati | Fede | 3 | Fanteria, Sacro | blu 4 | 2,5 s | Danno 10, Cura 4, Scudo 4 | 0,5 | 18 |
| Ingegneri militari | Sapere | 3 | Assedio | rosso 5 | 3 s | Danno agli scudi 14, Danno 10, Inefficienza 5 s (edifici) | 1 | 22 |
| Legione | Impero | 3 | Fanteria | rosso 5 | 2,5 s | Danno 14, Scudo 7 | 0,5 | 21 |
| Assassini | Ombra | 3 | Fanteria | verde 4 | 3 s | Sabotaggio 4 s (truppe), Corruzione 6, Danno 2 | 0,5 | 19 |

---

## 5. Identità e perk

### 5.1 Elementi dell’identità

Popoli, governi, credi e culture restano come oggi. Cambiano solo gli esclusivi, ricalcolati con la regola di budget (era 1, +1 punto):

| Esclusivo | Identità | Oggi | Proposta | Punti |
|---|---|---|---|---:|
| Porto fluviale (edificio, Commerciale, verde) | Popolo del delta | Oro 4, Cibo 1; 1 mana ogni 3 s | Oro 2, Cibo 2; 1 mana ogni 2 s | 5 |
| Arcieri dei boschi (truppa, Tiratori, verde 2, 1,2 s) | Popolo delle foreste | Danno 4 | Danno 5 | 5 |
| Guardie delle vette (truppa, Fanteria, nessun mana, 3 s) | Montanari | Danno 6 | Danno 2, Scudo 2 (gente “dura a cedere”) | 4 |

### 5.2 Perk esistenti

Restano invariati: Allevatori, Biblioteca reale, Consiglio allargato, Contrattatori, Fabbri esperti, Mulini, Mura antiche.

### 5.3 Perk nuovi

Usano gli effetti nuovi. Disponibili alla creazione e come ricompense degli incontri del mondo.

| Perk | Effetto |
|---|---|
| Veleni sottili | Gli elementi che infliggono Corruzione ne infliggono 1 in più. |
| Erboristi di corte | Gli elementi che curano curano 1 in più. |
| Genio militare | Le truppe Assedio fanno il 25% di danno agli scudi in più. |
| Mura di pietra | Gli edifici Difensivi producono 1 scudo in più. |

---

## 6. Malus dei fantasmi

I sei malus esistenti restano (Ricerca dimezzata, Oro dimezzato, Inefficienza, Truppa provata, Mercati diffidenti, Mercanti in fuga). Se ne aggiungono sei che usano gli effetti nuovi. Seguono P1: deviano, non debilitano.

| Malus | Effetto | Spinge a… |
|---|---|---|
| Mura incrinate | Lo scudo prodotto è ridotto del 50%. | puntare su cura o attacco |
| Ferite infette | Le cure sono ridotte del 50%. | puntare su scudo o attacco |
| Semi del dissenso | Ogni scontro inizia con 5 Corruzione (§7 questione C). | curare o chiudere presto lo scontro |
| Rete compromessa | In ogni scontro un edificio a caso parte sabotato per 3 s (§7 questione C). | non dipendere da un solo edificio |
| Scorte avariate | Il Cibo prodotto è dimezzato. | comprare Cibo o tenere meno truppe |
| Diserzioni | Una truppa a caso consuma il doppio del Cibo. | rivedere l’ordine di consumo |

---

## 7. Questioni per Davide

Il catalogo funziona solo se queste questioni vengono decise. Alcune toccano regole del GDD.

| # | Questione | Proposta |
|---|---|---|
| A | Il GDD (§5.3) dice “ogni edificio produce mana di un colore”, ma dalla v0.13 un edificio può produrre solo difesa (Palizzata, Bastioni, Reliquiario). | Ogni edificio ha un **colore di famiglia** anche se produce 0 mana. Da correggere nel GDD. |
| B | In che era compaiono gli effetti (P2a)? | Tabella di §3.4: Corruzione debole dall’era 1, Assedio e Inefficienza dall’era 2, Sabotaggio dall’era 3. |
| C | Scudo e Corruzione partono da zero (§7.6 del GDD). Un malus o un perk può cambiare il valore di partenza (Semi del dissenso) o far partire un elemento sabotato (Rete compromessa)? | Sì: le regole fissano il valore di base, i modificatori possono alterarlo. |
| D | Via dell’Ombra modifica la **durata** di Inefficienza e Sabotaggio: è un bersaglio nuovo per i modificatori (§8.2 del GDD). | Ammetterlo, oppure sostituire il tratto. |
| E | Elementi spostati o tolti: Consolato e Stalle passano all’era 2 (per avere 8 edifici per era); la Cava esce dal catalogo (la Pietra arriva da Miniera, Palizzata, Cantiere, Bastioni). | Confermare o scegliere altri spostamenti. |
| F | I potenziamenti oggi danno “+50% danno per livello” (§16.3 del GDD), ma le truppe ora hanno anche scudo, cura, Corruzione… | +50% a **tutti** i valori d’effetto (durate comprese) per livello. |
| G | Numeri che cambiano molto rispetto ai dati attuali: Moschettieri da 10 a 5 di danno (erano fuori scala), costi uniformi per era (4 / 7 / 10). | Accettare come effetto della regola di budget. |
| H | Dimensioni ipotizzate: pool di 4 vie per era più le esclusive; 1 elemento esclusivo per via e per era; esclusivi +1 punto. | Confermare. |

---

## 8. Riepilogo dei numeri

| | Era 1 | Era 2 | Era 3 | Totale |
|---|---:|---:|---:|---:|
| Edifici base | 8 | 8 | 8 | 24 |
| Truppe base | 8 | 8 | 8 | 24 |
| Vie | — | 4 | 4 + 1 esclusiva | 9 |
| Esclusivi delle vie | — | 4 | 9 | 13 |
| Esclusivi dell’identità | 3 | — | — | 3 |
| Perk | 11 (7 esistenti + 4 nuovi) | | | 11 |
| Malus | 12 (6 esistenti + 6 nuovi) | | | 12 |
