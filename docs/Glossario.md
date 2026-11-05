# ULTRALOPOLIS — Glossario

**Versione:** bozza 1 — 5 novembre 2026
**Riferimento:** Game Design Document v0.24 (`docs/Ultralopolis_GDD.md`)
**Stato:** **bozza da approvare.** Raccoglie i termini del GDD, del Catalogo e dei testi del gioco. Dove la stessa cosa ha più nomi (o lo stesso nome indica più cose), c'è una proposta di Claude da decidere con Davide (Parte 1).

Il glossario decide **come si chiamano le cose**, non come funzionano: per le regole vale il GDD. Sostituisce il vecchio glossario del GDD (§19).

---

## Come si legge

Ogni voce ha tre colonne:

| Colonna | Che cosa contiene |
|---|---|
| **Nome** | Il nome ufficiale: quello da usare nel gioco, nel GDD e nel Catalogo. |
| **Per il giocatore** | Una frase semplice, pronta da usare nel gioco (aiuti, descrizioni, manuale). |
| **Per noi** | Sezione del GDD, nomi da non usare più, avvertenze. |

Stato del nome, indicato in fondo alla colonna “Per noi”:

| Stato | Significato |
|---|---|
| **Deciso** | Il nome è confermato nel GDD o non ha alternative in uso. |
| **Provvisorio** | Il GDD dice che è un nome placeholder: può cambiare quando si vuole. |
| **Da decidere (A1…)** | Ci sono nomi doppi. Il codice rimanda alla Parte 1, dove c'è la proposta. |

**Proposta:** nel codice i nomi tecnici interni (es. `cooldown`, `opportunities`) possono restare come sono; conta ciò che leggono il giocatore e chi lavora sul design. Se un nome cambia, si cambiano i testi del gioco, non per forza i file del codice.

---

# PARTE 1 — NOMI DA DECIDERE

Per ogni riga Davide può accettare la proposta, scegliere un'alternativa o proporne un'altra. Dopo la decisione la riga esce da qui e il nome diventa **Deciso** nella Parte 2.

## A. La stessa cosa con più nomi

