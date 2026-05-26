## Controla la visualización e interacciones de la escena de cocina.
## Se comunica con KitchenManager para toda la lógica de recetas e ingredientes.
## Este script solo gestiona la UI y los clics, KitchenManager gestiona el estado.
extends Node2D


# ===== REFERENCIAS A NODOS =====

@onready var order_items_list: VBoxContainer = %OrderItemsList
@onready var coffee_machine: TextureButton = %CoffeeMachineBtn
@onready var blender: TextureButton = %BlenderBtn
# Cartel que se ilumina cuando la orden está completa.
@onready var order_ready_sign: TextureButton = %OrderReadySignBtn
# Area de click del recetario.
@onready var recipe_book_btn: TextureButton = %RecipeBookBtn
@onready var pastry_shelf: Control = %PastryShelf
@onready var milkshake_shelf: Control = %MilkshakeShelf

# Sonidos
@onready var sfx_wrong: AudioStreamPlayer = %SFXWrong
@onready var sfx_correct: AudioStreamPlayer = %SFXCorrect
@onready var sfx_recipe_completed: AudioStreamPlayer = %SFXRecipeCompleted
@onready var sfx_order_completed: AudioStreamPlayer = %SFXOrderCompleted

# Popup de ingredientes, está en la escena oculto y se muestra cuando hace falta
@onready var ingredient_popup = %IngredientPopup
# Recetario, está en la escena oculto y se muestra cuando el jugador clica el libro
@onready var recipe_book = %RecipeBook

# UICanvas para agregar el popup
@onready var ui_canvas: CanvasLayer = %UICanvas


# ===== CONSTANTES Y VARIABLES =====

# Popup de cuando se completa una parte de la orden.
const RecipeCompletedPopup: PackedScene = preload("res://scenes/kitchen/recipe_completed_popup.tscn")

# Categoría activa del popup abierto actualmente
var _current_popup_category: String = ""


# ===== CICLO DE VIDA =====

func _ready() -> void:
	SceneManager.transition_in()
	MusicManager.play("cute_bossa_nova") 
	# OrderReadySignBtn empieza desactivado hasta que la orden esté completa.
	order_ready_sign.disabled = true
	
	# PENDIENTE - esto es solo para las pruebas
	# TODO: BORRAR ESTO, solo es para probar
	GameState.current_order_recipe_ids = ["cappuccino", "smoothie_strawberry", "cake_apple", "cookie_butter"]
	
	# Conectamos las señales del KitchenManager.
	KitchenManager.ingredient_correct.connect(_on_ingredient_correct)
	KitchenManager.ingredient_wrong.connect(_on_ingredient_wrong)
	KitchenManager.ingredient_already_added.connect(_on_ingredient_already_added)
	KitchenManager.recipe_completed.connect(_on_recipe_completed)
	KitchenManager.order_completed.connect(_on_order_completed)
	
	# Conectamos los clics de la cafetera y la batidora.
	coffee_machine.pressed.connect(_on_coffee_machine_pressed)
	blender.pressed.connect(_on_blender_pressed)
	# Conectamos el clic del cartel de orden lista.
	order_ready_sign.pressed.connect(_on_order_ready_sign_pressed)
	# Conectamos el clic del libro del recetario.
	recipe_book_btn.pressed.connect(_on_recipe_book_pressed)
	
	# Conectamos los KitchenItems de ambos estantes, cada item sabe su propio recipe_id.
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

