extends CanvasLayer

var claud_npc: Node = null

@onready var monedas_label: Label = $Overlay/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/MonedasLabel
@onready var vida_label: Label = $Overlay/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/VidaRow/VidaLabel
@onready var danio_label: Label = $Overlay/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/DanioRow/DanioLabel
@onready var velocidad_label: Label = $Overlay/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/VelocidadRow/VelocidadLabel
@onready var vida_button: Button = $Overlay/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/VidaRow/VidaButton
@onready var danio_button: Button = $Overlay/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/DanioRow/DanioButton
@onready var velocidad_button: Button = $Overlay/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/VelocidadRow/VelocidadButton
@onready var estado_label: Label = $Overlay/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/EstadoLabel
@onready var cerrar_button: Button = $Overlay/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CerrarButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true

	vida_button.pressed.connect(_comprar.bind("vida"))
	danio_button.pressed.connect(_comprar.bind("danio"))
	velocidad_button.pressed.connect(_comprar.bind("velocidad"))
	cerrar_button.pressed.connect(_cerrar)

	if not GameState.monedas_cambiaron.is_connected(_actualizar_interfaz):
		GameState.monedas_cambiaron.connect(_actualizar_interfaz)
	if not GameState.mejoras_cambiaron.is_connected(_actualizar_interfaz):
		GameState.mejoras_cambiaron.connect(_actualizar_interfaz)

	_actualizar_interfaz()
	cerrar_button.grab_focus()


func _exit_tree() -> void:
	get_tree().paused = false


func _cerrar() -> void:
	queue_free()


func _actualizar_interfaz() -> void:
	monedas_label.text = "Monedas disponibles: %d" % GameState.monedas
	_actualizar_boton("vida", vida_label, vida_button)
	_actualizar_boton("danio", danio_label, danio_button)
	_actualizar_boton("velocidad", velocidad_label, velocidad_button)


func _actualizar_boton(tipo: String, etiqueta: Label, boton: Button) -> void:
	var nivel: int = int(GameState.niveles_mejoras.get(tipo, 0))
	var precio: int = GameState.obtener_precio_mejora(tipo)
	var descripcion := ""

	match tipo:
		"vida":
			descripcion = "Vida máxima  |  Nivel %d/5  |  +10 PV" % nivel
		"danio":
			descripcion = "Daño de ataque  |  Nivel %d/5  |  +5 daño" % nivel
		"velocidad":
			descripcion = "Velocidad  |  Nivel %d/5  |  +10 velocidad" % nivel

	etiqueta.text = descripcion

	if precio < 0:
		boton.text = "MAX"
		boton.disabled = true
	else:
		boton.text = "Comprar · %d monedas" % precio
		boton.disabled = false


func _comprar(tipo: String) -> void:
	var precio: int = GameState.obtener_precio_mejora(tipo)

	if precio < 0:
		estado_label.text = "Esta mejora ya alcanzó su nivel máximo."
		return

	if GameState.monedas < precio:
		estado_label.text = "No tenés monedas suficientes."
		return

	if not GameState.comprar_mejora(tipo):
		estado_label.text = "No se pudo completar la compra."
		return

	var npc := claud_npc
	queue_free()
	await get_tree().process_frame

	if is_instance_valid(npc) and npc.has_method("mostrar_dialogo_compra"):
		npc.mostrar_dialogo_compra()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		queue_free()
		get_viewport().set_input_as_handled()
