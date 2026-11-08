class_name DeedDef
extends Resource
## Un'impresa (GDD §10.4.1, v0.27): l'obiettivo che completa un passo dell'albero di una via.
## Un traguardo conta ciò che si fa dopo l'adozione della via; un'impresa di stato guarda
## com'è la nazione e basta raggiungerla una volta. Contiene solo dati: le regole stanno in RunState.

enum Kind {
	VITTORIE,             ## Traguardo: vincere (o pareggiare) N scontri.
	TECNOLOGIE,           ## Traguardo: completare N tecnologie (della sfera, se indicata).
	PROPOSTE,             ## Traguardo: prendere N proposte dal consigliere indicato.
	EVENTI,               ## Traguardo: scegliere N Eventi di una delle sfere indicate.
	CARTE,                ## Stato: avere sulla plancia N carte con uno dei tipi indicati.
	CARTE_LIVELLO,        ## Stato: avere N carte con uno dei tipi, al livello minimo indicato.
	PRODUZIONE,           ## Stato: raccogliere in una sola produzione almeno N della risorsa.
	MALCONTENTO_MASSIMO,  ## Stato: chiudere un anno con il Malcontento a N o meno.
}

## Scontri che contano per VITTORIE.
enum Battles {
	TUTTI,
	FANTASMI,
	INCONTRI,
}

## Carte che contano per CARTE e CARTE_LIVELLO.
enum Pieces {
	QUALSIASI,
	EDIFICI,
	TRUPPE,
}

@export var kind: Kind = Kind.VITTORIE
## Quantità da raggiungere (per MALCONTENTO_MASSIMO: il Malcontento massimo).
@export var amount: int = 1
@export var battles: Battles = Battles.TUTTI
## Sfere (categorie) per TECNOLOGIE ed EVENTI; vuoto = qualsiasi.
@export var spheres: PackedStringArray = PackedStringArray()
## Consigliere per PROPOSTE (id).
@export var advisor_id: StringName = &""
## Nome del consigliere, per il testo.
@export var advisor_name: String = ""
## Tipi per CARTE e CARTE_LIVELLO (basta uno).
@export var types: Array[StringName] = []
@export var pieces: Pieces = Pieces.QUALSIASI
## Livello minimo per CARTE_LIVELLO.
@export var min_level: int = 2
## Risorsa per PRODUZIONE.
@export var resource: Res.Type = Res.Type.ORO


## true per i traguardi, che contano solo dopo l'adozione della via.
func is_milestone() -> bool:
	return kind in [Kind.VITTORIE, Kind.TECNOLOGIE, Kind.PROPOSTE, Kind.EVENTI]


## L'impresa in una riga, come la legge il giocatore.
func describe() -> String:
	match kind:
		Kind.VITTORIE:
			var what: String = "scontri"
			if battles == Battles.FANTASMI:
				what = "scontri con il fantasma"
			elif battles == Battles.INCONTRI:
				what = "incontri del mondo"
			return "Vinci %d %s" % [amount, what]
		Kind.TECNOLOGIE:
			if spheres.is_empty():
				return "Completa %d tecnologie" % amount
			return "Completa %d tecnologie di %s" % [amount, " o ".join(spheres)]
		Kind.PROPOSTE:
			return "Prendi %d opportunità da: %s" % [amount, advisor_name if advisor_name != "" else String(advisor_id)]
		Kind.EVENTI:
			return "Scegli %d Eventi di %s" % [amount, " o ".join(spheres)] if not spheres.is_empty() else "Scegli %d Eventi" % amount
		Kind.CARTE:
			return "Abbi %d %s %s sulla plancia" % [amount, _pieces_word(), _types_text()]
		Kind.CARTE_LIVELLO:
			return "Abbi %d %s %s al livello %d o più" % [amount, _pieces_word(), _types_text(), min_level]
		Kind.PRODUZIONE:
			return "Raccogli almeno %d %s in una sola produzione" % [amount, Res.NAMES[resource]]
		Kind.MALCONTENTO_MASSIMO:
			return "Chiudi un anno con il Malcontento a %d o meno" % amount
	return "?"


func _pieces_word() -> String:
	match pieces:
		Pieces.EDIFICI:
			return "edifici"
		Pieces.TRUPPE:
			return "truppe"
	return "tessere"


func _types_text() -> String:
	var names: PackedStringArray = PackedStringArray()
	for card_type: StringName in types:
		names.append(String(card_type))
	return " o ".join(names)