# Rellena el ticket con todos los items del pedido activo.
func _setup_ticket() -> void:
	var recipes : Dictionary = KitchenManager.get_current_recipes()
	if recipes.is_empty():
		return
	
	# Limpiamos el ticket por si hubiera contenido anterior.
	for child in order_items_list.get_children():
		child.queue_free()
	
	# Creamos una fila por cada receta del pedido.
	for recipe_id in recipes:
		var recipe: Dictionary = recipes[recipe_id]
		
		var row := HBoxContainer.new()
		row.name = "Row_" + recipe_id
		row.add_theme_constant_override("separation", 8)
		
		var checkbox := TextureRect.new()
		checkbox.name = "Check_" + recipe_id
		checkbox.custom_minimum_size = Vector2(24, 24)
		checkbox.size = Vector2(24, 24)
		checkbox.texture = load("res://assets/images/ui/check_pink.png")
		checkbox.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		checkbox.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		checkbox.modulate = Color(0.1, 0.1, 0.1, 1.0)
		
		var label := RichTextLabel.new()
		label.text = recipe.get("display_name", "")
		label.fit_content = true
		label.scroll_active = false
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.add_theme_font_override("normal_font", load("res://assets/fonts/PatrickHand-Regular.ttf"))
		label.add_theme_font_size_override("normal_font_size", 22)
		label.add_theme_color_override("default_color", Color(0.42745098, 0.30980393, 0.2509804, 1))
		
		row.add_child(label)
		row.add_child(checkbox)
		order_items_list.add_child(row)


# Marca el check de una receta completada en el ticket poniéndolo blanco.
func _mark_recipe_completed(recipe_id: String) -> void:
	for row in order_items_list.get_children():
		var checkbox := row.find_child("Check_" + recipe_id, true, false)
		if checkbox:
			# Volvemos el modulate a blanco para que se vea la imagen original.
			checkbox.modulate = Color.WHITE
			return


# ===== SEÑALES DE KITCHENMANAGER =====

# Desactiva el botón del ingrediente en el popup y reproduce el sonido de acierto.
func _on_ingredient_correct(ingredient_id: String, _recipe_id: String) -> void:
	_disable_popup_button(ingredient_id)
	sfx_correct.play()

# Busca el botón del ingrediente en el popup y lo desactiva visualmente.
# Se llama solo cuando el ingrediente es correcto, nunca para los incorrectos.
func _disable_popup_button(ingredient_id: String) -> void:
	var btn: TextureButton = ingredient_popup.find_child("Btn_" + ingredient_id, true, false)
	if btn:
		btn.disabled = true
		btn.modulate = Color(0.743, 0.743, 0.743, 0.702)

# Reproduce el sonido de fallo cuando el ingrediente no pertenece a ninguna receta.
func _on_ingredient_wrong(_ingredient_id: String) -> void:
	sfx_wrong.play()

# PENDIENTE
func _on_ingredient_already_added(_ingredient_id: String) -> void:
	# El jugador ha intentado añadir un ingrediente que ya estaba en la lista.
	# El botón ya estará desactivado visualmente así que no hace falta hacer nada más.
	# TODO: parpadeo visual en el checkbox ya marcado
	pass

# TODO: PENDIENTE
# Marca la receta como completada en el ticket y muestra el popup de receta completada.
func _on_recipe_completed(recipe_id: String) -> void:
	# Una receta del pedido está completa, marcamos su check en el ticket
	_mark_recipe_completed(recipe_id)
	sfx_recipe_completed.play()
	_show_recipe_completed_popup(recipe_id)

# Espera al sonido de receta, reproduce el de orden completa e ilumina el cartel.
func _on_order_completed() -> void:
	# Esperamos a que termine el sonido de receta completada antes de reproducir el de orden completa.
	await sfx_recipe_completed.finished
	sfx_order_completed.play()
	# Todos los items del pedido están completos, iluminamos el cartel.
	order_ready_sign.disabled = false
	# Al desactivar disabled, Godot cambia automáticamente a texture_normal.
	# pero añadimos el tween encima para suavizar la transición.
	order_ready_sign.modulate = Color(0.9, 0.783, 0.783, 0.012)
	# Tween es una herramienta de Godot que interpola valores automáticamente en cada frame,
	# aquí lo usamos para animar el modulate de oscuro a blanco en 0.6s sin tocar _process().
	var tween = create_tween()
	tween.tween_property(order_ready_sign, "modulate", Color.WHITE, 0.6)\
		 .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

# Instancia el popup de receta completada y lo añade al UICanvas para que esté por encima de todo.
func _show_recipe_completed_popup(recipe_id: String) -> void:
	var recipe : Dictionary = DataLoader.get_recipe(recipe_id)
	if recipe.is_empty():
		return
	
	var popup: Control = RecipeCompletedPopup.instantiate()
	# Se añade al UICanvas para que esté por encima de todo.
	ui_canvas.add_child(popup)
	
	var display_name: String = recipe.get("display_name", recipe_id)
	var image_path: String   = recipe.get("recipe_image", "")
	popup.setup(display_name, image_path)


