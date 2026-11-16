extends AnimatedSprite2D

var is_player_close = false
var dialogue_active = false

const DIALOGUE = preload("res://Dialogos/Dialogos Elfi zona 1.dialogue")


func _ready():
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)


func _process(delta):
	if is_player_close and Input.is_action_just_pressed("Accion") and not dialogue_active:
		dialogue_active = true
		DialogueManager.show_dialogue_balloon(DIALOGUE)


func _on_dialogue_ended(resource):
	dialogue_active = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	is_player_close = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	is_player_close = false
