extends Area2D

@export var item_id: String = "Memoria_RAM"
@export var cantidad: int = 1
@export var icono: Texture2D

var jugador_en_rango: Node2D = null

@onready var indicacion: Label = get_node_or_null("Indicacion")


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if indicacion:
		indicacion.text = "[E] Recoger"
		indicacion.hide()


func _process(_delta: float) -> void:
	if jugador_en_rango == null:
		return

	if Input.is_action_just_pressed("Accion"):
		var textura = icono

		if textura == null:
			textura = $Sprite2D.texture

		if textura == null:
			push_error("El objeto no tiene una textura asignada: " + item_id)
			return

		if GameState.agregar_item(item_id, textura, cantidad):
			print("Recogiste: ", item_id)
			queue_free()
		else:
			print("No se pudo agregar el objeto. ¿Inventario lleno?")
			
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		jugador_en_rango = body

		if indicacion:
			indicacion.show()


func _on_body_exited(body: Node2D) -> void:
	if body == jugador_en_rango:
		jugador_en_rango = null

		if indicacion:
			indicacion.hide()
