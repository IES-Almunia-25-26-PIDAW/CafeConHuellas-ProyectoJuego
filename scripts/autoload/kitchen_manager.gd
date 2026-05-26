## Autoload singleton que gestiona toda la lógica de la escena de cocina.
## Controla el estado de un pedido activo: ingredientes pendientes, añadidos y recetas completadas.
## Soporta pedidos con múltiples recetas (máximo 4) que el jugador puede preparar en cualquier orden.
## [br]
## Flujo típico:
##   1. La escena de cocina llama a start_order() en su _ready()
##   2. El jugador interactúa y se llama a try_add_ingredient() o try_complete_direct_recipe()
##   3. Cuando order_completed se emite, la escena puede llamar a finish_order()
extends Node

# ===== SEÑALES =====

## Se emite cuando el jugador añade un ingrediente correcto a cualquier receta del pedido.
signal ingredient_correct(ingredient_id: String, recipe_id: String)
## Se emite cuando el jugador añade un ingrediente que no pertenece a ninguna receta pendiente.
signal ingredient_wrong(ingredient_id: String)
## Se emite cuando el jugador intenta añadir un ingrediente que ya añadió antes.
signal ingredient_already_added(ingredient_id: String)
## Se emite cuando una receta individual del pedido se completa.
signal recipe_completed(recipe_id: String)
## Se emite cuando todos los items del pedido están completos.
signal order_completed


# ===== ESTADO INTERNO =====
# Todos estos diccionarios se indexan por recipe_id y se limpian en start_order() y finish_order().

# Datos completos de cada receta del pedido, indexados por recipe_id.
var _recipes: Dictionary = {}
# Ingredientes pendientes por receta: { recipe_id: [ingredient_ids] }.
var _remaining_ingredients: Dictionary = {}
# Ingredientes ya añadidos por receta: { recipe_id: [ingredient_ids] }.
var _added_ingredients: Dictionary = {}
# Recetas ya completadas.
var _completed_recipes: Array[String] = []


# ===== PUBLIC API =====

## Inicia la lógica de cocina con las recetas del pedido activo en GameState.
## Debe llamarse desde la escena de cocina en su _ready().
func start_order() -> void:
	var recipe_ids := GameState.current_order_recipe_ids

	# Comprobación de seguridad: si no hay orden activa, avisamos y salimos.
	if recipe_ids.is_empty():
		push_error("KitchenManager: start_order() llamado sin current_order_recipe_ids en GameState.")
		return

	# Limpiamos el estado anterior.
	_recipes.clear()
	_remaining_ingredients.clear()
	_added_ingredients.clear()
	_completed_recipes.clear()

	# Cargamos cada receta del pedido.
	for recipe_id in recipe_ids:
		var recipe := DataLoader.get_recipe(recipe_id)
		if recipe.is_empty():
			push_error("KitchenManager: La receta '%s' no existe en DataLoader." % recipe_id)
			continue

		_recipes[recipe_id] = recipe
		_remaining_ingredients[recipe_id] = recipe["ingredients"].duplicate()
		_added_ingredients[recipe_id] = []


## Procesa el intento del jugador de añadir un ingrediente.
## Si se especifica categoría, solo comprueba contra recetas de esa categoría.
## Emite ingredient_correct, ingredient_wrong o ingredient_already_added según el resultado.
func try_add_ingredient(ingredient_id: String, category: String = "") -> void:
	# Comprobamos si ya fue añadido en una receta de la misma categoría.
	for recipe_id in _added_ingredients:
		if category != "" and _recipes[recipe_id].get("category", "") != category:
			continue
		if _added_ingredients[recipe_id].has(ingredient_id):
			ingredient_already_added.emit(ingredient_id)
			return

	# Buscamos en qué receta pendiente encaja este ingrediente.
	# Si se especifica categoría, solo buscamos en recetas de esa categoría.
	for recipe_id in _remaining_ingredients:
		if _completed_recipes.has(recipe_id):
			continue
		if category != "" and _recipes[recipe_id].get("category", "") != category:
			continue
		if _remaining_ingredients[recipe_id].has(ingredient_id):
			_remaining_ingredients[recipe_id].erase(ingredient_id)
			_added_ingredients[recipe_id].append(ingredient_id)
			ingredient_correct.emit(ingredient_id, recipe_id)

			# Comprobamos si esta receta está completa.
			if _remaining_ingredients[recipe_id].is_empty():
				_completed_recipes.append(recipe_id)
				recipe_completed.emit(recipe_id)

				# Comprobamos si el pedido entero está completo.
				if _completed_recipes.size() == _recipes.size():
					order_completed.emit()
			return

	# Si no encaja en ninguna receta pendiente, es incorrecto.
	ingredient_wrong.emit(ingredient_id)


## Devuelve los datos de todas las recetas del pedido activo.
## Devuelve una copia para evitar modificaciones accidentales desde fuera.
func get_current_recipes() -> Dictionary:
	return _recipes.duplicate()


## Devuelve true si el ingrediente ya fue añadido en cualquier receta del pedido.
func is_ingredient_added(ingredient_id: String) -> bool:
	for recipe_id in _added_ingredients:
		if _added_ingredients[recipe_id].has(ingredient_id):
			return true
	return false

## Devuelve los ingredientes ya añadidos en recetas de una categoría específica.
func get_added_ingredients_for_category(category: String) -> Array:
	var result: Array = []
	for recipe_id in _added_ingredients:
		if _recipes[recipe_id].get("category", "") != category:
			continue
		for ingredient_id in _added_ingredients[recipe_id]:
			if not result.has(ingredient_id):
				result.append(ingredient_id)
	return result


## Devuelve true si una receta específica ya está completada.
func is_recipe_completed(recipe_id: String) -> bool:
	return _completed_recipes.has(recipe_id)

## Completa directamente una receta de tipo direct_click (repostería, batidos).
## Se llama cuando el jugador clica directamente en el producto sin añadir ingredientes.
func try_complete_direct_recipe(recipe_id: String) -> void:
	# Comprobamos si esta receta está en el pedido.
	if not _recipes.has(recipe_id):
		ingredient_wrong.emit(recipe_id)
		return

	# Comprobamos si ya está completada.
	if _completed_recipes.has(recipe_id):
		ingredient_already_added.emit(recipe_id)
		return

	# La completamos directamente.
	_completed_recipes.append(recipe_id)
	_remaining_ingredients[recipe_id].clear()
	recipe_completed.emit(recipe_id)

	# Comprobamos si el pedido entero está completo.
	if _completed_recipes.size() == _recipes.size():
		order_completed.emit()


## Limpia todo el estado del pedido al terminar.
## Debe llamarse cuando la escena de cocina se cierra o el pedido se entrega.
func finish_order() -> void:
	GameState.current_order_recipe_ids.clear()
	_recipes.clear()
	_remaining_ingredients.clear()
	_added_ingredients.clear()
	_completed_recipes.clear()
