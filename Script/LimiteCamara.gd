extends Node2D

@onready var camara: Camera2D = $Player/Camera2D
@onready var limites: ReferenceRect = $LimitedeCamara

func _ready() -> void:
	var rect = limites.get_global_rect()
	camara.limit_left = int(rect.position.x)
	camara.limit_top = int(rect.position.y)
	camara.limit_right = int(rect.end.x)
	camara.limit_bottom = int(rect.end.y)
