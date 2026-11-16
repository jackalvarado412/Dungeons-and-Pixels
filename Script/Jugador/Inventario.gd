extends Node
var items: Dictionary = {}
func agregar_item(id:String, cantidad:int = 1) -> void:
	if items.has(id):
		items[id] += cantidad
	else:
		items[id] = cantidad
	print("Inventario:", items)
func eliminar_item(id:String, cantidad:int = 1) -> bool:
	if !items.has(id):
		return false
	items[id] -= cantidad
	if items[id] <= 0:
		items.erase(id)
	return true
func tiene_item(id:String) -> bool:
	return items.has(id)
func cantidad_item(id:String) -> int:
	if items.has(id):
		return items[id]
	return 0
