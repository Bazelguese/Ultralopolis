class_name NationStore
extends RefCounted
## Salva e carica le nazioni create in un file JSON (in user://, cioè nella cartella
## dei dati del gioco sul PC del giocatore).

const FORMAT_VERSION: int = 1
const DEFAULT_PATH: String = "user://nazioni.json"


static func load_all(path: String = DEFAULT_PATH) -> Array[NationTemplate]:
	var nations: Array[NationTemplate] = []
	if not FileAccess.file_exists(path):
		return nations
	var json: JSON = JSON.new()
	var error: Error = json.parse(FileAccess.get_file_as_string(path))
	var parsed: Variant = json.data if error == OK else null
	if not parsed is Dictionary:
		push_warning("NationStore: file delle nazioni non leggibile (%s)." % path)
		return nations
	var list: Variant = (parsed as Dictionary).get("nazioni", [])
	if list is Array:
		for entry: Variant in list:
			if entry is Dictionary:
				nations.append(NationTemplate.from_dict(entry))
	return nations


static func save_all(nations: Array[NationTemplate], path: String = DEFAULT_PATH) -> bool:
	var list: Array[Dictionary] = []
	for nation: NationTemplate in nations:
		list.append(nation.to_dict())
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("NationStore: impossibile scrivere %s." % path)
		return false
	file.store_string(JSON.stringify({"versione": FORMAT_VERSION, "nazioni": list}, "\t"))
	file.close()
	return true


## Aggiunge la nazione o sostituisce quella con lo stesso id.
static func upsert(nation: NationTemplate, path: String = DEFAULT_PATH) -> bool:
	var nations: Array[NationTemplate] = load_all(path)
	for i: int in range(nations.size()):
		if nations[i].id == nation.id:
			nations[i] = nation
			return save_all(nations, path)
	nations.append(nation)
	return save_all(nations, path)


static func remove(nation_id: String, path: String = DEFAULT_PATH) -> bool:
	var nations: Array[NationTemplate] = load_all(path)
	var kept: Array[NationTemplate] = []
	for nation: NationTemplate in nations:
		if nation.id != nation_id:
			kept.append(nation)
	return save_all(kept, path)