# ===== INTERACCIONES =====

# Abre el popup de ingredientes cuando el jugador clica la cafetera.
# Solo funciona si hay alguna receta de café en el pedido.
func _on_coffee_machine_pressed() -> void:
	var recipes : Dictionary = KitchenManager.get_current_recipes()
	var has_coffee := false
	for recipe_id in recipes:
		if recipes[recipe_id].get("category", "") == "coffee" and not KitchenManager.is_recipe_completed(recipe_id):
			has_coffee = true
			break
	if not has_coffee:
		
		return
	_open_ingredient_popup("¿Qué le añades al café?", "coffee")


# Abre el popup de ingredientes cuando el jugador clica la batidora.
# Solo funciona si hay alguna receta de smoothie en el pedido.
func _on_blender_pressed() -> void:
	var recipes : Dictionary = KitchenManager.get_current_recipes()
	var has_smoothie := false
	for recipe_id in recipes:
		if recipes[recipe_id].get("category", "") == "smoothie" and not KitchenManager.is_recipe_completed(recipe_id):
			has_smoothie = true
			break
	if not has_smoothie:
		
		return
	_open_ingredient_popup("¿Qué le añades al smoothie?", "smoothie")

# Completa directamente la receta del item clicado en el estante.
func _on_shelf_item_clicked(recipe_id: String) -> void:
	KitchenManager.try_complete_direct_recipe(recipe_id)

# Cuando se hace click al libro abre el libro de recetas.
func _on_recipe_book_pressed() -> void:
	recipe_book.show()

# Finaliza la orden y vuelve a la escena de diálogo.
func _on_order_ready_sign_pressed() -> void:
	# Si llega aquí, la orden ya está completa (ya que el cartel está en disabled por defecto).
	KitchenManager.finish_order()
	var return_file: String = "res://resources/story/" + GameState.chapter_id + ".json"
	TransitionManager.change_scene("res://scenes/cafe_client_zone.tscn")

# Muestra el popup con solo los ingredientes de la categoría activa.
func _open_ingredient_popup(title: String, category: String) -> void:
	_current_popup_category = category
	
	# Si ya está visible no hacemos nada
	if ingredient_popup.visible:
		return
	
	# Recopilamos todos los ingredientes posibles de la categoría desde el DataLoader.
	var all_recipes : Dictionary = DataLoader.get_all_recipes()
	var category_ingredients: Array = []
	for recipe_id in all_recipes:
		if all_recipes[recipe_id].get("category", "") == category:
			for ingredient_id in all_recipes[recipe_id].get("ingredients", []):
				if not category_ingredients.has(ingredient_id):
					category_ingredients.append(ingredient_id)
	
	# Obtenemos los ingredientes ya añadidos en esta categoría para marcarlos en el popup.
	var already_added : Array = KitchenManager.get_added_ingredients_for_category(category)
	
	# Configuramos el popup con los ingredientes de la categoría.
	ingredient_popup.setup(title, category_ingredients, already_added)
	
	# Conectamos sus señales si no están conectadas ya.
	if not ingredient_popup.ingredient_selected.is_connected(_on_popup_ingredient_selected):
		ingredient_popup.ingredient_selected.connect(_on_popup_ingredient_selected)
	if not ingredient_popup.popup_closed.is_connected(_on_popup_closed):
		ingredient_popup.popup_closed.connect(_on_popup_closed)

	# Mostramos el popup.
	ingredient_popup.show()


# Pasa el ingrediente seleccionado al KitchenManager con la categoría activa.
func _on_popup_ingredient_selected(ingredient_id: String) -> void:
	KitchenManager.try_add_ingredient(ingredient_id, _current_popup_category)

# Se llama cuando el jugador cierra el popup manualmente.
# Aunque esté vacía es por si en el futuro queremos hacer algo cuando el jugador cierre el popup.
func _on_popup_closed() -> void:
	pass
