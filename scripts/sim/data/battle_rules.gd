class_name BattleRules
extends Resource
## Regole numeriche della battaglia (GDD §7.5, §16.3). Valori placeholder.

## Durata di un passo della simulazione, in millisecondi (convenzione §16.3).
@export var tick_ms: int = 100

@export_group("Logoramento")
## Momento in cui inizia il logoramento (GDD §7.5: 45 secondi).
@export var attrition_start_ms: int = 45000
## Ogni quanto il logoramento colpisce, in millisecondi.
@export var attrition_interval_ms: int = 1000
## Danno del primo colpo di logoramento (placeholder).
@export var attrition_first_damage: int = 1
## Aumento del danno a ogni colpo successivo (placeholder).
@export var attrition_damage_increase: int = 1

@export_group("Inefficienza")
## Velocità del timer di un elemento rallentato, in percentuale (GDD §7.7: metà velocità).
@export var inefficiency_speed_percent: int = 50

@export_group("Sicurezza")
## Protezione tecnica contro dati sbagliati che impedirebbero la fine dello scontro.
## Non è una regola di gioco: con il logoramento attivo non dovrebbe mai scattare.
@export var safety_limit_ms: int = 3600000
