# ULTRALOPOLIS — Proposta: identità della nazione

**Versione:** bozza 1 — 5 novembre 2026
**Riferimento:** Game Design Document v0.21 (`docs/Ultralopolis_GDD.md`), §9 Identità della civiltà
**Stato:** **proposta, non approvata nel GDD.** Raccoglie le decisioni prese con Davide e le idee ancora da approvare. Nomi ed effetti sono **placeholder**; i valori numerici vengono ignorati di proposito.

Il GDD resta la fonte di verità. Questo documento non cambia il gioco: quando Davide lo approva, le decisioni vanno riportate nel GDD (vedi §1).

Ogni voce ha uno stato:

| Stato | Significato |
|---|---|
| **Deciso** | Scelto da Davide in questa discussione. Da riportare nel GDD. |
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
| Tier e ere | Il tier **non** è legato all'era | Deciso |
| Credo | Tipo di fede; **incanti comuni** per tutti più **1-2 incanti esclusivi** per credo | Deciso |
| Cultura | Modo di **usare le risorse** e di **influenzare i consiglieri** | Deciso |
| Eventi | Tutte le dimensioni (dal popolo alla cultura) contribuiscono a determinare gli eventi | Deciso |
| Incompatibilità fra elementi | **Nessuna per ora**; obiettivo futuro: **sinergie e tensioni** | Deciso |
| Creazione | Resta **a colonne**: un elemento per dimensione più i perk | Deciso |
| Malcontento | Nuovo contatore che porta alla rivoluzione (§7) | Deciso — **modifica del nucleo** |

---

## 1. Che cosa cambierebbe nel GDD

Queste decisioni toccano regole già scritte. Vanno approvate esplicitamente prima di aggiornare il GDD.

| # | Punto del GDD | Oggi | Con questa proposta |
|---|---|---|---|
| A | **Nucleo, P5** | Non esiste un contatore di malcontento | Nuova risorsa: il **Malcontento** (§7). È una **modifica del nucleo**, confermata da Davide. |
| B | **Parte III, Spunti** | "Eventi a scelta con testo e opzioni" è uno spunto | Gli eventi a scelta **entrano nel progetto**: servono per la Riforma e la Rivoluzione (§4.3). Confermato da Davide. |
| C | **§9.1** | "Il giocatore vede **tutte** le opzioni e sceglie…" | Diventa "tutte le opzioni **di partenza**". I governi dei tier più alti non si scelgono alla creazione. La schermata può mostrarli bloccati, per far vedere dove si può arrivare (Proposta). |
| D | **§9.1** | "Popolo, governo, credo e cultura restano fissi durante la run" (Direzione per il cambiamento) | Il **governo** cambia durante la run (§4.3). Popolo, credo e cultura restano fissi per ora. |
| E | **§9.3** | Incompatibilità "Da definire" | Nessuna incompatibilità; sinergie e tensioni diventano una **Direzione**. |
| F | **§9.3, catalogo** | 3 popoli, 3 governi, 3 credi, 3 culture | Nuovo catalogo placeholder di questo documento. L'**Ordine della Ragione** esce dai credi (§5). |
| G | **§13.1** | Origini possibili degli eventi | Si aggiungono il **Malcontento** e l'identità (etichette, §8). |

---

## 2. Che cosa fa ogni dimensione

Ogni dimensione agisce su una parte diversa del gioco, così scegliere un governo o un credo "sa" davvero di governo o di credo. Tutte usano la stessa scheda del §9.2 del GDD.

| Dimensione | Che cos'è | Su che cosa agisce | Stato |
|---|---|---|---|
| **Popolo** | Una razza fantasy | **Chi sei sulla plancia**: Resistenza, truppe ed edifici esclusivi in ogni era, un tratto della razza | Deciso |
| **Governo** | Una forma di governo, a tier | **Come decidi**: quali consiglieri compaiono, quante proposte, quanto costano | Deciso nella logica; effetti Proposta |
| **Credo** | Un tipo di fede | **Gli incanti** del Sacerdote (GDD §4.3) e la Fede | Deciso |
| **Cultura** | Un modo di vivere | **Come usi le risorse** e come influenzi i consiglieri | Deciso |
| **Perk** | Abilità passive | Bonus mirati, soprattutto in battaglia | Invariato |

