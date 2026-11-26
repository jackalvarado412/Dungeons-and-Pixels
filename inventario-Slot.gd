extends Button
signal slot_clickeado(indice: int)
@onready var icono_rect: TextureRect = $Icono
@onready var cantidad_label: Label = $Cantidad
var indice_slot: int = 0
func _ready() -> void:
	pressed.connect(func(): slot_clickeado.emit(indice_slot))
func actualizar_slot(datos_item) -> void:
	if datos_item == null:
		icono_rect.texture = null
		cantidad_label.text = ""
	else:
		icono_rect.texture = datos_item["icono"]
		cantidad_label.text = str(datos_item["cantidad"]) if datos_item["cantidad"] > 1 else ""
