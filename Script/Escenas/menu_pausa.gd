extends CanvasLayer
func _ready():
	hide()
	get_tree().paused = false
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pausa()
func toggle_pausa():
	var esta_pausado = get_tree().paused
	get_tree().paused = !esta_pausado
	if get_tree().paused:
		show()
	else:
		hide()
func _on_continuar_pressed():
	toggle_pausa()
func _on_salir_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Escenas/menu_principal.tscn") 
