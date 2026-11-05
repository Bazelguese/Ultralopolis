# ULTRALOPOLIS — Catalogo placeholder

**Versione:** bozza 5 — 5 novembre 2026 (tecnologie, §6 quater)
**Riferimento:** Game Design Document v0.22 (`docs/Ultralopolis_GDD.md`)
**Stato:** **tutto placeholder.** Nomi, numeri ed effetti servono a provare le regole, non sono bilanciamento approvato. Dalla v0.18 del GDD questo catalogo **è nel gioco**: i file dati sono in `data/catalog/` (edifici, truppe, `consiglieri/`, `opportunities/` per le azioni, `vie/`, `perk/`, `modifiers/`) e si modificano dall’Ispettore di Godot.

**Bozza 4 (GDD v0.22):** le etichette diventano **tipi** (1–2 per carta), i colori del mana sono **quattro** (viola nuovo), le risorse cambiano (via la Fauna, nuove **Stabilità** e **Documenti**), i potenziamenti si fanno con l’opzione **Potenzia** del Consiglio. Il Consiglio è in §6 bis.

Il GDD resta la fonte di verità per le regole. Questo documento contiene solo **contenuti**; dove un contenuto richiederebbe una regola nuova è segnalato in §7.

---

## 1. Regola di budget

Ogni elemento ha un valore in **punti** che dipende dalla sua era. Gli effetti costano punti. Così i numeri restano placeholder ma coerenti fra loro: per ritoccare il bilanciamento basta cambiare i valori di questa sezione.

### 1.1 Moltiplicatore d’era

| Era | Moltiplicatore | Budget di un edificio | Costo base in Oro (edifici e truppe) |
|---|---:|---:|---:|
| 1 | ×1 | 4 punti | 4 |
| 2 | ×1,5 | 6 punti | 7 |
| 3 | ×2 | 8 punti | 10 |

Il moltiplicatore cresce con l’era: è il principio P2a (gli effetti più forti nelle ere avanzate).

**Costi variabili.** Un elemento può costare 1 Oro in più o in meno del costo base della sua era; ogni Oro in più o in meno vale **±1 punto** di budget. Elementi che si discostano dal costo base:

| Elemento | Era | Costo | Budget |
|---|---:|---:|---|
| Fattoria | 1 | 3 | −1 |
| Mercato | 1 | 5 | +1 |
| Santuario | 1 | 5 | +1 |
| Lancieri | 1 | 3 | −1 |
| Frombolieri | 1 | 5 | +1 |
| Guardie | 2 | 6 | −1 |
| Cavalieri | 2 | 8 | +1 |
| Banca | 3 | 11 | +1 |
| Cattedrale | 3 | 11 | +1 |
| Moschettieri | 3 | 9 | −1 |
| Bombarde | 3 | 11 | +1 |

Nelle tabelle seguenti la colonna “Punti” tiene già conto di queste variazioni.

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

**Cibo:** 0,5 per tutte; 1 per le truppe a cavallo (Esploratori, Cavalieri, Arcieri a cavallo, Corazzieri) e per le truppe Assedio.

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

Si potenzia con l’opzione **Potenzia** del consigliere scelto (GDD §6.5, v0.22): la carta deve avere almeno un tipo della sua categoria. Costi: livello 2 = 2 × era della carta, livello 3 = 3 × era unità della **risorsa della categoria** (GDD §4.2.4). Il Maestro delle spie chiede la stessa quantità di Oro e della sua risorsa casuale; l’Anziano chiede Oro. I valori stanno nelle regole della run (`upgrade_cost_per_era`).

Effetti (GDD §6.5): ogni livello dà **+50% a tutti i valori d’effetto**, durate comprese, arrotondato per difetto; gli edifici anche +1 a ogni risorsa per fase. Il mana prodotto non cambia.

### 1.7 Colori del mana

Quattro colori (GDD §5.3, v0.22). Il colore non dipende dai tipi: è una **tendenza** per scrivere il catalogo, legata alle categorie dei consiglieri: **rosso** Militare e Opera; **verde** Terra e Ricchezza; **blu** Fede e Stato; **viola** Conoscenza e Ombra. Ogni era ha truppe di tutti e quattro i colori, così ogni colore di edificio serve anche in battaglia. Le eccezioni sono volute: per esempio Segheria e Cantiere sono verdi, i tiratori mercenari (Frombolieri, Balestrieri, Moschettieri) verdi, l’Università blu.

Un edificio **senza mana è neutro**: non ha colore (§5.3 del GDD). Come ogni altro edificio può essere disponibile a tutti (Palizzata, Bastioni) oppure esclusivo di certe nazioni (Reliquiario).

---

## 2. Edifici

Legenda della colonna “In battaglia”: ciò che l’edificio produce allo scadere del suo unico intervallo (§7.4 del GDD).

### 2.1 Era 1 — budget 4, costo base 4 Oro (14 edifici)

| Edificio | Tipi | Colore | Per fase | In battaglia | Extra | Punti |
|---|---|---|---|---|---|---:|
| Fattoria | Produzione | verde | Oro 1, Cibo 2 | 1 mana ogni 4 s | — | 3 |
| Segheria | Produzione | verde | Oro 1, Legno 2 | 1 mana ogni 2 s | — | 4 |
| Miniera | Produzione | rosso | Pietra 1, Ferro 2 | 1 mana ogni 1,5 s | — | 4,2 |
| Mercato | Economico | verde | Oro 2, Influenza 1 | 1 mana ogni 1,5 s | — | 5,2 |
| Biblioteca | Accademico | viola | Ricerca 1, Documenti 2 | 1 mana ogni 2 s | — | 4 |
| Santuario | Spirituale | blu | Fede 2 | 1 mana + 1 cura ogni 2 s | — | 4,5 |
| Caserma | Infrastruttura Bellica | rosso | Ferro 1 | 1 mana ogni 3 s | +1 spazio truppa | 3,8 |
| Palizzata | Guardiano | **neutro** | Legno 1, Pietra 1 | 3 scudo ogni 3 s (nessun mana) | — | 4 |
| Cava | Produzione | rosso | Pietra 3 | 1 mana ogni 1,5 s | — | 4,2 |
| Consolato | Nobile, Legge | blu | Oro 1, Stabilità 2 | 1 mana ogni 2 s | — | 4 |
| Stalle | Fauna, Produzione | verde | Cibo 2, Legno 1 | 1 mana ogni 1,5 s | — | 4,2 |
| Tribunale *(nuovo, bozza 4)* | Legge | blu | Oro 1, Stabilità 2 | 1 mana ogni 2 s | — | 4 |
| Covo *(nuovo, bozza 4)* | Criminale, Infrastruttura Segreta | viola | Influenza 1, Documenti 1 | 1 mana + 1 Corruzione ogni 3 s | — | 3,8 |
| Armeria *(nuova, bozza 4)* | Infrastruttura Bellica | rosso | Ferro 2 | 1 mana ogni 1,5 s | — | 3,7 |

