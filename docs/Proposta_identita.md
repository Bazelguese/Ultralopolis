# ULTRALOPOLIS — Proposta: identità della nazione

**Versione:** bozza 2 — 5 novembre 2026
**Riferimento:** Game Design Document v0.23 (`docs/Ultralopolis_GDD.md`), §9 Identità della civiltà
**Stato:** **approvata da Davide il 5 novembre 2026 e riportata nel GDD v0.24.** Nomi ed effetti sono **placeholder**; i valori numerici vengono ignorati di proposito. Le voci rimaste **Proposta** sono dettagli non discussi uno per uno: nel GDD compaiono come Proposta.

**Storia del documento.**
- La bozza 1 è nata in un'altra sessione, sul ramo `claude/exciting-wright-ax675q`, partendo dal GDD v0.21.
- La bozza 2 la riallinea alla v0.22 (tipi, categorie, Potenzia, quattro colori, nuove risorse) e alla v0.23 (Eventi, Visitatori e Fortune), e aggiunge le decisioni prese con Davide il 5 novembre: Malcontento e Stabilità, tipi d'identità.

Il GDD resta la fonte di verità. Questo documento non cambia il gioco: quando Davide lo approva, le decisioni vanno riportate nel GDD (vedi §1).

| Stato | Significato |
|---|---|
| **Deciso** | Scelto da Davide (nella bozza 1 o in questa discussione). Da riportare nel GDD. |
| **Proposta** | Idea di Claude, non ancora approvata. |
| **Da definire** | Nessuna regola ancora. |

---

## 0. Riepilogo delle decisioni

| Tema | Decisione | Stato |
|---|---|---|
| Popolo | **Razze fantasy originali**, con elementi esclusivi **in ogni era** | Deciso |
| Razze nel prototipo | **3 razze**, scelte da Claude (§3) | Deciso |
| Aspetto grafico delle razze sui pezzi | Rimandato | Da definire |
| Governo | **Molte forme di governo**, organizzate in **tier**: alcune non si scelgono alla creazione ma si raggiungono durante la run | Deciso |
| Cambio di governo | Due vie: **evoluzione** (solo in avanti) e **rivoluzione** (anche all'indietro) (§4.3) | Deciso |
| Tier e ere | Il tier del governo **non** è legato all'era (diverso dal livello del Consiglio, che segue l'era: GDD §4.2.1) | Deciso |
| Credo | Tipo di fede; **incanti comuni** per tutti più **1-2 incanti esclusivi** per credo | Deciso |
| Cultura | Modo di **usare le risorse** e di **influenzare i consiglieri** | Deciso |
| Eventi | Tutte le dimensioni (dal popolo alla cultura) contribuiscono a determinare gli eventi | Deciso |
| Incompatibilità fra elementi | **Nessuna per ora**; obiettivo futuro: **sinergie e tensioni** | Deciso |
| Creazione | Resta **a colonne**: un elemento per dimensione più i perk | Deciso |
| Malcontento | Nuovo contatore che porta alla rivoluzione (§7) | Deciso — **modifica del nucleo** |
| Malcontento e Stabilità | Il Malcontento è una **pressione** che sale da sola; la **Stabilità** (risorsa dello Stato, v0.22) è ciò che si **spende** per farlo scendere | Deciso (5 novembre) |
| Tipi d'identità | Le "etichette" della bozza 1 diventano **tipi d'identità**, uniti alla proposta di Claude sui tipi legati alla nazione (§8) | Deciso (5 novembre) |

---

## 1. Che cosa cambierebbe nel GDD

