# Prove di stile (8 novembre 2026)

Tre prove dello stile della partita, fatte in Godot per vedere luci e animazioni vere.
Sono **separate dal gioco**: Godot, quando apre Ultralopolis, ignora questa cartella.

Lo scontro che si vede è **finto**: una sequenza di fatti scritta a mano, non la simulazione
del gioco. Serve solo a giudicare aspetto e movimento. I disegni sono messi a caso sulle carte.

| Prova | Scena | Video |
|---|---|---|
| 1 · Teatro di carta (scelta da Davide come base) | `teatro.tscn` | `video/teatro.mp4` |
| 2 · Lastra da stampa | `lastra.tscn` | `video/lastra.mp4` |
| 3 · Reliquiario | `reliquiario.tscn` | `video/reliquiario.mp4` |

## Come aprirle in Godot

1. Apri Godot 4.7: compare la finestra con l'elenco dei progetti.
2. Premi **Importa** (in alto a sinistra).
3. Scegli il file `prove/stile/project.godot` dentro la cartella di Ultralopolis e conferma.
4. Nel pannello **FileSystem** (in basso a sinistra) fai doppio clic su `teatro.tscn`.
5. Premi **F6** (oppure il pulsante «Esegui scena corrente» in alto a destra): parte lo scontro di prova,
   che si chiude da solo dopo circa 15 secondi.

## Che cosa contiene

- `prova_base.gd`: la sequenza dello scontro finto, comune alle tre prove.
- `teatro.gd`, `lastra.gd`, `reliquiario.gd`: l'aspetto e le animazioni di ciascuna prova.
- `arte/`: i disegni di Davide (da `assets/illustrazioni/`) ridotti a 512 × 512.
- `sagome/`: gli stessi disegni ritagliati come figurine di carta, con il bordo color crema.
  Li ha preparati lo script `ritaglia.py` (toglie il nero attorno alla figura, non le linee interne).
- `font/`: copia dei caratteri Barlow del gioco.
