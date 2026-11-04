# Ultralopolis — istruzioni per Claude Code

## Contesto

Ultralopolis è un gioco strategico asincrono per PC, sviluppato in Godot. Il creatore, Davide, **non programma**: il codice lo scrivi tu.

- Spiega ogni modifica in italiano semplice: cosa cambia nel gioco, non come è fatto il codice.
- Non dare per scontata alcuna conoscenza di programmazione. Quando Davide deve fare qualcosa in Godot o in Cursor, indica i passaggi esatti (menu, pulsanti, impostazioni).
- Se una richiesta è ambigua, chiedi prima di scrivere codice.

## Fonte di verità: il Game Design Document

Il design è in `docs/Ultralopolis_GDD.md`. Leggilo prima di lavorare su qualsiasi sistema di gioco.

Ogni indicazione del GDD ha uno stato. Rispettalo:

| Stato | Cosa fare |
|---|---|
| **Confermato** | È una regola: implementala così. |
| **Direzione** | È un obiettivo: chiedi come realizzarlo prima di inventare regole. |
| **Proposta** | Non è approvata: non trattarla come regola senza conferma di Davide. |
| **Da definire** | Non esiste una regola: chiedi. Se serve una convenzione temporanea per far funzionare il codice, dichiarala e rendila facile da cambiare. |
| **Spunto** | Non implementarlo. La base però non deve renderlo impossibile. |

Le convenzioni temporanee già in uso sono elencate nel GDD (§16.3). Se ne introduci una nuova, segnalalo a Davide e proponi di aggiungerla lì.

Se una richiesta tocca il **nucleo** (Parte I del GDD), o richiede una nuova risorsa o una nuova famiglia di effetti (principio P5), dillo esplicitamente prima di procedere: è una modifica del cuore del gioco, non un contenuto.

Non modificare il GDD di tua iniziativa. Se una decisione presa con Davide cambia il design, proponi l'aggiornamento del documento.

## Motore e linguaggio

- **Godot 4.7, GDScript 2.0.** Esportazione nativa per PC. Non progettare per il web.
- **Tipi statici ovunque**: variabili, parametri e valori di ritorno tipizzati (`var mana: int = 0`, `func pay(cost: int) -> bool:`).
- **Vietata la sintassi di Godot 3.** Esempi da non usare mai:

| Godot 3 (vietato) | Godot 4 (corretto) |
|---|---|
| `export var x` | `@export var x` |
| `onready var x` | `@onready var x` |
| `yield(...)` | `await ...` |
| `connect("segnale", self, "metodo")` | `segnale.connect(metodo)` |
| `.instance()` | `.instantiate()` |
| `Spatial`, `KinematicBody` | `Node3D`, `CharacterBody3D` |
| `tool` | `@tool` |

In caso di dubbio su un'API, verifica sulla documentazione di Godot 4 invece di affidarti alla memoria.

## Architettura

Tieni separate **simulazione** e **presentazione** (GDD §16.2).

- La simulazione (economia, mana, cooldown, Resistenza, esito) è logica pura: classi GDScript che non dipendono da nodi della scena, dalla grafica o dal frame rate.
- La presentazione (plancia 3D, pezzi, interfaccia) legge lo stato della simulazione e lo mostra. Non contiene regole di gioco.
- Il componente **Modificatori** (GDD §8) è il punto in cui si innestano malus, perk ed effetti futuri. Usa sempre la struttura bersaglio / effetto / durata / origine / cumulabilità.

### Simulazione deterministica

Lo stesso scontro deve dare lo stesso risultato su qualunque macchina, perché i fantasmi vengono rigiocati su PC diversi.

- La battaglia avanza a **tick fissi** (convenzione attuale: 100 ms), mai con il `delta` di `_process`.
- Mana, cooldown (in millisecondi), danni e Resistenza sono **numeri interi**. Niente `float` nella simulazione.
- Ogni casualità usa un `RandomNumberGenerator` con seme esplicito e registrato.
- L'ordine di valutazione delle truppe è **da destra verso sinistra** (GDD §7.3). Una truppa senza mana resta in attesa, senza nuovo cooldown e senza prenotare mana.

## Dati di gioco

- Valori di bilanciamento, edifici, truppe, ere e plance generate stanno in **file dati**, non nel codice. Cambiare un numero non deve richiedere di toccare uno script.
- Formato: Resource personalizzate di Godot (`.tres`) per il catalogo.
- I fantasmi si salvano come JSON con le **statistiche complete** degli elementi, la versione delle regole e il seme casuale (GDD §11.4).

## Grafica

- **Plancia 3D, pezzi 2D** (GDD §14.2): la plancia è una scena 3D; edifici, truppe e segnalini sono superfici piane con immagini 2D posate sopra.
- Interfaccia (risorse, Prestigio, offerte) in 2D sopra la scena.
- Nessun modello 3D di truppe e nessuna animazione scheletrica. Le animazioni sono movimenti semplici via codice (spostamento, rotazione, scossa) con i Tween.
- Finché Davide non fornisce le illustrazioni, usa segnaposto semplici e chiaramente provvisori (forme e colori con il nome dell'elemento).
- La battaglia deve spiegarsi da sola (principio P4): il giocatore deve vedere perché una truppa non si è attivata.

## Struttura delle cartelle

```
docs/          Game Design Document e documentazione
data/          file dati del catalogo (.tres) e configurazione
scripts/sim/   simulazione e regole (logica pura)
scripts/ui/    presentazione e interfaccia
scenes/        scene di Godot
assets/        immagini, texture, font, audio
tests/         verifiche delle regole
```

## Verifica

- Dopo ogni modifica, controlla che gli script non abbiano errori. Se Godot è disponibile da riga di comando, usalo per verificarlo.
- Le regole della simulazione vanno verificate con test automatici basati sui casi del GDD (§17). Non aggiungere plugin o dipendenze esterne senza chiedere.
- Non dire che qualcosa funziona se non l'hai verificato: indica cosa hai controllato e cosa deve provare Davide in Godot.

## Git

- Commit piccoli, uno per modifica logica, con messaggi in italiano.
- Non cambiare la visibilità del repository e non pubblicare build senza che Davide lo chieda.
