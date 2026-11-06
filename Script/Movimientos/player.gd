extends CharacterBody2D
# MOVIMIENTO
const SPEED := 100.0
var current_dir := "down"
# VIDA
@export var vida_maxima := 100
var vida := 100
var player_alive := true
# COMBATE
@export var daño_ataque := 20
var attack_ip := false
var enemigos_golpeados = []
# INVENTARIO SIMPLE
var pociones := 0
func _ready():
	add_to_group("Jugador")
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
	if Input.is_action_pressed("ui_right"):
		input_vector.x = 1
		current_dir = "right"
	elif Input.is_action_pressed("ui_left"):
		input_vector.x = -1
		current_dir = "left"
	if Input.is_action_pressed("ui_down"):
		input_vector.y = 1
		current_dir = "down"
	elif Input.is_action_pressed("ui_up"):
		input_vector.y = -1
		current_dir = "up"
	velocity = input_vector.normalized() * SPEED
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
func recibir_daño(cantidad:int):
	if !player_alive:
		return
	vida -= cantidad
	print("Vida:", vida)
	if vida <= 0:
		morir()
func curar(cantidad:int):
	vida += cantidad
	if vida > vida_maxima:
		vida = vida_maxima
	print("Vida:", vida)
func morir():
	player_alive = false
	print("GAME OVER")
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
	print("Recogiste una poción")
	print("Pociones:", pociones)
func usar_pocion():
	if pociones <= 0:
		print("No tienes pociones")
		return
	pociones -= 1
	curar(25)
	print("Usaste una poción")
	print("Pociones restantes:", pociones)
# IDENTIFICADOR DE JUGADOR
func player():
	pass
