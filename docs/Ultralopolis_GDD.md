# ULTRALOPOLIS
## Game Design Document — v0.32

**Data:** 8 novembre 2026
**Stato:** base di design (nucleo) per il primo prototipo — v0.17 approvata dal creatore
**Motore scelto:** Godot 4.7 (GDScript, esportazione nativa per PC)
**Repository:** https://github.com/Bazelguese/Ultralopolis

---

## 0. Come leggere questo documento

### 0.1 Obiettivo del documento

Il gioco crescerà nel tempo con nuove meccaniche e nuovi contenuti. Questo documento serve a fissare una **base solida**: un cuore di regole su cui fare affidamento, in modo che le aggiunte future si innestino senza stravolgerlo.

Per questo il documento è diviso in livelli:

| Livello | Contenuto | Come cambia |
|---|---|---|
| **Parte I — Nucleo** | Le regole su cui si appoggia tutto il resto: struttura della run, economia, plancia, combattimento, linguaggio degli effetti. | Cambia raramente. Ogni modifica è una nuova versione del documento e va verificata contro i contenuti esistenti. |
| **Parte II — Sistemi** | Sistemi costruiti sul nucleo: identità, ere, fantasmi, spionaggio, eventi. | Si estendono aggiungendo contenuti e regole locali, senza toccare il nucleo. |
| **Parte III — Riserva di spunti** | Idee per il futuro, annotate ma deliberatamente non introdotte. | Entrano nei sistemi quando il gioco è pronto ad accoglierle. |
| **Parte IV — Prototipo e tecnica** | Confini del primo prototipo, architettura, criteri di verifica, decisioni aperte. | Si aggiorna a ogni iterazione di sviluppo. |

### 0.2 Stati delle indicazioni

| Stato | Significato |
|---|---|
| **Confermato** | Scelta approvata dal creatore; base del progetto. |
| **Direzione** | Obiettivo espresso per il gioco, con funzionamento dettagliato ancora da progettare. |
| **Proposta** | Possibile soluzione emersa, non ancora approvata come regola. |
| **Da definire** | Questione necessaria o utile, senza una soluzione concordata. |
| **Spunto** | Idea per il futuro, annotata in Parte III e volutamente non introdotta nella base. |

Uno spunto non è un obbligo: non deve essere soddisfatto dalla base, ma la base non deve renderlo impossibile.

### 0.3 Valori numerici e codice

I numeri di economia, mana, ricarica, danni, Resistenza e ricerca sono placeholder e non costituiscono bilanciamento approvato. Fanno eccezione i valori esplicitamente adottati per la struttura della run e della plancia iniziale.

Le versioni precedenti citavano una bozza di codice: quella bozza non è nel repository e il codice del prototipo parte da zero. Le convenzioni provvisorie necessarie a far funzionare il codice sono elencate in §16.3 e restano modificabili. Il documento non certifica che il codice sia stato eseguito o verificato in Godot.

---

## 1. Visione del gioco

Ultralopolis è un gioco strategico asincrono nel quale ogni partita è una run indipendente che racconta la crescita di una civiltà. Il giocatore costruisce la propria nazione, sviluppa un’economia, ricerca nuove ere tecnologiche e prepara una plancia che combatte automaticamente contro copie delle nazioni di altri giocatori e contro minacce del mondo.

La fantasia centrale è **vivere la nazione come un personaggio di un GDR**. Le decisioni devono costruire un’identità e una storia: non soltanto una produzione efficiente o un esercito potente, ma un popolo trasformato dalle proprie scelte, dagli eventi e dai nemici incontrati. Il tema di nazione e popolo viene portato avanti senza la classica struttura a turni, con il twist della battaglia automatica.

### 1.1 Riferimenti dichiarati

| Riferimento | Aspetto di interesse per Ultralopolis |
|---|---|
| Civilization / Stellaris | Identità della civiltà, sviluppo, ricerca, trasformazione e ingresso in nuove ere. |
| The Bazaar | Run asincrona, scansione in momenti di scelta, preparazione della plancia, scontro automatico contro fantasmi, struttura di vittorie e Prestigio. |
| 9 Kings | Riferimento generale dichiarato; nessuna sua regola specifica è stata adottata. |
| Villages & Dungeons | Ispirazione per il rapporto fra produzione di mana e attivazione delle unità. |

La tabella descrive le intenzioni del progetto; non è una ricostruzione integrale delle regole dei giochi citati.

### 1.2 Pilastri

1. **Nazione persistente dentro la run.** Edifici, esercito, risorse e conseguenze danno continuità alle scelte.
2. **Economia e guerra collegate.** Gli stessi edifici sostengono lo sviluppo fuori battaglia e alimentano le truppe durante lo scontro.
3. **Preparazione strategica, combattimento automatico.** Il giocatore organizza la plancia prima di vedere il risultato.
4. **Identità e conseguenze da GDR.** Popolo, istituzioni ed eventi rendono riconoscibile ogni partita.
5. **Asincronia.** I nemici sono copie; non è necessario che due persone giochino nello stesso momento.
6. **Realizzabilità grafica.** Il gioco funziona su una plancia 3D con pezzi 2D statici e feedback leggibile, senza eserciti animati complessi.

---

# PARTE I — NUCLEO

## 2. Principi di design del nucleo

Questi principi valgono per tutto il contenuto futuro. Un nuovo elemento che li viola richiede una discussione esplicita, non un’aggiunta silenziosa.

| # | Principio | Stato |
|---|---|---|
| P1 | **Le conseguenze negative deviano, non debilitano.** Un malus deve spingere il giocatore a ragionare in modo diverso per un periodo, non indebolirlo pesantemente. Esempio: produzione di Ricerca dimezzata per un anno, durante il quale il giocatore può orientarsi su altro. | Confermato |
| P2 | **La potenza segue il progresso.** Effetti molto forti non devono essere disponibili dall’inizio della run. | Direzione |
| P2a | Il meccanismo naturale per farlo sono le ere: gli effetti più forti vengono sbloccati da ere avanzate. | Confermato (v0.15) |
| P3 | **Gli edifici si distinguono per il rapporto fra le due funzioni.** La doppia funzione crea scelte solo se edifici diversi bilanciano diversamente produzione economica e mana (es. molta Ricerca e poco mana, poco Oro e molto mana). Se un edificio fosse migliore su entrambi i fronti, la scelta sparirebbe. | Proposta |
| P4 | **La battaglia deve spiegarsi da sola.** Il giocatore deve poter capire perché una truppa non si è attivata (mana insufficiente, ricarica, effetto nemico). Con la priorità da destra verso sinistra, la leggibilità fa parte della meccanica. | Proposta |
| P5 | **Il contenuto si esprime con il linguaggio del nucleo.** Nuovi edifici, truppe, eventi e malus vanno descritti con risorse, spazi, ricarica, mana, Resistenza e modificatori già esistenti (§8). Ciò che richiede una nuova famiglia di effetti o una nuova risorsa è una modifica del nucleo. | Proposta |

## 3. Struttura della run

### 3.1 Run indipendente — Confermato

Ogni partita è una nuova storia di una civiltà. “Campagna” descrive eventualmente la storia vissuta in quella run, non una campagna narrativa separata e permanente.

Gli elementi posseduti e le conseguenze persistono all’interno della run. Progressione permanente fra run, sblocchi di account o ricompense collezionabili non sono definiti.

### 3.2 Anni e stagioni — Confermato (modifica del nucleo, v0.25)

La run è divisa in anni. Ogni anno ha **12 round, uno per mese**, divisi in **quattro stagioni da 3 round**. L'anno comincia con l'**inverno** e si chiude con lo **scontro contro un fantasma** alla fine dell'autunno:

| Stagione | Mesi | Si chiude con |
|---|---|---|
| **Inverno** | gennaio, febbraio, marzo | nessuno scontro |
| **Primavera** | aprile, maggio, giugno | un **incontro del mondo** (§3.3) |
| **Estate** | luglio, agosto, settembre | un secondo **incontro del mondo** |
| **Autunno** | ottobre, novembre, dicembre | lo **scontro con il fantasma**, che chiude l'anno |

In ogni round il giocatore ascolta uno dei consiglieri della nazione (§4.2). Edifici e truppe si ottengono in **tutte le stagioni**.

| Regola | Stato |
|---|---|
| 12 round all'anno, uno per mese, in 4 stagioni da 3 | Confermato (v0.25) |
| L'anno va dall'inverno all'autunno: l'ultimo scontro dell'anno è il fantasma | Confermato (v0.25) |
| Primavera ed estate finiscono con un incontro del mondo, l'autunno con il fantasma; d'inverno non si combatte | Confermato (v0.25) |
| La produzione avviene all'inizio di ogni stagione; d'inverno gli edifici non producono Cibo (§5.2) | Confermato (v0.25) |
| L'inverno è la stagione della politica interna: eventi suoi, più azioni "interne", meno tessere militari (§4.2, §4.2.5) | Confermato (v0.25) |
| Ogni round mostra il **nome del mese** (es. "Anno 2 · Estate · Agosto") | Confermato (v0.25) |
| Edifici e truppe disponibili in tutte le stagioni | Confermato (v0.21) |
| Le stagioni sostituiscono le due metà Produzione e Preparazione (5 round, incontro, 5 round, fantasma) della v0.21 | Confermato (v0.25) |
| All'inizio di ogni stagione la nazione vive una **cronaca** (§9.6): Solstizio d'inverno, Equinozio di primavera, Solstizio d'estate, Equinozio d'autunno. Non consuma un round e non si salta; la produzione della stagione arriva dopo la reazione. Nel primo anno niente Solstizio d'inverno | Confermato (modifica del nucleo, v0.29) |

La durata in minuti della run non è ancora fissata. Con 12 round e 3 scontri un anno dura circa un quarto in più della v0.24.

### 3.3 Incontri del mondo — Confermato nella funzione, Da definire nei dettagli

Lo scontro contro il fantasma resta il momento centrale dell’anno, ma da solo lascia l’anno povero di tensione. Nel ruolo che in The Bazaar hanno gli scontri contro i mostri entrano gli **incontri del mondo**: minacce ed eventi legati al tema della nazione, ad esempio un’invasione di barbari o un attacco di pirati.

| Aspetto | Stato |
|---|---|
| Esistenza degli incontri come parte dell’anno | Confermato |
| Prima implementazione: solo scontri automatici contro una **plancia generata** | Confermato |
| In futuro, misto di scontri automatici ed eventi a scelta (testo e opzioni) | Direzione |
| Lo scontro usa la stessa simulazione del combattimento contro i fantasmi; la plancia generata ha la stessa struttura di una plancia giocatore | Proposta |
| Le 10 vittorie della run restano legate agli scontri contro i fantasmi; gli incontri del mondo non le modificano | Proposta |
| **Due incontri per anno**, in momenti fissi: alla fine della primavera e alla fine dell'estate (§3.2; struttura ispirata agli scontri con i mostri di The Bazaar) | Confermato (v0.25) |
| L'incontro d'estate è più forte di quello di primavera: a metà strada fra un anno e il successivo | Proposta (v0.25) |
| Il giocatore sceglie **fra 3 incontri** diversi (es. tre minacce di difficoltà e ricompensa diverse) | Confermato |
| Presenza nel primo prototipo | Confermato |
| La sconfitta ha **conseguenze leggere** | Confermato |
| Conseguenza della sconfitta: l’**Oro del Magazzino viene dimezzato** (arrotondato per difetto); **nessuna perdita di Prestigio** | Confermato; entità da tarare nel playtest |
| Una sconfitta durante l’ultima possibilità **termina la run** | Confermato |
| Ricompense per la vittoria: edifici, truppe, peculiarità, risorse o **tecnologie già iniziate** (carte dorate, §10.5.6, v0.26). Ogni incontro propone un **pool ristretto**; il giocatore sceglie **se e che cosa** prendere | Confermato (le tecnologie dalla v0.26) |
| Una vittoria (anche un pareggio) dà inoltre un **bottino fisso** di Oro e Ricerca, più alto per gli incontri più difficili | Confermato (v0.21); valori placeholder (§16.3) |
| Le plance generate diventano più forti con il passare degli anni; la loro Resistenza è fissata nei dati, senza il calcolo di §7.1 | Confermato; valori placeholder |
| Negli anni senza incontri scritti a mano, il gioco **genera** 3 incontri (facile, media, difficile) per ogni incontro dell'anno, dal catalogo, più forti con gli anni e con ricompense proporzionate | Confermato (v0.17; due volte all'anno dalla v0.25); regole di crescita placeholder (§16.3) |

### 3.4 Vittoria e fine della run — Base adottata

| Regola | Valore o comportamento |
|---|---|
| Vittorie necessarie | 10 scontri contro fantasmi vinti, anche non consecutivi. |
| Prestigio iniziale | 20. |
| Vittoria annuale | Aggiunge una vittoria al totale della run e dà un **bottino fisso** di Oro e Ricerca (Confermato v0.21; valori placeholder, §16.3). |
| Sconfitta annuale | Fa perdere Prestigio pari al numero dell’anno corrente. |
| Primo esaurimento del Prestigio | Attiva l’ultima possibilità; la run continua. |
| Sconfitta durante l’ultima possibilità | Termina la run. |

Valori adottati come base ispirata al sistema standard di The Bazaar. Non implicano che il bilanciamento di quel gioco sia automaticamente valido per Ultralopolis.

Esempio: perdere nell’anno 3 costa 3 Prestigio; perdere nell’anno 8 costa 8. Non esiste un numero fisso di sconfitte tollerate.

Non sono previste per ora regole per recuperare Prestigio o ricompense speciali all’attivazione dell’ultima possibilità.

**Pareggio — Confermato.** Il pareggio (entrambe le nazioni cadono nello stesso istante, per Resistenza a zero o per Corruzione, §7.5 e §7.6) conta come **vittoria**: aggiunge una vittoria e non fa perdere Prestigio. Il giocatore però subisce, come in una sconfitta, i **malus che il fantasma infligge** (le conseguenze lasciate dalle armi nemiche, §11.1 e §13.2). Durante l’ultima possibilità un pareggio quindi non termina la run. Nel primo prototipo i fantasmi non infliggono malus, perciò il pareggio equivale a una vittoria.

**Da definire:** conseguenze di abbandono e trattamento dei combattimenti che non terminano.

## 4. Ciclo annuale

### 4.1 Sequenza di riferimento

| Passaggio | Comportamento |
|---|---|
| Nuovo anno (gennaio) | Conservazione della nazione, del Magazzino e dei modificatori attivi; aggiornamento delle durate; consumo di Cibo (§5.4). |
| Selezione dei nemici | Il fantasma dell'anno e i due incontri vengono fissati. |
| Inverno | Gli edifici producono, senza Cibo (§5.2); round 1–3 (gennaio, febbraio, marzo). Nessuno scontro. |
| Primavera | Gli edifici producono; round 4–6 (aprile, maggio, giugno); **incontro del mondo** (§3.3). |
| Estate | Gli edifici producono; round 7–9 (luglio, agosto, settembre); secondo **incontro del mondo**. |
| Autunno | Gli edifici producono; round 10–12 (ottobre, novembre, dicembre). Lo spionaggio (§12) agisce sul fantasma già fissato. |
| Combattimento contro il fantasma | Produzione di mana e attivazione automatica delle truppe. |
| Esito | Vittoria o sconfitta, bottino, aggiornamento della run ed eventuali conseguenze. L'anno finisce. |

Il fantasma va fissato **prima dei round** (e quindi delle opportunità di spionaggio) e non cambia dopo che il giocatore ha investito per ottenere informazioni su di esso — Confermato.

### 4.2 Il Consiglio — Confermato nella struttura (v0.21)

Al posto dei mercanti di The Bazaar la nazione ha un **Consiglio**: consiglieri di tipo diverso (economico, agricolo, costruttore, comandante, spionaggio…). Ogni consigliere ha un proprio pool di opportunità: **azioni** (tutto ciò che non è l’acquisto di un elemento) ed **edifici e truppe a lui affini**. Il Consiglio dà una direzione al giocatore: prima sceglie a chi dare ascolto, poi che cosa fare.

La produzione di risorse avviene all’inizio di ogni **stagione**, non a ogni round (§5.2).

| Regola | Stato |
|---|---|
| In ogni round compaiono **3 consiglieri** pescati a caso, diversi fra loro; al massimo uno può essere sostituito da un Evento, un Visitatore o una Fortuna (§4.2.5) | Confermato (v0.23) |
| Il giocatore ne sceglie **uno**; la scelta è definitiva per il round | Confermato |
| Il consigliere mostra **3 opportunità** dal suo pool; il giocatore ne prende **una sola** | Confermato; eccezione: l'ascensione *Doppio ascolto* (§10.4.2, v0.27) |
| Il pool di un consigliere è dato dalla sua **categoria** (§4.2.4): propone gli edifici e le truppe che hanno almeno un tipo della categoria | Confermato (v0.22) |
| Oltre alle opportunità, ogni consigliere ordinario offre l’opzione **Potenzia** (§6.5): non consuma la scelta del round e si usa una volta per round | Confermato (v0.22) |
| Ogni round ha un **tema**, che decide che cosa propongono i consiglieri: **Azioni** (solo azioni), **Edifici** (solo edifici affini), **Truppe** (solo truppe affini), **Misto** (azioni ed elementi) | Confermato |
| Ogni stagione ha i suoi tre temi, in ordine pescato a caso con il seme della run: **inverno** Azioni, Edifici, Misto (nessun round Truppe); **primavera** Edifici, Misto, Misto; **estate** Truppe, Edifici, Misto; **autunno** Truppe, Azioni, Misto. Il tema è visibile prima di scegliere il consigliere | Confermato (v0.25; nella v0.21 ogni metà aveva Azioni, Edifici, Truppe e due Misti) |
| D'inverno Cancelliere, Sacerdote e Fattore compaiono più spesso (+1 di peso), il Generale meno (peso dimezzato, almeno 1) | Proposta (v0.25) |
| Un consigliere che non ha niente da proporre per il tema del round non viene pescato in quel round | Confermato (v0.21) |
| Si può **passare**: senza scegliere un consigliere, oppure dopo averlo scelto senza prendere nulla. Passare non dà nulla | Confermato (v0.21) |
| Il **rinnovo** a pagamento ripesca le opportunità del consigliere scelto | Confermato (v0.21) |
| Il rinnovo costa Oro, almeno 1; il costo aumenta a ogni rinnovo e a ogni nuovo round si dimezza l’aumento accumulato (arrotondato per difetto), senza scendere sotto il costo iniziale | Confermato |
| Il rinnovo si può pagare, in alternativa all’Oro, con la **risorsa della categoria** del consigliere (§4.2.4) | Confermato (v0.22) |
| Il costo del rinnovo pagato con la risorsa della categoria segue lo stesso aumento e lo stesso contatore del rinnovo in Oro; il Maestro delle spie si rinnova con la risorsa casuale del round; Giullare e Anziano, senza categoria, solo in Oro | Proposta |
| Le azioni **non costano Oro**, ma altre risorse coerenti con il tema; edifici, truppe e spazi si pagano in Oro | Confermato (v0.20) |
| L’**identità** della nazione (popolo, governo, credo, cultura, vie) rende più frequenti alcuni consiglieri, già nel prototipo | Confermato |
| Gli edifici e le truppe proposti sono dell’era corrente, esclusivi delle vie compresi | Confermato |
| Un'opportunità che in quel momento non ha senso non compare (es. accorciare un malus senza malus attivi, spazi oltre il massimo) | Confermato |

#### 4.2.1 Livelli dei consiglieri — Confermato (v0.21)

I consiglieri hanno **3 livelli**, legati all’**era**: Funzionari, Ministri e Gran Consiglieri (nomi placeholder). Un livello più alto ha un pool più ricco e opportunità più forti.

- **Confermato (v0.21):** il livello è quello dell’era corrente; entrando in una nuova era tutto il Consiglio sale di livello.
- **Da definire con il bilanciamento:** se le opportunità migliori costano di più o lo stesso.

#### 4.2.2 Consiglieri speciali — Confermato (v0.21)

- **Giullare:** propone **5 elementi**, edifici e truppe mescolati: uno per ciascun colore di mana (rosso, verde, blu, viola) e un edificio neutro — Confermato (v0.22; nella v0.21 erano 4). Non offre Potenzia.
- **Anziano:** propone **peculiarità** ed **elementi neutrali**. Gli elementi neutrali sono gli edifici neutri, perché non esistono truppe neutre — Confermato (v0.21). Offre Potenzia **solo per gli edifici neutri**, qualunque tipo abbiano, e **una volta all’anno** — Confermato (v0.22).
- Giullare e Anziano ignorano il tema del round — Confermato (v0.21).

#### 4.2.3 Consiglio del prototipo — Confermato come punto di partenza (v0.21)

Nomi, azioni e costi placeholder. Le azioni riprendono le scelte del vecchio sistema delle opportunità (prima della v0.21). Gli elementi proposti da ciascun consigliere dipendono dalla sua categoria (§4.2.4). Dalla v0.22 le azioni “Potenzia un edificio” e “Potenzia una truppa” non esistono più: le sostituisce l’opzione Potenzia di tutti i consiglieri (§6.5).

| Consigliere | Categoria | Azioni | Paga le azioni con |
|---|---|---|---|
| Tesoriere | Ricchezza | Esattori: Oro subito · Assemblea: +50% Oro o Ricerca per un anno (il Mercante, Ricerca in Oro, è stato tolto nella v0.26) | gratis (correzione dell’8 novembre 2026) |
| Fattore | Terra | Scorte: Cibo in cambio di Legno · Razioni: per un anno le truppe mangiano meno | Legno |
| Architetto | Opera | Architetti: spazio edificio · Fortificazioni: Resistenza nel prossimo scontro con il fantasma | Pietra, Legno (lo spazio in Oro) |
| Generale | Militare | Quartiermastro: spazio truppa · Addestramento: ricarica più corta per un anno | Ferro (lo spazio in Oro) |
| Studioso | Conoscenza | Studiosi: Legno in Ricerca · Archivisti: Documenti in Ricerca · Manuali tecnici: per un anno una truppa fa più danno · Revisione dei piani: ripesca la mano delle tecnologie (v0.26, §10.5.3). La Ricerca che dà va nella tecnologia in corso | Legno, Documenti |
| Sacerdote | Fede | Incanta una truppa (§4.3), un’azione per ogni effetto | Fede |
| Cancelliere (ex Diplomatico) | Stato | Ambasciata: accorcia un malus attivo · Decreto fiscale: Stabilità in Oro · Censimento: per un anno un'opportunità in più | Stabilità |
| Maestro delle spie | Ombra | Sabotaggio o Inefficienza sul fantasma (§12) | Documenti |
| Giullare | — | 5 elementi di mana diverso (§4.2.2) | — |
| Anziano | — | Una peculiarità (§9.3) | Fede e Influenza |

Le azioni **non** seguono la risorsa della categoria (§4.2.4): si pagano con le risorse indicate in questa tabella, placeholder — Confermato (v0.22). Ogni risorsa di categoria (§5.3) deve pagare **almeno un’azione** del Consiglio — Confermato (v0.22). Le azioni del Tesoriere sono gratuite, come nel gioco (correzione dell’8 novembre 2026, decisione di Davide): l’Influenza resta la risorsa di un’azione con la peculiarità dell’Anziano, e paga anche la Riforma. L’assegnazione attuale (Ambasciata in Stabilità, spionaggio in Documenti) è una Proposta. Dalla v0.22 la Fauna non esiste più come risorsa: Scorte non la produce più e il Fattore non la chiede.

