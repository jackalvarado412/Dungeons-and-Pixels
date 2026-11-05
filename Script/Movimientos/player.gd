extends CharacterBody2D
# VARIABLES DEL COMBATE
var enemy_inattack_range = false
var enemy_attack_cooldown = true
var player_alive = true
var attack_ip = false
# INVENTARIO

# MOVIMIENTO
const speed = 100
var current_dir = "down"
# VIDA
var vida := 100
func _physics_process(delta: float) -> void:
	player_movement()
	attack()
	enemy_attack()
# MOVIMIENTO DEL JUGADOR
func player_movement() -> void:
	if Input.is_action_pressed("ui_right"):
		current_dir = "right"
		velocity.x = speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_left"):
		current_dir = "left"
		velocity.x = -speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_down"):
		current_dir = "down"
		velocity.x = 0
		velocity.y = speed
	elif Input.is_action_pressed("ui_up"):
		current_dir = "up"
		velocity.x = 0
		velocity.y = -speed
	else:
		velocity.x = 0
		velocity.y = 0
	move_and_slide()
	# EVITAR QUE EL MOVIMIENTO INTERRUMPA EL ATAQUE
	if attack_ip == false:
		if velocity.x != 0 or velocity.y != 0:
			play_anim(1)
		else:
			play_anim(0)
# ANIMACIONES DE MOVIMIENTO
func play_anim(movement):
	var dir = current_dir
	var anim = $AnimatedSprite2D
	if dir == "right":
		anim.flip_h = false
		if movement == 1:
			anim.play("Costado")
		elif movement == 0:
			anim.play("Quieta derecha")
	elif dir == "left":
		anim.flip_h = true
		if movement == 1:
			anim.play("Costado")
		elif movement == 0:
			anim.play("Quieta derecha")
	elif dir == "down":
		anim.flip_h = false
		if movement == 1:
			anim.play("Caminar")
		elif movement == 0:
			anim.play("Quieta")
	elif dir == "up":
		anim.flip_h = false
		if movement == 1:
			anim.play("Caminar atras")
		elif movement == 0:
			anim.play("Quieta arriba")
# SISTEMA DE VIDA
func recibir_daño(cantidad):
	vida -= cantidad
	print("Vida restante:", vida)
	if vida <= 0:
		morir()
func curar(cantidad):
	vida += cantidad
	print("Vida restante:", vida)
func morir():
	player_alive = false
	print("GAME OVER")
# IDENTIFICAR AL JUGADOR
func player():
	pass
# DETECTAR ENEMIGOS
func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemigo"):
		enemy_inattack_range = true
func _on_hit_box_body_exited(body: Node2D) -> void:
	if body.is_in_group("Enemigo"):
		enemy_inattack_range = false
# ATAQUE DEL ENEMIGO
func enemy_attack():
	if enemy_inattack_range and enemy_attack_cooldown:
		recibir_daño(10)
		enemy_attack_cooldown = false
		$"Tiempo daño".start()
# ATAQUE DEL JUGADOR
func attack():
	if Input.is_action_just_pressed("attack") and attack_ip == false:
		attack_ip = true
		if current_dir == "right":
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("ataque derecha")
		elif current_dir == "left":
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("ataque izquierda")
		elif current_dir == "down":
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("ataque abajo")
		elif current_dir == "up":
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("ataque arriba")
# FINALIZAR ATAQUE
func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation.begins_with("ataque"):
		attack_ip = false
		if velocity.x != 0 or velocity.y != 0:
			play_anim(1)
		else:
			play_anim(0)
# INVENTARIO
func usar_pocion() -> void:
	if Inventario.cantidad_item("pocion") > 0:
		Inventario.eliminar_item("pocion", 1)
		curar(25)
		print("Usaste una poción")
	else:
		print("No tienes pociones")
func _process(_delta):
	if Input.is_action_just_pressed("usar_pocion"):
		usar_pocion()
