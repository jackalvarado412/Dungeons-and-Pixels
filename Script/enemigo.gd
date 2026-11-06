extends CharacterBody2D
# MOVIMIENTO
var speed = 50
var player_chase = false
var player = null
# VIDA
var vida := 50
# ATAQUE
var daño := 10
var puede_atacar := true
func _ready():
	add_to_group("Enemigo")
func _physics_process(delta):
	if player_chase and is_instance_valid(player):
		var direccion = (player.global_position - global_position).normalized()
		velocity = direccion * speed
		move_and_slide()
		$AnimatedSprite2D.play("Movimiento")
	else:
		velocity = Vector2.ZERO
	if is_instance_valid(player):
		atacar_jugador()
# DETECTAR JUGADOR
func _on_detencion_area_body_entered(body):
	if body.is_in_group("Jugador"):
		player = body
		player_chase = true
func _on_detencion_area_body_exited(body):
	if body == player:
		player = null
		player_chase = false
		velocity = Vector2.ZERO
# RECIBIR DAÑO
func recibir_daño(cantidad):
	vida -= cantidad
	print("Vida enemigo:", vida)
	if vida <= 0:
		queue_free()
# ATAQUE AL JUGADOR
func atacar_jugador():
	if player == null or !is_instance_valid(player):
		return
	if puede_atacar:
		if global_position.distance_to(player.global_position) < 25:
			if player.has_method("recibir_daño"):
				player.recibir_daño(daño)
			puede_atacar = false
			$TiempoAtaque.start()
func _on_tiempo_ataque_timeout():
	puede_atacar = true
func enemy():
	pass
