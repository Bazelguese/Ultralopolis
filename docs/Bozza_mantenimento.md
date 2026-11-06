# ULTRALOPOLIS — Bozza: mantenimento in risorse

**Data:** 6 novembre 2026
**Stato:** **approvata da Davide il 6 novembre 2026 e riportata nel GDD v0.28** (§5.6). Questo file resta come memoria della discussione.
**Riferimento:** `docs/Ultralopolis_GDD.md` v0.27, §5 Economia

**Modifica del nucleo.** Il mantenimento oggi esiste solo per il Cibo delle truppe (§5.4). Estenderlo ad altre risorse cambia l'economia della Parte I. Non serve una risorsa nuova; serve una **famiglia di effetti nuova** ("costo che si paga nel tempo") e una regola su che cosa succede se non si paga (principio P5).

---

## 0. Decisioni di Davide (6 novembre)

| Tema | Decisione | Stato |
|---|---|---|
| Metodo | **A + B**: pagano le carte potenziate (per livello) e le carte speciali | Confermato |
| Quando | **Prima di ogni scontro**: i due incontri del mondo e il fantasma | Confermato |
| Se non si paga | **Trascurata** (lavora peggio in quello scontro) **e Malcontento** | Confermato |
| Ordine di pagamento | **Da destra**, come il Cibo | Confermato |
| Valori | Placeholder piccoli, da tarare giocando | Confermato |

---

## 1. Perché ci pensiamo

- Con quattro produzioni all'anno le risorse si accumulano: nelle partite simulate si finisce con centinaia di Oro e decine di altre risorse. Oggi spenderle ha pochi sbocchi.
- Davide vorrebbe un modo "alla Stellaris": l'edificio base costa la risorsa comune, quello avanzato chiede anche un materiale raro. Le risorse diventano scelte, non solo punteggi.
- Il mantenimento dà un **prezzo nel tempo** alle carte forti: una carta potenziata o esclusiva vale di più, ma va nutrita. È un freno naturale a "comprare tutto".

---

## 2. Che cosa paga il mantenimento — cinque metodi

| Metodo | Come funziona | Pro | Contro |
|---|---|---|---|
| **A. Per livello** | Solo le carte potenziate pagano: livello 2 una piccola quota, livello 3 di più. La risorsa è quella della categoria che le ha potenziate (Ferro per il Generale, Fede per il Sacerdote…) | Si collega a Potenzia, che già usa le risorse di categoria. Le carte base restano libere | Potenziare diventa meno attraente: va tarato bene |
| **B. Carte speciali** | Pagano le carte segnate nei dati: esclusive di razza e governo, linee di elementi, carte dell'era 3. Ogni carta dice il suo mantenimento (es. "Colossi di pietra: 1 Pietra a stagione") | Il più vicino all'idea di Davide (materiale raro). Si decide carta per carta | Va scritto per ogni carta speciale; il catalogo cresce |
| **C. Per tipo** | Ogni tipo ha un costo tipico: Assedio Ferro e Legno, Spirituale Fede, Nobile Influenza, Criminale Documenti… Ogni carta paga quello dei suoi tipi | Tutto coerente, nessun caso speciale | Pesante: paga tutta la plancia. Tanti conti da seguire |
| **D. Oltre una soglia (logistica)** | Fino a N carte sulla plancia non si paga; ogni carta oltre la soglia costa una risorsa a stagione. La soglia sale con le ere | Frena l'espansione in modo semplice; si lega agli spazi | Non distingue fra carte forti e deboli |
| **E. Attivazione a scelta** | Il mantenimento non è obbligatorio: prima dello scontro il giocatore paga le carte speciali che vuole "attive"; quelle non pagate combattono come se fossero al livello 1, o senza il loro effetto speciale | Il giocatore decide; nessuna punizione nascosta | Un passaggio in più prima di ogni scontro |

**Proposta di Claude:** **A + B leggeri**. Pagano solo le carte potenziate (A) e le carte speciali (B), con quote piccole. Le carte base, che sono quasi tutta la plancia nei primi anni, restano gratuite.

---

## 3. Quando si paga

| Momento | Pro | Contro |
|---|---|---|
| **A ogni stagione**, subito dopo la produzione | Si vede subito: produzione e mantenimento nello stesso istante | Quattro pagamenti all'anno: più conti |
| **Una volta all'anno**, con il Cibo, a inizio inverno | Un solo momento, come il Cibo oggi | Il conto arriva tutto insieme; d'inverno si produce meno |
| **Prima di ogni scontro** (incontri e fantasma) | Si paga per combattere: logica militare | Gli edifici che non combattono restano fuori |