| # | Concetto | Nomi in uso oggi | Proposta | Perché |
|---|---|---|---|---|
| A1 | Attesa fra due attivazioni di una truppa | *cooldown* (GDD §7.2, §17); *ricarica* (GDD §5.4, §7.7, gioco, Catalogo) | **Ricarica** | È italiano e il gioco lo usa già. *Cooldown* resta solo nel codice. |
| A2 | Tempo fra due produzioni di un edificio nello scontro | *intervallo* (GDD §7.4); *ritmo* (GDD §7.4); nel gioco “ogni X s” | **Intervallo** | Un edificio non si “ricarica”: produce a tempo. Tenerlo distinto dalla ricarica aiuta a leggere le descrizioni. Al giocatore basta “ogni X s”. |
| A3 | Effetto che rallenta il timer | *Inefficienza* (GDD §7.7, §8.3, nome confermato nella v0.14); *rallentato*, *Rallenta il fantasma* (gioco) | **Inefficienza**; sulla carta colpita la scritta **“Inefficiente”** | Il GDD ha già scelto il nome. Oggi il giocatore legge quasi sempre “rallentato”; “Inefficienza” compare solo in qualche descrizione e come nome di un malus (B3). **Alternativa:** tornare a *Rallentamento* ovunque, più immediato ma cambia un nome confermato. |
| A4 | La dimensione dell'identità “chi sei” | *razza* (GDD §7.1.1, §9, §9.4.1); *popolo* (GDD §9.1, §9.4, gioco) | **Popolo** | Il gioco usa già “Popolo”. *Razza* resta solo nelle note di design (“popolo = razza fantasy”). |
| A5 | Le due parti dell'anno | *metà*, *macrofase* (GDD §19), *fase* (GDD §5.2, gioco) | **Fase** (fase di Produzione, fase di Preparazione) | *Macrofase* è tecnico; *metà* va bene nel parlato. I due nomi, Produzione e Preparazione, sono ancora rivedibili (GDD §3.2). Vedi anche B1. |
| A6 | Edifici e truppe | *elemento* (GDD), *carta* (GDD dalla v0.22, gioco), *pezzo* (GDD §14.2, grafica) | **Carta** | Sulla plancia sono disegnati come carte (direzione artistica). *Elemento* resta per le regole generali (“un elemento si può vendere”), *pezzo* solo per la grafica. Vedi anche B2. |
| A7 | Ciò che offre un consigliere | *proposta* (GDD §4.2, gioco); *offerta* (GDD §10, §14.3, malus “Mercati diffidenti”); *opportunità* (vecchio sistema, ancora nel codice, nei dati e nella direzione artistica) | **Proposta** | È il nome del Consiglio. *Opportunità* va ritirato; *offerte dell'era* diventa “carte dell'era”. |
| A8 | Il combattimento | *scontro*, *battaglia*, *combattimento* (tutti nel GDD); gioco: “Scontro con il fantasma”, “In battaglia” | **Scontro** | Un nome solo per il giocatore: “Scontro con il fantasma”, “nello scontro”. *Battaglia* e *combattimento* restano solo nei documenti tecnici. |
| A9 | Una partita completa | *run* (GDD), *partita* (gioco: “Nuova partita”), *campagna* (GDD §3.1) | **Partita** per il giocatore; *run* va bene fra noi | Il gioco è in italiano. *Campagna* da non usare. |
| A10 | Il valore che toglie solo scudo | *attacco d'assedio* (GDD §7.6.4, §8.3); *danno agli scudi* (GDD §6.5, §7.6.5, Catalogo); nel gioco “Assedio: toglie N scudo” | **Danno d'assedio** | Unisce i due nomi: dice che è un danno e che è dell'Assedio. Si distingue dal **tipo** Assedio. |
| A11 | Il popolo del giocatore | *nazione*, *civiltà* (GDD §1, §9) | **Nazione** | Il gioco dice già “Crea nazione”. *Civiltà* solo come parola descrittiva nel GDD. |
| A12 | Chi sta dall'altra parte nello scontro | *avversario* (GDD, gioco), *nemico* (alcune descrizioni dei dati) | **Avversario** | Vale sia per il fantasma sia per la plancia di un incontro. |
| A13 | Effetti che durano fuori dallo scontro | *modificatore* (GDD §8), *effetto attivo* (gioco: “EFFETTI ATTIVI”), *malus*, *bonus*, *conseguenza* (GDD §13) | Per il giocatore: **effetti attivi**, divisi in **malus** e **bonus**. *Modificatore* e *conseguenza* solo fra noi | Il giocatore non ha bisogno di sapere che malus e bonus sono lo stesso meccanismo. |

## B. Lo stesso nome per più cose

| # | Nome | Che cosa indica oggi | Proposta |
|---|---|---|---|
| B1 | **Produzione** | (1) la prima fase dell'anno; (2) le risorse e il mana che un edificio produce; (3) un **tipo** di carta (GDD §6.6) | Rinominare il tipo in **Materie prime**, che è proprio la sua definizione nel GDD (“edifici che producono materie prime”). **Alternativa:** rinominare la fase (es. *Crescita*; *Sviluppo* no, è già il nome dell'era 2). |
| B2 | **Carta** | (1) edifici e truppe; (2) ciò che compare in un round: consiglieri, Eventi, Visitatori, Fortune (“carte del round”, “carta speciale”) | *Carta* solo per edifici e truppe. Eventi, Visitatori e Fortune insieme si chiamano **Avvenimenti**; i consiglieri sono “consiglieri”. **Alternativa:** tenere “carte speciali”. |
| B3 | **Inefficienza** | (1) l'effetto di battaglia che rallenta (GDD §7.7); (2) un malus dei fantasmi (GDD §8.2.1, dati) | Rinominare il malus, per esempio **Lavori a rilento**, come gli altri malus con nomi a tema (*Mura incrinate*, *Scorte avariate*). |
| B4 | **Categoria** | (1) il campo di un consigliere (GDD §4.2.4); (2) la “categoria di bersaglio” di Inefficienza e Sabotaggio (GDD §7.7.1) | Il secondo diventa **bersagli ammessi** (solo truppe, solo edifici, qualsiasi). |
| B5 | **Livello** | (1) il livello di una carta, da 1 a 3 (GDD §6.5); (2) il livello del Consiglio, legato all'era (GDD §4.2.1) | Il giocatore vede “Livello” solo sulle carte. Il Consiglio mostra i nomi dei suoi livelli (Funzionari, Ministri, Gran Consiglieri) invece di un numero. |
| B6 | **Evento** | (1) la carta del round con testo e opzioni (GDD §4.2.5); (2) “eventi” in generale, compresi gli incontri del mondo (GDD §3.3, §13) | Per il giocatore *Evento* è solo la carta del round. Fra noi, per il senso generale, “avvenimento” o “conseguenza”. |
| B7 | **Mercante / Mercanti** | (1) un'azione del Tesoriere (Mercante: Ricerca in Oro); (2) il visitatore *Mercanti del delta*; (3) il malus *Mercanti in fuga* | Rinominare l'azione, per esempio **Vendita del sapere**, così “mercanti” resta ai personaggi. Bassa priorità. |
| B8 | **Fede** | (1) una risorsa; (2) la categoria del Sacerdote | **Nessun cambio proposto**: è voluto (la risorsa della categoria Fede è la Fede). Lo segnalo solo perché nelle descrizioni va scritto chiaro quale dei due si intende. |

