extends Control
func _ready() -> void:
	get_tree().paused = false
func _on_boton_volver_pressed() -> void:
	get_tree().change_scene_to_file(
		"res://Escenas/Mundos/Menusgeneral/menu_principal.tscn"
	)
