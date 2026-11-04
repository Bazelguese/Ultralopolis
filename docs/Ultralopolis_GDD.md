# ULTRALOPOLIS
## Game Design Document — v0.5

**Data:** 4 novembre 2026
**Stato:** base di design (nucleo) per il primo prototipo
**Motore scelto:** Godot (GDScript, esportazione nativa per PC)
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

I numeri di economia, mana, cooldown, danni, Resistenza e ricerca sono placeholder e non costituiscono bilanciamento approvato. Fanno eccezione i valori esplicitamente adottati per la struttura della run e della plancia iniziale.

La bozza di codice già preparata è un esperimento e non una fonte normativa: le convenzioni che introduce senza approvazione restano provvisorie (elenco in §16.3). Il documento non certifica che il codice sia stato eseguito o verificato in Godot.

---

## 1. Visione del gioco

Ultralopolis è un gioco strategico asincrono nel quale ogni partita è una run indipendente che racconta la crescita di una civiltà. Il giocatore costruisce la propria nazione, sviluppa un’economia, ricerca nuove ere tecnologiche e prepara una plancia che combatte automaticamente contro copie delle nazioni di altri giocatori e contro minacce del mondo.

La fantasia centrale è **vivere la nazione come un personaggio di un GDR**. Le decisioni devono costruire un’identità e una storia: non soltanto una produzione efficiente o un esercito potente, ma un popolo trasformato dalle proprie scelte, dagli eventi e dagli avversari incontrati. Il tema di nazione e popolo viene portato avanti senza la classica struttura a turni, con il twist della battaglia automatica.

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
5. **Asincronia.** Gli avversari sono copie; non è necessario che due persone giochino nello stesso momento.
6. **Realizzabilità grafica.** Il gioco funziona su una plancia 3D con pezzi 2D statici e feedback leggibile, senza eserciti animati complessi.

---

# PARTE I — NUCLEO

## 2. Principi di design del nucleo

Questi principi valgono per tutto il contenuto futuro. Un nuovo elemento che li viola richiede una discussione esplicita, non un’aggiunta silenziosa.

| # | Principio | Stato |
|---|---|---|
| P1 | **Le conseguenze negative deviano, non debilitano.** Un malus deve spingere il giocatore a ragionare in modo diverso per un periodo, non indebolirlo pesantemente. Esempio: produzione di Ricerca dimezzata per un anno, durante il quale il giocatore può orientarsi su altro. | Confermato |
| P2 | **La potenza segue il progresso.** Effetti molto forti non devono essere disponibili dall’inizio della run. | Direzione |
| P2a | Il meccanismo naturale per farlo sono le ere: gli effetti più forti vengono sbloccati da ere avanzate. | Proposta |
| P3 | **Gli edifici si distinguono per il rapporto fra le due funzioni.** La doppia funzione crea scelte solo se edifici diversi bilanciano diversamente produzione economica e mana (es. molta Ricerca e poco mana, poco Oro e molto mana). Se un edificio fosse migliore su entrambi i fronti, la scelta sparirebbe. | Proposta |
| P4 | **La battaglia deve spiegarsi da sola.** Il giocatore deve poter capire perché una truppa non si è attivata (mana insufficiente, cooldown, effetto avversario). Con la priorità da destra verso sinistra, la leggibilità fa parte della meccanica. | Proposta |
| P5 | **Il contenuto si esprime con il linguaggio del nucleo.** Nuovi edifici, truppe, eventi e malus vanno descritti con risorse, slot, cooldown, mana, Resistenza e modificatori già esistenti (§8). Ciò che richiede una nuova famiglia di effetti o una nuova risorsa è una modifica del nucleo. | Proposta |

## 3. Struttura della run

### 3.1 Run indipendente — Confermato

Ogni partita è una nuova storia di una civiltà. “Campagna” descrive eventualmente la storia vissuta in quella run, non una campagna narrativa separata e permanente.

Gli elementi posseduti e le conseguenze persistono all’interno della run. Progressione permanente fra run, sblocchi di account o ricompense collezionabili non sono definiti.

### 3.2 Anni e scontri — Confermato

La run è divisa in anni. Ogni anno contiene due macrofasi:

1. **Produzione**: sviluppo dell’economia e della nazione.
2. **Preparazione**: organizzazione della forza militare per lo scontro.

Ogni macrofase contiene più momenti di scelta fra opportunità alternative. L’anno si conclude con uno **scontro automatico contro un fantasma**, seguito dall’esito e dalle eventuali conseguenze. È previsto uno scontro contro un fantasma alla fine di ogni anno.

La durata in minuti della run non è ancora fissata.

### 3.3 Incontri del mondo — Confermato nella funzione, Da definire nei dettagli

