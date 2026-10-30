extends CharacterBody2D
const speed = 100
var current_dir = "down"
func _physics_process(delta: float) -> void:
	player_movement()
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
	if velocity.x != 0 or velocity.y != 0:
		play_anim(1)
	else:
		play_anim(0)
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
			
var vida := 100
func recibir_daño(cantidad):
	vida -= cantidad
	print("Vida restante:", vida)
	if vida <= 0:
		morir()
func morir():
	print("GAME OVER")
