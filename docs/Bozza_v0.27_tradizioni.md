# ULTRALOPOLIS — Bozza di aggiornamento del GDD (v0.27)
## Tradizioni e ascensioni: le vie diventano alberi

**Data:** 5 novembre 2026
**Stato:** **approvata da Davide il 5 novembre 2026 e riportata nel GDD v0.27** (§10.4.1, §10.4.2) e nel Catalogo (§4.4, §4.5). Questo file resta come memoria della discussione.
**Riferimento:** `docs/Ultralopolis_GDD.md` v0.26

Stati come nel GDD (§0.2): **Confermato** = deciso da Davide; **Proposta** = suggerito da Claude, da approvare; **Da definire** = manca una regola; **Spunto** = idea per il futuro, da non implementare.

**Portata.** Le vie stanno nella Parte II del GDD (§10.4): passi e imprese le ampliano senza toccare il nucleo. Non serve una risorsa nuova, perché i passi si sbloccano con le **imprese**, e gli effetti dei passi usano il linguaggio del nucleo (P5).

**Le ascensioni del livello 2 sono invece modifiche del nucleo.** Ognuna cambia una regola della Parte I (§6.2): va approvata una per una, ed entra nel GDD come modifica del nucleo.

Riferimento verificato (Stellaris Wiki, pagine *Traditions* e *Ascension perks*): in Stellaris ogni albero ha un'adozione, 5 tradizioni e un completamento, e si compra con l'Unità. Completando un albero si apre uno spazio per un'ascensione; le ascensioni sono permanenti e a livelli.

---

## 1. Decisioni prese con Davide

| # | Decisione | Stato |
|---|---|---|
| 1 | Le tradizioni **non sono un sistema a parte**: ogni **via** diventa un albero di tradizioni | Confermato |
| 2 | I passi dell'albero si sbloccano con le **imprese** della nazione, cioè facendo cose, non pagando una risorsa | Confermato |
| 3 | Un'**ascensione** si ottiene **completando un albero** | Confermato |
| 4 | Si progetta subito, insieme alle tecnologie | Confermato |
| 5 | L'era 1 **non ha un albero**: le tradizioni cominciano con la prima via, nell'era 2 | Confermato |
| 6 | **4 passi** per via | Confermato |
| 7 | Le **imprese si vedono prima di scegliere la via**, sulla sua carta | Confermato |
| 8 | Piacciono soprattutto le ascensioni che **cambiano una regola**, come "Seconda natura" | Confermato |
| 9 | Approvate **tutte** le 8 ascensioni del livello 2, come placeholder; la prima ascensione è di livello 1, la seconda di livello 2; il catalogo dei passi va bene come punto di partenza | Confermato |

---

## 2. Che cosa diventa una via

| Parte dell'albero | Che cosa è | Stato |
|---|---|---|
| **Adozione** | Scegliere la via entrando nell'era, come oggi. Dà ciò che la via dà già: tratto permanente, bonus immediato, offerte più frequenti, esclusivi e tecnologie esclusive (§10.4) | Proposta (nessun cambiamento alle vie di oggi) |
| **Passi** | **4 tradizioni** per via, ognuna con la sua impresa e il suo effetto | Confermato (decisione 6) |
| **Completamento** | Quando i 4 passi sono fatti, la nazione sceglie un'**ascensione** (§5) | Confermato (decisione 3) |

| Regola | Stato |
|---|---|
| I passi si possono completare **in qualsiasi ordine**: tutte le imprese della via sono attive insieme, e l'ordine nasce da come gioca la nazione | Proposta |
| Un passo si completa **da solo** appena l'impresa riesce, e il suo effetto vale subito e **per sempre** | Proposta |
| L'albero di una via **resta aperto anche nelle ere successive**: una via scelta nell'era 2 si può completare nell'era 3 | Proposta |
| La carta della via mostra, prima della scelta, le **4 imprese** e i loro effetti (decisione 7) | Confermato |
| Le vie restano una per era, dalla seconda (§10.4): nel prototipo, con 3 ere, sono **2 alberi per run**. L'era 1 non ha albero (decisione 5) | Confermato |

