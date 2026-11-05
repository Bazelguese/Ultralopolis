# ULTRALOPOLIS — Bozza di aggiornamento del GDD (v0.23)
## Eventi, Visitatori e Fortune nei round del Consiglio

**Data:** 5 novembre 2026
**Stato:** **bozza da approvare.** Niente di questo documento è ancora nel GDD né nel gioco. Raccoglie le decisioni prese con Davide e propone le regole e un primo catalogo, tutto placeholder.
**Riferimento:** `docs/Ultralopolis_GDD.md` v0.22

Stati come nel GDD (§0.2): **Confermato** = deciso da Davide; **Proposta** = suggerito da Claude, da approvare; **Spunto** = idea per il futuro, da non implementare.

**Modifica del nucleo.** Cambia che cosa può comparire in un round (§4.2, Parte I). Gli effetti invece usano solo il linguaggio che esiste già (risorse, carte, livelli, spazi, modificatori, spionaggio): nessuna nuova famiglia di effetti (principio P5).

---

## 1. Decisioni

| # | Decisione | Stato |
|---|---|---|
| 1 | Nei round, oltre ai consiglieri, possono comparire **Eventi**, **Visitatori** e **Fortune**. Altre famiglie legate al GDR restano possibili | Confermato |
| 2 | Compaiono **al posto di un consigliere**: delle 3 carte del round, al massimo una è di queste famiglie | Confermato |
| 3 | Compaiono con una probabilità scritta nei dati: in media in **1 round su 3** | Confermato nella forma; valore placeholder |
| 4 | Nessun evento arriva da solo, senza essere scelto | Confermato per ora; gli eventi forzati restano uno **Spunto** |
| 5 | Ogni carta ha una **sfera**: una delle 8 categorie del Consiglio (§4.2.4) | Confermato |
| 6 | Ogni carta ha delle **radici**, che la rendono esclusiva o più frequente: elementi dell'identità, vie, era, tipi sulla plancia, stato della nazione | Confermato |
| 7 | Le **opzioni** di un evento possono essere sbloccate dalla nazione: identità, tipi sulla plancia, risorse | Confermato |

---

## 2. Regole proposte — nuova §4.2.5 del GDD

### 2.1 Nel round

