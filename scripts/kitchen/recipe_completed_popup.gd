extends Control

# RecipeCompletedPopup: Popup que aparece cuando se completa una receta, es una pequeña animación de unos segundos

@onready var popup_panel: PanelContainer = %PopupPanel
@onready var recipe_image: TextureRect = %RecipeImage
@onready var recipe_label: RichTextLabel = %RecipeLabel

# Duración total visible antes del fade out
const SHOW_TIME: float = 1.2
const FADE_TIME: float = 0.3


func setup(display_name: String, image_path: String) -> void:
	recipe_label.text = "Preparado: ¡%s!" % display_name
	
	if image_path != "" and ResourceLoader.exists(image_path):
		recipe_image.texture = load(image_path)
	else:
		recipe_image.visible = false
		
	_animate()

func _animate() -> void:
	modulate.a = 0.0
	popup_panel.position.y += 20
	
	var tween := create_tween()
	# Fade in + subida
	tween.tween_property(self, "modulate:a", 1.0, FADE_TIME)
	tween.parallel().tween_property(popup_panel, "position:y", popup_panel.position.y - 20, FADE_TIME)
	# Espera visible
	tween.tween_interval(SHOW_TIME)
	# Fade out y destrucción
	tween.tween_property(self, "modulate:a", 0.0, FADE_TIME)
	tween.tween_callback(queue_free)
