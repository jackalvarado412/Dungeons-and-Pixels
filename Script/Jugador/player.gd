extends CharacterBody2D
const PANTALLA_MUERTE = preload("res://Escenas/Mundos/Menusgeneral/Pantalla de muerde.tscn")
const SPEED_BASE := 1000
var velocidad_actual := SPEED_BASE
var temporizador_velocidad: Timer
var current_dir := "down"
@export var vida_maxima := 100
var vida := 100
var player_alive := true
@export var daño_ataque := 200
var attack_ip := false
var enemigos_golpeados = []
var pociones := 0
func _ready():
	add_to_group("Jugador")
	# Cargamos la vida y pociones guardadas en el script global al cambiar de nivel
	vida_maxima = GameState.vida_maxima
	vida = GameState.vida_actual
	pociones = GameState.pociones
	# Actualizamos la barra de vida visualmente en el primer fotograma de la nueva escena
	call_deferred("actualizar_barra_vida")
	temporizador_velocidad = Timer.new()
	temporizador_velocidad.one_shot = true
	add_child(temporizador_velocidad)
	temporizador_velocidad.timeout.connect(restaurar_velocidad)
func _process(_delta):
	if Input.is_action_just_pressed("usar_pocion"):
		usar_pocion()

func _physics_process(_delta):
	if !player_alive:
		return
	player_movement()
	attack()
	enemy_attack()

# MOVIMIENTO
func player_movement():
	var input_vector := Vector2.ZERO
	if Input.is_action_pressed("Derecha"):
		input_vector.x = 1
		current_dir = "right"
	elif Input.is_action_pressed("Izquierda"):
		input_vector.x = -1
		current_dir = "left"
	if Input.is_action_pressed("Abajo"):
		input_vector.y = 1
		current_dir = "down"
	elif Input.is_action_pressed("Arriba"):
		input_vector.y = -1
		current_dir = "up"
	velocity = input_vector.normalized() * velocidad_actual
	move_and_slide()
	if !attack_ip:
		if velocity.length() > 0:
			play_anim(1)
		else:
			play_anim(0)

# ANIMACIONES
func play_anim(movement):
	var anim = $AnimatedSprite2D
	match current_dir:
		"right":
			anim.flip_h = false
			if movement == 1:
				anim.play("Costado")
			else:
				anim.play("Quieta derecha")
		"left":
			anim.flip_h = true
			if movement == 1:
				anim.play("Costado")
			else:
				anim.play("Quieta derecha")
		"down":
			anim.flip_h = false
			if movement == 1:
				anim.play("Caminar")
			else:
				anim.play("Quieta")
		"up":
			anim.flip_h = false
			if movement == 1:
				anim.play("Caminar atras")
			else:
				anim.play("Quieta arriba")

# VIDA
func recibir_daño(cantidad: int):
	if !player_alive:
		return
	vida = max(vida - cantidad, 0)
	GameState.vida_actual = vida # Guardamos la vida actual globalmente
	print("Vida:", vida)
	actualizar_barra_vida()
	if vida <= 0:
		morir()

func curar(cantidad: int):
	vida = min(vida + cantidad, vida_maxima)
	GameState.vida_actual = vida # Guardamos la vida curada globalmente
	print("Vida:", vida)
	actualizar_barra_vida()

func actualizar_barra_vida():
	var barra_nodo = get_tree().get_first_node_in_group("BarraDeVida")
	if barra_nodo:
		var texture_progress = barra_nodo.find_child("TextureProgressBar", true, false)
		if texture_progress:
			texture_progress.max_value = vida_maxima
			texture_progress.value = vida
			print("¡Barra actualizada a:", vida, "!")
		else:
			print("❌ No se encontró el TextureProgressBar hijo.")
	else:
		print("❌ No se encontró el nodo en el grupo BarraDeVida.")

func morir():
	if !player_alive:
		return
	player_alive = false
	print("GAME OVER")
	# Reiniciamos los datos globales para la próxima partida
	GameState.vida_actual = GameState.vida_maxima
	GameState.pociones = 0
	var pantalla = PANTALLA_MUERTE.instantiate()
	get_tree().current_scene.add_child(pantalla)
	queue_free()

func enemy_attack():
	pass

# ATAQUE DEL JUGADOR
func aplicar_daño():
	for body in $"Hit box".get_overlapping_bodies():
		if body.is_in_group("Enemigo"):
			if body not in enemigos_golpeados:
				if body.has_method("recibir_daño"):
					print("¡Golpeaste al enemigo!")
					body.recibir_daño(daño_ataque)
					enemigos_golpeados.append(body)

func attack():
	if Input.is_action_just_pressed("attack") and !attack_ip:
		attack_ip = true
		enemigos_golpeados.clear()
		match current_dir:
			"right":
				$AnimatedSprite2D.flip_h = false
				$AnimatedSprite2D.play("ataque derecha")
			"left":
				$AnimatedSprite2D.flip_h = false
				$AnimatedSprite2D.play("ataque izquierda")
			"down":
				$AnimatedSprite2D.play("ataque abajo")
			"up":
				$AnimatedSprite2D.play("ataque arriba")
		aplicar_daño()

func _on_attack_area_body_entered(body):
	if !attack_ip:
		return
	if body.is_in_group("Enemigo"):
		if body not in enemigos_golpeados:
			if body.has_method("recibir_daño"):
				body.recibir_daño(daño_ataque)
				enemigos_golpeados.append(body)

func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation.begins_with("ataque"):
		attack_ip = false
		if velocity.length() > 0:
			play_anim(1)
		else:
			play_anim(0)

# INVENTARIO
func recoger_pocion():
	pociones += 1
	GameState.pociones = pociones
	print("Recogiste una poción")
	print("Pociones:", pociones)

func usar_pocion():
	if pociones <= 0:
		print("No tienes pociones")
		return
	pociones -= 1
	GameState.pociones = pociones
	curar(25)
	print("Usaste una poción")
	print("Pociones restantes:", pociones)

# IDENTIFICADOR DE JUGADOR
func player():
	pass
func activar_velocidad_doble(duracion: float = 20.0) -> void:
	velocidad_actual = SPEED_BASE * 2
	temporizador_velocidad.start(duracion)
	print("¡Velocidad duplicada!")

func restaurar_velocidad() -> void:
	velocidad_actual = SPEED_BASE
	print("Velocidad normal restaurada")