## C. Parole inglesi in un gioco in italiano

L'interfaccia è in italiano (GDD §14.3). Queste parole oggi compaiono al giocatore o compariranno.

| # | Parola | Dove | Proposta |
|---|---|---|---|
| C1 | **Round** | GDD, gioco (“Passa il round”) | **Tenere Round**: è breve e chi gioca agli auto-battler lo conosce. **Alternativa a tema:** *Seduta* (del Consiglio). |
| C2 | **Perk** | GDD §9.3, gioco | **Talento**. **Alternativa:** tenere *Perk*, che i giocatori di The Bazaar conoscono. |
| C3 | **Tier** (del governo) | GDD §9.4.2 | **Rango** (“governo di rango 2”). |
| C4 | **Clown** | GDD §4.2.2 (nome placeholder) | **Giullare**, più adatto a un consiglio di corte. |
| C5 | **Cooldown**, **run** | GDD | Vedi A1 e A9. |

---

# PARTE 2 — GLOSSARIO

Le voci usano già i nomi proposti nella Parte 1; il codice fra parentesi indica la decisione da prendere.

## La partita

| Nome | Per il giocatore | Per noi |
|---|---|---|
| **Partita** | La storia completa della tua nazione: dura finché ottieni 10 vittorie o perdi durante l'ultima possibilità. | GDD §3.1, §3.4. Fra noi anche *run*; non usare *campagna*. Da decidere (A9). |
| **Anno** | Ogni anno ha una fase di Produzione, un incontro del mondo, una fase di Preparazione e lo scontro con il fantasma. | GDD §3.2, §4.1. Deciso. |
| **Fase** | Metà dell'anno. All'inizio di ogni fase i tuoi edifici producono risorse; poi seguono 5 round. | GDD §3.2, §5.2. Non usare *macrofase*. Da decidere (A5). |
| **Produzione** | La prima fase dell'anno. | GDD §3.2. Nome rivedibile. Provvisorio; vedi B1. |
| **Preparazione** | La seconda fase dell'anno, prima dello scontro con il fantasma. | GDD §3.2. Nome rivedibile. Provvisorio. |
| **Round** | Un momento di scelta: ascolti un consigliere (o un avvenimento) e prendi una sua proposta, oppure passi. | GDD §4.2. Da decidere (C1). |
| **Tema del round** | Dice che cosa propongono i consiglieri in questo round: Azioni, Edifici, Truppe o Misto. | GDD §4.2. Prima era il “tipo del round”: non usare. Deciso. |
| **Passare** | Chiudere il round senza prendere nulla. | GDD §4.2. Deciso. |
| **Vittoria** | Vinci lo scontro con il fantasma: aggiungi una vittoria e ricevi un bottino. Con 10 vittorie vinci la partita. | GDD §3.4. Deciso. |
| **Sconfitta** | Perdi lo scontro con il fantasma: perdi tanto Prestigio quanto il numero dell'anno. | GDD §3.4. Deciso. |
| **Pareggio** | Le due nazioni cadono nello stesso istante. Conta come vittoria, ma subisci i malus del fantasma. | GDD §3.4. Deciso. |
| **Prestigio** | Quanto la tua nazione può ancora permettersi di perdere. Si parte da 20; ogni sconfitta lo fa scendere. | GDD §3.4. È separato dalla Resistenza. Deciso. |
| **Ultima possibilità** | Quando il Prestigio finisce per la prima volta, la partita continua; la prossima sconfitta la chiude. | GDD §3.4. Anche perdere un incontro del mondo la chiude (§3.3); un pareggio no. Deciso. |
| **Bottino** | Oro e Ricerca che ricevi sempre quando vinci (o pareggi) uno scontro. | GDD §3.3, §3.4. Diverso dalla ricompensa. Deciso. |
| **Ricompensa** | Dopo un incontro del mondo vinto, una carta, un talento o delle risorse da scegliere; puoi anche non prendere nulla. | GDD §3.3. Deciso. |
| **Cronaca** | Il diario di ciò che è successo nella partita. | Nome usato solo nell'interfaccia; non è nel GDD. Deciso. |

