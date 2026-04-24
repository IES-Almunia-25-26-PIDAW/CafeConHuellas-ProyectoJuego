extends Node2D

# cafe_kitchen_scene.gd: Controla la visualización y las interacciones de la escena de cocina.
# Se comunica con KitchenManager para toda la lógica, él solo maneja la UI y los clics.

# ===== REFERENCIAS A NODOS =====

@onready var order_items_list: VBoxContainer = %OrderItemsList

@onready var coffee_machine_area: Area2D = %CoffeeMachineArea
@onready var blender_area: Area2D = %BlenderArea

@onready var pastry_shelf: Control = %PastryShelf
@onready var milkshake_shelf: Control = %MilkshakeShelf

# Cartel que se ilumina cuando la orden está completa
@onready var order_ready_sign: Area2D = %OrderReadySign

@onready var sfx_correct: AudioStreamPlayer = %SFXCorrect
@onready var sfx_wrong: AudioStreamPlayer = %SFXWrong

# Popup de ingredientes, está en la escena oculto y se muestra cuando hace falta
@onready var ingredient_popup = %IngredientPopup

# Recetario, está en la escena oculto y se muestra cuando el jugador clica el libro
@onready var recipe_book = %RecipeBook
# Area de click del recetario
@onready var recipe_book_area: Area2D = %RecipeBookArea


# ===== INICIALIZACIÓN =====

# Categoría activa del popup abierto actualmente
var _current_popup_category: String = ""

func _ready() -> void:
	# El cartel empieza oscuro y desactivado hasta que la orden esté completa
	order_ready_sign.monitoring = false
	order_ready_sign.modulate = Color(0.5, 0.5, 0.5, 0.7)
	
	# PENDIENTE - esto es solo para las pruebas
	# TODO: BORRAR ESTO, solo es para probar
	GameState.current_order_recipe_ids = ["cappuccino", "smoothie_strawberry", "cake_apple", "cookie_butter"]
	
	# Conectamos las señales del KitchenManager
	KitchenManager.ingredient_correct.connect(_on_ingredient_correct)
	KitchenManager.ingredient_wrong.connect(_on_ingredient_wrong)
	KitchenManager.ingredient_already_added.connect(_on_ingredient_already_added)
	KitchenManager.recipe_completed.connect(_on_recipe_completed)
	KitchenManager.order_completed.connect(_on_order_completed)
	
	# Conectamos los clics de la cafetera y la batidora
	coffee_machine_area.input_event.connect(_on_coffee_machine_clicked)
	blender_area.input_event.connect(_on_blender_clicked)
	
	# Conectamos el clic del cartel de orden lista
	order_ready_sign.input_event.connect(_on_order_ready_sign_clicked)
	
	# Conectamos el clic del libro del recetario
	recipe_book_area.input_event.connect(_on_recipe_book_clicked)
	
	# Conectamos los KitchenItems de ambos estantes, cada item sabe su propio recipe_id
	for item in pastry_shelf.get_children():
		var kitchen_item := item as KitchenItem
		if kitchen_item:
			kitchen_item.item_clicked.connect(_on_shelf_item_clicked)
			
	for item in milkshake_shelf.get_children():
		var kitchen_item := item as KitchenItem
		if kitchen_item:
			kitchen_item.item_clicked.connect(_on_shelf_item_clicked)

	# Iniciamos la lógica de la orden
	KitchenManager.start_order()

	# Dibujamos el ticket con las recetas del pedido
	_setup_ticket()


# ===== UI =====

# Rellena el ticket con todos los items del pedido
func _setup_ticket() -> void:
	var recipes := KitchenManager.get_current_recipes()
	if recipes.is_empty():
		return

	# Limpiamos el ticket por si hubiera contenido anterior
	for child in order_items_list.get_children():
		child.queue_free()

	# Creamos una fila por cada receta del pedido
	for recipe_id in recipes:
		var recipe: Dictionary = recipes[recipe_id]

		var row := HBoxContainer.new()
		row.name = "Row_" + recipe_id

		var checkbox := TextureRect.new()
		checkbox.name = "Check_" + recipe_id
		checkbox.custom_minimum_size = Vector2(24, 24)
		checkbox.size = Vector2(24, 24)
		checkbox.texture = load("res://assets/images/test_kitchen/check_test.png")
		checkbox.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		checkbox.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		checkbox.modulate = Color(0.1, 0.1, 0.1, 1.0)

		var label := Label.new()
		label.text = recipe.get("display_name", "")

		row.add_child(label)
		row.add_child(checkbox)
		order_items_list.add_child(row)


# Marca el check de una receta completada en el ticket
func _mark_recipe_completed(recipe_id: String) -> void:
	for row in order_items_list.get_children():
		var checkbox := row.find_child("Check_" + recipe_id, true, false)
		if checkbox:
			# Volvemos el modulate a blanco para que se vea la imagen original
			checkbox.modulate = Color.WHITE
			return


# ===== SEÑALES DE KITCHENMANAGER =====

func _on_ingredient_correct(ingredient_id: String, _recipe_id: String) -> void:
	# Un ingrediente correcto, reproducimos el sonido de acierto
	_disable_popup_button(ingredient_id)
	sfx_correct.play()