Lo scontro contro il fantasma resta il momento centrale dell’anno, ma da solo lascia l’anno povero di tensione. Nel ruolo che in The Bazaar hanno gli scontri contro i mostri entrano gli **incontri del mondo**: minacce ed eventi legati al tema della nazione, ad esempio un’invasione di barbari o un attacco di pirati.

| Aspetto | Stato |
|---|---|
| Esistenza degli incontri come parte dell’anno | Confermato |
| Prima implementazione: solo scontri automatici contro una **plancia generata** | Confermato |
| In futuro, misto di scontri automatici ed eventi a scelta (testo e opzioni) | Direzione |
| Lo scontro usa la stessa simulazione del combattimento contro i fantasmi; la plancia generata ha la stessa struttura di una plancia giocatore | Proposta |
| Le 10 vittorie della run restano legate agli scontri contro i fantasmi; gli incontri del mondo non le modificano | Proposta |
| Numero di incontri per anno e loro posizione (in quale macrofase, se come opportunità o come momento fisso) | Da definire |
| Presenza nel primo prototipo | Confermato |
| La sconfitta ha **conseguenze leggere**, dello stesso tipo della sconfitta contro un fantasma ma di entità inferiore | Confermato |
| Forma ed entità esatta della conseguenza (es. una frazione della perdita di Prestigio prevista per l’anno) | Proposta, da tarare nel playtest |
| Effetto di una sconfitta durante l’ultima possibilità (può terminare la run oppure no) | Da definire |
| Ricompense per la vittoria | Da definire |

### 3.4 Vittoria e fine della run — Base adottata

| Regola | Valore o comportamento |
|---|---|
| Vittorie necessarie | 10 scontri contro fantasmi vinti, anche non consecutivi. |
| Prestigio iniziale | 20. |
| Vittoria annuale | Aggiunge una vittoria al totale della run. |
| Sconfitta annuale | Fa perdere Prestigio pari al numero dell’anno corrente. |
| Primo esaurimento del Prestigio | Attiva l’ultima possibilità; la run continua. |
| Sconfitta durante l’ultima possibilità | Termina la run. |

Valori adottati come base ispirata al sistema standard di The Bazaar. Non implicano che il bilanciamento di quel gioco sia automaticamente valido per Ultralopolis.

Esempio: perdere nell’anno 3 costa 3 Prestigio; perdere nell’anno 8 costa 8. Non esiste un numero fisso di sconfitte tollerate.

Non sono previste per ora regole per recuperare Prestigio o ricompense speciali all’attivazione dell’ultima possibilità.

**Pareggio — Da definire.** Il prototipo usa una regola provvisoria (§16.3). Come riferimento: in The Bazaar non esistono pareggi, e il doppio azzeramento conta come vittoria del giocatore attivo.

**Da definire:** conseguenze di abbandono e trattamento dei combattimenti che non terminano.

## 4. Ciclo annuale

### 4.1 Sequenza di riferimento

| Passaggio | Comportamento |
|---|---|
| Nuovo anno | Conservazione della nazione, del Magazzino e dei modificatori attivi; aggiornamento delle durate. |
| Selezione del fantasma | L’avversario dell’anno viene fissato. |
| Inizio Produzione | Tutti gli edifici già costruiti producono le rispettive risorse. |
| Scelte di Produzione | Opportunità di costruzione e sviluppo. |
| Inizio Preparazione | Tutti gli edifici già costruiti producono di nuovo. |
| Scelte di Preparazione | Reclutamento, organizzazione della plancia e, in futuro, spionaggio e operazioni militari. |
| Incontri del mondo | Posizione nell’anno da definire (§3.3). |
| Combattimento contro il fantasma | Produzione di mana e attivazione automatica delle truppe. |
| Esito | Vittoria o sconfitta, aggiornamento della run ed eventuali conseguenze. |

Il fantasma va fissato **prima delle opportunità di spionaggio** e non cambia dopo che il giocatore ha investito per ottenere informazioni su di esso — Confermato.

### 4.2 Scelte alternative — Confermato nella struttura

Le macrofasi non rappresentano un unico acquisto: contengono più occasioni nelle quali il giocatore sceglie che cosa fare, rinunciando alle alternative per quel momento. Mercanti, costruttori, studiosi, assemblee, ambasciate e reclutatori sono esempi di opportunità, non un catalogo definitivo.

La produzione di risorse avviene all’inizio delle **due macrofasi**, non a ogni opportunità interna.

**Da definire:** numero di momenti per fase, numero di alternative mostrate, contenuto dei negozi, costo degli incontri, frequenza degli eventi, possibilità di passare o aggiornare le offerte.

## 5. Economia

### 5.1 Doppia funzione degli edifici — Confermato

| Contesto | Funzione |
|---|---|
| Fuori dal combattimento | Produzione di risorse per la crescita della nazione. |
| Durante il combattimento | Produzione di mana per alimentare le truppe. |