| # | Punto del GDD (v0.23) | Oggi | Con questa proposta |
|---|---|---|---|
| A | **Nucleo: §5.3 e P5** | Non esiste un contatore di malcontento | Nuova risorsa della nazione: il **Malcontento** (§7). **Modifica del nucleo**, confermata da Davide. |
| B | **§4.2.5, eventi forzati** | Nessun evento arriva da solo (gli eventi forzati sono uno spunto) | La **Rivoluzione** è la **prima eccezione**: arriva da sola (§4.3). Deciso. |
| C | **§4.2.5, effetti delle opzioni** | Risorse, carte, livelli, spazi, modificatori, spionaggio | Si aggiungono: **cambiare governo** e **far salire o scendere il Malcontento**. Toccano l'identità e la nuova risorsa, non la battaglia. |
| D | **§6.6 e §4.2.4, tipi** | I tipi di una carta stanno nelle categorie (salvo Capitale) | Nascono i **tipi d'identità**, fuori dalle categorie (§8). |
| E | **§9.1** | "Il giocatore vede **tutte** le opzioni e sceglie…" | "Tutte le opzioni **di partenza**". I governi dei tier più alti non si scelgono alla creazione; la schermata può mostrarli bloccati (Proposta). |
| F | **§9.1** | Popolo, governo, credo e cultura restano fissi | Il **governo** cambia durante la run (§4.3); popolo, credo e cultura restano fissi per ora. |
| G | **§9.2, scheda dell'identità** | Resistenza, dotazione, consiglieri e proposte favoriti, elementi esclusivi, tratto permanente | Nuovi effetti sul **Consiglio** (§4.2) e sulle **risorse** (§6). Il §9.2 lo prevede ("altri effetti verranno aggiunti"). |
| H | **§9.3, incompatibilità** | Da definire | Nessuna incompatibilità; sinergie e tensioni diventano una **Direzione**. |
| I | **§9.3, catalogo** | 3 popoli, 3 governi, 3 credi, 3 culture | Nuovo catalogo placeholder (§3–§6). L'**Ordine della Ragione** esce dai credi (§5.3). |
| J | **§13.1** | Origini possibili degli eventi | Si aggiungono il **Malcontento** e i **tipi d'identità**. |

---

## 2. Che cosa fa ogni dimensione

Ogni dimensione agisce su una parte diversa del gioco, così scegliere un governo o un credo "sa" davvero di governo o di credo. Tutte usano la stessa scheda del §9.2 del GDD.

| Dimensione | Che cos'è | Su che cosa agisce | Stato |
|---|---|---|---|
| **Popolo** | Una razza fantasy | **Chi sei sulla plancia**: Resistenza, esclusivi in ogni era, un tratto della razza, il suo tipo d'identità | Deciso |
| **Governo** | Una forma di governo, a tier | **Come decidi**: quali consiglieri compaiono, quanti, quante proposte, quanto costano | Deciso nella logica; effetti Proposta |
| **Credo** | Un tipo di fede | **Gli incanti** del Sacerdote (GDD §4.3) e la Fede | Deciso |
| **Cultura** | Un modo di vivere | **Come usi le risorse** e come influenzi i consiglieri | Deciso |
| **Perk** | Abilità passive | Bonus mirati, soprattutto in battaglia | Invariato |

Ogni elemento dà anche, come oggi, **una risorsa alla Capitale** (GDD §6.2, v0.22) e un peso agli **eventi** che lo hanno come radice (§4.2.5).

---

## 3. Popolo: le razze

### 3.1 Le tre razze del prototipo

| Razza (placeholder) | Chi sono | Stile di gioco | Sostituisce | Risorsa della Capitale (Proposta) |
|---|---|---|---|---|
| **Pietrosangue** | Popolo di roccia viva delle montagne, lento a cedere | **Difesa**: Resistenza alta, truppe che fanno scudo | Montanari | Pietra |
| **Maremani** | Anfibi delle lagune, barcaioli e commercianti | **Economia**: Oro e Cibo, edifici Economici | Popolo del delta | Influenza |
| **Cinerali** | Popolo alato delle scogliere vulcaniche | **Attacco rapido**: truppe veloci a distanza | Popolo delle foreste | Ferro |

**Perché queste tre:**

1. **Tre strategie diverse fra loro** (difendersi, arricchirsi, colpire per primi). Così si vede subito se la razza cambia davvero il modo di giocare (principio P3).
2. **Riusano gli esclusivi che esistono già** per l'era 1. Mancano quelli delle ere 2 e 3: 6 elementi nuovi.
3. Idee scartate per ora: un popolo-fungo delle paludi (la Corruzione si addice di più al Culto del vuoto, §5) e un popolo di cristallo legato al mana (si sovrapporrebbe a Mulini e Spiriti dei luoghi).

