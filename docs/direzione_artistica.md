# Ultralopolis — Direzione artistica (proposta)

**Stato:** proposta di lavoro, non approvata nel GDD. Quando le scelte saranno stabili, andranno riportate nel GDD (§14.2) con l'approvazione di Davide.
**Ultimo aggiornamento:** 8 novembre 2026

Questo documento descrive l'aspetto attuale del gioco e spiega come preparare le illustrazioni perché restino coerenti tra loro.

---

## 1. Direzione generale

Fantasy moderno, ispirato per sensazione ai giochi da tavolo digitali e agli auto-battler recenti (riferimenti indicati da Davide: The Bazaar, TFT). È uno stile **originale**: non si copiano personaggi, grafica o interfacce di altri giochi.

| Aspetto | Scelta attuale |
|---|---|
| Ambiente | Notte blu scura, terreno di pietra, plance come lastre di pietra con il bordo luminoso del proprio lato. |
| Lati | Azzurro per il giocatore, cremisi per l'avversario. |
| Pezzi | Carte con angoli arrotondati, cornice metallica, illustrazione, nome su fascia scura, gemma del mana nell'angolo, "pastiglie" con i numeri. |
| Interfaccia | Pannelli scuri semitrasparenti ai bordi dello schermo; pulsante principale dorato; dettagli al passaggio del mouse. |
| Caratteri | Barlow Semi Condensed (titoli e numeri), Barlow (testi). Licenza SIL OFL, in `assets/fonts/`. |
| Movimento | Carte che si sollevano al passaggio del mouse, scattano quando si attivano, scintille e gemme di mana che volano con una scia, stemma che trema quando subisce danni. |

Tutti i colori, i caratteri e i materiali stanno in `scripts/ui/stile_visivo.gd`: cambiando quel file cambia l'aspetto di tutto il gioco.

## 2. Colori riservati

Alcuni colori hanno un significato e non vanno usati per altro, perché la battaglia deve spiegarsi da sola (principio P4).

| Significato | Colore |
|---|---|
| Mana rosso (guerra) | rosso acceso `#ff4a3d` |
| Mana verde (ricchezza) | verde `#3ddc6b` |
| Mana blu (diplomazia e sapere) | blu `#3d8bff` |
| Mana energetico | oro `#ffcc33` |
| Danno, malus, attesa per mancanza di mana | rosso `#e8423f` |
| Azione principale, Prestigio, costi | oro `#f2b632` / `#ffd76a` |

**Cornice delle carte secondo l'era (proposta visiva, non è una regola):** bronzo per la Fondazione, argento per lo Sviluppo, oro per l'Ascesa. Le opportunità senza edificio o truppa hanno la cornice viola; incontri e fantasmi hanno la cornice cremisi.

## 3. Le illustrazioni delle carte

### 3.1 Dove metterle

Il gioco cerca da solo le immagini con il nome dell'identificativo dell'elemento (il campo `id` nei file del catalogo). Se un'immagine manca, la carta mostra il segnaposto: una sfumatura del colore del mana con l'iniziale.

| Elemento | Percorso |
|---|---|
| Edifici | `assets/illustrazioni/edifici/<id>.png` (es. `fattoria.png`) |
| Truppe | `assets/illustrazioni/truppe/<id>.png` (es. `arcieri.png`) |
| Opportunità senza edificio o truppa | `assets/illustrazioni/azioni/<id>.png` (es. `studiosi.png`) |
| Incontri del mondo | `assets/illustrazioni/incontri/<nome del file dell'incontro>.png` |

Formato: **PNG quadrato, 512 × 512 pixel**. Il gioco ritaglia l'immagine per riempire il riquadro della carta, quindi il soggetto deve stare **al centro** con un po' di margine.

### 3.2 Come devono essere