La scelta di un edificio incide quindi su entrambi i momenti di gioco. Gli edifici persistono durante la run: non si ricostruisce l’economia da zero ogni anno. Il criterio con cui differenziare gli edifici è proposto in P3.

### 5.2 Produzione per fase — Confermato

All’inizio di Produzione e Preparazione, gli edifici presenti depositano automaticamente le rispettive risorse nel Magazzino, una volta per ingresso nella fase.

Un edificio costruito durante una fase non produce retroattivamente: inizia a produrre dalla fase successiva.

**Esempio senza valori:** una biblioteca costruita durante Produzione fornisce la prima Ricerca all’inizio della Preparazione dello stesso anno, e produce di nuovo all’inizio della Produzione dell’anno seguente.

### 5.3 Risorse della base

| Risorsa | Origine | Impiego |
|---|---|---|
| Oro | Edifici, fuori dal combattimento; potenziali opportunità future. | Acquisti e sviluppo. |
| Ricerca | Edifici dedicati, fuori dal combattimento. | Pagamento del passaggio di era. |
| Mana | Edifici, durante il combattimento. | Attivazione delle truppe. |

Oro e Ricerca sono conservati nel **Magazzino**: le risorse non spese restano disponibili fra fasi e anni, senza limite di capacità nella base iniziale.

Il mana è distinto dal Magazzino e non finanzia acquisti fuori battaglia.

**Proposta tecnica del prototipo:** mana iniziale pari a zero, nessun limite di accumulo durante lo scontro, azzeramento a fine battaglia.

Altre risorse, materiali e mantenimento non sono definiti. L’introduzione di una nuova risorsa è una modifica del nucleo (P5).

## 6. Plancia della nazione

### 6.1 Configurazione iniziale — Confermato

| Zona | Spazi iniziali | Massimo indicativo |
|---|---:|---:|
| Edifici | 4 | 10 |
| Truppe | 3 | 12 |

I valori iniziali sono confermati. I massimi sono un’indicazione del creatore sulla plancia di fine run (**Direzione**): verso la fine della partita la plancia deve essere piena di edifici e truppe.

La base usa due file separate. Un elemento occupa uno spazio. Gli spazi sono capacità disponibili, non elementi automaticamente posseduti.

Le truppe possono essere riordinate prima della battaglia; la loro posizione determina la priorità nell’uso del mana. Durante il combattimento la disposizione resta fissa.

### 6.2 Dotazione iniziale — Base approvata

- Prima era.
- Un edificio di base che produce Oro fuori dal combattimento e mana in battaglia.
- Una truppa di base con cooldown, senza richiesta di mana.
- Tre spazi edificio e due spazi truppa vuoti.
- Una dotazione di Oro per un primo acquisto.
- Nessuna Ricerca iniziale.

Quantità, nomi e statistiche sono placeholder. Eventuali varianti per popolo restano una proposta.

### 6.3 Espansione della plancia — Da definire

Il passaggio da 3 a fino a 12 spazi truppa rende l’espansione uno degli assi principali di progressione della run. Il meccanismo non è ancora fissato. Ipotesi indicate dal creatore:

- ricompense legate all’ingresso nelle ere;
- edifici che concedono spazi, ad esempio una caserma che aggiunge spazi truppa.

La seconda ipotesi ha una conseguenza da valutare: un edificio che concede spazi occupa a sua volta uno spazio edificio, quindi entra nella stessa scelta della doppia funzione.

### 6.4 Vendita e sostituzione — Da definire, priorità alta

Il principio P1 funziona solo se il giocatore, colpito da un malus, ha davvero alternative da perseguire. A plancia piena, “costruire altro” significa sostituire un elemento: le regole di vendita, sostituzione e rimborso determinano quindi quanto un malus devia o punisce. Vanno fissate prima di sviluppare i malus.

**Da definire anche:** riserva fuori plancia, copie multiple, fusioni e potenziamento degli elementi.

Una mappa a distretti con adiacenze era stata discussa come alternativa precedente: **non fa parte della plancia concordata.**

## 7. Combattimento automatico

La stessa simulazione regola gli scontri contro i fantasmi e, nella proposta attuale, quelli contro le plance generate degli incontri del mondo.

### 7.1 Obiettivo — Confermato

Ogni nazione possiede una **Resistenza**. Gli attacchi riducono la Resistenza avversaria; arrivare a zero significa perdere lo scontro.

Truppe ed edifici non hanno punti vita individuali e non vengono eliminati durante la battaglia nella base.

Resistenza e Prestigio sono separati: la prima riguarda il singolo scontro, il secondo la sopravvivenza della run. La Resistenza viene ripristinata prima dello scontro successivo.

### 7.2 Attivazione delle truppe — Confermato