Con la v0.22 i Tiratori non sono più un tipo: per i Cinerali "a distanza" è un tema, non una regola. Le loro truppe saranno **Fante** e **Cinerale** (§8).

### 3.2 Esclusivi in ogni era

Come per le vie (GDD §10.4), gli esclusivi di una razza sono **diversi per ogni era**, e quelli di un'era passata escono dalle offerte. Le idee per le ere 2 e 3 vanno costruite con la regola di budget del Catalogo (era +1 punto). Ogni esclusivo ha almeno un **tipo di categoria**, così un consigliere lo propone e lo potenzia, più il **tipo della razza** (§8).

| Razza | Era 1 (esiste già) | Era 2 (idea) | Era 3 (idea) |
|---|---|---|---|
| Pietrosangue | Guardie delle vette (Guardiano, Patriota → + Pietrosangue) | Un edificio Guardiano che produce scudo | Una truppa d'Assedio pesante e lenta |
| Maremani | Porto fluviale (Economico, Infrastruttura Strategica → + Maremano) | Una truppa Spirituale che cura | Un edificio di Produzione ed Economico che produce Oro e Cibo |
| Cinerali | Arcieri dei boschi (Guardiano → Fante + Cinerale) | Una truppa veloce che rallenta il nemico (Inefficienza) | Una truppa Fante molto veloce |

Gli esclusivi esistenti vanno rinominati per la nuova razza (es. "Arcieri delle ceneri" per i Cinerali).

### 3.3 Che cosa si sposta dai vecchi popoli — Deciso

| Oggi è legato a | Passa a |
|---|---|
| Montanari: evento *Il passo innevato*, fortuna *Una vena d'argento* | Pietrosangue |
| Popolo del delta: evento *La piena del fiume*, fortuna *Raccolto abbondante*, visitatore *Mercanti del delta* | Maremani (il visitatore diventa *Mercanti delle lagune*) |
| Popolo delle foreste: evento *Il cervo bianco* | Cinerali, con un evento nuovo al posto del cervo (es. *La montagna si sveglia*: un vulcano che erutta) |

### 3.4 Da definire

- Il tratto permanente di ogni razza.
- Se e come la razza si vede sui pezzi: rimandato da Davide.

---

## 4. Governo: forme a tier

### 4.1 L'albero dei governi (placeholder)

Si parte da un governo del **tier 1**. Le frecce indicano dove può evolvere. Un governo può essere raggiunto da più rami (es. il Totalitarismo).

```
TIER 1 (alla creazione)    TIER 2                         TIER 3
Monarchia          ──►  Monarchia assoluta        ──►  Totalitarismo
                   └─►  Monarchia costituzionale  ──►  Repubblica parlamentare
Repubblica         ──►  Oligarchia                ──►  Plutocrazia
                   └─►  Dittatura                 ──►  Totalitarismo
Teocrazia          ──►  Ierocrazia                ──►  (da definire)
```

Numero di tier, nomi e rami sono placeholder.

### 4.2 Che cosa fa ogni governo — Deciso come punto di partenza, valori placeholder

Il governo cambia **come si usa il Consiglio** (GDD §4.2). Un tier più alto spinge più in là la stessa idea del suo ramo.

