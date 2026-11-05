# ULTRALOPOLIS — Bozza di aggiornamento del GDD (v0.25)
## L'anno in dodici mesi e quattro stagioni

**Data:** 5 novembre 2026
**Stato:** **approvata da Davide e riportata nel GDD v0.25** (5 novembre 2026). Non ancora nel gioco. Questo file resta come memoria della discussione.
**Riferimento:** `docs/Ultralopolis_GDD.md` v0.24

Stati come nel GDD (§0.2): **Confermato** = deciso da Davide; **Proposta** = suggerito da Claude, da approvare; **Da definire** = nessuna regola ancora; **Spunto** = idea per il futuro, da non implementare.

**Modifica del nucleo.** Cambia la struttura dell'anno (§3.2, §4.1) e la produzione (§5.2), regole della Parte I oggi Confermate. Gli effetti invece usano solo il linguaggio che esiste già: nessuna nuova risorsa e nessuna nuova famiglia di effetti (principio P5). La stagione diventa una nuova **radice** per eventi e consiglieri (§4.2.5).

**Bozza 2:** l'anno comincia con l'**inverno** e finisce con l'**autunno**, così lo scontro con il fantasma chiude l'anno (Davide). Rispetto alla bozza 1 spariscono le regole sullo spionaggio d'inverno e sul consumo di Cibo spostato.

---

## 1. Decisioni di Davide (5 novembre)

| # | Decisione | Stato |
|---|---|---|
| 1 | L'anno ha **12 round, uno per mese**, divisi in **4 stagioni da 3 round** | Confermato |
| 2 | L'anno **comincia con l'inverno e finisce con l'autunno**: l'ultimo scontro dell'anno è il fantasma | Confermato |
| 3 | **Primavera** ed **Estate** finiscono con un **incontro del mondo**; l'**Autunno** con il **fantasma**; d'**Inverno** non si combatte | Confermato |
| 4 | Gli edifici producono **all'inizio di ogni stagione**; d'inverno **non producono Cibo** | Confermato |
| 5 | L'inverno ha **eventi suoi** e più azioni "interne", meno carte militari | Confermato |
| 6 | I **temi dei round** dipendono dalla stagione | Confermato |
| 7 | **10 vittorie** contro i fantasmi e **20 di Prestigio** restano uguali | Confermato |
| 8 | I **valori di produzione** restano quelli di oggi (placeholder) | Confermato |
| 9 | I **temi delle stagioni** del §2.3 | Confermato |
| 10 | Ogni round mostra il **nome del mese** | Confermato |

---

## 2. L'anno

```
INVERNO             PRIMAVERA           ESTATE              AUTUNNO
Gen  Feb  Mar       Apr  Mag  Giu   ⚔   Lug  Ago  Set   ⚔   Ott  Nov  Dic   ☠
nessuno scontro     incontro del mondo  incontro del mondo  fantasma: fine dell'anno
```

All'inizio di ogni stagione gli edifici producono (d'inverno senza Cibo).