### 2.2 Era 2 — budget 6, costo base 7 Oro

| Edificio | Tipi | Colore | Per fase | In battaglia | Extra | Punti |
|---|---|---|---|---|---|---:|
| Accademia | Accademico | viola | Ricerca 3, Documenti 2 | 1 mana ogni 2 s | — | 6 |
| Bottega | Economico | verde | Oro 4 | 1 mana ogni 2 s | — | 6 |
| Cantiere | Produzione, Infrastruttura Strategica | verde | Legno 2, Pietra 2 | 1 mana ogni 2 s | +1 spazio edificio | 6 |
| Fortezza | Infrastruttura Bellica | rosso | Pietra 1 | 1 mana + 2 scudo ogni 3 s | +1 spazio truppa | 5,8 |
| Tempio | Spirituale | blu | Fede 2 | 1 mana + 2 cura ogni 2 s | — | 6 |
| Granaio | Produzione, Economico | verde | Oro 1, Cibo 4 | 1 mana ogni 1,5 s | — | 5,7 |
| Fonderia | Produzione | rosso | Oro 1, Ferro 3 | 1 mana ogni 1 s | — | 6,5 |
| Loggia segreta | Infrastruttura Segreta, Criminale | viola | Influenza 1, Documenti 2 | 1 mana + 2 Corruzione ogni 3 s | — | 5,8 |
| Prefettura *(nuova, bozza 4)* | Legge, Patriota | blu | Oro 2, Stabilità 2 | 1 mana + 1 scudo ogni 2 s | — | 6,5 |
| Mercato nero *(nuovo, bozza 4)* | Criminale, Infrastruttura Strategica | viola | Oro 2, Influenza 2 | 1 mana ogni 1,5 s | — | 5,7 |
| Campo d’addestramento *(nuovo, bozza 4)* | Infrastruttura Bellica | rosso | Oro 1, Ferro 2 | 1 mana ogni 1 s | — | 6 |
| Torre di guardia *(nuova, bozza 4)* | Guardiano | **neutro** | Pietra 2 | 5 scudo ogni 3 s (nessun mana) | — | 6 |

### 2.3 Era 3 — budget 8, costo base 10 Oro

| Edificio | Tipi | Colore | Per fase | In battaglia | Extra | Punti |
|---|---|---|---|---|---|---:|
| Università | Accademico | blu | Ricerca 5, Stabilità 2 | 1 mana ogni 2 s | — | 8 |
| Banca | Economico, Nobile | verde | Oro 6, Influenza 1 | 1 mana ogni 1,5 s | — | 9,2 |
| Cattedrale | Spirituale | blu | Oro 1, Fede 4 | 3 mana ogni 2 s | — | 9 |
| Cittadella | Infrastruttura Bellica | rosso | Ferro 1 | 1 mana + 1 scudo ogni 2 s | +2 spazi truppa | 8 |
| Arsenale | Infrastruttura Bellica | rosso | Oro 1, Ferro 2 | 3 mana ogni 2 s | — | 8 |
| Bastioni | Guardiano | **neutro** | Pietra 2 | 7 scudo ogni 3 s (nessun mana) | — | 8 |
| Ospedale | Spirituale | blu | Ricerca 1 | 1 mana + 3 cura ogni 2 s | — | 7,5 |
| Rete di informatori | Infrastruttura Segreta, Criminale | viola | Oro 2, Influenza 1, Documenti 2 | 1 mana + Sabotaggio 2 s (truppe) ogni 4 s | — | 7,5 |
| Palazzo del governo *(nuovo, bozza 4)* | Nobile, Legge | blu | Oro 2, Influenza 1, Stabilità 3 | 2 mana ogni 2 s | — | 8 |
| Arsenale clandestino *(nuovo, bozza 4)* | Infrastruttura Bellica, Criminale | viola | Oro 1, Ferro 2, Documenti 2 | 2 mana + Sabotaggio 2 s (truppe) ogni 4 s | — | 8 |
| Acciaieria *(nuova, bozza 4)* | Produzione | rosso | Oro 1, Pietra 2, Ferro 4 | 2 mana ogni 2 s | — | 8 |

### 2.4 Capitale

Invariata (§6.2 del GDD): 1 di ogni risorsa a ogni fase, 1 mana energetico ogni 2 s. È fuori dalla regola di budget.

---

## 3. Truppe

Legenda: “Mana” indica colore e quantità richiesti a ogni attivazione; “Effetti” è ciò che la truppa fa quando si attiva. Inefficienza e Sabotaggio indicano tra parentesi la categoria di bersaglio (§7.7 del GDD).

### 3.1 Era 1 — moltiplicatore ×1, costo base 4 Oro

| Truppa | Tipi | Mana | Ricarica | Effetti | Cibo | Punti |
|---|---|---|---:|---|---:|---:|
| Milizia | Fante, Patriota | nessuno | 2 s | Danno 2 | 0,5 | 2 |
| Lancieri | Fante | nessuno | 3 s | Danno 1, Scudo 1 | 0,5 | 2 |
| Arcieri | Fante | rosso 2 | 1,5 s | Danno 4 | 0,5 | 4 |
| Scudieri | Fante, Guardiano | rosso 2 | 2,5 s | Scudo 5 | 0,5 | 5 |
| Frombolieri | Fante | verde 3 | 2 s | Danno 7 | 0,5 | 7 |
| Esploratori | Fauna | verde 1 | 1 s | Danno 2 | 1 | 2 |
| Erboristi | Spirituale | blu 2 | 2 s | Cura 5 | 0,5 | 5 |
| Sobillatori | Criminale | viola 2 | 3 s | Corruzione 4 | 0,5 | 6 |
| Zappatori *(nuovi, bozza 4)* | Assedio | rosso 2 | 2,5 s | Danno 3, Scudo 2 (niente danno agli scudi nell’era 1) | 1 | 5 |
| Tagliagole *(nuovi, bozza 4)* | Criminale | viola 2 | 2 s | Danno 5 | 0,5 | 5 |

### 3.2 Era 2 — moltiplicatore ×1,5, costo base 7 Oro

