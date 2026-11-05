# ULTRALOPOLIS — Bozza di aggiornamento del GDD (v0.25)
## Ricerca e albero delle tecnologie

**Data:** 5 novembre 2026
**Stato:** bozza da approvare. Il GDD non è ancora stato modificato.
**Riferimento:** `docs/Ultralopolis_GDD.md` v0.24

Stati come nel GDD (§0.2): **Confermato** = deciso da Davide; **Proposta** = suggerito da Claude, da approvare; **Direzione** = obiettivo, da progettare; **Da definire** = manca una regola; **Spunto** = idea per il futuro, da non implementare.

**Modifica del nucleo.** Cambia lo scopo della Ricerca (§5.3, Parte I) e le ricompense degli incontri (§3.3, Parte I). Supera due regole oggi Confermate: “la Ricerca si conserva e viene spesa” (§10.1) e “struttura lineare, senza albero tecnologico” (§10.2).

Non serve una risorsa nuova, né una nuova famiglia di effetti (P5). Gli effetti delle tecnologie sono modificatori (§8.2): sulle offerte, sul Consiglio, sugli spazi o sui valori di battaglia. Oppure sono perk, che sono già modificatori permanenti. L’unico concetto nuovo è la **linea**, un modo di scrivere il catalogo (§2.6).

---

## 1. Decisioni prese con Davide

| # | Decisione | Stato |
|---|---|---|
| 1 | Esiste un **vero albero** delle tecnologie, con prerequisiti | Confermato |
| 2 | Le tecnologie si scelgono **come in Stellaris**: il gioco mostra una **mano di 3 carte**, prese da tecnologie della stessa altezza o di altezze vicine | Confermato |
| 3 | La ricerca **non è istantanea**: la tecnologia scelta si riempie con la Ricerca che la nazione guadagna | Confermato |
| 4 | Tutta la Ricerca guadagnata (produzione, bottino, azioni, eventi) va nella tecnologia in corso e **non entra nel Magazzino** | Confermato |
| 5 | Spariscono quindi gli usi della Ricerca come moneta: il **Mercante** (Ricerca in Oro), la **vendita della Ricerca** al mercato e il pagamento delle azioni del Tesoriere in Ricerca (le paga in Influenza) | Confermato |
| 6 | La Ricerca in più a una tecnologia completata **non va persa**: passa alla tecnologia successiva | Confermato |
| 7 | Si può **cambiare tecnologia a metà**: i progressi su quella lasciata restano salvati | Confermato |
| 8 | Per entrare in un’era servono **un certo numero di tecnologie**; non si paga più l’era con la Ricerca | Confermato |
| 9 | Il passaggio d’era non è automatico: quando ha le tecnologie richieste, è il **giocatore a decidere quando** entrare | Confermato |
| 10 | La tecnologia da studiare si sceglie **in qualunque momento** fuori dalla battaglia e **non consuma il round** | Confermato |
| 11 | Le tecnologie completate valgono **per sempre** | Confermato |
| 12 | Si può ricercare **tutto**: elementi (edifici e truppe), perk, miglioramenti del Consiglio e della nazione, dottrine sui tipi | Confermato |
| 13 | Un elemento sbloccato appartiene a una **linea**: in ogni era la tecnologia offre la versione di quell’era. Se l’era nuova non ha una versione, resta quella precedente | Confermato |
| 14 | Ogni via ha anche delle **tecnologie esclusive** (dalla decisione 22, anche ogni razza) | Confermato |
| 15 | Lo **Studioso** aiuta la ricerca: le sue azioni portano Ricerca alla tecnologia in corso, e un’azione nuova ripesca la mano | Confermato |
| 16 | L’albero ha **4 rami, uno per colore di mana**, ciascuno con le due categorie a cui il colore tende (§5.3) | Confermato |
| 17 | Le tecnologie costano **solo Ricerca**. Solo alcuni **progetti speciali** potranno chiedere anche una risorsa di categoria, per non legare una nazione a una sola risorsa | Confermato (progetti speciali: Direzione) |
| 18 | **Carte dorate**: Eventi, Fortune e incontri del mondo possono dare una tecnologia già iniziata | Confermato |
| 19 | **Sconto sulla carta scartata**: una tecnologia mostrata e non scelta ha metà probabilità di uscire nella mano successiva | Confermato |
| 20 | I fantasmi generati ricevono a caso il numero di tecnologie richiesto per ogni era raggiunta | Confermato come convenzione provvisoria (§16.3) |
| 21 | Costi di prova: **3 Ricerca** per la prima altezza di un’era, **4** per la seconda, poi a salire con le ere | Confermato come punto di partenza; placeholder |
| 22 | Anche le **razze** hanno tecnologie esclusive, come le vie | Confermato |
| 23 | I **progetti speciali** non entrano nel primo prototipo: arrivano dopo | Confermato |