- Un solo soggetto chiaro, centrato, con una sagoma leggibile anche in piccolo.
- Colori saturi; luce calda davanti e un contorno di luce fredda sul bordo.
- Sfondo dipinto semplice, con una leggera sfumatura e i bordi un po' più scuri.
- Nessun testo, nessuna lettera, nessun logo, nessuna cornice: cornice e scritte le disegna già il gioco.
- Stesso stile per tutte le immagini: conviene generarle tutte con lo stesso testo di stile e lo stesso modello.

### 3.3 Testo da usare con un generatore di immagini

Struttura: `Game card illustration: <soggetto>. ` seguito sempre dallo stesso blocco di stile:

> Stylized painterly fantasy illustration for a game card, bold readable silhouette, centered subject, vibrant saturated colors, strong warm key light and cool rim light, soft painted background with simple atmospheric gradient, slight vignette, clean shapes, high detail on the subject, no text, no letters, no logos, no frame, no border, square composition.

Soggetti già preparati per il primo gruppo (gli elementi della prima era):

| id | Soggetto |
|---|---|
| edifici/capitale | a grand fantasy capital city keep with tall towers, banners and golden domes on a hill |
| edifici/fattoria | a cozy fantasy farmstead with a red barn, wheat fields and a windmill |
| edifici/biblioteca | a fantasy library tower with glowing blue windows, books and scrolls, arcane light |
| edifici/caserma | a stone fantasy barracks with red banners, weapon racks and a training yard |
| edifici/mercato | a lively fantasy market square with colorful stall awnings, crates and goods |
| truppe/milizia | a fantasy militia soldier with a wooden shield and short sword, simple armor, determined pose |
| truppe/lancieri | a fantasy spearman with a long spear and tall shield, steel helmet, ready stance |
| truppe/arcieri | a fantasy archer drawing a longbow, hooded cloak, dynamic pose |

**Stato del primo gruppo:** il 4 novembre 2026 la generazione con ElevenLabs non è partita perché l'account collegato aveva raggiunto il limite giornaliero di immagini del piano gratuito. Gli otto testi sono salvati in un progetto ElevenLabs chiamato "Ultralopolis - illustrazioni carte (batch 1)" (modello GPT Image 2.5, formato 1:1), pronti da rilanciare.

### 3.4 Elementi che avranno bisogno di un'illustrazione

Edifici: accademia, banca, biblioteca, bottega, cantiere, capitale, caserma, cattedrale, cava, cittadella, consolato, fattoria, fortezza, mercato, miniera, santuario, segheria, stalle, tempio, università.
Truppe: arcieri, arieti, balestrieri, bombarde, catapulte, cavalieri, esploratori, frombolieri, guardie, lancieri, milizia, moschettieri, paladini.

## 4. Simboli sulle carte

Come nei giochi da tavolo, consiglieri, azioni ed eventi mostrano **che cosa fanno con dei simboli** invece che con il testo. Il testo completo resta nel riquadro che compare passando il mouse. Idea e scelte di Davide (8 novembre 2026), approvate nel GDD (§14.4, v0.30); i simboli attuali sono provvisori.

### 4.1 Come si leggono

Ogni riga è una cosa che la carta può fare e si legge da sinistra a destra: **quello che paghi → quello che ottieni**.

| Esempio | Significato |
|---|---|
| `2[Stabilità] → +4[Oro]` | Paghi 2 Stabilità, ricevi 4 Oro (Decreto fiscale). |
| `1[anno] +50%[Oro] / +50%[Ricerca]` | Per un anno, +50% Oro oppure +50% Ricerca, a scelta (Assemblea). |
| `2[Ferro] → 1[anno] [truppa] −25%[clessidra]` | Paghi 2 Ferro: per un anno una truppa ha la ricarica più corta del 25% (Addestramento). |
| `2[Pietra] → [fantasma]: +10[castello]` | Nel prossimo scontro con il fantasma, +10 Resistenza (Fortificazioni). |
| `6[Oro] → +1[edificio tratteggiato]` | Uno spazio edificio in più (Architetti). |
| `[potenzia]: [Influenza]` | Il consigliere potenzia le carte facendo pagare Influenza. |
| `[edificio] / [truppa]` | In questo round il consigliere propone anche edifici e truppe. |
| `[lucchetto] ...` | Opzione di un evento che adesso non si può scegliere: la riga è spenta. |

