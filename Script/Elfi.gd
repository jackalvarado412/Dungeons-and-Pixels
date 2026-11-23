extends AnimatedSprite2D

@export var dialogo_presentacion: DialogueResource = preload("res://Dialogos/Elfi_presentacion.dialogue.dialogue")
@export var dialogo_2: DialogueResource = preload("res://Dialogos/Elfi_dialogo_2.dialogue.dialogue")
@export var dialogo_3: DialogueResource = preload("res://Dialogos/Elfi_dialogo_3.dialogue.dialogue")

var is_player_close = false
var dialogue_active = false
var presentacion_realizada = false
var siguiente_dialogo = 0

func _ready():
	if not DialogueManager.dialogue_ended.is_connected(_on_dialogue_ended):
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _process(_delta):
	if is_player_close and Input.is_action_just_pressed("Accion") and not dialogue_active:
		dialogue_active = true
		if not presentacion_realizada:
			presentacion_realizada = true
			DialogueManager.show_dialogue_balloon(dialogo_presentacion)
		else:
			if siguiente_dialogo == 0:
				DialogueManager.show_dialogue_balloon(dialogo_2)
				siguiente_dialogo = 1
			else:
				DialogueManager.show_dialogue_balloon(dialogo_3)
				siguiente_dialogo = 0

func _on_dialogue_ended(_resource):
	dialogue_active = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		is_player_close = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		is_player_close = false
