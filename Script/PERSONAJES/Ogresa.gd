extends CharacterBody2D
signal vida_cambiada(vida_actual, vida_maxima)
signal ogresa_derrotada
@export var vida_maxima: int = 100
var vida_actual: int = 100
var esta_derrotada: bool = false
@onready var barra_vida: ProgressBar = $BarraVida
func _ready() -> void:
	add_to_group("Ogresa")
	vida_actual = vida_maxima
	barra_vida.max_value = vida_maxima
	barra_vida.value = vida_actual
	vida_cambiada.connect(actualizar_barra_vida)
	print("Ogresa lista. Vida: ", vida_actual, "/", vida_maxima)
func actualizar_barra_vida(vida: int, vida_maxima_personaje: int) -> void:
	barra_vida.max_value = vida_maxima_personaje
	barra_vida.value = vida
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		recibir_danio(20)
func recibir_danio(cantidad: int) -> void:
	if esta_derrotada or cantidad <= 0:
		return
	vida_actual = clampi(vida_actual - cantidad, 0, vida_maxima)
	print("La Ogresa recibió daño. Vida: ", vida_actual)
	vida_cambiada.emit(vida_actual, vida_maxima)
	if vida_actual <= 0:
		morir()
func recibir_daño(cantidad: int) -> void:
	recibir_danio(cantidad)
func curar(cantidad: int) -> void:
	if esta_derrotada or cantidad <= 0:
		return
	vida_actual = clampi(vida_actual + cantidad, 0, vida_maxima)
	vida_cambiada.emit(vida_actual, vida_maxima)
	print("La Ogresa recuperó vida: ", vida_actual)
func morir() -> void:
	if esta_derrotada:
		return
	esta_derrotada = true
	print("¡La Ogresa fue derrotada!")
	ogresa_derrotada.emit()
