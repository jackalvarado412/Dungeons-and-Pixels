extends Node2D

const DIALOGOS_CLAUD = preload("res://Dialogos/Claud.dialogue.dialogue")

@onready var jugador = $Player
@onready var claud = $Ogresa/CharacterBody2D
@onready var indicacion: Label = $Ogresa/CharacterBody2D/Indicacion

var enemigos_restantes: int = 0

var combate_terminado := false
var puede_interactuar := false
var dialogo_activo := false

var tipo_dialogo_actual := ""


func _ready() -> void:

	if not DialogueManager.dialogue_ended.is_connected(_on_dialogue_ended):
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

	var enemigos = [
		$"Ogresa enemigo",
		$"Ogresa enemigo2",
		$"Ogresa enemigo3"
	]

	for enemigo in enemigos:
		if not is_instance_valid(enemigo):
			continue

		if GameState.enemigo_ya_derrotado(enemigo):
			continue

		enemigos_restantes += 1

		enemigo.tree_exited.connect(_on_enemigo_eliminado)

	print("Enemigos restantes: ", enemigos_restantes)

	if enemigos_restantes == 0:
		call_deferred("_terminar_combate")


func _on_enemigo_eliminado() -> void:
	if combate_terminado:
		return

	enemigos_restantes = max(enemigos_restantes - 1, 0)

	print("Enemigos restantes: ", enemigos_restantes)

	if enemigos_restantes == 0:
		_terminar_combate()


func _terminar_combate() -> void:
	if GameState.claud_invitacion_mostrada:
		combate_terminado = true
		puede_interactuar = true
		return

	GameState.claud_invitacion_mostrada = true

	combate_terminado = true
	_iniciar_dialogo("llamada")


func _process(_delta: float) -> void:
	if not puede_interactuar or dialogo_activo:
		return

	var distancia = jugador.global_position.distance_to(
		claud.global_position
	)

	var esta_cerca = distancia <= 85.0

	if esta_cerca and Input.is_action_just_pressed("Accion"):
		_interactuar_con_claud()


func _interactuar_con_claud() -> void:
	if dialogo_activo:
		return

	if not GameState.claud_presentacion_hecha:
		_iniciar_dialogo("presentacion")
		return

	if GameState.claud_conversacion <= 5:
		var titulo = "interaccion_" + str(GameState.claud_conversacion)

		GameState.claud_conversacion += 1

		_iniciar_dialogo(titulo)
		return

	abrir_tienda()

func abrir_tienda() -> void:
	print("Abriendo tienda de Claud...")
	
func _iniciar_dialogo(titulo: String) -> void:
	if dialogo_activo:
		return

	dialogo_activo = true
	tipo_dialogo_actual = titulo

	# Evita que la misma pulsación de E
	# se interprete como una nueva interacción.
	await get_tree().process_frame

	while Input.is_action_pressed("Accion"):
		await get_tree().process_frame

	DialogueManager.show_dialogue_balloon(
		DIALOGOS_CLAUD,
		titulo
	)


func _on_dialogue_ended(_resource) -> void:
	dialogo_activo = false

	match tipo_dialogo_actual:

		"llamada":
			puede_interactuar = true
			print("Claud espera al jugador.")

		"presentacion":
			GameState.claud_presentacion_hecha = true
			puede_interactuar = true

	tipo_dialogo_actual = ""


func mostrar_dialogo_compra() -> void:
	if dialogo_activo:
		return

	if not GameState.claud_presentacion_hecha:
		return

	var numero = randi_range(1, 2)

	_iniciar_dialogo("compra_" + str(numero))