## La nazione e l'identità

| Nome | Per il giocatore | Per noi |
|---|---|---|
| **Nazione** | Il tuo popolo, con nome e identità. La crei prima di giocare e resta salvata: puoi usarla per più partite. | GDD §9.1. Non usare *civiltà* nel gioco. Da decidere (A11). |
| **Identità** | Ciò che rende unica la tua nazione: popolo, governo, credo, cultura e talenti, più le vie scelte durante la partita. | GDD §9. Deciso. |
| **Elemento dell'identità** | Ognuna delle scelte che formano l'identità (un popolo, un governo, un credo, una cultura). | GDD §9.2. Parola soprattutto per noi. Deciso. |
| **Popolo** | Chi sei: dà Resistenza, carte esclusive in ogni era, un tratto e un tipo. | GDD §9.4. Nel design: “razza fantasy”. Popoli del prototipo: Pietrosangue, Maremani, Cinerali (Provvisori). Da decidere (A4). |
| **Governo** | Come decidi: cambia il modo in cui funziona il Consiglio. Può evolvere o cambiare con una rivoluzione. | GDD §9.4.2. Deciso. |
| **Rango** (del governo) | Quanto è evoluto il tuo governo. Si parte dal rango 1. | GDD §9.4.2 (*tier*). Non dipende dall'era. Da decidere (C3). |
| **Evoluzione** | Il governo passa al rango successivo, scegliendo fra i rami possibili. Ti viene proposta entrando in una nuova era. | GDD §9.4.2. Deciso. |
| **Riforma** | Un evento che, pagando Influenza, fa evolvere il governo. | GDD §9.4.2. Deciso. |
| **Rivoluzione** | Quando il Malcontento raggiunge la soglia, il popolo cambia governo, anche verso un rango più basso. Poi il Malcontento si azzera. | GDD §5.5, §9.4.2. È l'unico evento che arriva da solo. Deciso. |
| **Credo** | La fede della tua nazione: aggiunge incanti esclusivi. | GDD §9.4.3. Credi del prototipo: Culto solare, Spiriti dei luoghi, Culto degli antenati, Culto del vuoto (Provvisori). Deciso. |
| **Cultura** | Come la tua nazione usa le risorse e tratta con i consiglieri. | GDD §9.4.3. Culture: mercantile, guerriera, erudita, artigiana (Provvisorie). Deciso. |
| **Talento** | Un bonus passivo. Alcuni si scelgono creando la nazione, altri si ottengono durante la partita. | GDD §9.3 (*perk*). Da decidere (C2). |
| **Tratto** | Un effetto che dura tutta la partita, dato dal popolo, dal governo, dal credo, dalla cultura o da una via. | GDD §9.2, §10.4 (*tratto permanente*). Deciso. |
| **Carta esclusiva** | Una carta che ti viene proposta solo grazie al tuo popolo, governo, credo, cultura o a una via. | GDD §9.2, §10.4. Anche *esclusivo*. Deciso. |
| **Tipo d'identità** | Il tipo che porta una carta esclusiva (es. Pietrosangue, Monarchico, Solare). Non decide quali consiglieri la propongono, ma conta per talenti ed eventi. | GDD §6.6. Deciso. |
| **Capitale** | Il cuore della nazione. Produce Oro, Cibo, Ricerca e una risorsa per ogni elemento dell'identità; nello scontro dà mana energetico. Non si vende e non si sostituisce. | GDD §6.2. Ha un tipo proprio, Capitale (Proposta). Deciso. |
| **Malcontento** | La pressione del popolo. Sale con sconfitte, carestie e malus; scende soprattutto spendendo Stabilità. Se raggiunge la soglia, scoppia la Rivoluzione. | GDD §5.5. È un contatore, non una risorsa da vendere. Deciso. |

