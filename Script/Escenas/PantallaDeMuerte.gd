extends CanvasLayer
const PRIMER_MUNDO = "res://Escenas/Mundos/Corruptos/mundo.tscn"
const MENU_PRINCIPAL ="res://Escenas/Mundos/Menusgeneral/menu_principal.tscn" 
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	var boton_reanudar = $Control/CenterContainer/VBoxContainer/Reanudar
	var boton_menu = $Control/CenterContainer/VBoxContainer/VolverMenu
	if not boton_reanudar.pressed.is_connected(_on_reanudar_pressed):
		boton_reanudar.pressed.connect(_on_reanudar_pressed)
	if not boton_menu.pressed.is_connected(_on_volver_menu_pressed):
		boton_menu.pressed.connect(_on_volver_menu_pressed)
func _on_reanudar_pressed():
	print("REINICIANDO PARTIDA")
	get_tree().paused = false
	Inventario.items.clear()
	get_tree().change_scene_to_file(PRIMER_MUNDO)
func _on_volver_menu_pressed():
	print("VOLVIENDO AL MENU PRINCIPAL")
	get_tree().paused = false
	get_tree().change_scene_to_file(MENU_PRINCIPAL)