| Truppa | Tipi | Mana | Ricarica | Effetti | Cibo | Punti |
|---|---|---|---:|---|---:|---:|
| Guardie | Legge | nessuno | 2,5 s | Scudo 2 | 0,5 | 2 |
| Balestrieri | Fante | verde 2 | 1,5 s | Danno 6 | 0,5 | 6 |
| Arieti | Assedio | rosso 4 | 3 s | Danno agli scudi 10, Danno 8 | 1 | 13 |
| Guastatori | Fante, Criminale | viola 3 | 3 s | Danno 7, Inefficienza 4 s (edifici) | 0,5 | 11 |
| Cavalieri | Fauna, Nobile | verde 3 | 2 s | Danno 10 | 1 | 10 |
| Arcieri a cavallo | Fauna, Fante | verde 2 | 1,5 s | Danno 4, Inefficienza 2 s (truppe) | 1 | 6 |
| Confraternita | Spirituale, Guardiano | blu 3 | 2,5 s | Cura 6, Scudo 4 | 0,5 | 10 |
| Predicatori | Spirituale | blu 3 | 3 s | Corruzione 6, Danno 2 | 0,5 | 11 |
| Contrabbandieri *(nuovi, bozza 4)* | Criminale | verde 2 | 1,5 s | Danno 4, Inefficienza 2 s (edifici) | 0,5 | 6 |
| Avvelenatori *(nuovi, bozza 4)* | Criminale | viola 3 | 3 s | Danno 2, Corruzione 6 | 0,5 | 11 |

### 3.3 Era 3 — moltiplicatore ×2, costo base 10 Oro

| Truppa | Tipi | Mana | Ricarica | Effetti | Cibo | Punti |
|---|---|---|---:|---|---:|---:|
| Moschettieri | Fante | verde 2 | 2,5 s | Danno 10 | 0,5 | 10 |
| Granatieri | Fante, Assedio | rosso 5 | 3 s | Danno 15, Danno agli scudi 12 | 1 | 21 |
| Catapulte | Assedio | rosso 6 | 3,5 s | Danno agli scudi 16, Danno 17 | 1 | 25 |
| Bombarde | Assedio | rosso 8 | 4 s | Danno agli scudi 12, Danno 27 | 1 | 33 |
| Corazzieri | Fauna | verde 4 | 2,5 s | Danno 12, Scudo 5 | 1 | 17 |
| Spie | Criminale | viola 4 | 4 s | Sabotaggio 4 s (truppe), Corruzione 8 | 0,5 | 20 |
| Paladini | Spirituale, Guardiano | blu 4 | 2 s | Danno 10, Cura 6 | 0,5 | 16 |
| Inquisitori | Spirituale, Legge | blu 4 | 3 s | Corruzione 12 | 0,5 | 18 |
| Guardia reale *(nuova, bozza 4)* | Nobile, Patriota | blu 4 | 2,5 s | Danno 10, Scudo 7 | 0,5 | 17 |
| Lame nere *(nuove, bozza 4)* | Criminale | viola 4 | 2,5 s | Danno 9, Sabotaggio 4 s (truppe) | 0,5 | 17 |

### 3.4 Quando compaiono gli effetti — deciso con Davide

| Effetto | Prima era |
|---|---|
| Danno, Scudo, Cura | 1 (Confermato nel GDD per scudo e cura) |
| Corruzione | 1, debole (Sobillatori, Corruzione 4); piena dall’era 2 |
| Danno agli scudi, Inefficienza | 2 |
| Sabotaggio | 3 |

---

## 4. Vie

Pool di **4 vie per era** (se ne mostrano 3, §10.4 del GDD), più vie esclusive di certe identità. Ogni via ha **un elemento esclusivo per ogni era** dalla sua in poi. Gli esclusivi seguono la regola di §1.5.

“Favorita da” indica gli elementi dell’identità o le vie precedenti che aumentano la probabilità che la via compaia (peso +1 ciascuno, §16.3 del GDD). “Offerte più frequenti” indica consiglieri e azioni che la via rende più probabili: un’azione favorita rende più frequente anche il suo consigliere.

### 4.1 Vie dell’era 2

| Via | Favorita da | Offerte più frequenti | Tratto permanente | Bonus immediato |
|---|---|---|---|---|
| Via del Commercio | Cultura mercantile, Popolo del delta, Repubblica | Tesoriere, Esattori (prima Mercante) | +1 Oro per fase da ogni edificio Economico | +6 Oro |
| Via della Guerra | Cultura guerriera, Montanari, Monarchia | Generale, Addestramento | Le truppe Fante ricaricano il 10% più in fretta | +1 spazio truppa |
| Via della Fede | Teocrazia, Culto del Sole, Antichi spiriti | Ambasciata, Fortificazioni | +1 Fede per fase da ogni edificio Spirituale | +4 Fede |
| Via del Sapere | Cultura erudita, Ordine della Ragione | Studiosi | +1 Ricerca per fase da ogni edificio Accademico | +5 Ricerca |

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
| Via dell’Impero | Via della Guerra, Monarchia | Quartiermastro, Generale | +10 Resistenza in ogni scontro | +1 spazio truppa, +1 spazio edificio |
| Via dell’Oro | Via del Commercio, Repubblica, Popolo del delta | Esattori | Rinnovare le offerte costa 1 Oro in meno | +10 Oro |
| Via della Rivelazione | Via della Fede, Teocrazia, Culto del Sole | Ambasciata | Gli edifici Spirituali producono il 10% più in fretta | +6 Fede |
| Via dell’Ombra | Via del Sapere, Ordine della Ragione, Repubblica | Studiosi, Ambasciata | Inefficienza e Sabotaggio inflitti durano 1 s in più (§7 questione D) | +5 Influenza |
| Via degli Spiriti *(esclusiva: solo con Antichi spiriti)* | Popolo delle foreste | Esattori | +1 Cibo per fase da ogni edificio Fauna o di Produzione | +4 Legno |

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

| Edificio | Via | Era | Tipi | Colore | Per fase | In battaglia | Punti |
|---|---|---:|---|---|---|---|---:|
| Fondaco | Commercio | 2 | Economico, Infrastruttura Strategica | verde | Oro 4, Influenza 1 | 1 mana ogni 1,5 s | 7,2 |
| Monastero | Fede | 2 | Spirituale | blu | Ricerca 1, Fede 2 | 1 mana + 2 cura ogni 2 s | 7 |
| Osservatorio | Sapere | 2 | Accademico | viola | Ricerca 4, Documenti 2 | 1 mana ogni 2 s | 7 |
| Compagnia commerciale | Commercio | 3 | Economico, Infrastruttura Strategica | verde | Oro 5 | 2 mana ogni 2 s | 9 |
| Borsa | Oro | 3 | Economico | verde | Oro 7 | 1 mana ogni 2 s | 9 |
| Reliquiario | Rivelazione | 3 | Spirituale, Guardiano | **neutro** | Fede 2 | 2 cura + 2 Corruzione ogni 2 s (nessun mana) | 8,5 |
| Totem degli antenati | Spiriti | 3 | Fauna, Spirituale | verde | Fede 2 | 2 mana + 2 scudo + 1 cura ogni 2 s | 9,5 |

