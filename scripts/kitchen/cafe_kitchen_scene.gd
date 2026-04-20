extends Node2D

# cafe_kitchen_scene.gd: Controla la visualización y las interacciones de la escena de cocina.
# Se comunica con KitchenManager para toda la lógica, él solo maneja la UI y los clics.

# ===== REFERENCIAS A NODOS =====

@onready var recipe_name: Label = $UICanvas/OrderTicket/TicketPanel/TicketContent/RecipeName
@onready var ingredients_list: VBoxContainer = $UICanvas/OrderTicket/TicketPanel/TicketContent/IngredientsList
@onready var confirm_button: Button = $UICanvas/OrderTicket/TicketPanel/TicketContent/ConfirmButton

@onready var coffee_machine_area: Area2D = $InteractionCanvas/CoffeeMachineArea
@onready var blender_area: Area2D = $InteractionCanvas/BlenderArea

@onready var pastry_shelf: Node2D = $InteractionCanvas/PastryShelf


# ===== INICIALIZACIÓN =====

func _ready() -> void:
	# Ocultamos el botón de confirmar hasta que la orden esté completa
	confirm_button.visible = false

	# Conectamos las señales del KitchenManager
	KitchenManager.ingredient_correct.connect(_on_ingredient_correct)
	KitchenManager.ingredient_wrong.connect(_on_ingredient_wrong)
	KitchenManager.ingredient_already_added.connect(_on_ingredient_already_added)
	KitchenManager.order_completed.connect(_on_order_completed)

	# Conectamos los clics de la cafetera y la batidora
	coffee_machine_area.input_event.connect(_on_coffee_machine_clicked)
	blender_area.input_event.connect(_on_blender_clicked)

	# Conectamos el botón de confirmar
	confirm_button.pressed.connect(_on_confirm_pressed)

	# Iniciamos la lógica de la orden
	KitchenManager.start_order()

	# Dibujamos el ticket con la receta activa
	_setup_ticket()


# ===== UI =====

# Rellena el ticket con el nombre de la receta y la lista de ingredientes
func _setup_ticket() -> void:
	var recipe := KitchenManager.get_current_recipe()
	if recipe.is_empty():
		return

	# Ponemos el nombre de la receta en el título del ticket
	recipe_name.text = recipe["display_name"]

	# Creamos una fila por cada ingrediente con su nombre y un checkbox
	for ingredient_id in recipe["ingredients"]:
		var ingredient := DataLoader.get_ingredient(ingredient_id)
		if ingredient.is_empty():
			continue

		var row := HBoxContainer.new()
		var checkbox := TextureRect.new()
		var label := Label.new()

		checkbox.name = "Check_" + ingredient_id
		checkbox.custom_minimum_size = Vector2(24, 24)

		label.text = ingredient["display_name"]

		row.add_child(checkbox)
		row.add_child(label)
		ingredients_list.add_child(row)


# Marca el checkbox de un ingrediente como completado
func _mark_ingredient(ingredient_id: String) -> void:
	var checkbox := ingredients_list.find_child("Check_" + ingredient_id, true, false)
	if checkbox:
		# Por ahora cambia la modulate a verde, cuando haya arte se cambia por una textura que haga nuestra pedazo de artista
		checkbox.modulate = Color.GREEN


# ===== SEÑALES DE KITCHENMANAGER =====

func _on_ingredient_correct(ingredient_id: String) -> void:
	_mark_ingredient(ingredient_id)
	# TODO: reproducir SFXCorrect

func _on_ingredient_wrong(_ingredient_id: String) -> void:
	# TODO: reproducir SFXWrong
	pass

func _on_ingredient_already_added(_ingredient_id: String) -> void:
	# TODO: parpadeo visual en el checkbox ya marcado
	pass

func _on_order_completed() -> void:
	confirm_button.visible = true


# ===== INTERACCIONES =====

func _on_coffee_machine_clicked(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		# TODO: abrir popup de ingredientes del café

func _on_blender_clicked(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		# TODO: abrir popup de ingredientes del smoothie

func _on_confirm_pressed() -> void:
	KitchenManager.finish_order()
	# TODO: transición de vuelta a la escena del mostrador
	pass