## Il Consiglio

| Nome | Per il giocatore | Per noi |
|---|---|---|
| **Consiglio** | I consiglieri della tua nazione. In ogni round ne compaiono tre e ne ascolti uno. | GDD §4.2. Ha preso il posto delle *opportunità* (v0.21). Deciso. |
| **Consigliere** | Un membro del Consiglio con un suo campo: propone azioni, edifici e truppe, e può potenziare le tue carte. | GDD §4.2.3. Tesoriere, Fattore, Architetto, Generale, Studioso, Sacerdote, Cancelliere, Maestro delle spie (Provvisori). Il *Diplomatico* ora è il Cancelliere. Deciso. |
| **Consigliere speciale** | Un consigliere senza campo, che ignora il tema del round: il Giullare e l'Anziano. | GDD §4.2.2. Il gioco usa già “Consigliere speciale”. Deciso. |
| **Giullare** | Propone 5 carte, una per ogni colore di mana più un edificio neutro. Non potenzia. | GDD §4.2.2 (*Clown*). Da decidere (C4). |
| **Anziano** | Propone talenti ed edifici neutri; una volta all'anno può potenziare un edificio neutro. | GDD §4.2.2. Provvisorio. |
| **Livelli del Consiglio** | Il Consiglio cresce con le ere: Funzionari, poi Ministri, poi Gran Consiglieri. | GDD §4.2.1. Nomi Provvisori; vedi B5. |
| **Categoria** | Il campo di un consigliere: i tipi di carte di cui si occupa. | GDD §4.2.4. Militare, Opera, Terra, Ricchezza, Conoscenza, Fede, Stato, Ombra (Provvisori). Le carte non hanno categoria, solo tipi. Vedi B4. Deciso. |
| **Proposta** | Una delle tre cose che un consigliere ti offre: un'azione, un edificio o una truppa. Ne prendi una sola. | GDD §4.2. Non usare *offerta* né *opportunità*. Da decidere (A7). |
| **Azione** | Una proposta che non è una carta: un effetto subito o per un anno. Non costa Oro ma altre risorse. | GDD §4.2, §4.2.3. Deciso. |
| **Potenzia** | Fa salire di livello una tua carta che ha un tipo del consigliere. Non conta come scelta del round e si usa una volta per round. | GDD §6.5. Deciso. |
| **Rinnovo** | Paghi per vedere tre proposte nuove dallo stesso consigliere. Costa Oro o la risorsa del consigliere, ogni volta un po' di più. | GDD §4.2. Nel gioco: “Proposte rinnovate”. Deciso. |
| **Avvenimento** | Una carta che compare in un round al posto di un consigliere: un Evento, un Visitatore o una Fortuna. | GDD §4.2.5 (*carta speciale*). Da decidere (B2). |
| **Evento** | Una situazione con un testo e 2-3 opzioni. Alcune opzioni si sbloccano solo con certe caratteristiche della tua nazione. | GDD §4.2.5. Vedi B6. Deciso. |
| **Opzione** | Una delle risposte possibili a un evento. | GDD §4.2.5. Deciso. |
| **Requisito** | Ciò che serve per scegliere un'opzione. Un'opzione bloccata si vede comunque, spenta, con il requisito accanto. | GDD §4.2.5. Deciso. |
| **Visitatore** | Un personaggio di passaggio con le sue proposte e i suoi prezzi. | GDD §4.2.5. Nel gioco: “Di passaggio”. Deciso. |
| **Fortuna** | Un dono semplice. | GDD §4.2.5. Nel gioco: “Un dono”. Deciso. |
| **Sfera** | La categoria a cui appartiene un avvenimento: ne dà il tema e la cornice. | GDD §4.2.5. Soprattutto per noi. Deciso. |
| **Radici** | Ciò che fa comparire un avvenimento o lo rende più frequente (es. il tuo credo, una via, un tipo sulla plancia). | GDD §4.2.5. Solo per noi: il giocatore non lo vede. Deciso. |
| **Incanto** | Il Sacerdote aggiunge a una truppa un effetto in più nello scontro, con un costo di mana in più. Ogni truppa si incanta una volta sola. | GDD §4.3. Incanti comuni: Furia, Egida, Grazia, Maledizione, Torpore (Provvisori). Deciso. |
| **Spionaggio** | Le proposte del Maestro delle spie: lo scontro con il fantasma dell'anno inizia con un suo edificio o una sua truppa già sabotati o inefficienti. | GDD §12. Deciso. |

