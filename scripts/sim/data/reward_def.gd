class_name RewardDef
extends Resource
## Una ricompensa che un incontro del mondo può offrire (GDD §3.3).

enum Kind {
	ORO,
	RICERCA,
	EDIFICIO,
	TRUPPA,
	PERK,
	RISORSA,  ## Una risorsa del Magazzino diversa da Oro e Ricerca (vedi "resource").
	TECNOLOGIA,  ## Una tecnologia già iniziata, una carta dorata (GDD §10.5.6, v0.25).
}

@export var kind: Kind = Kind.ORO
## Quantità di Oro o Ricerca (per ORO e RICERCA).
@export var amount: int = 0
## Edificio regalato (per EDIFICIO).
@export var building: BuildingDef
## Truppa regalata (per TRUPPA).
@export var troop: TroopDef
## Perk ottenuto (per PERK).
@export var perk: IdentityDef
## Risorsa ricevuta (per RISORSA), in unità intere indicate da "amount".
@export var resource: Res.Type = Res.Type.LEGNO
## Tecnologia già iniziata (per TECNOLOGIA). Se manca, una tecnologia a caso fra quelle che la
## nazione può ricercare nella sua era.
@export var tech: TechDef


func describe() -> String:
	match kind:
		Kind.ORO:
			return "%d Oro" % amount
		Kind.RICERCA:
			return "%d Ricerca" % amount
		Kind.EDIFICIO:
			return "Edificio: %s" % (building.display_name if building != null else "?")
		Kind.TRUPPA:
			return "Truppa: %s" % (troop.display_name if troop != null else "?")
		Kind.PERK:
			return "Perk: %s" % (perk.display_name if perk != null else "?")
		Kind.RISORSA:
			return "%d %s" % [amount, Res.NAMES[resource]]
		Kind.TECNOLOGIA:
			return "Tecnologia già iniziata: %s" % (tech.display_name if tech != null else "a caso")
	return "?"
