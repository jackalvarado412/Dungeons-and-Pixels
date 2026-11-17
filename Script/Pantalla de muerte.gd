extends CanvasLayer
const PRIMER_MUNDO = "res://Escenas/Mundos/mundo.tscn"
const MENU_PRINCIPAL = "res://Escenas/menu_principal.tscn"
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	$Control/VBoxContainer/Reanudar.pressed.connect(_on_reanudar_pressed)
	$Control/VBoxContainer/VolverMenu.pressed.connect(_on_volver_menu_pressed)
func _on_reanudar_pressed():
	get_tree().paused = false
	Inventario.items.clear()
	get_tree().change_scene_to_file(PRIMER_MUNDO)
func _on_volver_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file(MENU_PRINCIPAL)
