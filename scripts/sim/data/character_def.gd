class_name CharacterDef
extends Resource
## Un personaggio ricorrente delle cronache (GDD §9.6, v0.29): un ruolo (generale, erede,
## profeta, mercante straniero) e i nomi fra cui la run ne pesca uno. Contiene solo dati.

@export var id: StringName = &""
## Ruolo, come lo legge il giocatore: "Generale", "Erede"...
@export var role: String = ""
## Nomi possibili; la run ne sceglie uno con il suo seme.
@export var names: PackedStringArray = PackedStringArray()
## Chi è, in breve. {nome} diventa il nome scelto.
@export_multiline var description: String = ""
