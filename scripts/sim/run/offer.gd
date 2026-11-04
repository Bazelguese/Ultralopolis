class_name Offer
extends RefCounted
## Una delle alternative mostrate in un'opportunità (GDD §4.2):
## un tipo di opportunità (OpportunityDef) più, se serve, l'edificio o la truppa pescati.

var opportunity: OpportunityDef
## Edificio offerto (COSTRUISCI_EDIFICIO).
var building: BuildingDef
## Truppa offerta (RECLUTA_TRUPPA).
var troop: TroopDef
## Oro da pagare.
var price: int = 0
## Ricerca da pagare.
var research_price: int = 0


var kind: OpportunityDef.Kind:
	get:
		return opportunity.kind


## Titolo breve, es. "Costruttori: Fattoria".
func describe() -> String:
	match opportunity.kind:
		OpportunityDef.Kind.COSTRUISCI_EDIFICIO:
			return "%s: %s" % [opportunity.display_name, building.display_name]
		OpportunityDef.Kind.RECLUTA_TRUPPA:
			return "%s: %s" % [opportunity.display_name, troop.display_name]
	return opportunity.display_name


## Costo leggibile, es. "3 Oro", "2 Ricerca", "gratis".
func cost_text() -> String:
	var parts: PackedStringArray = PackedStringArray()
	if price > 0:
		parts.append("%d Oro" % price)
	if research_price > 0:
		parts.append("%d Ricerca" % research_price)
	return " + ".join(parts) if not parts.is_empty() else "gratis"
