extends Area2D
@export var item_id:String = "pocion"
@export var cantidad:int = 1
func _ready() -> void:
	body_entered.connect(_on_body_entered)
func _on_body_entered(body:Node2D) -> void:
	if body.is_in_group("jugador"):
		Inventario.agregar_item(item_id, cantidad)
		print("Recogiste:", item_id)
		queue_free()