Una truppa si attiva quando:

1. il suo cooldown è terminato;
2. è disponibile il mana richiesto.

All’attivazione consuma il mana, applica il proprio effetto e riavvia il cooldown. Se manca il mana, resta pronta in attesa.

Non esiste un attacco base universale indipendente dal mana. Possono esistere **truppe senza richiesta di mana**, regolate soltanto dal cooldown.

### 7.3 Priorità di utilizzo — Confermato

Le truppe pronte vengono valutate **da destra verso sinistra** sulla plancia del proprietario:

- la truppa più a destra viene considerata per prima;
- se può pagare, si attiva e riduce il mana disponibile per le successive;
- se non può pagare, viene saltata;
- il mana non viene prenotato per la truppa saltata;
- le truppe più a sinistra possono usare il mana residuo se sufficiente.

Una truppa economica può quindi ritardare una truppa costosa. Produzione, costi, cooldown e ordine della plancia formano insieme la strategia. Con plance fino a 12 truppe questo ordine diventa una fonte importante di profondità, e per la stessa ragione la sua leggibilità (P4) è un requisito.

Le truppe in attesa vengono verificate di nuovo quando il mana torna disponibile: la carenza di mana non impone un nuovo cooldown.

### 7.4 Produzione durante lo scontro

Gli edifici producono mana durante il combattimento in una **riserva condivisa** (base del primo prototipo). Ritmi individuali di produzione sono la soluzione operativa proposta; quantità e tempi restano configurabili.

**Da definire:** uno o più tipi di mana, vincoli di compatibilità, produzione iniziale, capienza e interazioni che alterano la riserva.

### 7.5 Tempistiche e casi limite — Da definire

- Cooldown inizialmente pieno oppure unità pronte a inizio battaglia.
- Ordine di risoluzione fra produzione, attacchi ed effetti simultanei.
- Risoluzione simultanea e doppio azzeramento della Resistenza (legato al pareggio, §3.4).
- Durata massima della battaglia e regola contro gli stalli.
- Pausa, velocità e possibilità di saltare la visualizzazione.

La simulazione non deve dipendere dalla velocità grafica del dispositivo, per ottenere scontri riproducibili (requisito tecnico proposto).

## 8. Linguaggio degli effetti e modificatori — Proposta

Questa sezione è il punto di innesto per i contenuti futuri: ogni nuovo elemento dovrebbe poter essere descritto con le voci seguenti (P5).

### 8.1 Due scale di tempo

| Scala | Unità | Esempi |
|---|---|---|
| Battaglia | Tempo di simulazione (secondi o tick) | Un effetto che ritarda una truppa avversaria per qualche secondo. |
| Run | Fasi e anni | Un malus che dimezza la produzione di Ricerca per un anno. |

### 8.2 Struttura di un modificatore

| Campo | Significato |
|---|---|
| Bersaglio | Che cosa viene modificato: Resistenza, riserva di mana, una truppa, un edificio, una risorsa del Magazzino, una produzione, gli spazi, le offerte. |
| Effetto | La variazione applicata. |
| Durata | Istantaneo, secondi di battaglia, numero di fasi o di anni. |
| Origine | Chi o che cosa lo ha generato (un evento, un incontro, una nazione avversaria). |
| Cumulabilità | Come si comporta con altri modificatori uguali. |

Il campo **Origine** esiste fin dalla base anche se non viene mostrato: permette in futuro di dare un nome ai malus inflitti dagli avversari (Parte III) senza modificare il nucleo.

### 8.3 Famiglie di effetti

I nomi tematici sono suggeriti dal creatore al posto dei termini generici del genere; restano provvisori.

| Famiglia | Nome tematico proposto | Funzione | Stato |
|---|---|---|---|
| Danno | — | Riduce la Resistenza avversaria. | Base |
| Erosione | **Corruzione** (al posto di Veleno) | Riduzione continua nel tempo. | Proposta |
| Rallentamento | **Inefficienza** (al posto di Rallentamento) | Allunga cooldown o ritmo di produzione; applicata a un edificio produttore di mana è particolarmente tematica. | Proposta |
| Disattivazione | **Sabotaggio** (al posto di Distruggi) | Impedisce o ritarda l’attivazione di un elemento, senza eliminarlo. | Proposta |
| Eliminazione | **Uccidi** | Rimuove un elemento dallo scontro. | Spunto: oggi gli elementi non vengono eliminati in battaglia (§7.1), quindi richiede una modifica del nucleo. |

Il rapporto fra Corruzione come erosione e Diplomazia come sistema di accordi o diserzioni resta una proposta (§13.3).

---

# PARTE II — SISTEMI

## 9. Identità della civiltà — Direzione

