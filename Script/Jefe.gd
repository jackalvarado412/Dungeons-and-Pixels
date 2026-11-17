extends CharacterBody2D
@export var timer_ataque: Timer
@export_file("*.tscn") var escena_al_morir: String = ""
var speed = 150
var player_chase = false
var player = null
var vida := 1
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
	if vida <= 0:
		return
	vida -= cantidad
	print("Vida enemigo:", vida)
	if vida <= 0:
		morir()
func morir() -> void:
	if escena_al_morir != "":
		hide()
		$CollisionShape2D.set_deferred("disabled", true)
		set_physics_process(false)
		await sacudir_camara(1.5, 10.0)
		get_tree().call_deferred("change_scene_to_file", escena_al_morir)
	queue_free()
func sacudir_camara(duracion: float, intensidad: float) -> void:
	var camara = get_viewport().get_camera_2d()
	if not camara:
		return
	var tiempo_transcurrido := 0.0
	while tiempo_transcurrido < duracion:
		camara.offset = Vector2(
			randf_range(-intensidad, intensidad),
			randf_range(-intensidad, intensidad)
		)
		await get_tree().process_frame
		tiempo_transcurrido += get_process_delta_time()
	camara.offset = Vector2.ZERO
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