---

## 3. Le imprese

Un'impresa è un obiettivo che si legge in una riga e che il gioco può controllare da solo, per esempio "Vinci 3 scontri" o "Abbi 4 carte Fante sulla plancia". Accanto a ogni impresa si vede quanto manca (P4).

### 3.1 Due generi di impresa

| Genere | Come si controlla | Esempio | Stato |
|---|---|---|---|
| **Traguardo** | Conta le cose fatte **dopo l'adozione della via**: quello che era già fatto prima non vale | "Vinci 3 scontri" | Proposta |
| **Stato** | Guarda com'è la nazione in quel momento; basta esserci arrivati una volta | "Abbi 4 carte Fante sulla plancia" | Proposta |

### 3.2 Imprese possibili nel primo prototipo

Sono tutte cose che il gioco conosce già, quindi non servono regole nuove.

| Impresa | Genere | Stato |
|---|---|---|
| Vincere N scontri: fantasmi, incontri o entrambi; un pareggio conta come vittoria (§3.4) | Traguardo | Proposta |
| Completare N tecnologie, di qualsiasi sfera o di una sfera (§10.5) | Traguardo | Proposta |
| Prendere N proposte da un consigliere | Traguardo | Proposta |
| Scegliere N Eventi di una sfera (§4.2.5) | Traguardo | Proposta |
| Avere sulla plancia N carte con un tipo | Stato | Proposta |
| Avere N carte con un tipo al livello 2 o più | Stato | Proposta |
| Raccogliere in una sola produzione almeno N di una risorsa | Stato | Proposta |
| Chiudere un anno con il Malcontento a N o meno (§5.5) | Stato | Proposta |

| Regola | Stato |
|---|---|
| I passi di un albero vanno dal più facile al più difficile: il primo si fa in un anno, l'ultimo chiede di puntare sulla via | Proposta |
| Le imprese sono scritte nei dati della via, non nel codice: si cambiano senza toccare uno script | Proposta |
| Imprese che guardano dentro la battaglia, come "vinci uno scontro senza scendere sotto metà Resistenza" | Spunto (servono statistiche della battaglia che oggi non si registrano) |

---

## 4. Catalogo dei passi (placeholder)

Gli effetti usano modificatori che il gioco ha già. I numeri sono placeholder.

### 4.1 Vie dell'era 2

| Via | Passo | Impresa | Effetto |
|---|---|---|---|
| **Commercio** | Botteghe | Prendi 3 proposte dal Tesoriere | +1 Oro per fase dalla Capitale |
| | Carovane | Abbi 2 edifici Infrastruttura Strategica | +1 Influenza per fase da ogni edificio Infrastruttura Strategica |
| | Fiere annuali | Raccogli almeno 12 Oro in una sola produzione | Rinnovare le proposte costa 1 Oro in meno |
| | Gilde | Abbi 3 edifici Economici al livello 2 o più | +10% Oro prodotto |
| **Guerra** | Veterani | Vinci 2 scontri | Le truppe Fante che fanno danno ne fanno 1 in più |
| | Arsenali | Abbi 2 edifici Infrastruttura Bellica | +1 Ferro per fase da ogni edificio Infrastruttura Bellica |
| | Dottrina | Prendi 4 proposte dal Generale | +1 spazio truppa |
| | Esercito di popolo | Abbi 3 carte Fante al livello 2 o più | +8 Resistenza in ogni scontro |
| **Fede** | Pellegrini | Scegli 1 Evento di Fede | +1 Fede per fase dalla Capitale |
| | Confraternite | Abbi 3 carte Spirituali | Gli elementi Spirituali che curano curano 1 in più |
| | Concilio | Prendi 4 proposte dal Sacerdote | +6 Resistenza in ogni scontro |
| | Santità | Chiudi un anno con il Malcontento a 2 o meno | Gli edifici Spirituali producono il 10% più in fretta |
| **Sapere** | Scuole | Completa 2 tecnologie | +1 Documenti per fase dalla Capitale |
| | Biblioteche | Abbi 2 edifici Accademici | +1 Documenti per fase da ogni edificio Accademico |
| | Accademie | Completa 3 tecnologie di Conoscenza | +10% Ricerca prodotta |
| | Enciclopedisti | Raccogli almeno 8 Ricerca in una sola produzione | Ogni consigliere mostra una proposta in più |