| Elemento | Ruolo previsto |
|---|---|
| Razza / popolo | Identità di base della civiltà. |
| Perk / tratti | Caratteristiche distintive e orientamento della strategia. |
| Governo | Organizzazione politica della nazione. |
| Credo religioso | Identità spirituale e rapporto con eventi o scelte. |
| Cultura | Identità sociale e sviluppo della civiltà. |

Queste dimensioni fanno parte della visione. Non sono ancora definiti catalogo, bonus, incompatibilità o numero di scelte iniziali.

L’identità dovrebbe influenzare opportunità, risposte agli eventi, strategie disponibili e, in futuro, abilità speciali (ad esempio i malus con nome, Parte III). Il modo in cui può cambiare durante la partita resta da progettare: riforme politiche, conversioni religiose e trasformazioni culturali sono possibilità, non regole.

**Proposta, non confermata:** partire con un’identità ridotta e far emergere cultura e credo attraverso gli eventi. Non sostituisce la scelta delle caratteristiche alla fondazione.

**Nota di portata:** cinque assi combinati moltiplicano il lavoro di contenuto e bilanciamento. È proposto di introdurli gradualmente, privilegiando assi che cambiano quali offerte e quali eventi compaiono, più che bonus percentuali.

## 10. Ricerca ed ere

### 10.1 Avanzamento asimmetrico — Confermato

Le ere dipendono dall’investimento in Ricerca, non da un calendario uguale per tutti: una civiltà può entrare in una nuova era prima di un’altra.

La **Ricerca si conserva e viene spesa** per avanzare quando il giocatore può pagare il costo. Il passaggio non avviene automaticamente al raggiungimento di una soglia.

### 10.2 Base di lavoro — Proposta

Tre ere iniziali, con nomi di lavoro “Fondazione”, “Sviluppo” e “Ascesa”.

Una nuova era sblocca offerte e possibilità di miglioramento. Gli elementi posseduti restano utilizzabili e non migliorano automaticamente: il vantaggio tecnologico richiede anche la capacità economica di acquistare ciò che viene sbloccato.

Le ere sono anche il veicolo proposto per P2a (effetti forti solo in ere avanzate) e una delle ipotesi per l’espansione della plancia (§6.3).

### 10.3 Questioni aperte

- Costo delle ere e andamento fra un’era e la successiva.
- Momento preciso in cui è possibile pagare l’avanzamento.
- Eventuale consumo di un’opportunità per avanzare.
- Tecnologie individuali, albero di ricerca o specializzazioni.
- Rapporto fra ricerca e identità della civiltà.
- Persistenza delle offerte delle ere precedenti.

Per la prima prova è prevista la sola progressione delle ere, senza albero tecnologico.

## 11. Fantasmi e asincronia

### 11.1 Principio — Confermato

L’avversario annuale è una copia registrata della nazione di un altro giocatore. Lo scontro modifica la run del giocatore attivo, non la partita del proprietario originale.

Un’arma del fantasma può lasciare una conseguenza nella run del giocatore attivo. Un sabotaggio del giocatore agisce sulla copia affrontata, non sulla nazione originale di una persona assente.

### 11.2 Selezione — Confermato

L’avversario viene fissato prima delle occasioni di spionaggio e rimane lo stesso fino allo scontro.

**Proposta:** abbinare nazioni dello stesso anno senza obbligare alla stessa era, così l’investimento tecnologico conserva valore. I criteri definitivi di matchmaking non sono approvati.

### 11.3 Popolamento iniziale — Confermato

La scarsità di avversari nei primi tempi non è considerata un problema: il creatore popolerà il gioco con fantasmi ricavati dalle proprie partite sulla versione definitiva. I playtest diventano così avversari utili.

Per il primo prototipo si usano avversari locali di prova (§16.3); non costituiscono multiplayer online.

### 11.4 Dati di una copia — Proposta tecnica

Anno, era, identità rilevante, Resistenza massima, edifici, truppe e loro ordine, modificatori attivi e versione delle regole. Se il combattimento introduce casualità, va gestito anche il seme casuale.

È proposto di salvare le **statistiche complete** degli elementi e non solo il loro identificativo: se in seguito un elemento viene ribilanciato, la copia continua a combattere com’era stata registrata.

**Da definire:** momento di pubblicazione della copia, backend, autenticazione, criteri di selezione, gestione delle versioni, controlli contro dati non validi.

## 12. Spionaggio e sabotaggio — Direzione

Ottenere informazioni sull’avversario prima dello scontro e poter intervenire su minacce specifiche. L’esempio iniziale: una statistica di spionaggio che permette di scoprire un oggetto bellico forte e sabotarlo, impedendone o ritardandone l’attivazione.

Lo spionaggio appartiene soprattutto alla Preparazione e usa il fantasma già selezionato. Raccogliere informazioni e sabotare sono azioni distinte; il loro rapporto resta da progettare. Il sabotaggio si esprime con la famiglia Disattivazione (§8.3).

