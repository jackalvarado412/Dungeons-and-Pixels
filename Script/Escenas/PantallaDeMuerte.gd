extends CanvasLayer
func _on_reanudar_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Escenas/Mundos/Corruptos/mundo.tscn")
func _on_volver_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Escenas/Mundos/Menusgeneral/menu_principal.tscn")
