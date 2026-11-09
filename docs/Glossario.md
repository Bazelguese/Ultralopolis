# ULTRALOPOLIS — Glossario

**Versione:** 2 — 8 novembre 2026
**Riferimento:** Game Design Document v0.31 (`docs/Ultralopolis_GDD.md`)
**Stato:** **approvato da Davide l'8 novembre 2026.** Raccoglie i termini del GDD, del Catalogo e dei testi del gioco; tutti i nomi doppi sono stati decisi (registro in fondo). I nomi segnati **Provvisorio** restano placeholder e possono cambiare. Il GDD (dalla v0.31), il Catalogo, la direzione artistica e i testi del gioco usano i nomi decisi.

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
| **Deciso** | Il nome è confermato nel GDD o deciso da Davide in questo glossario. |
| **Provvisorio** | Il GDD dice che è un nome placeholder: può cambiare quando si vuole. |
| **Da decidere** | Ci sono nomi doppi: la questione è nella Parte 1, con una proposta. |

Nel codice i nomi tecnici interni (nomi di variabili, classi, cartelle come `opportunities/` o `perk/`) possono restare come sono; conta ciò che leggono il giocatore e chi lavora sul design. Se un nome cambia, si cambiano i testi del gioco, non per forza i file del codice.

---

# PARTE 1 — NOMI DA DECIDERE

