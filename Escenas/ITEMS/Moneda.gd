extends Area2D
@export var valor: int = 1
var jugador_en_rango: bool = false
@onready var indicacion: Label = $Label
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	indicacion.text = "[E] Recoger"
	indicacion.hide()
func _process(_delta: float) -> void:
	if jugador_en_rango and Input.is_action_just_pressed("Accion"):
		GameState.agregar_monedas(valor)
		queue_free()
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		jugador_en_rango = true
		indicacion.show()
func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		jugador_en_rango = false
		indicacion.hide()
