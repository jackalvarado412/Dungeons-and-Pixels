extends CharacterBody2D
@export var velocidad := 80.0
var jugador = null
func _physics_process(delta):
	if jugador:
		var direccion = (jugador.global_position - global_position).normalized()
		velocity = direccion * velocidad
		move_and_slide()
		if direccion.x < 0:
			$Sprite2D.flip_h = true
		elif direccion.x > 0:
			$Sprite2D.flip_h = false
	else:
		velocity = Vector2.ZERO
		move_and_slide()
func _on_detector_jugador_body_entered(body):
	if body.is_in_group("Jugador"):
		jugador = body
func _on_detector_jugador_body_exited(body):
	if body == jugador:
		jugador = null
var vida := 50
func recibir_daño(cantidad):
	vida -= cantidad
	print("Vida enemigo:", vida)
	if vida <= 0:
		queue_free()
