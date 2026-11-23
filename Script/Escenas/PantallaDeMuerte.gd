extends CanvasLayer

const AUDIOS_MUERTE := [
	preload("res://Sonido/Cache.mp3"),
	preload("res://Sonido/Fierro.mp3"),
	preload("res://Sonido/Piratas.mp3"),
	preload("res://Sonido/Reiniciar un segundo.mp3")
]
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var reproductor := get_node_or_null("AudioStreamPlayer2D")
	if reproductor:
		reproductor.stream = AUDIOS_MUERTE.pick_random()
		reproductor.volume_db = 0.0
		reproductor.play()
		print("🔊 Reproduciendo audio de muerte: ", reproductor.stream.resource_path)
	else:
		print("❌ No se encontró el nodo AudioStreamPlayer2D")
func _on_reanudar_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Escenas/Mundos/Corruptos/mundo.tscn")
func _on_volver_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Escenas/Mundos/Menusgeneral/menu_principal.tscn")
