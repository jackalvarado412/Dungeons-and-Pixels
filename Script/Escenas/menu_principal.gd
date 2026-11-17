extends Control
const PRIMER_MUNDO := "res://Escenas/Mundos/Corruptos/mundo.tscn"
func _ready() -> void:
	print("Menu principal cargado correctamente")
func _on_jugar_pressed() -> void:
	print("Se presiono el boton JUGAR")
	GameState.iniciar_partida()
	var resultado = get_tree().change_scene_to_file(PRIMER_MUNDO)
	if resultado != OK:
		print("ERROR al cargar el primer mundo. Codigo: ", resultado)
	else:
		print("Cargando primer mundo...")
func _on_salir_pressed() -> void:
	get_tree().quit()
