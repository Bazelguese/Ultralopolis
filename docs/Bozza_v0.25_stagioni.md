# ULTRALOPOLIS — Bozza di aggiornamento del GDD (v0.25)
## L'anno in dodici mesi e quattro stagioni

**Data:** 5 novembre 2026
**Stato:** **bozza, da approvare.** Non cambia ancora né il GDD né il gioco.
**Riferimento:** `docs/Ultralopolis_GDD.md` v0.24

Stati come nel GDD (§0.2): **Confermato** = deciso da Davide; **Proposta** = suggerito da Claude, da approvare; **Da definire** = nessuna regola ancora; **Spunto** = idea per il futuro, da non implementare.

**Modifica del nucleo.** Cambia la struttura dell'anno (§3.2, §4.1), la produzione (§5.2) e il consumo di Cibo (§5.4), tutte regole della Parte I oggi Confermate. Gli effetti invece usano solo il linguaggio che esiste già: nessuna nuova risorsa e nessuna nuova famiglia di effetti (principio P5). La stagione diventa una nuova **radice** per eventi e consiglieri (§4.2.5).

---

## 1. Decisioni di Davide (5 novembre)

| # | Decisione | Stato |
|---|---|---|
| 1 | L'anno ha **12 round, uno per mese**, divisi in **4 stagioni da 3 round** | Confermato |
| 2 | **Primavera** ed **Estate** finiscono con un **incontro del mondo**; l'**Autunno** finisce con lo **scontro con il fantasma**; d'**Inverno** non si combatte | Confermato |
| 3 | Gli edifici producono **all'inizio di ogni stagione**; d'inverno producono **meno o niente Cibo** | Confermato nella forma; quantità Da definire (§3.2) |
| 4 | D'inverno si **consuma il Cibo**; l'inverno ha **eventi suoi** e più azioni "interne", meno carte militari | Confermato |
| 5 | I **temi dei round** dipendono dalla stagione | Confermato |
| 6 | **10 vittorie** contro i fantasmi e **20 di Prestigio** restano uguali | Confermato |

---

## 2. L'anno

```
PRIMAVERA            ESTATE               AUTUNNO              INVERNO
Mar  Apr  Mag   ⚔   Giu  Lug  Ago   ⚔   Set  Ott  Nov   ☠   Dic  Gen  Feb
produzione          produzione          produzione          produzione (senza Cibo)
                                                            consumo di Cibo
incontro del mondo  incontro del mondo  fantasma            nessuno scontro
```

| Regola | Stato |
|---|---|
| L'anno comincia in **primavera** (marzo) e finisce con l'**inverno** (febbraio) | Proposta |
| Ogni round ha il nome del suo mese, visibile in alto (es. "Anno 2 · Estate · Luglio") | Proposta |
| Il **fantasma** dell'anno e i **due incontri** (primavera ed estate) si fissano all'inizio dell'anno e non cambiano più (come oggi, §4.1) | Proposta |
| L'**incontro d'estate** è più forte di quello di primavera (stessa regola di crescita degli anni, a metà strada fra un anno e il successivo) | Proposta |
| Ogni incontro resta una scelta **fra 3** (facile, media, difficile), con le stesse conseguenze di oggi: bottino e ricompensa se vinci, Oro dimezzato e +1 Malcontento se perdi, fine della run in ultima possibilità | Proposta |
| Dopo il fantasma d'autunno l'anno **continua** con l'inverno; l'esito (vittoria, Prestigio, malus) vale subito | Proposta |
| Produzione e Preparazione spariscono come nomi di fase: le fasi sono le **stagioni** | Proposta |

### 2.1 Produzione

| Regola | Stato |
|---|---|
| All'inizio di ogni stagione gli edifici depositano le loro risorse, come oggi all'inizio di ogni metà (§5.2). Un edificio costruito in una stagione produce dalla stagione successiva | Proposta |
| **D'inverno nessun edificio produce Cibo** (nemmeno la Capitale); tutte le altre risorse sì | Proposta |
| I valori di produzione **restano quelli di oggi**: le entrate dell'anno raddoppiano (4 produzioni invece di 2). Sono placeholder: il bilanciamento si rifà con le prove | Proposta |

### 2.2 Inverno

| Regola | Stato |
|---|---|
| Il **consumo di Cibo** si sposta all'**inizio dell'inverno** (oggi è all'inizio dell'anno, §5.4), dopo la produzione invernale (che non dà Cibo): mangiano prima le truppe più lente, come oggi | Proposta |
| Si mangia **già dal primo inverno** (oggi nel primo anno le truppe non mangiano): a dicembre il giocatore ha già avuto tre stagioni per prepararsi | Proposta |
| Una truppa affamata ricarica più piano fino al consumo dell'inverno dopo: quindi negli scontri di tutto l'anno successivo. Ogni truppa affamata dà +1 Malcontento (§5.5) | Proposta |
| D'inverno **non ci sono round Truppe** (vedi temi, §2.3) | Proposta |
| D'inverno Cancelliere, Sacerdote e Fattore sono **più frequenti** (+1 di peso), il Generale **meno** (peso dimezzato, almeno 1) | Proposta |
| D'inverno le azioni di **spionaggio non compaiono**: il fantasma dell'anno è già stato affrontato e quello nuovo non è ancora fissato | Proposta |
| La **Riforma** e i **Tumulti in piazza** sono più frequenti d'inverno (+1 di peso) | Proposta |

