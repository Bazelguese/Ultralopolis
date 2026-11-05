class_name CatalogDef
extends Resource
## Catalogo di gioco: tutto ciò che può comparire in una run (GDD §16.2).

@export var buildings: Array[BuildingDef] = []
@export var troops: Array[TroopDef] = []
## Ere in ordine: posizione 0 = prima era.
@export var eras: Array[EraDef] = []
@export var ghosts: Array[GhostDef] = []
@export var encounters: Array[EncounterDef] = []
## Consiglieri del Consiglio, con le loro categorie (GDD §4.2, §4.2.4).
@export var advisors: Array[AdvisorDef] = []
## Popoli, governi, credi, culture e perk fra cui scegliere (GDD §9).
@export var identities: Array[IdentityDef] = []
## Regole per generare fantasmi e incontri negli anni senza dati scritti a mano.
## Se manca, si usa il fantasma più recente e nessun incontro in più.
@export var generator: GeneratorRules
