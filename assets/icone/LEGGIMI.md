# Simboli del gioco

Questi sono i simboli che il gioco mette sui consiglieri, sulle azioni, sugli avvenimenti, nella barra
delle risorse e davanti alle parole chiave dei testi. Ogni file è un concetto del gioco: il nome del
file è il concetto. Alcuni file hanno ancora un nome tecnico vecchio (es. `perk.svg`, `proposta.svg`):
conta il significato scritto nell'elenco, con i nomi del glossario (`docs/Glossario.md`).

## Come sostituire un simbolo

1. Prepara un'immagine **quadrata**, **bianca su sfondo trasparente** (SVG oppure PNG 512 × 512).
   Il gioco la colora da solo dove serve: deve essere bianca.
2. Salvala in questa cartella con **lo stesso nome** di quella da sostituire (es. `stabilita.svg`).
   Se usi un PNG, cancella l'SVG con lo stesso nome.
3. Apri il progetto in Godot: l'immagine viene importata da sola.

Se un simbolo manca, al suo posto compare un cerchio con l'iniziale del concetto.

## Elenco

| File | Significato | Icona originale (game-icons.net) |
|---|---|---|
| `oro.svg` | Oro | two-coins |
| `ricerca.svg` | Ricerca | light-bulb |
| `cibo.svg` | Cibo | wheat |
| `legno.svg` | Legno | log |
| `pietra.svg` | Pietra | stone-block |
| `ferro.svg` | Ferro | anvil |
| `fede.svg` | Fede | prayer |
| `influenza.svg` | Influenza | crown |
| `stabilita.svg` | Stabilità | scales |
| `documenti.svg` | Documenti | scroll-unfurled |
| `malcontento.svg` | Malcontento | fist |
| `danno.svg` | Danno | broadsword |
| `scudo.svg` | Scudo | shield |
| `cura.svg` | Cura | health-normal |
| `corruzione.svg` | Corruzione | poison-bottle |
| `assedio.svg` | Danno d'assedio | catapult |
| `inefficienza.svg` | Inefficienza | snail |
| `sabotaggio.svg` | Sabotaggio (ferma) | cog-lock |
| `resistenza.svg` | Resistenza | castle |
| `edificio.svg` | Edificio | house |
| `truppa.svg` | Truppa | visored-helm |
| `potenzia.svg` | Potenzia | upgrade |
| `malus.svg` | Malus | armor-downgrade |
| `anno.svg` | Durata in anni | calendar |
| `ricarica.svg` | Ricarica (truppe), ciclo (edifici), tempo | hourglass |
| `rinnovo.svg` | Rinnovo, ripescare | cycle |
| `spia.svg` | Spionaggio | spy |
| `fantasma.svg` | Scontro con il fantasma | ghost |
| `incanto.svg` | Incanto | sparkles |
| `perk.svg` | Peculiarità | laurels |
| `governo.svg` | Governo | throne-king |
| `tecnologia.svg` | Tecnologia | gears |
| `proposta.svg` | Opportunità del Consiglio | card-draw |
| `caso.svg` | A caso | perspective-dice-six-faces-random |
| `bloccato.svg` | Opzione bloccata | padlock |
| `azione.svg` | Azioni del Consiglio (la riga «azioni» del consigliere) | stamper |
| `scambio.svg` | Scambio di risorse | trade |

### Tipi (medaglioni sulla linguetta)

Il simbolo di un tipo è `tipo_<nome del tipo>.svg`, tutto minuscolo e con `_` al posto degli spazi (es. «Infrastruttura Bellica» → `tipo_infrastruttura_bellica.svg`). Per dare un simbolo a un tipo nuovo basta aggiungere il file. Un tipo senza file, come i tipi d'identità, usa lo stendardo `tipo_identita.svg`.

| File | Tipo | Icona originale (game-icons.net) |
|---|---|---|
| `tipo_fante.svg` | Fante | spears |
| `tipo_assedio.svg` | Assedio | siege-ram |
| `tipo_guardiano.svg` | Guardiano | guarded-tower |
| `tipo_infrastruttura_bellica.svg` | Infrastruttura Bellica | barracks |
| `tipo_infrastruttura_strategica.svg` | Infrastruttura Strategica | harbor-dock |
| `tipo_infrastruttura_segreta.svg` | Infrastruttura Segreta | all-seeing-eye |
| `tipo_materie_prime.svg` | Materie prime | mine-wagon |
| `tipo_economico.svg` | Economico | shop |
| `tipo_fauna.svg` | Fauna | horse-head |
| `tipo_nobile.svg` | Nobile | diamond-ring |
| `tipo_accademico.svg` | Accademico | open-book |
| `tipo_legge.svg` | Legge | gavel |
| `tipo_criminale.svg` | Criminale | robber-mask |
| `tipo_spirituale.svg` | Spirituale | temple-gate |
| `tipo_patriota.svg` | Patriota | eagle-emblem |
| `tipo_capitale.svg` | Capitale | capitol |
| `tipo_identita.svg` | Tutti i tipi d'identità (Pietrosangue, Monarchico…) | knight-banner |

Il mana non ha un file: le gemme colorate le disegna il gioco, perché il colore è il loro significato.
L'unica eccezione è `gemma.svg`, un esagono bianco che serve solo nei testi dei riquadri: il gioco lo colora
con il colore del mana davanti alle parole «rosso», «verde», «blu», «viola» ed «energetico».

## Licenza

Le icone vengono da [game-icons.net](https://game-icons.net) (autori principali Lorc e
Delapouite, con altri contributori), distribuite con licenza
[CC BY 3.0](https://creativecommons.org/licenses/by/3.0/): si possono usare anche in un gioco
venduto, a patto di **citare gli autori** nei crediti del gioco. Sono state solo ricolorate di bianco.

Prima di pubblicare il gioco va aggiunta una schermata dei crediti con questa citazione, e va
controllato sul sito l'autore di ciascuna icona usata.