### 2.3 Temi dei round

Oggi ogni metà ha un round Azioni, uno Edifici, uno Truppe e due Misti. Con le stagioni ogni stagione ha i suoi tre temi, in ordine pescato a caso con il seme della run:

| Stagione | Temi | Perché |
|---|---|---|
| Primavera | Edifici, Misto, Misto | si costruisce |
| Estate | Truppe, Edifici, Misto | si arma la nazione per la stagione delle guerre |
| Autunno | Truppe, Azioni, Misto | si prepara il fantasma (spionaggio, incanti) |
| Inverno | Azioni, Azioni, Misto | politica interna, nessun round Truppe |

In un anno: 3 Azioni, 2 Edifici, 2 Truppe, 5 Misti (oggi 2, 2, 2, 4). Stato: **Proposta**; i temi stanno nei file dati e si cambiano senza toccare il codice.

### 2.4 Eventi e stagioni

| Regola | Stato |
|---|---|
| Nuova **radice** degli eventi, dei visitatori e delle fortune: le **stagioni** in cui possono comparire (nessuna = tutte) | Proposta |
| Eventi esistenti legati a una stagione: *Un inverno lungo* (inverno), *Il passo innevato* (inverno), *La piena del fiume* (primavera), *Raccolto abbondante* (autunno), *Il torneo* (estate), *La grande fiera* (estate o autunno), *Le terre di confine* (primavera) | Proposta |
| Eventi nuovi d'inverno, placeholder: *La festa di mezzo inverno* (Stato: Stabilità o −Malcontento), *Il gelo* (Terra: Legno → riparo, oppure malus breve), *Le veglie al focolare* (Conoscenza: Ricerca o Documenti) | Proposta |
| La probabilità delle carte speciali (33%) resta uguale in tutte le stagioni | Proposta |

### 2.5 Che cosa resta uguale

- 10 vittorie contro i fantasmi per vincere; 20 di Prestigio; una sconfitta nell'anno N toglie N (Confermato).
- Il Consiglio: 3 carte per round (o quante ne decide il governo), 3 proposte, Potenzia, rinnovo, passare.
- Le ere: si avanza in qualunque round, pagando la Ricerca.
- I malus "per un anno" durano fino alla fine dell'inverno; "fino al prossimo fantasma" fino all'autunno.
- Il mercato, la vendita, il riordino delle truppe.

---

## 3. Conseguenze da sapere

| Tema | Che cosa succede |
|---|---|
| **Durata** | Ogni anno ha 12 round invece di 10 e 3 scontri invece di 2: un anno dura circa un quarto in più |
| **Economia** | Con i valori di oggi le entrate raddoppiano (§2.1): l'Oro e le risorse abbonderanno finché non ribilanciamo |
| **Incontri** | Con due incontri all'anno servono 6 plance per anno negli anni scritti a mano (oggi 3): il generatore ne crea 3 per ogni incontro |
| **Cibo** | Con il consumo in inverno e niente Cibo d'inverno, il Cibo va accumulato nelle tre stagioni prima: la carestia diventa una scelta da preparare |
| **Codice** | Cambiano le fasi della run, i nomi in schermata, i temi, la produzione, il consumo, le radici degli eventi e il generatore degli incontri. Vanno rifatti molti test |

---

## 4. Domande ancora aperte

1. **Cibo d'inverno:** niente Cibo (Proposta) o metà?
2. **Primo inverno:** le truppe mangiano già nel primo anno (Proposta) o dal secondo come oggi?
3. **Valori di produzione:** restano quelli di oggi (Proposta, le entrate raddoppiano) o li dimezziamo subito?
4. **Spionaggio d'inverno:** non compare (Proposta) o vale per il fantasma dell'anno dopo (che allora andrebbe fissato all'inizio dell'inverno)?
5. **Temi delle stagioni:** la tabella del §2.3 va bene?
6. **Mesi visibili:** mostriamo il nome del mese (Proposta) o solo la stagione e il numero del round?

---

## 5. Che cosa cambierebbe nel GDD

| Punto | Oggi | Con la bozza |
|---|---|---|
| §3.2 Anni e scontri | 5 round, incontro, 5 round, fantasma | 4 stagioni da 3 round: incontro, incontro, fantasma, nessuno scontro |
| §3.3 Incontri del mondo | Uno per anno, fra Produzione e Preparazione | Due per anno, a fine primavera e a fine estate |
| §4.1 Sequenza | Produzione, round 1–5, incontro, Preparazione, round 6–10, fantasma | La sequenza delle stagioni (§2) |
| §4.2 Il Consiglio | Temi per metà | Temi per stagione (§2.3); pesi dei consiglieri d'inverno |
| §4.2.5 Eventi | Radici: identità, vie, era, tipi, stato | Si aggiunge la stagione |
| §5.2 Produzione | All'inizio delle due metà | All'inizio di ogni stagione; niente Cibo d'inverno |
| §5.4 Cibo | All'inizio dell'anno, dall'anno 2 | All'inizio dell'inverno, dal primo anno |
| §12 Spionaggio | Sul fantasma dell'anno | Non d'inverno |
| §16.3 e glossario | Produzione e Preparazione | Stagioni |