| Regola | Stato |
|---|---|
| Quando il round pesca le sue 3 carte, con la probabilità dei dati (placeholder 33%) una delle tre è un Evento, un Visitatore o una Fortuna, al posto di un consigliere | Proposta |
| Fra le tre famiglie si pesca con pesi scritti nei dati (placeholder: Eventi 5, Visitatori 3, Fortune 2) | Proposta |
| Le carte nuove **ignorano il tema del round**, come Clown e Anziano | Proposta |
| Sceglierla è la scelta del round, definitiva come quella di un consigliere. Si può sempre passare | Proposta |
| Non offrono Potenzia (salvo che un'opzione lo dia esplicitamente) | Proposta |
| Un evento compare **una sola volta per run**, salvo quelli segnati come ripetibili; Visitatori e Fortune possono tornare, ma non due volte nello stesso anno | Proposta |

### 2.2 Le tre famiglie

| Famiglia | Come funziona | Stato |
|---|---|---|
| **Evento** | Un testo e da 2 a 3 opzioni. Ogni opzione ha un costo, che può anche essere zero, e un effetto. Scelta un'opzione, il round si chiude | Proposta |
| **Visitatore** | Un consigliere di passaggio: mostra 3 proposte prese dalla sua lista (carte, anche di altre nazioni o di un'altra era, e azioni), con i suoi prezzi. Si rinnova solo in Oro | Proposta |
| **Fortuna** | Un dono semplice, senza scelte difficili: prendendolo, il round si chiude | Proposta |

### 2.3 Sfera e radici

| Regola | Stato |
|---|---|
| La **sfera** è una delle 8 categorie (Militare, Opera, Terra, Ricchezza, Conoscenza, Fede, Stato, Ombra): dice di che cosa parla la carta e dà la tendenza delle risorse che usa e del colore della cornice | Proposta |
| Le **radici** usano lo stesso schema delle vie (§10.4): **richiede** (la carta compare solo se la nazione ne ha almeno una) e **favorita da** (+1 di peso per ciascuna) | Proposta |
| Radici possibili: elemento dell'identità (popolo, governo, credo, cultura, perk), via, era minima e massima, tipi presenti sulla plancia, stato della nazione (una risorsa sopra una soglia, un malus attivo) | Proposta |

### 2.4 Opzioni sbloccate dalla nazione

| Regola | Stato |
|---|---|
| Un'opzione può chiedere un **requisito**: un elemento dell'identità, una carta con un certo tipo sulla plancia, una quantità di una risorsa | Proposta |
| Un'opzione bloccata **si vede comunque**, spenta, con il requisito scritto accanto: il giocatore capisce che cosa avrebbe potuto fare un'altra nazione (principio P4) | Proposta |
| Ogni evento ha almeno un'opzione senza requisiti | Proposta |

### 2.5 Che cosa possono fare le opzioni (linguaggio del nucleo, P5)

- dare o togliere risorse;
- dare un edificio o una truppa (precisa, oppure a caso fra quelle dell'era con un certo tipo), con le regole della sostituzione;
- potenziare una carta a scelta con un certo tipo;
- dare uno spazio edificio o truppa;
- applicare un modificatore (bonus per un anno, per il prossimo scontro con il fantasma, oppure permanente);
- uno spionaggio sul fantasma dell'anno.

Il recupero del Prestigio resta escluso, perché il GDD non lo prevede (Parte III).

---

## 3. Catalogo proposto — Eventi (18, placeholder)

Notazione delle opzioni: **[requisito]** = opzione sbloccata solo con quel requisito. "Per un anno" segue §8.2.1. I valori seguono più o meno il budget del Catalogo (1 Oro ≈ 1 Ricerca ≈ 2 unità delle altre risorse).

### 3.1 Uno per ogni elemento dell'identità

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

### 3.2 Generici, legati all'era

| Evento | Sfera | Radici | Opzioni |
|---|---|---|---|
| **Banditi sulla strada** | Ombra | era 1 | Scorta armata: 2 Ferro → +3 Oro · Assoldali: 3 Oro → ricevi i Tagliagole (se c'è spazio) · **[Criminale]** Un accordo nell'ombra: +2 Documenti |
| **Un inverno lungo** | Terra | era 1 | Razionamento: 2 Legno → per un anno le truppe mangiano la metà · Granai del re: 3 Oro → +4 Cibo · **[Produzione]** I campi resistono: +3 Cibo |
| **Gli esuli** | Stato | era 2 | Accoglili: 2 Cibo → +3 Stabilità · Arruolali: 4 Oro → ricevi una truppa dell'era, a caso · **[Patriota]** Nuovi patrioti: +2 Stabilità e +2 Influenza |
| **Febbre nei quartieri** | Fede | era 2 | Ospedali da campo: 3 Fede → +3 Stabilità · Chiudi le porte: +4 Stabilità, ma per un anno la Ricerca prodotta si dimezza · **[Spirituale]** I monaci curano: +2 Fede |
| **La grande opera** | Opera | era 3 | Costruiscila: 5 Pietra → +1 spazio edificio · Rimandala: +2 Pietra · **[Infrastruttura Strategica]** Ingegneri esperti: 3 Pietra → +1 spazio edificio |
| **Congiura a corte** | Ombra | era 3 | Reprimi: 3 Stabilità → +10 Resistenza nel prossimo scontro con il fantasma · Infiltra i congiurati: 3 Documenti → la truppa più veloce del fantasma parte sabotata per 5 s · **[Legge]** Processo pubblico: +4 Stabilità |

---

## 4. Catalogo proposto — Visitatori (6, placeholder)

| Visitatore | Sfera | Radici | Che cosa propone (3 alla volta) | Prezzi |
|---|---|---|---|---|
| **Mercanti del delta** | Ricchezza | favoriti da Popolo del delta e Via del Commercio | Edifici Economici dell'era, compresi gli esclusivi di altre nazioni (Porto fluviale, Fondaco…) | Oro +1 |
| **Compagnia di ventura** | Militare | favorita da Cultura guerriera e Via della Guerra | Truppe Fante dell'era e di quella successiva | Oro +1; +3 per l'era successiva |
| **Pellegrini** | Fede | favoriti da Teocrazia e dai credi | Incanti del Sacerdote ed elementi Spirituali dell'era | come il Sacerdote |
| **Ambasciatore straniero** | Stato | dall'era 2; favorito da Monarchia e Repubblica | Ambasciata, Decreto fiscale, Dono diplomatico (+3 Influenza) | come il Cancelliere |
| **Contrabbandiere** | Ombra | richiede una carta Criminale sulla plancia o la Via dell'Ombra | Carte Criminali ed esclusivi di altre identità (Arcieri dei boschi, Guardie delle vette…) | Oro −1 e 1 Documenti |
| **Inventore errante** | Conoscenza | favorito da Ordine della Ragione e Cultura erudita; non nell'ultima era | Carte dell'era successiva, in anteprima | Oro +3 |

---

## 5. Catalogo proposto — Fortune (6, placeholder)

I valori crescono con l'era: il numero indicato va moltiplicato per l'era corrente.

| Fortuna | Sfera | Favorita da | Dono |
|---|---|---|---|
| **Raccolto abbondante** | Terra | Popolo del delta, Antichi spiriti | +3 Cibo |
| **Una vena d'argento** | Opera | Montanari | +2 Ferro e +2 Oro |
| **Visione sacra** | Fede | Culto del Sole, Teocrazia | +3 Fede |
| **La biblioteca ritrovata** | Conoscenza | Cultura erudita, Ordine della Ragione | +2 Documenti e +1 Ricerca |
| **Festa del popolo** | Stato | Repubblica, Monarchia | +2 Stabilità e +1 Influenza |
| **Bottino dimenticato** | Militare | Cultura guerriera | +3 Ferro |

---

## 6. Spunti (da non implementare ora, la base non deve impedirli)

| Spunto | Nota |
|---|---|
| **Eventi forzati**: arrivano da soli e chiedono solo come reagire | Decisione 4. Andranno rispettati P1 e P4. |
| **Catene di eventi**: una scelta sblocca un evento negli anni successivi | Richiede che la nazione ricordi le scelte fatte: la base salva già l'identità e i modificatori. |
| **Personaggi ricorrenti**: un visitatore che torna e ricorda i rapporti avuti | Come le catene, con un nome proprio. |
| **Tratti acquisiti**: un evento lascia un tratto permanente che diventa parte dell'identità | Primo passo verso riforme e conversioni (§9.1). |
| **Altre famiglie GDR** (scoperte, crisi, alleanze…) | Decisione 1: la struttura resta aperta. |

---

## 7. Che cosa servirà nel gioco (dopo l'approvazione)

- Dati nuovi: una scheda per Eventi e Fortune (testo, sfera, radici, opzioni con requisito, costo ed effetto) e una per i Visitatori (lista di proposte e regole di prezzo). Come per i consiglieri, si modificano dall'Ispettore di Godot.
- La pesca del round con la carta non-consigliere; la schermata dell'evento con le opzioni bloccate visibili.
- Test sui casi principali: probabilità e massimo una per round, radici, opzioni bloccate, evento una volta per run.
- Aggiornamento del GDD (§4.2.5 nuova, §13, §16.3, §17, Parte III) e del Catalogo.

## 8. Domande per Davide

1. Le **regole** della §2 vanno bene, in particolare "un evento una volta per run" e "le opzioni bloccate si vedono spente"?
2. Nel **catalogo** c'è qualcosa da togliere, cambiare o aggiungere?
3. I **pesi** (Eventi 5, Visitatori 3, Fortune 2) e la probabilità di 1 round su 3 vanno bene per cominciare?
