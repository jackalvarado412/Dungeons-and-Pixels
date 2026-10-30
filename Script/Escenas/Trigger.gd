extends Area2D
@export var ruta_cinematica : String
func _on_body_entered(body):
	if body.is_in_group("Jugador"):
		get_tree().change_scene_to_file(ruta_cinematica)
