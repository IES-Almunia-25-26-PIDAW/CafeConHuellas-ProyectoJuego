class_name KitchenItem
extends TextureButton

# KitchenItem: Es un item de la escena de la cocina, reutilizable para cualquier producto


# Señal que emite este item cuando se hace click, pasando el recipe_id
signal item_clicked(recipe_id: String)

# ID de la receta que representa este item, se asigna en el inspector
@export var recipe_id: String = ""


func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if recipe_id == "":
		push_warning("KitchenItem: item presionado sin recipe_id asignado.")
		return
	item_clicked.emit(recipe_id)