## Economia e risorse

| Nome | Per il giocatore | Per noi |
|---|---|---|
| **Magazzino** | Dove stanno tutte le tue risorse, senza limite. Resta di anno in anno. | GDD §5.3. Il mana non sta nel Magazzino. Deciso. |
| **Risorsa** | Ciò che gli edifici producono e che spendi per comprare, potenziare e pagare le azioni. | GDD §5.3. Deciso. |
| **Oro** | La moneta comune: compra carte e spazi e paga i rinnovi. | GDD §5.3. Deciso. |
| **Ricerca** | Serve a entrare in una nuova era. | GDD §5.3, §10. In futuro anche tecnologie. Deciso. |
| **Cibo** | Sfama le truppe all'inizio di ogni anno, dal secondo in poi. | GDD §5.4. Nel codice si conta in decimi. Deciso. |
| **Ferro, Pietra, Legno, Influenza, Fede, Stabilità, Documenti** | Le risorse dei consiglieri: servono per Potenzia, per i rinnovi e per alcune azioni. | GDD §5.3, §4.2.4. Ogni categoria ha la sua. La *Fauna* non è più una risorsa: è solo un tipo. Deciso. |
| **Mercato** | Vendi risorse in cambio di Oro, quando vuoi fuori dallo scontro. Non si possono comprare risorse. | GDD §5.3. Deciso. |
| **Mantenimento** | All'inizio di ogni anno, dal secondo, ogni truppa mangia la sua razione di Cibo. | GDD §5.4. Deciso. |
| **Affamata** | Una truppa rimasta senza Cibo: ricarica più lenta fino al pasto successivo. | GDD §5.4. Scritta già nel gioco. Deciso. |
| **Vendita** | Togli una carta dalla plancia e ti torna metà di quanto l'hai pagata. | GDD §6.4. Deciso. |
| **Sostituzione** | Vendi una carta e ne metti una nuova al suo posto. | GDD §6.4. Deciso. |
| **Dotazione iniziale** | Ciò con cui inizi la partita: Capitale, una truppa, un po' di Oro e spazi vuoti. | GDD §6.2. Le carte della dotazione non rimborsano nulla. Deciso. |

## La plancia e le carte

| Nome | Per il giocatore | Per noi |
|---|---|---|
| **Plancia** | Il tavolo della tua nazione: una fila di edifici e una fila di truppe. | GDD §6.1, §14.2. Deciso. |
| **Spazio** | Un posto per una carta. Si parte con 4 spazi edificio e 3 spazi truppa; se ne ottengono altri con le ere, con certi edifici e con l'Oro. | GDD §6.1, §6.3. Nel gioco: “LIBERO” e “DA CONQUISTARE”. Non usare *slot*. Deciso. |
| **Carta** | Un edificio o una truppa. | GDD *elemento*. *Pezzo* solo per la grafica. Da decidere (A6, B2). |
| **Edificio** | Fuori dallo scontro produce risorse; nello scontro produce mana, altri effetti o entrambi. | GDD §5.1. Deciso. |
| **Edificio neutro** | Un edificio che non produce mana e quindi non ha colore. | GDD §5.3. Deciso. |
| **Truppa** | Nello scontro si attiva quando la ricarica è finita e c'è il mana che chiede. | GDD §7.2. Deciso. |
| **Livello** | Una carta va dal livello 1 al 3; ogni livello rafforza tutti i suoi effetti. | GDD §6.5. Vedi B5. Deciso. |
| **Tipo** | Una caratteristica della carta (es. Fante, Guardiano, Spirituale). Decide quali consiglieri la propongono e la potenziano. | GDD §6.6. Ha sostituito le *etichette*. Elenco nel GDD §6.6 (Provvisorio). Vedi B1. Deciso. |
| **Ordine delle truppe** | Nello scontro le truppe agiscono da destra verso sinistra: la più a destra usa il mana per prima. Puoi riordinarle quando vuoi fuori dallo scontro. | GDD §7.3. Deciso. |

## Lo scontro

