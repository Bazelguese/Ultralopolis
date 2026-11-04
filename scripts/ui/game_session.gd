extends Node
## Sessione di gioco (caricata automaticamente all'avvio, nome globale: GameSession).
## Ricorda fra una schermata e l'altra quale nazione si gioca o si modifica,
## e porta da una schermata all'altra. Nessuna regola di gioco qui.

const MENU_SCENE: String = "res://scenes/main_menu.tscn"
const SELECT_SCENE: String = "res://scenes/nation_select.tscn"
const CREATOR_SCENE: String = "res://scenes/nation_creator.tscn"
## Partita sulla plancia 3D (GDD §14.2).
const GAME_SCENE: String = "res://scenes/partita_3d.tscn"

const CATALOG_PATH: String = "res://data/catalog/catalog.tres"
const RUN_RULES_PATH: String = "res://data/rules/run_rules.tres"
const BATTLE_RULES_PATH: String = "res://data/rules/battle_rules.tres"
const RESISTANCE_RULES_PATH: String = "res://data/rules/resistance_rules.tres"

## File in cui si salvano le nazioni create.
var store_path: String = NationStore.DEFAULT_PATH
## Nazione scelta per giocare.
var selected_nation: NationTemplate
## Nazione aperta nella schermata di creazione per essere modificata (null = nuova).
var editing_nation: NationTemplate
## Schermata a cui torna la creazione dopo Salva o Annulla.
var creator_return_scene: String = MENU_SCENE
## Nei test si spegne per non cambiare davvero schermata.
var navigation_enabled: bool = true
## Ultima schermata richiesta (utile ai test).
var last_scene_request: String = ""


func catalog() -> CatalogDef:
	return load(CATALOG_PATH) as CatalogDef


func run_rules() -> RunRules:
	return load(RUN_RULES_PATH) as RunRules


func battle_rules() -> BattleRules:
	return load(BATTLE_RULES_PATH) as BattleRules


func resistance_rules() -> ResistanceRules:
	return load(RESISTANCE_RULES_PATH) as ResistanceRules


func saved_nations() -> Array[NationTemplate]:
	return NationStore.load_all(store_path)


func go(scene_path: String) -> void:
	last_scene_request = scene_path
	if navigation_enabled:
		get_tree().change_scene_to_file.call_deferred(scene_path)


## "Gioca": la lista delle nazioni se ce ne sono, altrimenti la creazione.
func play() -> void:
	if saved_nations().is_empty():
		open_creator(null, SELECT_SCENE)
	else:
		go(SELECT_SCENE)


func open_creator(nation: NationTemplate, return_scene: String) -> void:
	editing_nation = nation
	creator_return_scene = return_scene
	go(CREATOR_SCENE)


func start_game(nation: NationTemplate) -> void:
	selected_nation = nation
	go(GAME_SCENE)


## Identificativo nuovo per una nazione.
func new_nation_id() -> String:
	return "nazione_%d_%d" % [Time.get_unix_time_from_system(), randi() % 100000]
