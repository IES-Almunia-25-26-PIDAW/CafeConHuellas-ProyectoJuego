extends Node

# KitchenManager: Gestiona toda la lógica de la escena de cocina.
# Sabe qué receta hay que preparar, qué ingredientes se han añadido,
# y avisa al resto de la escena cuando la orden está completa.

# ===== SEÑALES =====

# Se emite cuando el jugador añade un ingrediente correcto
signal ingredient_correct(ingredient_id: String)
# Se emite cuando el jugador añade un ingrediente que no pertenece a la receta
signal ingredient_wrong(ingredient_id: String)
# Se emite cuando el jugador intenta añadir un ingrediente que ya añadió antes
signal ingredient_already_added(ingredient_id: String)
# Se emite cuando todos los ingredientes de la orden están completos
signal order_completed


# ===== ESTADO INTERNO =====

# Datos completos de la receta que hay que preparar (viene de DataLoader)
var _current_recipe: Dictionary = {}
# Lista de ingredientes que el jugador todavía tiene que añadir
var _remaining_ingredients: Array[String] = []
# Lista de ingredientes que el jugador ya ha añadido correctamente
var _added_ingredients: Array[String] = []


# ===== PUBLIC API =====

# Inicia la lógica de la cocina con la receta pedida por el cliente.
# Se llama desde la escena de cocina en su _ready().
func start_order() -> void:
	var recipe_id := GameState.current_order_recipe_id

	# Comprobación de seguridad: si no hay orden activa, avisamos y salimos
	if recipe_id.is_empty():
		push_error("KitchenManager: start_order() llamado sin current_order_recipe_id en GameState.")
		return

	# Cargamos los datos completos de la receta desde DataLoader
	_current_recipe = DataLoader.get_recipe(recipe_id)
	if _current_recipe.is_empty():
		push_error("KitchenManager: La receta '%s' no existe en DataLoader." % recipe_id)
		return

	# Copiamos los ingredientes necesarios a la lista de pendientes
	_remaining_ingredients.assign(_current_recipe["ingredients"])
	# Limpiamos la lista de ya añadidos por si hubiera basura de una orden anterior
	_added_ingredients.clear()


# El jugador ha hecho clic en un ingrediente. Comprobamos si es correcto.
func try_add_ingredient(ingredient_id: String) -> void:
	if _added_ingredients.has(ingredient_id):
		# El jugador ha repetido un ingrediente que ya añadió, lo ignoramos sin penalizar
		ingredient_already_added.emit(ingredient_id)
	elif _remaining_ingredients.has(ingredient_id):
		_remaining_ingredients.erase(ingredient_id)
		_added_ingredients.append(ingredient_id)
		ingredient_correct.emit(ingredient_id)

		# Si ya no quedan ingredientes pendientes, la orden está completa
		if _remaining_ingredients.is_empty():
			order_completed.emit()
	else:
		ingredient_wrong.emit(ingredient_id)


# Devuelve los datos de la receta activa (para que la UI pueda mostrar el ticket) (Devuelve una copia para que nadie pueda modificar los datos por accidente)
func get_current_recipe() -> Dictionary:
	return _current_recipe.duplicate()

# Devuelve true si el ingrediente ya fue añadido correctamente
func is_ingredient_added(ingredient_id: String) -> bool:
	return _added_ingredients.has(ingredient_id)


# Limpia el estado al terminar (se llama al completar la orden antes de cambiar de escena)
func finish_order() -> void:
	GameState.current_order_recipe_id = ""
	_current_recipe = {}
	_remaining_ingredients = []
	_added_ingredients = []