**Da definire:** formula, probabilità, costi, durata, bersagli consentiti, contromisure. Ritardare un produttore di mana è un’interazione coerente con il sistema, non una regola approvata.

## 13. Eventi e conseguenze

### 13.1 Direzione centrale

Eventi e conseguenze dipendono dalle scelte fatte, dall’identità della nazione e dall’interazione con gli avversari. È parte della visione fondamentale, anche se non entra nel primo test del combattimento.

Origini possibili: sviluppo economico, ingresso in una nuova era, decisioni politiche, vittoria o sconfitta, incontri del mondo, armi particolari di un fantasma.

Gli incontri del mondo (§3.3) sono la prima forma concreta di evento: inizialmente scontri automatici, in futuro anche eventi a scelta.

### 13.2 Conseguenze persistenti

Un effetto avversario o un evento può lasciare un modificatore per uno o più anni. Le conseguenze seguono P1: cambiano il modo di giocare per un periodo, senza debilitare pesantemente.

Durata, intensità, cumulabilità, rimozione e rapporto con le opportunità annuali restano da definire. È stata proposta una gestione che offra una decisione (ricostruire, accettare un costo temporaneo, scegliere una risposta politica): direzione di design, non catalogo approvato.

### 13.3 Corruzione e diplomazia

Il creatore ha suggerito Corruzione o Diplomazia come reinterpretazioni tematiche di effetti simili al veleno. La distinzione fra corruzione come erosione e diplomazia come sistema di accordi o diserzioni è una proposta, non una decisione.

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
| Interfaccia (risorse, Prestigio, offerte) in 2D sovrapposta alla scena | Proposta |
| Animazioni dei pezzi come movimenti semplici via codice (spostamento, rotazione, scossa) per produzione, consumo di mana, attivazioni e danni | Proposta |
| Plancia a geometria semplice, con l’aspetto affidato ai materiali e alle texture | Proposta |
| Inquadratura quasi dall’alto, perché fino a 12 truppe in fila restino leggibili | Proposta |
| Stile visivo e materiali della plancia | Da definire |

Testi, numeri e indicatori restano elementi di interfaccia separati dalle illustrazioni.

### 14.3 Informazioni da rendere leggibili

| Contesto | Informazioni essenziali |
|---|---|
| Run | Anno, fase, era, vittorie, Prestigio, ultima possibilità. |
| Economia | Oro e Ricerca nel Magazzino; produzione prevista per fase. |
| Plancia | Elementi presenti, spazi liberi, ordine delle truppe. |
| Offerte | Costo, requisiti, effetto, disponibilità nell’era corrente. |
| Ricerca | Costo della prossima era e risorsa disponibile. |
| Modificatori | Effetti attivi, durata residua e, quando previsto, origine. |
| Battaglia | Resistenza delle due parti, mana, cooldown, unità in attesa e motivo dell’attesa. |
| Esito | Risultato, perdita di Prestigio, vittorie, conseguenze. |

**Piattaforma — Confermato:** PC. Una fila fino a 12 truppe e una fino a 10 edifici condizionano comunque inquadratura e layout.

---

# PARTE III — RISERVA DI SPUNTI

Idee annotate per il futuro. Non vanno implementate nella base; la base non deve però renderle impossibili.

| Spunto | Origine | Nota per l’introduzione |
|---|---|---|
| Truppa che elimina una truppa avversaria (Uccidi) | Creatore | Troppo forte all’inizio. Richiede regole su elementi eliminati, oggi assenti: è una modifica del nucleo. Candidata per ere avanzate (P2). |
| Malus che porta il nome della nazione che lo ha inflitto | Creatore | Non sempre presente: effetto speciale di certi perk o abilità legati a razza e identità. Usa il campo Origine (§8.2). |
| Eventi a scelta con testo e opzioni | Creatore | Seconda forma degli incontri del mondo, dopo gli scontri automatici. |
| Diplomazia come accordi o diserzioni | Creatore | Vedi §13.3. |
| Edificio che concede spazi (es. caserma per le truppe) | Creatore | Ipotesi per §6.3. |
| Ricompense di era che espandono la plancia | Creatore | Ipotesi per §6.3. |
| Identità emergente (cultura e credo dagli eventi) | Proposta precedente | Non confermata; vedi §9. |
| Nemesi: ritrovare più avanti una copia dello stesso giocatore che ci ha sconfitto | Proposta di Claude | Non discussa. Dà continuità narrativa agli avversari in un contesto asincrono. |
| Scudo, cura e riduzione del danno | Proposta precedente | Non confermati e non richiesti dalla prima simulazione. |
| Recupero del Prestigio | — | Nessuna regola prevista. |
| Progressione fra run | — | Non definita. |

---