| Nome | Per il giocatore | Per noi |
|---|---|---|
| **Scontro** | La battaglia automatica fra la tua plancia e quella dell'avversario. | GDD §7. Non usare *combattimento*. Da decidere (A8). |
| **Avversario** | Chi affronti nello scontro: il fantasma dell'anno o la plancia di un incontro del mondo. | Non usare *nemico*. Da decidere (A12). |
| **Resistenza** | La vita della tua nazione nello scontro. Se arriva a zero, perdi. Si ricalcola all'inizio di ogni scontro. | GDD §7.1, §7.1.1. Non sono punti vita delle carte. Deciso. |
| **Mana** | L'energia che gli edifici producono nello scontro e che le truppe spendono per attivarsi. Si azzera a fine scontro. | GDD §5.3, §7.4. Deciso. |
| **Colori del mana** | Rosso, verde, blu, viola, più l'energetico. Una truppa paga con il suo colore. | GDD §5.3. *Viola* è un nome placeholder. La direzione artistica non ha ancora il viola: va aggiornata. Deciso. |
| **Mana energetico** | Vale come mana di qualsiasi colore. Lo produce la Capitale. | GDD §5.3. Deciso. |
| **Ricarica** | Il tempo che una truppa aspetta fra un'attivazione e la successiva. | GDD *cooldown*. Da decidere (A1). |
| **Intervallo** | Ogni quanto un edificio produce nello scontro. | GDD §7.4. Da decidere (A2). |
| **In attesa** | La truppa è pronta ma non c'è abbastanza mana: aspetta senza perdere nulla. | GDD §7.2, §7.3. Il motivo dell'attesa deve sempre vedersi (P4). Deciso. |
| **Danno** | Toglie Resistenza all'avversario, ma prima consuma il suo scudo. | GDD §7.6, §8.3. Deciso. |
| **Scudo** | Una riserva che assorbe il danno prima della Resistenza. Resta finché non viene consumata. | GDD §7.6.1. Deciso. |
| **Cura** | Ridà Resistenza persa, mai oltre il massimo. | GDD §7.6.2. Deciso. |
| **Corruzione** | Sale durante lo scontro e non scende mai. Quando raggiunge la tua Resistenza, perdi. Lo scudo non la ferma. | GDD §7.6.3. Ha sostituito il *veleno*. Deciso. |
| **Danno d'assedio** | Toglie solo scudo all'avversario, prima del danno normale. Ce l'hanno solo le truppe Assedio. | GDD *attacco d'assedio*, *danno agli scudi*. Da decidere (A10). |
| **Inefficienza** | Per qualche secondo il timer della carta colpita va a metà velocità. | GDD §7.7. Sulla carta: “Inefficiente”. Da decidere (A3). |
| **Sabotaggio** | Per qualche secondo la carta colpita è ferma e non può attivarsi. | GDD §7.7. Sulla carta: “Sabotato”. Deciso. |
| **Logoramento** | Dopo 45 secondi entrambe le nazioni perdono Resistenza, sempre di più, finché lo scontro finisce. | GDD §7.5. Lo scudo lo assorbe. Deciso. |
| **Istante** | Un passo dello scontro. Nello stesso istante prima si produce mana, poi agiscono le truppe. | GDD §7.6.6. Nel codice dura 100 ms (*tick*). Parola soprattutto per noi. Deciso. |

## Ere e vie

| Nome | Per il giocatore | Per noi |
|---|---|---|
| **Era** | Un'epoca della tua nazione. Ci entri spendendo Ricerca: porta carte nuove, spazi in più e più Resistenza. | GDD §10. Ere del prototipo: Fondazione, Sviluppo, Ascesa (Provvisori). Deciso. |
| **Via** | Dalla seconda era, entrando in un'era scegli fra tre direzioni di sviluppo. La via diventa parte della tua identità. | GDD §10.4. Es. Via del Commercio, Via della Guerra (Provvisori). Deciso. |
| **Bonus immediato** | Ciò che una via ti dà subito, appena la scegli. | GDD §10.4. Deciso. |

## Fantasmi e incontri

| Nome | Per il giocatore | Per noi |
|---|---|---|
| **Fantasma** | La copia registrata della nazione di un altro giocatore: è l'avversario di fine anno. | GDD §11. Può lasciarti dei malus. Deciso. |
| **Incontro del mondo** | Una minaccia a metà anno, come barbari o pirati. Ne scegli uno fra tre e affronti la sua plancia. Se perdi, il tuo Oro si dimezza. | GDD §3.3. Gli incontri hanno difficoltà facile, media e difficile. Deciso. |
| **Plancia generata** | La plancia avversaria di un incontro del mondo, creata dal gioco. | GDD §3.3. Soprattutto per noi. Deciso. |

