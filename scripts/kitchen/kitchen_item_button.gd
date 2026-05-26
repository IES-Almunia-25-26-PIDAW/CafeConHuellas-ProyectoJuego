## Item interactivo de la escena de cocina, reutilizable para cualquier producto.
## Al hacer clic emite item_clicked con su recipe_id para que la escena lo procese.
class_name KitchenItem
extends TextureButton


# ===== SEÑALES =====

## Se emite cuando el jugador hace clic en el item.
signal item_clicked(recipe_id: String)


# ===== VARIABLES =====

## ID de la receta que representa este item. Debe asignarse en el inspector.
@export var recipe_id: String = ""


# ===== CICLO DE VIDA =====

func _ready() -> void:
	pressed.connect(_on_pressed)


# ===== INTERACCIONES =====

# Emite item_clicked con el recipe_id si está asignado.
func _on_pressed() -> void:
	if recipe_id == "":
		push_warning("KitchenItem: item presionado sin recipe_id asignado.")
		return
	item_clicked.emit(recipe_id)