# Busca el botón del ingrediente en el popup y lo desactiva visualmente
# Se llama solo cuando el ingrediente es correcto, nunca para los incorrectos
func _disable_popup_button(ingredient_id: String) -> void:
	var btn: Button = ingredient_popup.ingredients_grid.find_child("Btn_" + ingredient_id, true, false)
	if btn:
		btn.disabled = true
		btn.modulate = Color(0.5, 0.5, 0.5, 0.7)

func _on_ingredient_wrong(_ingredient_id: String) -> void:
	# El ingrediente no pertenece a ninguna receta del pedido
	sfx_wrong.play()

#PENDIENTE
func _on_ingredient_already_added(_ingredient_id: String) -> void:
	# El jugador ha intentado añadir un ingrediente que ya estaba en la lista
	# El botón ya estará desactivado visualmente así que no hace falta hacer nada más
	# TODO: parpadeo visual en el checkbox ya marcado
	pass

#PENDIENTE
func _on_recipe_completed(recipe_id: String) -> void:
	# Una receta del pedido está completa, marcamos su check en el ticket
	# TODO: cambiar por sonido específico de receta completada cuando tengamos los sonidos definitivos
	_mark_recipe_completed(recipe_id)
	sfx_correct.play()

func _on_order_completed() -> void:
	# Todos los items del pedido están completos, iluminamos el cartel
	order_ready_sign.monitoring = true
	order_ready_sign.modulate = Color.WHITE


# ===== INTERACCIONES =====

# Abre el popup de ingredientes cuando el jugador clica la cafetera
# Solo funciona si hay alguna receta de café en el pedido
func _on_coffee_machine_clicked(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var recipes := KitchenManager.get_current_recipes()
		var has_coffee := false
		for recipe_id in recipes:
			if recipes[recipe_id].get("category", "") == "coffee" and not KitchenManager.is_recipe_completed(recipe_id):
				has_coffee = true
				break
		if not has_coffee:
			sfx_wrong.play()
			return
		get_viewport().set_input_as_handled()
		_open_ingredient_popup("¿Qué le añades al café?", "coffee")

# Abre el popup de ingredientes cuando el jugador clica la batidora
# Solo funciona si hay alguna receta de smoothie en el pedido
func _on_blender_clicked(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var recipes := KitchenManager.get_current_recipes()
		var has_smoothie := false
		for recipe_id in recipes:
			if recipes[recipe_id].get("category", "") == "smoothie" and not KitchenManager.is_recipe_completed(recipe_id):
				has_smoothie = true
				break
		if not has_smoothie:
			sfx_wrong.play()
			return
		get_viewport().set_input_as_handled()
		_open_ingredient_popup("¿Qué le añades al smoothie?", "smoothie")

# Recibe el recipe_id del item clickado
func _on_shelf_item_clicked(recipe_id: String) -> void:
	KitchenManager.try_complete_direct_recipe(recipe_id)

# Muestra el popup con solo los ingredientes de la categoría activa
func _open_ingredient_popup(title: String, category: String) -> void:
	_current_popup_category = category
	
	# Si ya está visible no hacemos nada
	if ingredient_popup.visible:
		return

	# Recopilamos todos los ingredientes posibles de la categoría desde el DataLoader
	var all_recipes := DataLoader.get_all_recipes()
	var category_ingredients: Array = []
	for recipe_id in all_recipes:
		if all_recipes[recipe_id].get("category", "") == category:
			for ingredient_id in all_recipes[recipe_id].get("ingredients", []):
				if not category_ingredients.has(ingredient_id):
					category_ingredients.append(ingredient_id)

	# Obtenemos los ingredientes ya añadidos en esta categoría para marcarlos en el popup
	var already_added := KitchenManager.get_added_ingredients_for_category(category)

	# Configuramos el popup con los ingredientes de la categoría
	ingredient_popup.setup(title, category_ingredients, already_added)

	# Conectamos sus señales si no están conectadas ya
	if not ingredient_popup.ingredient_selected.is_connected(_on_popup_ingredient_selected):
		ingredient_popup.ingredient_selected.connect(_on_popup_ingredient_selected)
	if not ingredient_popup.popup_closed.is_connected(_on_popup_closed):
		ingredient_popup.popup_closed.connect(_on_popup_closed)

	# Mostramos el popup
	ingredient_popup.show()


# Recibe el ingrediente seleccionado en el popup y se lo pasa al KitchenManager con la categoría activa
func _on_popup_ingredient_selected(ingredient_id: String) -> void:
	KitchenManager.try_add_ingredient(ingredient_id, _current_popup_category)

# Se llama cuando el jugador cierra el popup manualmente
# Aunque esté vacía es por si en el futuro queremos hacer algo cuando el jugador cierre el popup
func _on_popup_closed() -> void:
	pass

# Abre el recetario cuando el jugador clica el libro
func _on_recipe_book_clicked(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		recipe_book.show()

# Se llama cuando el jugador clica el cartel de orden lista
func _on_order_ready_sign_clicked(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Si la orden no está completa, ignoramos el clic
		if not order_ready_sign.monitoring:
			return
		get_viewport().set_input_as_handled()
		# La orden está completa, limpiamos el estado y volvemos al mostrador con fade
		KitchenManager.finish_order()
		# Transición de vuelta a la escena del mostrador usando el autoload TransitionManager
		TransitionManager.change_scene("res://scenes/cafe_client_zone.tscn")