---

## 2. Regole proposte — nuova §10 del GDD

### 2.1 La Ricerca

| Regola | Stato |
|---|---|
| La Ricerca guadagnata va nella **tecnologia in corso** (decisione 4) | Confermato |
| Se non c’è una tecnologia in corso (all’inizio della run, o dopo averne completata una senza sceglierne un’altra), la Ricerca resta **in attesa** e passa alla prima tecnologia scelta. La Ricerca in attesa non si vende e non si spende in altro | Proposta |
| Una tecnologia si completa **appena** raggiunge il suo costo, anche a metà di una fase (per esempio subito dopo il bottino o un’azione dello Studioso) | Proposta |
| La produzione arriva solo all’inizio delle due metà dell’anno (§5.2): le tecnologie si completano quindi a blocchi, circa 2 volte all’anno, più bottino, azioni ed eventi. I costi si tarano su questo ritmo | Proposta |
| Il malus **Ricerca dimezzata** resta: rallenta la ricerca per un anno (esempio di P1) | Proposta |

### 2.2 L’albero

| Regola | Stato |
|---|---|
| Un **unico albero** per tutta la run. Ogni era occupa una fascia di **altezze**: l’era 1 le altezze 1 e 2, l’era 2 le altezze 3 e 4, l’era 3 le altezze 5 e 6 | Proposta |
| **4 rami**, uno per colore (decisione 16): | Confermato |
| — **Rosso**: Militare, Opera | |
| — **Verde**: Terra, Ricchezza | |
| — **Blu**: Fede, Stato | |
| — **Viola**: Conoscenza, Ombra | |
| Ogni tecnologia ha una **sfera**: una delle 8 categorie, come gli eventi (§4.2.5). La sfera dice di che cosa parla la tecnologia e in quale ramo sta | Proposta |
| Si possono ricercare solo tecnologie della **propria era o di ere passate**, mai di ere future | Proposta |
| **Altezza dentro un ramo**: la seconda altezza di un’era si apre dopo **1 tecnologia** della prima altezza dello stesso ramo (in Stellaris servono 6 tecnologie del livello precedente) | Proposta; quantità placeholder |
| **Prerequisiti precisi**: alcune tecnologie richiedono una tecnologia specifica, anche di un altro ramo (una freccia nell’albero) | Proposta |
| L’albero è **tutto visibile**; ogni tecnologia mostra i prerequisiti che le mancano (P4) | Proposta |
| Dimensione del prototipo: per era e per ramo, 2 tecnologie alla prima altezza e 1 alla seconda, cioè **12 tecnologie per era** (36 in tutto), più quelle esclusive delle vie e delle razze | Proposta; placeholder |
| Le tecnologie esclusive di una via o di una razza stanno nel ramo della loro sfera e compaiono nella mano solo per chi ha quella via o razza (radice “richiede”). Proposta per il prototipo: 1 per via e 1 per razza in ogni era | Confermato (decisione 22); quantità Proposta |

### 2.3 La mano di carte

| Regola | Stato |
|---|---|
| La mano ha **3 carte** (decisione 2) | Confermato |
| Si pesca fra le tecnologie **disponibili**: prerequisiti completati, era non futura, non ancora completate | Proposta |
| “Stessa altezza o simili”: si pesca solo fra le tecnologie disponibili dell’**altezza più bassa** ancora aperta e di quella **subito sopra** | Proposta |
| **Peso** di ogni tecnologia: base 1, +1 per ogni sua **radice** “favorita da” che la nazione possiede. Le radici sono quelle degli eventi (§4.2.5): identità, vie, era, tipi sulla plancia, stato della nazione. Una radice “richiede” la fa comparire solo se la nazione ce l’ha | Proposta |
| **Sconto sulla carta scartata** (decisione 19): una carta mostrata e non scelta ha il peso dimezzato nella mano successiva | Confermato nella forma; dettaglio Proposta |
| Lo sconto si accumula a ogni scarto (1/2, 1/4…), con un minimo, e si azzera quando la tecnologia viene scelta | Proposta; placeholder |
| Una nuova mano si pesca **ogni volta che si completa una tecnologia** | Proposta (come in Stellaris) |
| Le tecnologie **iniziate e non finite** compaiono sempre, in più rispetto alle 3 carte, finché non sono completate (come in Stellaris) | Proposta |
| La pescata usa il seme della run (§16.3) | Convenzione tecnica |

