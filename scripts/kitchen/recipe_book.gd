extends Control

# recipe_book.gd: Muestra el recetario con todas las recetas organizadas por categoría.
# El jugador puede navegar entre recetas y consultar ingredientes y preparación.

# ===== REFERENCIAS A NODOS =====

@onready var overlay: ColorRect = %Overlay
@onready var btn_coffee: Button = %BtnCoffee
@onready var btn_smoothie: Button = %BtnSmoothie
@onready var btn_cake: Button = %BtnCake
@onready var btn_cookie: Button = %BtnCookie

@onready var recipe_image: TextureRect = %RecipeImage
@onready var recipe_name_label: RichTextLabel  = %RecipeNameLabel
@onready var recipe_desc_label: RichTextLabel  = %RecipeDescLabel
@onready var recipe_ingredients_label: RichTextLabel  = %RecipeIngredientsLabel
@onready var recipe_how_to_label: RichTextLabel = %RecipeHowToLabel

@onready var btn_prev: Button = %BtnPrev
@onready var btn_next: Button = %BtnNext

# Sonido de la página
@onready var sfx_page_turn: AudioStreamPlayer = %SFXPageTurn


# ===== ESTADO INTERNO =====

# Todas las recetas cargadas del JSON organizadas por categoría
var _recipes_by_category: Dictionary = {}
# Categoría actualmente seleccionada
var _current_category: String = "coffee"
# Índice de la receta que se está mostrando
var _current_index: int = 0


# ===== INICIALIZACIÓN =====

func _ready() -> void:
	# Conectamos las pestañas de categoría
	btn_coffee.pressed.connect(_on_category_pressed.bind("coffee"))
	btn_smoothie.pressed.connect(_on_category_pressed.bind("smoothie"))
	btn_cake.pressed.connect(_on_category_pressed.bind("pastry_cake"))
	btn_cookie.pressed.connect(_on_category_pressed.bind("pastry_cookie"))

	# Conectamos la navegación
	btn_prev.pressed.connect(_on_prev_pressed)
	btn_next.pressed.connect(_on_next_pressed)

	# Conectamos el cierre al clicar el overlay
	overlay.gui_input.connect(_on_overlay_clicked)

	# Cargamos y organizamos todas las recetas
	_load_recipes()

	# Mostramos la primera categoría por defecto
	_on_category_pressed("coffee", false)


# ===== CARGA DE DATOS =====

# Carga todas las recetas del DataLoader y las organiza por categoría
func _load_recipes() -> void:
	var all_recipes := DataLoader.get_all_recipes()

	_recipes_by_category = {
		"coffee": [],
		"smoothie": [],
		"pastry_cake": [],
		"pastry_cookie": []
	}

	for recipe_id in all_recipes:
		var recipe: Dictionary = all_recipes[recipe_id]
		var category: String = recipe.get("category", "")

		if category == "coffee":
			_recipes_by_category["coffee"].append(recipe)
		elif category == "smoothie":
			_recipes_by_category["smoothie"].append(recipe)
		elif category == "pastry":
			# Separamos tartas y galletas por el ID
			if recipe_id.begins_with("cake"):
				_recipes_by_category["pastry_cake"].append(recipe)
			elif recipe_id.begins_with("cookie"):
				_recipes_by_category["pastry_cookie"].append(recipe)


# ===== UI =====

# Muestra la receta del índice actual en la categoría actual
func _show_current_recipe() -> void:
	var recipes: Array = _recipes_by_category[_current_category]
	if recipes.is_empty():
		return

	var recipe: Dictionary = recipes[_current_index]

	# Imagen de la receta
	var image_path: String = recipe.get("recipe_image", "")
	if image_path != "" and ResourceLoader.exists(image_path):
		recipe_image.texture = load(image_path)
	else:
		recipe_image.texture = null

	# Nombre en negrita con BBCode
	recipe_name_label.text = "[b]" + recipe.get("display_name", "") + "[/b]"
	
	# Descripción
	recipe_desc_label.text = recipe.get("description", "")

	# Ingredientes, el título ya está en el nodo RecipeIngredientsTitleLabel del .tscn
	var ingredient_names: Array = []
	for ingredient_id in recipe.get("ingredients", []):
		var ingredient := DataLoader.get_ingredient(ingredient_id)
		if not ingredient.is_empty():
			# Añadimos bullet point delante de cada ingrediente
			ingredient_names.append("• " + ingredient["display_name"])
		else:
			ingredient_names.append("• " + ingredient_id)
	recipe_ingredients_label.text = "\n".join(ingredient_names)

	# Preparación, el título ya está en el nodo RecipeHowToTitleLabel del .tscn
	recipe_how_to_label.text = recipe.get("how_to_make", "")


	# Actualizamos los botones de navegación
	btn_prev.disabled = _current_index == 0
	btn_next.disabled = _current_index == recipes.size() - 1


# ===== INTERACCIONES =====

# Actualiza visualmente qué pestaña está activa
func _update_tab_visuals(active_category: String) -> void:
	btn_coffee.modulate = Color.WHITE if active_category == "coffee" else Color(0.6, 0.6, 0.6, 1.0)
	btn_smoothie.modulate = Color.WHITE if active_category == "smoothie" else Color(0.6, 0.6, 0.6, 1.0)
	btn_cake.modulate = Color.WHITE if active_category == "pastry_cake" else Color(0.6, 0.6, 0.6, 1.0)
	btn_cookie.modulate = Color.WHITE if active_category == "pastry_cookie" else Color(0.6, 0.6, 0.6, 1.0)
	
# Cambia la categoría activa y resetea el índice
func _on_category_pressed(category: String, play_sound: bool = true) -> void:
	_current_category = category
	_current_index = 0
	_update_tab_visuals(category)
	_show_current_recipe()
	if play_sound:
		sfx_page_turn.play()

func _on_prev_pressed() -> void:
	if _current_index > 0:
		_current_index -= 1
		_show_current_recipe()
		sfx_page_turn.play()

func _on_next_pressed() -> void:
	var recipes: Array = _recipes_by_category[_current_category]
	if _current_index < recipes.size() - 1:
		_current_index += 1
		_show_current_recipe()
		sfx_page_turn.play()

# Cierra el recetario al clicar el overlay
func _on_overlay_clicked(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		hide()
