extends CanvasLayer
@onready var botones_menu: VBoxContainer = $Control/VBoxContainer
@onready var inventario_ui: Control = $Control/InventarioUI
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	get_tree().paused = false
	inventario_ui.cerrado.connect(_al_cerrar_inventario)
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pausa()
func toggle_pausa() -> void:
	var esta_pausado = get_tree().paused
	get_tree().paused = !esta_pausado
	if get_tree().paused:
		botones_menu.show()
		inventario_ui.hide()
		show()
	else:
		hide()
func _on_continuar_pressed() -> void:
	toggle_pausa()
func _on_salir_pressed() -> void:
	get_tree().paused = false
	hide()
	get_tree().change_scene_to_file("res://Escenas/Mundos/Menusgeneral/menu_principal.tscn")
func _on_inventario_pressed() -> void:
	botones_menu.hide()
	inventario_ui.refrescar_inventario()
	inventario_ui.show()
func _al_cerrar_inventario() -> void:
	botones_menu.show()
