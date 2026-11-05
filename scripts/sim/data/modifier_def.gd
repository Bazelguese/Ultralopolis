class_name ModifierDef
extends Resource
## Scheda di un modificatore (GDD §8.2): bersaglio, effetto, durata e cumulabilità.
## L'origine (chi l'ha inflitto) si aggiunge quando il modificatore viene applicato.
## Lo stesso sistema serve per i malus e per i bonus (perk, ricompense durature).

enum Effect {
	PRODUZIONE_ORO,       ## Percentuale sull'Oro prodotto a ogni fase (-50 = dimezzato).
	PRODUZIONE_RICERCA,   ## Percentuale sulla Ricerca prodotta a ogni fase.
	INTERVALLO_MANA,      ## Percentuale sull'intervallo di produzione di mana di un edificio (+50 = più lento).
	RICARICA_TRUPPA,      ## Percentuale sulla ricarica di una truppa (+50 = più lenta).
	COSTO_RINNOVO,        ## Oro in più (o in meno) per rinnovare le offerte.
	ALTERNATIVE_OFFERTE,  ## Alternative in più (o in meno) in ogni opportunità.
	RESISTENZA,           ## Resistenza in più (o in meno) negli scontri.
	PRODUZIONE_PERCENTUALE,   ## Percentuale sulla produzione della risorsa indicata in "resource".
	PRODUZIONE_PER_EDIFICIO,  ## Unità in più della risorsa "resource" per ogni edificio interessato.
	DANNO_TRUPPA,             ## Percentuale sul danno di una truppa.
	VALORE_PERCENTUALE,       ## Percentuale su un valore di battaglia ("battle_value") di edifici e truppe.
	VALORE_FISSO,             ## Unità in più su un valore di battaglia, solo per chi lo ha già.
	SCUDO_INIZIALE,           ## Scudo con cui la nazione inizia ogni scontro (GDD §8.2, v0.16).
	CORRUZIONE_INIZIALE,      ## Corruzione con cui la nazione inizia ogni scontro.
	SABOTAGGIO_INIZIALE,      ## Millisecondi di Sabotaggio su un edificio a caso a inizio scontro.
	CIBO_TRUPPA,              ## Percentuale sul Cibo consumato da una truppa (GDD §5.4).
}

## Valori di battaglia di edifici e truppe che un modificatore può cambiare.
enum BattleValue {
	DANNO,
	SCUDO,
	CURA,
	CORRUZIONE,
	ASSEDIO,
	INEFFICIENZA,
	SABOTAGGIO,
}

enum Target {
	NAZIONE,          ## Tutta la nazione.
	EDIFICIO_A_CASO,  ## Un edificio scelto a caso quando il modificatore viene applicato.
	TRUPPA_A_CASO,    ## Una truppa scelta a caso quando il modificatore viene applicato.
	EDIFICIO_SCELTO,  ## Un edificio scelto dal giocatore.
	TRUPPA_SCELTA,    ## Una truppa scelta dal giocatore.
}

enum Duration {
	ANNI,                       ## Anni interi (vedi duration_years).
	PROSSIMO_SCONTRO_FANTASMA,  ## Finisce dopo il prossimo scontro con il fantasma.
	PERMANENTE,                 ## Dura tutta la run (es. tratti dell'identità e perk).
}

## Che cosa succede se lo stesso modificatore arriva di nuovo (GDD §8.2).
enum Stacking {
	ALLUNGA_DURATA,  ## Si allunga solo la durata (scelta di Davide per i malus).
	SOMMA_EFFETTI,   ## Si aggiunge una seconda copia: gli effetti si sommano.
	NESSUN_EFFETTO,  ## Il secondo non ha effetto.
}

@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""
## true = malus, false = bonus. Serve solo per mostrarlo al giocatore.
@export var is_malus: bool = true
@export var effect: Effect = Effect.PRODUZIONE_RICERCA
@export var target: Target = Target.NAZIONE
## Se indicata, l'effetto vale solo per gli edifici o le truppe con questo tipo (GDD §6.6).
@export var target_type: StringName = &""
## In alternativa: l'effetto vale per gli elementi che hanno almeno uno di questi tipi.
@export var target_types_any: Array[StringName] = []
## Risorsa interessata (per PRODUZIONE_PERCENTUALE e PRODUZIONE_PER_EDIFICIO).
@export var resource: Res.Type = Res.Type.ORO
## Valore di battaglia interessato (per VALORE_PERCENTUALE e VALORE_FISSO).
@export var battle_value: BattleValue = BattleValue.DANNO
## Percentuale per gli effetti in percentuale, numero intero per gli altri.
@export var amount: int = 0
@export var duration_kind: Duration = Duration.ANNI
## Anni interi in cui resta attivo, a partire dall'anno successivo a quello in cui arriva.
@export var duration_years: int = 1
@export var stacking: Stacking = Stacking.ALLUNGA_DURATA