**Proposta:** a ogni stagione dopo la produzione. La barra delle risorse mostrerebbe "prossima stagione +5 / −2" con l'origine (come il tooltip della produzione di oggi).

---

## 4. Che cosa succede se non si paga

| Conseguenza | Effetto | Implicazioni |
|---|---|---|
| **1. Trascurata** | La carta lavora peggio fino al pagamento successivo: ricarica o intervallo ×1,5, come una truppa affamata | Regola già nota ai giocatori (Cibo). Una sola famiglia di effetti |
| **2. Spenta** | La carta non si attiva in battaglia finché non si paga | Molto punitiva; da evitare per le carte base |
| **3. Malcontento** | +1 Malcontento per ogni carta non pagata | Lega economia e politica. Rischio di rivoluzioni "per colpa del bilancio" |
| **4. Perde il livello** | Una carta potenziata non pagata torna giù di un livello | Chiaro ma severo: si perde un investimento |
| **5. Debito** | Il gioco converte da solo l'Oro nella risorsa mancante, a un tasso sfavorevole | Rende utile l'Oro accumulato. Va contro la regola "con l'Oro non si comprano risorse" (§5.3) |

**Proposta:** **1 (trascurata)** per tutte, ed eventualmente **3** solo per le carte di governo o di culto. L'ordine di pagamento è come per il Cibo: prima le carte più a destra, oppure lo sceglie il giocatore (Da definire).

---

## 5. Implicazioni sul resto del gioco

| Parte del gioco | Che cosa cambia |
|---|---|
| **Economia** (§5) | Le risorse accumulate trovano uno sbocco; i valori di produzione e i prezzi vanno ritarati insieme |
| **Potenzia** (§6.5) | Con il metodo A potenziare ha un costo nel tempo: diventa una scelta, non un automatismo |
| **Mercato** (§5.3) | Il mercato vende soltanto: se manca una risorsa per il mantenimento non la si compra. Restano la produzione, le azioni e gli eventi. Il metodo 5 (debito) cambierebbe questa regola |
| **Stagioni** (§3.2) | D'inverno niente Cibo; se il mantenimento chiede altre risorse anche d'inverno, l'inverno diventa più duro |
| **Identità** (§9) | Nuovi effetti possibili: una cultura che riduce il mantenimento (Artigiana), un governo che lo trasforma in Malcontento (Totalitarismo), una razza "frugale" |
| **Tecnologie** (§10.5) | Tecnologie che riducono il mantenimento di un tipo ("Logistica": Assedio −1 Ferro) |
| **Fantasmi** (§11) | I fantasmi sono registrazioni con le statistiche già salvate: non pagano mantenimento. Se una carta era trascurata al momento del salvataggio, il fantasma la ricorda trascurata (è nelle statistiche) |
| **Interfaccia** (P4) | Ogni carta che paga deve mostrare il suo mantenimento; le carte trascurate devono vedersi (fascia di stato, come "Senza cibo"); il tooltip delle risorse deve dire "−2: Colossi di pietra" |
| **Complessità** | È un sistema in più da leggere. Con A + B leggeri resta limitato alle carte che il giocatore ha scelto di rendere forti |

---

## 6. Domande ancora aperte (bozza 2)

1. **Quali sono le carte speciali?** Proposta: le esclusive (di razza, governo, credo, cultura e vie) e quelle delle linee di elementi. Le carte dell'era 3 normali no.
2. **Con che risorsa paga una carta potenziata?** Proposta: la risorsa della categoria del suo primo tipo (per esempio una truppa Fante paga Ferro, una Spirituale paga Fede). Ricordare chi l'ha potenziata, invece, chiede di salvarlo sulla carta.
3. **Il Malcontento:** +1 per ogni carta non pagata (proposta), oppure +1 per scontro se almeno una carta resta trascurata?
4. **"Trascurata":** proposta ricarica e intervallo ×1,5 in quello scontro, come una truppa affamata. Va bene?
5. **Le carte senza combattimento** (edifici che producono e basta) pagano anche loro prima degli scontri? Proposta: sì, tutte le carte sulla plancia.

## 6 bis. Domande della bozza 1, con le risposte

1. **Metodo:** A + B (Davide).
2. **Momento:** prima di ogni scontro (Davide).
3. **Se non si paga:** trascurata e Malcontento (Davide).
4. **Ordine di pagamento:** da destra (Davide).
5. **Valori:** placeholder piccoli, da tarare giocando (Davide).