**Truppe** (budget dell’era +1)

| Truppa | Via | Era | Tipi | Mana | Ricarica | Effetti | Cibo | Punti |
|---|---|---:|---|---|---:|---|---:|---:|
| Veterani | Guerra | 2 | Fante | rosso 3 | 2 s | Danno 7, Scudo 3 | 0,5 | 10 |
| Guardia d’élite | Guerra | 3 | Fante | rosso 4 | 2 s | Danno 12, Scudo 5 | 0,5 | 17 |
| Crociati | Fede | 3 | Spirituale, Patriota | blu 4 | 2,5 s | Danno 10, Cura 4, Scudo 4 | 0,5 | 18 |
| Ingegneri militari | Sapere | 3 | Assedio, Accademico | viola 5 | 3 s | Danno agli scudi 14, Danno 10, Inefficienza 5 s (edifici) | 1 | 22 |
| Legione | Impero | 3 | Fante, Patriota | rosso 5 | 2,5 s | Danno 14, Scudo 7 | 0,5 | 21 |
| Assassini | Ombra | 3 | Criminale | viola 4 | 3 s | Sabotaggio 4 s (truppe), Corruzione 6, Danno 2 | 0,5 | 19 |

---

## 5. Identità e perk

### 5.1 Elementi dell’identità

Esclusivi dell’identità (era 1, +1 punto di budget):

| Esclusivo | Identità | Tipi | Colore | Valori | Punti |
|---|---|---|---|---|---:|
| Porto fluviale (edificio) | Popolo del delta | Economico, Infrastruttura Strategica | verde | Oro 2, Cibo 2; 1 mana ogni 2 s | 5 |
| Arcieri dei boschi (truppa) | Popolo delle foreste | Guardiano | verde 2, 1,2 s | Danno 5 | 5 |
| Guardie delle vette (truppa) | Montanari | Guardiano, Patriota | nessun mana, 3 s | Danno 2, Scudo 2 (gente “dura a cedere”) | 4 |

**Risorsa della Capitale (GDD §6.2, v0.22).** Ogni popolo, governo, credo e cultura indica una risorsa che la Capitale produce in più (+1 a fase); risorse uguali si sommano. Placeholder:

| Elemento | Risorsa | Elemento | Risorsa |
|---|---|---|---|
| Montanari | Pietra | Culto del Sole | Fede |
| Popolo del delta | Influenza | Antichi spiriti | Legno |
| Popolo delle foreste | Legno | Ordine della Ragione | Ricerca |
| Monarchia | Stabilità | Cultura guerriera | Ferro |
| Repubblica | Influenza | Cultura mercantile | Oro |
| Teocrazia | Fede | Cultura erudita | Documenti |

### 5.2 Perk esistenti

Restano invariati: Biblioteca reale, Consiglio allargato, Contrattatori, Fabbri esperti, Mulini, Mura antiche. **Allevatori** (v0.22): le truppe **Fauna** ricaricano del 15% più in fretta (prima: Cavalleria).

### 5.3 Perk nuovi

Usano gli effetti nuovi. Disponibili alla creazione e come ricompense degli incontri del mondo.

| Perk | Effetto |
|---|---|
| Veleni sottili | Gli elementi che infliggono Corruzione ne infliggono 1 in più. |
| Erboristi di corte | Gli elementi che curano curano 1 in più. |
| Genio militare | Le truppe Assedio fanno il 25% di danno agli scudi in più. |
| Mura di pietra | Gli elementi Guardiani che producono scudo ne producono 1 in più. |

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

## 6 bis. Il Consiglio (GDD §4.2, v0.21–v0.22)

Le categorie, i loro tipi e le risorse di Potenzia sono nel GDD (§4.2.4). File dati: `data/catalog/consiglieri/`. Ogni consigliere propone le carte dell’era che hanno almeno un suo tipo, più le sue azioni (file in `data/catalog/opportunities/`).

| Consigliere | Categoria · colore | Risorsa di Potenzia | Azioni (costo) |
|---|---|---|---|
| Generale | Militare · rosso | Ferro | Quartiermastro (5 Oro, spazio truppa) · Addestramento (2 Ferro) |
| Architetto | Opera · rosso | Pietra | Architetti (6 Oro, spazio edificio) · Fortificazioni (2 Pietra) |
| Fattore | Terra · verde | Legno | Scorte (2 Legno → 3 Cibo) · Razioni (2 Legno: per un anno le truppe mangiano la metà) |
| Tesoriere | Ricchezza · verde | Influenza | Esattori (+3 Oro) · Assemblea (+50% Oro o Ricerca per un anno) · *Ministri:* Grandi esattori (+6 Oro) |
| Studioso | Conoscenza · viola | Documenti | Studiosi (3 Legno → 3 Ricerca) · Archivisti (2 Documenti → 3 Ricerca) · Manuali tecnici (2 Documenti: per un anno una truppa a scelta fa il 25% di danno in più) · *Ministri:* Trattati (4 Legno → 5 Ricerca) · Revisione dei piani (2 Documenti: ripesca la mano delle tecnologie, v0.25) |
| Sacerdote | Fede · blu | Fede | Cinque incanti (2 Fede ciascuno) · Processione (2 Fede, solo Teocrazia) |
| Cancelliere | Stato · blu | Stabilità | Ambasciata (2 Stabilità) · Decreto fiscale (2 Stabilità → 4 Oro) · Censimento (2 Stabilità: per un anno ogni consigliere mostra una proposta in più) · Tributi feudali (+5 Oro, solo Monarchia) |
| Maestro delle spie | Ombra · viola | Oro + una risorsa casuale | Sei spionaggi (2 Documenti ciascuno) · *Ministri:* Rete di sabotatori (3 Documenti) |
| Clown | — | — (non potenzia) | Un elemento per colore (rosso, verde, blu, viola) e un edificio neutro |
| Anziano | — | Oro (solo edifici neutri, una volta all’anno) | Consiglio degli anziani: un perk (2 Fede + 2 Influenza) · edifici neutri |

**Livelli del Consiglio** (GDD §4.2.1): Funzionari nell’era 1, Ministri nell’era 2, Gran Consiglieri nell’era 3. Le azioni in *corsivo* compaiono solo dal livello indicato (campo `min_level` dell’azione). Livelli e azioni di livello arrivano dal lavoro sul Consiglio v0.21.

