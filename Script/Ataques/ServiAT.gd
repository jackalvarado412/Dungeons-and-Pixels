extends CharacterBody2D
@export var daño := 25
var atacando := false
func _process(delta):
	if Input.is_action_just_pressed("ataque") and !atacando:
		atacar()
func atacar():
	atacando = true
	$AnimationPlayer.play("ataque")
	$Hitbox.monitoring = true
	await get_tree().create_timer(0.2).timeout
	$Hitbox.monitoring = false
	await $AnimationPlayer.animation_finished
	atacando = false