### 4.2 Vie dell'era 3

| Via | Passo | Impresa | Effetto |
|---|---|---|---|
| **Impero** | Legati | Vinci 2 scontri | +1 spazio edificio |
| | Strade | Abbi 2 edifici Infrastruttura Strategica | +1 Pietra per fase da ogni edificio Infrastruttura Strategica |
| | Legioni | Abbi 4 carte Fante al livello 2 o più | Le truppe Fante fanno il 10% di danno in più |
| | Pax | Vinci 3 scontri con il fantasma | +10 Resistenza in ogni scontro |
| **Oro** | Zecche | Prendi 3 proposte dal Tesoriere | +2 Oro per fase dalla Capitale |
| | Banchieri | Abbi 3 edifici Economici | +1 Influenza per fase da ogni edificio Economico |
| | Credito | Raccogli almeno 20 Oro in una sola produzione | Rinnovare le proposte costa 1 Oro in meno |
| | Monopolio | Abbi 2 edifici Economici al livello 3 | +15% Oro prodotto |
| **Rivelazione** | Visioni | Scegli 1 Evento di Fede | +1 Fede per fase da ogni edificio Spirituale |
| | Martiri | Vinci 2 scontri | Gli elementi Spirituali che producono scudo ne producono 1 in più |
| | Profeti | Prendi 3 proposte dal Sacerdote | +8 Resistenza in ogni scontro |
| | Ultima rivelazione | Abbi 2 carte Spirituali al livello 3 | Gli elementi che curano curano 2 in più |
| **Ombra** | Informatori | Prendi 3 proposte dal Maestro delle spie | Le truppe Criminali ricaricano il 10% più in fretta |
| | Covi | Abbi 2 edifici Infrastruttura Segreta | +1 Documenti per fase da ogni edificio Infrastruttura Segreta |
| | Sicari | Vinci 2 scontri con il fantasma | Il Sabotaggio inflitto dura il 25% in più |
| | Ombra lunga | Abbi 4 carte Criminali | Gli elementi che infliggono Corruzione ne infliggono 1 in più |
| **Spiriti** | Boschi sacri | Abbi 2 edifici di Produzione o Fauna | +1 Legno per fase dalla Capitale |
| | Branchi | Abbi 3 carte Fauna | Le truppe Fauna ricaricano il 10% più in fretta |
| | Antenati | Scegli 2 Eventi di Terra o di Fede | +8 Resistenza in ogni scontro |
| | Grande madre | Raccogli almeno 10 Cibo in una sola produzione | +1 Cibo per fase da ogni edificio Fauna o di Produzione |

---

## 5. Le ascensioni

| Regola | Stato |
|---|---|
| Completando un albero si sceglie **1 ascensione fra 3** pescate, con più probabilità per quelle coerenti con l'identità e le vie (stessa regola delle vie, §16.3) | Proposta |
| Le ascensioni sono **permanenti** e non si cambiano | Proposta (come in Stellaris) |
| **Livello 1**: effetti forti con il linguaggio di oggi. **Livello 2**: cambiano una regola del gioco (decisione 8) e compaiono solo a chi ha già un'ascensione. Nel prototipo, con 2 alberi per run, la prima ascensione è di livello 1 e la seconda di livello 2 | Proposta |
| Un'ascensione già presa non si ripresenta | Proposta |
| Alcune ascensioni possono essere esclusive di una via o di un elemento dell'identità (radice "richiede") | Proposta |
| Un'ascensione che cambia una regola **si vede in battaglia** (P4): per esempio la truppa incantata due volte mostra entrambi gli incanti, e "Ultima trincea" mostra il momento in cui salva la nazione | Proposta |

---

## 6. Catalogo delle ascensioni (placeholder)

### 6.1 Livello 1 — effetti forti con il linguaggio di oggi