Un'opportunità che in quel momento non ha senso non compare (es. Ambasciata senza malus attivi, spazi oltre il massimo).

**Da definire:** catalogo definitivo del Consiglio e dei pool, frequenza dei consiglieri, eventi.

#### 4.2.4 Categorie — Confermato (modifica del nucleo, v0.22)

Una **categoria** è un insieme di tipi (§6.6) ed è il campo di un consigliere. Le tessere non hanno una categoria: hanno solo tipi.

| Regola | Stato |
|---|---|
| Ogni consigliere ordinario ha una categoria; Giullare e Anziano non ne hanno | Confermato |
| Un consigliere propone gli edifici e le truppe che hanno **almeno un tipo** della sua categoria | Confermato |
| Lo stesso tipo può stare in più categorie: le sue tessere possono allora essere proposte da più consiglieri | Confermato |
| Un consigliere può potenziare (§6.5) le tessere che hanno almeno un tipo della sua categoria, pagando con la **risorsa della categoria** (tabella sotto) | Confermato |
| La risorsa della categoria vale solo per Potenzia; le azioni si pagano come in §4.2.3 | Confermato |
| **Ombra** chiede Oro più una **risorsa casuale**, pescata fra Ferro, Pietra, Legno, Influenza, Fede, Stabilità e Documenti (escluse Ricerca e Cibo) | Confermato |
| La risorsa casuale di Ombra si pesca con il seme della run quando il Maestro delle spie compare fra i consiglieri del round, è **visibile prima di sceglierlo** e resta la stessa per tutto il round | Confermato |
| Costo del Potenzia dell’Anziano (che non ha categoria) | Da definire; nel prototipo Oro (§16.3) |

| Categoria | Tipi | Consigliere | Risorsa di Potenzia | Colore tendenziale (§5.3) |
|---|---|---|---|---|
| Militare | Assedio, Infrastruttura Bellica, Fante, Guardiano | Generale | Ferro | rosso |
| Opera | Infrastruttura Strategica, Materie prime, Assedio | Architetto | Pietra | rosso |
| Terra | Fauna, Materie prime, Guardiano, Economico | Fattore | Legno | verde |
| Ricchezza | Economico, Fante, Infrastruttura Strategica, Nobile | Tesoriere | Influenza | verde |
| Conoscenza | Accademico, Criminale, Legge, Infrastruttura Segreta | Studioso | Documenti | viola |
| Fede | Spirituale, Patriota, Fauna, Guardiano | Sacerdote | Fede | blu |
| Stato | Legge, Patriota, Accademico, Nobile | Cancelliere | Stabilità | blu |
| Ombra | Criminale, Infrastruttura Strategica, Infrastruttura Bellica, Infrastruttura Segreta | Maestro delle spie | Oro + una risorsa casuale | viola |

Categorie e tipi: Confermato nella struttura, nomi placeholder. Fante sta anche in Ricchezza perché i soldati si possono comprare (mercenari). Ombra rappresenta i servizi segreti, che fanno il lavoro sporco: per questo propone anche infrastrutture belliche e strategiche.

Nota per il catalogo: un tipo presente in molte categorie rende le sue tessere “comuni” (le propongono e le potenziano molti consiglieri); un tipo presente in una sola categoria le rende “mirate”. Dare un tipo a una tessera significa decidere quali consiglieri la propongono.

#### 4.2.5 Eventi, Visitatori e Fortune — Confermato (modifica del nucleo, v0.23)

Nei round, oltre ai consiglieri, possono comparire **avvenimenti** di altre famiglie, legate alla vita della nazione come in un GDR. Gli effetti usano solo il linguaggio del nucleo (risorse, tessere, livelli, spazi, modificatori, spionaggio; P5).