Gli effetti del governo sul Consiglio (un consigliere in più o in meno, una proposta in più, un consigliere sempre presente) richiedono **nuovi tipi di effetto** nella scheda dell'identità. Il §9.2 del GDD lo prevede ("altri effetti verranno aggiunti"). Non sono una nuova risorsa né una nuova famiglia di effetti di battaglia, quindi **non** toccano il nucleo.

---

## 3. Popolo: le razze

### 3.1 Le tre razze del prototipo

| Razza (placeholder) | Chi sono | Stile di gioco | Sostituisce |
|---|---|---|---|
| **Pietrosangue** | Popolo di roccia viva delle montagne, lento a cedere | **Difesa**: Resistenza alta, truppe che fanno scudo | Montanari |
| **Maremani** | Anfibi delle lagune, barcaioli e commercianti | **Economia**: Oro e Cibo, edifici Commerciali | Popolo del delta |
| **Cinerali** | Popolo alato delle scogliere vulcaniche | **Attacco rapido**: truppe veloci e Tiratori | Popolo delle foreste |

**Perché queste tre:**

1. **Tre strategie diverse fra loro** (difendersi, arricchirsi, colpire per primi). Così si vede subito se la razza cambia davvero il modo di giocare (principio P3).
2. **Riusano gli esclusivi che esistono già** per l'era 1. Mancano solo quelli delle ere 2 e 3: 6 elementi nuovi in tutto.
3. Altre idee scartate per ora: un popolo-fungo delle paludi (la Corruzione si addice di più al Culto del vuoto, §5) e un popolo di cristallo legato al mana (si sovrapporrebbe a Mulini e Spiriti dei luoghi).

### 3.2 Esclusivi in ogni era

Come per le vie (GDD §10.4), gli esclusivi di una razza sono **diversi per ogni era**, e quelli di un'era passata escono dalle offerte. Le idee per le ere 2 e 3 sono solo indicative e vanno costruite con la regola di budget del Catalogo (era +1 punto).

| Razza | Era 1 (esiste già) | Era 2 (idea) | Era 3 (idea) |
|---|---|---|---|
| Pietrosangue | Guardie delle vette (truppa, Fanteria, senza mana) | Un edificio Difensivo che produce scudo | Una truppa d'Assedio pesante e lenta |
| Maremani | Porto fluviale (edificio, Commerciale) | Una truppa che cura | Un edificio che produce Oro e Cibo insieme |
| Cinerali | Arcieri dei boschi (truppa, Tiratori, rapida) | Una truppa rapida che rallenta il nemico (Inefficienza) | Una truppa di Tiratori molto veloce |

Gli esclusivi esistenti vanno rinominati per la nuova razza (es. le "Guardie delle vette" dei Pietrosangue).

### 3.3 Da definire

- Il tratto permanente di ogni razza.
- Se e come la razza si vede sui pezzi (illustrazioni diverse per razza): rimandato da Davide.

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

Il numero di tier, i nomi e i rami sono placeholder. In futuro si possono aggiungere altri governi di tier 1 (es. un Consiglio tribale).

### 4.2 Che cosa fa ogni governo (Proposta)

La logica è la stessa per tutti: il governo cambia **come si usa il Consiglio**. Un tier più alto spinge più in là la stessa idea del suo ramo.