### 2.4 Il passaggio d’era

| Regola | Stato |
|---|---|
| Per entrare nell’era successiva servono **N tecnologie dell’era corrente** (decisione 8) | Confermato nella forma; “dell’era corrente” è Proposta |
| Valori di prova: 4 tecnologie dell’era 1 per l’era 2; 5 tecnologie dell’era 2 per l’era 3 | Placeholder |
| Raggiunto il numero, il giocatore entra quando vuole, in entrambe le metà, senza consumare il round (decisione 9, come §10.3) | Confermato |
| Il resto non cambia (§10.2): spazi, quota di Resistenza, scelta della via, salita di livello del Consiglio, eventuale evoluzione del governo (§9.4.2), offerte della nuova era | Confermato (regole esistenti) |
| Entrando nell’era, la mano si ripesca gratis, perché si aprono le tecnologie della nuova era | Proposta |

### 2.5 Che cosa si ricerca

Tutti gli effetti usano il linguaggio del nucleo (P5).

| Famiglia | Esempio (placeholder) | Come si esprime |
|---|---|---|
| **Linea di elementi** | Sblocca una nuova linea di truppe Fante | Modificatore permanente sulle offerte (§8.2): l’elemento entra fra le proposte (§2.6) |
| **Perk** | Un perk come quelli dell’Anziano | Perk (§9.3), cioè un modificatore permanente |
| **Consiglio** | Una proposta in più da un consigliere; rinnovo meno caro; Potenzia meno caro per una categoria | Modificatore permanente sulle offerte o sui costi (§9.2 elenca già questi effetti per l’identità) |
| **Nazione** | Uno spazio edificio o truppa; +1 di una risorsa prodotta dalla Capitale | Modificatore permanente sugli spazi o sulla produzione |
| **Dottrina sui tipi** | “Le truppe Fante ricaricano il 10% più in fretta”; “chi cura cura 1 in più” | Modificatore permanente sui valori di battaglia (§16.3, ordine dei calcoli) |

| Regola | Stato |
|---|---|
| Ogni tecnologia ha un **solo effetto principale**, facile da leggere sulla carta | Proposta |
| Gli effetti più forti stanno nelle altezze alte e nelle ere avanzate (P2a) | Proposta |

### 2.6 Le linee di elementi

| Regola | Stato |
|---|---|
| Una **linea** è una serie di elementi, uno per era, con lo stesso ruolo (decisione 13). Per esempio una linea di tiratori fatta come Frombolieri (era 1), Balestrieri (era 2) e Moschettieri (era 3) | Confermato nella forma |
| La tecnologia sblocca la **linea**, non un singolo elemento: in ogni era fa comparire fra le proposte la versione dell’era corrente | Confermato |
| Se una linea non ha una versione per l’era corrente, resta disponibile l’**ultima versione** precedente | Confermato |
| Gli elementi di una linea entrano nelle proposte dei consiglieri secondo i loro **tipi**, come ogni altra carta (§4.2.4). Il Clown li può proporre | Proposta |
| Gli elementi delle linee **non** sono nel catalogo base dell’era: si ottengono solo con la tecnologia (o come ricompensa) | Proposta |
| È un’**eccezione** alla regola “le offerte delle ere precedenti spariscono” (§10.2, §10.3), solo per la versione che resta quando manca quella dell’era nuova | Confermato (decisione 13) |

### 2.7 Carte dorate

| Regola | Stato |
|---|---|
| Un’opzione di un Evento, una Fortuna o la ricompensa di un incontro del mondo possono dare una **tecnologia già iniziata** (decisione 18) | Confermato |
| La carta dorata ha già una parte del costo pagata (placeholder: metà) e compare **sempre** nella mano, in più rispetto alle 3 carte, finché non è completata | Proposta |
| Può essere anche una tecnologia che la nazione non potrebbe ancora pescare (altezza più alta, ma mai di un’era futura) | Proposta |
| Le ricompense degli incontri del mondo (§3.3: edifici, truppe, perk o risorse) si ampliano con le **tecnologie** | Confermato (decisione 18); modifica del nucleo |

