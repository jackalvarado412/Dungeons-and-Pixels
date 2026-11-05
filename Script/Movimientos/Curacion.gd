func usar_pocion() -> void:
	if Inventario.cantidad_item("pocion") > 0:
		Inventario.eliminar_item("pocion", 1)
		curar(25)
		print("Usaste una poción")
	else:
		print("No tienes pociones")
		func _process(_delta):
	if Input.is_action_just_pressed("usar_pocion"):
		usar_pocion()