| Governo | Tier | Idea, nel Consiglio della v0.23 |
|---|---|---|
| Monarchia | 1 | Un **consigliere di corte**, scelto alla creazione, compare più spesso (+2 di peso). |
| Monarchia assoluta | 2 | Il consigliere di corte compare **sempre** fra i 3. |
| Monarchia costituzionale | 2 | Il Cancelliere compare più spesso; l'Ambasciata costa meno Stabilità. |
| Repubblica | 1 | Compaiono **4 consiglieri** invece di 3, ma le proposte costano 1 Oro in più. |
| Oligarchia | 2 | Tesoriere e Cancelliere favoriti; i Visitatori compaiono più spesso. |
| Plutocrazia | 3 | Idea da sviluppare (estremizza l'Oligarchia). |
| Dittatura | 2 | Compaiono **2 consiglieri**, ma quello scelto offre **una proposta in più**. |
| Totalitarismo | 3 | Come la Dittatura, più: Maestro delle spie favorito, spionaggi più lunghi, il Clown non compare mai. |
| Repubblica parlamentare | 3 | Idea da sviluppare. |
| Teocrazia | 1 | Il **Sacerdote** è sempre fra i consiglieri. |
| Ierocrazia | 2 | Gli incanti costano 1 Fede in meno. |

Effetti nuovi da aggiungere alla scheda dell'identità (§9.2): consiglieri in più o in meno nel round, un consigliere sempre presente, un consigliere escluso, Oro in più o in meno sulle proposte. "Una proposta in più" esiste già (lo usa il Censimento).

Ogni governo continua a dare una quota di Resistenza (GDD §7.1.1) e una risorsa alla Capitale (es. Monarchia → Stabilità, Repubblica → Influenza, come oggi).

### 4.3 Come cambia il governo

**Evoluzione — Deciso**

| Regola | Stato |
|---|---|
| Va **solo in avanti**, al tier successivo, scegliendo fra i rami possibili | Deciso |
| Si può evolvere **entrando in una nuova era**: l'evoluzione viene **proposta** e il giocatore può rifiutarla | Deciso |
| Si può evolvere anche con una **Riforma**: un **evento** pagato con **Influenza** | Deciso |
| Il tier non dipende dall'era: con una Riforma si può salire anche restando nella stessa era | Deciso |

**La Riforma come evento della v0.23 — Proposta.** È un Evento (§4.2.5) di sfera Stato, con radice "governo di tier 1 o 2". Ha un'opzione per ogni ramo possibile, che costa Influenza e cambia governo. Le opzioni dei rami possono avere requisiti: per esempio la Monarchia assoluta richiede una carta Nobile. Ha anche un'opzione "Rimanda" gratuita, perché ogni evento ne deve avere una senza requisiti. Come tutti gli eventi compare al massimo una volta per run, salvo che lo segniamo ripetibile: Proposta, ripetibile, perché si può riformare più volte.

**Rivoluzione — Deciso**

| Regola | Stato |
|---|---|
| È un cambio **voluto dal popolo**, causato dall'accumulo di **Malcontento** (§7) | Deciso |
| Può portare a qualsiasi governo, **anche di un tier più basso** | Deciso |
| **Scelta mista**: la **causa** del Malcontento decide quali governi sono possibili; il **giocatore** sceglie fra quelli | Deciso |
| Dopo la rivoluzione il Malcontento **si azzera** | Deciso |
| La causa è la fonte che ha prodotto più Malcontento (es. molte sconfitte: governi militari; carestie: governi popolari) | Proposta |
| È un Evento della v0.23: un'opzione per ogni governo possibile, tutte gratuite. È la **prima eccezione** alla regola “nessun evento arriva da solo”: raggiunta la soglia, il round successivo mostra solo la Rivoluzione | Deciso |

**Che cosa succede al vecchio governo — Proposta**

- Il **tratto permanente** del vecchio governo finisce e vale quello nuovo; cambia anche la **risorsa della Capitale** del governo.
- Gli elementi già sulla plancia **restano**, come con le ere. Gli esclusivi del vecchio governo non vengono più offerti, ma il loro **tipo d'identità** resta sulle carte (§8).
- Il cambio resta scritto nella **storia della nazione**.

**Da definire:** se all'ingresso in un'era l'evoluzione viene proposta prima o dopo la via; il costo della Riforma; quale governo hanno i fantasmi generati e se evolvono.

---

## 5. Credo: tipi di fede

### 5.1 Regola degli incanti — Deciso

- Gli **incanti comuni** restano per tutti: Furia (danno), Egida (scudo), Grazia (cura), Maledizione (Corruzione), Torpore (Inefficienza). La bozza 1 li chiamava Fuoco, Guardia, Vita, Ombra, Gelo.
- Ogni credo aggiunge **1-2 incanti esclusivi**, offerti dal Sacerdote e dai Pellegrini solo a quella nazione. Sono azioni esclusive dell'identità, come Processione e Tributi feudali.
- Gli incanti esclusivi usano solo le **famiglie di effetti esistenti**: non toccano il nucleo. Proposta: un incanto esclusivo può aggiungere **due effetti** insieme, cosa che quelli comuni non fanno.

### 5.2 Credi del prototipo (placeholder)

| Credo | Che fede è | Incanto esclusivo (idea) | Sostituisce | Risorsa della Capitale (Proposta) |
|---|---|---|---|---|
| **Culto solare** | Adorazione del sole e della luce | Danno + Cura insieme | Culto del Sole | Fede |
| **Spiriti dei luoghi** | Animismo: ogni bosco e fiume ha uno spirito | Cura che rallenta i nemici (Inefficienza) | Antichi spiriti | Legno |
| **Culto degli antenati** | Venerazione dei padri fondatori | Scudo più forte sulle truppe senza mana | — | Stabilità |
| **Culto del vuoto** | Fede oscura nel nulla | Corruzione + Sabotaggio | — | Documenti |

### 5.3 Dove va l'Ordine della Ragione — Deciso

Non è una fede: esce dai credi, e la sua idea (il sapere) passa alla **Cultura erudita**. Oggi compare in dieci file dei dati (compreso il suo):

| Oggi | Passa a |
|---|---|
| Risorsa della Capitale (Ricerca) | Cultura erudita (che oggi dà Documenti) passa a Ricerca; i Documenti vanno al Culto del vuoto |
| Eventi *La disputa dei dotti*, *La biblioteca ritrovata*; visitatori *Inventore errante*, *Pellegrini* | Cultura erudita; i Pellegrini restano favoriti dai credi |
| Vie del Sapere e dell'Ombra (favorite dall'Ordine) | Cultura erudita e Culto del vuoto |
| Fantasma dell'anno 3 | Culto degli antenati |

