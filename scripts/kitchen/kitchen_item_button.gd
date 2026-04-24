class_name KitchenItem
extends TextureButton

# KitchenItem: Es un item de la escena de la cocina, reutilizable para cualquier producto


# Señal que emite este item cuando se hace click, pasando el recipe_id
signal item_clicked(recipe_id: String)

# ID de la receta que representa este item, se asigna en el inspector
@export var recipe_id: String = ""

# TODO: borrar esto jejsjs
# Texturas de los estados visuales — asignar en el inspector de cada instancia
# texture_normal ya existe en TextureButton como propiedad nativa,
# aquí solo declaramos las adicionales para documentar qué se espera:
# texture_normal  → apariencia por defecto   (propiedad nativa de TextureButton)
# texture_hover   → apariencia al pasar el ratón (propiedad nativa de TextureButton)
# texture_pressed → apariencia al hacer clic    (propiedad nativa de TextureButton)
# texture_disabled → apariencia desactivado     (propiedad nativa de TextureButton)

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if recipe_id == "":
		push_warning("KitchenItem: item presionado sin recipe_id asignado.")
		return
	item_clicked.emit(recipe_id)
