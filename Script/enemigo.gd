extends CharacterBody2D

var speed = 50
var player_chase = false
var player = null

var health = 100
var Player_inttack_zone = false


func _physics_process(delta):
	if player_chase: 
		position += (player.position - position)/speed
	   
		$AnimatedSprite2D.play("Movimiento")


func _on_detencion_area_body_entered(body):
	player = body 
	player_chase = true


func _on_detencion_area_body_exited(body:):
	player = null
	player_chase = false

func enemy():
	pass
	


func _on_detector_jugador_body_entered(body):
	if body.is_in_group("Jugador"):
		player = body
func _on_detector_jugador_body_exited(body):
	if body == player:
		player = null
var vida := 50
func recibir_daño(cantidad):
	vida -= cantidad
	print("Vida enemigo:", vida)
	if vida <= 0:
		queue_free()
