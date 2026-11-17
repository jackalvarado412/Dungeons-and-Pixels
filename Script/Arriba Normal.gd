extends Area2D
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		call_deferred("change_scene")
func change_scene() -> void:
	get_tree().change_scene_to_file("res://Escenas/Mundos/normales/mundo_normal.tscn")
