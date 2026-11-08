class_name VistaRigaSimboli
extends Control
## Una riga di simboli dentro l'interfaccia 2D (es. nella legenda), disegnata come sulle carte.
## Solo presentazione.

var riga: RigaSimboli
## Senza pastiglia si disegnano solo i simboli, senza il fondo scuro.
var con_pastiglia: bool = true


static func crea(p_riga: RigaSimboli, altezza: float, p_con_pastiglia: bool = true) -> VistaRigaSimboli:
	var vista: VistaRigaSimboli = VistaRigaSimboli.new()
	vista.riga = p_riga
	vista.con_pastiglia = p_con_pastiglia
	vista.custom_minimum_size = Vector2(DisegnoSimboli.larghezza_pastiglia(p_riga, altezza), altezza)
	vista.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	vista.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	vista.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return vista


func _draw() -> void:
	var area: Rect2 = Rect2(Vector2.ZERO, size)
	if con_pastiglia:
		DisegnoSimboli.pastiglia(self, riga, area)
	else:
		DisegnoSimboli.disegna_riga(self, riga, area)