## Effetti che durano

| Nome | Per il giocatore | Per noi |
|---|---|---|
| **Effetti attivi** | Tutto ciò che in questo momento modifica la tua nazione, con la durata che resta. | Nel gioco: “EFFETTI ATTIVI”. Da decidere (A13). |
| **Malus** | Un effetto negativo che dura per un certo numero di anni. Non ti rovina: ti spinge a giocare in modo diverso. | GDD §8.2.1, principio P1. Deciso. |
| **Bonus** | Un effetto positivo che dura per un certo tempo. | GDD §8.2.1. Deciso. |
| **Origine** | Chi ti ha dato l'effetto, per esempio il nome del fantasma. | GDD §8.2. Deciso. |

---

# PARTE 3 — PAROLE DEL PROGETTO (SOLO PER NOI)

Termini del lavoro di design e del codice. Il giocatore non li vede.

| Nome | Significato | Riferimento |
|---|---|---|
| **Nucleo** | Le regole su cui si appoggia tutto il resto (Parte I del GDD). Cambiarle è una “modifica del nucleo”. | GDD §0.1 |
| **Stati delle indicazioni** | Confermato, Direzione, Proposta, Da definire, Spunto. | GDD §0.2 |
| **Spunto** | Idea per il futuro, annotata ma volutamente non introdotta. | GDD Parte III |
| **Placeholder** | Nome o numero provvisorio, che serve solo a provare le regole. | GDD §0.3 |
| **Convenzione provvisoria** | Regola temporanea che fa funzionare il codice finché manca una decisione. | GDD §16.3 |
| **Principi P1–P5** | Le regole di fondo del design (es. P1: i malus deviano, non debilitano; P4: lo scontro si spiega da solo). | GDD §2 |
| **Modificatore** | Il meccanismo unico dietro malus, bonus, tratti e incanti: bersaglio, effetto, durata, origine, cumulabilità. | GDD §8.2 |
| **Conseguenza** | Un cambiamento della partita che resta dopo un evento o uno scontro. | GDD §13.2 |
| **Famiglia di effetti** | Danno, danno d'assedio, scudo, cura, Corruzione, Inefficienza, Sabotaggio. Una famiglia nuova è una modifica del nucleo. | GDD §8.3, P5 |
| **Elemento** | Parola generale delle regole per “carta” (edificio o truppa). | Vedi A6 |
| **Catalogo** | L'elenco di tutti i contenuti (carte, consiglieri, vie, eventi…) con i loro valori. | `docs/Catalogo.md`, `data/catalog/` |
| **Budget** | Il valore in punti di una carta, usato per bilanciare il catalogo. | Catalogo §1 |
| **Seme** | Il numero che decide la casualità: lo stesso seme dà sempre la stessa partita o lo stesso scontro. | GDD §7.5 |
| **Tick** | Il passo fisso della simulazione (100 ms). Per il giocatore è l'*istante*. | GDD §16.3 |
| **Simulazione / presentazione** | Le regole pure (simulazione) e ciò che si vede sullo schermo (presentazione), tenute separate. | GDD §16.2 |

---

## Nomi ritirati

Non vanno più usati nel gioco né nei documenti nuovi.

| Nome vecchio | Ora si dice | Da quando |
|---|---|---|
| Opportunità | Proposta del Consiglio | GDD v0.21 |
| Etichetta | Tipo | GDD v0.22 |
| Tipo del round | Tema del round | GDD v0.22 |
| Diplomatico | Cancelliere | GDD v0.22 |
| Fauna (come risorsa) | Resta solo come tipo | GDD v0.22 |
| Tiratori, Cavalleria (etichette) | Non esistono più | GDD v0.22 |
| Veleno | Corruzione | GDD v0.13 |
| Distruggi | Sabotaggio | GDD v0.14 |
| Montanari, Popolo del delta, Popolo delle foreste | Pietrosangue, Maremani, Cinerali | GDD v0.24 |
| Ordine della Ragione (credo) | Cultura erudita | GDD v0.24 |
