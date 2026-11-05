extends Area2D

@onready var exclamation_mark = $ExclamationMark

var is_player_close = false

const DIALOGUE = preload("res://Dialogos/Dialogos Elfi zona 1.dialogue")


func _process(delta):
	if is_player_close and Input.is_action_just_pressed("Accion"):
		DialogueManager.show_dialogue_balloon(DIALOGUE)


func _on_area_entered(area):
	exclamation_mark.visible = true
	is_player_close = true


func _on_area_exited(area):
	exclamation_mark.visible = false
	is_player_close = false
