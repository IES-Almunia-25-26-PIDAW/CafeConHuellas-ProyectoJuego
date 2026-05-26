## Popup que aparece brevemente al completar una receta del pedido.
## Muestra la imagen y el nombre de la receta con una animación de fade y subida.
## Se destruye automáticamente al terminar la animación.
extends Control


# ===== REFERENCIAS A NODOS =====

@onready var popup_panel: PanelContainer = %PopupPanel
@onready var recipe_image: TextureRect = %RecipeImage
@onready var recipe_label: RichTextLabel = %RecipeLabel


# ===== CONSTANTES =====

# Duración total visible antes del fade out.
const SHOW_TIME: float = 1.2
const FADE_TIME: float = 0.3


# ===== PUBLIC API =====

## Configura el popup con el nombre e imagen de la receta completada y lanza la animación.
## [param display_name] Nombre de la receta a mostrar.
## [param image_path] Ruta a la imagen de la receta. Si no existe, se oculta el nodo.
func setup(display_name: String, image_path: String) -> void:
	recipe_label.text = "Preparado: ¡%s!" % display_name
	
	if image_path != "" and ResourceLoader.exists(image_path):
		recipe_image.texture = load(image_path)
	else:
		recipe_image.visible = false
		
	_animate()


# ===== LÓGICA INTERNA =====

# Anima el popup: fade in con subida, espera visible, fade out y se destruye.
func _animate() -> void:
	modulate.a = 0.0
	popup_panel.position.y += 20
	
	var tween := create_tween()
	# Fade in + subida.
	tween.tween_property(self, "modulate:a", 1.0, FADE_TIME)
	tween.parallel().tween_property(popup_panel, "position:y", popup_panel.position.y - 20, FADE_TIME)
	# Espera visible.
	tween.tween_interval(SHOW_TIME)
	# Fade out y destrucción.
	tween.tween_property(self, "modulate:a", 0.0, FADE_TIME)
	# queue_free elimina el nodo al terminar para no acumular instancias.
	tween.tween_callback(queue_free)