| Governo | Tier | Idea |
|---|---|---|
| Monarchia | 1 | Un **consigliere di corte**, scelto alla creazione, compare più spesso. |
| Monarchia assoluta | 2 | Il consigliere di corte compare **sempre**. |
| Monarchia costituzionale | 2 | Idea da sviluppare. |
| Repubblica | 1 | Si ascolta **un consigliere in più**, ma le sue proposte costano di più. |
| Oligarchia | 2 | Tesoriere e Diplomatico favoriti; le azioni pagate in Oro costano meno. |
| Plutocrazia | 3 | Idea da sviluppare (estremizza l'Oligarchia). |
| Dittatura | 2 | Si vede **un consigliere in meno**, ma quello scelto offre **una proposta in più**. |
| Totalitarismo | 3 | Come la Dittatura, più: Maestro delle spie favorito, spionaggio più forte, il Clown non compare mai. |
| Repubblica parlamentare | 3 | Idea da sviluppare. |
| Teocrazia | 1 | Il **Sacerdote** è sempre fra i consiglieri. |
| Ierocrazia | 2 | Idea da sviluppare (es. incanti meno costosi in Fede). |

Ogni governo continua a dare una quota di Resistenza, come prevede il GDD §7.1.1.

### 4.3 Come cambia il governo

**Evoluzione — Deciso**

| Regola | Stato |
|---|---|
| Va **solo in avanti**, al tier successivo, scegliendo fra i rami possibili | Deciso |
| Si può evolvere **entrando in una nuova era**: l'evoluzione viene **proposta** e il giocatore può rifiutarla | Deciso |
| Si può evolvere anche con una **Riforma**: un **evento** pagato con **Influenza** | Deciso |
| Il tier non dipende dall'era: con una Riforma si può salire anche restando nella stessa era | Deciso |
| Finché gli eventi a scelta non esistono, l'evoluzione avviene solo entrando in una nuova era | Conseguenza |

**Rivoluzione — Deciso**

| Regola | Stato |
|---|---|
| È un cambio **voluto dal popolo**, causato dall'accumulo di **Malcontento** (§7) | Deciso |
| Può portare a qualsiasi governo, **anche di un tier più basso** | Deciso |
| **Scelta mista**: la **causa** del Malcontento decide quali governi sono possibili; il **giocatore** sceglie fra quelli | Deciso |
| Dopo la rivoluzione il Malcontento **si azzera** | Deciso |
| La causa è la fonte che ha prodotto più Malcontento (es. molte sconfitte: governi militari; carestie: governi popolari) | Proposta |

**Che cosa succede al vecchio governo — Proposta**

- Il **tratto permanente** del vecchio governo finisce e vale quello nuovo.
- Gli elementi già sulla plancia **restano**, come succede con le ere; gli esclusivi del vecchio governo non vengono più offerti.
- Il cambio resta scritto nella **storia della nazione**, come capitolo della run (fantasia del GDR).

**Da definire:**

- Se all'ingresso in un'era l'evoluzione del governo viene proposta prima o dopo la scelta della via.
- Il costo in Influenza della Riforma e quando compare l'evento.
- Quale governo possono avere i fantasmi generati e se evolvono con gli anni.

---

## 5. Credo: tipi di fede

### 5.1 Regola degli incanti — Deciso

- Gli **incanti comuni** di oggi (Fuoco, Gelo, Ombra, Guardia, Vita; GDD §4.3) restano disponibili a tutti.
- Ogni credo aggiunge **1-2 incanti esclusivi**, offerti dal Sacerdote solo a quella nazione.
- Gli incanti esclusivi usano solo le **famiglie di effetti esistenti** (Danno, attacco d'assedio, Scudo, Cura, Corruzione, Inefficienza, Sabotaggio): non toccano il nucleo.

### 5.2 Credi del prototipo (placeholder)

| Credo | Che fede è | Incanto esclusivo (idea) | Sostituisce |
|---|---|---|---|
| **Culto solare** | Adorazione del sole e della luce | Danno + Cura insieme | Culto del Sole |
| **Spiriti dei luoghi** | Animismo: ogni bosco e fiume ha uno spirito | Cura che rallenta i nemici (Inefficienza) | Antichi spiriti |
| **Culto degli antenati** | Venerazione dei padri fondatori | Scudo più forte sulle truppe senza mana | — |
| **Culto del vuoto** | Fede oscura nel nulla | Corruzione + Sabotaggio | — |

L'**Ordine della Ragione** non è una fede: esce dai credi e la sua idea (il sapere) passa alla Cultura erudita (§6).

---

## 6. Cultura: come si usano le risorse

| Cultura (placeholder) | Idea | Stato |
|---|---|---|
| **Mercantile** | Tasso migliore al mercato delle risorse | Proposta |
| **Guerriera** | Le azioni del Generale costano meno Ferro | Proposta |
| **Erudita** | Le azioni dello Studioso costano meno o rendono di più (eredita l'Ordine della Ragione) | Proposta |
| **Artigiana** | Potenziamenti più economici | Proposta |

---

## 7. Malcontento — modifica del nucleo

Il Malcontento è un **nuovo contatore della nazione**. Per il principio P5 è una nuova risorsa, quindi una modifica del nucleo: **Davide l'ha confermato** in questa discussione.

| Regola | Stato |
|---|---|
| Sale con: **sconfitte**, **carestie** (Cibo insufficiente), **malus subiti**, alcune **azioni del Consiglio** | Deciso (proposta approvata da Davide) |
| Scende con: **Fede**, **Cibo** o un'**azione del Consiglio** apposita | Deciso (proposta approvata da Davide) |
| Raggiunta una **soglia**, scatta l'evento **Rivoluzione** (§4.3) | Deciso |
| Dopo la rivoluzione si **azzera** | Deciso |
| È **sempre visibile**, con la soglia, e il gioco avverte quando la rivoluzione si avvicina: il giocatore deve vederla arrivare (come il principio P4 per la battaglia) | Proposta |
| Vive **fuori dalla battaglia**: non entra nella simulazione dello scontro e non cambia la Resistenza | Proposta |
| Si conserva da un anno all'altro, come le risorse del Magazzino | Proposta |

**Da definire:**

- Valori: quanto sale per ogni causa, quanto costa farlo scendere, a quanto sta la soglia.
- Quale consigliere offre l'azione che lo fa scendere.
- Quali azioni del Consiglio lo fanno salire.
- Se l'identità (razza, governo, cultura) lo fa salire più o meno in fretta.

---

## 8. Identità ed eventi

Tutte le dimensioni contribuiscono a determinare quali eventi capitano (Deciso). Per rendere possibili gli eventi futuri senza costruirli subito:

- ogni elemento dell'identità riceve delle **etichette** (es. "marittimo", "devoto", "guerriero", "autoritario") che gli eventi potranno leggere nelle loro condizioni di comparsa (GDD §13.4) — **Proposta**;
- le stesse etichette serviranno in futuro per le **sinergie e tensioni** fra elementi (§0).

---

## 9. Ordine di lavoro suggerito

Ogni passo funziona da solo e si può provare in Godot prima del successivo.

| Passo | Contenuto | Tocca il nucleo? |
|---|---|---|
| 1 | Nuovo catalogo: 3 razze, credi con incanti esclusivi, culture, governi del tier 1, etichette | No |
| 2 | Nuovi tipi di effetto del governo sul Consiglio (consiglieri in più o in meno, consigliere sempre presente) | No (estende la scheda §9.2) |
| 3 | Governi a tier ed evoluzione proposta all'ingresso in un'era | No |
| 4 | Esclusivi delle razze per le ere 2 e 3 | No |
| 5 | Sistema degli eventi a scelta | No, ma promuove uno Spunto |
| 6 | Riforma (evento) | No |
| 7 | Malcontento e Rivoluzione | **Sì** (nuova risorsa) |

## 10. Nota tecnica a margine

Alcune descrizioni degli elementi attuali citano ancora consiglieri che non esistono più dopo l'arrivo del Consiglio: la Cultura mercantile ("Costruttori"), la Cultura guerriera ("Reclutatori") e il perk Consiglio allargato ("ogni opportunità mostra un'alternativa in più"). Sono testi da aggiornare, indipendenti da questa proposta.
