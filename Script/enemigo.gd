extends CharacterBody2D
@onready var timer_ataque: Timer = $"Tiempo ataque"
var speed: float = 250.0
var player_chase: bool = false
var objetivos_detectados: Array[Node2D] = []
var objetivo_actual: Node2D = null
var vida: int = 50
var daño: int = 10
var puede_atacar: bool = true
func _ready() -> void:
	add_to_group("Enemigo")
func _physics_process(_delta: float) -> void:
	seleccionar_objetivo()
	if objetivo_actual != null and is_instance_valid(objetivo_actual):
		var distancia = global_position.distance_to(
			objetivo_actual.global_position
		)
		if distancia < 35:
			velocity = Vector2.ZERO
			atacar_objetivo()
		else:
			var direccion = (
				objetivo_actual.global_position - global_position
			).normalized()
			velocity = direccion * speed
			move_and_slide()
			$AnimatedSprite2D.play("Movimiento")
	else:
		velocity = Vector2.ZERO
		player_chase = false
func _on_detencion_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador") or body.is_in_group("Ogresa"):
		if not objetivos_detectados.has(body):
			objetivos_detectados.append(body)
		player_chase = true
		print("Objetivo detectado: ", body.name)
func _on_detencion_area_body_exited(body: Node2D) -> void:
	if objetivos_detectados.has(body):
		objetivos_detectados.erase(body)
	if body == objetivo_actual:
		objetivo_actual = null
	if objetivos_detectados.is_empty():
		player_chase = false
		velocity = Vector2.ZERO
func seleccionar_objetivo() -> void:
	var distancia_menor: float = INF
	var objetivo_mas_cercano: Node2D = null
	for personaje in objetivos_detectados:
		if not is_instance_valid(personaje):
			continue
		if personaje.is_in_group("Ogresa"):
			if personaje.get("esta_derrotada") == true:
				continue
		var distancia = global_position.distance_to(
			personaje.global_position
		)
		if distancia < distancia_menor:
			distancia_menor = distancia
			objetivo_mas_cercano = personaje
	objetivo_actual = objetivo_mas_cercano
	player_chase = objetivo_actual != null
func recibir_daño(cantidad: int) -> void:
	vida -= cantidad
	print("Vida enemigo: ", vida)
	if vida <= 0:
		queue_free()
func atacar_objetivo() -> void:
	if objetivo_actual == null:
		return
	if not is_instance_valid(objetivo_actual):
		return
	if puede_atacar:
		if objetivo_actual.has_method("recibir_daño"):
			print("¡La araña golpeó a: ", objetivo_actual.name, "!")
			objetivo_actual.recibir_daño(daño)
			puede_atacar = false
			timer_ataque.start()
func _on_tiempo_ataque_timeout() -> void:
	puede_atacar = true
func enemy():
	pass
func _on_area_2d_2_body_entered(body: Node2D) -> void:
	pass
func _on_area_2d_3_body_entered(body: Node2D) -> void:
	pass
func _on_area_2d_4_body_entered(body: Node2D) -> void:
	pass
func _on_area_2d_body_entered(body: Node2D) -> void:
	pass
func _on_area_2d_5_body_entered(body: Node2D) -> void:
	pass
