extends Area2D
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		call_deferred("mostrar_fin_beta")
func mostrar_fin_beta() -> void:
	get_tree().change_scene_to_file(
		"res://Escenas/Mundos/Menusgeneral/Fin de la beta.tscn"
	)