**Incanti del Sacerdote** (GDD §4.3): una sola volta per truppa; aggiungono un effetto e 2 mana. Se la truppa non chiedeva mana, lo chiede del colore dell’incanto.

| Incanto | Effetto aggiunto (era 1 / 2 / 3 della truppa) | Colore se la truppa non usava mana |
|---|---|---|
| Furia | Danno 2 / 4 / 6 | rosso |
| Egida | Scudo 2 / 4 / 6 | blu |
| Grazia | Cura 2 / 4 / 6 | blu |
| Maledizione | Corruzione 1 / 3 / 4 | viola |
| Torpore | Inefficienza 2 / 4 / 6 s su una truppa nemica | viola |

**Spionaggi del Maestro delle spie** (GDD §12): valgono per lo scontro con il fantasma dell’anno.

| Spionaggio | Effetto | Bersaglio |
|---|---|---|
| Sicari nell’ombra | Sabotaggio 5 s | la truppa più veloce |
| Colpo all’avanguardia | Sabotaggio 5 s | la truppa più a destra (la prima ad agire) |
| Rifornimenti avvelenati | Inefficienza 10 s | l’edificio più veloce |
| Infiltrati | Inefficienza 10 s | un elemento a caso |
| Doppio gioco | Sabotaggio 5 s | la truppa più lenta |
| Veleno nei pozzi | Inefficienza 10 s | la truppa più veloce |
| Rete di sabotatori *(dal livello Ministri)* | Sabotaggio 8 s | l’elemento più veloce (truppa o edificio) |

**Copertura (bozza 4).** Ogni consigliere ordinario ha almeno due azioni comuni e, in ogni era, almeno un edificio e una truppa con un suo tipo (lo verifica un test automatico). Per riempire i buchi sono state aggiunte: Tribunale, Prefettura e Palazzo del governo (Stato); Covo, Mercato nero e Arsenale clandestino (Ombra); Acciaieria (Opera, era 3); Zappatori (Assedio dell’era 1, per l’Architetto); Tagliagole (Ombra, era 1); Guardia reale (Stato, era 3); le azioni Archivisti, Manuali tecnici, Decreto fiscale e Censimento. In seguito sono arrivati Armeria, Campo d’addestramento e Torre di guardia per il Generale, Contrabbandieri, Avvelenatori e Lame nere per il Maestro delle spie: ora entrambi hanno almeno 2 truppe e 3 edifici in ogni era.

---

## 6 ter. Eventi, Visitatori e Fortune (GDD §4.2.5, v0.23)

Compaiono nei round al posto di un consigliere. File dati: `data/catalog/eventi/` (eventi e fortune) e `data/catalog/visitatori/`. Ogni carta ha una sfera (una categoria del Consiglio) e delle radici; le opzioni fra parentesi quadre richiedono qualcosa alla nazione e, se manca, restano visibili ma spente.

### Eventi (18)

Notazione delle opzioni: **[requisito]** = opzione sbloccata solo con quel requisito. "Per un anno" segue §8.2.1. I valori seguono più o meno il budget del Catalogo (1 Oro ≈ 1 Ricerca ≈ 2 unità delle altre risorse).

**Uno per ogni elemento dell'identità**

