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
	"base": "────── BASE ──────",
	"fruit": "────── FRUTAS ──────",
	"sweetener": "────── ENDULZANTES ──────",
	"flavor": "────── SABORES EXTRA ──────"
}

# Colores del tema kawaii/cozy café
const COLOR_SECTION_BG := Color(0.54, 0.37, 0.37, 1.0)
const COLOR_SECTION_TEXT    := Color(0.98, 0.92, 0.80, 1.0)

# Fondo del botón normal (beige cálido)
const COLOR_BTN_BG          := Color(0.95, 0.75, 0.52, 1.0)
const COLOR_BTN_BORDER      := Color(0.85, 0.60, 0.33, 1.0)
# Fondo del botón hover (beige más claro)
const COLOR_BTN_BG_HOVER    := Color(1.0, 0.84, 0.62, 1.0)
# Fondo del botón para "flavor" (verde menta)
const COLOR_BTN_BG_FLAVOR        := Color(0.55, 0.86, 0.70, 1.0)
const COLOR_BTN_BORDER_FLAVOR    := Color(0.35, 0.70, 0.50, 1.0)
const COLOR_BTN_BG_FLAVOR_HOVER  := Color(0.68, 0.93, 0.78, 1.0)
# Estado desactivado
const COLOR_DISABLED        := Color(0.4, 0.4, 0.4, 0.5)

# Variable para fuente de letra
var _section_font


# ===== ESTILOS HELPERS =====

func _make_btn_style(bg: Color, border: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.border_width_left   = 2
	s.border_width_top    = 2
	s.border_width_right  = 2
	s.border_width_bottom = 2
	s.set_corner_radius_all(10)
	s.content_margin_left   = 4.0
	s.content_margin_top    = 4.0
	s.content_margin_right  = 4.0
	s.content_margin_bottom = 4.0
	return s

func _ready() -> void:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.65, 0.46, 0.46, 0.95)
	panel_style.set_corner_radius_all(16)
	panel_style.border_width_left   = 3
	panel_style.border_width_top    = 3
	panel_style.border_width_right  = 3
	panel_style.border_width_bottom = 3
	panel_style.border_color = Color(0.52, 0.34, 0.34, 1.0)
	$PopupPanel.add_theme_stylebox_override("panel", panel_style)
	
	var title_style := StyleBoxFlat.new()
	title_style.bg_color = Color(0.47, 0.30, 0.30, 1.0)
	title_style.corner_radius_top_left  = 14
	title_style.corner_radius_top_right = 14
	title_style.corner_radius_bottom_left  = 0
	title_style.corner_radius_bottom_right = 0
	title_style.content_margin_left   = 16.0
	title_style.content_margin_right  = 16.0
	title_style.content_margin_top    = 12.0
	title_style.content_margin_bottom = 12.0
	%PopupTitle.get_parent().add_theme_constant_override("separation", 0)
	%PopupTitle.add_theme_stylebox_override("normal", title_style)
	
	if ResourceLoader.exists("res://assets/fonts/Fredoka-Medium.ttf"):
		var font := load("res://assets/fonts/Fredoka-Medium.ttf")
		%PopupTitle.add_theme_font_override("normal_font", font)
		%PopupTitle.add_theme_font_size_override("normal_font_size", 25)
	
# ===== PUBLIC API =====

func setup(title: String, ingredient_ids: Array, already_added: Array = []) -> void:
	popup_title.text = title

	var font := load("res://assets/fonts/Fredoka-Medium.ttf")
	_section_font = font

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

		# --- Cabecera de sección con fondo oscuro ---
		var header := PanelContainer.new()
		var header_style := StyleBoxFlat.new()
		header_style.bg_color = COLOR_SECTION_BG
		header_style.content_margin_left   = 12.0
		header_style.content_margin_right  = 12.0
		header_style.content_margin_top    = 5.0
		header_style.content_margin_bottom = 5.0
		header.add_theme_stylebox_override("panel", header_style)

		var section_label := Label.new()
		section_label.text = TYPE_LABELS.get(type, type.to_upper())
		section_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		section_label.add_theme_font_size_override("font_size", 20)
		section_label.add_theme_color_override("font_color", COLOR_SECTION_TEXT)
		if _section_font:
			section_label.add_theme_font_override("font", _section_font)

		header.add_child(section_label)
		ingredients_container.add_child(header)

		# --- Grid de 3 columnas con margen ---
		var grid := GridContainer.new()
		grid.columns = 3
		grid.add_theme_constant_override("h_separation", 14)
		grid.add_theme_constant_override("v_separation", 14)

		var grid_centered := HBoxContainer.new()
		grid_centered.alignment = BoxContainer.ALIGNMENT_CENTER
		grid_centered.add_child(grid)
		ingredients_container.add_child(grid_centered)
		
		var grid_margin := MarginContainer.new()
		grid_margin.add_theme_constant_override("margin_bottom", 4)
		grid_margin.add_child(grid_centered)
		ingredients_container.add_child(grid_margin)

		var use_green := (type == "flavor")

		# --- Creación de cada botón ---
		for ingredient_id in by_type[type]:
			var ingredient := DataLoader.get_ingredient(ingredient_id)
			var btn := TextureButton.new()
			btn.name = "Btn_" + ingredient_id
			btn.ignore_texture_size = true
			btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
			btn.custom_minimum_size = Vector2(80, 80)
			btn.tooltip_text = ingredient.get("display_name", ingredient_id)

			# Fondo visual según tipo de sección
			if use_green:
				btn.add_theme_stylebox_override("normal",  _make_btn_style(COLOR_BTN_BG_FLAVOR, COLOR_BTN_BORDER_FLAVOR))
				btn.add_theme_stylebox_override("hover",   _make_btn_style(COLOR_BTN_BG_FLAVOR_HOVER, COLOR_BTN_BORDER_FLAVOR))
				btn.add_theme_stylebox_override("pressed", _make_btn_style(Color(0.376, 0.659, 0.502, 1.0), COLOR_BTN_BORDER_FLAVOR))
			else:
				btn.add_theme_stylebox_override("normal",  _make_btn_style(COLOR_BTN_BG, COLOR_BTN_BORDER))
				btn.add_theme_stylebox_override("hover",   _make_btn_style(COLOR_BTN_BG_HOVER, COLOR_BTN_BORDER))
				btn.add_theme_stylebox_override("pressed", _make_btn_style(Color(0.75, 0.565, 0.376, 1.0), COLOR_BTN_BORDER))

			var icon_path: String = ingredient.get("icon", "")
			if icon_path != "" and ResourceLoader.exists(icon_path):
				btn.texture_normal = load(icon_path)

			if already_added.has(ingredient_id):
				btn.disabled = true
				btn.modulate = COLOR_DISABLED
			else:
				btn.mouse_entered.connect(func() -> void:
					if not btn.disabled:
						btn.modulate = Color(1.1, 1.1, 1.1, 1.0)
				)
				btn.mouse_exited.connect(func() -> void:
					if not btn.disabled:
						btn.modulate = Color(1.0, 1.0, 1.0, 1.0)
				)
				btn.pressed.connect(func() -> void:
					_on_ingredient_pressed(ingredient_id)
				)

			grid.add_child(btn)


# ===== INTERACCIONES =====

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if not $PopupPanel.get_rect().has_point(get_local_mouse_position()):
			popup_closed.emit()
			hide()


func _on_ingredient_pressed(ingredient_id: String) -> void:
	ingredient_selected.emit(ingredient_id)
