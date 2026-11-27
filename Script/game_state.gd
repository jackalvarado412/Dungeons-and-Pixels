extends Node
signal inventario_cambiado

var nivel_reparado: bool = false
var vida_maxima: int = 100
var vida_actual: int = 100
var pociones: int = 0
signal monedas_cambiaron
signal mejoras_cambiaron

var monedas: int = 0

# Mejoras permanentes de Claud. Los precios aumentan por nivel.
const MEJORAS_CLAUD := {
	"vida": {"precio": 20, "incremento": 10, "max_nivel": 5},
	"danio": {"precio": 30, "incremento": 5, "max_nivel": 5},
	"velocidad": {"precio": 25, "incremento": 10, "max_nivel": 5}
}

var niveles_mejoras: Dictionary = {
	"vida": 0,
	"danio": 0,
	"velocidad": 0
}
var bono_danio: int = 0
var bono_velocidad: int = 0

# Progreso del encuentro con Claud durante la partida.
var claud_invitacion_mostrada: bool = false
var claud_presentacion_hecha: bool = false
var claud_conversacion: int = 1


func obtener_precio_mejora(tipo: String) -> int:
	if not MEJORAS_CLAUD.has(tipo):
		return -1
	var configuracion: Dictionary = MEJORAS_CLAUD[tipo]
	var nivel: int = int(niveles_mejoras.get(tipo, 0))
	if nivel >= int(configuracion["max_nivel"]):
		return -1
	return int(configuracion["precio"]) * (nivel + 1)


func comprar_mejora(tipo: String) -> bool:
	var precio := obtener_precio_mejora(tipo)
	if precio < 0 or monedas < precio:
		return false

	var configuracion: Dictionary = MEJORAS_CLAUD[tipo]
	monedas -= precio
	niveles_mejoras[tipo] = int(niveles_mejoras.get(tipo, 0)) + 1

	match tipo:
		"vida":
			vida_maxima += int(configuracion["incremento"])
			vida_actual = min(vida_actual + int(configuracion["incremento"]), vida_maxima)
		"danio":
			bono_danio += int(configuracion["incremento"])
		"velocidad":
			bono_velocidad += int(configuracion["incremento"])

	monedas_cambiaron.emit()
	mejoras_cambiaron.emit()

	var jugador = get_tree().get_first_node_in_group("Jugador")
	if is_instance_valid(jugador) and jugador.has_method("aplicar_mejoras_game_state"):
		jugador.aplicar_mejoras_game_state()

	print("Mejora comprada: ", tipo, " | monedas restantes: ", monedas)
	return true
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
	vida_maxima = 100
	vida_actual = vida_maxima
	pociones = 0
	bono_danio = 0
	bono_velocidad = 0
	niveles_mejoras = {"vida": 0, "danio": 0, "velocidad": 0}
	claud_invitacion_mostrada = false
	claud_presentacion_hecha = false
	claud_conversacion = 1
	inicializar_inventario()
	slots_inventario.fill(null)
	monedas_cambiaron.emit()
	mejoras_cambiaron.emit()

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
