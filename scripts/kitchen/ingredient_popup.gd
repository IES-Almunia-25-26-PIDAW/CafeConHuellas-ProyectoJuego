extends Control

# ingredient_popup.gd: Muestra los ingredientes disponibles para que el jugador los seleccione.
# Se usa tanto para la cafetera como para la batidora.
# Recibe una lista de ingredient_ids y genera un botón por cada uno.

# ===== SEÑALES =====

# Se emite cuando el jugador hace clic en un ingrediente
signal ingredient_selected(ingredient_id: String)
# Se emite cuando el jugador cierra el popup
signal popup_closed


# ===== REFERENCIAS A NODOS =====

@onready var popup_title: Label = $PopupPanel/PopupContent/PopupTitle
@onready var ingredients_grid: GridContainer = $PopupPanel/PopupContent/IngredientsGrid


# ===== PUBLIC API =====

# Configura y muestra el popup con los ingredientes de la receta activa.
# Se llama desde cafe_kitchen_scene.gd cuando el jugador clica la cafetera o la batidora.
func setup(title: String, ingredient_ids: Array, already_added: Array = []) -> void:
	popup_title.text = title

	# Limpiamos la cuadrícula por si el popup se reutiliza
	for child in ingredients_grid.get_children():
		child.queue_free()

	# Creamos un botón por cada ingrediente
	for ingredient_id in ingredient_ids:
		var ingredient := DataLoader.get_ingredient(ingredient_id)
		if ingredient.is_empty():
			continue

		# Cuando tengamos las fotos de los ingredientes, se cambia a TextureButton.new() y a "icon"
		var btn := Button.new()
		btn.name = "Btn_" + ingredient_id
		btn.text = ingredient["display_name"]

		# Si el ingrediente ya fue añadido, desactivamos el botón visualmente
		if already_added.has(ingredient_id):
			btn.disabled = true
			btn.modulate = Color(0.5, 0.5, 0.5, 0.7)

		#PENDIENTE: TODO cambiaremos los botones por TextureButton
		# Cuando tengamos los dibujos listos en res://assets/images/ingredients/,
		# (añadir también un texture_hover para el efecto hover), pondríamos algo como:
		# var texture = load(ingredient["icon"])
		# if texture:
		# 	btn.texture_normal = texture

		btn.pressed.connect(_on_ingredient_pressed.bind(ingredient_id))
		ingredients_grid.add_child(btn)


# ===== INTERACCIONES =====

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		# Si el clic no está dentro del PopupPanel, cerramos el popup
		if not $PopupPanel.get_rect().has_point(get_local_mouse_position()):
			popup_closed.emit()
			hide()


func _on_ingredient_pressed(ingredient_id: String) -> void:
	ingredient_selected.emit(ingredient_id)
