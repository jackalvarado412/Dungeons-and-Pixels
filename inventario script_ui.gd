extends Control

signal cerrado

const ESCENA_SLOT = preload("res://Script/Escenas/slot_inventario.tscn") # Asegúrate de que coincida con la ruta de tu .tscn

@onready var cuadricula: GridContainer = $PanelContainer/VBoxContainer/Cuadricula
@onready var boton_volver: Button = $PanelContainer/VBoxContainer/Volver

var slots_ui: Array = []

func _ready() -> void:
	boton_volver.pressed.connect(_al_presionar_volver)
	crear_cuadricula()

func crear_cuadricula() -> void:
	GameState.inicializar_inventario()
	for i in range(GameState.MAX_SLOTS):
		var slot = ESCENA_SLOT.instantiate()
		slot.indice_slot = i
		slot.slot_clickeado.connect(_on_slot_clickeado)
		cuadricula.add_child(slot)
		slots_ui.append(slot)
	refrescar_inventario()

func refrescar_inventario() -> void:
	GameState.inicializar_inventario()
	for i in range(GameState.MAX_SLOTS):
		slots_ui[i].actualizar_slot(GameState.slots_inventario[i])

func _on_slot_clickeado(indice: int) -> void:
	GameState.usar_item_en_slot(indice)
	refrescar_inventario()
	var jugador = get_tree().get_first_node_in_group("Jugador")
	if jugador and jugador.has_method("actualizar_barra_vida"):
		jugador.vida = GameState.vida_actual
		jugador.pociones = GameState.pociones
		jugador.actualizar_barra_vida()

func _al_presionar_volver() -> void:
	hide()
	cerrado.emit()