| Questione | Proposta | Alternative | Dettagli |
|---|---|---|---|
| **Nomi dei quattro popoli** (Davide ha deciso l'8 novembre 2026 che Insettoidi, Acquatici, Uccelli antropomorfi e Bio-macchine sostituiscono Pietrosangue, Maremani e Cinerali, con nomi nuovi) | **Chitinari** (tipo Chitinaro) · **Salmastri** (Salmastro) · **Altivoli** (Altivolo) · **Innestati** (Innestato) | Alveani, Ronzanti · Squamari, Perlacei · Rostrati, Piumanti · Cuorlegno, Germoglianti | `docs/Bozza_popoli.md` §2. Una volta decisi, Pietrosangue, Maremani e Cinerali passano fra i nomi ritirati |

Le altre questioni sono state decise l'8 novembre 2026 (vedi il registro in fondo).

Quando un nome nuovo ha un doppione, o lo stesso nome finisce per indicare due cose, la questione si scrive qui con una proposta. Davide decide, la riga esce da qui, il nome diventa **Deciso** nella Parte 2 e la decisione entra nel registro.

---

# PARTE 2 — GLOSSARIO

## La partita

| Nome | Per il giocatore | Per noi |
|---|---|---|
| **Partita** | La storia completa della tua nazione: dura finché ottieni 10 vittorie o perdi durante l'ultima possibilità. | GDD §3.1, §3.4. Fra noi anche *run*; non usare *campagna*. Deciso. |
| **Anno** | Dodici mesi in quattro stagioni: inverno, primavera, estate e autunno. L'anno finisce con lo scontro con il fantasma. | GDD §3.2. Deciso. |
| **Stagione** | Un quarto dell'anno, di 3 mesi. All'inizio di ogni stagione arriva una cronaca, poi i tuoi edifici producono risorse. | GDD §3.2, §5.2. Non usare *fase*, *metà*, *macrofase*. Deciso. |
| **Inverno** | La stagione della politica interna: non si combatte e gli edifici non producono Cibo. | GDD §3.2. Deciso. |
| **Primavera** | Finisce con un incontro del mondo. | GDD §3.2. Deciso. |
| **Estate** | Finisce con un secondo incontro del mondo. | GDD §3.2. Deciso. |
| **Autunno** | Finisce con lo scontro con il fantasma, che chiude l'anno. | GDD §3.2. Deciso. |
| **Mese** | Un round dell'anno: gennaio è il primo, dicembre l'ultimo. | GDD §3.2. Deciso. |
| **Round** | Un mese di scelte: ascolti un consigliere (o un avvenimento) e prendi una sua opportunità, oppure passi. | GDD §4.2. Deciso: resta *Round*. |
| **Tema del round** | Dice che cosa propongono i consiglieri in questo round: Azioni, Edifici, Truppe o Misto. Ogni stagione ha i suoi temi. | GDD §4.2. Prima era il “tipo del round”: non usare. Deciso. |
| **Passare** | Chiudere il round senza prendere nulla. | GDD §4.2. Deciso. |
| **Vittoria** | Vinci lo scontro con il fantasma: aggiungi una vittoria e ricevi un bottino. Con 10 vittorie vinci la partita. | GDD §3.4. Deciso. |
| **Sconfitta** | Perdi lo scontro con il fantasma: perdi tanto Prestigio quanto il numero dell'anno. | GDD §3.4. Deciso. |
| **Pareggio** | Le due nazioni cadono nello stesso istante. Conta come vittoria, ma subisci i malus del fantasma. | GDD §3.4. Deciso. |
| **Prestigio** | Quanto la tua nazione può ancora permettersi di perdere. Si parte da 20; ogni sconfitta contro il fantasma lo fa scendere. | GDD §3.4. È separato dalla Resistenza. Deciso. |
| **Ultima possibilità** | Quando il Prestigio finisce per la prima volta, la partita continua; la prossima sconfitta la chiude. | GDD §3.4. Anche perdere un incontro del mondo la chiude (§3.3); un pareggio no. Deciso. |
| **Bottino** | Oro e Ricerca che ricevi sempre quando vinci (o pareggi) uno scontro. | GDD §3.3, §3.4. Diverso dalla ricompensa. Deciso. |
| **Ricompensa** | Dopo un incontro del mondo vinto, una tessera, una peculiarità, delle risorse o una carta dorata da scegliere; puoi anche non prendere nulla. | GDD §3.3. Deciso. |
| **Annali** | Il pannello con la storia della tua nazione e tutto ciò che è successo nella partita. | GDD §9.6.1 (*pannello Cronaca*). Non chiamarlo *Cronaca*: la cronaca è la scena di inizio stagione. Deciso. |

## La nazione e l'identità

| Nome | Per il giocatore | Per noi |
|---|---|---|
| **Nazione** | Il tuo popolo, con nome e identità. La crei prima di giocare e resta salvata: puoi usarla per più partite. | GDD §9.1. Non usare *civiltà* nel gioco. Deciso. |
| **Identità** | Ciò che rende unica la tua nazione: popolo, governo, credo, cultura e peculiarità, più le vie scelte e le usanze prese durante la partita. | GDD §9, §9.6.3. Deciso. |
| **Elemento dell'identità** | Ognuna delle scelte che formano l'identità (un popolo, un governo, un credo, una cultura). | GDD §9.2. Parola soprattutto per noi. Deciso. |
| **Popolo** | Chi sei: dà Resistenza, tessere esclusive in ogni era, un tratto e un tipo. | GDD §9.4. Nel design: “razza fantasy”; non usare *razza* nel gioco. Popoli del prototipo: Pietrosangue, Maremani, Cinerali (Provvisori). Deciso. |
| **Governo** | Come decidi: cambia il modo in cui funziona il Consiglio. Può evolvere o cambiare con una rivoluzione. | GDD §9.4.2. Deciso. |
| **Rango** (del governo) | Quanto è evoluto il tuo governo. Si parte dal rango 1. | GDD §9.4.2 (*tier*). Non dipende dall'era. Deciso. |
| **Evoluzione** | Il governo passa al rango successivo, scegliendo fra i rami possibili. Ti viene proposta entrando in una nuova era. | GDD §9.4.2. Deciso. |
| **Riforma** | Un evento che, pagando Influenza, fa evolvere il governo. | GDD §9.4.2. Deciso. |
| **Rivoluzione** | Quando il Malcontento raggiunge la soglia, il popolo cambia governo, anche verso un rango più basso. Poi il Malcontento si azzera. | GDD §5.5, §9.4.2. Arriva da sola, come le cronache. Deciso. |
| **Credo** | La fede della tua nazione: aggiunge incanti esclusivi. | GDD §9.4.3. Credi del prototipo: Culto solare, Spiriti dei luoghi, Culto degli antenati, Culto del vuoto (Provvisori). Deciso. |
| **Cultura** | Come la tua nazione usa le risorse e tratta con i consiglieri. | GDD §9.4.3. Culture: mercantile, guerriera, erudita, artigiana (Provvisorie). Deciso. |
| **Peculiarità** | Un bonus passivo. Alcune si scelgono creando la nazione, altre si ottengono durante la partita. | GDD §9.3 (*perk*). Attenzione: è vicina a *Tratto*; nelle descrizioni vanno tenute distinte. Deciso. |
| **Tratto** | Un effetto che dura tutta la partita, dato dal popolo, dal governo, dal credo, dalla cultura o da una via. | GDD §9.2, §10.4 (*tratto permanente*). Deciso. |
| **Tessera esclusiva** | Una tessera che ti viene proposta solo grazie al tuo popolo, governo, credo, cultura o a una via. | GDD §9.2, §10.4. Anche *esclusiva*. Deciso. |
| **Tipo d'identità** | Il tipo che porta una tessera esclusiva (es. Pietrosangue, Monarchico, Solare). Non decide quali consiglieri la propongono, ma conta per peculiarità ed eventi. | GDD §6.6. Deciso. |
| **Capitale** | Il cuore della nazione. Produce Oro, Cibo, Ricerca e una risorsa per ogni elemento dell'identità; nello scontro dà mana energetico. Non si vende e non si sostituisce. | GDD §6.2. Ha un tipo proprio, Capitale (Proposta). Deciso. |
| **Malcontento** | La pressione del popolo. Sale con sconfitte, carestie, malus e tessere trascurate; scende soprattutto spendendo Stabilità. Se raggiunge la soglia, scoppia la Rivoluzione. | GDD §5.5, §5.6. È un contatore, non una risorsa da vendere. Deciso. |

## Le cronache della nazione

| Nome | Per il giocatore | Per noi |
|---|---|---|
| **Cronaca** | All'inizio di ogni stagione una scena racconta qualcosa che è successo alla tua nazione, e tu scegli come reagisce. | GDD §9.6.1. Non è il pannello con la storia (quello sono gli *Annali*). Deciso. |
| **Momento di cronaca** | Il nome della cronaca di ogni stagione: Solstizio d'inverno, Equinozio di primavera, Solstizio d'estate, Equinozio d'autunno. | GDD §9.6.1. Deciso. |
| **Reazione** | Uno dei 2-3 atteggiamenti fra cui scegli in una cronaca. Ce n'è sempre una gratuita. | GDD §9.6.1. Deciso. |
| **Inclinazione** | Una delle quattro tendenze della nazione fra due poli: Spada (Conquistatrice / Pacifica), Porta (Aperta / Chiusa), Altare (Devota / Profana), Legge (Ordinata / Libera). Le reazioni le spostano. | GDD §9.6.2. Nomi Provvisori. Deciso. |
| **Usanza** | Quando un'inclinazione arriva a un estremo, la nazione prende un'usanza: un tratto permanente con un nome e una storia. | GDD §9.6.3. È un elemento dell'identità. Deciso. |
| **Vocazione** | Un modo di giocare speciale, aperto da due usanze compatibili. Arriva come una cronaca: la accetti o la rifiuti. | GDD §9.6.5. Al massimo 2 per partita (Provvisorio). Deciso. |
| **Personaggio** | Una persona con un nome che torna nelle cronache, come un generale o un profeta. Si fida più o meno di te secondo le tue scelte. | GDD §9.6.4. Compare dopo il primo fantasma. Deciso. |
| **Fiducia** | Quanto un personaggio si fida della tua nazione. | GDD §9.6.4. Deciso. |
| **Ricordo** | La traccia di una scelta che la nazione conserva: più avanti può far arrivare cronache collegate. | GDD §9.6.4. Deciso. |
| **Catena** | Una serie di cronache collegate da un ricordo. | GDD §9.6.4. Parola soprattutto per noi. Deciso. |
| **Storia della nazione** | L'elenco delle reazioni e dei fatti della partita, che si legge negli Annali. | GDD §9.6.1. Deciso. |

## Il Consiglio

| Nome | Per il giocatore | Per noi |
|---|---|---|
| **Consiglio** | I consiglieri della tua nazione. In ogni round ne compaiono tre e ne ascolti uno. | GDD §4.2. Ha preso il posto del vecchio sistema delle opportunità (v0.21); oggi *opportunità* indica ciò che offre un consigliere. Deciso. |
| **Consigliere** | Un membro del Consiglio con un suo campo: propone azioni, edifici e truppe, e può potenziare le tue tessere. | GDD §4.2.3. Tesoriere, Fattore, Architetto, Generale, Studioso, Sacerdote, Cancelliere, Maestro delle spie (Provvisori). Il *Diplomatico* ora è il Cancelliere. Non chiamarlo *carta*. Deciso. |
| **Consigliere speciale** | Un consigliere senza campo, che ignora il tema del round: il Giullare e l'Anziano. | GDD §4.2.2. Deciso. |
| **Giullare** | Propone 5 tessere, una per ogni colore di mana più un edificio neutro. Non potenzia. | GDD §4.2.2 (*Clown*). Deciso. |
| **Anziano** | Propone peculiarità ed edifici neutri; una volta all'anno può potenziare un edificio neutro. | GDD §4.2.2. Provvisorio. |
| **Livelli del Consiglio** | Il Consiglio cresce con le ere: Funzionari, poi Ministri, poi Gran Consiglieri. | GDD §4.2.1. Il giocatore vede questi nomi, non un numero: “Livello” è solo delle tessere. Nomi Provvisori. |
| **Categoria** | Il campo di un consigliere: i tipi di tessere di cui si occupa. | GDD §4.2.4. Militare, Opera, Terra, Ricchezza, Conoscenza, Fede, Stato, Ombra (Provvisori). Le tessere non hanno categoria, solo tipi. Per gli effetti di battaglia non si dice “categoria di bersaglio” ma *bersagli ammessi*. Deciso. |
| **Opportunità** | Una delle tre cose che un consigliere ti offre: un'azione, un edificio o una truppa. Ne prendi una sola. | GDD §4.2 (*proposta*). Fino alla v0.20 era il nome del sistema di scelte prima del Consiglio. Non usare *proposta* (resta solo come stato del GDD) né *offerta*. Deciso. |
| **Azione** | Un'opportunità che non è una tessera: un effetto subito o per un anno. Non costa Oro (tranne gli spazi), ma a volte altre risorse. | GDD §4.2, §4.2.3. Non chiamarla *carta*. Deciso. |
| **Potenzia** | Fa salire di livello una tua tessera che ha un tipo del consigliere. Non conta come scelta del round e si usa una volta per round. | GDD §6.5. Deciso. |
| **Rinnovo** | Paghi per vedere tre opportunità nuove dallo stesso consigliere. Costa Oro o la risorsa del consigliere, ogni volta un po' di più. | GDD §4.2. Deciso. |
| **Avvenimento** | Ciò che può comparire in un round al posto di un consigliere: un Evento, un Visitatore o una Fortuna. | GDD §4.2.5 (*carta speciale*, *carte del round*). Non chiamarli *carte*. Deciso. |
| **Evento** | Una situazione con un testo e 2-3 opzioni. Alcune opzioni si sbloccano solo con certe caratteristiche della tua nazione. | GDD §4.2.5. Per il giocatore *Evento* è solo questo avvenimento. Fra noi, per il senso generale, “conseguenza” o “fatto della nazione”. Deciso. |
| **Opzione** | Una delle risposte possibili a un evento. | GDD §4.2.5. Per le cronache si dice *reazione*. Deciso. |
| **Requisito** | Ciò che serve per scegliere un'opzione. Un'opzione bloccata si vede comunque, spenta, con il requisito accanto. | GDD §4.2.5. Deciso. |
| **Visitatore** | Un personaggio di passaggio con le sue opportunità e i suoi prezzi. | GDD §4.2.5. Nel gioco: “Di passaggio”. Deciso. |
| **Fortuna** | Un dono semplice. | GDD §4.2.5. Nel gioco: “Un dono”. Deciso. |
| **Sfera** | La categoria a cui appartiene un avvenimento o una tecnologia: ne dà il tema e la cornice. | GDD §4.2.5, §10.5.2. Soprattutto per noi. Deciso. |
| **Radici** | Ciò che fa comparire un avvenimento, una cronaca o una tecnologia, o li rende più frequenti (es. il tuo credo, una via, la stagione, un tipo sulla plancia). | GDD §4.2.5. Solo per noi: il giocatore non lo vede. Deciso. |
| **Incanto** | Il Sacerdote aggiunge a una truppa un effetto in più nello scontro, con un costo di mana in più. Ogni truppa si incanta una volta sola. | GDD §4.3. Incanti comuni: Furia, Egida, Grazia, Maledizione, Torpore (Provvisori). Deciso. |
| **Spionaggio** | Le opportunità del Maestro delle spie: lo scontro con il fantasma dell'anno inizia con un suo edificio o una sua truppa già sabotati o inefficienti. | GDD §12. Deciso. |

## Economia e risorse

| Nome | Per il giocatore | Per noi |
|---|---|---|
| **Magazzino** | Dove stanno le tue risorse, senza limite. Resta di anno in anno. | GDD §5.3. Il mana e la Ricerca non stanno nel Magazzino. Deciso. |
| **Risorsa** | Ciò che gli edifici producono e che spendi per comprare, potenziare e pagare le azioni. | GDD §5.3. Deciso. |
| **Oro** | La moneta comune: compra tessere e spazi e paga i rinnovi. | GDD §5.3. Deciso. |
| **Ricerca** | Riempie la tecnologia che stai studiando. Non sta nel Magazzino e non si vende. | GDD §5.3, §10.5.1. Deciso. |
| **Cibo** | Serve per le razioni delle truppe, all'inizio di ogni anno. D'inverno gli edifici non lo producono. | GDD §5.2, §5.4. Nel codice si conta in decimi. Deciso. |
| **Ferro, Pietra, Legno, Influenza, Fede, Stabilità, Documenti** | Le risorse dei consiglieri: servono per Potenzia, per i rinnovi, per alcune azioni e per il mantenimento. | GDD §5.3, §4.2.4, §5.6. Ogni categoria ha la sua. *Fede* è sia una risorsa sia la categoria del Sacerdote, di proposito: nelle descrizioni va scritto chiaro quale si intende. La *Fauna* non è più una risorsa: è solo un tipo. Deciso. |
| **Mercato** | Vendi risorse in cambio di Oro, quando vuoi fuori dallo scontro. Non si possono comprare risorse. | GDD §5.3. Deciso. |
| **Razione** | All'inizio di ogni anno, dal secondo, ogni truppa mangia la sua razione di Cibo. | GDD §5.4 (*mantenimento*, nel senso del Cibo). Non chiamarla *mantenimento*. Deciso. |
| **Affamata** | Una truppa rimasta senza razione: ricarica più lenta fino al pasto successivo. | GDD §5.4. Scritta già nel gioco. Deciso. |
| **Mantenimento** | Prima di ogni scontro le tessere potenziate e quelle speciali costano un po' della risorsa del consigliere legato al loro primo tipo. | GDD §5.6. Solo per le tessere: il Cibo delle truppe è la *razione*. Deciso. |
| **Trascurata** | Una tessera di cui non hai pagato il mantenimento: in quello scontro è più lenta, e il Malcontento sale. | GDD §5.6. Deciso. |
| **Vendita** | Togli una tessera dalla plancia e ti torna metà di quanto l'hai pagata. | GDD §6.4. Deciso. |
| **Sostituzione** | Vendi una tessera e ne metti una nuova al suo posto. | GDD §6.4. Deciso. |
| **Dotazione iniziale** | Ciò con cui inizi la partita: Capitale, una truppa, un po' di Oro e spazi vuoti. | GDD §6.2. Le tessere della dotazione non rimborsano nulla. Deciso. |

## La plancia e le tessere

| Nome | Per il giocatore | Per noi |
|---|---|---|
| **Plancia** | Il tavolo della tua nazione: una fila di edifici e una fila di truppe. | GDD §6.1, §14.2. Deciso. |
| **Tessera** | Un edificio o una truppa: ciò che metti sulla plancia. | GDD *elemento*; prima anche *carta*. Non chiamare *carta* edifici e truppe. Nel codice i pezzi sulla plancia sono già `Tessera3D`. *Pezzo* solo per la grafica. Deciso. |
| **Spazio** | Un posto per una tessera. Si parte con 4 spazi edificio e 3 spazi truppa; se ne ottengono altri con le ere, con certi edifici e con l'Oro. | GDD §6.1, §6.3. Nel gioco: “LIBERO” e “DA CONQUISTARE”. Non usare *slot*. Deciso. |
| **Edificio** | Fuori dallo scontro produce risorse; nello scontro produce mana, altri effetti o entrambi. | GDD §5.1. Deciso. |
| **Edificio neutro** | Un edificio che non produce mana e quindi non ha colore. | GDD §5.3. Deciso. |
| **Truppa** | Nello scontro si attiva quando la ricarica è finita e c'è il mana che chiede. | GDD §7.2. Deciso. |
| **Livello** | Una tessera va dal livello 1 al 3; ogni livello rafforza tutti i suoi effetti. | GDD §6.5. Con l'ascensione *Maestria* si arriva al 4. Solo le tessere hanno un livello numerato. Deciso. |
| **Tessera speciale** | Una tessera esclusiva o di una linea: paga il mantenimento anche al livello 1. | GDD §5.6 (*carte speciali*). Deciso. |
| **Tipo** | Una caratteristica della tessera (es. Fante, Guardiano, Spirituale). Decide quali consiglieri la propongono e la potenziano. | GDD §6.6. Ha sostituito le *etichette*. Elenco nel GDD §6.6 (Provvisorio). Il tipo *Produzione* si chiama ora **Materie prime**. Deciso. |
| **Materie prime** | Il tipo degli edifici che producono materie prime, per esempio pietra, legno, ferro e cibo. | GDD §6.6 (tipo *Produzione*). Rinominato perché “produzione” indica già ciò che gli edifici producono. Deciso. |
| **Stendardo** | Il drappo di carta della tua nazione, con le iniziali e la Resistenza: steso sulla plancia, si alza in piedi negli scontri e brucia quando la Resistenza scende. | GDD §9.1, §14.2 (teatro di carta). Si personalizzerà nella creazione della nazione (Direzione). Non usarlo per il simbolo dei tipi d'identità: quello è il *Vessillo*. Deciso. |
| **Ordine delle truppe** | Nello scontro le truppe agiscono da destra verso sinistra: la più a destra usa il mana per prima. Puoi riordinarle quando vuoi fuori dallo scontro. | GDD §7.3. Deciso. |

## Lo scontro

| Nome | Per il giocatore | Per noi |
|---|---|---|
| **Scontro** | La battaglia automatica fra la tua plancia e quella del nemico. | GDD §7. Non usare *combattimento* né *battaglia* nel gioco. Deciso. |
| **Nemico** | Chi affronti nello scontro: il fantasma dell'anno o la plancia di un incontro del mondo. | Non usare *avversario* nei testi del gioco. Deciso. |
| **Resistenza** | La vita della tua nazione nello scontro. Se arriva a zero, perdi. Si ricalcola all'inizio di ogni scontro. | GDD §7.1, §7.1.1. Non sono punti vita delle tessere. Deciso. |
| **Mana** | L'energia che gli edifici producono nello scontro e che le truppe spendono per attivarsi. Si azzera a fine scontro. | GDD §5.3, §7.4. Deciso. |
| **Colori del mana** | Rosso, verde, blu, viola, più l'energetico. Una truppa paga con il suo colore. | GDD §5.3. *Viola* è un nome placeholder. Deciso. |
| **Mana energetico** | Vale come mana di qualsiasi colore. Lo produce la Capitale. | GDD §5.3. Deciso. |
| **Ricarica** | Il tempo che una truppa aspetta fra un'attivazione e la successiva. | GDD *cooldown*. Per gli edifici si dice *ciclo*. Deciso. |
| **Ciclo** | Ogni quanto un edificio produce nello scontro: “produce ogni ciclo di 3 s”. | GDD §7.4 (*intervallo*, *ritmo*). Funziona come la ricarica; la differenza è che una truppa a ricarica finita può restare in attesa del mana, un edificio produce sempre. Deciso. |
| **In attesa** | La truppa è pronta ma non c'è abbastanza mana: aspetta senza perdere nulla. | GDD §7.2, §7.3. Il motivo dell'attesa deve sempre vedersi (P4). Deciso. |
| **Danno** | Toglie Resistenza al nemico, ma prima consuma il suo scudo. | GDD §7.6, §8.3. Deciso. |
| **Scudo** | Una riserva che assorbe il danno prima della Resistenza. Resta finché non viene consumata. | GDD §7.6.1. Deciso. |
| **Cura** | Ridà Resistenza persa, mai oltre il massimo. | GDD §7.6.2. Deciso. |
| **Corruzione** | Sale durante lo scontro e non scende mai. Quando raggiunge la tua Resistenza, perdi. Lo scudo non la ferma. | GDD §7.6.3. Ha sostituito il *veleno*. Deciso. |
| **Danno d'assedio** | Toglie solo scudo al nemico, prima del danno normale. Ce l'hanno solo le truppe Assedio. | GDD *attacco d'assedio*, *danno agli scudi*. Deciso. |
| **Inefficienza** | Per qualche secondo il timer della tessera colpita va a metà velocità. | GDD §7.7. Sulla tessera: “Inefficiente”. Non usare *rallentato*. Il malus che si chiamava così ora è *Lavori a rilento*. Deciso. |
| **Sabotaggio** | Per qualche secondo la tessera colpita è ferma e non può attivarsi. | GDD §7.7. Sulla tessera: “Sabotato”. Deciso. |
| **Bersagli ammessi** | Che cosa può colpire un effetto: solo truppe, solo edifici o qualsiasi tessera. | GDD §7.7.1 (*categoria di bersaglio*). Rinominato per non confonderlo con la categoria dei consiglieri. Deciso. |
| **Logoramento** | Dopo 45 secondi entrambe le nazioni perdono Resistenza, sempre di più, finché lo scontro finisce. | GDD §7.5. Lo scudo lo assorbe. Deciso. |
| **Istante** | Un passo dello scontro. Nello stesso istante prima si produce mana, poi agiscono le truppe. | GDD §7.6.6. Nel codice dura 100 ms (*tick*). Parola soprattutto per noi. Deciso. |

## Ere, vie e tradizioni

| Nome | Per il giocatore | Per noi |
|---|---|---|
| **Era** | Un'epoca della tua nazione. Ci entri quando vuoi, dopo aver completato abbastanza tecnologie dell'era in corso: porta tessere nuove, spazi in più e più Resistenza. | GDD §10.2, §10.3. Ere del prototipo: Fondazione, Sviluppo, Ascesa (Provvisori). Deciso. |
| **Via** | Dalla seconda era, entrando in un'era scegli fra tre direzioni di sviluppo. La via diventa parte della tua identità. | GDD §10.4. Es. Via del Commercio, Via della Guerra (Provvisori). Non chiamarla *carta*. Deciso. |
| **Adozione** | La scelta di una via: dà subito un tratto, un bonus immediato e apre le sue tradizioni. | GDD §10.4.1. Deciso. |
| **Bonus immediato** | Ciò che una via ti dà subito, appena la scegli. | GDD §10.4. Deciso. |
| **Tradizione** | Una delle 4 tappe dell'albero di una via. Si completa da sola appena riesci nella sua impresa, e dà un effetto permanente. | GDD §10.4.1. Non usare *passo*. Deciso. |
| **Impresa** | L'obiettivo che completa una tradizione: un traguardo (es. vincere 3 scontri) o uno stato della nazione (es. 4 tessere Fante sulla plancia). | GDD §10.4.1. Deciso. |
| **Ascensione** | Completate le 4 tradizioni di una via, scegli un'ascensione fra 3: un effetto permanente forte. Le ascensioni maggiori cambiano una regola del gioco. | GDD §10.4.2. **Ascensione minore** (prima “livello 1”) e **ascensione maggiore** (prima “livello 2”): “Livello” resta solo alle tessere. Deciso. |

## Tecnologie

| Nome | Per il giocatore | Per noi |
|---|---|---|
| **Tecnologia** | Una scoperta che studi con la Ricerca. Completata, vale per sempre: tessere nuove, peculiarità, aiuti del Consiglio, spazi o bonus sui tipi. | GDD §10.5. Deciso. |
| **Carta** | Una tecnologia della mano. “Carta” si usa solo per le tecnologie. | GDD §10.5.3. Non chiamare *carta* edifici, truppe, consiglieri, azioni, avvenimenti o vie. Deciso. |
| **Mano** | Le 3 carte di tecnologia fra cui scegli quella da studiare. Si ripesca ogni volta che ne completi una. | GDD §10.5.3. Deciso. |
| **Tecnologia in corso** | La tecnologia che stai studiando: la Ricerca che guadagni la riempie un po' alla volta. | GDD §10.5.1. Deciso. |
| **Albero delle tecnologie** | Tutte le tecnologie della partita, con i loro prerequisiti. È sempre tutto visibile. | GDD §10.5.2. Deciso. |
| **Ramo** | Una delle quattro parti dell'albero, una per colore di mana. | GDD §10.5.2. Deciso. |
| **Altezza** | Il piano dell'albero in cui sta una tecnologia; ogni era ne ha due. | GDD §10.5.2. Soprattutto per noi. Deciso. |
| **Carta dorata** | Una tecnologia già studiata a metà, ricevuta da un evento, una fortuna o un incontro del mondo. Resta sempre nella mano finché non la completi. | GDD §10.5.6. Deciso. |
| **Linea** | Una serie di tessere, una per era, con lo stesso ruolo. La sblocca una tecnologia. | GDD §10.5.5. Deciso. |
| **Tecnologia esclusiva** | Una tecnologia che compare solo per chi ha una certa via o un certo popolo. | GDD §10.5.2. Deciso. |
| **Dottrina** | Una tecnologia che rafforza tutte le tessere di un tipo (es. “le truppe Fante ricaricano più in fretta”). | GDD §10.5.4. Deciso. |
| **Progetto speciale** | Una tecnologia che chiede anche una risorsa dei consiglieri, oltre alla Ricerca. | GDD §10.5.7. Direzione: non è nel gioco. Deciso. |

## Fantasmi e incontri

| Nome | Per il giocatore | Per noi |
|---|---|---|
| **Fantasma** | La copia registrata della nazione di un altro giocatore: è il nemico di fine anno. | GDD §11. Può lasciarti dei malus. Deciso. |
| **Incontro del mondo** | Una minaccia alla fine della primavera e dell'estate, come barbari o pirati. Ne scegli uno fra tre e affronti la sua plancia. Se perdi, il tuo Oro si dimezza. | GDD §3.3. Gli incontri hanno difficoltà facile, media e difficile. Deciso. |
| **Plancia generata** | La plancia nemica di un incontro del mondo, creata dal gioco. | GDD §3.3. Soprattutto per noi. Deciso. |

## Effetti che durano

| Nome | Per il giocatore | Per noi |
|---|---|---|
| **Effetti attivi** | Tutto ciò che in questo momento modifica la tua nazione, con la durata che resta. | Nel gioco: “EFFETTI ATTIVI”. Deciso. |
| **Malus** | Un effetto negativo che dura per un certo numero di anni. Non ti rovina: ti spinge a giocare in modo diverso. | GDD §8.2.1, principio P1. Deciso. |
| **Bonus** | Un effetto positivo che dura per un certo tempo. | GDD §8.2.1. Deciso. |
| **Origine** | Chi ti ha dato l'effetto, per esempio il nome del fantasma. | GDD §8.2. Deciso. |

## Leggere il gioco

| Nome | Per il giocatore | Per noi |
|---|---|---|
| **Simboli** | Le icone che dicono che cosa fa una tessera, un consigliere o un'azione: si leggono da sinistra a destra, “quello che paghi → quello che ottieni”. | GDD §14.4. Deciso. |
| **Vessillo** | Il simbolo dei tipi d'identità (popolo, governo, credo, cultura) nei medaglioni dei tipi: tutti hanno lo stesso vessillo; il nome del tipo è nei dettagli. | GDD §14.4. Prima chiamato *stendardo*: quel nome ora è del drappo della nazione. Deciso. |
| **Legenda** | Il pannello che spiega come si leggono i simboli, con esempi presi dal gioco. | GDD §14.4. Deciso. |
| **Parole chiave** | Le parole colorate nei testi (risorse, effetti, colori del mana, tipi): passandoci sopra se ne legge la spiegazione. | GDD §16.3 (testi colorati). File: `data/ui/lessico.tres`. Le spiegazioni vengono da questo glossario. Deciso. |

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
| **Elemento** | Parola generale delle regole per una tessera (edificio o truppa). Nel gioco si dice *tessera*. | Parte 2, Tessera |
| **Catalogo** | L'elenco di tutti i contenuti (tessere, consiglieri, vie, eventi, tecnologie…) con i loro valori. | `docs/Catalogo.md`, `data/catalog/` |
| **Budget** | Il valore in punti di una tessera, usato per bilanciare il catalogo. | Catalogo §1 |
| **Seme** | Il numero che decide la casualità: lo stesso seme dà sempre la stessa partita o lo stesso scontro. | GDD §7.5 |
| **Tick** | Il passo fisso della simulazione (100 ms). Per il giocatore è l'*istante*. | GDD §16.3 |
| **Simulazione / presentazione** | Le regole pure (simulazione) e ciò che si vede sullo schermo (presentazione), tenute separate. | GDD §16.2 |

---

## Nomi ritirati

Non vanno più usati nel gioco né nei documenti nuovi.

| Nome vecchio | Ora si dice | Da quando |
|---|---|---|
| Opportunità (il vecchio sistema di scelte) | Consiglio; *opportunità* ora indica ciò che offre un consigliere | GDD v0.21; Glossario, 8 nov. 2026 |
| Proposta, offerta (di un consigliere) | Opportunità | Glossario, 8 nov. 2026 |
| Produzione, Preparazione (le parti dell'anno) | Le quattro stagioni | GDD v0.25 |
| Fase, metà, macrofase | Stagione | GDD v0.25; Glossario, 8 nov. 2026 |
| Carta (per edifici e truppe) | Tessera | Glossario, 8 nov. 2026 |
| Carta (per consiglieri, azioni, avvenimenti, vie) | Il loro nome | Glossario, 8 nov. 2026 |
| Carta speciale, carte del round | Avvenimento | Glossario, 8 nov. 2026 |
| Carte speciali (nel mantenimento) | Tessere speciali | Glossario, 8 nov. 2026 |
| Mantenimento (il Cibo delle truppe) | Razione | Glossario, 8 nov. 2026 |
| Passo (dell'albero di una via) | Tradizione | Glossario, 8 nov. 2026 |
| Cronaca (il pannello) | Annali | Glossario, 8 nov. 2026 |
| Cooldown | Ricarica (truppe) | Glossario, 8 nov. 2026 |
| Intervallo, ritmo (di un edificio) | Ciclo | Glossario, 8 nov. 2026 |
| Rallentato, rallentamento | Inefficiente, Inefficienza | Glossario, 8 nov. 2026 |
| Razza | Popolo | Glossario, 8 nov. 2026 |
| Elemento, pezzo (nei testi del gioco) | Tessera | Glossario, 8 nov. 2026 |
| Combattimento, battaglia (nei testi del gioco) | Scontro | Glossario, 8 nov. 2026 |
| Run, campagna (nei testi del gioco) | Partita | Glossario, 8 nov. 2026 |
| Attacco d'assedio, danno agli scudi | Danno d'assedio | Glossario, 8 nov. 2026 |
| Civiltà (nei testi del gioco) | Nazione | Glossario, 8 nov. 2026 |
| Avversario | Nemico | Glossario, 8 nov. 2026 |
| Modificatore, conseguenza (nei testi del gioco) | Effetti attivi: malus e bonus | Glossario, 8 nov. 2026 |
| Perk | Peculiarità | Glossario, 8 nov. 2026 |
| Livello 1, livello 2 (delle ascensioni) | Ascensione minore, ascensione maggiore | Glossario, 8 nov. 2026 |
| Consiglio ristretto (ascensione) | Corte affollata | Glossario, 8 nov. 2026 |
| Tier (del governo) | Rango | Glossario, 8 nov. 2026 |
| Clown | Giullare | Glossario, 8 nov. 2026 |
| Produzione (tipo) | Materie prime | Glossario, 8 nov. 2026 |
| Categoria di bersaglio | Bersagli ammessi | Glossario, 8 nov. 2026 |
| Inefficienza (nome del malus) | Lavori a rilento | Glossario, 8 nov. 2026 |
| Mercante (azione del Tesoriere) | Tolta dal gioco | GDD v0.26 |
| Etichetta | Tipo | GDD v0.22 |
| Tipo del round | Tema del round | GDD v0.22 |
| Diplomatico | Cancelliere | GDD v0.22 |
| Fauna (come risorsa) | Resta solo come tipo | GDD v0.22 |
| Tiratori, Cavalleria (etichette) | Non esistono più | GDD v0.22 |
| Veleno | Corruzione | GDD v0.13 |
| Distruggi | Sabotaggio | GDD v0.14 |
| Montanari, Popolo del delta, Popolo delle foreste | Pietrosangue, Maremani, Cinerali | GDD v0.24 |
| Ordine della Ragione (credo) | Cultura erudita | GDD v0.24 |

---

## Registro delle decisioni

| Data | Decisione |
|---|---|
| 5 novembre 2026 | Bozza 1 del glossario, in un documento a parte; la §19 del GDD rimanda qui. |
| 8 novembre 2026 | Davide approva: Ricarica, Inefficienza (sulla tessera “Inefficiente”), Popolo, Scontro, Partita, Danno d'assedio, Nazione, Effetti attivi con malus e bonus, Round, Rango, Giullare. |
| 8 novembre 2026 | Ricarica per le truppe, **Ciclo** per gli edifici: funzionano allo stesso modo, ma si tengono due nomi coerenti. |
| 8 novembre 2026 | Ciò che offre un consigliere si chiama **Opportunità**, non *Proposta* (che resta uno stato del GDD). Chi si affronta nello scontro è il **Nemico**. *Perk* diventa **Peculiarità**. |
| 8 novembre 2026 | Eventi, Visitatori e Fortune insieme sono **Avvenimenti**. Il malus *Inefficienza* diventa **Lavori a rilento**. Il tipo *Produzione* diventa **Materie prime**. La “categoria di bersaglio” diventa **bersagli ammessi**. |
| 8 novembre 2026 | “Livello” solo sulle tessere; il Consiglio mostra i nomi dei suoi livelli. Per il giocatore *Evento* è solo l'avvenimento del round. *Fede* resta sia risorsa sia categoria. |
| 8 novembre 2026 | Le parti dell'anno sono le **stagioni**, come nel GDD v0.25 (inverno, primavera, estate, autunno). La proposta di rinominare l'azione *Mercante* non serve più: l'azione è stata tolta nella v0.26. |
| 8 novembre 2026 | Edifici e truppe si chiamano **tessere**; “carta” vale **solo per le tecnologie** (mano, carta dorata). Consiglieri, azioni, avvenimenti e vie si chiamano con il loro nome. |
| 8 novembre 2026 | Il Cibo delle truppe è la **razione**; **mantenimento** è solo il costo delle tessere prima degli scontri. Le tappe delle vie sono **tradizioni** (non *passi*). Il pannello con la storia della partita si chiama **Annali**; **Cronaca** resta la scena di inizio stagione. |
| 8 novembre 2026 | Le ascensioni sono **minori** e **maggiori** (non di livello 1 e 2): “Livello” resta solo alle tessere. L'ascensione *Consiglio ristretto* diventa **Corte affollata**, perché dà un consigliere in più. |
| 8 novembre 2026 | **Stendardo** è il drappo di carta della nazione (teatro di carta); il simbolo dei tipi d'identità si chiama **Vessillo**. |
