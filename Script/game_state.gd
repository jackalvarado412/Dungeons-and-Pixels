extends Node
signal inventario_cambiado

var nivel_reparado: bool = false
var vida_maxima: int = 100
var vida_actual: int = 100
var pociones: int = 0
signal monedas_cambiaron
var monedas: int = 0
func agregar_monedas(cantidad: int = 1) -> void:
	if cantidad <= 0:
		return
	monedas += cantidad
	monedas_cambiaron.emit()
	print("Monedas actuales: ", monedas)
const MAX_SLOTS := 4
var slots_inventario: Array = []
const MAPAS_NORMALES := {
	"res://Escenas/Mundos/Corruptos/mundo.tscn": "res://Escenas/Mundos/normales/mundo_normal.tscn",
	"res://Escenas/Mundos/Corruptos/cueva_interior.tscn": "res://Escenas/Mundos/normales/Cueva interior color.tscn",
	"res://Escenas/Mundos/Corruptos/Nivel 1 derecha.tscn": "res://Escenas/Mundos/normales/Derecha a color.tscn",
	"res://Escenas/Mundos/Corruptos/nivel_1_izquierda.tscn": "res://Escenas/Mundos/normales/izquierda colores.tscn",
	"res://Escenas/Mundos/Corruptos/arriba.tscn": "res://Escenas/Mundos/normales/arriba a color.tscn"
}

func _ready() -> void:
	get_tree().scene_changed.connect(_al_cambiar_escena)
	inicializar_inventario()

func inicializar_inventario() -> void:
	if slots_inventario.size() < MAX_SLOTS:
		slots_inventario.resize(MAX_SLOTS)
		slots_inventario.fill(null)

func iniciar_partida() -> void:
	monedas = 0
	nivel_reparado = false
	vida_actual = vida_maxima
	pociones = 0
	inicializar_inventario()
	slots_inventario.fill(null)

func agregar_item(nombre: String, icono: Texture2D, cantidad: int = 1, apilable: bool = true) -> bool:
	if icono == null:
		push_warning("El objeto no tiene un icono asignado: " + nombre)
		return false

	if apilable:
		for i in range(MAX_SLOTS):
			if slots_inventario[i] != null and slots_inventario[i]["nombre"] == nombre:
				slots_inventario[i]["cantidad"] += cantidad
				inventario_cambiado.emit()
				return true

	for i in range(MAX_SLOTS):
		if slots_inventario[i] == null:
			slots_inventario[i] = {
				"nombre": nombre,
				"icono": icono,
				"cantidad": cantidad
			}
			inventario_cambiado.emit()
			return true

	return false

func usar_item_en_slot(indice: int) -> void:
	if indice < 0 or indice >= MAX_SLOTS:
		return

	var item = slots_inventario[indice]

	if item == null:
		return

	var jugador = get_tree().get_first_node_in_group("Jugador")

	if jugador == null:
		return

	match item["nombre"]:

		"Memoria_RAM":
			jugador.activar_velocidad_doble(20.0)
			jugador.curar(10)

		"Disco_Duro":
			if jugador.vida >= jugador.vida_maxima:
				return
			jugador.curar(25)

		"Pocion":
			if jugador.vida >= jugador.vida_maxima:
				return
			jugador.curar(25)
			pociones = max(pociones - 1, 0)

		_:
			return

	item["cantidad"] -= 1

	if item["cantidad"] <= 0:
		slots_inventario[indice] = null

	inventario_cambiado.emit()

func derrotar_jefe() -> void:
	if nivel_reparado:
		return
	nivel_reparado = true
	reparar_mapa_actual()

func _al_cambiar_escena() -> void:
	if nivel_reparado:
		reparar_mapa_actual()

func reparar_mapa_actual() -> void:
	var escena := get_tree().current_scene
	if escena == null:
		return
	var ruta_color: String = MAPAS_NORMALES.get(escena.scene_file_path, "")
	if ruta_color.is_empty():
		push_warning("No hay una versión a color configurada para: " + escena.scene_file_path)
		return
	var escena_color: PackedScene = load(ruta_color)
	if escena_color == null:
		push_error("No se pudo cargar el mapa reparado: " + ruta_color)
		return
	var instancia_color := escena_color.instantiate()
	var mapa_nuevo := _buscar_tilemap(instancia_color)
	var mapa_actual := _buscar_tilemap(escena)
	if mapa_nuevo == null or mapa_actual == null:
		push_error("No se encontró un TileMap en la escena actual o en su versión a color.")
		instancia_color.queue_free()
		return
	var padre := mapa_actual.get_parent()
	var indice := mapa_actual.get_index()
	var transformacion := mapa_actual.transform
	var nombre_mapa := mapa_actual.name
	instancia_color.remove_child(mapa_nuevo)
	mapa_nuevo.name = nombre_mapa
	mapa_nuevo.transform = transformacion
	padre.add_child(mapa_nuevo)
	padre.move_child(mapa_nuevo, indice)
	mapa_actual.queue_free()
	instancia_color.queue_free()

func _buscar_tilemap(nodo: Node) -> TileMap:
	if nodo is TileMap:
		return nodo
	for hijo in nodo.get_children():
		var encontrado := _buscar_tilemap(hijo)
		if encontrado != null:
			return encontrado
	return null
