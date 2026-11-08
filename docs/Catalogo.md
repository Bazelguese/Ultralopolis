# ULTRALOPOLIS — Catalogo placeholder

**Versione:** bozza 8 — 6 novembre 2026 (identità v0.24, tecnologie v0.26, tradizioni v0.27, cronache v0.29)
**Riferimento:** Game Design Document v0.29 (`docs/Ultralopolis_GDD.md`); nomi allineati al Glossario (`docs/Glossario.md`) l'8 novembre 2026 (GDD v0.31)
**Stato:** **tutto placeholder.** Nomi, numeri ed effetti servono a provare le regole, non sono bilanciamento approvato. Dalla v0.18 del GDD questo catalogo **è nel gioco**: i file dati sono in `data/catalog/` (edifici, truppe, `consiglieri/`, `opportunities/` per le azioni, `vie/`, `perk/`, `modifiers/`) e si modificano dall’Ispettore di Godot.

**Bozza 4 (GDD v0.22):** le etichette diventano **tipi** (1–2 per tessera), i colori del mana sono **quattro** (viola nuovo), le risorse cambiano (via la Fauna, nuove **Stabilità** e **Documenti**), i potenziamenti si fanno con l’opzione **Potenzia** del Consiglio. Il Consiglio è in §6 bis.

**Bozza 5 (GDD v0.24):** nuova identità della nazione (§6 quater): tre popoli, governi a ranghi, quattro credi con incanti esclusivi, quattro culture, tipi d'identità, tessere esclusive per popoli, governi, credi e culture, Malcontento e Rivoluzione. I vecchi popoli e l'Ordine della Ragione sono stati ridistribuiti.

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

**Punti = economia + scontro + spazi**, entro il budget dell’era con una tolleranza di ±0,5.

| Voce | Punti |
|---|---|
| Economia, per stagione | Oro 1, Ricerca 1, altre risorse 0,5 per unità |
| Scontro, a ogni ciclo | (4 × mana + 3 × punti effetto) ÷ ciclo in secondi |
| Spazio concesso | 2 per spazio |

Esempio: Fattoria, era 1 → Oro 1 + Cibo 2 = 2 punti; 1 mana ogni 2 s = 4 ÷ 2 = 2 punti; totale **4**.

Spendere il budget in economia o nello scontro è la scelta di doppia funzione (P3).

### 1.5 Elementi esclusivi

Gli esclusivi (delle vie e dell’identità) hanno **+1 punto** di budget rispetto agli elementi base della stessa era: sono la ricompensa per aver scelto quella strada. Costano come gli altri.

### 1.6 Potenziamenti

Si potenzia con l’opzione **Potenzia** del consigliere scelto (GDD §6.5, v0.22): la tessera deve avere almeno un tipo della sua categoria. Costi: livello 2 = 2 × era della tessera, livello 3 = 3 × era unità della **risorsa della categoria** (GDD §4.2.4). Il Maestro delle spie chiede la stessa quantità di Oro e della sua risorsa casuale; l’Anziano chiede Oro. I valori stanno nelle regole della run (`upgrade_cost_per_era`).

Effetti (GDD §6.5): ogni livello dà **+50% a tutti i valori d’effetto**, durate comprese, arrotondato per difetto; gli edifici anche +1 a ogni risorsa per stagione. Il mana prodotto non cambia.

### 1.7 Colori del mana

Quattro colori (GDD §5.3, v0.22). Il colore non dipende dai tipi: è una **tendenza** per scrivere il catalogo, legata alle categorie dei consiglieri: **rosso** Militare e Opera; **verde** Terra e Ricchezza; **blu** Fede e Stato; **viola** Conoscenza e Ombra. Ogni era ha truppe di tutti e quattro i colori, così ogni colore di edificio serve anche nello scontro. Le eccezioni sono volute: per esempio Segheria e Cantiere sono verdi, i tiratori mercenari (Frombolieri, Balestrieri, Moschettieri) verdi, l’Università blu.

Un edificio **senza mana è neutro**: non ha colore (§5.3 del GDD). Come ogni altro edificio può essere disponibile a tutti (Palizzata, Bastioni) oppure esclusivo di certe nazioni (Reliquiario).

---

## 2. Edifici

Legenda della colonna “Nello scontro”: ciò che l’edificio produce allo scadere del suo unico ciclo (§7.4 del GDD).

### 2.1 Era 1 — budget 4, costo base 4 Oro (14 edifici)

| Edificio | Tipi | Colore | Per stagione | Nello scontro | Extra | Punti |
|---|---|---|---|---|---|---:|
| Fattoria | Materie prime | verde | Oro 1, Cibo 2 | 1 mana ogni 4 s | — | 3 |
| Segheria | Materie prime | verde | Oro 1, Legno 2 | 1 mana ogni 2 s | — | 4 |
| Miniera | Materie prime | rosso | Pietra 1, Ferro 2 | 1 mana ogni 1,5 s | — | 4,2 |
| Mercato | Economico | verde | Oro 2, Influenza 1 | 1 mana ogni 1,5 s | — | 5,2 |
| Biblioteca | Accademico | viola | Ricerca 1, Documenti 2 | 1 mana ogni 2 s | — | 4 |
| Santuario | Spirituale | blu | Fede 2 | 1 mana + 1 cura ogni 2 s | — | 4,5 |
| Caserma | Infrastruttura Bellica | rosso | Ferro 1 | 1 mana ogni 3 s | +1 spazio truppa | 3,8 |
| Palizzata | Guardiano | **neutro** | Legno 1, Pietra 1 | 3 scudo ogni 3 s (nessun mana) | — | 4 |
| Cava | Materie prime | rosso | Pietra 3 | 1 mana ogni 1,5 s | — | 4,2 |
| Consolato | Nobile, Legge | blu | Oro 1, Stabilità 2 | 1 mana ogni 2 s | — | 4 |
| Stalle | Fauna, Materie prime | verde | Cibo 2, Legno 1 | 1 mana ogni 1,5 s | — | 4,2 |
| Tribunale *(nuovo, bozza 4)* | Legge | blu | Oro 1, Stabilità 2 | 1 mana ogni 2 s | — | 4 |
| Covo *(nuovo, bozza 4)* | Criminale, Infrastruttura Segreta | viola | Influenza 1, Documenti 1 | 1 mana + 1 Corruzione ogni 3 s | — | 3,8 |
| Armeria *(nuova, bozza 4)* | Infrastruttura Bellica | rosso | Ferro 2 | 1 mana ogni 1,5 s | — | 3,7 |

### 2.2 Era 2 — budget 6, costo base 7 Oro

| Edificio | Tipi | Colore | Per stagione | Nello scontro | Extra | Punti |
|---|---|---|---|---|---|---:|
| Accademia | Accademico | viola | Ricerca 3, Documenti 2 | 1 mana ogni 2 s | — | 6 |
| Bottega | Economico | verde | Oro 4 | 1 mana ogni 2 s | — | 6 |
| Cantiere | Materie prime, Infrastruttura Strategica | verde | Legno 2, Pietra 2 | 1 mana ogni 2 s | +1 spazio edificio | 6 |
| Fortezza | Infrastruttura Bellica | rosso | Pietra 1 | 1 mana + 2 scudo ogni 3 s | +1 spazio truppa | 5,8 |
| Tempio | Spirituale | blu | Fede 2 | 1 mana + 2 cura ogni 2 s | — | 6 |
| Granaio | Materie prime, Economico | verde | Oro 1, Cibo 4 | 1 mana ogni 1,5 s | — | 5,7 |
| Fonderia | Materie prime | rosso | Oro 1, Ferro 3 | 1 mana ogni 1 s | — | 6,5 |
| Loggia segreta | Infrastruttura Segreta, Criminale | viola | Influenza 1, Documenti 2 | 1 mana + 2 Corruzione ogni 3 s | — | 5,8 |
| Prefettura *(nuova, bozza 4)* | Legge, Patriota | blu | Oro 2, Stabilità 2 | 1 mana + 1 scudo ogni 2 s | — | 6,5 |
| Mercato nero *(nuovo, bozza 4)* | Criminale, Infrastruttura Strategica | viola | Oro 2, Influenza 2 | 1 mana ogni 1,5 s | — | 5,7 |
| Campo d’addestramento *(nuovo, bozza 4)* | Infrastruttura Bellica | rosso | Oro 1, Ferro 2 | 1 mana ogni 1 s | — | 6 |
| Torre di guardia *(nuova, bozza 4)* | Guardiano | **neutro** | Pietra 2 | 5 scudo ogni 3 s (nessun mana) | — | 6 |

### 2.3 Era 3 — budget 8, costo base 10 Oro

| Edificio | Tipi | Colore | Per stagione | Nello scontro | Extra | Punti |
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
| Acciaieria *(nuova, bozza 4)* | Materie prime | rosso | Oro 1, Pietra 2, Ferro 4 | 2 mana ogni 2 s | — | 8 |

### 2.4 Capitale

Invariata (§6.2 del GDD): 1 di ogni risorsa a ogni stagione, 1 mana energetico ogni 2 s. È fuori dalla regola di budget.

---

## 3. Truppe

