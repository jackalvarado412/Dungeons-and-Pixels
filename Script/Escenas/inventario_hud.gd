extends CanvasLayer

@onready var monedas_label: Label = $ContadorMonedas/MonedasLabel

const ESCENA_SLOT = preload("res://Script/Escenas/slot_inventario.tscn")

@onready var cuadricula: HBoxContainer = $ContenedorHud/CuadriculaHUD

var slots_ui: Array = []

func _ready() -> void:
	GameState.monedas_cambiaron.connect(actualizar_monedas)
	actualizar_monedas()
	crear_cuadricula()
	if GameState.has_signal("inventario_cambiado") and not GameState.inventario_cambiado.is_connected(refrescar_inventario):
		GameState.inventario_cambiado.connect(refrescar_inventario)

func crear_cuadricula() -> void:
	GameState.inicializar_inventario()
	for child in cuadricula.get_children():
		child.queue_free()
	slots_ui.clear()

	for i in range(GameState.MAX_SLOTS):
		var slot = ESCENA_SLOT.instantiate()
		slot.indice_slot = i
		slot.slot_clickeado.connect(_on_slot_clickeado)
		cuadricula.add_child(slot)
		slots_ui.append(slot)
	refrescar_inventario()

func refrescar_inventario() -> void:
	GameState.inicializar_inventario()
	if slots_ui.size() < GameState.MAX_SLOTS:
		return
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
func actualizar_monedas() -> void:
	monedas_label.text = str(GameState.monedas)