| Evento | Sfera | Radici | Opzioni |
|---|---|---|---|
| **Il passo innevato** | Opera | favorito da Montanari | Spala la neve: 2 Pietra → 3 Ferro · Aspetta il disgelo: per un anno la Capitale produce 1 Pietra in più · **[Guardiano]** Le guardie aprono la strada: +2 Ferro |
| **La piena del fiume** | Terra | favorito da Popolo del delta | Alza gli argini: 3 Legno → +2 Stabilità · Lascia allagare i campi: per un anno +1 Cibo per fase dagli edifici di Produzione · **[Economico]** I mercanti noleggiano chiatte: +4 Oro |
| **Il cervo bianco** | Terra | favorito da Popolo delle foreste | Caccialo: +3 Cibo e +1 Legno · Lascialo libero: +2 Fede · **[truppa Fauna]** Addomesticalo: una truppa Fauna sale di livello |
| **L'erede al trono** | Stato | favorito da Monarchia | Festa di corte: 3 Oro → +3 Stabilità · Matrimonio politico: 2 Stabilità → +4 Influenza · **[Nobile]** Il giuramento dei nobili: per un anno le truppe Nobili ricaricano il 10% più in fretta |
| **Le elezioni** | Stato | favorito da Repubblica | Campagna generosa: 3 Oro → per un anno ogni consigliere mostra una proposta in più · Lascia decidere il popolo: +2 Stabilità · **[Legge]** Riforma delle leggi: 2 Documenti → +3 Stabilità e +2 Influenza |
| **Il concilio dei sacerdoti** | Fede | favorito da Teocrazia | Dottrina severa: 2 Fede → +10 Resistenza nel prossimo scontro con il fantasma · Apertura al popolo: +2 Influenza · **[Spirituale]** Grande processione: +3 Fede |
| **L'eclissi** | Fede | favorito da Culto del Sole | Rito di riparazione: 3 Fede → +5 Oro · Presagio di guerra: fino al prossimo fantasma le truppe ricaricano il 10% più in fretta · **[Accademico]** Gli astronomi la spiegano: +3 Ricerca |
| **Il bosco che sussurra** | Fede | favorito da Antichi spiriti | Offerta agli spiriti: 2 Cibo → +3 Fede · Abbatti il bosco: +4 Legno · **[Guardiano]** I guardiani del bosco: ricevi gli Esploratori (se c'è spazio) |
| **La disputa dei dotti** | Conoscenza | favorito da Ordine della Ragione | Finanzia la scuola: 3 Oro → +3 Ricerca · Pubblica gli atti: 2 Documenti → +3 Influenza · **[Accademico]** Il trattato fondamentale: +2 Ricerca e +2 Documenti |
| **Il torneo** | Militare | favorito da Cultura guerriera | Premi ricchi: 3 Oro → per un anno una truppa a scelta fa il 25% di danno in più · Torneo modesto: 1 Ferro → +2 Stabilità · **[Fante]** Il campione: una truppa Fante a scelta sale di livello |
| **La grande fiera** | Ricchezza | favorito da Cultura mercantile | Fiera delle meraviglie: 4 Oro → ricevi un edificio Economico dell'era, a caso · Banchi per tutti: 2 Influenza → +5 Oro · **[Infrastruttura Strategica]** Le strade portano mercanti: +2 Oro e +2 Influenza |
| **Il manoscritto perduto** | Conoscenza | favorito da Cultura erudita | Compralo: 4 Oro → +4 Documenti · Fallo copiare: 2 Documenti → +3 Ricerca · **[Criminale]** Rubalo: 1 Stabilità → +4 Documenti |

**Generici, legati all'era**

| Evento | Sfera | Radici | Opzioni |
|---|---|---|---|
| **Banditi sulla strada** | Ombra | era 1 | Scorta armata: 2 Ferro → +3 Oro · Assoldali: 3 Oro → ricevi i Tagliagole (se c'è spazio) · **[Criminale]** Un accordo nell'ombra: +2 Documenti |
| **Un inverno lungo** | Terra | era 1 | Razionamento: 2 Legno → per un anno le truppe mangiano la metà · Granai del re: 3 Oro → +4 Cibo · **[Produzione]** I campi resistono: +3 Cibo |
| **Gli esuli** | Stato | era 2 | Accoglili: 2 Cibo → +3 Stabilità · Arruolali: 4 Oro → ricevi una truppa dell'era, a caso · **[Patriota]** Nuovi patrioti: +2 Stabilità e +2 Influenza |
| **Febbre nei quartieri** | Fede | era 2 | Ospedali da campo: 3 Fede → +3 Stabilità · Chiudi le porte: +4 Stabilità, ma per un anno la Ricerca prodotta si dimezza · **[Spirituale]** I monaci curano: +2 Fede |
| **La grande opera** | Opera | era 3 | Costruiscila: 5 Pietra → +1 spazio edificio · Rimandala: +2 Pietra · **[Infrastruttura Strategica]** Ingegneri esperti: 3 Pietra → +1 spazio edificio |
| **Congiura a corte** | Ombra | era 3 | Reprimi: 3 Stabilità → +10 Resistenza nel prossimo scontro con il fantasma · Infiltra i congiurati: 3 Documenti → la truppa più veloce del fantasma parte sabotata per 5 s · **[Legge]** Processo pubblico: +4 Stabilità |

### Visitatori (6)

| Visitatore | Sfera | Radici | Che cosa propone (3 alla volta) | Prezzi |
|---|---|---|---|---|
| **Mercanti del delta** | Ricchezza | favoriti da Popolo del delta e Via del Commercio | Edifici Economici dell'era, compresi gli esclusivi di altre nazioni (Porto fluviale, Fondaco…) | Oro +1 |
| **Compagnia di ventura** | Militare | favorita da Cultura guerriera e Via della Guerra | Truppe Fante dell'era e di quella successiva | Oro +1; +3 per l'era successiva |
| **Pellegrini** | Fede | favoriti da Teocrazia e dai credi | Incanti del Sacerdote ed elementi Spirituali dell'era | come il Sacerdote |
| **Ambasciatore straniero** | Stato | dall'era 2; favorito da Monarchia e Repubblica | Ambasciata, Decreto fiscale, Dono diplomatico (+3 Influenza) | come il Cancelliere |
| **Contrabbandiere** | Ombra | richiede una carta Criminale sulla plancia o la Via dell'Ombra | Carte Criminali ed esclusivi di altre identità (Arcieri dei boschi, Guardie delle vette…) | Oro −1 e 1 Documenti |
| **Inventore errante** | Conoscenza | favorito da Ordine della Ragione e Cultura erudita; non nell'ultima era | Carte dell'era successiva, in anteprima | Oro +3 |

### Fortune (6)

I valori crescono con l'era: il numero indicato va moltiplicato per l'era corrente.

| Fortuna | Sfera | Favorita da | Dono |
|---|---|---|---|
| **Raccolto abbondante** | Terra | Popolo del delta, Antichi spiriti | +3 Cibo |
| **Una vena d'argento** | Opera | Montanari | +2 Ferro e +2 Oro |
| **Visione sacra** | Fede | Culto del Sole, Teocrazia | +3 Fede |
| **La biblioteca ritrovata** | Conoscenza | Cultura erudita, Ordine della Ragione | +2 Documenti e +1 Ricerca |
| **Festa del popolo** | Stato | Repubblica, Monarchia | +2 Stabilità e +1 Influenza |
| **Bottino dimenticato** | Militare | Cultura guerriera | +3 Ferro |

Nota: il Contrabbandiere richiede una carta Criminale sulla plancia ed è favorito dalla Via dell'Ombra (§16.3 del GDD).

---

## 6 quater. Tecnologie (GDD §10.5, v0.25)

**Stato: proposta di Claude, tutta placeholder** (nomi, effetti e costi). File dati: `data/catalog/tecnologie/` e, per le linee, `data/catalog/linee/`.

Regole del GDD usate qui: 4 rami per colore; ogni era ha due **altezze**; per era e per ramo ci sono 2 tecnologie alla prima altezza (una per categoria) e 1 alla seconda; la seconda altezza si apre con 1 tecnologia della prima nello stesso ramo. Costi di prova: era 1 **3 / 4** Ricerca, era 2 **5 / 6**, era 3 **7 / 8** (prima / seconda altezza). Per entrare nell’era 2 servono **4 tecnologie dell’era 1**, per l’era 3 **5 dell’era 2**.

Tutti gli effetti usano modificatori che il gioco ha già (P5): nessuna regola nuova. “Prerequisito” indica una freccia precisa dell’albero, oltre alla regola dell’altezza.

### 6 quater.1 Era 1 — Fondazione (altezze 1 e 2)

| Ramo | Altezza | Tecnologia | Sfera | Effetto | Prerequisito |
|---|---:|---|---|---|---|
| Rosso | 1 | **Disciplina** | Militare | Linea dei **Picchieri** (§6 quater.5) | — |
| Rosso | 1 | **Carpenteria** | Opera | +1 spazio edificio | — |
| Rosso | 2 | **Schieramento** | Militare | Le truppe Fante ricaricano il 5% più in fretta | Disciplina |
| Verde | 1 | **Rotazione dei campi** | Terra | Linea degli **Orti** | — |
| Verde | 1 | **Contabilità** | Ricchezza | +1 Oro per fase dalla Capitale | — |
| Verde | 2 | **Fiere** | Ricchezza | Rinnovare le proposte costa 1 Oro in meno | — |
| Blu | 1 | **Liturgia** | Fede | Linea dei **Penitenti** | — |
| Blu | 1 | **Codice delle leggi** | Stato | +1 Stabilità per fase dalla Capitale | — |
| Blu | 2 | **Milizie cittadine** | Stato | +5 Resistenza in ogni scontro | — |
| Viola | 1 | **Scrittura** | Conoscenza | Linea dello **Scriptorium** | — |
| Viola | 1 | **Bassifondi** | Ombra | Le truppe Criminali ricaricano il 10% più in fretta | — |
| Viola | 2 | **Copisti** | Conoscenza | +1 Documenti per fase da ogni edificio Accademico | Scrittura |

### 6 quater.2 Era 2 — Sviluppo (altezze 3 e 4)

| Ramo | Altezza | Tecnologia | Sfera | Effetto | Prerequisito |
|---|---:|---|---|---|---|
| Rosso | 3 | **Armi in acciaio** | Militare | Le truppe Fante fanno il 10% di danno in più | Disciplina |
| Rosso | 3 | **Ingegneria d’assedio** | Opera | Perk **Genio militare** (Assedio +25% danno agli scudi) | — |
| Rosso | 4 | **Caserme permanenti** | Opera | +1 spazio truppa | — |
| Verde | 3 | **Aratro pesante** | Terra | +1 Cibo per fase da ogni edificio di Produzione | — |
| Verde | 3 | **Banchi di cambio** | Ricchezza | +1 Influenza per fase da ogni edificio Economico | Contabilità |
| Verde | 4 | **Lettere di credito** | Ricchezza | Ogni consigliere mostra una proposta in più | — |
| Blu | 3 | **Ordini ospitalieri** | Fede | Perk **Erboristi di corte** (chi cura cura 1 in più) | — |
| Blu | 3 | **Burocrazia** | Stato | +1 Stabilità per fase da ogni edificio di Legge | Codice delle leggi |
| Blu | 4 | **Reliquie** | Fede | +1 Fede per fase da ogni edificio Spirituale | — |
| Viola | 3 | **Archivi di Stato** | Conoscenza | +1 Documenti per fase dalla Capitale | — |
| Viola | 3 | **Alchimia dei veleni** | Ombra | Perk **Veleni sottili** (Corruzione +1) | — |
| Viola | 4 | **Controspionaggio** | Ombra | L’Inefficienza inflitta dura il 25% in più | — |

### 6 quater.3 Era 3 — Ascesa (altezze 5 e 6)

| Ramo | Altezza | Tecnologia | Sfera | Effetto | Prerequisito |
|---|---:|---|---|---|---|
| Rosso | 5 | **Polvere da sparo** | Militare | Le truppe Assedio fanno il 15% di danno in più | Ingegneria d’assedio |
| Rosso | 5 | **Grandi opere** | Opera | +1 spazio edificio | — |
| Rosso | 6 | **Stato maggiore** | Militare | +10 Resistenza in ogni scontro | — |
| Verde | 5 | **Irrigazione** | Terra | +1 Legno per fase da ogni edificio di Produzione | Aratro pesante |
| Verde | 5 | **Banca centrale** | Ricchezza | +20% Oro prodotto | — |
| Verde | 6 | **Compagnie di ventura** | Ricchezza | Le truppe Fante ricaricano il 10% più in fretta | — |
| Blu | 5 | **Teologia** | Fede | Gli edifici Spirituali producono il 10% più in fretta | — |
| Blu | 5 | **Diritto** | Stato | Gli elementi di Legge che producono scudo ne producono 2 in più | — |
| Blu | 6 | **Amministrazione centrale** | Stato | Rinnovare le proposte costa 1 Oro in meno | — |
| Viola | 5 | **Stampa** | Conoscenza | +20% Ricerca prodotta | Copisti |
| Viola | 5 | **Cifrari** | Ombra | Il Sabotaggio inflitto dura il 25% in più | — |
| Viola | 6 | **Metodo scientifico** | Conoscenza | Perk **Biblioteca reale** (+25% Ricerca prodotta) | — |

Le tecnologie che danno un perk non compaiono se la nazione ha già quel perk.

### 6 quater.4 Tecnologie esclusive

Compaiono solo per chi ha la via o il popolo, alla prima altezza della loro era e nel ramo della loro sfera. Costano come le altre della stessa altezza.

**Vie (13)**

| Via | Era | Tecnologia | Sfera | Effetto |
|---|---:|---|---|---|
| Commercio | 2 | **Rotte carovaniere** | Ricchezza | +1 Oro per fase da ogni edificio Infrastruttura Strategica |
| Commercio | 3 | **Monopoli** | Ricchezza | +10% Oro prodotto |
| Guerra | 2 | **Veterani di cento battaglie** | Militare | Le truppe Fante che fanno danno ne fanno 1 in più |
| Guerra | 3 | **Arte della guerra** | Militare | +1 spazio truppa |
| Fede | 2 | **Pellegrinaggi** | Fede | +1 Fede per fase dalla Capitale |
| Fede | 3 | **Concilio** | Fede | Gli elementi Spirituali che curano curano 1 in più |
| Sapere | 2 | **Enciclopedia** | Conoscenza | +1 Ricerca per fase da ogni edificio Accademico |
| Sapere | 3 | **Accademie reali** | Conoscenza | +20% Ricerca prodotta |
| Impero | 3 | **Legioni di frontiera** | Militare | +10 Resistenza in ogni scontro |
| Oro | 3 | **Zecca** | Ricchezza | +1 Oro per fase da ogni edificio Economico |
| Rivelazione | 3 | **Miracoli** | Fede | Gli elementi Spirituali che producono scudo ne producono 2 in più |
| Ombra | 3 | **Gilda degli assassini** | Ombra | Le truppe Criminali fanno il 15% di danno in più |
| Spiriti | 3 | **Canti degli antenati** | Terra | Gli edifici Fauna producono il 10% più in fretta |

**Popoli (9).** Il gioco usa ancora i popoli del catalogo precedente; quando arriveranno le razze della v0.24 (§9.4.1 del GDD) queste tecnologie passeranno a Pietrosangue, Maremani e Cinerali, come gli altri esclusivi.

| Popolo | Era | Tecnologia | Sfera | Effetto |
|---|---:|---|---|---|
| Montanari | 1 | **Scalpellini** | Opera | +1 Pietra per fase dalla Capitale |
| Montanari | 2 | **Rocche di montagna** | Militare | Gli elementi Guardiani che producono scudo ne producono 1 in più |
| Montanari | 3 | **Cuore di pietra** | Opera | +10 Resistenza in ogni scontro |
| Popolo del delta | 1 | **Chiatte** | Ricchezza | +1 Oro per fase da ogni edificio Infrastruttura Strategica |
| Popolo del delta | 2 | **Canali** | Terra | +1 Cibo per fase da ogni edificio di Produzione |
| Popolo del delta | 3 | **Porto franco** | Ricchezza | Rinnovare le proposte costa 1 Oro in meno |
| Popolo delle foreste | 1 | **Sentieri nascosti** | Terra | Le truppe Guardiane ricaricano il 10% più in fretta |
| Popolo delle foreste | 2 | **Erbe dei boschi** | Fede | Gli elementi che curano curano 1 in più |
| Popolo delle foreste | 3 | **Spiriti del bosco** | Terra | +1 Legno per fase da ogni edificio Fauna |

### 6 quater.5 Linee di elementi

Una linea ha una versione per era (GDD §10.5.5). Le versioni **non sono nel catalogo base**: compaiono fra le proposte solo dopo la tecnologia. Come gli esclusivi (§1.5) hanno **+1 punto** di budget e costano il costo base della loro era.

| Linea | Tecnologia | Era 1 | Era 2 | Era 3 |
|---|---|---|---|---|
| Picchieri (truppe) | Disciplina | **Picchieri** | **Alabardieri** | **Lanzichenecchi** |
| Orti (edifici) | Rotazione dei campi | **Orti** | **Poderi** | **Latifondi** |
| Penitenti (truppe) | Liturgia | **Penitenti** | **Custodi del tempio** | **Templari** |
| Scriptorium (edifici) | Scrittura | **Scriptorium** | **Collegio** | **Ateneo** |

**Truppe delle linee**

| Truppa | Era | Tipi | Mana | Ricarica | Effetti | Cibo | Punti |
|---|---:|---|---|---:|---|---:|---:|
| Picchieri | 1 | Fante | rosso 2 | 2 s | Danno 4, Scudo 2 | 0,5 | 6 |
| Alabardieri | 2 | Fante | rosso 3 | 2,5 s | Danno 8, Scudo 3 | 0,5 | 11 |
| Lanzichenecchi | 3 | Fante | rosso 4 | 2,5 s | Danno 13, Scudo 5 | 0,5 | 18 |
| Penitenti | 1 | Spirituale | blu 2 | 2,5 s | Cura 3, Scudo 3 | 0,5 | 6 |
| Custodi del tempio | 2 | Spirituale | blu 3 | 2,5 s | Cura 6, Scudo 5 | 0,5 | 11 |
| Templari | 3 | Spirituale | blu 4 | 2,5 s | Danno 8, Cura 5, Scudo 5 | 0,5 | 18 |

**Edifici delle linee**

| Edificio | Era | Tipi | Colore | Per fase | In battaglia | Punti |
|---|---:|---|---|---|---|---:|
| Orti | 1 | Produzione | verde | Oro 1, Cibo 2, Legno 2 | 1 mana ogni 2 s | 5 |
| Poderi | 2 | Produzione | verde | Oro 1, Cibo 3, Legno 3 | 1 mana ogni 1,5 s | 6,7 |
| Latifondi | 3 | Produzione | verde | Oro 2, Cibo 4, Legno 3 | 1 mana ogni 1 s | 9,5 |
| Scriptorium | 1 | Accademico | viola | Ricerca 1, Documenti 2 | 1 mana ogni 1,5 s | 4,7 |
| Collegio | 2 | Accademico | viola | Ricerca 2, Documenti 2 | 1 mana ogni 1 s | 7 |
| Ateneo | 3 | Accademico | viola | Ricerca 3, Documenti 3 | 1 mana ogni 1 s | 8,5 |

### 6 quater.6 Studioso e carte dorate

- **Revisione dei piani** (Studioso, nuova): 2 Documenti, ripesca la mano delle tecnologie.
- Il **Mercante** del Tesoriere (2 Ricerca → 4 Oro) è tolto (GDD v0.25). Dove le vie e il Popolo del delta lo rendevano più frequente, ora rendono più frequenti gli **Esattori**.
- **Carte dorate** (GDD §10.5.6), primi esempi: l’evento **La disputa dei dotti** e la fortuna **La biblioteca ritrovata** danno, oltre ai loro effetti, una tecnologia di Conoscenza già iniziata a metà; gli incontri del mondo generati possono offrire fra le ricompense una tecnologia già iniziata.

---

## 7. Questioni per Davide

Tutte le questioni della bozza 1 sono decise.

| # | Questione | Decisione |
|---|---|---|
| A | Edifici senza mana | Sono **neutri**, senza colore; possono essere comuni (Palizzata, Bastioni) o esclusivi di certe nazioni (Reliquiario) (GDD §5.3, v0.16). |
| B | Era degli effetti | Come in §3.4. |
| C | Valori di partenza dello scontro | I modificatori possono cambiarli (GDD §8.2, v0.16): Semi del dissenso e Rete compromessa restano. |
| D | Via dell’Ombra allunga la durata di Inefficienza e Sabotaggio | Ammesso: la durata è un valore dell’effetto, come danno e cura. |
| E | Edifici dell’era 1 | L’era 1 ha **11 edifici**: restano Cava, Consolato e Stalle, più la Palizzata. L’era 2 riceve **Granaio** e **Fonderia** per restare a 8. |
| F | Potenziamenti | +50% a tutti i valori d’effetto per livello (GDD §6.5, v0.16). |
| G | Numeri | Costi variabili di ±1 Oro dentro l’era, compensati da ±1 punto (§1.1). I Moschettieri chiedono 2 mana rosso e tornano a 10 di danno. |
| H | Dimensioni | Pool di 4 vie per era più le esclusive; 1 esclusivo per via e per era; esclusivi +1 punto. |

## 8. Riepilogo dei numeri

| | Era 1 | Era 2 | Era 3 | Totale |
|---|---:|---:|---:|---:|
| Edifici base | 14 | 12 | 11 | 37 |
| Truppe base | 10 | 10 | 10 | 30 |
| Vie | — | 4 | 4 + 1 esclusiva | 9 |
| Esclusivi delle vie | — | 4 | 9 | 13 |
| Esclusivi dell’identità | 3 | — | — | 3 |
| Perk | 11 (7 esistenti + 4 nuovi) | | | 11 |
| Malus | 12 (6 esistenti + 6 nuovi) | | | 12 |
| Consiglieri | 8 ordinari + Clown e Anziano | | | 10 |
| Azioni del Consiglio | 33 (di cui 2 esclusive dell’identità e 3 dal livello Ministri) | | | 33 |
| Eventi / Fortune / Visitatori | 18 / 6 / 6 | | | 30 |
| Tecnologie base | 12 | 12 | 12 | 36 |
| Tecnologie esclusive (vie / popoli) | 0 / 3 | 4 / 3 | 9 / 3 | 13 / 9 |
| Elementi delle linee | 2 + 2 | 2 + 2 | 2 + 2 | 12 |
