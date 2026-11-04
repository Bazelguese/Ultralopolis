class_name Offer
extends RefCounted
## Una proposta di un consigliere (GDD §4.2): un edificio, una truppa, un perk
## oppure un'azione (OpportunityDef).

var kind: OpportunityDef.Kind = OpportunityDef.Kind.SCAMBIO_RISORSE
## Il consigliere che la propone (può essere null nei test che creano offerte a mano).
var councillor: CouncillorDef
## L'azione proposta; null per un semplice edificio o una semplice truppa.
var opportunity: OpportunityDef
## Edificio offerto (COSTRUISCI_EDIFICIO).
var building: BuildingDef
## Truppa offerta (RECLUTA_TRUPPA).
var troop: TroopDef
## Perk offerto (PERK).
var perk: IdentityDef
## Oro da pagare.
var price: int = 0
## Ricerca da pagare.
var research_price: int = 0
## Altre risorse da pagare (può essere null).
var other_cost: ResourceAmounts


static func of_building(def: BuildingDef, p_councillor: CouncillorDef = null) -> Offer:
	var offer: Offer = Offer.new()
	offer.kind = OpportunityDef.Kind.COSTRUISCI_EDIFICIO
	offer.building = def
	offer.price = def.cost_gold
	offer.councillor = p_councillor
	return offer


static func of_troop(def: TroopDef, p_councillor: CouncillorDef = null) -> Offer:
	var offer: Offer = Offer.new()
	offer.kind = OpportunityDef.Kind.RECLUTA_TRUPPA
	offer.troop = def
	offer.price = def.cost_gold
	offer.councillor = p_councillor
	return offer


static func of_action(def: OpportunityDef, p_councillor: CouncillorDef = null) -> Offer:
	var offer: Offer = Offer.new()
	offer.kind = def.kind
	offer.opportunity = def
	offer.price = def.cost_gold
	offer.research_price = def.cost_research
	offer.other_cost = def.cost_resources
	offer.councillor = p_councillor
	return offer


## Nome di ciò che si prende, es. "Fattoria", "Esattori", "Perk: Mercanti abili".
func title() -> String:
	if building != null:
		return building.display_name
	if troop != null:
		return troop.display_name
	if perk != null:
		return perk.display_name
	if opportunity != null:
		return opportunity.display_name
	return "?"


## Titolo con il consigliere, es. "Architetto: Fattoria".
func describe() -> String:
	if councillor != null:
		return "%s: %s" % [councillor.display_name, title()]
	return title()


## Spiegazione per il giocatore.
func description() -> String:
	if perk != null:
		return perk.description
	if opportunity != null:
		return opportunity.description
	return ""


## Costo leggibile, es. "3 Oro", "2 Ricerca", "gratis".
func cost_text() -> String:
	var parts: PackedStringArray = PackedStringArray()
	if price > 0:
		parts.append("%d Oro" % price)
	if research_price > 0:
		parts.append("%d Ricerca" % research_price)
	if other_cost != null and not other_cost.is_empty():
		parts.append(other_cost.describe())
	return " + ".join(parts) if not parts.is_empty() else "gratis"
