# ULTRALOPOLIS — Bozza: mantenimento in risorse

**Data:** 6 novembre 2026
**Stato:** **bozza di discussione.** Non cambia né il GDD né il gioco. Le idee qui sono **Proposte** da scegliere.
**Riferimento:** `docs/Ultralopolis_GDD.md` v0.27, §5 Economia

**Modifica del nucleo.** Il mantenimento oggi esiste solo per il Cibo delle truppe (§5.4). Estenderlo ad altre risorse cambia l'economia della Parte I. Non serve una risorsa nuova; serve una **famiglia di effetti nuova** ("costo che si paga nel tempo") e una regola su che cosa succede se non si paga (principio P5).

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

## 6. Domande per Davide

1. **Metodo:** A, B, C, D, E, o una combinazione (proposta A + B)?
2. **Momento:** a ogni stagione, una volta all'anno, o prima degli scontri?
3. **Se non si paga:** trascurata, spenta, Malcontento, perde il livello, debito, o una combinazione?
4. **Ordine di pagamento:** come il Cibo (da destra) o lo sceglie il giocatore?
5. **Valori:** per ora placeholder piccoli (1 unità a stagione per livello o carta speciale), da tarare giocando?
