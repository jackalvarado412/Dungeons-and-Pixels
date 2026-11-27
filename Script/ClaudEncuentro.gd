extends Node2D

@onready var claud: CharacterBody2D = $Ogresa/CharacterBody2D

var enemigos_restantes: int = 0
var encuentro_finalizado: bool = false


func _ready() -> void:
	if GameState.claud_invitacion_mostrada:
		encuentro_finalizado = true
		claud.habilitar_interaccion()
		return

	var enemigos = [
		get_node_or_null("Ogresa enemigo"),
		get_node_or_null("Ogresa enemigo2"),
		get_node_or_null("Ogresa enemigo3")
	]

	for enemigo in enemigos:
		if not is_instance_valid(enemigo):
			continue
		enemigos_restantes += 1
		enemigo.tree_exited.connect(_on_enemigo_eliminado)

	if enemigos_restantes == 0:
		call_deferred("_finalizar_encuentro")


func _on_enemigo_eliminado() -> void:
	if encuentro_finalizado:
		return

	enemigos_restantes = maxi(enemigos_restantes - 1, 0)
	print("Enemigos restantes para liberar a Claud: ", enemigos_restantes)

	if enemigos_restantes == 0:
		_finalizar_encuentro()


func _finalizar_encuentro() -> void:
	if encuentro_finalizado:
		return

	encuentro_finalizado = true
	if GameState.claud_invitacion_mostrada:
		claud.habilitar_interaccion()
		return

	GameState.claud_invitacion_mostrada = true
	claud.iniciar_llamada()
