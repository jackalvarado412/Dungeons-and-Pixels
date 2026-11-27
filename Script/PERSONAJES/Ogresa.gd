extends CharacterBody2D

const DIALOGOS_CLAUD: DialogueResource = preload("res://Dialogos/Claud.dialogue.dialogue")
const ESCENA_TIENDA_CLAUD: PackedScene = preload("res://Escenas/Dialogos/ClaudTienda.tscn")

signal vida_cambiada(vida_actual, vida_maxima)
signal ogresa_derrotada
@export var vida_maxima: int = 100
var vida_actual: int = 100
var esta_derrotada: bool = false
@onready var barra_vida: ProgressBar = $BarraVida
@onready var indicacion: Label = $Indicacion

var interaccion_habilitada: bool = false
var dialogo_activo: bool = false
var dialogo_actual: String = ""


func _ready() -> void:
	add_to_group("Ogresa")
	add_to_group("Claud")
	indicacion.hide()
	interaccion_habilitada = GameState.claud_invitacion_mostrada
	if not DialogueManager.dialogue_ended.is_connected(_on_dialogue_ended):
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	vida_actual = vida_maxima
	barra_vida.max_value = vida_maxima
	barra_vida.value = vida_actual
	vida_cambiada.connect(actualizar_barra_vida)
	print("Ogresa lista. Vida: ", vida_actual, "/", vida_maxima)
func _process(_delta: float) -> void:
	if not interaccion_habilitada or dialogo_activo:
		indicacion.hide()
		return

	var jugador := get_tree().get_first_node_in_group("Jugador")
	if not is_instance_valid(jugador):
		indicacion.hide()
		return

	var esta_cerca := global_position.distance_to(jugador.global_position) <= 85.0
	indicacion.visible = esta_cerca

	if esta_cerca and Input.is_action_just_pressed("Accion"):
		_interactuar()


func iniciar_llamada() -> void:
	if dialogo_activo:
		return
	_iniciar_dialogo("llamada")


func habilitar_interaccion() -> void:
	interaccion_habilitada = true


func _interactuar() -> void:
	if not GameState.claud_presentacion_hecha:
		_iniciar_dialogo("presentacion")
		return

	var titulo := "interaccion_" + str(GameState.claud_conversacion)

	GameState.claud_conversacion += 1

	if GameState.claud_conversacion > 3:
		GameState.claud_conversacion = 1

	_iniciar_dialogo(titulo)

	_abrir_tienda()


func _iniciar_dialogo(titulo: String) -> void:
	if dialogo_activo:
		return
	dialogo_activo = true
	dialogo_actual = titulo
	indicacion.hide()
	DialogueManager.show_dialogue_balloon(DIALOGOS_CLAUD, titulo)


func _on_dialogue_ended(recurso: DialogueResource) -> void:
	if recurso != DIALOGOS_CLAUD:
		return

	dialogo_activo = false

	if dialogo_actual == "llamada":
		habilitar_interaccion()

	elif dialogo_actual == "presentacion":
		GameState.claud_presentacion_hecha = true

	elif dialogo_actual.begins_with("interaccion_"):
		call_deferred("_abrir_tienda")

	dialogo_actual = ""

func _abrir_tienda() -> void:
	var tienda = ESCENA_TIENDA_CLAUD.instantiate()
	tienda.set("claud_npc", self)
	get_tree().current_scene.add_child(tienda)
	indicacion.hide()


func mostrar_dialogo_compra() -> void:
	if dialogo_activo:
		return
	var numero := randi_range(1, 2)
	_iniciar_dialogo("compra_" + str(numero))


func actualizar_barra_vida(vida: int, vida_maxima_personaje: int) -> void:
	barra_vida.max_value = vida_maxima_personaje
	barra_vida.value = vida
	
	
func recibir_danio(cantidad: int) -> void:
	if esta_derrotada or cantidad <= 0:
		return
	vida_actual = clampi(vida_actual - cantidad, 0, vida_maxima)
	print("La Ogresa recibió daño. Vida: ", vida_actual)
	vida_cambiada.emit(vida_actual, vida_maxima)
	if vida_actual <= 0:
		morir()
func recibir_daño(cantidad: int) -> void:
	recibir_danio(cantidad)
func curar(cantidad: int) -> void:
	if esta_derrotada or cantidad <= 0:
		return
	vida_actual = clampi(vida_actual + cantidad, 0, vida_maxima)
	vida_cambiada.emit(vida_actual, vida_maxima)
	print("La Ogresa recuperó vida: ", vida_actual)
func morir() -> void:
	if esta_derrotada:
		return
	esta_derrotada = true
	print("¡La Ogresa fue derrotada!")
	ogresa_derrotada.emit()
