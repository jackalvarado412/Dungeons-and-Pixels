extends CharacterBody2D

@onready var timer_ataque: Timer = $"Tiempo ataque"

# MOVIMIENTO
var speed = 120
var player_chase = false
var player = null

# VIDA
var vida := 50

# ATAQUE
var daño := 10
var puede_atacar := true

# DETECTAR JUGADOR
var objetivos_en_rango: Array = []

func _ready():
	add_to_group("Enemigo")
	call_deferred("actualizar_objetivo")

func _physics_process(_delta):
	if player_chase and is_instance_valid(player):
		var direccion = (player.global_position - global_position).normalized()
		velocity = direccion * speed
		move_and_slide()
		$AnimatedSprite2D.play("Movimiento")
	else:
		velocity = Vector2.ZERO
		
	if is_instance_valid(player):
		atacar_jugador()

func _on_detencion_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador") or body.is_in_group("Ogresa"):
		if not body in objetivos_en_rango:
			objetivos_en_rango.append(body)
		actualizar_objetivo()

func _on_detencion_area_body_exited(body: Node2D) -> void:
	if body in objetivos_en_rango:
		objetivos_en_rango.erase(body)
	actualizar_objetivo()

func actualizar_objetivo() -> void:
	player = null
	player_chase = false
	
	# 1. Prioridad: Buscar al Player dentro del área de detección
	for obj in objetivos_en_rango:
		if is_instance_valid(obj) and obj.is_in_group("Jugador") and not obj.is_in_group("Ogresa"):
			player = obj
			player_chase = true
			return
			
	# 2. Si el Player no está cerca, buscar a la Ogresa directamente
	var ogresa = get_tree().get_first_node_in_group("Ogresa")
	if is_instance_valid(ogresa):
		player = ogresa
		player_chase = true

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
		if global_position.distance_to(player.global_position) < 35:
			if player.has_method("recibir_daño"):
				print("¡El enemigo golpeó al jugador!")
				player.recibir_daño(daño)
			puede_atacar = false
			timer_ataque.start()

func _on_tiempo_ataque_timeout():
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
