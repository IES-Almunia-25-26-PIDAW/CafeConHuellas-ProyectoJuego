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
@onready var milkshake_shelf: Node2D = $InteractionCanvas/MilkshakeShelf

@onready var sfx_correct: AudioStreamPlayer = $SFXCorrect
@onready var sfx_wrong: AudioStreamPlayer = $SFXWrong

# ===== INICIALIZACIÓN =====

func _ready() -> void:
	# Ocultamos el botón de confirmar hasta que la orden esté completa
	confirm_button.visible = false

	# TODO: BORRAR ESTO, solo es para probar
	GameState.current_order_recipe_id = "cappuccino"

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

	# Conectamos los clics de cada tarta y galleta del estante
	for area in pastry_shelf.get_children():
		area.input_event.connect(_on_pastry_clicked.bind(area.name))

	# Conectamos los clics de cada batido y leche
	for area in milkshake_shelf.get_children():
		area.input_event.connect(_on_pastry_clicked.bind(area.name))


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
	# Marca el checkbox en el ticket y desactiva el botón en el popup
	_mark_ingredient(ingredient_id)
	_disable_popup_button(ingredient_id)
	sfx_correct.play()

# Busca el botón del ingrediente en el popup y lo desactiva visualmente
# Se llama solo cuando el ingrediente es correcto, nunca para los incorrectos
func _disable_popup_button(ingredient_id: String) -> void:
	var popup := $UICanvas.find_child("IngredientPopup", true, false)
	if popup == null:
		return
	var btn: Button = popup.ingredients_grid.find_child("Btn_" + ingredient_id, true, false)
	if btn:
		btn.disabled = true
		btn.modulate = Color(0.5, 0.5, 0.5, 0.7)

func _on_ingredient_wrong(_ingredient_id: String) -> void:
	# El ingrediente no pertenece a la receta
	sfx_wrong.play()

func _on_ingredient_already_added(_ingredient_id: String) -> void:
	# El jugador ha intentado añadir un ingrediente que ya estaba en la lista
	# El botón ya estará desactivado visualmente así que no hace falta hacer nada más
	# TODO: parpadeo visual en el checkbox ya marcado
	pass

func _on_order_completed() -> void:
	# Todos los ingredientes están añadidos, mostramos el botón de confirmar
	confirm_button.visible = true


# ===== INTERACCIONES =====

# Abre el popup de ingredientes cuando el jugador clica la cafetera
func _on_coffee_machine_clicked(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		_open_ingredient_popup("¿Qué le añades al café?")

# Abre el popup de ingredientes cuando el jugador clica la batidora
func _on_blender_clicked(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		_open_ingredient_popup("¿Qué le añades al smoothie?")


# Detecta qué tarta o galleta ha clicado el jugador y lo pasa al KitchenManager
func _on_pastry_clicked(_viewport: Node, event: InputEvent, _shape_idx: int, area_name: String) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		# Convertimos el nombre del nodo al ID de la receta
		# Ej: "CakeAppleArea" --> "cake_apple"
		var recipe_id := _area_name_to_recipe_id(area_name)
		KitchenManager.try_add_ingredient(recipe_id)

# Convierte el nombre del nodo Area2D al ID del ingrediente correspondiente
func _area_name_to_recipe_id(area_name: String) -> String:
	var map := {
		"CakeAppleArea": "cake_apple",
		"CakeCarrotArea": "cake_carrot",
		"CakeLemonArea": "cake_lemon",
		"CakeCheeseArea": "cake_cheese",
		"CookieButterArea": "cookie_butter",
		"CookieChocolateArea": "cookie_chocolate",
		"CookieOatHoneyArea": "cookie_oat_honey",
		"MilkshakeChocolateArea": "milkshake_chocolate",
		"MilkshakeVanillaArea": "milkshake_vanilla",
		"MilkshakeStrawberryArea": "milkshake_strawberry",
		"MilkDrinkArea": "milk_drink"
	}
	return map.get(area_name, "")


# Instancia el popup y lo configura con los ingredientes de la receta activa
func _open_ingredient_popup(title: String) -> void:
	# Si ya hay un popup abierto no abrimos otro
	if $UICanvas.find_child("IngredientPopup", true, false) != null:
		return

	var recipe := KitchenManager.get_current_recipe()
	if recipe.is_empty():
		return

	var popup_scene := preload("res://scenes/kitchen/ingredient_popup.tscn")
	var popup := popup_scene.instantiate()

	# Lo añadimos al UICanvas para que quede por encima de todo
	$UICanvas.add_child(popup)
	# Lo centramos en pantalla
	popup.set_anchors_preset(Control.PRESET_CENTER)

	# Lo configuramos con el título y todos los ingredientes disponibles
	var all_ingredients := DataLoader.get_all_ingredients()
	popup.setup(title, all_ingredients.keys())

	# Conectamos sus señales
	popup.ingredient_selected.connect(_on_popup_ingredient_selected)
	popup.popup_closed.connect(_on_popup_closed)

# Recibe el ingrediente seleccionado en el popup y se lo pasa al KitchenManager
func _on_popup_ingredient_selected(ingredient_id: String) -> void:
	KitchenManager.try_add_ingredient(ingredient_id)

# Se llama cuando el jugador cierra el popup manualmente
# Aunque esté vacía es por si en el futuro queremos hacer algo cuando el jugador cierre el popup, 
# por ejemplo reproducir un sonido de cierre, o una animación
# el popup ya se destruye solo con el queue_free() que tiene en su propio script
func _on_popup_closed() -> void:
	pass


func _on_confirm_pressed() -> void:
	# La orden está completa, limpiamos el estado y volvemos al mostrador
	KitchenManager.finish_order()
	# Transición de vuelta a la escena del mostrador
	get_tree().change_scene_to_file("res://scenes/cafe_client_zone.tscn")