# PARTE IV — PROTOTIPO E TECNICA

## 15. Primo prototipo

### 15.1 Obiettivo

Verificare un ciclo completo nel quale sviluppo economico, ordine delle truppe e produzione di mana producano scelte comprensibili. I valori devono poter cambiare rapidamente senza modificare le regole.

### 15.2 Funzioni da includere

- Nuova run con dotazione iniziale comune.
- Quattro spazi edificio e tre spazi truppa.
- Due macrofasi con raccolta automatica all’ingresso.
- Magazzino persistente e acquisti.
- Ricerca spendibile per avanzare di era.
- Riordino delle truppe prima dello scontro.
- Fantasma locale fissato per l’anno.
- Produzione di mana e attivazioni automatiche.
- Resistenza, esito e progressione della run.
- Incontri del mondo come scontri automatici contro plance generate, con conseguenze leggere in caso di sconfitta.
- Interfaccia di controllo leggibile, con il motivo dell’attesa delle truppe.
- Valori separati dal codice della simulazione.

### 15.3 Sistemi successivi

Proposta di ordine: vendita e sostituzione, espansione della plancia, modificatori pluriennali, opportunità alternative complete, identità della civiltà, eventi a scelta, spionaggio e sabotaggi, salvataggi, fantasmi online.

Rimandare un sistema non significa rimuoverlo dal gioco finale.

## 16. Organizzazione tecnica

### 16.1 Scelte operative

- Motore: Godot.
- Piattaforma di pubblicazione: PC.
- Linguaggio: GDScript, con tipi statici e sintassi di Godot 4 (niente sintassi di Godot 3) — Confermato.
- Il codice è scritto da Claude Code; editor esterno: Cursor collegato a Godot con l’estensione Godot Tools.
- Simulazione a tick fissi e con valori interi (mana, cooldown in millisecondi, Resistenza), per scontri identici su ogni macchina: Proposta tecnica.
- Sviluppo e test principali: altro PC del creatore.
- Collaborazione e modifiche: repository GitHub separato da Satze, `Bazelguese/Ultralopolis`.
- Non è necessario installare Godot su questo PC per preparare o modificare i sorgenti.

Questo documento non comporta caricamenti sul repository né modifiche della sua visibilità.

### 16.2 Architettura suggerita

| Componente | Responsabilità |
|---|---|
| Stato della run | Anno, fase, era, vittorie, Prestigio. |
| Economia | Magazzino, produzione, pagamenti. |
| Plancia | Elementi, spazi, ordine delle truppe. |
| Catalogo | Definizioni e valori configurabili di edifici, truppe e plance generate. |
| Modificatori | Effetti persistenti e temporanei, durata, origine, cumulabilità (§8). |
| Simulazione | Mana, cooldown, effetti, Resistenza, risultato; comune a fantasmi e incontri. |
| Fantasmi | Copie immutabili e selezione dell’avversario. |
| Incontri ed eventi | Condizioni, plance generate, scelte, conseguenze. |
| Interfaccia | Presentazione dello stato e input consentiti. |

La separazione fra simulazione e presentazione permette di verificare le regole anche quando la grafica cambia. Il componente Modificatori è il punto in cui si innestano malus, perk ed effetti futuri senza modificare la simulazione.

### 16.3 Convenzioni della bozza di codice, non approvate

| Convenzione | Stato |
|---|---|
| Due opportunità per macrofase | Placeholder per rendere navigabile il ciclo. |
| Acquisti da catalogo fisso | Semplificazione; non rappresenta le opportunità alternative finali. |
| Sostituzione senza rimborso | Temporanea; da rivedere con priorità (§6.4). |
| Avanzamento di era nelle due fasi, senza consumare opportunità | Temporanea. |
| Tre ere e relativo catalogo | Base di prova. |
| Tick di 100 ms e cooldown inizialmente pieni | Convenzione della simulazione. |
| Logoramento dopo 60 secondi | Misura temporanea contro gli stalli. |
| Pareggio senza vittorie né perdita di Prestigio | Provvisoria; il pareggio resta da definire. |
| Avversari locali determinati dall’anno | Sostituto del futuro servizio di fantasmi. |

Tutti gli esempi di carte e statistiche della bozza restano modificabili.

## 17. Verifica delle meccaniche

Criteri di accettazione proposti per il prototipo:

| Caso | Risultato atteso |
|---|---|
| Ingresso in una fase | Una sola raccolta dagli edifici già presenti. |
| Costruzione durante Produzione | Nessuna raccolta retroattiva; prima produzione in Preparazione. |
| Risorse non spese | Conservate al cambio fase e al cambio anno. |
| Passaggio di era | Ricerca pagata una volta; resto conservato; offerte coerenti con l’era. |
| Truppa pronta senza mana | In attesa, senza consumi né cooldown aggiuntivo; il motivo è visibile. |
| Più truppe pronte | Valutazione da destra a sinistra. |
| Prima truppa troppo costosa | Saltata; la successiva può usare il mana disponibile. |
| Truppa a costo zero | Si attiva senza mana al termine del cooldown. |
| Avvio di un nuovo combattimento | Resistenza ripristinata; mana secondo la convenzione scelta. |
| Sconfitta nell’anno N | Perdita di N Prestigio, salvo ultima possibilità già attiva. |
| Prima discesa a zero Prestigio | Run ancora attiva in ultima possibilità. |
| Ulteriore sconfitta | Fine della run. |
| Decima vittoria | Fine della run con successo. |
| Modificatore pluriennale (quando introdotto) | Applicato per la durata prevista e poi rimosso; esempio: Ricerca dimezzata per un anno. |
| Scontro contro plancia generata | Stessa simulazione e stesse regole dello scontro contro un fantasma. |
| Sconfitta contro un incontro del mondo | Conseguenza dello stesso tipo della sconfitta annuale, di entità inferiore; nessuna vittoria della run modificata. |
| Spionaggio (futuro) | Informazione relativa alla copia effettivamente affrontata. |

Domande di playtest: l’ordine delle truppe cambia davvero la strategia? Il motivo di una mancata attivazione è leggibile? Investire in Ricerca è un’alternativa credibile? Le due fasi offrono decisioni diverse? L’economia può riprendersi dopo una sconfitta? Un malus fa cambiare piano o si limita a pesare?

## 18. Decisioni ancora necessarie

| Priorità | Questione |
|---|---|
| Prima del test del ciclo | Cooldown iniziale, mana iniziale, risoluzione simultanea. |
| Prima del test del ciclo | Pareggi e prevenzione degli stalli. |
| Prima del test delle scelte | Numero di opportunità per fase e alternative presentate. |
| Prima dei malus pluriennali | Vendita, sostituzione e rimborso (§6.4). |
| Prima di sviluppare il catalogo | Riserva, duplicati, miglioramenti; criterio dei rapporti fra le due funzioni degli edifici (P3). |
| Prima del test del ciclo | Incontri del mondo: numero e posizione nell’anno, ricompense, entità della conseguenza leggera, comportamento durante l’ultima possibilità. |
| Prima di ampliare la plancia | Meccanismo di espansione degli spazi (§6.3); piattaforma e layout. |
| Prima di ampliare la ricerca | Numero e identità delle ere; momento e costo del passaggio. |
| Per la componente GDR | Identità iniziale, sue modifiche, eventi a scelta. |
| Per lo spionaggio | Informazioni visibili, costi, bersagli, effetti, contromisure. |
| Per l’online | Pubblicazione dei fantasmi, matchmaking, versionamento. |
| Più avanti | Progressione fra run, audio, monetizzazione, stile visivo. |

Non occorre risolvere tutto prima di provare la base. Le convenzioni indispensabili possono essere temporanee, purché dichiarate e facilmente modificabili.

## 19. Glossario

| Termine | Definizione |
|---|---|
| Nucleo | Insieme delle regole su cui si appoggiano tutti i contenuti; cambia solo con una nuova versione del documento. |
| Spunto | Idea per il futuro, annotata ma non introdotta nella base. |
| Run | Partita indipendente che racconta la storia di una civiltà. |
| Anno | Unità di progressione con due macrofasi, incontri del mondo e uno scontro finale contro un fantasma. |
| Produzione | Macrofase dedicata principalmente allo sviluppo della nazione. |
| Preparazione | Macrofase dedicata principalmente all’organizzazione per lo scontro. |
| Opportunità | Momento di scelta interno a una macrofase. |
| Incontro del mondo | Minaccia o evento dell’anno (es. barbari, pirati); inizialmente uno scontro contro una plancia generata. |
| Plancia generata | Plancia avversaria creata dal gioco per un incontro del mondo. |
| Magazzino | Riserva persistente di Oro e Ricerca. |
| Mana | Risorsa prodotta in battaglia e spesa per attivare le truppe. |
| Cooldown | Tempo di attesa fra due attivazioni. |
| Resistenza | Capacità della nazione di sopravvivere al singolo scontro. |
| Prestigio | Risorsa che determina la sopravvivenza della run dopo le sconfitte. |
| Fantasma | Copia di una nazione avversaria usata per uno scontro asincrono. |
| Era | Livello di sviluppo tecnologico raggiunto spendendo Ricerca. |
| Modificatore | Effetto con bersaglio, durata, origine e regole di cumulo. |
| Origine | Fonte di un modificatore; permette in futuro i malus con nome. |
| Conseguenza | Modifica dello stato della run che persiste dopo un evento o uno scontro. |

---

## Registro delle versioni

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
