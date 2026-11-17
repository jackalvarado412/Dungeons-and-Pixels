extends CharacterBody2D
@export var vida_maxima: int = 300
var vida: int
func _ready() -> void:
	vida = vida_maxima
	add_to_group("Jefe")
func recibir_daño(cantidad: int) -> void:
	if vida <= 0:
		return
	vida = max(vida - cantidad, 0)
	print("Vida del jefe: ", vida, "/", vida_maxima)
	if vida == 0:
		_derrotado()
func _derrotado() -> void:
	GameState.derrotar_jefe()
	queue_free()