---

## 6. Cultura: come si usano le risorse

| Cultura (placeholder) | Idea | Stato |
|---|---|---|
| **Mercantile** | Tasso migliore al mercato delle risorse | Deciso come punto di partenza |
| **Guerriera** | Le azioni del Generale costano meno Ferro | Deciso come punto di partenza |
| **Erudita** | Le azioni dello Studioso costano meno o rendono di più (eredita l'Ordine della Ragione) | Deciso come punto di partenza |
| **Artigiana** | **Potenzia costa meno** (1 unità in meno per livello): con la v0.22 si potenzia solo con i consiglieri | Deciso come punto di partenza |

Servono effetti nuovi della scheda dell'identità, tutti fuori dalla battaglia: tasso del mercato, costo delle azioni di un consigliere, costo di Potenzia.

---

## 7. Malcontento e Stabilità — modifica del nucleo

Il Malcontento è un **nuovo contatore della nazione**. Per il principio P5 è una nuova risorsa, quindi una modifica del nucleo: **Davide l'ha confermato**.

Ha un rapporto preciso con la **Stabilità**, deciso il 5 novembre: due facce dello stesso tema, non due doppioni.
- Il **Malcontento** è una **pressione** che sale da sola, per quello che succede alla nazione.
- La **Stabilità** è la **risorsa che si spende** per farlo scendere.

| Regola | Stato |
|---|---|
| Sale con: **sconfitte**, **carestie** (Cibo insufficiente), **malus subiti**, alcune **opzioni degli eventi** | Deciso (le opzioni degli eventi: Proposta, v0.23) |
| Scende soprattutto **spendendo Stabilità**: un'azione del **Cancelliere** (es. *Ordine pubblico*: Stabilità → −Malcontento) | Deciso nella forma (5 novembre); azione Proposta |
| Scende anche con **Fede** (un'azione del Sacerdote) e con **Cibo** (un'azione del Fattore), e con alcune opzioni degli eventi | Deciso (bozza 1); azioni Proposta |
| Raggiunta una **soglia**, scatta la **Rivoluzione** (§4.3) | Deciso |
| Dopo la rivoluzione si **azzera** | Deciso |
| È **sempre visibile** nella barra delle risorse, con la soglia, e il gioco avverte quando la rivoluzione si avvicina (come P4 per la battaglia) | Proposta |
| Vive **fuori dalla battaglia**: non entra nella simulazione e non cambia la Resistenza | Proposta |
| Non si vende al mercato e non si accumula come scorta: è un contatore, non un bene | Proposta |
| Si conserva da un anno all'altro | Proposta |
| Gli eventi possono avere come radice "Malcontento sopra una soglia" (es. *Tumulti in piazza*) | Proposta |

**Da definire:** valori (quanto sale per ogni causa, quanto vale 1 Stabilità, la soglia); se l'identità lo fa salire più o meno in fretta.

---

## 8. Tipi d'identità — unione della bozza 1 e della proposta di Claude

La bozza 1 proponeva **etichette** per gli elementi dell'identità (es. "marittimo", "devoto"), da leggere negli eventi. Claude proponeva **tipi** sulle carte esclusive dell'identità. Davide ha deciso di unirle: diventano i **tipi d'identità**.

| Regola | Stato |
|---|---|
| Ogni elemento dell'identità (razza, governo, credo, cultura) ha un **suo tipo**, es. Pietrosangue, Monarchico, Solare, Mercantile | Deciso |
| I tipi d'identità **non stanno in nessuna categoria** (come il tipo Capitale): non decidono quali consiglieri propongono o potenziano una carta | Deciso |
| Le carte esclusive di un elemento portano il suo tipo, **più almeno un tipo di categoria**, altrimenti nessun consigliere le proporrebbe | Deciso |
| Limite: 1-2 tipi di categoria più al massimo 1 tipo d'identità, quindi **3 tipi** al massimo | Deciso |
| Servono a: perk e tratti ("le carte Pietrosangue producono 1 scudo in più"), radici e requisiti degli eventi (un'opzione **[Monarchico]**), sinergie e tensioni future | Deciso |
| Una carta esclusiva di un'altra nazione (comprata dal Contrabbandiere o dai Mercanti) porta in casa il suo **tipo straniero**, che può sbloccare eventi e opzioni di quella nazione | Deciso (conseguenza) |
| Se cambia il governo, le carte del vecchio governo **tengono** il loro tipo | Deciso |
| Anche le **vie** hanno un tipo d'identità sui loro esclusivi | Da definire |
| Esclusivi per governi, credi e culture: oggi solo i popoli hanno carte esclusive. Proposta: **una carta esclusiva per ciascuno** (9 carte nuove), oltre agli incanti esclusivi dei credi | Deciso |

---

## 9. Ordine di lavoro suggerito

Ogni passo funziona da solo e si può provare in Godot prima del successivo.

| Passo | Contenuto | Tocca il nucleo? |
|---|---|---|
| 1 | Nuovo catalogo: 3 razze, 4 credi, 4 culture, governi del tier 1; spostamento di eventi, fortune, visitatori e Capitale (§3.3, §5.3) | No |
| 2 | Tipi d'identità sulle carte esclusive e nelle radici degli eventi (§8) | No (estende §6.6) |
| 3 | Effetti del governo e della cultura sul Consiglio e sulle risorse (§4.2, §6) | No (estende §9.2) |
| 4 | Incanti esclusivi dei credi | No |
| 5 | Governi a tier: evoluzione proposta all'ingresso in un'era e Riforma come evento | No (estende le opzioni degli eventi) |
| 6 | Esclusivi delle razze per le ere 2 e 3, esclusivi di governi, credi e culture | No |
| 7 | Malcontento, azioni che lo fanno scendere, Rivoluzione | **Sì** (nuova risorsa) |

---

## 10. Risposte di Davide (5 novembre 2026)

1. **La Rivoluzione arriva da sola:** sì, è la prima eccezione alla regola della v0.23.
2. **Tipi d'identità:** sì, un tipo per elemento, al massimo 3 tipi per carta, 9 carte esclusive nuove per governi, credi e culture.
3. **Ordine della Ragione e vecchi popoli:** sì, ridistribuiti come in §3.3 e §5.3.
4. **Effetti di governi e culture:** sì, come punto di partenza.