### 2.8 Lo Studioso

| Regola | Stato |
|---|---|
| Studiosi, Archivisti e Trattati restano: la Ricerca che danno va nella tecnologia in corso | Confermato (decisione 15) |
| Azione nuova, **Revisione dei piani** (nome placeholder): ripesca la mano. Si paga in Documenti (placeholder: 2) | Confermato nella forma; nome e costo Proposta |

### 2.9 Progetti speciali — Direzione

Alcune tecnologie (i “progetti speciali”) possono chiedere, oltre alla Ricerca, una risorsa di categoria (decisione 17). La maggior parte delle tecnologie costa solo Ricerca.

Non entrano nel primo prototipo (decisione 23).

**Da definire:** quali tecnologie sono progetti speciali, se sono più forti delle altre, quando si paga la risorsa. Proposta: un progetto speciale per ramo e per era, con la risorsa pagata quando lo si inizia.

---

## 3. Interfaccia (P4)

| Regola | Stato |
|---|---|
| Sempre visibili: la tecnologia in corso, la Ricerca già raccolta su quella da raccogliere, la Ricerca prevista alla prossima produzione | Proposta |
| Visibili anche il numero di tecnologie per la prossima era e un pulsante per entrare quando si può | Proposta |
| Una schermata dell’albero con i 4 rami, le tecnologie completate, iniziate e bloccate, e il motivo del blocco | Proposta |
| La mano di carte si apre da un pulsante sulla plancia, senza consumare il round | Proposta |

---

## 4. Fantasmi

| Regola | Stato |
|---|---|
| Un fantasma salvato registra già le statistiche complete delle carte (§11.4): le tecnologie che cambiano i valori di battaglia vanno salvate fra i suoi modificatori attivi | Proposta tecnica |
| I fantasmi generati ricevono a caso, con il seme della run, il numero di tecnologie richiesto per ogni era raggiunta (decisione 20); valgono solo quelle che agiscono in battaglia | Convenzione provvisoria |

---

## 5. Che cosa cambia nel GDD

| Sezione | Modifica |
|---|---|
| §3.3 Incontri | Le ricompense possono essere anche tecnologie (carte dorate) |
| §4.2.3 Consiglio | Tolto il Mercante; il Tesoriere paga le azioni in Influenza; lo Studioso ha l’azione Revisione dei piani |
| §5.3 Risorse | Ricerca: “tecnologie (e quindi ere)”; non sta nel Magazzino e non si vende al mercato |
| §10 Ricerca ed ere | Riscritta con le regole di questa bozza: tolte “la Ricerca si conserva e viene spesa” e “struttura lineare” |
| §14.3 Informazioni | Ricerca: tecnologia in corso, avanzamento, tecnologie per la prossima era |
| §15.2 Prototipo | “Ricerca spendibile per avanzare di era” diventa “albero delle tecnologie” |
| §16.3 Convenzioni | Valori di prova (costi, numero di tecnologie per era, sconto, carta dorata a metà, costo di Revisione dei piani); tecnologie dei fantasmi generati |
| §17 Verifica | Nuovi casi: Ricerca nella tecnologia in corso; avanzo che passa alla successiva; progressi conservati; mano di 3 carte; sconto sulla carta scartata; era con N tecnologie; linea senza versione nell’era nuova; carta dorata |
| §18 Decisioni | “Prima di ampliare la ricerca”: catalogo delle tecnologie, progetti speciali |
| §19 Glossario | Tecnologia, Mano, Linea, Carta dorata, Altezza |
| Catalogo | Nuova sezione con l’albero del prototipo e le linee |

---

## 6. Domande risolte

1. **Costi:** 3 Ricerca per la prima altezza, 4 per la seconda (decisione 21). Con Capitale e una Biblioteca (1 + 1 Ricerca per fase, cioè 4 all’anno) più il bottino (2 dal fantasma, 1-3 dall’incontro) arrivano circa 6-8 Ricerca all’anno: circa 2 tecnologie all’anno all’inizio, e l’era 2 (4 tecnologie) verso il secondo o terzo anno. Oggi l’era 2 costa 8 Ricerca, quindi il ritmo resta simile.
2. **Razze:** sì, hanno tecnologie esclusive (decisione 22).
3. **Progetti speciali:** dopo il primo prototipo (decisione 23).