| Ascensione | Effetto |
|---|---|
| **Nazione in armi** | +1 spazio truppa e +1 spazio edificio |
| **Consiglio ristretto** | In ogni round compare un consigliere in più (effetto già usato dai governi, v0.24) |
| **Botteghe maestre** | Potenzia costa 1 in meno, mai sotto 1 (effetto già usato dalla cultura artigiana, v0.24) |
| **Eredità imperiale** | +20 Resistenza in ogni scontro |
| **Età dell'oro** | +25% di tutte le risorse prodotte |
| **Maestri d'armi** | Tutte le truppe fanno il 15% di danno in più |

### 6.2 Livello 2 — cambiano una regola (modifiche del nucleo, da approvare una per una)

| Ascensione | Effetto | Regola che cambia | Rischio da tenere d'occhio |
|---|---|---|---|
| **Seconda natura** | Ogni truppa si può incantare **due volte** | §4.3: "ogni truppa si può incantare una sola volta" | Truppe con due effetti e +4 mana: forti ma lente da alimentare |
| **Ultima trincea** | La prima volta in ogni scontro che la Resistenza arriva a zero, torna a **1** | §7.1: "arrivare a zero significa perdere" | Non salva dalla Corruzione: resta il contro |
| **Prima scintilla** | Gli edifici iniziano lo scontro con l'intervallo **a metà**, non pieno | §7.5: "truppe ed edifici iniziano con l'intervallo pieno" | Rende più veloce l'inizio: da provare con il logoramento |
| **Disciplina ferrea** | La truppa più a destra **prenota** il mana: le altre non lo usano finché lei non si attiva | §7.3: "il mana non viene prenotato per la truppa saltata" | Cambia l'ordine delle truppe: la regola di priorità va spiegata bene a schermo |
| **Mana unito** | Una truppa può pagare con il mana di **qualsiasi colore**, dopo il proprio e l'energetico | §5.3: "una truppa paga prima con il proprio colore e poi con l'energetico" | Molto forte per le nazioni a più colori |
| **Maestria** | Le carte possono arrivare al **livello 4** | §6.5: "3 livelli" | Serve un costo di Potenzia per il livello 4 |
| **Doppio ascolto** | Una volta per metà anno si prendono **due proposte** dallo stesso consigliere | §4.2: "se ne prende una sola" | Da limitare (una volta per metà) per non svuotare la scelta |
| **Esercito frugale** | Le truppe senza Cibo **non rallentano** | §5.4: "ricarica ×1,5 senza cibo" | Toglie peso al Cibo: da accoppiare a nazioni che ne hanno poco |

I fantasmi registrano anche le ascensioni del livello 2 (§8): la versione delle regole salvata nel fantasma deve dire quali regole cambiano per lui.

---

## 7. Interfaccia (P4)

| Regola | Stato |
|---|---|
| Un pannello **Tradizioni**, accanto a Ricerca: per ogni via adottata, i suoi passi con l'impresa, l'avanzamento ("2/3 scontri vinti") e l'effetto | Proposta |
| Quando un passo si completa compare un messaggio, e la cronaca lo registra | Proposta |
| La scelta dell'ascensione si fa con le carte sul tavolo, come le vie | Proposta |

---

## 8. Fantasmi

| Regola | Stato |
|---|---|
| Un fantasma salvato registra i passi e le ascensioni; in battaglia valgono i passi su tutta la nazione e le ascensioni che cambiano le regole della battaglia | Proposta tecnica |
| Fantasmi generati: tutti i passi delle vie delle ere passate e metà di quelli della via dell'era corrente, scelti a caso con il seme della run; un'ascensione per ogni albero completo | Convenzione provvisoria (§16.3) |

---

## 9. Domande per Davide

1. **Ascensioni del livello 2 (§6.2):** quali approvi? Ognuna è una modifica del nucleo. Puoi approvarle tutte, solo alcune, o proporne altre.
2. **Livelli:** va bene che la prima ascensione sia di livello 1 (effetti forti di oggi) e la seconda di livello 2 (regole che cambiano)? Oppure vuoi che anche la prima possa cambiare una regola?
3. **Catalogo dei passi (§4):** va bene come punto di partenza, o vuoi cambiare qualche impresa?