Legenda: “Mana” indica colore e quantità richiesti a ogni attivazione; “Effetti” è ciò che la truppa fa quando si attiva. Inefficienza e Sabotaggio indicano tra parentesi i bersagli ammessi (§7.7 del GDD).

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
| Zappatori *(nuovi, bozza 4)* | Assedio | rosso 2 | 2,5 s | Danno 3, Scudo 2 (niente danno d'assedio nell’era 1) | 1 | 5 |
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

“Favorita da” indica gli elementi dell’identità o le vie precedenti che aumentano la probabilità che la via compaia (peso +1 ciascuno, §16.3 del GDD). “Opportunità più frequenti” indica consiglieri e azioni che la via rende più probabili: un’azione favorita rende più frequente anche il suo consigliere.

### 4.1 Vie dell’era 2

| Via | Favorita da | Opportunità più frequenti | Tratto permanente | Bonus immediato |
|---|---|---|---|---|
| Via del Commercio | Cultura mercantile, Maremani, Repubblica | Tesoriere, Esattori (prima Mercante) | +1 Oro per stagione da ogni edificio Economico | +6 Oro |
| Via della Guerra | Cultura guerriera, Pietrosangue, Monarchia | Generale, Addestramento | Le truppe Fante ricaricano il 10% più in fretta | +1 spazio truppa |
| Via della Fede | Teocrazia, Culto solare, Spiriti dei luoghi | Ambasciata, Fortificazioni | +1 Fede per stagione da ogni edificio Spirituale | +4 Fede |
| Via del Sapere | Cultura erudita | Studiosi | +1 Ricerca per stagione da ogni edificio Accademico | +5 Ricerca |

**Esclusivi delle vie dell’era 2**

| Via | Era 2 | Era 3 |
|---|---|---|
| Commercio | **Fondaco** (edificio) | **Compagnia commerciale** (edificio) |
| Guerra | **Veterani** (truppa) | **Guardia d’élite** (truppa) |
| Fede | **Monastero** (edificio) | **Crociati** (truppa) |
| Sapere | **Osservatorio** (edificio) | **Ingegneri militari** (truppa) |

### 4.2 Vie dell’era 3

| Via | Favorita da | Opportunità più frequenti | Tratto permanente | Bonus immediato |
|---|---|---|---|---|
| Via dell’Impero | Via della Guerra, Monarchia | Quartiermastro, Generale | +10 Resistenza in ogni scontro | +1 spazio truppa, +1 spazio edificio |
| Via dell’Oro | Via del Commercio, Repubblica, Maremani | Esattori | Rinnovare le opportunità costa 1 Oro in meno | +10 Oro |
| Via della Rivelazione | Via della Fede, Teocrazia, Culto solare | Ambasciata | Gli edifici Spirituali producono il 10% più in fretta | +6 Fede |
| Via dell’Ombra | Via del Sapere, Culto del vuoto, Repubblica | Studiosi, Ambasciata | Inefficienza e Sabotaggio inflitti durano 1 s in più (§7 questione D) | +5 Influenza |
| Via degli Spiriti *(esclusiva: solo con Spiriti dei luoghi)* | Cinerali | Esattori | +1 Cibo per stagione da ogni edificio Fauna o di Materie prime | +4 Legno |

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

| Edificio | Via | Era | Tipi | Colore | Per stagione | Nello scontro | Punti |
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

### 4.4 Tradizioni delle vie (GDD §10.4.1, v0.27)

**Stato: placeholder.** Ogni via ha 4 tradizioni; ognuna si completa con la sua impresa e dà un effetto permanente. File dati: le tradizioni sono dentro i file delle vie (`data/catalog/vie/`).

#### 4.4.1 Vie dell'era 2

| Via | Passo | Impresa | Effetto |
|---|---|---|---|
| **Commercio** | Botteghe | Prendi 3 opportunità dal Tesoriere | +1 Oro per stagione dalla Capitale |
| | Carovane | Abbi 2 edifici Infrastruttura Strategica | +1 Influenza per stagione da ogni edificio Infrastruttura Strategica |
| | Fiere annuali | Raccogli almeno 12 Oro in una sola produzione | Rinnovare le opportunità costa 1 Oro in meno |
| | Gilde | Abbi 3 edifici Economici al livello 2 o più | +10% Oro prodotto |
| **Guerra** | Veterani | Vinci 2 scontri | Le truppe Fante che fanno danno ne fanno 1 in più |
| | Arsenali | Abbi 2 edifici Infrastruttura Bellica | +1 Ferro per stagione da ogni edificio Infrastruttura Bellica |
| | Dottrina | Prendi 4 opportunità dal Generale | +1 spazio truppa |
| | Esercito di popolo | Abbi 3 tessere Fante al livello 2 o più | +8 Resistenza in ogni scontro |
| **Fede** | Pellegrini | Scegli 1 Evento di Fede | +1 Fede per stagione dalla Capitale |
| | Confraternite | Abbi 3 tessere Spirituali | Gli elementi Spirituali che curano curano 1 in più |
| | Concilio | Prendi 4 opportunità dal Sacerdote | +6 Resistenza in ogni scontro |
| | Santità | Chiudi un anno con il Malcontento a 2 o meno | Gli edifici Spirituali producono il 10% più in fretta |
| **Sapere** | Scuole | Completa 2 tecnologie | +1 Documenti per stagione dalla Capitale |
| | Biblioteche | Abbi 2 edifici Accademici | +1 Documenti per stagione da ogni edificio Accademico |
| | Accademie | Completa 3 tecnologie di Conoscenza | +10% Ricerca prodotta |
| | Enciclopedisti | Raccogli almeno 8 Ricerca in una sola produzione | Ogni consigliere mostra un'opportunità in più |

#### 4.4.2 Vie dell'era 3

| Via | Passo | Impresa | Effetto |
|---|---|---|---|
| **Impero** | Legati | Vinci 2 scontri | +1 spazio edificio |
| | Strade | Abbi 2 edifici Infrastruttura Strategica | +1 Pietra per stagione da ogni edificio Infrastruttura Strategica |
| | Legioni | Abbi 4 tessere Fante al livello 2 o più | Le truppe Fante fanno il 10% di danno in più |
| | Pax | Vinci 3 scontri con il fantasma | +10 Resistenza in ogni scontro |
| **Oro** | Zecche | Prendi 3 opportunità dal Tesoriere | +2 Oro per stagione dalla Capitale |
| | Banchieri | Abbi 3 edifici Economici | +1 Influenza per stagione da ogni edificio Economico |
| | Credito | Raccogli almeno 20 Oro in una sola produzione | Rinnovare le opportunità costa 1 Oro in meno |
| | Monopolio | Abbi 2 edifici Economici al livello 3 | +15% Oro prodotto |
| **Rivelazione** | Visioni | Scegli 1 Evento di Fede | +1 Fede per stagione da ogni edificio Spirituale |
| | Martiri | Vinci 2 scontri | Gli elementi Spirituali che producono scudo ne producono 1 in più |
| | Profeti | Prendi 3 opportunità dal Sacerdote | +8 Resistenza in ogni scontro |
| | Ultima rivelazione | Abbi 2 tessere Spirituali al livello 3 | Gli elementi che curano curano 2 in più |
| **Ombra** | Informatori | Prendi 3 opportunità dal Maestro delle spie | Le truppe Criminali ricaricano il 10% più in fretta |
| | Covi | Abbi 2 edifici Infrastruttura Segreta | +1 Documenti per stagione da ogni edificio Infrastruttura Segreta |
| | Sicari | Vinci 2 scontri con il fantasma | Il Sabotaggio inflitto dura il 25% in più |
| | Ombra lunga | Abbi 4 tessere Criminali | Gli elementi che infliggono Corruzione ne infliggono 1 in più |
| **Spiriti** | Boschi sacri | Abbi 2 edifici di Materie prime o Fauna | +1 Legno per stagione dalla Capitale |
| | Branchi | Abbi 3 tessere Fauna | Le truppe Fauna ricaricano il 10% più in fretta |
| | Antenati | Scegli 2 Eventi di Terra o di Fede | +8 Resistenza in ogni scontro |
| | Grande madre | Raccogli almeno 10 Cibo in una sola produzione | +1 Cibo per stagione da ogni edificio Fauna o di Materie prime |

### 4.5 Ascensioni (GDD §10.4.2, v0.27)

**Stato: placeholder.** File dati: `data/catalog/ascensioni/`.

#### 4.5.1 Livello 1 — effetti forti con il linguaggio di oggi

| Ascensione | Effetto |
|---|---|
| **Nazione in armi** | +1 spazio truppa e +1 spazio edificio |
| **Consiglio ristretto** | In ogni round compare un consigliere in più (effetto già usato dai governi, v0.24) |
| **Botteghe maestre** | Potenzia costa 1 in meno, mai sotto 1 (effetto già usato dalla cultura artigiana, v0.24) |
| **Eredità imperiale** | +20 Resistenza in ogni scontro |
| **Età dell'oro** | +25% di tutte le risorse prodotte |
| **Maestri d'armi** | Tutte le truppe fanno il 15% di danno in più |

#### 4.5.2 Livello 2 — cambiano una regola (modifiche del nucleo, GDD §10.4.2)

| Ascensione | Effetto | Regola che cambia | Rischio da tenere d'occhio |
|---|---|---|---|
| **Seconda natura** | Ogni truppa si può incantare **due volte** | §4.3: "ogni truppa si può incantare una sola volta" | Truppe con due effetti e +4 mana: forti ma lente da alimentare |
| **Ultima trincea** | La prima volta in ogni scontro che la Resistenza arriva a zero, torna a **1** | §7.1: "arrivare a zero significa perdere" | Non salva dalla Corruzione: resta il contro |
| **Prima scintilla** | Gli edifici iniziano lo scontro con l'ciclo **a metà**, non pieno | §7.5: "truppe ed edifici iniziano con il ciclo pieno" | Rende più veloce l'inizio: da provare con il logoramento |
| **Disciplina ferrea** | La truppa più a destra **prenota** il mana: le altre non lo usano finché lei non si attiva | §7.3: "il mana non viene prenotato per la truppa saltata" | Cambia l'ordine delle truppe: la regola di priorità va spiegata bene a schermo |
| **Mana unito** | Una truppa può pagare con il mana di **qualsiasi colore**, dopo il proprio e l'energetico | §5.3: "una truppa paga prima con il proprio colore e poi con l'energetico" | Molto forte per le nazioni a più colori |
| **Maestria** | Le tessere possono arrivare al **livello 4** | §6.5: "3 livelli" | Serve un costo di Potenzia per il livello 4 |
| **Doppio ascolto** | Una volta per metà anno si prendono **due opportunità** dallo stesso consigliere | §4.2: "se ne prende una sola" | Da limitare (una volta per metà) per non svuotare la scelta |
| **Esercito frugale** | Le truppe senza Cibo **non rallentano** | §5.4: "ricarica ×1,5 senza cibo" | Toglie peso al Cibo: da accoppiare a nazioni che ne hanno poco |

---

## 5. Identità e peculiarità

### 5.1 Elementi dell’identità

Dalla bozza 5 l'identità completa (popoli, governi, credi, culture, esclusivi, risorse della Capitale) è in **§6 quater**.

### 5.2 Peculiarità esistenti

Restano invariati: Biblioteca reale, Consiglio allargato, Contrattatori, Fabbri esperti, Mulini, Mura antiche. **Allevatori** (v0.22): le truppe **Fauna** ricaricano del 15% più in fretta (prima: Cavalleria).

### 5.3 Peculiarità nuove

Usano gli effetti nuovi. Disponibili alla creazione e come ricompense degli incontri del mondo.

| Peculiarità | Effetto |
|---|---|
| Veleni sottili | Gli elementi che infliggono Corruzione ne infliggono 1 in più. |
| Erboristi di corte | Gli elementi che curano curano 1 in più. |
| Genio militare | Le truppe Assedio fanno il 25% di danno d'assedio in più. |
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

## 6 bis. Il Consiglio (GDD §4.2, v0.21–v0.24)

Le categorie, i loro tipi e le risorse di Potenzia sono nel GDD (§4.2.4). File dati: `data/catalog/consiglieri/`. Ogni consigliere propone le tessere dell’era che hanno almeno un suo tipo, più le sue azioni (file in `data/catalog/opportunities/`).

| Consigliere | Categoria · colore | Risorsa di Potenzia | Azioni (costo) |
|---|---|---|---|
| Generale | Militare · rosso | Ferro | Quartiermastro (5 Oro, spazio truppa) · Addestramento (2 Ferro) |
| Architetto | Opera · rosso | Pietra | Architetti (6 Oro, spazio edificio) · Fortificazioni (2 Pietra) |
| Fattore | Terra · verde | Legno | Scorte (2 Legno → 3 Cibo) · Razioni (2 Legno: per un anno le truppe mangiano la metà) · Distribuzione di grano (3 Cibo → −2 Malcontento, v0.24) |
| Tesoriere | Ricchezza · verde | Influenza | Esattori (+3 Oro) · Assemblea (+50% Oro o Ricerca per un anno) · *Ministri:* Grandi esattori (+6 Oro) |
| Studioso | Conoscenza · viola | Documenti | Studiosi (3 Legno → 3 Ricerca) · Archivisti (2 Documenti → 3 Ricerca) · Manuali tecnici (2 Documenti: per un anno una truppa a scelta fa il 25% di danno in più) · *Ministri:* Trattati (4 Legno → 5 Ricerca) · Revisione dei piani (2 Documenti: ripesca la mano delle tecnologie, v0.26) |
| Sacerdote | Fede · blu | Fede | Cinque incanti (2 Fede ciascuno) · Processione (2 Fede, solo Teocrazia) · Predica di pace (3 Fede → −2 Malcontento, v0.24) · un incanto esclusivo per credo (§6 quater.3) |
| Cancelliere | Stato · blu | Stabilità | Ambasciata (2 Stabilità) · Decreto fiscale (2 Stabilità → 4 Oro) · Censimento (2 Stabilità: per un anno ogni consigliere mostra un'opportunità in più) · Tributi feudali (+5 Oro, solo Monarchia) · Ordine pubblico (2 Stabilità → −3 Malcontento, v0.24) |
| Maestro delle spie | Ombra · viola | Oro + una risorsa casuale | Sei spionaggi (2 Documenti ciascuno) · *Ministri:* Rete di sabotatori (3 Documenti) |
| Giullare | — | — (non potenzia) | Una tessera per colore (rosso, verde, blu, viola) e un edificio neutro |
| Anziano | — | Oro (solo edifici neutri, una volta all’anno) | Consiglio degli anziani: una peculiarità (2 Fede + 2 Influenza) · edifici neutri |

Le azioni che fanno scendere il Malcontento compaiono solo se c'è Malcontento. Governi e culture possono cambiare quanti consiglieri compaiono, quali, e quanto costano opportunità, azioni e Potenzia (§6 quater).

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

Compaiono nei round al posto di un consigliere. File dati: `data/catalog/eventi/` (eventi e fortune) e `data/catalog/visitatori/`. Ogni avvenimento ha una sfera (una categoria del Consiglio) e delle radici; le opzioni fra parentesi quadre richiedono qualcosa alla nazione e, se manca, restano visibili ma spente.

### Eventi (27 + Riforma, Tumulti e Rivoluzione)

Notazione delle opzioni: **[requisito]** = opzione sbloccata solo con quel requisito. "Per un anno" segue §8.2.1. I valori seguono più o meno il budget del Catalogo (1 Oro ≈ 1 Ricerca ≈ 2 unità delle altre risorse).

**Uno per ogni elemento dell'identità**

| Evento | Sfera | Radici | Opzioni |
|---|---|---|---|
| **Il passo innevato** | Opera | favorito da Pietrosangue | Spala la neve: 2 Pietra → 3 Ferro · Aspetta il disgelo: per un anno la Capitale produce 1 Pietra in più · **[Guardiano]** Le guardie aprono la strada: +2 Ferro · **[Pietrosangue]** La roccia viva apre il passo: +3 Pietra e +2 Ferro |
| **La piena del fiume** | Terra | favorito da Maremani | Alza gli argini: 3 Legno → +2 Stabilità · Lascia allagare i campi: per un anno +1 Cibo per stagione dagli edifici di Materie prime · **[Economico]** I mercanti noleggiano chiatte: +4 Oro · **[Maremano]** I barcaioli salvano il raccolto: +3 Cibo e +2 Influenza |
| **La montagna si sveglia** | Terra | favorito da Cinerali | Evacua i villaggi: 2 Cibo → +3 Stabilità · Raccogli l'ossidiana: +3 Ferro e +1 Pietra · **[edificio di Materie prime]** Forgia nella lava: un edificio di Materie prime sale di livello · **[Cinerale]** Volano sopra la cenere: +3 Ferro e +2 Documenti |
| **L'erede al trono** | Stato | favorito da Monarchia | Festa di corte: 3 Oro → +3 Stabilità · Matrimonio politico: 2 Stabilità → +4 Influenza · **[Nobile]** Il giuramento dei nobili: per un anno le truppe Nobili ricaricano il 10% più in fretta · Annuncio in piazza: +1 Stabilità |
| **Le elezioni** | Stato | favorito da Repubblica | Campagna generosa: 3 Oro → per un anno ogni consigliere mostra un'opportunità in più · Lascia decidere il popolo: +2 Stabilità · **[Legge]** Riforma delle leggi: 2 Documenti → +3 Stabilità e +2 Influenza |
| **Il concilio dei sacerdoti** | Fede | favorito da Teocrazia | Dottrina severa: 2 Fede → +10 Resistenza nel prossimo scontro con il fantasma · Apertura al popolo: +2 Influenza · **[Spirituale]** Grande processione: +3 Fede |
| **L'eclissi** | Fede | favorito da Culto solare | Rito di riparazione: 3 Fede → +5 Oro · Presagio di guerra: fino al prossimo fantasma le truppe ricaricano il 10% più in fretta · **[Accademico]** Gli astronomi la spiegano: +3 Ricerca |
| **Il bosco che sussurra** | Fede | favorito da Spiriti dei luoghi | Offerta agli spiriti: 2 Cibo → +3 Fede · Abbatti il bosco: +4 Legno · **[Guardiano]** I guardiani del bosco: ricevi gli Esploratori (se c'è spazio) |
| **La disputa dei dotti** | Conoscenza | favorito da Cultura erudita | Finanzia la scuola: 3 Oro → +3 Ricerca · Pubblica gli atti: 2 Documenti → +3 Influenza · **[Accademico]** Il trattato fondamentale: +2 Ricerca e +2 Documenti · Ascolta entrambi: +1 Ricerca |
| **Il torneo** | Militare | favorito da Cultura guerriera | Premi ricchi: 3 Oro → per un anno una truppa a scelta fa il 25% di danno in più · Torneo modesto: 1 Ferro → +2 Stabilità · **[Fante]** Il campione: una truppa Fante a scelta sale di livello · Giostra di paese: +1 Influenza |
| **La grande fiera** | Ricchezza | favorito da Cultura mercantile | Fiera delle meraviglie: 4 Oro → ricevi un edificio Economico dell'era, a caso · Banchi per tutti: 2 Influenza → +5 Oro · **[Infrastruttura Strategica]** Le strade portano mercanti: +2 Oro e +2 Influenza · Passeggia fra i banchi: +1 Oro |
| **Il manoscritto perduto** | Conoscenza | favorito da Cultura erudita | Compralo: 4 Oro → +4 Documenti · Fallo copiare: 2 Documenti → +3 Ricerca · **[Criminale]** Rubalo: 1 Stabilità → +4 Documenti · Leggilo in biblioteca: +1 Documenti |

**Generici, legati all'era**

| Evento | Sfera | Radici | Opzioni |
|---|---|---|---|
| **Banditi sulla strada** | Ombra | era 1 | Scorta armata: 2 Ferro → +3 Oro · Assoldali: 3 Oro → ricevi i Tagliagole (se c'è spazio) · **[Criminale]** Un accordo nell'ombra: +2 Documenti · Arma i contadini: +1 Ferro, Malcontento +1 |
| **Un inverno lungo** | Terra | era 1 | Razionamento: 2 Legno → per un anno le truppe mangiano la metà · Granai del re: 3 Oro → +4 Cibo · **[Materie prime]** I campi resistono: +3 Cibo · Taglia i boschi del re: +2 Legno, Malcontento +1 |
| **Gli esuli** | Stato | era 2 | Accoglili: 2 Cibo → +3 Stabilità · Arruolali: 4 Oro → ricevi una truppa dell'era, a caso · **[Patriota]** Nuovi patrioti: +2 Stabilità e +2 Influenza · Confisca i loro beni: +3 Oro, Malcontento +1 |
| **Febbre nei quartieri** | Fede | era 2 | Ospedali da campo: 3 Fede → +3 Stabilità · Chiudi le porte: +4 Stabilità, ma per un anno la Ricerca prodotta si dimezza · **[Spirituale]** I monaci curano: +2 Fede |
| **La grande opera** | Opera | era 3 | Costruiscila: 5 Pietra → +1 spazio edificio · Rimandala: +2 Pietra · **[Infrastruttura Strategica]** Ingegneri esperti: 3 Pietra → +1 spazio edificio |
| **Congiura a corte** | Ombra | era 3 | Reprimi: 3 Stabilità → +10 Resistenza nel prossimo scontro con il fantasma · Infiltra i congiurati: 3 Documenti → la truppa più veloce del fantasma parte sabotata per 5 s · **[Legge]** Processo pubblico: +4 Stabilità · Fingi di non sapere: +2 Documenti, Malcontento +1 |

**Senza costi (v0.24).** Davide: ogni evento ha almeno un'opzione gratuita e senza requisiti, così si può sempre scegliere qualcosa. Le opzioni gratuite aggiunte agli eventi qui sopra sono più deboli, oppure fanno salire il Malcontento. Questi sei eventi non chiedono mai risorse: si sceglie fra vantaggi diversi, o fra un vantaggio e una conseguenza.

| Evento | Sfera | Radici | Opzioni |
|---|---|---|---|
| **Il pellegrino cieco** | Fede | — | Accoglilo: +2 Fede · Chiedigli una profezia: fino al prossimo fantasma le truppe ricaricano il 10% più in fretta, Malcontento +1 · **[Spirituale]** Benedizione: +2 Fede e +1 Stabilità |
| **Una cometa nel cielo** | Conoscenza | — | Studiala: +2 Ricerca · Annuncia un presagio: +3 Fede, Malcontento +1 · **[Accademico]** Calcola l'orbita: +2 Ricerca e +2 Documenti |
| **La carovana smarrita** | Ricchezza | — | Guidala in città: +2 Influenza · Saccheggiala: +5 Oro, Malcontento +2 · **[truppa Fante]** Scortala: +3 Oro e +1 Influenza |
| **Il disertore** | Militare | — | Interrogalo: +2 Documenti · Arruolalo: una truppa dell'era a caso, Malcontento +1 · **[Legge]** Processo militare: +2 Stabilità e +1 Documenti |
| **Le terre di confine** | Terra | — | Coltivala: +3 Cibo · Disbosca tutto: +4 Legno, Malcontento +1 · **[edificio di Materie prime]** Fattorie nuove: +1 spazio edificio |
| **Il cantastorie** | Stato | — | Ascoltalo: Malcontento −1 · Fallo tacere: +2 Stabilità, Malcontento +1 · **[Patriota]** Canti di gloria: +2 Influenza, Malcontento −1 |

**Governo e Malcontento (v0.24)**

| Evento | Sfera | Radici | Opzioni |
|---|---|---|---|
| **La Riforma** | Stato | solo se il governo può evolvere; ripetibile | Un'opzione per ramo: "Verso: …" costa 3 Influenza per rango e chiede il requisito del ramo (es. **[Nobile]** per la Monarchia assoluta) · Rimanda: nulla |
| **Tumulti in piazza** | Stato | Malcontento almeno 4; ripetibile | Reprimi i tumulti: 2 Ferro → −3 Malcontento · Concedi pane e feste: 3 Oro → −2 · **[Legge]** Processi esemplari: −4 Malcontento e +1 Documenti · Lascia correre: +1 Malcontento |
| **La Rivoluzione** | Stato | **arriva da sola** quando il Malcontento tocca la soglia; non si può passare | Un'opzione gratuita per ogni governo legato alla causa principale del Malcontento (§6 quater.5); poi il Malcontento si azzera |

### Visitatori (6)

| Visitatore | Sfera | Radici | Che cosa propone (3 alla volta) | Prezzi |
|---|---|---|---|---|
| **Mercanti delle lagune** | Ricchezza | favoriti da Maremani e Via del Commercio | Edifici Economici dell'era, compresi gli esclusivi di altre nazioni (Porto lagunare, Emporio…) | Oro +1 |
| **Compagnia di ventura** | Militare | favorita da Cultura guerriera e Via della Guerra | Truppe Fante dell'era e di quella successiva | Oro +1; +3 per l'era successiva |
| **Pellegrini** | Fede | favoriti da Teocrazia e dai credi | Incanti del Sacerdote (compresi quelli esclusivi del proprio credo) ed elementi Spirituali dell'era | come il Sacerdote |
| **Ambasciatore straniero** | Stato | dall'era 2; favorito da Monarchia e Repubblica | Ambasciata, Decreto fiscale, Dono diplomatico (+3 Influenza) | come il Cancelliere |
| **Contrabbandiere** | Ombra | richiede una tessera Criminale sulla plancia o la Via dell'Ombra | Tessere Criminali ed esclusivi di altre identità (Arcieri delle ceneri, Guardie delle vette…) | Oro −1 e 1 Documenti |
| **Inventore errante** | Conoscenza | favorito da Cultura erudita; non nell'ultima era | Tessere dell'era successiva, in anteprima | Oro +3 |

### Fortune (6)

I valori crescono con l'era: il numero indicato va moltiplicato per l'era corrente.

| Fortuna | Sfera | Favorita da | Dono |
|---|---|---|---|
| **Raccolto abbondante** | Terra | Maremani, Spiriti dei luoghi | +3 Cibo |
| **Una vena d'argento** | Opera | Pietrosangue | +2 Ferro e +2 Oro |
| **Visione sacra** | Fede | Culto solare, Teocrazia | +3 Fede |
| **La biblioteca ritrovata** | Conoscenza | Cultura erudita | +2 Documenti e +1 Ricerca |
| **Festa del popolo** | Stato | Repubblica, Monarchia | +2 Stabilità e +1 Influenza |
| **Bottino dimenticato** | Militare | Cultura guerriera | +3 Ferro |

Nota: il Contrabbandiere richiede una tessera Criminale sulla plancia ed è favorito dalla Via dell'Ombra (§16.3 del GDD).

## 6 quater. Identità della nazione (GDD §9, v0.24)

File dati: `data/catalog/identita/`, `data/catalog/buildings/esclusivi/`, `data/catalog/troops/esclusive/`, `data/catalog/opportunities/esclusive/`. Ogni elemento ha un **tipo d'identità** (fuori dalle categorie) e dà +1 a stagione di una risorsa alla Capitale. Le tessere esclusive portano il tipo dell'elemento più 1-2 tipi di categoria.

### 6 quater.1 Popoli

| Popolo | Tipo | Resistenza | Tratto e dotazione | Esclusivi (era) | Capitale |
|---|---|---:|---|---|---|
| **Pietrosangue** | Pietrosangue | 8 | Parte con i Lancieri | Guardie delle vette (1) · Bastione di roccia viva (2) · Colossi di pietra (3) | Pietra |
| **Maremani** | Maremano | 2 | +3 Oro iniziale; Esattori più frequenti (il Mercante è tolto nella v0.26) | Porto lagunare (1) · Cantori delle maree (2) · Darsena delle lagune (3) | Influenza |
| **Cinerali** | Cinerale | 4 | Le truppe ricaricano il 10% più in fretta | Arcieri delle ceneri (1) · Falchi di cenere (2) · Lame del vulcano (3) | Ferro |

### 6 quater.2 Governi a ranghi

Alla creazione si sceglie un governo del rango 1. Entrando in un'era (dopo la via) il governo può evolvere al rango successivo, oppure restare com'è; si evolve anche con la Riforma (§6 ter).

```
RANGO 1                RANGO 2                        RANGO 3
Monarchia      ──►  Monarchia assoluta        ──►  Totalitarismo
               └─►  Monarchia costituzionale  ──►  Repubblica parlamentare
Repubblica     ──►  Oligarchia                ──►  Plutocrazia
               └─►  Dittatura                 ──►  Totalitarismo
Teocrazia      ──►  Ierocrazia
```

| Governo | Rango | Tipo | Resistenza | Effetto sul Consiglio | Requisito della Riforma | Capitale |
|---|---:|---|---:|---|---|---|
| **Monarchia** | 1 | Monarchico | 6 | Il primo consigliere ascoltato diventa il consigliere di corte (+2 peso); Fortificazioni più frequenti; Tributi feudali esclusivi | — | Stabilità |
| **Repubblica** | 1 | Repubblicano | 2 | 4 consiglieri per round; opportunità +1 Oro; rinnovo −1 Oro | — | Influenza |
| **Teocrazia** | 1 | Teocratico | 4 | Il Sacerdote è sempre presente; Ambasciata più frequente; Processione esclusiva | — | Fede |
| **Monarchia assoluta** | 2 | Assolutista | 7 | Il consigliere di corte è sempre presente | Nobile | Stabilità |
| **Monarchia costituzionale** | 2 | Costituzionale | 5 | Cancelliere più frequente; Ambasciata −1 Stabilità | Legge | Influenza |
| **Oligarchia** | 2 | Oligarchico | 3 | Tesoriere e Cancelliere più frequenti; Visitatori più frequenti (+2 peso) | Economico | Oro |
| **Dittatura** | 2 | Dittatoriale | 6 | 2 consiglieri, ma quello scelto offre un'opportunità in più | Patriota | Ferro |
| **Ierocrazia** | 2 | Ierocratico | 6 | Sacerdote sempre presente; le sue azioni −1 Fede | Spirituale | Fede |
| **Totalitarismo** | 3 | Totalitario | 8 | Come la Dittatura; Maestro delle spie più frequente; spionaggi +1 s; il Giullare non compare | Criminale | Documenti |
| **Repubblica parlamentare** | 3 | Parlamentare | 4 | 4 consiglieri senza sovrapprezzo; rinnovo −1 Oro | Legge | Influenza |
| **Plutocrazia** | 3 | Plutocratico | 3 | Opportunità −1 Oro; Visitatori molto più frequenti (+4 peso); Tesoriere più frequente | Nobile | Oro |

Tessere esclusive dei governi: Castello del re (Monarchia, era 2), Foro (Repubblica, era 1), Guardie del tempio (Teocrazia, era 2), Guardia del sovrano (Monarchia assoluta, era 2), Camera dei pari (Monarchia costituzionale, era 2), Banco delle famiglie (Oligarchia, era 2), Milizia del regime (Dittatura, era 2), Collegio dei sacerdoti (Ierocrazia, era 2), Polizia segreta (Totalitarismo, era 3), Parlamento (Repubblica parlamentare, era 3), Mercenari dei magnati (Plutocrazia, era 3). Quando il governo cambia, le tessere del vecchio governo restano sulla plancia con il loro tipo, ma non vengono più offerte.

### 6 quater.3 Credi e incanti esclusivi

| Credo | Tipo | Resistenza | Tratto | Incanto esclusivo | Tessera esclusiva | Capitale |
|---|---|---:|---|---|---|---|
| **Culto solare** | Solare | 2 | +20% Oro prodotto | Mezzogiorno: danno + cura 2/3/4, 3 Fede | Altare del sole (1) | Fede |
| **Spiriti dei luoghi** | Animista | 2 | Mana degli edifici il 10% più in fretta | Linfa degli spiriti: cura 2/4/6 + Inefficienza 1/2/3 s, 3 Fede | Bosco sacro (2) | Legno |
| **Culto degli antenati** | Ancestrale | 3 | 3 di scudo a inizio scontro | Scudo degli avi: scudo 2/4/6, +50% sulle truppe senza mana, 2 Fede | Ossario degli avi (3) | Stabilità |
| **Culto del vuoto** | Abissale | 1 | Corruzione inflitta +20% | Morso del nulla: Corruzione 1/2/3 + Sabotaggio 1/2/3 s, 3 Fede, viola | Adepti del vuoto (2) | Documenti |

Gli incanti esclusivi li offrono il Sacerdote e i Pellegrini, solo alla nazione che ha quel credo.

### 6 quater.4 Culture

| Cultura | Tipo | Resistenza | Effetto | Tessera esclusiva | Capitale |
|---|---|---:|---|---|---|
| **Mercantile** | Mercantile | 0 | +4 Oro iniziale; al mercato 1 unità → 1 Oro; Tesoriere più frequente | Emporio (1) | Oro |
| **Guerriera** | Guerriero | 3 | Parte con una Milizia; azioni del Generale −1 Ferro; Generale e Addestramento più frequenti | Campioni del clan (2) | Ferro |
| **Erudita** | Erudito | 0 | +3 Ricerca iniziale; +25% Ricerca prodotta (eredità dell'Ordine della Ragione); azioni dello Studioso −1; Studiosi più frequenti | Collegio dei saggi (2) | Ricerca |
| **Artigiana** | Artigiano | 1 | Potenzia −1 unità; +2 Legno e +2 Pietra iniziali; Architetto più frequente | Gilda dei mastri (2) | Pietra |

Gli sconti lasciano sempre almeno 1 unità.

### 6 quater.5 Tessere esclusive nuove

| Tessera | Elemento | Era | Tipi | Colore | Valori | Oro |
|---|---|---:|---|---|---|---:|
| Bastione di roccia viva (edificio) | Pietrosangue | 2 | Guardiano, Pietrosangue | neutro | Scudo 6 ogni 3 s | 7 |
| Colossi di pietra (truppa) | Pietrosangue | 3 | Assedio, Pietrosangue | rosso 6, 4 s | Danno 16, Scudo 4, Assedio 14; 1 Cibo | 10 |
| Cantori delle maree (truppa) | Maremani | 2 | Spirituale, Maremano | blu 3, 2 s | Cura 6 | 7 |
| Darsena delle lagune (edificio) | Maremani | 3 | Materie prime, Economico, Maremano | verde | Oro 5, Cibo 4; 1 mana ogni 2 s | 10 |
| Falchi di cenere (truppa) | Cinerali | 2 | Fante, Cinerale | verde 2, 1,2 s | Danno 4, Inefficienza 2 s | 7 |
| Lame del vulcano (truppa) | Cinerali | 3 | Fante, Cinerale | rosso 3, 1,2 s | Danno 9 | 10 |
| Castello del re (edificio) | Monarchia | 2 | Nobile, Guardiano, Monarchico | neutro | Stabilità 2; Scudo 4 ogni 3 s | 7 |
| Foro (edificio) | Repubblica | 1 | Legge, Repubblicano | blu | Influenza 2; 1 mana ogni 2 s | 4 |
| Guardie del tempio (truppa) | Teocrazia | 2 | Spirituale, Guardiano, Teocratico | blu 3, 2,5 s | Scudo 5, Cura 3 | 7 |
| Altare del sole (edificio) | Culto solare | 1 | Spirituale, Solare | blu | Oro 1, Fede 1; 1 mana ogni 2 s | 4 |
| Bosco sacro (edificio) | Spiriti dei luoghi | 2 | Fauna, Animista | verde | Cibo 2; Cura 2; 1 mana ogni 1,5 s | 7 |
| Ossario degli avi (edificio) | Culto degli antenati | 3 | Guardiano, Spirituale, Ancestrale | neutro | Stabilità 2; Scudo 5, Cura 2 ogni 2 s | 10 |
| Adepti del vuoto (truppa) | Culto del vuoto | 2 | Criminale, Abissale | viola 3, 3 s | Corruzione 7 | 7 |
| Emporio (edificio) | Cultura mercantile | 1 | Economico, Mercantile | verde | Oro 3; 1 mana ogni 1,5 s | 5 |
| Campioni del clan (truppa) | Cultura guerriera | 2 | Fante, Patriota, Guerriero | rosso 3, 2 s | Danno 9 | 7 |
| Collegio dei saggi (edificio) | Cultura erudita | 2 | Accademico, Erudito | viola | Ricerca 3, Documenti 1; 1 mana ogni 2 s | 7 |
| Gilda dei mastri (edificio) | Cultura artigiana | 2 | Materie prime, Infrastruttura Strategica, Artigiano | rosso | Legno 1, Pietra 1; 1 mana ogni 1,5 s | 7 |
| Guardia del sovrano (truppa) | Monarchia assoluta | 2 | Nobile, Patriota, Assolutista | blu 3, 2,5 s | Danno 6, Scudo 4 | 7 |
| Camera dei pari (edificio) | Monarchia costituzionale | 2 | Legge, Nobile, Costituzionale | blu | Stabilità 2, Influenza 1; 1 mana ogni 2 s | 7 |
| Banco delle famiglie (edificio) | Oligarchia | 2 | Economico, Nobile, Oligarchico | verde | Oro 4; 1 mana ogni 1,5 s | 7 |
| Milizia del regime (truppa) | Dittatura | 2 | Fante, Patriota, Dittatoriale | rosso 2, 1,5 s | Danno 6 | 7 |
| Collegio dei sacerdoti (edificio) | Ierocrazia | 2 | Spirituale, Legge, Ierocratico | blu | Fede 2; Cura 2; 1 mana ogni 2 s | 7 |
| Polizia segreta (truppa) | Totalitarismo | 3 | Criminale, Legge, Totalitario | viola 4, 3 s | Danno 6, Inefficienza 3 s | 10 |
| Parlamento (edificio) | Repubblica parlamentare | 3 | Legge, Infrastruttura Strategica, Parlamentare | blu | Influenza 3, Stabilità 2; 2 mana ogni 2 s | 10 |
| Mercenari dei magnati (truppa) | Plutocrazia | 3 | Fante, Nobile, Plutocratico | verde 3, 2 s | Danno 12 | 10 |

Gli esclusivi dell'era 1 che esistevano già sono stati rinominati: Porto lagunare (era Porto fluviale), Arcieri delle ceneri (erano Arcieri dei boschi, ora Fante invece di Guardiano).

### 6 quater.6 Malcontento e Rivoluzione

| Voce | Valore (placeholder) |
|---|---|
| Soglia della Rivoluzione / avviso | 10 / da 7 |
| Sale | +2 fantasma perso · +1 incontro perso · +1 per truppa senza Cibo · +1 per malus subito · alcune opzioni degli eventi |
| Scende | Ordine pubblico (Cancelliere): 2 Stabilità → −3 · Predica di pace (Sacerdote): 3 Fede → −2 · Distribuzione di grano (Fattore): 3 Cibo → −2 · Tumulti in piazza |

Governi possibili nella Rivoluzione, secondo la causa principale (escluso il governo attuale):

| Causa | Governi |
|---|---|
| Sconfitte | Dittatura, Monarchia assoluta, Totalitarismo |
| Carestie | Repubblica, Repubblica parlamentare, Monarchia costituzionale |
| Malus subiti | Teocrazia, Ierocrazia, Monarchia |
| Scelte degli eventi | Oligarchia, Plutocrazia, Repubblica |

## 6 quinquies. Stagioni (GDD §3.2, §4.2, §4.2.5; v0.25)

L'anno va dall'inverno all'autunno, 3 round per stagione (uno per mese). Valori placeholder, tutti nei file dati.

**Temi dei round** (`data/rules/run_rules.tres`, campo `season_themes`): inverno Azioni, Edifici, Misto · primavera Edifici, Misto, Misto · estate Truppe, Edifici, Misto · autunno Truppe, Azioni, Misto.

**Consiglieri d'inverno** (campi `favored_seasons` e `disfavored_seasons`): Cancelliere, Sacerdote e Fattore +1 di peso; Generale peso dimezzato (almeno 1).

**Eventi legati alle stagioni** (campi `seasons` e `favored_seasons`):

| Evento | Stagioni |
|---|---|
| Un inverno lungo, Il passo innevato | solo inverno |
| La piena del fiume, Le terre di confine | solo primavera |
| Il torneo | solo estate |
| Raccolto abbondante (fortuna) | estate e autunno |
| La grande fiera | solo autunno |
| La Riforma, Tumulti in piazza | tutte, più frequenti d'inverno (+1) |

**Eventi invernali nuovi** (solo inverno):

| Evento | Sfera | Opzioni |
|---|---|---|
| **La festa di mezzo inverno** | Stato | Accendi i falò: 2 Legno → Malcontento −2 · Banchetto al palazzo: 3 Oro → +2 Stabilità, Malcontento −1 · Lascia fare al popolo: +1 Stabilità · **[Patriota]** Canti dei padri: +2 Stabilità e +1 Influenza |
| **Il gelo** | Terra | Rinforza le case: 2 Legno → +2 Stabilità · Taglia il ghiaccio: +2 Pietra, Malcontento +1 · Aspetta il disgelo: +1 Legno · **[Materie prime]** Le scorte del granaio: +2 Cibo |
| **Le veglie al focolare** | Conoscenza | Raccogli i racconti: +2 Documenti · Insegna a leggere: 2 Oro → +3 Ricerca · Ascolta e basta: +1 Ricerca · **[Accademico]** Lezioni dei sapienti: +2 Ricerca e +1 Documenti |

**Incontri d'estate:** generati come a metà strada fra un anno e il successivo (Resistenza, truppe, edifici e ricompense). Gli incontri scritti a mano degli anni 1–3 sono quelli di primavera.

---

## 6 quinquies. Tecnologie (GDD §10.5, v0.26)

**Stato: proposta di Claude, tutta placeholder** (nomi, effetti e costi). File dati: `data/catalog/tecnologie/` e, per le linee, `data/catalog/linee/`.

Regole del GDD usate qui: 4 rami per colore; ogni era ha due **altezze**; per era e per ramo ci sono 2 tecnologie alla prima altezza (una per categoria) e 1 alla seconda; la seconda altezza si apre con 1 tecnologia della prima nello stesso ramo. Costi di prova: era 1 **3 / 4** Ricerca, era 2 **5 / 6**, era 3 **7 / 8** (prima / seconda altezza). Per entrare nell’era 2 servono **4 tecnologie dell’era 1**, per l’era 3 **5 dell’era 2**.

Tutti gli effetti usano modificatori che il gioco ha già (P5): nessuna regola nuova. “Prerequisito” indica una freccia precisa dell’albero, oltre alla regola dell’altezza.

### 6 quinquies.1 Era 1 — Fondazione (altezze 1 e 2)

| Ramo | Altezza | Tecnologia | Sfera | Effetto | Prerequisito |
|---|---:|---|---|---|---|
| Rosso | 1 | **Disciplina** | Militare | Linea dei **Picchieri** (§6 quinquies.5) | — |
| Rosso | 1 | **Carpenteria** | Opera | +1 spazio edificio | — |
| Rosso | 2 | **Schieramento** | Militare | Le truppe Fante ricaricano il 5% più in fretta | Disciplina |
| Verde | 1 | **Rotazione dei campi** | Terra | Linea degli **Orti** | — |
| Verde | 1 | **Contabilità** | Ricchezza | +1 Oro per stagione dalla Capitale | — |
| Verde | 2 | **Fiere** | Ricchezza | Rinnovare le opportunità costa 1 Oro in meno | — |
| Blu | 1 | **Liturgia** | Fede | Linea dei **Penitenti** | — |
| Blu | 1 | **Codice delle leggi** | Stato | +1 Stabilità per stagione dalla Capitale | — |
| Blu | 2 | **Milizie cittadine** | Stato | +5 Resistenza in ogni scontro | — |
| Viola | 1 | **Scrittura** | Conoscenza | Linea dello **Scriptorium** | — |
| Viola | 1 | **Bassifondi** | Ombra | Le truppe Criminali ricaricano il 10% più in fretta | — |
| Viola | 2 | **Copisti** | Conoscenza | +1 Documenti per stagione da ogni edificio Accademico | Scrittura |

### 6 quinquies.2 Era 2 — Sviluppo (altezze 3 e 4)

| Ramo | Altezza | Tecnologia | Sfera | Effetto | Prerequisito |
|---|---:|---|---|---|---|
| Rosso | 3 | **Armi in acciaio** | Militare | Le truppe Fante fanno il 10% di danno in più | Disciplina |
| Rosso | 3 | **Ingegneria d’assedio** | Opera | Peculiarità **Genio militare** (Assedio +25% danno d'assedio) | — |
| Rosso | 4 | **Caserme permanenti** | Opera | +1 spazio truppa | — |
| Verde | 3 | **Aratro pesante** | Terra | +1 Cibo per stagione da ogni edificio di Materie prime | — |
| Verde | 3 | **Banchi di cambio** | Ricchezza | +1 Influenza per stagione da ogni edificio Economico | Contabilità |
| Verde | 4 | **Lettere di credito** | Ricchezza | Ogni consigliere mostra un'opportunità in più | — |
| Blu | 3 | **Ordini ospitalieri** | Fede | Peculiarità **Erboristi di corte** (chi cura cura 1 in più) | — |
| Blu | 3 | **Burocrazia** | Stato | +1 Stabilità per stagione da ogni edificio di Legge | Codice delle leggi |
| Blu | 4 | **Reliquie** | Fede | +1 Fede per stagione da ogni edificio Spirituale | — |
| Viola | 3 | **Archivi di Stato** | Conoscenza | +1 Documenti per stagione dalla Capitale | — |
| Viola | 3 | **Alchimia dei veleni** | Ombra | Peculiarità **Veleni sottili** (Corruzione +1) | — |
| Viola | 4 | **Controspionaggio** | Ombra | L’Inefficienza inflitta dura il 25% in più | — |

### 6 quinquies.3 Era 3 — Ascesa (altezze 5 e 6)

| Ramo | Altezza | Tecnologia | Sfera | Effetto | Prerequisito |
|---|---:|---|---|---|---|
| Rosso | 5 | **Polvere da sparo** | Militare | Le truppe Assedio fanno il 15% di danno in più | Ingegneria d’assedio |
| Rosso | 5 | **Grandi opere** | Opera | +1 spazio edificio | — |
| Rosso | 6 | **Stato maggiore** | Militare | +10 Resistenza in ogni scontro | — |
| Verde | 5 | **Irrigazione** | Terra | +1 Legno per stagione da ogni edificio di Materie prime | Aratro pesante |
| Verde | 5 | **Banca centrale** | Ricchezza | +20% Oro prodotto | — |
| Verde | 6 | **Compagnie di ventura** | Ricchezza | Le truppe Fante ricaricano il 10% più in fretta | — |
| Blu | 5 | **Teologia** | Fede | Gli edifici Spirituali producono il 10% più in fretta | — |
| Blu | 5 | **Diritto** | Stato | Gli elementi di Legge che producono scudo ne producono 2 in più | — |
| Blu | 6 | **Amministrazione centrale** | Stato | Rinnovare le opportunità costa 1 Oro in meno | — |
| Viola | 5 | **Stampa** | Conoscenza | +20% Ricerca prodotta | Copisti |
| Viola | 5 | **Cifrari** | Ombra | Il Sabotaggio inflitto dura il 25% in più | — |
| Viola | 6 | **Metodo scientifico** | Conoscenza | Peculiarità **Biblioteca reale** (+25% Ricerca prodotta) | — |

Le tecnologie che danno una peculiarità non compaiono se la nazione ha già quella peculiarità.

### 6 quinquies.4 Tecnologie esclusive

Compaiono solo per chi ha la via o il popolo, alla prima altezza della loro era e nel ramo della loro sfera. Costano come le altre della stessa altezza.

**Vie (13)**

| Via | Era | Tecnologia | Sfera | Effetto |
|---|---:|---|---|---|
| Commercio | 2 | **Rotte carovaniere** | Ricchezza | +1 Oro per stagione da ogni edificio Infrastruttura Strategica |
| Commercio | 3 | **Monopoli** | Ricchezza | +10% Oro prodotto |
| Guerra | 2 | **Veterani di cento battaglie** | Militare | Le truppe Fante che fanno danno ne fanno 1 in più |
| Guerra | 3 | **Arte della guerra** | Militare | +1 spazio truppa |
| Fede | 2 | **Pellegrinaggi** | Fede | +1 Fede per stagione dalla Capitale |
| Fede | 3 | **Concilio** | Fede | Gli elementi Spirituali che curano curano 1 in più |
| Sapere | 2 | **Enciclopedia** | Conoscenza | +1 Ricerca per stagione da ogni edificio Accademico |
| Sapere | 3 | **Accademie reali** | Conoscenza | +20% Ricerca prodotta |
| Impero | 3 | **Legioni di frontiera** | Militare | +10 Resistenza in ogni scontro |
| Oro | 3 | **Zecca** | Ricchezza | +1 Oro per stagione da ogni edificio Economico |
| Rivelazione | 3 | **Miracoli** | Fede | Gli elementi Spirituali che producono scudo ne producono 2 in più |
| Ombra | 3 | **Gilda degli assassini** | Ombra | Le truppe Criminali fanno il 15% di danno in più |
| Spiriti | 3 | **Canti degli antenati** | Terra | Gli edifici Fauna producono il 10% più in fretta |

**Popoli (9).** Sono i popoli della v0.24 (§9.4.1 del GDD); le tecnologie di Pietrosangue e Maremani vengono da quelle pensate per Montanari e Popolo del delta, quelle dei Cinerali sono nuove e usano il loro tipo d’identità.

| Popolo | Era | Tecnologia | Sfera | Effetto |
|---|---:|---|---|---|
| Pietrosangue | 1 | **Scalpellini** | Opera | +1 Pietra per stagione dalla Capitale |
| Pietrosangue | 2 | **Rocche di montagna** | Militare | Gli elementi Guardiani che producono scudo ne producono 1 in più |
| Pietrosangue | 3 | **Cuore di pietra** | Opera | +10 Resistenza in ogni scontro |
| Maremani | 1 | **Chiatte** | Ricchezza | +1 Oro per stagione da ogni edificio Infrastruttura Strategica |
| Maremani | 2 | **Canali** | Terra | +1 Cibo per stagione da ogni edificio di Materie prime |
| Maremani | 3 | **Porto franco** | Ricchezza | Rinnovare le opportunità costa 1 Oro in meno |
| Cinerali | 1 | **Vedette delle scogliere** | Militare | Le truppe Cinerali ricaricano il 10% più in fretta |
| Cinerali | 2 | **Forgia vulcanica** | Opera | +1 Ferro per stagione dalla Capitale |
| Cinerali | 3 | **Pioggia di cenere** | Militare | Le truppe Cinerali fanno il 15% di danno in più |

### 6 quinquies.5 Linee di elementi

Una linea ha una versione per era (GDD §10.5.5). Le versioni **non sono nel catalogo base**: compaiono fra le opportunità solo dopo la tecnologia. Come gli esclusivi (§1.5) hanno **+1 punto** di budget e costano il costo base della loro era.

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

| Edificio | Era | Tipi | Colore | Per stagione | Nello scontro | Punti |
|---|---:|---|---|---|---|---:|
| Orti | 1 | Materie prime | verde | Oro 1, Cibo 2, Legno 2 | 1 mana ogni 2 s | 5 |
| Poderi | 2 | Materie prime | verde | Oro 1, Cibo 3, Legno 3 | 1 mana ogni 1,5 s | 6,7 |
| Latifondi | 3 | Materie prime | verde | Oro 2, Cibo 4, Legno 3 | 1 mana ogni 1 s | 9,5 |
| Scriptorium | 1 | Accademico | viola | Ricerca 1, Documenti 2 | 1 mana ogni 1,5 s | 4,7 |
| Collegio | 2 | Accademico | viola | Ricerca 2, Documenti 2 | 1 mana ogni 1 s | 7 |
| Ateneo | 3 | Accademico | viola | Ricerca 3, Documenti 3 | 1 mana ogni 1 s | 8,5 |

### 6 quinquies.6 Studioso e carte dorate

- **Revisione dei piani** (Studioso, nuova): 2 Documenti, ripesca la mano delle tecnologie.
- Il **Mercante** del Tesoriere (2 Ricerca → 4 Oro) è tolto (GDD v0.26). Dove le vie e i Maremani lo rendevano più frequente, ora rendono più frequenti gli **Esattori**.
- **Carte dorate** (GDD §10.5.6), primi esempi: l’evento **La disputa dei dotti** e la fortuna **La biblioteca ritrovata** danno, oltre ai loro effetti, una tecnologia di Conoscenza già iniziata a metà; gli incontri del mondo generati possono offrire fra le ricompense una tecnologia già iniziata.

---

## 6 sexies. Cronache della nazione (GDD §9.6, v0.29)

Tutto placeholder. File in `data/catalog/cronache/`, `usanze/`, `vocazioni/`, `personaggi/`. Le reazioni mostrano in gioco dove spingono la nazione; ogni cronaca ha almeno una reazione gratuita.

### 6 sexies.1 Spinte iniziali sulle inclinazioni

| Elemento | Spinta |
|---|---|
| Pietrosangue | → Chiusa |
| Cinerali | → Conquistatrice |
| Maremani | → Aperta |
| Monarchia | → Ordinata |
| Monarchia assoluta | → Ordinata ×2 |
| Monarchia costituzionale | → Pacifica, → Ordinata |
| Repubblica | → Libera |
| Repubblica parlamentare | → Pacifica, → Libera |
| Oligarchia | → Aperta |
| Plutocrazia | → Aperta |
| Dittatura | → Conquistatrice, → Ordinata |
| Totalitarismo | → Chiusa, → Ordinata ×2 |
| Teocrazia | → Devota |
| Ierocrazia | → Devota ×2 |
| Culto solare | → Devota |
| Culto degli antenati | → Chiusa, → Devota |
| Culto del vuoto | → Conquistatrice, → Devota |
| Spiriti dei luoghi | → Pacifica, → Devota |
| Cultura guerriera | → Conquistatrice |
| Cultura mercantile | → Aperta |
| Cultura erudita | → Profana |
| Cultura artigiana | → Ordinata |

### 6 sexies.2 Usanze (a ±5)

| Usanza | Polo | Effetto | Storia |
|---|---|---|---|
| Trofei di guerra | Conquistatrice | +1 Oro per ogni incontro del mondo vinto. | Dall'anno {anno} il popolo espone nelle piazze i trofei dei vinti. |
| Ambasciate permanenti | Pacifica | +1 Influenza all'inizio di ogni stagione. | Dall'anno {anno} le ambasciate non chiudono mai, nemmeno in guerra. |
| Porti franchi | Aperta | I Visitatori compaiono più spesso nei round del Consiglio. | Dall'anno {anno} chiunque può attraccare e vendere senza pagare dazio. |
| Mura dei padri | Chiusa | +5 Resistenza in ogni scontro; i Visitatori compaiono più di rado. | Dall'anno {anno} nessuno straniero dorme dentro le mura. |
| Processioni | Devota | +1 Fede all'inizio di ogni stagione. | Dall'anno {anno} a ogni stagione le statue degli dei girano per le strade. |
| Accademie laiche | Profana | +1 Ricerca all'inizio di ogni stagione. | Dall'anno {anno} nelle accademie si insegna che gli dei non rispondono. |
| Il grande catasto | Ordinata | +1 Documenti all'inizio di ogni stagione. | Dall'anno {anno} ogni campo, casa e famiglia è scritta in un registro. |
| Mercato nero tollerato | Libera | Le azioni del Maestro delle spie costano 1 unità in meno (almeno 1). | Dall'anno {anno} le guardie guardano altrove quando passano i contrabbandieri. |

### 6 sexies.3 Vocazioni

| Vocazione | Nasce da | Che cosa cambia |
|---|---|---|
| Assimilatori | Trofei di guerra + Mura dei padri | Dopo un incontro vinto puoi prendere, al posto della ricompensa, una truppa del nemico: diventa tua, con il tipo Assimilato e quello del tuo popolo. Ogni assimilazione porta +1 Malcontento. |
| Repubblica mercantile | Porti franchi + Mercato nero tollerato | Le opportunità costano 1 Oro in meno, i Visitatori compaiono molto più spesso e al mercato basta 1 unità in meno per 1 Oro. |
| Teocrazia profetica | Processioni + Il grande catasto | All'inizio di ogni anno una profezia rivela una truppa del fantasma. |
| Popolo errante | Porti franchi + Ambasciate permanenti | Nel primo round di ogni stagione c'è sempre un Visitatore nei round del Consiglio. |
| Stato di polizia | Il grande catasto + Mura dei padri | Il Malcontento non supera mai la soglia di avviso, ma la Stabilità chiesta dalle azioni costa il doppio. |

### 6 sexies.4 Personaggi

| Personaggio | Nomi |
|---|---|
| Generale | Varo, Ilda, Brenno, Sefra, Taddeo, Orsola |
| Erede | Aurelio, Mirta, Leandro, Isaura, Corrado, Viola |
| Profeta | Anselmo, Ysolde, Gaspare, Nives, Orfeo |
| Mercante straniero | Dario di Calce, Zenobia, Ismail, Fiorenza, Lucano |

### 6 sexies.5 Cronache (35)

| Cronaca | Momento | Condizioni | Reazioni |
|---|---|---|---|
| **La notte più lunga** — Nel solstizio d'inverno {nazione} accende i fuochi sulle colline e conta chi non è tornato dall'anno passato. | Solstizio d'inverno | ripetibile | Onora i caduti (Il loro sangue chiede altre vittorie.; → Conquistatrice) · Prega per un anno di pace (→ Pacifica, → Devota) · Fai festa fino all'alba (Paghi 2 Oro; il Malcontento scende di 1.; → Libera) |
| **I conti dell'inverno** — I granai di {nazione} sono mezzi vuoti e gli scribi portano i registri dell'anno. | Solstizio d'inverno | ripetibile | Razionamento severo (Ricevi 1 Stabilità.; → Ordinata) · Apri i granai al popolo (Paghi 1 Cibo; il Malcontento scende di 1.; → Libera) · Compra grano dagli stranieri (Paghi 3 Oro, ricevi 2 Cibo.; → Aperta) |
| **Il disgelo** — La neve si ritira dai passi. I giovani di {nazione} guardano oltre i confini. | Equinozio di primavera | ripetibile | Mandali a esplorare (Ricevi 1 Ricerca.; → Aperta) · Arruolali (Ricevi 1 Ferro.; → Conquistatrice) · Tienili a casa, nei campi (Ricevi 1 Cibo.; → Chiusa) |
| **Le nascite di primavera** — È una primavera di molte nascite. Le levatrici di {nazione} dicono che è un segno. | Equinozio di primavera | ripetibile | Un segno degli dei (Ricevi 1 Fede.; → Devota) · Più braccia per lo Stato (Ricevi 1 Legno.; → Ordinata) · Solo bocche da sfamare (→ Profana) |
| **La festa del giorno più lungo** — Nel solstizio d'estate {nazione} si ferma per tre giorni. Come vuoi che si festeggi? | Solstizio d'estate | ripetibile | Giochi di guerra (Ricevi 1 Ferro.; → Conquistatrice) · Fiera degli stranieri (Ricevi 2 Oro.; → Aperta) · Riti nei templi (Ricevi 1 Fede.; → Devota) |
| **La calura** — Un'estate feroce: fiumi bassi, animi accesi. Nelle piazze scoppiano risse. | Solstizio d'estate | ripetibile | Pugno duro sulle risse (Ricevi 1 Stabilità.; → Ordinata) · Lascia sfogare il popolo (Il Malcontento scende di 1.; → Libera) · Scava nuovi pozzi (Paghi 1 Pietra, ricevi 1 Cibo.; → Chiusa) |
| **Il raccolto** — L'equinozio d'autunno porta il raccolto. Che cosa ne fa {nazione}? | Equinozio d'autunno | ripetibile | La decima al tempio (Paghi 1 Cibo, ricevi 2 Fede.; → Devota) · Vendi l'eccedenza (Paghi 1 Cibo, ricevi 3 Oro.; → Aperta) · Riempi i magazzini dell'esercito (→ Conquistatrice, → Chiusa) |
| **I presagi d'autunno** — Corvi sulla capitale. Si dice che il fantasma dell'anno sia già in cammino. | Equinozio d'autunno | ripetibile | Consulta gli indovini (Paghi 1 Fede: una tessera del fantasma partirà inefficiente.; → Devota) · Rafforza le mura (Paghi 2 Pietra: +5 Resistenza nel prossimo scontro con il fantasma.; → Chiusa) · Sono solo uccelli (→ Profana) |
| **Tre vittorie di fila** — Tre vittorie di fila. Per le strade si canta il nome di {nazione}, e qualcuno comincia a dire che il mondo è nostro. | Solstizio d'inverno, Solstizio d'estate, Equinozio d'autunno | 3 vittorie di fila | Celebra il trionfo (Il Malcontento scende di 1.; → Conquistatrice ×2) · Resta umile (→ Pacifica, → Devota) · Fai sfilare i prigionieri in catene (Ricevi 1 Stabilità.; → Conquistatrice, → Chiusa) |
| **La sconfitta brucia** — La sconfitta contro {nemico} brucia ancora. Il popolo cerca qualcuno da incolpare. | Solstizio d'inverno, Solstizio d'estate, Equinozio d'autunno | ripetibile; ultimo scontro perso | Trova un colpevole (Il Malcontento scende di 1.; → Ordinata) · Giura vendetta (+5 Resistenza nel prossimo scontro con il fantasma.; → Conquistatrice) · Accetta il verdetto degli dei (→ Pacifica, → Devota) |
| **Il popolo mormora** — Nelle taverne si parla male del governo di {nazione}. Qualcuno ha scritto parole d'odio sui muri. | qualsiasi | ripetibile; Malcontento almeno 4 | Reprimi (Il Malcontento scende di 1.; → Chiusa, → Ordinata) · Ascolta le richieste (Paghi 3 Oro; il Malcontento scende di 2.; → Libera) · Lascia correre (→ Libera) |
| **La città dei ladri** — Nei vicoli di {nazione} c'è più legge dei ladri che legge dello Stato. | qualsiasi | almeno 3 tessere Criminale | Tollera, in cambio di una parte (Ricevi 2 Documenti e 1 Oro.; → Libera) · Una grande retata (Il Malcontento sale di 1.; → Ordinata ×2) · Arruola i migliori (Ricevi 1 Ferro.; → Conquistatrice, → Libera) |
| **Stranieri alle porte** — Una carovana di profughi chiede di entrare in {nazione}: fuggono da una guerra lontana. | Equinozio di primavera, Solstizio d'estate | — | Accoglili (Ricevi 1 Legno; il Malcontento sale di 1.; → Aperta ×2) · Respingili (→ Chiusa ×2) · Prendi i forti, respingi i deboli (Ricevi 1 Ferro.; → Conquistatrice, → Chiusa) |
| **Il tempio e il palazzo** — I sacerdoti chiedono che sia il tempio a scegliere i giudici di {nazione}. | qualsiasi | dall'anno 2 | Concedi (Ricevi 1 Fede.; → Devota, → Ordinata) · La legge è dello Stato (Ricevi 1 Stabilità.; → Profana, → Ordinata) · Decidano le città (→ Libera ×2) |
| **La processione infinita** — {nazione} è sempre più devota. Una processione blocca la capitale da giorni. | qualsiasi | 3 passi verso Devota | Unisciti alla processione (Ricevi 2 Fede.; → Devota) · Disperdi la folla (Il Malcontento sale di 1.; → Profana, → Ordinata) |
| **I veterani affamati di guerra** — {nazione} ha fame di guerra. I veterani chiedono nuove campagne. | qualsiasi | 3 passi verso Conquistatrice | Prepara la prossima campagna (Le truppe fanno il 10% di danno in più per un anno.; → Conquistatrice) · Calma gli animi (Ricevi 1 Stabilità.; → Pacifica) |
| **Le porte sbarrate** — Le porte di {nazione} restano chiuse anche di giorno. I mercanti stranieri smettono di venire. | qualsiasi | 3 passi verso Chiusa | Va bene così (Ricevi 1 Pietra.; → Chiusa) · Riapri il mercato (Ricevi 2 Oro.; → Aperta) |
| **I libelli** — In {nazione} circolano libelli e canzoni che deridono il governo. | qualsiasi | 3 passi verso Libera | Lasciali scrivere (Ricevi 1 Documenti; il Malcontento scende di 1.; → Libera) · Censura (Ricevi 1 Stabilità.; → Ordinata) |
| **Il prigioniero** — Dopo la vittoria su {nemico} i soldati portano un prigioniero illustre: il figlio del loro capo. | Solstizio d'estate, Equinozio d'autunno | ultimo scontro vinto | Liberalo con onore (→ Pacifica, → Aperta; ricordo prigioniero_liberato) · Tienilo come ostaggio (Ricevi 2 Influenza.; → Ordinata; ricordo prigioniero_ostaggio) · Giustizialo davanti al popolo (Il Malcontento scende di 1.; → Conquistatrice, → Chiusa; ricordo prigioniero_giustiziato) |
| **Il dono del liberato** — Il prigioniero liberato è tornato dai suoi. Oggi suo padre manda doni e parole di amicizia. | qualsiasi | ricordo: prigioniero_liberato | Accetta l'amicizia (Ricevi 3 Oro e 1 Influenza.; → Aperta) · Prendi i doni, non l'amicizia (Ricevi 2 Oro.; → Chiusa) |
| **Il riscatto dell'ostaggio** — La famiglia dell'ostaggio offre un riscatto per riaverlo. | qualsiasi | ricordo: prigioniero_ostaggio | Accetta il riscatto (Ricevi 5 Oro.) · Tienilo: vale di più qui (Ricevi 1 Influenza.; → Ordinata) |
| **L'ombra del giustiziato** — Il popolo del prigioniero giustiziato non ha dimenticato. Ai confini compaiono bande che portano il suo nome. | qualsiasi | ricordo: prigioniero_giustiziato | Schiacciali (Paghi 1 Ferro, ricevi 1 Stabilità.; → Conquistatrice) · Paga per la pace (Paghi 4 Oro.; → Pacifica) · Lasciali venire (−5 Resistenza nel prossimo scontro con il fantasma.) |
| **Il giovane capitano** — Un giovane capitano si è distinto in battaglia. I soldati di {nazione} lo seguirebbero ovunque. | Equinozio di primavera, Solstizio d'estate, Equinozio d'autunno | dall'anno 2 | Promuovilo generale (Entra nella storia un generale, fedele.; → Conquistatrice) · Promuovilo, ma tienilo d'occhio (Entra nella storia un generale, sospettoso.; → Ordinata) · Rimandalo nei ranghi |
| **Il generale chiede gloria** — {personaggio}, il tuo generale, chiede di guidare la prossima campagna. | qualsiasi | con il generale (fiducia ≥ 0) | Concedigli il comando (Una truppa sale di un livello; il generale si fida di più.; → Conquistatrice) · Il comando resta a corte (Il generale si fida di meno.; → Ordinata) |
| **Il generale trama** — Le spie riferiscono che {personaggio} incontra di notte i capi dell'esercito. | qualsiasi | con il generale (fiducia ≤ -1) | Arrestalo (Il generale esce dalla storia; il Malcontento sale di 1.; → Ordinata; ricordo generale_arrestato) · Compralo (Paghi 5 Oro; il generale si fida di più.) · Fingi di non sapere (Il generale si fida ancora di meno.) |
| **Il colpo di stato** — {personaggio} marcia sulla capitale con metà dell'esercito. | qualsiasi | con il generale (fiducia ≤ -2) | Combatti (Il generale esce dalla storia; il Malcontento sale di 2.; → Conquistatrice) · Cedi parte del potere (Il Malcontento scende di 1; il generale si fida di più.; → Libera ×2) · Fallo sparire (Paghi 2 Documenti: il generale esce dalla storia.; → Profana, → Ordinata) |
| **Nasce un erede** — Nella notte del solstizio nasce l'erede di {nazione}. Bisogna decidere chi lo crescerà. | Solstizio d'inverno | dall'anno 2 | Fra i soldati (Entra nella storia l'erede.; → Conquistatrice; ricordo erede_soldato) · Fra i sacerdoti (Entra nella storia l'erede.; → Devota; ricordo erede_devoto) · Fra gli studiosi (Entra nella storia l'erede; ricevi 1 Ricerca.; → Profana; ricordo erede_studioso) |
| **L'erede parla al consiglio** — {personaggio} è cresciuto. Oggi parla per la prima volta davanti al consiglio di {nazione}. | qualsiasi | dall'anno 4; con il erede | Ascoltalo (Ricevi 2 Influenza; l'erede si fida di più.) · Mettilo a tacere (L'erede si fida di meno.; → Ordinata) |
| **Il profeta** — Un eremita scende dai monti: dice di aver visto in sogno il fantasma dell'anno. | Equinozio d'autunno | dall'anno 2 | Ascoltalo (Entra nella storia un profeta; ricevi 1 Fede.; → Devota) · Scaccialo (→ Profana) |
| **La profezia** — {personaggio} il profeta ha parlato di nuovo: sa dove colpirà il fantasma. | Equinozio d'autunno | con il profeta (fiducia ≥ 0) | Segui la profezia (Un elemento del fantasma partirà sabotato; il profeta si fida di più.; → Devota) · Basta profezie (Il profeta esce dalla storia.; → Profana) |
| **Il mercante straniero** — Un mercante dai porti lontani chiede il permesso di aprire un banco nella capitale di {nazione}. | Equinozio di primavera, Solstizio d'estate | dall'anno 2 | Concedi il banco (Entra nella storia un mercante; ricevi 2 Oro.; → Aperta) · Concedi, con una tassa pesante (Entra nella storia un mercante, scontento; ricevi 4 Oro.; → Ordinata) · Mandalo via (→ Chiusa) |
| **L'affare del mercante** — {personaggio} propone un affare: le sue navi in cambio del tuo ferro. | qualsiasi | con il mercante (fiducia ≥ 0) | Accetta (Paghi 2 Ferro, ricevi 6 Oro.; → Aperta) · Rifiuta (Il mercante si fida di meno.) |
| **Gli assimilati** — Gli assimilati lavorano nei campi di {nazione}, ma di notte cantano nella loro lingua. | qualsiasi | ricordo: assimilati | Proibisci la loro lingua (Ricevi 1 Stabilità.; → Chiusa, → Ordinata) · Lasciali cantare (→ Aperta) · Convertili alla nostra fede (Paghi 1 Fede; il Malcontento scende di 1.; → Devota) |
| **La rivolta degli assimilati** — Gli assimilati si sono ribellati: chiedono di tornare quello che erano. | qualsiasi | Malcontento almeno 3; ricordo: assimilati | Reprimi (Il Malcontento scende di 1.; → Conquistatrice, → Ordinata) · Concedi diritti (Paghi 2 Oro; il Malcontento scende di 2.; → Aperta, → Libera) |
| **Una nazione diversa** — Le usanze di {nazione} si sono intrecciate. Gli anziani dicono che il popolo è pronto a diventare qualcosa di nuovo: {vocazione}. | qualsiasi | offre una vocazione | Restiamo come siamo (Rifiuti la vocazione: non tornerà.) |


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
| Esclusivi dell’identità | 6 | 16 | 6 | 28 |
| Peculiarità | 11 (7 esistenti + 4 nuove) | | | 11 |
| Malus | 12 (6 esistenti + 6 nuovi) | | | 12 |
| Consiglieri | 8 ordinari + Giullare e Anziano | | | 10 |
| Azioni del Consiglio | 40 (senza il Mercante e con Revisione dei piani, v0.26; di cui 6 esclusive dell’identità, compresi 4 incanti dei credi, e 3 dal livello Ministri) | | | 40 |
| Eventi / Fortune / Visitatori | 30 (27 + Riforma, Tumulti, Rivoluzione) / 6 / 6 | | | 42 |
| Tecnologie base | 12 | 12 | 12 | 36 |
| Tecnologie esclusive (vie / popoli) | 0 / 3 | 4 / 3 | 9 / 3 | 13 / 9 |
| Elementi delle linee | 2 + 2 | 2 + 2 | 2 + 2 | 12 |
