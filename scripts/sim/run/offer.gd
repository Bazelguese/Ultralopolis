class_name Offer
extends RefCounted
## Una proposta del consigliere scelto nel round (GDD §4.2): un edificio, una truppa,
## un perk oppure un'azione del Consiglio (OpportunityDef).

var kind: OpportunityDef.Kind = OpportunityDef.Kind.COSTRUISCI_EDIFICIO
## Azione proposta (null per edifici e truppe).
var opportunity: OpportunityDef
## Consigliere che fa la proposta.
var advisor: AdvisorDef
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


## true se la proposta è un edificio o una truppa.
func is_element() -> bool:
	return kind == OpportunityDef.Kind.COSTRUISCI_EDIFICIO or kind == OpportunityDef.Kind.RECLUTA_TRUPPA


## Titolo breve, es. "Fattoria", "Esattori", "Perk: Mulini".
func describe() -> String:
	match kind:
		OpportunityDef.Kind.COSTRUISCI_EDIFICIO:
			return building.display_name
		OpportunityDef.Kind.RECLUTA_TRUPPA:
			return troop.display_name
		OpportunityDef.Kind.PERK:
			# Nell'anteprima del consigliere il perk non è ancora stato pescato.
			if perk != null:
				return "Perk: %s" % perk.display_name
	return opportunity.display_name


## Descrizione completa della proposta (per le azioni e i perk).
func description() -> String:
	if kind == OpportunityDef.Kind.PERK and perk != null:
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