| Momento | Che cosa succede | Stato |
|---|---|---|
| **Inizio dell'anno** (gennaio) | Si fissano il fantasma dell'anno e i due incontri; finiscono i modificatori scaduti; le truppe mangiano (dall'anno 2), come oggi (§5.4) | Proposta |
| **Inverno** · gen, feb, mar | Produzione senza Cibo, poi 3 round. Nessuno scontro | Proposta |
| **Primavera** · apr, mag, giu | Produzione, 3 round, poi l'**incontro del mondo** (scelta fra 3) | Proposta |
| **Estate** · lug, ago, set | Produzione, 3 round, poi il secondo **incontro del mondo**, più forte del primo | Proposta |
| **Autunno** · ott, nov, dic | Produzione, 3 round, poi lo **scontro con il fantasma**: esito, Prestigio, malus. L'anno finisce | Proposta |

| Regola | Stato |
|---|---|
| Ogni round ha il nome del suo mese, visibile in alto (es. "Anno 2 · Estate · Agosto") | Confermato |
| Ogni incontro resta una scelta **fra 3** (facile, media, difficile), con le conseguenze di oggi: bottino e ricompensa se vinci; Oro dimezzato e +1 Malcontento se perdi; fine della run in ultima possibilità | Proposta |
| L'incontro d'estate è più forte di quello di primavera (a metà strada fra un anno e il successivo) | Proposta |
| Produzione e Preparazione spariscono come nomi di fase: le fasi sono le **stagioni** | Proposta |
| Lo spionaggio agisce sul fantasma dell'anno, come oggi: si può comprare in qualunque stagione, perché il fantasma è fissato a gennaio e si affronta a dicembre | Proposta (nessun cambiamento) |

### 2.1 Produzione

| Regola | Stato |
|---|---|
| All'inizio di ogni stagione gli edifici depositano le loro risorse, come oggi all'inizio di ogni metà (§5.2). Un edificio costruito in una stagione produce dalla stagione successiva | Proposta |
| **D'inverno nessun edificio produce Cibo** (nemmeno la Capitale); tutte le altre risorse sì | Confermato |
| I valori di produzione **restano quelli di oggi**: le entrate dell'anno raddoppiano (4 produzioni invece di 2). Sono placeholder: il bilanciamento si rifà con le prove | Confermato |

### 2.2 Inverno

| Regola | Stato |
|---|---|
| Il consumo di Cibo resta all'inizio dell'anno, cioè all'inizio dell'inverno, e resta dall'anno 2 (§5.4, nessun cambiamento). Con l'inverno senza Cibo, il Cibo per mangiare va messo da parte nell'anno prima | Proposta |
| D'inverno **non ci sono round Truppe** (vedi temi, §2.3) | Proposta |
| D'inverno Cancelliere, Sacerdote e Fattore sono **più frequenti** (+1 di peso), il Generale **meno** (peso dimezzato, almeno 1) | Proposta |
| La **Riforma** e i **Tumulti in piazza** sono più frequenti d'inverno (+1 di peso) | Proposta |

### 2.3 Temi dei round

Oggi ogni metà ha un round Azioni, uno Edifici, uno Truppe e due Misti. Con le stagioni ogni stagione ha i suoi tre temi, in ordine pescato a caso con il seme della run:

| Stagione | Temi | Perché |
|---|---|---|
| Inverno | Azioni, Edifici, Misto | politica interna e costruzione, nessun round Truppe; è anche l'inizio della run, quindi serve poter costruire |
| Primavera | Edifici, Misto, Misto | si cresce |
| Estate | Truppe, Edifici, Misto | ci si arma per la stagione delle guerre |
| Autunno | Truppe, Azioni, Misto | si prepara il fantasma (spionaggio, incanti, ultime truppe) |

In un anno: 2 Azioni, 3 Edifici, 2 Truppe, 5 Misti (oggi 2, 2, 2, 4). I temi stanno nei file dati e si cambiano senza toccare il codice. Stato: **Confermato** (Davide, 5 novembre).

### 2.4 Eventi e stagioni

| Regola | Stato |
|---|---|
| Nuova **radice** degli eventi, dei visitatori e delle fortune: le **stagioni** in cui possono comparire (nessuna = tutte) | Proposta |
| Eventi esistenti legati a una stagione: *Un inverno lungo* e *Il passo innevato* (inverno), *La piena del fiume* e *Le terre di confine* (primavera), *Il torneo* (estate), *Raccolto abbondante* (estate o autunno), *La grande fiera* (autunno) | Proposta |
| Eventi nuovi d'inverno, placeholder: *La festa di mezzo inverno* (Stato: Stabilità o −Malcontento), *Il gelo* (Terra: Legno per ripararsi, oppure un malus breve), *Le veglie al focolare* (Conoscenza: Ricerca o Documenti) | Proposta |
| La probabilità delle carte speciali (33%) resta uguale in tutte le stagioni | Proposta |

### 2.5 Che cosa resta uguale

- 10 vittorie contro i fantasmi per vincere; 20 di Prestigio; una sconfitta nell'anno N toglie N (Confermato).
- L'ordine "inizio anno → round → scontri → fantasma che chiude l'anno".
- Il consumo di Cibo all'inizio dell'anno, dall'anno 2.
- Lo spionaggio sul fantasma dell'anno.
- Il Consiglio: 3 carte per round (o quante ne decide il governo), 3 proposte, Potenzia, rinnovo, passare.
- Le ere: si avanza in qualunque round, pagando la Ricerca.
- I malus "per un anno" e "fino al prossimo fantasma".
- Il mercato, la vendita, il riordino delle truppe.

---

## 3. Conseguenze da sapere

| Tema | Che cosa succede |
|---|---|
| **Durata** | Ogni anno ha 12 round invece di 10 e 3 scontri invece di 2: un anno dura circa un quarto in più |
| **Economia** | Con i valori di oggi le entrate raddoppiano (§2.1): Oro e risorse abbonderanno finché non ribilanciamo |
| **Incontri** | Con due incontri all'anno servono 6 plance per anno negli anni scritti a mano (oggi 3): il generatore ne crea 3 per ogni incontro |
| **Cibo** | L'inverno non produce Cibo e si mangia proprio all'inizio dell'inverno: il Cibo dell'anno va accumulato fra primavera e autunno |
| **Codice** | Cambiano le fasi della run, i nomi in schermata, i temi, la produzione, le radici degli eventi e il generatore degli incontri. Vanno rifatti molti test |

---

## 4. Domande chiuse (Davide, 5 novembre)

1. **Cibo d'inverno:** niente Cibo.
2. **Valori di produzione:** restano quelli di oggi.
3. **Temi delle stagioni:** quelli del §2.3.
4. **Mesi visibili:** sì, il nome del mese.

Restano **Proposta** i dettagli non discussi uno per uno: i pesi dei consiglieri d'inverno, gli eventi legati alle stagioni e i tre eventi invernali nuovi, l'incontro d'estate più forte.

---

## 5. Che cosa cambierebbe nel GDD

| Punto | Oggi | Con la bozza |
|---|---|---|
| §3.2 Anni e scontri | 5 round, incontro, 5 round, fantasma | 4 stagioni da 3 round: inverno senza scontri, incontro, incontro, fantasma |
| §3.3 Incontri del mondo | Uno per anno, fra Produzione e Preparazione | Due per anno, a fine primavera e a fine estate |
| §4.1 Sequenza | Produzione, round 1–5, incontro, Preparazione, round 6–10, fantasma | La sequenza delle stagioni (§2) |
| §4.2 Il Consiglio | Temi per metà | Temi per stagione (§2.3); pesi dei consiglieri d'inverno |
| §4.2.5 Eventi | Radici: identità, vie, era, tipi, stato | Si aggiunge la stagione |
| §5.2 Produzione | All'inizio delle due metà | All'inizio di ogni stagione; niente Cibo d'inverno |
| §16.3 e glossario | Produzione e Preparazione | Stagioni |
