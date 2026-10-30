extends CharacterBody2D
@export var velocidad := 80.0
@export var daño := 10
@export var rango_ataque := 50
var jugador = null
func _physics_process(delta):
	if jugador:
		var distancia = global_position.distance_to(jugador.global_position)
		if distancia > rango_ataque:
			var direccion = (jugador.global_position - global_position).normalized()
			velocity = direccion * velocidad
		else:
			velocity = Vector2.ZERO
		move_and_slide()
func _on_attack_timer_timeout():
	if jugador == null:
		return
	var distancia = global_position.distance_to(jugador.global_position)
	if distancia <= rango_ataque:
		jugador.recibir_daño(daño)
