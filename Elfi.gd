extends AnimatedSprite2D

var is_player_close = false

const DIALOGUE = preload("res://Dialogos/Dialogos Elfi zona 1.dialogue")


func _process(delta):
	if is_player_close and Input.is_action_just_pressed("Accion"):
		print("gloa")
		DialogueManager.show_dialogue_balloon(DIALOGUE)


func _on_area_2d_body_entered(body: Node2D) -> void:
	is_player_close = true



func _on_area_2d_body_exited(body: Node2D) -> void:
	is_player_close = false