| Regola | Stato |
|---|---|
| Famiglie: **Evento** (un testo e 2-3 opzioni), **Visitatore** (un consigliere di passaggio con le sue opportunità e i suoi prezzi), **Fortuna** (un dono semplice). Altre famiglie legate al GDR restano possibili | Confermato |
| Compaiono **al posto di un consigliere**: al massimo una per round | Confermato |
| Compaiono con una probabilità scritta nei dati (in media 1 round su 3); fra le famiglie si pesca con pesi scritti nei dati (Eventi 5, Visitatori 3, Fortune 2) | Confermato; valori placeholder |
| Ignorano il tema del round, come Giullare e Anziano. Sceglierle è la scelta del round, definitiva; si può sempre passare | Confermato |
| Non offrono Potenzia (un'opzione può però potenziare una tessera); un Visitatore si rinnova solo in Oro | Confermato |
| Un Evento compare una sola volta per run, salvo quelli ripetibili; Visitatori e Fortune possono tornare, ma non nello stesso anno | Confermato |
| Ogni avvenimento ha una **sfera**: una delle 8 categorie (§4.2.4), che ne dà il tema e la cornice | Confermato |
| Ogni avvenimento ha delle **radici**, con lo schema delle vie (§10.4): **richiede** (compare solo con almeno uno) e **favorita da** (+1 di peso ciascuno). Radici: elementi dell'identità, vie, era minima e massima, tipi sulla plancia, stato della nazione (risorse, malus attivo); dalla v0.25 anche le **stagioni** in cui l'avvenimento può comparire | Confermato |
| Eventi legati alle stagioni: *Un inverno lungo* e *Il passo innevato* d'inverno, *La piena del fiume* e *Le terre di confine* in primavera, *Il torneo* d'estate, *Raccolto abbondante* d'estate o d'autunno, *La grande fiera* d'autunno; nuovi eventi invernali; d'inverno la Riforma e i Tumulti in piazza sono più frequenti (+1 di peso) | Proposta (v0.25) |
| Le opzioni di un Evento possono avere un **requisito**: un elemento dell'identità, una tessera con un certo tipo sulla plancia, risorse. Un'opzione bloccata si vede comunque, spenta, con il requisito accanto (P4). Ogni evento ha almeno un'opzione **gratuita e senza requisiti**, così si può sempre scegliere qualcosa (v0.24) | Confermato |
| Un'opzione che regala una tessera o uno spazio è **bloccata**, con il motivo, se il regalo non può arrivare (nessuno spazio libero, spazi già al massimo): così non si paga per niente. L'opzione gratuita dell'evento non ha regali, quindi resta sempre scegliere qualcosa | Confermato (decisione di Davide, 8 novembre 2026) |
| Nessun evento arriva da solo senza essere scelto, con due eccezioni: la **Rivoluzione** (§9.4.2) e le **cronache** della nazione all'inizio di ogni stagione (§9.6, v0.29) | Confermato (Rivoluzione dalla v0.24, cronache dalla v0.29) |
| Le opzioni possono anche **cambiare il governo** (Riforma, Rivoluzione) e far salire o scendere il **Malcontento** (§5.5) | Confermato (v0.24) |

Il catalogo del prototipo (18 eventi, 6 fortune, 6 visitatori) è in `docs/Catalogo.md`.

### 4.3 Incanto — Confermato (v0.21), valori placeholder

Il Sacerdote può **incantare** una truppa: le aggiunge un effetto in battaglia e un costo di mana.

| Regola | Stato |
|---|---|
| Effetti possibili: quelli esistenti, cioè danno, scudo, cura, Corruzione e Inefficienza (§7.6, §7.7) | Confermato |
| Solo le truppe si possono incantare, non gli edifici | Confermato |
| Una truppa che non usava mana, dopo l’incanto ne richiede | Confermato |
| Ogni truppa si può incantare **una sola volta** | Confermato; eccezione: con l'ascensione *Seconda natura* due volte (§10.4.2, v0.27) |
| Il mana richiesto è del colore della truppa; se la truppa non usava mana, è del colore dell’incanto. Costo in più: 2 mana | Confermato (v0.21); valori placeholder |
| Valore dell’effetto: circa metà del danno di una truppa dell’era; cresce con i potenziamenti come gli altri valori (§6.5) | Confermato (v0.21); valori placeholder |
| L’incanto resta sulla truppa per tutta la run e si perde se la truppa viene venduta o sostituita | Confermato (v0.21) |

Nel linguaggio degli effetti (§8) un incanto è un modificatore permanente sulla truppa, con l’incanto come origine. A differenza delle aggiunte fisse dei modificatori, che valgono solo per chi ha già quel valore (§16.3), l’incanto **aggiunge un effetto che la truppa non aveva**.

## 5. Economia

### 5.1 Doppia funzione degli edifici — Confermato

| Contesto | Funzione |
|---|---|
| Fuori dal combattimento | Produzione di risorse per la crescita della nazione. |
| Durante il combattimento | Produzione di mana per alimentare le truppe. |

La scelta di un edificio incide quindi su entrambi i momenti di gioco. Gli edifici persistono durante la run: non si ricostruisce l’economia da zero ogni anno. Il criterio con cui differenziare gli edifici è proposto in P3.

### 5.2 Produzione per stagione — Confermato (v0.25)

All’inizio di ogni stagione gli edifici presenti depositano automaticamente le rispettive risorse nel Magazzino, una volta per stagione. **D'inverno nessun edificio produce Cibo**, nemmeno la Capitale; tutte le altre risorse sì.

Un edificio costruito durante una stagione non produce retroattivamente: inizia a produrre dalla stagione successiva.

I valori di produzione restano quelli della v0.24: con quattro produzioni all'anno invece di due le entrate raddoppiano. Sono placeholder e il bilanciamento si rifà con le prove (Confermato, v0.25).

**Esempio senza valori:** una biblioteca costruita in primavera fornisce la prima Ricerca all’inizio dell’estate, e produce di nuovo all’inizio dell’autunno e dell’inverno successivo. Una fattoria costruita in autunno produce Cibo dalla primavera dell'anno dopo: d'inverno non ne dà.

### 5.3 Risorse — Confermato (modifica del nucleo, v0.12; riviste in v0.22)

Le risorse sono molte, come in uno strategico. L’Oro resta la moneta comune; le altre servono a **specializzarsi**: potenziamenti, azioni del Consiglio, mantenimento.

Dalla v0.22 **ogni categoria del Consiglio ha la sua risorsa** (§4.2.4): è quella con cui il consigliere fa pagare Potenzia (§6.5). Tre risorse restano fuori dalle categorie: l’Oro (moneta), la Ricerca (tecnologie, e con esse le ere) e il Cibo (razioni).

| Risorsa | Impiego | Prodotta soprattutto da |
|---|---|---|
| Oro | Moneta comune: edifici, truppe, spazi, rinnovi delle opportunità; Potenzia del Maestro delle spie, insieme a una risorsa casuale (§4.2.4). | edifici Economici |
| Ricerca | Tecnologie, e con esse il passaggio di era (§10.5, v0.26). **Non sta nel Magazzino**: va nella tecnologia in corso. Non è la risorsa di nessuna categoria. | edifici Accademici |
| Cibo | Razioni delle truppe (§5.4). | edifici di Materie prime agricole |
| Ferro | Potenzia del Generale (Militare). | edifici di Materie prime e Infrastrutture Belliche |
| Pietra | Potenzia dell’Architetto (Opera). | edifici di Materie prime |
| Legno | Potenzia del Fattore (Terra). | edifici di Materie prime |
| Influenza | Potenzia del Tesoriere (Ricchezza). | edifici Economici e Nobili |
| Fede | Potenzia del Sacerdote (Fede). | edifici Spirituali |
| **Stabilità** | Potenzia del Cancelliere (Stato). Nuova (v0.22). | edifici di Legge, Patrioti e di Stato (es. Consolato, Università) |
| **Documenti** | Potenzia dello Studioso (Conoscenza). Nuova (v0.22). | edifici Accademici e Infrastrutture Segrete (es. Biblioteca, Accademia, Osservatorio, Loggia segreta, Rete di informatori) |

- La **Fauna** non è più una risorsa (v0.22): resta solo come tipo (§6.6).
- Le **azioni** dei consiglieri non seguono la risorsa della categoria: si pagano come indicato in §4.2.3 — Confermato (v0.22).
- **Altri impieghi — Confermato (v0.22).** Le risorse di categoria non servono solo a Potenzia: pagano anche il **rinnovo** delle opportunità del proprio consigliere (§4.2) e **almeno un’azione** del Consiglio (§4.2.3). Così restano utili anche quando le tessere sono al livello massimo.
- **Direzione (v0.22):** gli eventi a scelta (§13) potranno chiedere risorse, comprese quelle di categoria. Le tecnologie costano solo Ricerca; solo alcuni progetti speciali potranno chiedere una risorsa di categoria (§10.5.7, v0.26).
- La colonna “Prodotta soprattutto da” è una tendenza per il catalogo, non una regola.

- Tutte le risorse stanno nel **Magazzino**, senza limite di capacità, tranne la **Ricerca**, che va nella tecnologia in corso (§10.5.1, v0.26).
- Un edificio può produrre più risorse a ogni stagione.
- I costi di base (edifici, truppe, spazi, rinnovi) restano in Oro.

**Mercato delle risorse — Confermato.** In ogni round il giocatore può sempre vendere risorse in cambio di Oro, a tasso fisso, senza consumare il round. Il mercato funziona **solo in vendita**: con l’Oro non si comprano risorse, così l’Oro raccoglie le eccedenze ma non sostituisce la specializzazione (confermato in v0.22). Una nazione generalista che produce un po’ di tutto può così vivere comprando con l’Oro. La Ricerca non si vende (v0.26). Tasso: placeholder (§16.3).

**Mana — Confermato.** Il mana è distinto dal Magazzino e non finanzia acquisti fuori battaglia. Mana iniziale pari a zero, nessun limite di accumulo durante lo scontro, azzeramento a fine battaglia.

**Quattro colori — Confermato (modifica del nucleo, v0.22).**

| Colore | Tema | Categorie a cui tende (§4.2.4) |
|---|---|---|
| Rosso | Guerra e opere | Militare, Opera |
| Verde | Ricchezza e terra | Terra, Ricchezza |
| Blu | Ordine: fede, Stato, diplomazia | Fede, Stato |
| Viola | Segreti: sapere e lavoro sporco (nome e tema placeholder) | Conoscenza, Ombra |
| Energetico | Vale come mana di qualsiasi colore | — |

- Il colore appartiene solo al mana: **i tipi non hanno colore** (§6.6). Un edificio che produce mana ha un colore; una truppa che chiede mana ha un colore.
- Le categorie della tabella sono una **tendenza per scrivere il catalogo**, non una regola: una tessera può avere qualsiasi colore. Ogni coppia di categorie condivide almeno un tipo.
- L’energetico resta della Capitale e non appartiene a nessun tipo.
- Con 4 colori la plancia iniziale non può coprirli tutti: si sceglie presto una direzione. Da osservare nel playtest.
- Un edificio **senza mana** è **neutro**: non ha colore. Come ogni altro edificio, può essere disponibile a tutti oppure peculiare di certe nazioni, come esclusivo dell’identità o di una via (§9.2, §10.4) — Confermato (modifica del nucleo, v0.16).
- Ogni truppa chiede mana di un colore, oppure nessuno.
- Una truppa paga **prima con il proprio colore e poi con l’energetico**. Eccezione: con l'ascensione *Mana unito* paga poi anche con gli altri colori (§10.4.2, v0.27).

### 5.4 Cibo e razioni — Confermato

- Ogni truppa consuma di base **0,5 Cibo**; alcune truppe possono chiederne di più.
- Il consumo avviene **all’inizio di ogni anno**, cioè all'inizio dell'inverno, **a partire dall’anno 2**: nel primo anno le truppe non mangiano. Siccome l'inverno non produce Cibo (§5.2), il Cibo per mangiare va messo da parte nell'anno prima (v0.25).
- Mangiano prima le truppe **più lente**, poi le più veloci; a parità di ricarica, prima quelle più a destra.
- Una truppa mangia tutta la sua razione o niente; il cibo avanzato passa alla truppa successiva.
- Una truppa che resta senza cibo ha la **ricarica ×1,5** fino al consumo dell’anno successivo. Eccezione: con l'ascensione *Esercito frugale* non rallenta (§10.4.2, v0.27).
- Le truppe reclutate durante l’anno sono sazie fino al consumo successivo.
- I fantasmi non soffrono la fame.

### 5.5 Malcontento — Confermato (modifica del nucleo, v0.24)

Il **Malcontento** è un contatore della nazione, distinto dal Magazzino. Insieme alla **Stabilità** forma un unico tema: il Malcontento è una **pressione** che sale da sola, la Stabilità è la **risorsa che si spende** per farlo scendere.

| Regola | Stato |
|---|---|
| Sale con sconfitte, carestie (Cibo insufficiente), malus subiti e alcune opzioni degli eventi | Confermato |
| Scende soprattutto spendendo **Stabilità** con un'azione del Cancelliere; anche con Fede (Sacerdote), Cibo (Fattore) e alcune opzioni degli eventi | Confermato nella forma; azioni Proposta |
| Raggiunta una **soglia**, scatta la **Rivoluzione** (§9.4.2); dopo la rivoluzione si azzera | Confermato |
| Si consulta con la sua soglia nella linguetta «Partita» in alto a destra (si apre passando il mouse o con un clic: Davide, 8 novembre 2026), e il gioco avverte quando la rivoluzione si avvicina (come P4) | Confermato (Davide, 8 novembre 2026); avviso Proposta |
| Vive fuori dalla battaglia: non entra nella simulazione e non cambia la Resistenza | Proposta |
| Non si vende al mercato; si conserva da un anno all'altro | Proposta |
| Gli eventi possono avere come radice “Malcontento sopra una soglia” | Proposta |
| Valori: quanto sale per ogni causa, quanto vale 1 Stabilità, la soglia | Da definire |

### 5.6 Mantenimento delle tessere — Confermato (modifica del nucleo, v0.28)

Oltre al Cibo delle truppe (§5.4), le tessere forti costano qualcosa nel tempo. Le risorse accumulate trovano così uno sbocco, e potenziare o prendere una tessera speciale diventa una scelta. Bozza della discussione: `docs/Bozza_mantenimento.md`.

| Regola | Stato |
|---|---|
| Pagano le **tessere potenziate** (per ogni livello sopra il primo) e le **tessere speciali** | Confermato |
| Tessere speciali: le **esclusive** (di popolo, governo, credo, cultura e vie) e le tessere delle **linee di elementi** (§10.5.5). Le tessere normali, anche dell'era 3, no | Confermato |
| La risorsa è quella della **categoria del primo tipo** della tessera (§4.2.4): una truppa Fante paga Ferro, una Spirituale Fede. I tipi fuori dalle categorie (identità, Capitale) si saltano; per l'Ombra si paga Oro | Confermato |
| Si paga **prima di ogni scontro**: i due incontri del mondo e il fantasma | Confermato |
| Tutte le tessere sulla plancia pagano, anche gli edifici che non combattono | Confermato |
| **Ordine da destra**, come il Cibo: prima le truppe da destra a sinistra, poi gli edifici da destra a sinistra | Confermato (ordine fra truppe ed edifici: Proposta) |
| Una tessera che non si può pagare è **trascurata** in quello scontro: ricarica (truppe) o ciclo (edifici) ×1,5, come una truppa affamata | Confermato |
| Ogni tessera non pagata dà **+1 Malcontento** (§5.5) | Confermato |
| Valori: 1 unità per ogni livello sopra il primo, 1 unità in più per le tessere speciali | Placeholder |
| Ogni tessera mostra il suo mantenimento; le tessere trascurate si vedono in battaglia; la barra delle risorse dice quanto si paga al prossimo scontro (P4) | Confermato |
| I fantasmi non pagano: sono registrazioni con le statistiche già salvate (§11) | Confermato |

## 6. Plancia della nazione

### 6.1 Configurazione iniziale — Confermato

| Zona | Spazi iniziali | Massimo indicativo |
|---|---:|---:|
| Edifici | 4 | 10 |
| Truppe | 3 | 12 |

I valori iniziali sono confermati. I massimi sono un’indicazione del creatore sulla plancia di fine run (**Direzione**): verso la fine della partita la plancia deve essere piena di edifici e truppe.

La base usa due file separate. Un elemento occupa uno spazio. Gli spazi sono capacità disponibili, non elementi automaticamente posseduti.

Le truppe possono essere riordinate **in qualunque momento fuori dal combattimento**; la loro posizione determina la priorità nell’uso del mana. Durante il combattimento la disposizione resta fissa.

Sono ammesse **copie multiple** dello stesso edificio o della stessa truppa — Confermato.

### 6.2 Dotazione iniziale — Base approvata

- Prima era.
- La **Capitale** (Confermato): produce 1 mana energetico in battaglia; non si può vendere né sostituire; peculiarità e caratteristiche dell’identità possono potenziarla.
- **Produzione della Capitale — Confermato (modifica del nucleo, v0.22):** a ogni stagione produce 1 **Oro**, 1 **Cibo** e 1 **Ricerca**, più **+1 di una risorsa indicata da ciascun elemento dell’identità** (popolo, governo, credo, cultura). Anche le **vie** (§10.4) possono aggiungerne, come tratto permanente. Se più elementi indicano la stessa risorsa, si sommano: la nazione nasce con una vocazione. Prima della v0.22 la Capitale produceva 1 di ogni risorsa.
- Una truppa di base con ricarica, senza richiesta di mana.
- Tre spazi edificio e due spazi truppa vuoti.
- Una dotazione di Oro per un primo acquisto.
- Nessuna Ricerca iniziale.

Quantità, nomi e statistiche sono placeholder. Eventuali varianti per popolo restano una proposta.

### 6.3 Espansione della plancia — Confermato nelle fonti (modifica del nucleo, v0.15); quantità e prezzi placeholder

Il passaggio da 3 a fino a 12 spazi truppa (e da 4 a fino a 10 spazi edificio) rende l’espansione uno degli assi principali di progressione della run. Gli spazi arrivano da **tre fonti insieme**:

- l’**ingresso nelle ere**: ogni era indica nei dati quanti spazi edificio e truppa concede (§10);
- **edifici che concedono spazi**, ad esempio una caserma che aggiunge spazi truppa;
- l’**acquisto di spazi con l’Oro**, come opportunità dell’Architetto e del Generale (§4.2.3).

Un edificio che concede spazi occupa a sua volta uno spazio edificio, quindi entra nella stessa scelta della doppia funzione.

Anche il bonus immediato di una via (§10.4) può concedere spazi, se i suoi dati lo prevedono.

**Da definire:** quantità e prezzi di ciascuna fonte; layout della plancia.

### 6.4 Vendita e sostituzione — Confermato

Il principio P1 funziona solo se il giocatore, colpito da un malus, ha davvero alternative da perseguire. A plancia piena, “costruire altro” significa sostituire un elemento: le regole di vendita, sostituzione e rimborso determinano quindi quanto un malus devia o punisce.

- Un elemento si può **vendere in qualunque momento fuori dal combattimento**, anche senza sostituirlo.
- Il rimborso è **metà del prezzo pagato**, arrotondato per difetto.
- La sostituzione equivale a vendere l’elemento presente e costruire il nuovo: il rimborso conta già per pagare il nuovo elemento, e una truppa nuova prende il posto di quella sostituita.
- Un elemento della dotazione iniziale non rimborsa nulla. Un elemento ottenuto come ricompensa rimborsa metà del suo prezzo di catalogo, come se fosse stato comprato.
- Un edificio che concede spazi si può vendere o sostituire solo se nessun elemento resta senza spazio.

**Da definire:** riserva fuori plancia, fusioni e potenziamento degli elementi.

Una mappa a distretti con adiacenze era stata discussa come alternativa precedente: **non fa parte della plancia concordata.**

### 6.5 Potenziamenti — Confermato

- Ogni edificio e ogni truppa ha dei **livelli** (3 livelli). Eccezione: con l'ascensione *Maestria* si arriva al livello 4 (§10.4.2, v0.27).
- **Potenzia — Confermato (modifica del nucleo, v0.22).** Si potenzia **solo con il Consiglio**, oltre che con eventi e ricompense; non più in qualunque momento.
  - Ogni consigliere ordinario offre, oltre alle 3 opportunità, una quarta opzione: **Potenzia**.
  - Potenzia porta di livello un edificio o una truppa della plancia che abbia **almeno un tipo** della categoria del consigliere (§4.2.4).
  - Usare Potenzia **non consuma la scelta** del round: si può prendere anche una delle opportunità. Una volta usata, l’opzione sparisce per quel round.
  - Potenzia è disponibile con **ogni tema del round**, per edifici e truppe.
  - Il **costo** lo decide il consigliere, con la risorsa della sua categoria (§4.2.4): la stessa tessera può costare risorse diverse a seconda di chi la potenzia. Quantità placeholder.
  - Potenzia non compare se nessuna tessera ha un tipo del consigliere o se sono tutte al livello massimo.
  - Il Giullare non offre Potenzia; l’Anziano solo per gli edifici neutri, una volta all’anno (§4.2.2).
- Effetti: ogni livello aumenta **tutti i valori d’effetto** dell’elemento (danno, scudo, cura, Corruzione, danno d'assedio, durate di Inefficienza e Sabotaggio); gli edifici producono anche più risorse per stagione (valori placeholder, §16.3) — Confermato (v0.16).

### 6.6 Tipi — Confermato (modifica del nucleo, v0.22)

Ogni edificio e ogni truppa ha **uno o più tipi**, presi da **un’unica lista** comune a edifici e truppe, come i tipi degli oggetti di The Bazaar. Dalla v0.22 i tipi sostituiscono le etichette.

| Regola | Stato |
|---|---|
| Un’unica lista di tipi per edifici e truppe; ogni tessera ha uno o più tipi | Confermato |
| Le vecchie etichette di ruolo delle truppe sono tipi come gli altri; Tiratori e Cavalleria non esistono più | Confermato |
| I tipi decidono quali consiglieri propongono e potenziano la tessera (§4.2.4) e a quali peculiarità e modificatori risponde (es. “le truppe Fante ricaricano più in fretta”) | Confermato |
| I tipi non hanno colore (§5.3) | Confermato |
| Alcuni tipi valgono soprattutto per edifici (le Infrastrutture), altri soprattutto per truppe (Fante); la distinzione non è una regola | Confermato |
| La Capitale ha un tipo proprio, **Capitale**, fuori da tutte le categorie | Proposta |
| **Tipi d'identità** (v0.24): ogni elemento dell'identità (popolo, governo, credo, cultura) ha un suo tipo, es. Pietrosangue, Monarchico, Solare. Stanno fuori da tutte le categorie: non decidono quali consiglieri propongono o potenziano una tessera | Confermato (v0.24) |
| Le tessere esclusive di un elemento portano il suo tipo d'identità **più almeno un tipo di categoria**; al massimo 1-2 tipi di categoria più 1 tipo d'identità (**3 tipi**) | Confermato (v0.24) |
| I tipi d'identità servono a peculiarità e tratti, alle radici e ai requisiti degli eventi (§4.2.5) e, in futuro, a sinergie e tensioni. Una tessera straniera porta in casa il suo tipo; se il governo cambia, le tessere del vecchio governo tengono il loro | Confermato (v0.24) |
| Tipi d'identità anche per le vie | Da definire |
| Ogni tessera ha **1 o 2 tipi**, 3 solo per tessere esclusive: un tipo dice che cosa fa la tessera, l’eventuale secondo chi rappresenta. Con 3 tipi per tessera ogni consigliere proporrebbe metà del catalogo | Proposta |

| Tipo | Significato (placeholder) |
|---|---|
| Fante | Soldati a piedi; si possono anche comprare (mercenari). |
| Assedio | Macchine e truppe d’assedio; può valere anche per edifici. |
| Guardiano | Chi protegge: mura, scorte, protettori sacri o della natura. |
| Infrastruttura Bellica | Edifici militari; in Ombra, le strutture del lavoro sporco. |
| Infrastruttura Strategica | Porti, cantieri, vie commerciali, edifici che danno spazi. |
| Infrastruttura Segreta | Logge, reti di informatori, basi nascoste. |
| Materie prime | Edifici che producono materie prime (fino alla v0.30: Produzione). |
| Economico | Commercio, denaro, economia anche agricola. |
| Fauna | Animali: allevamenti, cavalcature. |
| Nobile | Aristocrazia, alta finanza, diplomazia. |
| Accademico | Sapere, studio, ingegneria. |
| Legge | Ordine, giustizia, diplomazia di Stato. |
| Criminale | Spie, sobillatori, assassini, sabotatori. |
| Spirituale | Fede, culto, cura. |
| Patriota | Amore per la nazione, milizie e legioni. |

L’assegnazione dei tipi e dei colori alle tessere del prototipo è nel Catalogo (`docs/Catalogo.md`, bozza 4) e nei dati del gioco.

## 7. Combattimento automatico

La stessa simulazione regola gli scontri contro i fantasmi e, nella proposta attuale, quelli contro le plance generate degli incontri del mondo.

### 7.1 Obiettivo — Confermato

Ogni nazione possiede una **Resistenza**. Gli attacchi riducono la Resistenza nemica; arrivare a zero significa perdere lo scontro (eccezione: l'ascensione *Ultima trincea*, §10.4.2, v0.27). Si perde anche quando la **Corruzione** accumulata raggiunge la Resistenza (§7.6.3).

Truppe ed edifici non hanno punti vita individuali e non vengono eliminati durante la battaglia nella base.

Resistenza e Prestigio sono separati: la prima riguarda il singolo scontro, il secondo la sopravvivenza della run. La Resistenza viene ripristinata prima dello scontro successivo.

### 7.1.1 Calcolo della Resistenza — Confermato nella struttura, valori placeholder

La Resistenza massima di una nazione si calcola all’inizio di ogni scontro come somma di:

| Componente | Contributo |
|---|---|
| Era | Una quota per l’era raggiunta; più alta l’era, più alta la quota. |
| Identità | Una quota per governo, credo religioso e popolo (§9). |
| Anni | +X per ogni anno trascorso: la Resistenza cresce di anno in anno. |
| Edifici | Una quota minore per ogni edificio costruito; può essere influenzata dalle peculiarità. |
| Truppe | Una quota minore per ogni truppa posizionata; può essere influenzata dalle peculiarità. |

Nel primo prototipo l’identità non esiste ancora e contribuisce 0. Le plance generate degli incontri del mondo usano invece una Resistenza fissata nei dati (§3.3).

### 7.2 Attivazione delle truppe — Confermato

Una truppa si attiva quando:

1. la sua ricarica è terminata;
2. è disponibile il mana richiesto.

All’attivazione consuma il mana, applica il proprio effetto e riavvia la ricarica. Se manca il mana, resta pronta in attesa.

Non esiste un attacco base universale indipendente dal mana. Possono esistere **truppe senza richiesta di mana**, regolate soltanto dalla ricarica.

### 7.3 Priorità di utilizzo — Confermato

Le truppe pronte vengono valutate **da destra verso sinistra** sulla plancia del proprietario:

- la truppa più a destra viene considerata per prima;
- se può pagare, si attiva e riduce il mana disponibile per le successive;
- se non può pagare, viene saltata;
- il mana non viene prenotato per la truppa saltata (eccezione: l'ascensione *Disciplina ferrea*, §10.4.2, v0.27);
- le truppe più a sinistra possono usare il mana residuo se sufficiente.

Una truppa economica può quindi ritardare una truppa costosa. Produzione, costi, ricarica e ordine della plancia formano insieme la strategia. Con plance fino a 12 truppe questo ordine diventa una fonte importante di profondità, e per la stessa ragione la sua leggibilità (P4) è un requisito.

Le truppe in attesa vengono verificate di nuovo quando il mana torna disponibile: la carenza di mana non impone una nuova ricarica.

### 7.4 Produzione durante lo scontro

Gli edifici producono mana durante il combattimento in una **riserva condivisa** (base del primo prototipo).

**Confermato:** ogni edificio produce con un **ciclo individuale**, esattamente come la ricarica di una truppa (una quantità di mana a ogni ciclo). Come le truppe, gli edifici iniziano lo scontro con il ciclo pieno: il primo mana arriva allo scadere del primo ciclo. Quantità e tempi restano configurabili.

Ogni colore ha la sua riserva; il mana energetico copre qualsiasi colore (§5.3).

Oltre al mana, un edificio può produrre scudo, cura e Corruzione (§7.6.5): allo scadere del suo **unico ciclo** produce tutto insieme — Confermato.

**Da definire:** capienza della riserva e interazioni che la alterano.

### 7.5 Tempistiche e casi limite

| Regola | Stato |
|---|---|
| Truppe ed edifici iniziano la battaglia con ricarica e ciclo **pieni** | Confermato; eccezione: con l'ascensione *Prima scintilla* gli edifici partono a metà (§10.4.2, v0.27) |
| Nello stesso istante si risolve **prima la produzione di mana**, poi l’attivazione delle truppe; l’ordine completo è in §7.6.6 | Confermato |
| Le due nazioni agiscono **in contemporanea**; se entrambe cadono nello stesso istante (Resistenza a zero o Corruzione, §7.6.3), lo scontro è un pareggio (§3.4) | Confermato |
| **Logoramento** contro gli stalli: dopo **45 secondi** di battaglia entrambe le nazioni perdono Resistenza con un danno che cresce nel tempo (ispirato alla tempesta di sabbia di The Bazaar) | Confermato; forma del danno placeholder (§16.3) |
| Il logoramento è un danno come gli altri: viene **assorbito dallo scudo** e le cure lo compensano (§7.6) | Confermato (v0.13) |
| **Casualità ammessa** in battaglia, sempre con un **seme registrato**: lo stesso seme dà sempre lo stesso scontro. Ogni contenuto che usa il caso va segnalato come tale | Confermato (modifica del nucleo, v0.14; sostituisce “nessuna casualità”) |
| Pausa, cambio di velocità e possibilità di saltare la visualizzazione | Confermato, presenti nel prototipo |

La simulazione non deve dipendere dalla velocità grafica del dispositivo, per ottenere scontri riproducibili.

### 7.6 Difesa, Corruzione e Assedio — Confermato (modifica del nucleo, v0.13)

Oltre al danno, la battaglia conosce due forme di difesa (**Scudo** e **Cura**), un modo diverso di vincere (**Corruzione**) e un contro dedicato agli scudi (**danno d’assedio**). Insieme formano un triangolo: nessuna difesa vale contro tutto.

| | contro il Danno | contro la Corruzione |
|---|---|---|
| Scudo | Assorbe | Inutile |
| Cura | Recupera la Resistenza persa | Allontana la soglia, alzando la Resistenza |
| Danno d’assedio | Serve solo a togliere lo scudo nemico | — |

Scudo e cura sono disponibili **dalla prima era**. Nessuno di questi effetti ha un legame fisso con temi, risorse o tipi, salvo il danno d’assedio (§7.6.4): si decide elemento per elemento nel catalogo. Tutti i valori sono placeholder (§16.3).

#### 7.6.1 Scudo

- Ogni nazione ha una **riserva di scudo unica**, come la riserva di mana; le truppe non hanno punti vita individuali (§7.1).
- Lo scudo **parte da zero** a inizio scontro. È il valore di base: un modificatore può cambiarlo (§8.2).
- Il danno colpisce **prima lo scudo** e solo ciò che avanza arriva alla Resistenza.
- Lo scudo **resta finché non viene consumato** e **non ha tetto**.
- Anche il logoramento viene assorbito dallo scudo (§7.5).

#### 7.6.2 Cura

- Una cura ridà Resistenza persa, **mai oltre la Resistenza massima**.
- Nessuna regola speciale contro gli scontri che si trascinano: il logoramento cresce a ogni secondo e prima o poi supera qualsiasi cura.
- Conseguenza dell’ordine dell’istante (§7.6.6): una cura arrivata su Resistenza piena va persa, anche se nello stesso istante arriva un colpo.

#### 7.6.3 Corruzione

- Ogni nazione ha un contatore di **Corruzione** che parte da zero e **si accumula** durante lo scontro. Zero è il valore di base: un modificatore può cambiarlo (§8.2).
- Quando la Corruzione è **pari o superiore alla Resistenza attuale**, la nazione perde lo scontro.
- La Corruzione **non tocca lo scudo** e lo scudo non la ferma: è il contro naturale di una nazione molto difensiva.
- La Corruzione **non scende mai** durante lo scontro. L’unica risposta è alzare la Resistenza con la cura.
- Danno e Corruzione lavorano a tenaglia: il danno abbassa la Resistenza, la Corruzione sale verso di essa.

La Corruzione sostituisce la precedente proposta di un’erosione continua simile al veleno (§8.3).

#### 7.6.4 Danno d’assedio

- Solo le truppe con tipo **Assedio** (§6.6) possono avere un danno d’assedio.
- È un **secondo valore** della truppa, il danno d'assedio, che colpisce **solo lo scudo**, prima del danno normale. Esempio placeholder: Arieti, 10 di danno d'assedio + 3 di danno.
- Se il nemico non ha scudo, il danno d’assedio va perso.
- La truppa paga il suo normale costo in mana all’attivazione, come ogni altra truppa (§7.2).

#### 7.6.5 Fonti

| Fonte | Che cosa può produrre |
|---|---|
| Edificio | Allo scadere del suo unico ciclo (§7.4): mana, scudo, cura e Corruzione al nemico, **in qualsiasi combinazione**. Un edificio senza mana è neutro (§5.3). |
| Truppa | All’attivazione: danno, scudo, cura e Corruzione al nemico, **in qualsiasi combinazione**; le truppe Assedio anche il danno d'assedio. |

La libertà delle combinazioni sposta il peso sul bilanciamento del catalogo: un elemento misto non deve essere migliore su tutti i fronti (P3).

#### 7.6.6 Ordine dentro lo stesso istante

1. Gli edifici che hanno finito il ciclo producono mana, scudo, cura e Corruzione.
2. Le truppe pronte si attivano da destra verso sinistra (§7.3).
3. Si applicano le cure e lo scudo nuovo.
4. Il danno d’assedio toglie scudo.
5. Il danno normale e il logoramento colpiscono lo scudo, poi la Resistenza.
6. Alla **fine dell’istante** si controlla chi è caduto: Resistenza a zero, oppure Corruzione pari o superiore alla Resistenza. Se cadono entrambe le nazioni, è un pareggio (§3.4).

Inefficienza e Sabotaggio prodotti in un istante (passi 1 e 2) valgono **dall’istante successivo** (§7.7).

### 7.7 Inefficienza e Sabotaggio — Confermato (modifica del nucleo, v0.14)

Due effetti che agiscono sui **timer** degli elementi nemici (ricarica delle truppe, ciclo degli edifici), senza eliminarli.

| Effetto | Funzionamento |
|---|---|
| **Inefficienza** (rallenta) | Per una durata in secondi, il timer del bersaglio avanza **più piano**. L’intensità è un **valore unico** uguale per tutti (placeholder: metà velocità, §16.3); gli elementi si distinguono solo per la durata. |
| **Sabotaggio** (blocca) | Per una durata in secondi, il timer del bersaglio è **fermo** e il bersaglio **non può attivarsi**, nemmeno se è pronto e il mana è disponibile. |

#### 7.7.1 Fonti e bersagli

- Possono averli sia le **truppe** (all’attivazione) sia gli **edifici** (allo scadere del ciclo), in qualsiasi combinazione con gli altri effetti (§7.6.5).
- Colpiscono truppe ed edifici. Ogni effetto dichiara nei dati i propri **bersagli ammessi**: solo truppe, solo edifici o qualsiasi elemento.
- Su un edificio, rallentare o bloccare il timer rallenta o ferma **tutto ciò che produce** (mana, scudo, cura, Corruzione), perché l’edificio ha un unico ciclo (§7.4).
- Se non esiste un bersaglio valido fra i bersagli ammessi, l’effetto va perso.
- Un modificatore può far partire uno scontro con un elemento già inefficiente o sabotato (§8.2).
- **Confermato (v0.21):** lo spionaggio prima dello scontro (§12) sceglie il bersaglio con il criterio scritto nell'opportunità: a caso, l’elemento a un’estremità della fila (il più a destra, che agisce per primo, o il più a sinistra), il più lento o il più veloce. Per una truppa conta la ricarica, per un edificio il ciclo; a parità decide la posizione più a destra.

#### 7.7.2 Scelta del bersaglio: a caso, a rotazione

- Il bersaglio si sceglie **a caso** fra gli elementi validi dei bersagli ammessi, con il seme dello scontro (§7.5).
- La scelta è **a rotazione**, come pescare da un sacchetto: un elemento non viene colpito di nuovo finché tutti gli altri elementi validi non sono stati colpiti una volta; poi la rotazione ricomincia.
- La rotazione è **unica per nazione**: tutti gli effetti dello stesso tipo (Inefficienza o Sabotaggio) e con gli stessi bersagli ammessi di una nazione la condividono, così due sabotatori colpiscono elementi diversi.

#### 7.7.3 Durata e sovrapposizioni

- Se un elemento già colpito viene colpito di nuovo dallo stesso effetto, **le durate si sommano**.
- Un elemento insieme inefficiente e sabotato: **il blocco prevale**; intanto la durata di entrambi gli effetti scorre normalmente.
- Gli effetti valgono **dall’istante successivo** a quello in cui sono stati prodotti: le due nazioni agiscono in contemporanea, quindi una truppa sabotata nello stesso istante in cui si attiva si attiva comunque.

Conseguenza: l’Inefficienza **non ha effetto immediato** su una truppa già pronta in attesa di mana, perché il suo timer è già a zero; conta dalla ricarica successiva, se è ancora attiva. Il Sabotaggio invece la blocca subito.

## 8. Linguaggio degli effetti e modificatori — Proposta

Questa sezione è il punto di innesto per i contenuti futuri: ogni nuovo elemento dovrebbe poter essere descritto con le voci seguenti (P5).

### 8.1 Due scale di tempo

| Scala | Unità | Esempi |
|---|---|---|
| Battaglia | Tempo di simulazione (secondi o tick) | Un effetto che ritarda una truppa nemica per qualche secondo. |
| Run | Fasi e anni | Un malus che dimezza la produzione di Ricerca per un anno. |

### 8.2 Struttura di un modificatore

| Campo | Significato |
|---|---|
| Bersaglio | Che cosa viene modificato: Resistenza, riserva di mana, una truppa, un edificio, una risorsa del Magazzino, una produzione, gli spazi, le opportunità, i valori di partenza dello scontro (scudo, Corruzione, elementi inefficienti o sabotati; dalla v0.16). |
| Effetto | La variazione applicata. |
| Durata | Istantaneo, secondi di battaglia, numero di stagioni o di anni. |
| Origine | Chi o che cosa lo ha generato (un evento, un incontro, una nazione nemica). |
| Cumulabilità | Come si comporta con altri modificatori uguali. |

Il campo **Origine** è **mostrato al giocatore con il nome** di chi ha inflitto il modificatore (es. il nome del fantasma) — Confermato. Lo spunto dei malus che portano il nome della nazione nel proprio titolo (Parte III) resta separato.

### 8.2.1 Regole dei modificatori — Confermato

| Regola | Stato |
|---|---|
| Lo stesso sistema regge **malus e bonus** (peculiarità, ricompense durature) | Confermato |
| La durata si conta in **anni interi a partire dall’anno successivo**: un malus di 1 anno subito alla fine dell’anno N vale per tutto l’anno N+1 e sparisce all’inizio dell’anno N+2 | Confermato |
| Un **bonus** vale invece da subito **fino alla fine dell’anno in cui arriva** (più gli eventuali anni in più): un bonus di 1 anno preso nell’anno N sparisce all’inizio dell’anno N+1. Un bonus che agisce sulla razione di inizio anno (es. Razioni) dura un anno in più, così vale per la razione dell’anno dopo | Confermato (decisione di Davide, 8 novembre 2026) |
| Se arriva un malus già attivo, **si allunga solo la durata**; l’effetto non si somma | Confermato |
| Ogni fantasma ha nei dati i propri malus: li applica se il giocatore **perde o pareggia** contro di lui (§3.4, §11.1) | Confermato |
| La sconfitta contro un incontro del mondo **dimezza solo l’Oro**: gli incontri non lasciano malus (§3.3) | Confermato |

Primo catalogo di malus del prototipo (valori placeholder):

| Malus | Effetto |
|---|---|
| Ricerca dimezzata | La Ricerca prodotta a ogni stagione è dimezzata (esempio di P1). |
| Oro dimezzato | L’Oro prodotto a ogni stagione è dimezzato. |
| Lavori a rilento | Un edificio produce mana più lentamente in battaglia: la versione di run, per tutta la battaglia, dell’effetto di §7.7. |
| Truppa provata | Una truppa ha la ricarica più lunga in battaglia. |
| Mercati diffidenti | Rinnovare le opportunità costa di più. |
| Mercanti in fuga | Ogni consigliere mostra un’opportunità in meno (nel vecchio sistema delle opportunità, prima del Consiglio: un’alternativa in meno). |

### 8.3 Famiglie di effetti

I nomi tematici sono suggeriti dal creatore al posto dei termini generici del genere; restano provvisori.

| Famiglia | Nome tematico proposto | Funzione | Stato |
|---|---|---|---|
| Danno | — | Riduce la Resistenza nemica (prima lo scudo, §7.6.1). | Base |
| Danno agli scudi | **Danno d’assedio** (fino alla v0.30: Attacco d’assedio) | Toglie solo scudo, prima del danno normale; solo truppe Assedio (§7.6.4). | Confermato (v0.13) |
| Difesa | **Scudo**, **Cura** | Assorbe il danno; ridà Resistenza persa (§7.6.1, §7.6.2). | Confermato (v0.13) |
| Accumulo | **Corruzione** (al posto di Veleno) | Contatore che sconfigge la nazione quando raggiunge la Resistenza (§7.6.3). Sostituisce la precedente proposta di erosione continua. | Confermato (v0.13) |
| Rallentamento | **Inefficienza** (al posto di Rallentamento) | Per una durata, il timer del bersaglio avanza più piano (§7.7). | Confermato (v0.14) |
| Disattivazione | **Sabotaggio** (al posto di Distruggi) | Per una durata, il timer del bersaglio è fermo e il bersaglio non può attivarsi (§7.7). | Confermato (v0.14) |
| Eliminazione | **Uccidi** | Rimuove un elemento dallo scontro. | Spunto: oggi gli elementi non vengono eliminati in battaglia (§7.1), quindi richiede una modifica del nucleo. |

Dalla v0.18 il prototipo usa **tutte** queste famiglie tranne Eliminazione: Danno, danno d’assedio, Scudo, Cura, Corruzione, Inefficienza e Sabotaggio.

Il rapporto fra la Corruzione e la Diplomazia come sistema di accordi o diserzioni resta una proposta (§13.3).

---

# PARTE II — SISTEMI

## 9. Identità della civiltà — Confermato nella struttura, contenuti placeholder

| Elemento | Ruolo previsto |
|---|---|
| Popolo | Identità di base della civiltà. |
| Peculiarità / tratti | Caratteristiche distintive e orientamento della strategia. |
| Governo | Organizzazione politica della nazione. |
| Credo religioso | Identità spirituale e rapporto con eventi o scelte. |
| Cultura | Identità sociale e sviluppo della civiltà. |

### 9.1 Creazione della nazione — Confermato

| Regola | Stato |
|---|---|
| Tutte e cinque le dimensioni sono presenti fin da subito | Confermato |
| La nazione si crea **come in un GDR**: prima dell’anno 1 il giocatore vede tutte le opzioni **di partenza** e sceglie nome, un popolo, un governo, un credo, una cultura e alcune peculiarità iniziali; poi la run procede. I governi dei ranghi più alti non si scelgono alla creazione (la schermata può mostrarli bloccati: Proposta) | Confermato (v0.24) |
| Il **governo** cambia durante la run per evoluzione o rivoluzione (§9.4.2). Popolo, credo e cultura restano fissi per ora. L’identità **cresce** anche con le vie scelte entrando nelle ere (§10.4) | Confermato (v0.24) |
| Anche i fantasmi hanno un’identità, che vale per la loro Resistenza e per i loro tratti in battaglia | Confermato |
| Le nazioni create **restano salvate** sul PC; si possono **modificare** o **eliminare** (con conferma). Da una nazione salvata si possono giocare più run | Confermato |
| Lo **stendardo della nazione** (il drappo di carta con le iniziali e la Resistenza, §14.2) si **personalizza nella creazione della nazione**; che cosa si sceglie (colori, simbolo, forma) è da definire. Richiesta di Davide, 8 novembre 2026 | Direzione |

### 9.2 Che cosa fa un elemento dell’identità — Confermato, elenco aperto

Popoli, governi, credi, culture e peculiarità usano la stessa scheda. Ogni elemento può:

- dare una **quota di Resistenza** (§7.1.1);
- cambiare la **dotazione iniziale** (Oro, Ricerca, edifici, truppe);
- indicare **una risorsa che la Capitale produce** a ogni stagione (§6.2, v0.22): ogni popolo, governo, credo e cultura ne indica una;
- rendere alcuni **consiglieri o opportunità esclusivi o più frequenti** (§4.2);
- concedere **edifici o truppe esclusivi**;
- dare un **tratto permanente**, cioè un modificatore che dura tutta la run (§8);
- cambiare **il Consiglio**: consiglieri in più o in meno nel round, un consigliere sempre presente o escluso, opportunità in più, Oro in più o in meno sulle opportunità (v0.24);
- cambiare **l'uso delle risorse**: tasso del mercato, costo delle azioni di un consigliere, costo di Potenzia (v0.24);
- dare il suo **tipo d'identità** alle tessere esclusive (§6.6, v0.24);
- solo il popolo: indicare la **forma della plancia** della nazione (§14.2); è solo aspetto, senza effetti sulle regole (Davide, 9 novembre 2026).

Altri effetti verranno aggiunti man mano che le meccaniche si ampliano.

### 9.3 Peculiarità — Confermato

Le peculiarità (fino alla v0.30: *perk*) funzionano come le abilità di The Bazaar: bonus passivi. Alcune si scelgono alla creazione della nazione, altre si ottengono durante la run: come ricompense degli incontri del mondo (§3.3) e dall’Anziano del Consiglio (§4.2.2, v0.21). Numero delle peculiarità iniziali: placeholder (§16.3).

Catalogo del prototipo (placeholder, v0.24): 3 popoli (Pietrosangue, Maremani, Cinerali), governi a ranghi (§9.4.2: Monarchia, Repubblica e Teocrazia alla creazione), 4 credi (Culto solare, Spiriti dei luoghi, Culto degli antenati, Culto del vuoto), 4 culture (mercantile, guerriera, erudita, artigiana), le peculiarità. Il catalogo completo è in `docs/Catalogo.md` (§6 quater) ed è implementato nel gioco.

**Incompatibilità (v0.24):** nessuna per ora; **sinergie e tensioni** fra elementi sono una **Direzione**, da costruire sui tipi d'identità.

**Da definire:** livelli o rarità delle peculiarità, altre fonti di peculiarità.

L’identità dovrebbe influenzare opportunità, risposte agli eventi, strategie disponibili e, in futuro, abilità speciali (ad esempio i malus con nome, Parte III). Il modo in cui può cambiare durante la partita resta da progettare: riforme politiche, conversioni religiose e trasformazioni culturali sono possibilità, non regole. Le **vie delle ere** (§10.4) sono il primo modo confermato in cui l’identità cresce durante la run: usano la stessa scheda di §9.2 e si aggiungono agli elementi scelti alla creazione, senza sostituirli.

**Proposta non adottata:** partire con un’identità ridotta e far emergere cultura e credo attraverso gli eventi. Il creatore ha scelto tutte le dimensioni fin dalla fondazione; l’idea resta fra gli spunti (Parte III).

**Nota di portata:** cinque assi combinati moltiplicano il lavoro di contenuto e bilanciamento. È proposto di introdurli gradualmente, privilegiando assi che cambiano quali opportunità e quali eventi compaiono, più che bonus percentuali.

### 9.4 Identità del prototipo v0.24 — Confermato nella struttura, contenuti placeholder

Ogni dimensione agisce su una parte diversa del gioco. Dettagli, catalogo e motivazioni: `docs/Proposta_identita.md` (approvata il 5 novembre 2026).

| Dimensione | Su che cosa agisce |
|---|---|
| **Popolo** (razza fantasy) | Chi sei sulla plancia: Resistenza, esclusivi **in ogni era** (come le vie), un tratto, il tipo d'identità |
| **Governo** (a ranghi) | Come decidi: il Consiglio (§9.2) |
| **Credo** (tipo di fede) | Gli incanti: quelli comuni (§4.3) più 1-2 incanti esclusivi per credo, con le famiglie di effetti esistenti |
| **Cultura** | Come usi le risorse e come influenzi i consiglieri |

#### 9.4.1 Popoli

| Regola | Stato |
|---|---|
| Popoli fantasy originali con esclusivi in ogni era; quelli di un'era passata escono dalle opportunità | Confermato |
| Ogni popolo ha anche **tecnologie esclusive** in ogni era (§10.5.2) | Confermato (v0.26) |
| Prototipo: 3 popoli, Pietrosangue (difesa), Maremani (economia), Cinerali (attacco rapido); sostituiscono Montanari, Popolo del delta e Popolo delle foreste, ed ereditano i loro esclusivi, eventi, fortune e visitatori | Confermato |
| Aspetto dei popoli sui pezzi | Da definire (rimandato) |

#### 9.4.2 Governi a ranghi

| Regola | Stato |
|---|---|
| Molte forme di governo, in **ranghi**; alla creazione si sceglie un governo del rango 1 | Confermato |
| Il rango del governo non dipende dall'era (a differenza del livello del Consiglio, §4.2.1) | Confermato |
| **Evoluzione:** solo in avanti, al rango successivo, scegliendo fra i rami. Viene proposta entrando in una nuova era (si può rifiutare) oppure arriva con la **Riforma**, un evento pagato con Influenza | Confermato |
| **Rivoluzione:** causata dal Malcontento (§5.5); può portare a qualsiasi governo, anche di rango più basso. La causa del Malcontento decide quali governi sono possibili, il giocatore sceglie fra quelli; poi il Malcontento si azzera | Confermato |
| La Rivoluzione è un evento che **arriva da solo**: raggiunta la soglia, il round successivo mostra solo la Rivoluzione | Confermato (prima eccezione, §4.2.5) |
| Cambiando governo finisce il vecchio tratto e vale il nuovo; cambia la risorsa della Capitale; gli elementi sulla plancia restano | Proposta |
| Albero dei governi e loro effetti sul Consiglio | Confermato come punto di partenza; placeholder |

#### 9.4.3 Credi e culture

| Regola | Stato |
|---|---|
| Ogni credo aggiunge 1-2 incanti esclusivi, offerti da Sacerdote e Pellegrini solo a quella nazione | Confermato |
| L'**Ordine della Ragione** esce dai credi; il sapere passa alla Cultura erudita | Confermato |
| Culture del prototipo: mercantile (mercato), guerriera (azioni del Generale), erudita (azioni dello Studioso), artigiana (Potenzia) | Confermato come punto di partenza |

**Da definire:** tratti dei popoli, evoluzione proposta prima o dopo la via, costo della Riforma, governo e evoluzione dei fantasmi generati.

### 9.6 Cronache della nazione — Confermato nella struttura (modifica del nucleo, v0.29), contenuti placeholder

Davide vuole che la nazione sembri **viva**, non una serie di tasselli, e che ogni partita racconti una nazione **peculiare**, come in un sandbox (l'esempio è Stellaris: i robot che rapivano gli altri popoli e li trasformavano in cyborg). Bozza della discussione: `docs/Bozza_cronache.md`.

**Modifica del nucleo.** Aggiunge un momento nuovo all'inizio di ogni stagione (§3.2), un contatore nuovo (le inclinazioni) e regole che valgono per una sola nazione (le vocazioni).

#### 9.6.1 Momenti di cronaca

| Regola | Stato |
|---|---|
| All'inizio di ogni stagione arriva una **cronaca**: una scena che racconta qualcosa che è successo a questa nazione. Non è un'opportunità da prendere: il giocatore sceglie **come reagisce la nazione**, fra 2–3 atteggiamenti | Confermato (v0.29) |
| Momenti: **Solstizio d'inverno** (bilancio, riti, eredità), **Equinozio di primavera** (rinascita, partenze), **Solstizio d'estate** (feste, guerra; dopo il primo incontro), **Equinozio d'autunno** (raccolto, presagi del fantasma; dopo il secondo incontro). Nel primo anno niente Solstizio d'inverno | Confermato (v0.29) |
| Non consuma un round e non si salta; la produzione della stagione arriva **dopo** la reazione | Confermato (v0.29) |
| Le cronache sono costruite sulla partita: vittorie di fila, esito dell'ultimo scontro, tessere di un tipo sulla plancia, Malcontento, inclinazioni, ricordi e personaggi. Più condizioni personali ha una cronaca, più è probabile | Confermato (v0.29); pesi placeholder (§16.3) |
| Nei testi compaiono il nome della nazione, l'anno, il popolo, il governo, il credo, l'ultimo nemico e i personaggi | Confermato (v0.29) |
| Ogni cronaca ha almeno una reazione **gratuita e senza requisiti**, come gli eventi (§4.2.5). Le reazioni usano il linguaggio del nucleo (risorse, modificatori, spionaggio, livelli, Malcontento; P5) | Confermato (v0.29) |
| Il tono può essere **duro o moralmente ambiguo**: rapire, assimilare, reprimere, giustiziare | Confermato (Davide: "certo!") |
| Ogni reazione lascia una riga nella **storia della nazione**, visibile nel pannello Annali | Confermato (v0.29) |

#### 9.6.2 Inclinazioni

| Regola | Stato |
|---|---|
| Quattro coppie di tendenze opposte, sulla scheda della nazione come barre fra due poli: **Spada** (Conquistatrice / Pacifica), **Porta** (Aperta / Chiusa), **Altare** (Devota / Profana), **Legge** (Ordinata / Libera). Stanno nei **dettagli a scomparsa** della scheda: si aprono passando il mouse o con un clic (Davide, 8 novembre 2026; prima erano sempre visibili) | Confermato (Davide, v0.29 e 8 novembre 2026); nomi placeholder |
| Ogni reazione sposta una o due inclinazioni; la reazione mostra in anticipo dove spinge la nazione (P4) | Confermato (v0.29) |
| Le inclinazioni partono dall'identità: popoli, governi, credi e culture danno una spinta iniziale (es. Pietrosangue verso Chiusa, Teocrazia verso Devota) | Confermato (v0.29); valori placeholder |
| Le inclinazioni sono una **radice** delle cronache: alcune arrivano solo a una nazione molto devota, guerriera, chiusa o libera | Confermato (v0.29) |
| Le inclinazioni come radice di eventi e visitatori dei round | Proposta (non ancora nel gioco) |

#### 9.6.3 Usanze

| Regola | Stato |
|---|---|
| Quando un'inclinazione arriva a un **estremo**, la nazione prende l'**usanza** di quel polo: un tratto permanente piccolo, con un nome e una storia ("Dall'anno 3 il popolo espone nelle piazze i trofei dei vinti"). Una sola volta per polo | Confermato (v0.29; è il "tratto acquisito" della Parte III) |
| Otto usanze, una per polo: Trofei di guerra (Conquistatrice), Ambasciate permanenti (Pacifica), Porti franchi (Aperta), Mura dei padri (Chiusa), Processioni (Devota), Accademie laiche (Profana), Il grande catasto (Ordinata), Mercato nero tollerato (Libera). Effetti in `docs/Catalogo.md` §6 sexies | Placeholder (v0.29) |
| Le usanze sono elementi dell'identità: usano gli effetti dell'identità (§9.2) e, se valgono in battaglia, restano nell'identità del fantasma (§11.4) | Confermato (v0.29) |

#### 9.6.4 Personaggi e catene

| Regola | Stato |
|---|---|
| **Personaggi ricorrenti**: generale, erede, profeta, mercante straniero. Hanno un nome pescato con il seme della run, una **fiducia** che cambia con le scelte e cronache loro | Confermato (v0.29; Parte III) |
| I personaggi entrano nella storia **solo dopo il primo fantasma** (dall'anno 2), una volta ciascuno; possono uscirne (arrestati, scacciati, morti) | Confermato (Davide: "non prima del primo fantasma") |
| **Catene**: una reazione lascia un **ricordo** nella nazione; più avanti arrivano cronache che lo richiedono ("Hai liberato il prigioniero: ora suo padre manda doni") | Confermato (v0.29; Parte III) |

#### 9.6.5 Vocazioni

| Regola | Stato |
|---|---|
| Due usanze compatibili aprono una **vocazione**, che arriva come una cronaca speciale e si accetta o si rifiuta. Una vocazione rifiutata non torna; al massimo 2 vocazioni per run | Confermato (v0.29); massimo placeholder |
| Le vocazioni sono **"una via di mezzo"** (Davide): effetti forti e possibilità nuove in momenti che esistono già (dopo un incontro vinto, nel primo round della stagione, a inizio anno), ma **senza cambiare le regole di base** della battaglia e dell'economia | Confermato (Davide); questa lettura di "via di mezzo" è di Claude, da confermare |
| **Assimilatori** (Trofei di guerra + Mura dei padri): dopo un incontro vinto, al posto della ricompensa, si può prendere una truppa del nemico. Diventa della nazione con il tipo **Assimilato** e il tipo del popolo; ogni assimilazione dà +1 Malcontento e apre le cronache sugli assimilati | Proposta (v0.29) |
| **Repubblica mercantile** (Porti franchi + Mercato nero tollerato): opportunità −1 Oro, Visitatori molto più frequenti, mercato più conveniente. La bozza diceva "il mercato compra anche": è stata cambiata perché toccherebbe una regola del nucleo (§5.3) | Proposta (v0.29) |
| **Teocrazia profetica** (Processioni + Il grande catasto): a inizio anno una profezia rivela una truppa del fantasma, scritta sulla sua tessera | Proposta (v0.29) |
| **Popolo errante** (Porti franchi + Ambasciate permanenti): nel primo round di ogni stagione c'è sempre un Visitatore | Proposta (v0.29) |
| **Stato di polizia** (Il grande catasto + Mura dei padri): il Malcontento non supera mai la soglia di avviso, ma la Stabilità chiesta dalle azioni costa il doppio | Proposta (v0.29) |
| Le vocazioni compaiono sulla scheda della nazione e nella storia; usanze, vocazioni e personaggi formano l'**identità emergente** (Parte III) | Confermato (v0.29) |

**Da definire:** illustrazioni delle cronache; la schermata finale con la storia della run; quante cronache scrivere per ogni momento; equilibrio delle usanze e delle vocazioni.

## 10. Ricerca, tecnologie ed ere

Dalla v0.26 la Ricerca serve a un **albero delle tecnologie**, e le ere si raggiungono completando tecnologie. Le regole di dettaglio sono state discusse in `docs/Bozza_v0.26_ricerca_tecnologie.md`, approvata da Davide il 5 novembre 2026. Valori placeholder (§16.3).

Le tecnologie si esprimono con il linguaggio del nucleo (P5): i loro effetti sono modificatori permanenti (§8.2) o peculiarità (§9.3). L’unico concetto nuovo è la **linea** di elementi (§10.5.5), un modo di scrivere il catalogo.

### 10.1 Avanzamento asimmetrico — Confermato

Le ere dipendono dall’investimento in Ricerca, non da un calendario uguale per tutti: una civiltà può entrare in una nuova era prima di un’altra.

Fino alla v0.24 la Ricerca si conservava nel Magazzino e si spendeva per pagare l’era. Dalla v0.26 riempie le tecnologie un po’ alla volta, e l’era si raggiunge con un numero di tecnologie (§10.3).

### 10.2 Che cosa fa un’era — Confermato (v0.15; aggiornato in v0.26)

| Effetto dell’ingresso in un’era | Riferimento |
|---|---|
| Sblocca il catalogo dell’era; quelle delle ere precedenti non restano disponibili (salvo l’eccezione delle linee, §10.5.5) | §10.5.5 |
| Concede spazi edificio e truppa, nella quantità indicata nei dati dell’era | §6.3 |
| Alza la quota di Resistenza dovuta all’era | §7.1.1 |
| Dalla seconda era in poi, chiede di **scegliere una via** | §10.4 |
| Fa salire di livello il Consiglio e può proporre l’evoluzione del governo | §4.2.1, §9.4.2 |
| Apre le tecnologie della nuova era e ripesca gratis la mano | §10.5.3 |
| Rende disponibili gli effetti più forti (P2a) | §2 |

Gli elementi posseduti restano utilizzabili e non migliorano automaticamente: il vantaggio tecnologico richiede anche la capacità economica di acquistare ciò che viene sbloccato.

La scelta e la specializzazione passano sia per le tecnologie (§10.5) sia per le vie (§10.4). Fino alla v0.24 la struttura era lineare, senza albero tecnologico.

**Numero di ere — Da definire:** il prototipo ne usa 3 (“Fondazione”, “Sviluppo”, “Ascesa”, nomi placeholder); il numero della run completa si decide dopo i playtest. Ogni era in più richiede un catalogo base, nuove vie con i loro esclusivi e una nuova fascia dell’albero.

### 10.3 Regole del passaggio — Confermato (rivisto in v0.26)

| Regola | Stato |
|---|---|
| Per entrare nell’era successiva servono **N tecnologie dell’era corrente**; non si paga più l’era con la Ricerca | Confermato (v0.26) |
| Valori di prova: 4 tecnologie dell’era 1 per l’era 2; 5 dell’era 2 per l’era 3 | Placeholder |
| Raggiunto il numero, il passaggio **non è automatico**: il giocatore entra quando vuole, in qualunque round dell'anno, senza consumare il round | Confermato (v0.26) |
| Ogni era successiva richiede più tecnologie della precedente, senza meccanismi di recupero per chi è rimasto indietro | Confermato nella forma; valori placeholder |

Entrando in una nuova era, le tessere delle ere precedenti **non** restano disponibili, salvo l’eccezione delle linee (§10.5.5).

### 10.4 Le vie — Confermato (v0.15)

Entrando in un’era, dalla seconda in poi, la nazione sceglie una **via**: una direzione di sviluppo che diventa parte della sua identità (es. Via del Commercio, Via della Guerra, Via della Fede; nomi placeholder). Ogni era diventa così un capitolo della storia della nazione.

| Regola | Stato |
|---|---|
| La scelta è **obbligatoria**, al momento dell’ingresso nell’era | Confermato |
| Si sceglie **fra 3 vie** | Confermato |
| Ogni era ha un **pool di vie**. Le 3 vie da scegliere sono pescate dal pool, con più probabilità per le vie coerenti con l’identità e con le vie già scelte; alcune vie possono essere esclusive di certe identità o di certe vie precedenti | Confermato |
| Una via usa la **stessa scheda degli elementi dell’identità** (§9.2) | Confermato |
| Una via può: influenzare le opportunità (più frequenti o esclusive); concedere elementi esclusivi e **tecnologie esclusive** (§10.5.2, v0.26); dare un tratto permanente (§8), anche una risorsa in più prodotta dalla Capitale (§6.2, v0.22); dare un **bonus immediato** al momento della scelta (risorse, spazi, un elemento) | Confermato |
| Gli effetti sono **liberi**: possono riferirsi a tipi o a elementi specifici, caso per caso nel catalogo | Confermato |
| Gli **elementi esclusivi** di una via sono **diversi per ogni era**: una via scelta nell’era 2 ha esclusivi propri per l’era 2, per l’era 3 e per le successive. Gli esclusivi di un’era passata spariscono come le altre tessere dell'era | Confermato |
| Le vie si accumulano: nessuna sostituisce le precedenti o gli elementi scelti alla creazione | Confermato |
| Ogni via è un **albero di tradizioni**: adozione, 4 tradizioni sbloccate dalle imprese, completamento con un'ascensione (§10.4.1, §10.4.2) | Confermato (v0.27) |

Nota per il catalogo: un effetto legato a un elemento specifico perde valore quando l’elemento esce dalle opportunità con il cambio d’era; un effetto legato a un tipo continua a contare.

Le vie sono nel prototipo dalla v0.18, con il catalogo di `docs/Catalogo.md`.

#### 10.4.1 Tradizioni e imprese — Confermato (v0.27)

Le tradizioni di Stellaris entrano in Ultralopolis attraverso le vie, non come sistema a parte. Le regole sono state discusse in `docs/Bozza_v0.27_tradizioni.md`, approvata da Davide il 5 novembre 2026. Il catalogo delle tradizioni è in `docs/Catalogo.md` (§4.4). Valori placeholder (§16.3).

| Regola | Stato |
|---|---|
| L'**adozione** è la scelta della via entrando nell'era, come prima: tratto permanente, bonus immediato, opportunità più frequenti, esclusivi e tecnologie esclusive | Confermato |
| Ogni via ha **4 tradizioni**. Ogni tradizione ha un'**impresa** e un effetto permanente, espresso con il linguaggio del nucleo (P5) | Confermato |
| Le tradizioni non costano risorse: si completano **da soli** appena l'impresa riesce, **in qualsiasi ordine** | Confermato |
| L'albero di una via resta aperto anche nelle ere successive | Confermato |
| La via mostra le 4 imprese e i loro effetti **prima della scelta** | Confermato |
| L'era 1 non ha un albero: le tradizioni cominciano con la prima via, nell'era 2 | Confermato |
| Un'impresa **traguardo** conta solo ciò che si fa dopo l'adozione (es. vincere N scontri, completare N tecnologie di una sfera, prendere N opportunità da un consigliere, scegliere N eventi di una sfera) | Confermato |
| Un'impresa **di stato** guarda com'è la nazione (es. N tessere con un tipo sulla plancia, N tessere con un tipo al livello 2 o più, N di una risorsa in una sola produzione, Malcontento a N o meno a fine anno); basta arrivarci una volta | Confermato |
| Le imprese sono scritte nei dati della via; accanto a ognuna si vede quanto manca (P4) | Confermato |
| Imprese che guardano dentro la battaglia | Spunto (servono statistiche della battaglia che oggi non si registrano) |

#### 10.4.2 Ascensioni — Confermato (v0.27; le ascensioni maggiori sono una modifica del nucleo)

| Regola | Stato |
|---|---|
| Completando le 4 tradizioni di una via si sceglie **1 ascensione fra 3**, pescate con più probabilità per quelle coerenti con l'identità e le vie | Confermato |
| Le ascensioni sono **permanenti**; una già presa non si ripresenta; alcune possono essere esclusive di una via o di un elemento dell'identità | Confermato |
| **Ascensioni minori** (prima “livello 1”): effetti forti con il linguaggio di oggi. **Ascensioni maggiori** (prima “livello 2”): cambiano una regola e compaiono solo a chi ha già un'ascensione. Nel prototipo la prima ascensione è minore, la seconda maggiore (nomi decisi da Davide, 8 novembre 2026: “Livello” resta solo alle tessere) | Confermato |
| Un'ascensione che cambia una regola si vede in battaglia o sulla plancia (P4) | Confermato |

**Ascensioni maggiori — Confermato (modifica del nucleo, v0.27), valori placeholder.** Ognuna è un'eccezione scritta anche nella sezione della regola che cambia.

| Ascensione | Effetto | Regola che cambia |
|---|---|---|
| **Seconda natura** | Ogni truppa si può incantare due volte | §4.3 |
| **Ultima trincea** | La prima volta in ogni scontro che la Resistenza arriva a zero, torna a 1; non salva dalla Corruzione | §7.1 |
| **Prima scintilla** | Gli edifici iniziano lo scontro con il ciclo a metà | §7.5 |
| **Disciplina ferrea** | La truppa più a destra prenota il mana: finché aspetta, le altre truppe non spendono mana | §7.3 |
| **Mana unito** | Dopo il proprio colore e l'energetico, una truppa può pagare con gli altri colori | §5.3 |
| **Maestria** | Le tessere arrivano al livello 4 | §6.5 |
| **Doppio ascolto** | Una volta per stagione si prendono due opportunità dallo stesso consigliere (Proposta con le stagioni) | §4.2 |
| **Esercito frugale** | Le truppe senza Cibo non rallentano | §5.4 |

Le ascensioni minori (es. +1 spazio truppa e +1 spazio edificio; +20 Resistenza; +25% delle risorse prodotte) sono nel Catalogo (§4.5).

### 10.5 Tecnologie — Confermato (modifica del nucleo, v0.26)

#### 10.5.1 La Ricerca

| Regola | Stato |
|---|---|
| La ricerca **non è istantanea**: il giocatore sceglie una tecnologia e la Ricerca che la nazione guadagna la riempie un po’ alla volta | Confermato |
| Tutta la Ricerca guadagnata (produzione, bottino, azioni, eventi, fortune) va nella **tecnologia in corso** e **non entra nel Magazzino**: non si vende al mercato e non paga azioni | Confermato |
| Se non c’è una tecnologia in corso (all’inizio della run, o dopo averne completata una senza sceglierne un’altra), la Ricerca resta **in attesa** e passa alla prima tecnologia scelta | Confermato |
| Una tecnologia si completa **appena** raggiunge il suo costo, anche a metà di una stagione | Confermato |
| La Ricerca in più a una tecnologia completata **non va persa**: passa alla tecnologia successiva | Confermato |
| Si può **cambiare tecnologia a metà**: i progressi su quella lasciata restano salvati | Confermato |
| La tecnologia da studiare si sceglie **in qualunque momento** fuori dalla battaglia e **non consuma il round** | Confermato |
| Le tecnologie completate valgono **per sempre** | Confermato |
| Le tecnologie costano **solo Ricerca**. Costi di prova: 3 Ricerca per la prima altezza di un’era, 4 per la seconda, poi a salire con le ere | Confermato; valori placeholder |
| La produzione arriva all’inizio di ogni stagione (§5.2, v0.25): le tecnologie si completano a blocchi, circa quattro volte all’anno, più bottino, azioni ed eventi. I costi di prova erano pensati per due produzioni all'anno e vanno rivisti con le prove | Confermato (conseguenza); costi da ritarare |

#### 10.5.2 L’albero

| Regola | Stato |
|---|---|
| Esiste un **vero albero**, con prerequisiti, **unico** per tutta la run | Confermato |
| **4 rami**, uno per colore di mana, ciascuno con le due categorie a cui il colore tende (§5.3): **rosso** Militare e Opera; **verde** Terra e Ricchezza; **blu** Fede e Stato; **viola** Conoscenza e Ombra | Confermato |
| Ogni tecnologia ha una **sfera**: una delle 8 categorie, come gli eventi (§4.2.5). La sfera dice di che cosa parla e in quale ramo sta | Confermato |
| Ogni era occupa due **altezze**: l’era 1 le altezze 1 e 2, l’era 2 le altezze 3 e 4, l’era 3 le altezze 5 e 6 | Confermato |
| Si ricercano solo tecnologie della **propria era o di ere passate**, mai di ere future | Confermato |
| La seconda altezza di un’era si apre, in un ramo, dopo **1 tecnologia** della prima altezza dello stesso ramo | Confermato; quantità placeholder |
| Alcune tecnologie hanno un **prerequisito preciso**, anche di un altro ramo | Confermato |
| L’albero è **tutto visibile**; ogni tecnologia mostra i prerequisiti che le mancano (P4) | Confermato |
| Prototipo: per era e per ramo 2 tecnologie alla prima altezza e 1 alla seconda, cioè **12 tecnologie per era**, più le esclusive | Confermato; placeholder |
| **Tecnologie esclusive**: ogni via e ogni popolo ne hanno, nel ramo della loro sfera; compaiono solo per chi ha quella via o quel popolo. Prototipo: 1 per via e 1 per popolo in ogni era | Confermato; quantità placeholder |

#### 10.5.3 La mano di carte, come in Stellaris

| Regola | Stato |
|---|---|
| Il gioco mostra una **mano di 3 tecnologie**; il giocatore ne sceglie una da studiare | Confermato |
| Si pesca fra le tecnologie **disponibili** (prerequisiti completati, era non futura, non ancora completate) **in ogni ramo**, dell’**altezza più bassa** ancora aperta in quel ramo e di quella **subito sopra**. Così un ramo finito prima degli altri può andare avanti | Confermato (per ramo dal 6 novembre 2026, decisione di Davide) |
| **Peso**: base 1, +1 per ogni radice “favorita da” che la nazione possiede; una radice “richiede” la fa comparire solo se la nazione ce l’ha. Le radici sono quelle degli eventi (§4.2.5) | Confermato |
| **Sconto sulla carta scartata**: una tecnologia mostrata e non scelta ha il peso dimezzato nella mano successiva; lo sconto si accumula a ogni scarto fino a un minimo e si azzera quando la tecnologia viene scelta | Confermato; minimo placeholder |
| Una nuova mano si pesca **ogni volta che si completa una tecnologia** ed entrando in una nuova era | Confermato |
| Le tecnologie **iniziate e non finite** e le **carte dorate** (§10.5.6) compaiono sempre, in più rispetto alle 3 carte | Confermato |
| La pescata usa il seme della run | Convenzione tecnica (§16.3) |

#### 10.5.4 Che cosa si ricerca

| Famiglia | Esempio (placeholder) | Come si esprime |
|---|---|---|
| **Linea di elementi** | Una nuova linea di truppe Fante | Modificatore permanente sulle opportunità (§8.2), vedi §10.5.5 |
| **Peculiarità** | Una peculiarità come quelle dell’Anziano | Peculiarità (§9.3) |
| **Consiglio** | Un'opportunità in più da un consigliere; rinnovo o Potenzia meno cari | Modificatore permanente sulle opportunità o sui costi (come §9.2) |
| **Nazione** | Uno spazio edificio o truppa; +1 di una risorsa prodotta dalla Capitale | Modificatore permanente sugli spazi o sulla produzione |
| **Dottrina sui tipi** | “Le truppe Fante ricaricano più in fretta” | Modificatore permanente sui valori di battaglia (§16.3, ordine dei calcoli) |

Ogni tecnologia ha un **solo effetto principale**, facile da leggere. Gli effetti più forti stanno nelle altezze alte e nelle ere avanzate (P2a) — Confermato.

#### 10.5.5 Le linee di elementi

| Regola | Stato |
|---|---|
| Una **linea** è una serie di elementi, uno per era, con lo stesso ruolo (esempio: una linea di tiratori fatta come Frombolieri, Balestrieri, Moschettieri) | Confermato |
| La tecnologia sblocca la **linea**: in ogni era fa comparire fra le opportunità la versione dell’era corrente | Confermato |
| Se una linea non ha una versione per l’era corrente, resta disponibile l’**ultima versione precedente**: è l’unica eccezione alla regola per cui le tessere delle ere passate spariscono (§10.2) | Confermato |
| Gli elementi delle linee **non** sono nel catalogo base: si ottengono solo con la tecnologia o come ricompensa | Confermato |
| Entrano nelle opportunità dei consiglieri secondo i loro **tipi**, come ogni altra tessera (§4.2.4); il Giullare li può proporre | Confermato |

#### 10.5.6 Carte dorate

| Regola | Stato |
|---|---|
| Un’opzione di un Evento, una Fortuna o la ricompensa di un incontro del mondo (§3.3) possono dare una **tecnologia già iniziata** | Confermato |
| La carta dorata ha già **metà** del costo pagata e compare sempre nella mano finché non è completata | Confermato; quota placeholder |
| Può essere una tecnologia di un’altezza che la nazione non potrebbe ancora pescare, ma mai di un’era futura | Confermato |

#### 10.5.7 Progetti speciali — Direzione

Alcune tecnologie, i **progetti speciali**, potranno chiedere oltre alla Ricerca una risorsa di categoria. La maggior parte delle tecnologie costa solo Ricerca, così una nazione non resta legata a una sola risorsa. Non entrano nel primo prototipo.

**Da definire:** quali tecnologie sono progetti speciali, se sono più forti delle altre, quando si paga la risorsa (proposta: un progetto speciale per ramo e per era, pagato quando lo si inizia).

### 10.6 Questioni aperte

**Da definire:**

- Costi definitivi delle tecnologie e numero di tecnologie richiesto da ogni era.
- Numero definitivo di ere (§10.2).
- Catalogo delle vie e dei loro esclusivi.
- Catalogo dell’albero, delle linee e delle tecnologie esclusive di vie e popoli.
- Progetti speciali (§10.5.7).
- Catalogo definitivo delle tradizioni e delle ascensioni (§10.4.1, §10.4.2).

## 11. Fantasmi e asincronia

### 11.1 Principio — Confermato

Il nemico annuale è una copia registrata della nazione di un altro giocatore. Lo scontro modifica la run del giocatore attivo, non la partita del proprietario originale.

Un’arma del fantasma può lasciare una conseguenza nella run del giocatore attivo. Un sabotaggio del giocatore agisce sulla copia affrontata, non sulla nazione originale di una persona assente.

### 11.2 Selezione — Confermato

Il nemico viene fissato prima delle occasioni di spionaggio e rimane lo stesso fino allo scontro.

**Confermato (v0.15):** il nemico è un fantasma dello **stesso anno**, anche se di un’era diversa, così l’investimento tecnologico conserva valore. Gli altri criteri di matchmaking restano da definire.

### 11.3 Popolamento iniziale — Confermato

La scarsità di nemici nei primi tempi non è considerata un problema: il creatore popolerà il gioco con fantasmi ricavati dalle proprie partite sulla versione definitiva. I playtest diventano così nemici utili.

Per il prototipo si usano nemici locali (§16.3); non costituiscono multiplayer online. Negli anni senza un fantasma scritto a mano il gioco **genera** una nazione nemica dal catalogo (nome, Capitale, edifici, truppe, era, identità, peculiarità e un malus), sempre più forte con gli anni e riproducibile con il seme della run — Confermato (v0.17). Il salvataggio della propria nazione come fantasma è rimandato.

### 11.4 Dati di una copia — Proposta tecnica

Anno, era, identità rilevante (dalla v0.29 anche usanze e vocazioni), Resistenza massima, edifici, truppe e loro ordine, modificatori attivi (comprese le tecnologie che agiscono in battaglia, v0.26), tradizioni e ascensioni (v0.27) e versione delle regole. Le ascensioni che cambiano le regole della battaglia valgono anche per il fantasma. Poiché la battaglia ammette casualità (§7.5), va gestito anche il seme casuale.

È proposto di salvare le **statistiche complete** degli elementi e non solo il loro identificativo: se in seguito un elemento viene ribilanciato, la copia continua a combattere com’era stata registrata.

**Da definire:** momento di pubblicazione della copia, backend, autenticazione, criteri di selezione, gestione delle versioni, controlli contro dati non validi.

## 12. Spionaggio e sabotaggio — Confermato nella forma (v0.21), valori placeholder

Ottenere informazioni sul nemico prima dello scontro e poter intervenire su minacce specifiche. Lo spionaggio usa il fantasma già selezionato (§11.2). Il sabotaggio si esprime con la famiglia Disattivazione (§8.3) e con gli effetti di battaglia di §7.7.

| Regola | Stato |
|---|---|
| Lo spionaggio passa per il **Maestro delle spie**, uno dei consiglieri (§4.2) | Confermato |
| Ogni opportunità fa partire lo scontro con un elemento nemico **sabotato** o **inefficiente** per alcuni secondi | Confermato |
| Il bersaglio dipende dall'opportunità: **a caso**, a un’**estremità** della fila, il **più lento** o il **più veloce** (§7.7.1) | Confermato |
| Il Maestro delle spie propone anche edifici e truppe che infliggono Inefficienza o Sabotaggio | Confermato |
| Vale per lo scontro con il fantasma dell’anno, in qualunque stagione sia comprato: il fantasma si fissa a gennaio e si affronta a dicembre | Confermato (v0.21; v0.25) |
| Durate: 5 s di Sabotaggio, 10 s di Inefficienza; si paga in **Documenti** (v0.22; nella v0.21 in Influenza) | Confermato (v0.22); valori placeholder |
| Un'opportunità indica se colpisce truppe, edifici o qualsiasi elemento | Confermato (v0.21) |
| Il fantasma non spia il giocatore: è una registrazione (§11.1) | Confermato (v0.21) |

**Da definire:** informazioni visibili sulla plancia del fantasma, una statistica di spionaggio, contromisure.

## 13. Eventi e conseguenze

### 13.1 Direzione centrale

Eventi e conseguenze dipendono dalle scelte fatte, dall’identità della nazione e dall’interazione con i nemici. È parte della visione fondamentale, anche se non entra nel primo test del combattimento.

Origini possibili: sviluppo economico, ingresso in una nuova era, decisioni politiche, vittoria o sconfitta, incontri del mondo, armi particolari di un fantasma; dalla v0.24 anche il **Malcontento** (§5.5) e i **tipi d'identità** (§6.6).

Gli incontri del mondo (§3.3) sono la prima forma concreta di evento: inizialmente scontri automatici, in futuro anche eventi a scelta.

Dalla v0.23 gli **eventi a scelta** esistono nei round del Consiglio (§4.2.5): compaiono al posto di un consigliere, dipendono dall'identità e dalla plancia, e le loro opzioni possono lasciare modificatori (§13.2).

### 13.2 Conseguenze persistenti

Un effetto nemico o un evento può lasciare un modificatore per uno o più anni. Le conseguenze seguono P1: cambiano il modo di giocare per un periodo, senza debilitare pesantemente.

Durata, origine e cumulabilità dei malus del prototipo sono fissate in §8.2.1. Nel prototipo un malus si può accorciare con l’Ambasciata (§4.2, provvisorio). Intensità definitive e altre forme di rimozione restano da definire. È stata proposta una gestione che offra una decisione (ricostruire, accettare un costo temporaneo, scegliere una risposta politica): direzione di design, non catalogo approvato.

### 13.3 Corruzione e diplomazia

Il creatore ha suggerito Corruzione o Diplomazia come reinterpretazioni tematiche di effetti simili al veleno. Dalla v0.13 la Corruzione in battaglia è un accumulo che sconfigge la nazione quando raggiunge la Resistenza (§7.6.3), non più un’erosione. La Diplomazia come sistema di accordi o diserzioni resta una proposta, non una decisione.

### 13.4 Struttura dati di un evento — Proposta

Identificatore, condizioni di comparsa, testo, opzioni, requisiti, effetti immediati, modificatori persistenti (§8.2) e durata.

## 14. Interfaccia e direzione visiva

### 14.1 Vincolo — Confermato

Il progetto deve essere realizzabile senza competenze grafiche specialistiche, anche con asset generati con l’IA. Si preferisce una plancia, senza eserciti complessi animati sul campo.

### 14.2 Plancia 3D, pezzi 2D — Confermato

La plancia è una scena 3D; edifici, truppe e segnalini sono pezzi 2D con illustrazioni (anche generate con l’IA) posati sulla plancia. Il 3D riguarda l’ambiente, non le unità: niente modelli di truppe animati.

| Aspetto | Stato |
|---|---|
| Plancia in 3D, pezzi in 2D | Confermato |
| Interfaccia (risorse, Prestigio, opportunità) in 2D sovrapposta alla scena | Proposta |
| Animazioni dei pezzi come movimenti semplici via codice (spostamento, rotazione, scossa) per produzione, consumo di mana, attivazioni e danni | Proposta |
| Plancia a geometria semplice, con l’aspetto affidato ai materiali e alle texture | Proposta |
| Inquadratura quasi dall’alto, perché fino a 12 truppe in fila restino leggibili | Proposta |
| Stile visivo e materiali della plancia | Da definire |
| **Cuore** al centro della plancia: due placche, una per fila; su quella delle truppe lo stendardo con la Resistenza, su quella degli edifici la riserva di mana. Le file stanno ai due lati del cuore | Confermato (Davide, 9 novembre 2026); nome deciso il 10 novembre 2026 |
| L'ordine delle file non cambia (§7.3): si legge da sinistra a destra attraverso il cuore; una tessera nuova arriva in fondo a destra e le due metà si ribilanciano, quindi una tessera può passare dall'altra parte del cuore | Confermato (Davide, 9 novembre 2026) |
| La plancia non è un rettangolo: segue le file e cresce con loro verso i due lati. La sua **forma** è solo aspetto, senza effetti sulle regole | Confermato (Davide, 9 novembre 2026) |
| La forma della plancia del giocatore la indica il **popolo** (§9.2): Pietrosangue = **Bastione** (merli e torri), Maremani = **Arco** (file curve come un anfiteatro), Cinerali = **Ali** (due fasce a punta). Un fantasma mostra la forma del suo popolo | Confermato (Davide, 9 novembre 2026); forme dei popoli nuovi da decidere |
| Gli incontri del mondo hanno una forma per famiglia, con il tratto caratteristico sul lato rivolto verso il giocatore: mare (pirati, flotta pirata, armata del mare) = **Nave**, con la prua; terra selvaggia (barbari, orda, invasori) = **Pelli**, con pali e zanne; fuorilegge (briganti, predoni, ribelli) = **Barricata**, con un cavallo di Frisia | Confermato (Davide, 9 novembre 2026) |

Testi, numeri e indicatori restano elementi di interfaccia separati dalle illustrazioni.

### 14.3 Informazioni da rendere leggibili

| Contesto | Informazioni essenziali |
|---|---|
| Run | Anno, stagione, era, vittorie, Prestigio, ultima possibilità. Sempre visibili: anno, stagione, mese e tema del round; Prestigio, vittorie, era e Malcontento sono nella linguetta «Partita», che si apre passando il mouse (Davide, 8 novembre 2026). |
| Economia | Risorse nel Magazzino; produzione prevista per stagione. |
| Plancia | Elementi presenti, spazi liberi, ordine delle truppe. |
| Opportunità | Costo, requisiti, effetto, disponibilità nell’era corrente; con i simboli di §14.4 (v0.30). |
| Ricerca | Tecnologia in corso, Ricerca raccolta su quella necessaria, Ricerca prevista alla prossima produzione, tecnologie che mancano alla prossima era e pulsante per entrarvi; schermata dell’albero con tecnologie completate, iniziate e bloccate e il motivo del blocco (v0.26). |
| Tradizioni | Per ogni via adottata: le 4 tradizioni, l'impresa con quanto manca, l'effetto; le ascensioni prese (v0.27). |
| Nazione | Le quattro inclinazioni come barre fra due poli, le usanze, la vocazione e i personaggi con la loro fiducia (v0.29). Sempre visibile solo il nome; il resto si apre passando il mouse sulla scheda o con un clic (Davide, 8 novembre 2026). |
| Cronaca | Momento e anno, la scena, il personaggio coinvolto; per ogni reazione che cosa fa, dove spinge la nazione e, se è spenta, perché (v0.29). |
| Modificatori | Effetti attivi, durata residua e, quando previsto, origine. |
| Battaglia | Resistenza delle due parti, scudo, Corruzione accumulata rispetto alla Resistenza, danno assorbito dallo scudo, mana, ricarica, unità in attesa e motivo dell’attesa, elementi inefficienti o sabotati con durata residua e origine. |
| Esito | Risultato, perdita di Prestigio, vittorie, conseguenze. |

**Piattaforma — Confermato:** PC. Una fila fino a 12 truppe e una fino a 10 edifici condizionano comunque inquadratura e layout.

**Confermato:** risoluzione di riferimento 1920×1080; interfaccia in italiano.

**Schermate — Confermato:**

| Schermata | Contenuto |
|---|---|
| Menu principale | Gioca, Crea nazione, Esci dal gioco. |
| Gioca | Se esistono nazioni create, si sceglie con quale giocare; altrimenti si va alla creazione. |
| Crea nazione | Schermata a parte (§9.1). Creata dal menu, si torna al menu principale. |
| Partita | Si gioca sulla **plancia 3D** (§14.2): plancia, opportunità, incontri e battaglie; si può tornare al menu o ricominciare con la stessa nazione. |

### 14.4 Simboli — Confermato (v0.30)

Come nei giochi da tavolo, consiglieri, azioni e avvenimenti dicono **che cosa fanno con dei simboli**: ogni concetto del nucleo (risorse, effetti di battaglia, edificio, truppa, spazio, durata, Potenzia…) ha un simbolo, e le righe li combinano. Il testo completo resta nel riquadro dei dettagli, al passaggio del mouse. Serve al principio P4: si capisce a colpo d’occhio che cosa costa una scelta e che cosa dà. Idea di Davide (8 novembre 2026).

| Regola | Stato |
|---|---|
| Ogni riga è una cosa che si può fare e si legge da sinistra a destra: **quello che paghi → quello che ottieni** (es. Decreto fiscale: `2[Stabilità] → +4[Oro]`) | Confermato |
| `/` separa le alternative (es. Assemblea: `1[anno] +50%[Oro] / +50%[Ricerca]`); `·` separa due effetti della stessa scelta | Confermato |
| **Simboli monocromatici**: si riconoscono dalla forma, non dal colore, per non confonderli con il mana. Il colore sta nei numeri: oro per i costi, rosso per i malus. Il mana resta una gemma colorata | Confermato (scelta di Davide) |
| Uno **spazio** della plancia è il simbolo in una cornice tratteggiata; una tessera che **sale di livello** ha una freccia dorata | Confermato |
| Le righe si costruiscono **dai dati** del catalogo (costi, guadagni, modificatori di §8): cambiando un valore nei dati, la riga si aggiorna da sola | Confermato |
| Le righe corte si **affiancano** sulla stessa linea, per non sprecare spazio | Confermato (richiesta di Davide) |
| Nella **barra delle risorse** in basso ogni risorsa è **solo il suo simbolo**, lo stesso delle tessere; il nome è nel riquadro al passaggio del mouse (richiesta di Davide, v0.32). Il simbolo del Malcontento sta accanto al suo nome in alto | Confermato |
| Con il mouse sopra, un consigliere, un'azione o un avvenimento con i simboli si ingrandisce e il riquadro dei dettagli non lo copre | Confermato |
| Una **legenda** nel gioco (pulsante «Legenda» a destra) spiega come si leggono i simboli, con esempi presi dal gioco, che cosa vuol dire ogni simbolo, ogni tipo di azione della riga del timbro, ogni gemma di mana e colore dei numeri | Confermato (richiesta di Davide) |

**Che cosa mostrano consiglieri, azioni e avvenimenti — Confermato (prima fase):**

| Che cosa | Righe |
|---|---|
| Consigliere | In ordine di importanza: le sue **opportunità** del round (riga principale, del colore del consigliere: `[opportunità]: [edificio] / [truppa] / [timbro]`): edifici, truppe e azioni stanno **alla pari**, perché sono tutte opportunità e se ne prende una sola (scelta di Davide); sotto, una riga **più sottile** dice quali azioni: `[timbro] = ` e un simbolo per ogni *tipo* di azione possibile, separati da `/` («oppure»: sono voci distinte, non una frase) (scambio di risorse, bonus per un tempo, spazio, spionaggio, incanto, peculiarità…), senza costi né numeri, che si vedono sulle opportunità dopo averlo scelto; in fondo, **in disparte**, il **Potenzia** (riga con il solo bordo, mai affiancata: è un servizio in più, non un'opportunità; bordo dorato se puoi già potenziare qualche tessera, e sotto il consigliere "Ascolta · ▲ Potenzia N"). Il riquadro dei dettagli **dice solo ciò che si vede**: i tipi della linguetta, poi una frase per ogni riga, nello stesso ordine (richiesta di Davide) |
| Azione o peculiarità proposte | Costo → effetto |
| Evento, Fortuna, Visitatore | Una riga per opzione; un’opzione che adesso non si può scegliere è spenta e ha il lucchetto (P4), il motivo è nei dettagli |
| Opzione dell’evento scelto | Costo → effetti, su una o più righe |

**Tipi sulla linguetta — Confermato (v0.32, scelte di Davide):**

| Regola | Stato |
|---|---|
| Ogni **tipo** (§6.6) ha un simbolo in un **medaglione tondo**: la forma tonda lo distingue dalle risorse; come i tipi, i medaglioni non hanno colore | Confermato |
| I medaglioni stanno su una **linguetta sopra la tessera**, del colore della sua cornice, allineata a sinistra: su edifici e truppe i loro tipi, sul consigliere i tipi della sua categoria | Confermato |
| **Consiglieri e avvenimenti con un'illustrazione**: il **mezzo busto** del personaggio esce dal bordo alto della carta, come i ritratti nei dialoghi dei giochi di ruolo; per questo la linguetta dei tipi sta **sotto la carta** (Davide, 8 novembre 2026) | Confermato |
| Sopra e non di lato: sulla plancia le tessere della stessa fila sono troppo vicine per una linguetta laterale | Confermato |
| I **tipi d'identità** hanno tutti lo stesso simbolo, un **vessillo**; il nome è nei dettagli. La **Capitale** ha il suo | Confermato |
| Il simbolo di un tipo è il file `assets/icone/tipo_<nome>.svg`: un tipo nuovo prende un simbolo aggiungendo il file, senza toccare il codice; senza file prende il vessillo | Confermato |
| Lo stesso simbolo compare accanto al nome del tipo nei testi colorati (§16.3) e nella legenda | Confermato |

| Questione | Stato |
|---|---|
| Altri simboli su edifici e truppe (produzione, mana, effetti di battaglia), ricompense degli incontri e cronache | Da definire (seconda fase, dopo la prova della prima) |
| Gli otto poli delle inclinazioni delle cronache: per ora in parole | Da definire |
| Disegni definitivi dei simboli | Da definire; per ora icone provvisorie (§16.3) |

Dettagli grafici ed elenco dei simboli: `docs/direzione_artistica.md` (§4) e `assets/icone/LEGGIMI.md`.

---

# PARTE III — RISERVA DI SPUNTI

Idee annotate per il futuro. Non vanno implementate nella base; la base non deve però renderle impossibili.

| Spunto | Origine | Nota per l’introduzione |
|---|---|---|
| Truppa che elimina una truppa nemica (Uccidi) | Creatore | Troppo forte all’inizio. Richiede regole su elementi eliminati, oggi assenti: è una modifica del nucleo. Candidata per ere avanzate (P2). |
| Eventi forzati: arrivano da soli e chiedono solo come reagire | Creatore (v0.23) | Dalla v0.29 lo sono la Rivoluzione (§9.4.2) e le cronache (§9.6); altri dovranno rispettare P1 e P4 (§4.2.5). |
| Catene di eventi: una scelta sblocca un evento negli anni successivi | Proposta di Claude (v0.23) | Introdotte con le cronache (§9.6.4, v0.29); restano uno spunto per gli eventi dei round. |
| Personaggi ricorrenti: un visitatore che torna e ricorda i rapporti avuti | Proposta di Claude (v0.23) | Introdotti con le cronache (§9.6.4, v0.29); un visitatore che ricorda resta uno spunto. |
| Tratti acquisiti: un evento lascia un tratto permanente che diventa parte dell'identità | Proposta di Claude (v0.23) | Introdotti come usanze (§9.6.3, v0.29). |
| Malus che porta il nome della nazione che lo ha inflitto | Creatore | Non sempre presente: effetto speciale di certe peculiarità o abilità legate al popolo e all'identità. Usa il campo Origine (§8.2). |
| Eventi a scelta con testo e opzioni | Creatore | Seconda forma degli incontri del mondo, dopo gli scontri automatici. |
| Diplomazia come accordi o diserzioni | Creatore | Vedi §13.3. |
| Identità emergente (cultura e credo dagli eventi) | Proposta precedente | Dalla v0.29 esiste con inclinazioni, usanze e vocazioni (§9.6); cambiare cultura o credo dagli eventi resta uno spunto. |
| Nemesi: ritrovare più avanti una copia dello stesso giocatore che ci ha sconfitto | Proposta di Claude | Non discussa. Dà continuità narrativa ai nemici in un contesto asincrono. |
| Riduzione del danno a ogni colpo | Proposta precedente | Scudo e cura sono confermati dalla v0.13 (§7.6); la riduzione per colpo resta uno spunto. Punirebbe gli eserciti di truppe veloci e deboli. |
| Recupero del Prestigio | — | Nessuna regola prevista. |
| Progressione fra run | — | Non definita. |

---

# PARTE IV — PROTOTIPO E TECNICA

## 15. Primo prototipo

### 15.1 Obiettivo

Verificare un ciclo completo nel quale sviluppo economico, ordine delle truppe e produzione di mana producano scelte comprensibili. I valori devono poter cambiare rapidamente senza modificare le regole.

### 15.2 Funzioni da includere

- Nuova run con dotazione iniziale comune.
- Run completa: fino a 10 vittorie o alla sconfitta durante l’ultima possibilità, con riepilogo finale anno per anno (v0.17).
- Quattro spazi edificio e tre spazi truppa, espandibili (§6.3).
- Quattro stagioni con raccolta automatica all’ingresso e 3 round del Consiglio ciascuna, con il nome del mese (§3.2, v0.25). Consiglio nel prototipo dalla v0.22, con tipi, categorie, Potenzia, quattro colori di mana, incanti e spionaggio; dalla v0.23 anche Eventi, Visitatori e Fortune (§4.2.5).
- Magazzino persistente, acquisti, vendita con rimborso dimezzato, rinnovo delle opportunità.
- Albero delle tecnologie con la mano di 3 carte; ere raggiunte con le tecnologie (v0.26).
- Tradizioni delle vie con imprese e ascensioni (v0.27).
- Riordino delle truppe fuori dal combattimento.
- Fantasma locale fissato per l’anno.
- Produzione di mana e attivazioni automatiche.
- Resistenza, esito e progressione della run.
- Incontri del mondo come scontri automatici contro plance generate (scelta fra 3), con Oro dimezzato in caso di sconfitta e ricompense a scelta in caso di vittoria.
- Interfaccia leggibile sulla plancia 3D, con il motivo dell’attesa delle truppe, pausa, velocità e salto della visualizzazione.
- Valori separati dal codice della simulazione.

### 15.3 Sistemi successivi

Proposta di ordine: vecchie opportunità alternative complete (superate dal Consiglio, v0.21), identità della civiltà, eventi a scelta, spionaggio e sabotaggi, salvataggi, fantasmi online.

Rimandare un sistema non significa rimuoverlo dal gioco finale.

## 16. Organizzazione tecnica

### 16.1 Scelte operative

- Motore: Godot 4.7 (versione di riferimento 4.7.2).
- Piattaforma di pubblicazione: PC.
- Linguaggio: GDScript, con tipi statici e sintassi di Godot 4 (niente sintassi di Godot 3) — Confermato.
- Il codice è scritto da Claude Code; editor esterno: Cursor collegato a Godot con l’estensione Godot Tools.
- Simulazione a tick fissi e con valori interi (mana, ricarica in millisecondi, Resistenza), per scontri identici su ogni macchina: Proposta tecnica.
- Sviluppo e test principali: nuovo PC Windows del creatore, con Godot 4.7 e Cursor collegato tramite Godot Tools.
- Claude Code verifica script e test con Godot 4.7.2 nel proprio ambiente di lavoro.
- Test automatici delle regole con **GUT** (Godot Unit Test), dipendenza approvata dal creatore. Ogni nuova dipendenza va chiesta prima.
- Collaborazione e modifiche: repository GitHub separato da Satze, `Bazelguese/Ultralopolis`.

Questo documento non comporta caricamenti sul repository né modifiche della sua visibilità.

### 16.2 Architettura suggerita

| Componente | Responsabilità |
|---|---|
| Stato della run | Anno, stagione, era, vittorie, Prestigio. |
| Economia | Magazzino, produzione, pagamenti. |
| Plancia | Elementi, spazi, ordine delle truppe. |
| Catalogo | Definizioni e valori configurabili di edifici, truppe e plance generate. |
| Modificatori | Effetti persistenti e temporanei, durata, origine, cumulabilità (§8). |
| Simulazione | Mana, ricarica, effetti, Resistenza, risultato; comune a fantasmi e incontri. |
| Fantasmi | Copie immutabili e selezione del nemico. |
| Incontri ed eventi | Condizioni, plance generate, scelte, conseguenze. |
| Interfaccia | Presentazione dello stato e input consentiti. |

La separazione fra simulazione e presentazione permette di verificare le regole anche quando la grafica cambia. Il componente Modificatori è il punto in cui si innestano malus, peculiarità ed effetti futuri senza modificare la simulazione.

### 16.3 Convenzioni provvisorie del prototipo, non approvate

| Convenzione | Stato |
|---|---|
| Fantasmi e incontri scritti a mano per gli anni 1–3; dopo vengono generati. Crescita: un’era ogni 4 anni, più edifici e truppe ogni anno, truppe di un livello in più ogni 4 anni (file dati del generatore) | Placeholder. |
| Quantità di spazi concessi da ere, edifici e acquisti, e loro prezzi | Placeholder (le tre fonti sono confermate, §6.3). |
| Pescata delle 3 vie: peso base 1, +1 per ogni elemento dell’identità o via già scelta che la favorisce; se il pool ha meno di 3 vie valide, si mostrano tutte | Provvisoria, come per le opportunità. |
| Entrando in una nuova era, le opportunità del round in corso vengono ripescate gratis dalla nuova era (nel vecchio sistema delle opportunità, prima del Consiglio: le sue alternative) | Accettata dal creatore. |
| Un pareggio contro un incontro del mondo vale come vittoria (dà la ricompensa) | Accettata dal creatore. |
| Gli incontri di ogni anno sono i 3 indicati nei dati per quell’anno e per quella stagione (primavera o estate), non pescati a caso | Accettata dal creatore (stagione dalla v0.25). |
| Senza regole di generazione nei dati, se manca il fantasma di un anno si usa il più recente disponibile; uno scontro interrotto per il limite di sicurezza conta come pareggio | Protezioni tecniche contro dati sbagliati, accettate dal creatore. |
| Pool delle opportunità basato solo sull’era (l’identità non esiste ancora) | Semplificazione del prototipo. |
| Pescate delle opportunità con seme casuale registrato | Convenzione tecnica, per poter riprodurre una run nei test. |
| Tre ere e relativo catalogo | Base di prova; nomi, costi e statistiche placeholder. |
| Tick di 100 ms | Convenzione della simulazione. |
| Simboli (§14.4) presi da game-icons.net (licenza CC BY 3.0), un file per concetto in `assets/icone/`; prima di pubblicare il gioco servono i crediti degli autori | Provvisori, sostituibili file per file (v0.30). |
| Consiglieri, azioni e avvenimenti con i simboli: illustrazione più bassa, ingrandimento ×1,7 al passaggio del mouse, faccia opaca (senza riflesso) | Proposta visiva (v0.30). |
| Danno del logoramento: a partire da 45 secondi, danno a entrambe le nazioni che cresce a ogni secondo (1, 2, 3…) | Placeholder. |
| Valori della Resistenza (era, anni, edifici, truppe) e Resistenza fissa delle plance generate | Placeholder. |
| Quota degli anni nella Resistenza: l’anno N vale N volte X (l’anno 1 dà già X) | Convenzione. |
| Edifici e truppe danno nella Resistenza una quota fissa uguale per tutti; l’effetto delle peculiarità arriverà con i modificatori | Semplificazione del prototipo. |
| Limite tecnico di sicurezza: uno scontro che supera un’ora simulata viene interrotto (solo con dati sbagliati; con il logoramento non accade) | Protezione tecnica, non regola di gioco. |
| Costo del rinnovo delle opportunità e suo aumento | Placeholder. |
| Nemici locali determinati dall’anno | Sostituto del futuro servizio di fantasmi. |
| Intensità dei malus: Oro e Ricerca −50%, ciclo degli edifici e ricarica +50%, rinnovo +2 Oro, −1 alternativa | Placeholder. |
| Il bersaglio a caso di un malus (edificio o truppa) si sceglie quando il malus arriva, con il seme della run | Provvisoria. |
| Se l’elemento colpito viene venduto o sostituito, il malus finisce | Provvisoria. |
| Se non c’è un bersaglio da colpire, il malus non ha effetto | Provvisoria. |
| Malus diversi sullo stesso valore si sommano (es. due −50% azzerano) | Provvisoria. |
| Almeno 1 opportunità per consigliere (nel vecchio sistema delle opportunità, prima del Consiglio: 1 alternativa per scelta) | Provvisoria. |
| Costi delle azioni: Studiosi 3 Legno → 3 Ricerca; Addestramento 2 Ferro; Fortificazioni 2 Pietra; Ambasciata 2 Stabilità; Processione 2 Fede; Scorte 2 Legno → 3 Cibo; Razioni 2 Legno; incanti 2 Fede; spionaggi 2 Documenti (3 la Rete di sabotatori, che sabota per 8 s); Esattori +3 Oro, Grandi esattori +6 Oro e Assemblea gratis; Trattati 4 Legno → 5 Ricerca; peculiarità dell’Anziano 2 Fede + 2 Influenza; Archivisti 2 Documenti → 3 Ricerca; Manuali tecnici 2 Documenti; Decreto fiscale 2 Stabilità → 4 Oro; Censimento 2 Stabilità (v0.22). Architetti e Quartiermastro restano in Oro (gli spazi si comprano con l’Oro, §6.3) | Placeholder. |
| Peculiarità scelte alla creazione: 2 | Placeholder. |
| Bottino dei nemici sconfitti: fantasma 3 Oro e 2 Ricerca; incontri facile 2 Oro e 1 Ricerca, media 3 e 2, difficile 4 e 3 | Placeholder (v0.21). |
| Consiglio: le identità che favorivano i Costruttori ora favoriscono il Tesoriere, quelle che favorivano i Reclutatori il Generale (v0.22; nella v0.21 i Costruttori passavano all’Architetto) | Provvisoria. |
| Livelli del Consiglio: un livello più alto aggiunge azioni (Grandi esattori, Trattati, Rete di sabotatori dal livello 2, cioè dall’era 2); gli incanti crescono già con l’era della truppa | Provvisoria (v0.21). |
| Un consigliere o un'opportunità favoriti da un elemento dell’identità hanno peso +1 per ogni elemento che li favorisce (peso base 1) | Provvisoria (estesa ai consiglieri, v0.21). |
| Edifici e truppe della dotazione dell’identità entrano solo se c’è spazio, e come la dotazione iniziale non rimborsano nulla | Provvisoria. |
| I tratti permanenti non si possono accorciare con l’Ambasciata | Provvisoria. |
| Una peculiarità già posseduta non si può prendere di nuovo come ricompensa | Provvisoria. |
| Dei tratti di un fantasma valgono in battaglia solo quelli su tutta la nazione | Provvisoria. |
| Se si arriva alla creazione da Gioca (nessuna nazione salvata), dopo il salvataggio si torna alla lista delle nazioni | Provvisoria. |
| Tasso del mercato: 2 unità di una risorsa → 1 Oro, uguale per tutte | Placeholder. |
| Ogni uso di Potenzia sale di un livello | Provvisoria (v0.22). |
| Avvenimenti: probabilità 33% per round; pesi Eventi 5, Visitatori 3, Fortune 2; l'avvenimento prende il posto dell'ultimo consigliere pescato | Placeholder (v0.23). |
| Un evento conta come “comparso” appena viene pescato, anche se non lo si sceglie | Provvisoria (v0.23). |
| Fortune: il dono si moltiplica per l'era corrente | Placeholder (v0.23). |
| Edifici e truppe regalati da un evento entrano solo se c'è spazio e valgono il prezzo di catalogo per la vendita | Provvisoria (v0.23). |
| Contrabbandiere: richiede una tessera Criminale sulla plancia ed è favorito dalla Via dell'Ombra (le radici non permettono ancora “una cosa oppure l'altra”) | Provvisoria (v0.23). |
| Valori di eventi, fortune e visitatori (costi, doni, prezzi): vedi `docs/Catalogo.md` | Placeholder (v0.23). |
| Costo di Potenzia: livello 2 = 2 × era della tessera, livello 3 = 3 × era, in unità della risorsa della categoria; il Maestro delle spie chiede la stessa quantità di Oro e della risorsa casuale; l’Anziano chiede Oro | Placeholder (v0.22). |
| La Capitale non si potenzia: il suo tipo (Capitale) non sta in nessuna categoria | Accettata dal creatore per ora (v0.22). |
| In un round Misto almeno un’opportunità è un’azione, se il consigliere ne ha | Provvisoria (v0.22). |
| Giullare e Anziano compaiono in qualsiasi round, con lo stesso peso degli altri consiglieri | Provvisoria (v0.22). |
| Un consigliere è favorito (+1) da ogni elemento dell’identità che lo indica o che favorisce una sua azione | Provvisoria (v0.22). |
| Entrando in un’era (o scegliendo una via) prima di aver scelto il consigliere, si ripescano i consiglieri del round | Provvisoria (v0.22). |
| Spionaggio: il bersaglio si sceglie quando si compra, sul fantasma dell’anno; “estremità” = la truppa più a destra; con “più lento” o “più veloce” per le truppe conta la ricarica, per gli edifici il ciclo; a parità vince la posizione più a destra e le truppe stanno a destra degli edifici (v0.21) | Provvisoria. |
| Incanti: Furia (danno), Egida (scudo), Grazia (cura) 2/4/6 secondo l’era della truppa; Maledizione (Corruzione) 1/3/4; Torpore (Inefficienza su truppe) 2/4/6 s; colori rosso, blu, blu, viola, viola | Placeholder (v0.22). |
| Risorsa della Capitale per elemento dell’identità e produzioni di Stabilità e Documenti: vedi `docs/Catalogo.md` | Placeholder (v0.22). |
| Potenziamenti: +50% a tutti i valori d’effetto per livello (durate comprese), arrotondato per difetto, ma **almeno +1 per livello**, così anche un valore piccolo sale davvero (danno 1 → 2 → 3; 10 → 15 → 20); gli edifici anche +1 a ogni risorsa che producono per stagione. Il mana prodotto non cambia. Minimo nelle regole (`min_value_gain_per_level`) | Placeholder; il minimo per livello è una decisione di Davide (8 novembre 2026). |
| I potenziamenti pagati non vengono rimborsati alla vendita | Provvisoria. |
| Il Cibo si conta internamente in decimi per restare con numeri interi | Convenzione tecnica. |
| Avviando da sola la scena della partita (solo in Godot, per prova) si gioca con una nazione di prova | Convenzione tecnica. |
| Nazione di test: sempre in cima alla lista delle nazioni, identità con il primo elemento di ogni colonna, 99 di ogni risorsa tranne la Ricerca, tutti gli spazi liberi (`data/rules/test_nation.tres`) | Convenzione tecnica, solo per le prove (9 novembre 2026). |
| Un modificatore ricevuto a metà anno vale subito per il resto dell’anno, più gli anni di durata | Provvisoria. |
| Valori di scudo, cura, Corruzione e danno d’assedio di edifici e truppe | Placeholder. |
| Intensità dell’Inefficienza: il timer avanza a metà velocità; durate di Inefficienza e Sabotaggio | Placeholder. |
| Ogni scontro ha un proprio seme, ricavato dal seme della run e dall’anno, e salvato con la battaglia | Convenzione tecnica, per riprodurre lo scontro (§7.5). |
| Valori di battaglia di un elemento: prima il livello (+50% a livello), poi le percentuali dei modificatori, poi le aggiunte fisse; le aggiunte fisse valgono solo per chi ha già quel valore (es. “chi cura cura 1 in più”) | Provvisoria (v0.18). |
| I fantasmi generati scelgono a caso una via per ogni era raggiunta, fra quelle a loro consentite | Provvisoria (v0.18). |
| I malus nuovi del Catalogo entrano anche fra i malus dei fantasmi generati | Provvisoria (v0.18). |
| Identità (v0.24): nomi, tratti, Resistenza, tessere esclusive e risorse della Capitale di popoli, governi, credi e culture: vedi `docs/Catalogo.md` §6 quater | Placeholder (v0.24). |
| Un requisito di tipo d'identità (es. [Cinerale]) chiede una tessera di quel tipo sulla plancia, come i tipi di categoria; l'elemento dell'identità da solo non basta | Provvisoria (v0.24). |
| Consigliere di corte della Monarchia: è il primo consigliere ordinario ascoltato nella run, e non cambia più | Provvisoria (v0.24). |
| Effetti dei governi e delle culture sul Consiglio si sommano fra tutti gli elementi dell'identità; gli sconti sulle azioni tolgono unità da ogni risorsa del costo diversa dall'Oro, ma lasciano almeno 1; lo sconto su Potenzia lascia almeno 1 | Provvisoria (v0.24). |
| Un consigliere sempre presente non viene sostituito dall'avvenimento del round; se tutti i posti sono di consiglieri sempre presenti, quel round non ha avvenimento | Provvisoria (v0.24). |
| Repubblica: +1 Oro su ogni opportunità che costa Oro; Mercantile: al mercato 1 unità per 1 Oro | Placeholder (v0.24). |
| Incanti esclusivi dei credi: Mezzogiorno (danno + cura 2/3/4, 3 Fede), Linfa degli spiriti (cura 2/4/6 + Inefficienza 1/2/3 s, 3 Fede), Scudo degli avi (scudo 2/4/6, +50% sulle truppe senza mana, 2 Fede), Morso del nulla (Corruzione 1/2/3 + Sabotaggio 1/2/3 s, 3 Fede, viola) | Placeholder (v0.24). |
| Entrando in un'era l'evoluzione del governo si propone **dopo** la via; nessun requisito per evolvere entrando in un'era (i requisiti dei rami valgono solo per la Riforma) | Provvisoria (v0.24). |
| Riforma: 3 Influenza per ogni rango del governo da raggiungere; ripetibile; compare solo se il governo può evolvere | Placeholder (v0.24). |
| Cambiando governo, il nuovo governo dà anche la sua dotazione (oggi nessun governo dei ranghi 2 e 3 ne ha); il consigliere di corte resta | Provvisoria (v0.24). |
| Ogni governo ha una tessera esclusiva: quelli del rango 2 dell'era 2, quelli del rango 3 dell'era 3. Raggiunto con una Riforma prima di quell'era, la tessera compare solo arrivati all'era | Provvisoria (v0.24). |
| Le tessere esclusive di governi, credi e culture sono 19 (una per elemento), non 9 come nella bozza 1 della proposta | Accettata dal creatore (v0.24). |
| Valori del Malcontento: soglia 10, avviso da 7; +2 per un fantasma perso, +1 per un incontro perso, +1 per ogni truppa senza Cibo, +1 per ogni malus subito; Ordine pubblico 2 Stabilità → −3, Predica di pace 3 Fede → −2, Distribuzione di grano 3 Cibo → −2; Tumulti in piazza da 4 | Placeholder (v0.24). |
| Il Malcontento può superare la soglia fra un round e l'altro (es. a fine anno): la Rivoluzione arriva al primo round successivo | Provvisoria (v0.24). |
| Rivoluzione: la causa principale è quella che ha prodotto più Malcontento dall'ultima rivoluzione (a parità vale l'ordine sconfitte, carestie, malus, eventi). Governi possibili per causa: sconfitte → Dittatura, Monarchia assoluta, Totalitarismo; carestie → Repubblica, Repubblica parlamentare, Monarchia costituzionale; malus → Teocrazia, Ierocrazia, Monarchia; scelte degli eventi → Oligarchia, Plutocrazia, Repubblica. Il governo attuale è escluso; se non resta nessuno, si sceglie fra i governi del rango 1 | Provvisoria (v0.24). |
| Il Malcontento che sale per un'azione o un evento conta come causa "scelte degli eventi" | Provvisoria (v0.24). |
| Tecnologie: 3 Ricerca alla prima altezza di un’era e 4 alla seconda, poi a salire con le ere; 4 tecnologie dell’era 1 per l’era 2, 5 dell’era 2 per l’era 3 | Placeholder (v0.26). |
| Albero del prototipo: per era e per ramo 2 tecnologie alla prima altezza e 1 alla seconda (12 per era); 1 tecnologia esclusiva per via e per popolo in ogni era; la seconda altezza si apre con 1 tecnologia della prima nello stesso ramo | Placeholder (v0.26). |
| Sconto sulla carta scartata: peso dimezzato a ogni scarto, fino a un minimo di 1/8 | Placeholder (v0.26). |
| Carta dorata: metà del costo già pagata | Placeholder (v0.26). |
| Tradizioni: imprese ed effetti del Catalogo §4.4; ascensioni del Catalogo §4.5 | Placeholder (v0.27). |
| Imprese di stato: si controllano dopo ogni azione, a ogni produzione e a fine anno; un traguardo conta dal momento in cui la via è adottata | Provvisoria (v0.27). |
| Pescata delle 3 ascensioni: peso base 1, +1 per ogni elemento dell'identità o via che la favorisce, con il seme della run; se ce ne sono meno di 3 si mostrano tutte | Provvisoria (v0.27). |
| Disciplina ferrea: prenota il mana solo la truppa più a destra, e solo se è pronta e non sabotata; le truppe senza mana si attivano comunque | Provvisoria (v0.27). |
| Mana unito: gli altri colori si usano nell'ordine rosso, verde, blu, viola | Provvisoria (v0.27). |
| Maestria: il livello 4 costa 4 × era della tessera nella risorsa del consigliere, come gli altri livelli | Placeholder (v0.27). |
| Doppio ascolto: dopo la prima opportunità il round non si chiude e l'opportunità presa sparisce; vale una volta per stagione, con i consiglieri ordinari | Provvisoria (v0.27). |
| Fantasmi generati: tutte le tradizioni delle vie delle ere passate e metà di quelle della via dell'era corrente, a caso con il seme della run; un'ascensione per ogni albero completo | Provvisoria (v0.27). |
| Revisione dei piani (Studioso): 2 Documenti, ripesca la mano delle tecnologie | Placeholder (v0.26). |
| I fantasmi generati ricevono a caso, con il seme della run, il numero di tecnologie richiesto per ogni era raggiunta; in battaglia valgono solo quelle che agiscono in battaglia | Provvisoria (v0.26). |
| Incontro d'estate: forza a metà strada fra quella dell'anno e quella dell'anno successivo | Placeholder (v0.25). |
| Stagioni nel prototipo: pesi d'inverno dei consiglieri, eventi stagionali e tre eventi invernali come nelle Proposte del §4.2 e del §4.2.5; valori in `docs/Catalogo.md` §6 quinquies | Placeholder (v0.25). |
| Mantenimento: si pagano prima le truppe da destra a sinistra, poi gli edifici da destra a sinistra; una tessera si paga tutta o niente | Provvisoria (v0.28). |
| Cronache: inclinazioni da −5 a +5, usanza a ±5; peso di una cronaca 1 + 3 per ogni condizione personale; una cronaca ripetibile non torna per 2 anni se ce n'è un'altra possibile; pescata con un seme a parte, che non sposta quella dei consiglieri | Placeholder (v0.29). |
| Cronache: catalogo del prototipo (35 cronache, 8 usanze, 5 vocazioni, 4 personaggi) e spinte iniziali delle identità in `docs/Catalogo.md` §6 sexies | Placeholder (v0.29). |
| Vocazioni: al massimo 2 per run; la prima pronta ha la precedenza sulle altre cronache; una truppa assimilata conserva i suoi valori e i suoi tipi, più Assimilato e il tipo del popolo | Provvisoria (v0.29). |
| Testi colorati, sul modello di The Bazaar: nei suggerimenti, nei pannelli delle tessere e delle scelte, nelle cronache e nell'esito le parole chiave si riconoscono da sole e prendono un colore per famiglia (risorse come nella barra, effetti di battaglia, colori del mana, tipi, Consiglio e azioni, crescita della nazione, plancia e scontri, bonus e guadagni in verde, malus in rosso, costi in oro). Le parole che nel gioco hanno un simbolo (§14.4: risorse, effetti di battaglia, Resistenza, ricarica e ciclo, Potenzia, Malus, Malcontento, peculiarità, incanto, fantasma…) lo mostrano anche nel testo: lo stesso simbolo delle tessere, bianco; i colori del mana hanno la loro gemma colorata. I numeri vanno in grassetto e prendono il colore della parola che segue (+3 scudo). Accanto a un suggerimento compaiono al massimo 4 spiegazioni, prese dal glossario (`docs/Glossario.md`); Ricevi e Paghi non si spiegano; la parola del titolo non si rispiega. Parole, colori e spiegazioni stanno in `data/ui/lessico.tres` | Provvisoria (8 novembre 2026): palette e spiegazioni da approvare. |

Tutti gli esempi di tessere e statistiche restano modificabili.

## 17. Verifica delle meccaniche

Criteri di accettazione proposti per il prototipo:

| Caso | Risultato atteso |
|---|---|
| Ingresso in una stagione | Una sola raccolta dagli edifici già presenti; d'inverno senza Cibo. |
| Costruzione durante una stagione | Nessuna raccolta retroattiva; prima produzione all'inizio della stagione successiva. |
| Risorse non spese | Conservate al cambio di stagione e al cambio anno. |
| Ricerca guadagnata | Va tutta nella tecnologia in corso, oppure resta in attesa se non ce n’è una; non entra nel Magazzino. |
| Tecnologia completata | Si completa appena raggiunge il costo; la Ricerca in più passa alla successiva; si pesca una nuova mano. |
| Cambio di tecnologia | I progressi su quella lasciata restano salvati; la tecnologia iniziata ricompare sempre nella mano. |
| Mano | 3 tecnologie disponibili, in ogni ramo dalla sua altezza più bassa aperta e da quella sopra, mai di un’era futura; con lo stesso seme è sempre la stessa. |
| Carta scartata | Peso dimezzato nella mano successiva; torna normale quando viene scelta. |
| Seconda altezza | Si apre in un ramo dopo 1 tecnologia della prima altezza dello stesso ramo. |
| Passaggio di era | Possibile solo con N tecnologie dell’era corrente; non automatico; nessuna Ricerca spesa; opportunità coerenti con l’era. |
| Linea di elementi | Propone la versione dell’era corrente; senza versione nell’era nuova resta l’ultima precedente. |
| Carta dorata | Arriva con metà del costo pagata e compare sempre nella mano finché non è completata. |
| Tecnologie esclusive | Compaiono solo per chi ha la via o il popolo. |
| Ingresso in un’era | Spazi e quota di Resistenza dell’era concessi; dalla seconda era, scelta obbligatoria fra 3 vie. |
| Vie | Le 3 vie da scegliere vengono dal pool dell’era, pesate da identità e vie precedenti; la via scelta applica bonus immediato e tratto permanente. |
| Esclusivi delle vie | Compaiono fra le opportunità solo nell’era a cui appartengono e solo per chi ha la via. |
| Tradizioni delle vie | Un traguardo conta solo dopo l'adozione; un'impresa di stato si completa appena è vera; la tradizione dà subito il suo effetto. |
| Albero completo | Con 4 tradizioni completate si sceglie un'ascensione fra 3; la seconda ascensione è di livello 2. |
| Seconda natura | Una truppa si incanta due volte, con due effetti e +2 mana per incanto. |
| Ultima trincea | La prima volta che la Resistenza arriva a zero torna a 1; la seconda volta lo scontro è perso; la Corruzione sconfigge comunque. |
| Prima scintilla | Gli edifici producono la prima volta a metà del loro ciclo. |
| Disciplina ferrea | Con la truppa più a destra in attesa di mana, le altre non spendono mana. |
| Mana unito | Una truppa paga con un altro colore quando mancano il suo e l'energetico. |
| Maestria | Potenzia porta una tessera al livello 4. |
| Doppio ascolto | Dopo un'opportunità il round resta aperto una volta per stagione. |
| Esercito frugale | Una truppa senza Cibo mantiene la sua ricarica. |
| Abbinamento dei fantasmi | Stesso anno, era qualsiasi. |
| Truppa pronta senza mana | In attesa, senza consumi né ricarica aggiuntiva; il motivo è visibile. |
| Più truppe pronte | Valutazione da destra a sinistra. |
| Prima truppa troppo costosa | Saltata; la successiva può usare il mana disponibile. |
| Truppa a costo zero | Si attiva senza mana al termine della ricarica. |
| Inizio battaglia | Ricarica e cicli pieni; mana a zero. |
| Stesso istante | Prima la produzione di mana, poi le attivazioni. |
| Logoramento | Nessun danno prima di 45 secondi; poi danno crescente a entrambe le nazioni. |
| Doppio azzeramento | Pareggio: vittoria aggiunta, nessuna perdita di Prestigio, malus del fantasma applicati. |
| Scudo | Parte da zero; assorbe il danno prima della Resistenza; resta finché non viene consumato, senza tetto. |
| Logoramento con scudo | Il danno del logoramento viene assorbito dallo scudo. |
| Cura | Ridà Resistenza senza superare il massimo; nello stesso istante si applica prima del danno. |
| Corruzione | Sconfitta quando è pari o superiore alla Resistenza attuale, anche con scudo pieno; non scende mai. |
| Danno d’assedio | Toglie solo scudo, prima del danno normale; senza scudo va perso; solo truppe Assedio. |
| Caduta simultanea per danno e Corruzione | Pareggio. |
| Stesso seme | Lo stesso scontro con lo stesso seme dà sempre lo stesso risultato. |
| Inefficienza | Il timer del bersaglio avanza più piano per la durata; su un edificio rallenta tutte le sue produzioni. |
| Sabotaggio | Il bersaglio non si attiva per la durata, anche se pronto e con mana disponibile. |
| Rotazione dei bersagli | Nessun elemento valido viene colpito due volte prima che siano stati colpiti tutti; la rotazione è condivisa dalla nazione. |
| Colpo ripetuto | Le durate di Inefficienza o Sabotaggio si sommano. |
| Tempismo | Un elemento sabotato nello stesso istante in cui si attiva si attiva comunque; il blocco vale dall’istante successivo. |
| Inefficiente e sabotato insieme | Il blocco prevale; le durate di entrambi scorrono. |
| Resistenza | Somma di era, identità, anni, edifici e truppe all’inizio dello scontro. |
| Vendita | Rimborso pari a metà del prezzo pagato, arrotondato per difetto. |
| Rinnovo delle opportunità | Costa Oro, oppure la risorsa della categoria del consigliere; il costo cresce a ogni rinnovo e l’aumento si dimezza a ogni nuovo round. |
| Produzione della Capitale | 1 Oro, 1 Cibo, 1 Ricerca, più 1 della risorsa indicata da ogni elemento dell’identità e dalle vie con quel tratto; risorse uguali si sommano. |
| Mercato | Vende risorse per Oro; non permette di comprare risorse. |
| Avvio di un nuovo combattimento | Resistenza ripristinata; mana secondo la convenzione scelta. |
| Sconfitta nell’anno N | Perdita di N Prestigio, salvo ultima possibilità già attiva. |
| Prima discesa a zero Prestigio | Run ancora attiva in ultima possibilità. |
| Ulteriore sconfitta | Fine della run. |
| Decima vittoria | Fine della run con successo. |
| Anni oltre quelli scritti a mano | Fantasma e 3 incontri generati, uguali a parità di seme. |
| Modificatore pluriennale | Applicato per la durata prevista e poi rimosso; esempio: Ricerca dimezzata per un anno. |
| Stesso malus due volte | Si allunga la durata, l’effetto non raddoppia. |
| Sconfitta o pareggio contro un fantasma | Si applicano i suoi malus, con il suo nome come origine. |
| Scontro contro plancia generata | Stessa simulazione e stesse regole dello scontro contro un fantasma. |
| Sconfitta contro un incontro del mondo | Oro del Magazzino dimezzato (per difetto); Prestigio e vittorie invariati; durante l’ultima possibilità la run termina. |
| Vittoria contro un incontro del mondo | Bottino fisso di Oro e Ricerca; poi il giocatore può scegliere una ricompensa dal pool dell’incontro, oppure nessuna. |
| Vittoria o pareggio contro il fantasma | Bottino fisso di Oro e Ricerca; nessun bottino in caso di sconfitta. |
| Anno | Inverno (3 round), primavera (3 round, incontro), estate (3 round, incontro), autunno (3 round, fantasma); produzione all'inizio di ogni stagione. |
| Round | 3 consiglieri diversi; scelto uno, 3 opportunità (5 dal Giullare), se ne prende una sola o si passa. |
| Pool del consigliere | Propone solo tessere con almeno un tipo della sua categoria. |
| Potenzia | Sale di livello una tessera con almeno un tipo della categoria del consigliere; non consuma la scelta; una sola volta per round; non compare senza tessere valide o con tutte al massimo. |
| Potenzia dell’Anziano | Solo edifici neutri, una volta all’anno; il Giullare non lo offre. |
| Fuori dal Consiglio | Non si può potenziare (salvo eventi e ricompense). |
| Avvenimento nel round | Al massimo uno per round, al posto di un consigliere; con probabilità 0 compaiono solo consiglieri. |
| Evento | Compare una sola volta per run; scegliendo un'opzione se ne paga il costo, se ne ricevono gli effetti e il round si chiude. |
| Opzione bloccata | Si vede, spenta, con il requisito; non si può prendere finché il requisito manca. |
| Radici | Un avvenimento con “richiede” compare solo a chi ha il requisito; uno favorito esce più spesso. |
| Fortuna | Non torna nello stesso anno; il dono cresce con l'era. |
| Visitatore | Propone anche esclusivi di altre nazioni e tessere dell'era successiva ai suoi prezzi; non potenzia; si rinnova solo in Oro. |
| Costo di Potenzia | Si paga con la risorsa della categoria del consigliere. |
| Potenzia di Ombra | Costa Oro più la risorsa casuale, visibile prima di scegliere il consigliere; con lo stesso seme è sempre la stessa. |
| Tema del round | Un round Edifici propone solo edifici, Truppe solo truppe, Azioni solo azioni; Giullare e Anziano fanno eccezione. |
| Incanto | Una sola volta per truppa; aggiunge l’effetto e il costo di mana, anche a una truppa che non usava mana. |
| Spionaggio | Lo scontro con il fantasma parte con l’elemento scelto dal criterio dell'opportunità già sabotato o inefficiente; con lo stesso seme è sempre lo stesso. |
| Cronaca | Arriva all'inizio di ogni stagione, tranne il primo inverno; non si salta; la produzione arriva dopo la reazione; con lo stesso seme è sempre la stessa. |
| Inclinazioni | Partono dall'identità; una reazione le sposta; non superano il limite; all'estremo nasce l'usanza di quel polo, una volta sola. |
| Vocazione | Con le due usanze richieste arriva la cronaca della vocazione; accettata cambia ciò che dice, rifiutata non torna. |
| Personaggio | Non entra prima dell'anno 2; le sue cronache arrivano solo se c'è, con la fiducia richiesta; uscito dalla storia, la sua catena continua con i ricordi. |
| Assimilazione | Dopo un incontro vinto, con gli Assimilatori, si può prendere una truppa del nemico al posto della ricompensa: tipi Assimilato e popolo, +1 Malcontento. |

Domande di playtest: l’ordine delle truppe cambia davvero la strategia? Il motivo di una mancata attivazione è leggibile? Investire in Ricerca è un’alternativa credibile? Le stagioni offrono decisioni diverse? L’economia può riprendersi dopo una sconfitta? Un malus fa cambiare piano o si limita a pesare?

## 18. Decisioni ancora necessarie

| Priorità | Questione |
|---|---|
| Prima di sviluppare il catalogo | Riserva, miglioramenti; criterio dei rapporti fra le due funzioni degli edifici (P3). |
| Prima di ampliare la plancia | Quantità e prezzi degli spazi (§6.3); layout. |
| Prima di ampliare la ricerca | Numero definitivo delle ere; costi delle tecnologie e numero richiesto per ogni era; catalogo delle vie, dei loro esclusivi e dell’albero; progetti speciali; catalogo delle tradizioni e delle ascensioni (§10.4, §10.5). |
| Per la componente GDR | Valori del Malcontento; tratti dei popoli; costo della Riforma; governi dei fantasmi; tipi d'identità delle vie. |
| Per lo spionaggio | Informazioni visibili sul fantasma, statistica di spionaggio, contromisure. |
| Per il Consiglio | Pool definitivi dei consiglieri, prezzi per livello; costo del Potenzia dell’Anziano (§4.2.4). |
| Per l’online | Pubblicazione dei fantasmi, matchmaking, versionamento. |
| Più avanti | Progressione fra run, audio, monetizzazione, stile visivo. |

Non occorre risolvere tutto prima di provare la base. Le convenzioni indispensabili possono essere temporanee, purché dichiarate e facilmente modificabili.

## 19. Glossario

Il glossario è in un documento a parte: `docs/Glossario.md`. Per ogni termine indica il nome ufficiale, una frase per il giocatore e le note per noi; raccoglie anche i nomi ritirati e il registro delle decisioni sui nomi.

---

## Registro delle versioni

**Aggiunta del 10 novembre 2026** (v0.32, nessuna modifica del nucleo)
- **Plancia** (§14.2): il **Cuore** al centro, con lo stendardo e la riserva di mana; le file ai suoi lati nell'ordine di sempre; la forma della plancia, solo aspetto, la indica il popolo (Bastione, Arco, Ali) e per gli incontri del mondo la famiglia (Nave, Pelli, Barricata). Decisioni di Davide del 9 novembre 2026; nomi decisi il 10 novembre 2026 (glossario).
- §9.2: il popolo indica la forma della plancia.

**Aggiunta del 9 novembre 2026** (v0.32, nessuna modifica del nucleo)
- Nuova convenzione tecnica in §16.3: la **nazione di test**, sempre nella lista delle nazioni, per provare il gioco con 99 di ogni risorsa (Ricerca esclusa) e tutti gli spazi della plancia liberi. Richiesta di Davide.

**v0.32 — 8 novembre 2026**
- **Tipi sulla linguetta** (§14.4): ogni tipo ha un simbolo in un medaglione, su una linguetta sopra tessere e consiglieri; i tipi d'identità hanno tutti il vessillo (prima chiamato stendardo). Idea e scelte di Davide (linguetta sopra, medaglioni grandi, vessillo unico, anche sul consigliere).

**v0.31 — 8 novembre 2026** (solo nomi: nessuna regola cambia)
- Nuovo glossario in un documento a parte (`docs/Glossario.md`), approvato da Davide; la §19 rimanda a quello, e da lì vengono le spiegazioni delle parole chiave (§16.3).
- Edifici e truppe sono **tessere**; “carta” vale solo per le tecnologie (mano di carte, carta dorata); consiglieri, azioni, avvenimenti e vie si chiamano con il loro nome. Ciò che offre un consigliere è un'**opportunità** (prima proposta o offerta); Eventi, Visitatori e Fortune insieme sono **avvenimenti**.
- **Ricarica** delle truppe e **ciclo** degli edifici (prima cooldown e intervallo); **Inefficienza** e “inefficiente” al posto di rallentamento e “rallentato”; **danno d'assedio** al posto di attacco d'assedio e danno agli scudi; **nemico** al posto di avversario; **popolo** al posto di razza; **bersagli ammessi** al posto di categoria di bersaglio; malus **Lavori a rilento** (prima Inefficienza).
- **Peculiarità** al posto di perk, **rango** al posto di tier, **Giullare** al posto di Clown; il tipo *Produzione* diventa **Materie prime**; il Cibo delle truppe è la **razione** e il **mantenimento** è solo quello delle tessere (§5.6); le tappe delle vie sono **tradizioni** (non passi); il pannello della storia della nazione si chiama **Annali**.

**v0.30 — 8 novembre 2026**
- **Simboli sulle carte** (§14.4): consiglieri, azioni, eventi, fortune e visitatori mostrano costi ed effetti con simboli, come nei giochi da tavolo ("paghi → ottieni"); simboli monocromatici, colore solo nei numeri; righe corte affiancate. Prima fase approvata da Davide; edifici, truppe, ricompense e cronache restano da definire.
- Aggiornati §14.3 (offerte) e §16.3 (icone provvisorie, aspetto delle carte con i simboli).
- **Legenda dei simboli** nel gioco (§14.4), con esempi presi dalle carte vere.
- **Gerarchia sulla carta del consigliere** (§14.4): prima ciò che propone (riga colorata), poi le azioni, il Potenzia in fondo e in disparte (Davide: la carta del Tesoriere sembrava offrire solo Potenzia).
- Nella barra delle risorse in basso i nomi sono sostituiti dai simboli; il nome resta nel riquadro al passaggio del mouse (richiesta di Davide).
- Sul consigliere edifici, truppe e azioni stanno **alla pari** nella riga colorata (sono tutte opportunità); sotto, una riga sottile dice quali azioni (decisione di Davide).
- Le azioni del consigliere sono riassunte in **una riga di macrocategorie** (tipi di azione, senza numeri) invece di una riga per azione; le righe mostrano solo ciò che può davvero uscire nel round, e il riquadro dei dettagli dice solo ciò che si vede (decisioni di Davide).

**Correzione dell’8 novembre 2026** (v0.29, nessuna modifica del nucleo)
- Le azioni del Tesoriere (Esattori, Grandi esattori, Assemblea) sono **gratuite**, come già nel gioco: il GDD diceva che si pagavano in Influenza (§4.2.3, §16.3). Decisione di Davide: vale la versione del gioco.

**v0.29 — 6 novembre 2026** (modifica del nucleo)
- Approvata la bozza `docs/Bozza_cronache.md` (Davide: struttura sì, inclinazioni sì, vocazioni "una via di mezzo", personaggi non prima del primo fantasma, tono duro sì, "fai tutto").
- **Cronache della nazione** (§9.6): all'inizio di ogni stagione una scena costruita sulla partita, a cui la nazione reagisce; seconda eccezione a "nessun evento arriva da solo" (§3.2, §4.2.5).
- **Inclinazioni** visibili (Spada, Porta, Altare, Legge), **usanze** agli estremi, **personaggi** e **catene** con i ricordi, **vocazioni** da due usanze.
- Aggiornati fantasmi, informazioni da mostrare, spunti, convenzioni, verifica e glossario (§11.4, §14.3, Parte III, §16.3, §17, §19); in §16.3 anche l'ordine del mantenimento (v0.28).

**v0.28 — 6 novembre 2026** (modifica del nucleo)
- **Mantenimento delle carte** (§5.6): le carte potenziate e quelle speciali pagano la risorsa della categoria del loro primo tipo prima di ogni scontro; se non si paga la carta è trascurata e sale il Malcontento. Bozza: `docs/Bozza_mantenimento.md`.
- La mano delle tecnologie pesca **per ramo** (§10.5.3, decisione di Davide).

**v0.27 — 5 novembre 2026** (modifica del nucleo)
- Approvata la bozza `docs/Bozza_v0.27_tradizioni.md`: ogni **via** diventa un albero di **tradizioni**, come in Stellaris ma senza una risorsa nuova (§10.4.1).
- 4 passi per via, sbloccati dalle **imprese** (traguardi o stati della nazione), in qualsiasi ordine; le imprese si vedono sulla carta della via.
- Completando l'albero si sceglie un'**ascensione** fra 3 (§10.4.2). Il livello 2 cambia una regola del nucleo: Seconda natura (§4.3), Ultima trincea (§7.1), Prima scintilla (§7.5), Disciplina ferrea (§7.3), Mana unito (§5.3), Maestria (§6.5), Doppio ascolto (§4.2), Esercito frugale (§5.4).
- Aggiornati fantasmi, informazioni da mostrare, prototipo, convenzioni, verifica, decisioni e glossario (§11.4, §14.3, §15.2, §16.3, §17, §18, §19).

**v0.26 — 5 novembre 2026** (modifica del nucleo)
- Approvata la bozza `docs/Bozza_v0.26_ricerca_tecnologie.md`: la Ricerca serve a un **albero delle tecnologie** (§10.5).
- La Ricerca non sta più nel Magazzino: riempie la tecnologia in corso un po’ alla volta; non si vende e non paga azioni. Tolto il Mercante; il Tesoriere paga in Influenza (§4.2.3, §5.3). *(Corretto l’8 novembre 2026: le azioni del Tesoriere sono gratuite.)*
- Albero unico a **4 rami** per colore, ognuno con due categorie; due altezze per era; mano di **3 carte** come in Stellaris, con sconto sulla carta scartata; tecnologie iniziate e carte dorate sempre nella mano (§10.5.2, §10.5.3).
- Si ricercano linee di elementi, perk, miglioramenti del Consiglio e della nazione, dottrine sui tipi; tutte valgono per sempre (§10.5.4). Le **linee** propongono la versione dell’era corrente, o l’ultima precedente (§10.5.5).
- Le ere si raggiungono con **N tecnologie** dell’era corrente, quando lo decide il giocatore; non si paga più l’era con la Ricerca (§10.3). Superate “la Ricerca si conserva e viene spesa” e la struttura lineare.
- **Carte dorate** da eventi, fortune e incontri del mondo (§3.3, §10.5.6); tecnologie esclusive di vie e razze (§10.4, §9.4.1); azione Revisione dei piani dello Studioso (§4.2.3).
- Progetti speciali con risorsa di categoria: Direzione, dopo il primo prototipo (§10.5.7).
- Aggiornati informazioni da mostrare, prototipo, convenzioni, verifica, decisioni e glossario (§14.3, §15.2, §16.3, §17, §18, §19).

**v0.25 — 5 novembre 2026** (modifica del nucleo)
- L'anno ha **12 round, uno per mese**, in **quattro stagioni** da 3 round: inverno senza scontri, primavera ed estate con un incontro del mondo ciascuna, autunno con il fantasma che chiude l'anno (§3.2, §3.3, §4.1). Le stagioni sostituiscono Produzione e Preparazione.
- Gli edifici producono all'inizio di ogni stagione, d'inverno senza Cibo; i valori di produzione non cambiano (§5.2). Il consumo di Cibo resta all'inizio dell'anno, che ora è l'inizio dell'inverno (§5.4).
- Temi dei round per stagione (§4.2); nome del mese visibile in ogni round (§3.2).
- La stagione diventa una radice di eventi, visitatori e fortune (§4.2.5). Proposte: pesi dei consiglieri d'inverno, eventi stagionali e invernali, incontro d'estate più forte.
- Bozza della discussione: `docs/Bozza_v0.25_stagioni.md`.

**v0.24 — 5 novembre 2026** (modifica del nucleo)
- Approvata la proposta sull'identità (`docs/Proposta_identita.md`, bozza 2): razze fantasy, governi a tier con evoluzione e rivoluzione, credi con incanti esclusivi, culture che cambiano l'uso delle risorse (§9.4).
- Nuovo contatore **Malcontento**, con la **Stabilità** come risorsa per farlo scendere (§5.5).
- **Tipi d'identità** fuori dalle categorie, sulle carte esclusive; massimo 3 tipi per carta (§6.6).
- La **Rivoluzione** è il primo evento che arriva da solo (§4.2.5); le opzioni possono cambiare governo e Malcontento.
- Nuovi effetti della scheda dell'identità sul Consiglio e sulle risorse (§9.2).
- Ogni evento ha almeno un'opzione gratuita e senza requisiti (§4.2.5); sei eventi nuovi senza costi in risorse (Catalogo).

**v0.23 — 5 novembre 2026** (modifica del nucleo)
- Nei round possono comparire **Eventi**, **Visitatori** e **Fortune** al posto di un consigliere: al massimo una carta per round, in media 1 round su 3 (§4.2.5).
- Ogni carta ha una **sfera** (una delle 8 categorie) e delle **radici** (identità, vie, era, tipi sulla plancia, stato della nazione); le opzioni degli eventi possono essere sbloccate dalla nazione e quelle bloccate restano visibili (§4.2.5).
- Primo catalogo: 18 eventi, 6 fortune, 6 visitatori, tutti placeholder (Catalogo).
- Nuovi spunti: eventi forzati, catene di eventi, personaggi ricorrenti, tratti acquisiti (Parte III).

**v0.22 — 5 novembre 2026** (modifica del nucleo)
- Le etichette diventano **tipi**: un’unica lista per edifici e truppe; Tiratori e Cavalleria non esistono più (§6.6).
- **Categorie**: insiemi di tipi che formano il campo di ogni consigliere; un consigliere propone le carte con almeno un tipo della sua categoria (§4.2.4).
- **Potenzia**: si potenzia solo con il Consiglio (quarta opzione che non consuma la scelta), oltre che con eventi e ricompense; il costo lo decide il consigliere (§6.5). Tolte le azioni di potenziamento di Architetto e Generale (§4.2.3).
- **Quattro colori** di mana: rosso, verde, blu, viola, più l’energetico; i tipi non hanno colore, le categorie danno solo una tendenza (§5.3).
- Clown con 5 elementi; Anziano con Potenzia sugli edifici neutri una volta all’anno (§4.2.2). Diplomatico rinominato Cancelliere (placeholder).
- Il “tipo del round” si chiama ora **tema del round**, per non confonderlo con i tipi delle carte (§4.2).
- Direzione: la Ricerca servirà anche per le tecnologie (§10.5).
- **Risorse riviste** (§5.3, §4.2.4): ogni categoria ha la sua risorsa per Potenzia (Ferro, Pietra, Legno, Influenza, Documenti, Fede, Stabilità; Ombra Oro più una risorsa casuale). Nuove risorse **Stabilità** e **Documenti**; la **Fauna** non è più una risorsa (resta come tipo). Le azioni si pagano come prima.
- Le risorse di categoria pagano anche il **rinnovo** del proprio consigliere e almeno un’azione (Ambasciata in Stabilità, spionaggio in Documenti: Proposta); direzione: eventi a scelta e tecnologie potranno chiedere risorse (§5.3).
- La **Capitale** produce Oro, Cibo e Ricerca più una risorsa per ogni elemento dell’identità e per le vie con quel tratto (§6.2, §9.2, §10.4).
- Il **mercato** è solo in vendita (§5.3).

**v0.21 — 4 novembre 2026** (dopo le partite di Davide)
- L’anno ha 5 round, l’incontro del mondo, altri 5 round e il fantasma; edifici e truppe si ottengono in entrambe le metà (§3.2, §4.1). L’economia non cambia.
- Il **Consiglio** sostituisce le opportunità: 3 consiglieri a caso per round, se ne sceglie uno, si prende una delle sue 3 proposte; tipi di round, livelli legati all’era, Clown e Anziano (§4.2). Approvato dal creatore e nel prototipo, con il pool di §4.2.3.
- **Incanto** delle truppe (§4.3).
- **Spionaggio** con il Maestro delle spie: sabotaggio o rallentamento all’inizio dello scontro con il fantasma, con criterio di bersaglio (§7.7.1, §12).
- **Bottino** fisso di Oro e Ricerca per i nemici sconfitti (§3.3, §3.4, §16.3); già nel prototipo.

**v0.20 — 4 novembre 2026** (dopo le prime partite di Davide)
- La prima opportunità di ogni fase offre solo elementi: 3 edifici in Produzione, 3 truppe in Preparazione (§4.2).
- Le azioni che non sono acquisti costano risorse diverse dall’Oro (§4.2, §16.3).
- Il rinnovo delle offerte costa sempre almeno 1 Oro (§4.2).
- Nota: queste modifiche erano state numerate “v0.19” in parallelo alla v0.19 della plancia 3D.

**v0.19 — 4 novembre 2026**
- La partita si gioca solo sulla plancia 3D; l’interfaccia provvisoria è stata tolta (§14.3, §15.2, §16.3).

**v0.18 — 4 novembre 2026** (implementazione)
- Nel prototipo: scudo, cura, Corruzione, attacco d’assedio, Inefficienza e Sabotaggio con seme casuale (§7.6, §7.7); valori di partenza dello scontro (§8.2); potenziamenti su tutti i valori d’effetto (§6.5); ere con le vie (§10.4); edifici neutri (§5.3).
- Il catalogo di `docs/Catalogo.md` (bozza 3) è nei dati del gioco.
- Nuove convenzioni su ordine dei calcoli, vie dei fantasmi generati e malus (§16.3).

**v0.17 — 4 novembre 2026** (unione con il lavoro della sessione parallela)
- Il prototipo gioca una run completa, fino a 10 vittorie o alla sconfitta durante l’ultima possibilità, con riepilogo finale (§15.2).
- Fantasmi e incontri generati dal catalogo negli anni senza dati scritti a mano (§3.3, §11.3, §16.3).
- Nota: questa sessione aveva numerato queste modifiche “v0.13” in parallelo alla v0.13 su difesa e Corruzione; qui sono riunite come v0.17.

**v0.16 — 4 novembre 2026** (modifica del nucleo per gli edifici neutri)
- Edifici senza mana: neutri, senza colore; possono essere comuni o esclusivi di certe nazioni (§5.3).
- I modificatori possono cambiare i valori di partenza dello scontro: scudo, Corruzione, elementi rallentati o sabotati (§7.6, §7.7, §8.2).
- Potenziamenti: ogni livello aumenta tutti i valori d’effetto (§6.5, §16.3).
- Il catalogo placeholder dei contenuti è in `docs/Catalogo.md`.

**v0.15 — 4 novembre 2026** (modifica del nucleo per gli spazi della plancia)
- Ere lineari con scelta obbligatoria di una via fra 3 dalla seconda era; le vie usano la scheda dell’identità, compaiono da un pool pesato e hanno esclusivi diversi per ogni era (§10.2, §10.4).
- Costo delle ere crescente, senza recupero; numero di ere da definire dopo i playtest, 3 nel prototipo (§10.2).
- Spazi della plancia da tre fonti insieme: ere, edifici, acquisto con Oro (§6.3).
- P2a confermato: gli effetti più forti si sbloccano nelle ere avanzate (§2).
- Fantasmi dello stesso anno, anche di era diversa (§11.2).
- L’identità cresce con le vie (§9); aggiornati convenzioni, criteri di verifica e decisioni aperte (§16.3, §17, §18).

**v0.14 — 4 novembre 2026** (modifica del nucleo)
- Casualità ammessa in battaglia, sempre con seme registrato; sostituisce “nessuna casualità” (§7.5, §11.4).
- Nuova §7.7: Inefficienza (rallenta) e Sabotaggio (blocca) su truppe ed edifici, con bersaglio a caso a rotazione condivisa dalla nazione, durate sommate, effetto dall’istante successivo e blocco che prevale.
- Aggiornati malus Inefficienza, famiglie di effetti, spionaggio, informazioni di battaglia, convenzioni e criteri di verifica (§8.2.1, §8.3, §12, §14.3, §16.3, §17).

**v0.13 — 4 novembre 2026** (modifica del nucleo)
- Nuova §7.6: Scudo e Cura (famiglia Difesa), Corruzione come accumulo che sconfigge quando raggiunge la Resistenza, attacco d’assedio che colpisce solo gli scudi (solo truppe Assedio).
- Edifici e truppe possono produrre mana, scudo, cura e Corruzione in qualsiasi combinazione; un edificio produce tutto allo scadere del suo unico intervallo (§7.4, §7.6.5).
- Il logoramento viene assorbito dallo scudo; ordine completo dentro lo stesso istante (§7.5, §7.6.6).
- Pareggio anche per caduta simultanea dovuta alla Corruzione (§3.4).
- Aggiornati famiglie di effetti, riserva di spunti, informazioni di battaglia, convenzioni, criteri di verifica e glossario (§8.3, §13.3, Parte III, §14.3, §16.3, §17, §19).
- Correzioni: tolti dagli spunti e dalle decisioni aperte i tipi di mana, già confermati in v0.12; il Magazzino contiene tutte le risorse (§14.3, §19).

**v0.12 — 4 novembre 2026** (modifica del nucleo)
- Nuove risorse: Cibo, Legno, Pietra, Ferro, Fauna, Fede, Influenza; mercato delle risorse a tasso fisso (§5.3).
- Mana a colori (rosso, verde, blu) più l’energetico, che vale come qualsiasi colore (§5.3, §7.4).
- Cibo e mantenimento delle truppe, con fame che rallenta la ricarica (§5.4).
- La Capitale diventa l’edificio iniziale (§6.2).
- Potenziamenti a livelli ed etichette di edifici e truppe (§6.5, §6.6).

**v0.11 — 4 novembre 2026**
- Menu principale con Gioca, Crea nazione ed Esci; creazione della nazione in una schermata a parte (§14.3).
- Le nazioni create restano salvate e si possono modificare o eliminare (§9.1).

**v0.10 — 4 novembre 2026**
- Identità della civiltà: creazione della nazione come in un GDR con tutte e cinque le dimensioni; effetti possibili di ogni elemento; perk come abilità passive, alcune iniziali e altre come ricompense; identità anche per i fantasmi (§9).
- Contenuti placeholder dell’identità e nuove convenzioni provvisorie (§9.3, §16.3).

**v0.9 — 4 novembre 2026**
- Le 3 alternative sono tipi di opportunità diversi, pescati con la stessa probabilità; alcune hanno una scelta interna (§4.2).
- Primo elenco provvisorio di undici tipi di opportunità, fra cui Assemblea, Addestramento, Fortificazioni e Ambasciata (§4.2).
- I modificatori possono colpire la Resistenza e durare fino al prossimo scontro con il fantasma; i malus si possono accorciare con l’Ambasciata (§8, §13.2).

**v0.8 — 4 novembre 2026**
- Regole dei modificatori: malus e bonus nello stesso sistema, durata in anni dal successivo, stesso malus allunga la durata, malus dei fantasmi su sconfitta o pareggio, incontri solo Oro dimezzato (§8.2.1).
- L’origine dei modificatori è mostrata con il nome (§8.2).
- Primo catalogo di sei malus placeholder (§8.2.1).

**v0.7 — 4 novembre 2026**
- Corretto un fraintendimento: le opportunità sono **2 per fase**, ognuna con 3 alternative; ogni alternativa è un singolo acquisto (§4.2).
- Produzione = costruzione (edifici), Preparazione = disposizione (truppe) (§4.2).
- Espansione della plancia riportata a “Da definire”; il prototipo usa le tre vie solo in via provvisoria (§6.3, §16.3).
- Vendita: le ricompense rimborsano metà del prezzo di catalogo; dettagli della sostituzione e degli edifici che concedono spazi (§6.4).
- Aggiunte le convenzioni accettate dal creatore (§16.3).

**v0.6 — 4 novembre 2026**
- Pareggio confermato: conta come vittoria, ma applica i malus del fantasma (§3.4).
- Incontri del mondo: uno per anno fra Produzione e Preparazione, scelta fra 3, Oro dimezzato in caso di sconfitta, fine run se si perde in ultima possibilità, ricompense a scelta da un pool ristretto (§3.3, §4.1).
- Opportunità: 3 per fase con 3 alternative ciascuna, offerte pescate a caso da un pool, possibilità di passare e di rinnovare pagando Oro con costo crescente il cui aumento si dimezza a ogni nuova opportunità, senza scendere sotto il costo iniziale (§4.2).
- Mana iniziale zero confermato; direzione per più tipi di mana per colore (§5.3).
- Riordino delle truppe fuori dal combattimento, copie multiple ammesse (§6.1).
- Espansione della plancia con ere, edifici e acquisto con Oro (§6.3); vendita con rimborso dimezzato (§6.4).
- Calcolo della Resistenza da era, identità, anni, edifici e truppe (§7.1.1).
- Produzione degli edifici a ritmo individuale come i cooldown; tempistiche della battaglia confermate; logoramento dopo 45 secondi; nessuna casualità in battaglia (§7.4, §7.5).
- Solo Danno nel prototipo (§8.3); avanzamento di era senza consumare opportunità, offerte delle ere precedenti non disponibili (§10).
- Chiarito che la bozza di codice citata in precedenza non esiste; §16.3 diventa l’elenco delle convenzioni provvisorie del prototipo (§0.3).
- Interfaccia provvisoria 1920×1080 in italiano; nuovo PC Windows; GUT approvato per i test (§14.3, §16.1).
- Aggiornate le convenzioni del prototipo, i criteri di verifica e le decisioni aperte (§16.3, §17, §18).

**v0.5 — 4 novembre 2026**
- Confermato GDScript come linguaggio, con esportazione nativa per PC (§16.1).

**v0.4 — 4 novembre 2026**
- Confermata la direzione visiva: plancia 3D con pezzi 2D (§14.2, pilastro 6).
- Confermata la pubblicazione su PC (§14.3, §16.1); linguaggio ancora da scegliere.
- Aggiunta la proposta tecnica di simulazione a tick fissi con valori interi (§16.1).

**v0.3 — 4 novembre 2026**
- Incontri del mondo inclusi nel primo prototipo (§3.3, §15.2).
- Confermato che la sconfitta contro un incontro del mondo ha conseguenze leggere, dello stesso tipo della sconfitta contro un fantasma ma minori; entità da tarare e comportamento durante l’ultima possibilità da definire.

**v0.2 — 4 novembre 2026**
- Documento riorganizzato in Nucleo, Sistemi, Riserva di spunti, Prototipo e tecnica; aggiunto lo stato “Spunto”.
- Aggiunti i principi di design del nucleo (§2), fra cui P1 confermato: le conseguenze negative deviano, non debilitano.
- Aggiunti gli incontri del mondo (§3.3): sostituiscono il ruolo degli scontri PvE di The Bazaar; inizialmente scontri automatici contro plance generate.
- Aggiunti i massimi indicativi della plancia (10 edifici, 12 truppe) e le ipotesi di espansione (§6.3, da definire).
- Vendita e sostituzione portate a priorità alta, perché da esse dipende l’effetto dei malus (§6.4).
- Aggiunto il linguaggio degli effetti e la struttura dei modificatori con campo Origine (§8).
- Confermato il popolamento iniziale con fantasmi ricavati dalle partite del creatore (§11.3); proposta di salvare le statistiche complete nelle copie (§11.4).
- Pareggio esplicitamente lasciato da definire.
- Creata la riserva di spunti (Parte III), fra cui Uccidi e i malus con nome.

**v0.1 — 4 novembre 2026**
- Consolidamento delle decisioni della conversazione iniziale; distinzione fra regole confermate, direzione e convenzioni della bozza di prototipo.
