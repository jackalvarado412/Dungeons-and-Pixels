extends CharacterBody2D

enum Estado {
	PERSIGUIENDO,
	CARGANDO,
	EMBESTIDA,
	ATURDIDO
}

@export var vida_maxima: int = 300
var vida: int
@export var velocidad_persecucion: float = 90.0
@export var velocidad_embestida: float = 500.0
@export var daño: int = 20
@export var tiempo_carga: float = 1.0
@export var tiempo_aturdido: float = 2.0
@export var duracion_embestida: float = 0.5
@export var distancia_golpe: float = 35.0

# Nombres de animaciones ajustados a tu AnimatedSprite2D
@export var animacion_movimiento: String = "Movimiento"
@export var animacion_carga: String = "Ataque"
@export var animacion_embestida: String = "Ataque"
@export var animacion_aturdido: String = "Quieto"

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var estado_actual = Estado.PERSIGUIENDO
var player: Node2D = null
var direccion_embestida := Vector2.ZERO
var tiempo_estado := 0.0
var daño_aplicado := false

func _ready() -> void:
	vida = vida_maxima
	add_to_group("Enemigo")
	add_to_group("Jefe")
	reproducir_animacion(animacion_aturdido)

func _physics_process(delta: float) -> void:
	match estado_actual:
		Estado.PERSIGUIENDO:
			perseguir_jugador()
		Estado.CARGANDO:
			velocity = Vector2.ZERO
			tiempo_estado -= delta
			if tiempo_estado <= 0:
				iniciar_embestida()
		Estado.EMBESTIDA:
			realizar_embestida(delta)
		Estado.ATURDIDO:
			velocity = Vector2.ZERO
			tiempo_estado -= delta
			if tiempo_estado <= 0:
				estado_actual = Estado.PERSIGUIENDO
				reproducir_animacion(animacion_movimiento)

func _on_detencion_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		player = body

func _on_detencion_area_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		velocity = Vector2.ZERO
		reproducir_animacion(animacion_aturdido)

func perseguir_jugador() -> void:
	if not is_instance_valid(player):
		velocity = Vector2.ZERO
		reproducir_animacion(animacion_aturdido)
		return
		
	var direccion = (player.global_position - global_position).normalized()
	velocity = direccion * velocidad_persecucion
	
	# Voltea el sprite según la dirección hacia el jugador
	if direccion.x != 0:
		sprite.flip_h = direccion.x < 0
		
	move_and_slide()
	reproducir_animacion(animacion_movimiento)
	
	if global_position.distance_to(player.global_position) < 110.0:
		iniciar_carga()

func iniciar_carga() -> void:
	if not is_instance_valid(player):
		return
	estado_actual = Estado.CARGANDO
	direccion_embestida = (player.global_position - global_position).normalized()
	
	if direccion_embestida.x != 0:
		sprite.flip_h = direccion_embestida.x < 0
		
	tiempo_estado = tiempo_carga
	velocity = Vector2.ZERO
	reproducir_animacion(animacion_carga)
	print("El jefe está preparando una embestida")

func iniciar_embestida() -> void:
	estado_actual = Estado.EMBESTIDA
	tiempo_estado = duracion_embestida
	daño_aplicado = false
	velocity = direccion_embestida * velocidad_embestida
	reproducir_animacion(animacion_embestida)
	print("¡El jefe está embistiendo!")

func realizar_embestida(delta: float) -> void:
	tiempo_estado -= delta
	velocity = direccion_embestida * velocidad_embestida
	move_and_slide()
	if not daño_aplicado and is_instance_valid(player):
		if global_position.distance_to(player.global_position) < distancia_golpe:
			if player.has_method("recibir_daño"):
				player.recibir_daño(daño)
				daño_aplicado = true
				print("¡El jefe golpeó a Servi!")
	if is_on_wall() or tiempo_estado <= 0:
		iniciar_aturdimiento()

func iniciar_aturdimiento() -> void:
	estado_actual = Estado.ATURDIDO
	tiempo_estado = tiempo_aturdido
	velocity = Vector2.ZERO
	reproducir_animacion(animacion_aturdido)
	print("¡El jefe está aturdido!")

func recibir_daño(cantidad: int) -> void:
	if vida <= 0:
		return
	vida = max(vida - cantidad, 0)
	print("Vida del jefe: ", vida, "/", vida_maxima)
	if vida <= 0:
		morir()

func morir() -> void:
	print("¡JEFE DERROTADO!")
	set_physics_process(false)
	velocity = Vector2.ZERO
	GameState.nivel_reparado = true
	
	hide()
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)
	
	await sacudir_camara(1.5, 12.0)
	
	get_tree().call_deferred(
		"change_scene_to_file",
		"res://Escenas/Mundos/normales/Jefe Normal.tscn"
	)

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

func reproducir_animacion(nombre: String) -> void:
	if sprite.sprite_frames and sprite.sprite_frames.has_animation(nombre):
		if sprite.animation != nombre:
			sprite.play(nombre)
