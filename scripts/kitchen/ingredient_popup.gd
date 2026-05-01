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

@onready var popup_title: RichTextLabel = %PopupTitle
@onready var ingredients_container: VBoxContainer = %IngredientsContainer


# Tipos de ingredientes
const TYPE_ORDER: Array[String] = ["base", "fruit", "sweetener", "flavor"]
const TYPE_LABELS: Dictionary = {
	"base": "— BASE —",
	"fruit": "— FRUTAS —",
	"sweetener": "— ENDULZANTES —",
	"flavor": "— SABORES EXTRA —"
}

# Colores para los estados visuales
const COLOR_NORMAL: Color = Color(1.0, 1.0, 1.0, 1.0)
const COLOR_HOVER: Color = Color(1.2, 1.2, 1.2, 1.0)
const COLOR_DISABLED: Color = Color(0.4, 0.4, 0.4, 0.7)

# Variable para fuente de letra
var _section_font


# ===== PUBLIC API =====

# Configura y muestra el popup con los ingredientes de la receta activa.
# Se llama desde cafe_kitchen_scene.gd cuando el jugador clica la cafetera o la batidora.
func setup(title: String, ingredient_ids: Array, already_added: Array = []) -> void:
	popup_title.text = title
	
	# Fuente de letra para los labels
	# TODO:ana porfi pon la q es tengo sueño (y borra este comment)
	var font := load("res://assets/fonts/DMMono-Medium.ttf")
	# Guardarlo para usarlo en los labels
	_section_font = font

	# Limpiamos la cuadrícula por si el popup se reutiliza
	for child in ingredients_container.get_children():
		child.queue_free()
	
	# Agrupamos ingredientes por tipo
	var by_type: Dictionary = {}
	for ingredient_id in ingredient_ids:
		var ingredient := DataLoader.get_ingredient(ingredient_id)
		if ingredient.is_empty():
			continue
		var type: String = ingredient.get("type", "")
		if not by_type.has(type):
			by_type[type] = []
		by_type[type].append(ingredient_id)
	
	# Creamos una sección por cada tipo en el orden definido
	for type in TYPE_ORDER:
		if not by_type.has(type):
			continue
		
		# Label título
		var section_label := Label.new()
		section_label.text = TYPE_LABELS.get(type, type.to_upper())
		section_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		section_label.add_theme_font_size_override("font_size", 16)
		section_label.add_theme_color_override("font_color", Color(0.95, 0.88, 0.75, 1.0))
		# Fuente de letra del label
		if _section_font:
			section_label.add_theme_font_override("font", _section_font)
		
		# Fondo del label por detrás
		var label_style := StyleBoxFlat.new()
		label_style.bg_color = Color(0.35, 0.25, 0.18, 1.0)
		label_style.set_corner_radius_all(6)
		label_style.content_margin_left = 12
		label_style.content_margin_right = 12
		label_style.content_margin_top = 6
		label_style.content_margin_bottom = 6
		section_label.add_theme_stylebox_override("normal", label_style)
		
		ingredients_container.add_child(section_label)
		
		# Grid de 3 columnas para los botones de la sección
		var grid := GridContainer.new()
		grid.columns = 3
		grid.add_theme_constant_override("h_separation", 12)
		grid.add_theme_constant_override("v_separation", 12)
		
		# Grid centrado
		var grid_centered := HBoxContainer.new()
		grid_centered.alignment = BoxContainer.ALIGNMENT_CENTER
		grid_centered.add_child(grid)
		ingredients_container.add_child(grid_centered)
		
		# Creación de cada botón
		for ingredient_id in by_type[type]:
			var ingredient := DataLoader.get_ingredient(ingredient_id)
			var btn := TextureButton.new()
			btn.name = "Btn_" + ingredient_id
			btn.ignore_texture_size = true
			btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
			btn.custom_minimum_size = Vector2(80, 80)
			btn.tooltip_text = ingredient.get("display_name", ingredient_id)
			
			var icon_path: String = ingredient.get("icon", "")
			if icon_path != "" and ResourceLoader.exists(icon_path):
				btn.texture_normal = load(icon_path)
			
			if already_added.has(ingredient_id):
				btn.disabled = true
				btn.modulate = COLOR_DISABLED
			else:
				btn.mouse_entered.connect(func() -> void:
					if not btn.disabled:
						btn.modulate = COLOR_HOVER
				)
				btn.mouse_exited.connect(func() -> void:
					if not btn.disabled:
						btn.modulate = COLOR_NORMAL
				)
				btn.pressed.connect(func() -> void:
					_on_ingredient_pressed(ingredient_id)
				)
			
			grid.add_child(btn) 


# ===== INTERACCIONES =====

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		# Si el clic no está dentro del PopupPanel, cerramos el popup
		if not $PopupPanel.get_rect().has_point(get_local_mouse_position()):
			popup_closed.emit()
			hide()


func _on_ingredient_pressed(ingredient_id: String) -> void:
	ingredient_selected.emit(ingredient_id)