Regole della grafica:

- **Simboli monocromatici** (bianchi): si riconoscono dalla forma, non dal colore, così non si confondono con il mana (scelta di Davide).
- Il colore sta solo nei **numeri**: oro per i costi, rosso per i malus, bianco per il resto (colori riservati del §2).
- Il **mana** resta una gemma colorata disegnata dal gioco.
- `/` separa le alternative, `·` separa due effetti diversi della stessa scelta.
- Uno **spazio** della plancia è il simbolo dentro una cornice tratteggiata; una carta che **sale di livello** ha una freccia dorata.
- Le stesse icone delle risorse compaiono nella barra delle risorse in basso e accanto al Malcontento, così il giocatore le impara.
- Le righe corte stanno **affiancate** sulla stessa linea, ognuna nella sua pastiglia, per non sprecare spazio (richiesta di Davide); gli incanti e gli spionaggi di un consigliere si riuniscono in una riga sola.
- Con il mouse sopra, una carta con i simboli **si ingrandisce** (×1,7) e il testo dei dettagli va sotto o di fianco, senza coprirla.
- La **legenda** (pulsante «Legenda» a destra, accanto a Effetti e Cronaca) mostra come si legge una carta con esempi presi dalle carte vere, tutti i simboli, le gemme di mana e i colori dei numeri. Gli esempi si costruiscono dai dati, come le carte.
- Se con un consigliere puoi già potenziare qualche carta, la sua riga del Potenzia è **dorata** e sotto la carta compare "Ascolta · ▲ Potenzia N" (quante carte).

### 4.2 Dove sono

I simboli stanno in `assets/icone/`, un file per concetto (es. `stabilita.svg`). L'elenco e il modo per sostituirli sono in `assets/icone/LEGGIMI.md`. Quelli attuali vengono da game-icons.net (licenza CC BY 3.0): prima di pubblicare il gioco va aggiunta la citazione degli autori nei crediti.

Le righe si costruiscono da sole dai file dati del catalogo: cambiando un costo o un effetto in un file `.tres`, la carta si aggiorna senza toccare il codice.

### 4.3 Che cosa ha i simboli

| Carte | Stato |
|---|---|
| Consiglieri (Potenzia, edifici/truppe proposti, azioni possibili nel round), azioni e perk proposti, Eventi, Fortune, Visitatori e le loro opzioni | Fatto (prima fase) |
| Edifici e truppe (produzione, mana, effetti di battaglia), ricompense degli incontri, cronache | Da decidere con Davide (seconda fase) |
| Gli otto poli delle inclinazioni delle cronache | Per ora in parole |

## 5. Convenzioni provvisorie introdotte con questo stile

Da proporre per il GDD (§16.3) se Davide le approva:

| Convenzione | Stato |
|---|---|
| Colore della cornice delle carte secondo l'era (bronzo, argento, oro) | Proposta visiva |
| Illustrazioni cercate per identificativo nelle cartelle di `assets/illustrazioni/` | Convenzione tecnica |
| La partita si gioca solo sulla plancia 3D; l'interfaccia provvisoria è stata tolta (decisione di Davide) | Da riportare nel GDD (§14.3, §16.3) |
| La plancia mostra gli spazi ancora da conquistare fino al massimo (12 truppe, 10 edifici) | Proposta visiva |
| Simboli sulle carte (§4 di questo documento) al posto del testo, con il testo completo al passaggio del mouse | Riportato nel GDD (§14.4, v0.30) |
