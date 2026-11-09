class_name TestNationDef
extends Resource
## Nazione di test: serve solo per provare il gioco, non è una regola (convenzione §16.3).
## Compare sempre nella lista delle nazioni e parte con una dotazione diversa da quella
## normale (RunRules): le risorse indicate qui e, se richiesto, tutti gli spazi della plancia.

## Nome mostrato nella lista e in partita.
@export var nation_name: String = "Nazione di test"
## Risorse di partenza, in unità intere: prendono il posto della dotazione normale
## (Oro e Ricerca iniziali delle regole della run).
@export var starting_resources: ResourceAmounts
## Se vero, la plancia parte con tutti gli spazi edificio e truppa liberi (i massimi delle regole).
@export var open_all_slots: bool = true


## Testo breve per la lista delle nazioni, es. "99 Oro + 99 Cibo · tutti gli spazi liberi".
func describe() -> String:
	var parts: PackedStringArray = PackedStringArray()
	if starting_resources != null and not starting_resources.is_empty():
		parts.append(starting_resources.describe())
	if open_all_slots:
		parts.append("tutti gli spazi liberi")
	return " · ".join(parts)
