extends Control

# ActionPopup: Popup que aparece al atender la necesidad de una mascota
# Enseña una animación del protagonista cuidando a la mascota específica realizando esa acción

@onready var popup_panel: PanelContainer = %PopupPanel
@onready var action_sprite: AnimatedSprite2D = %ActionSprite
@onready var action_label: RichTextLabel = %ActionLabel

# Labels posibles dependiendo de la acción que se realice
const ACTION_LABELS: Dictionary = {
	"food": "¡Le has dado de comer!",
	"bath": "¡Le has bañado!",
	"love": "¡Le has dado cariño!"
}

const SHOW_TIME: float = 2.0
const FADE_TIME: float = 0.3


func _ready() -> void:
	visible = false

# Acción
func play_action(need: String) -> void:
	action_label.text = ACTION_LABELS.get(need, "")
	# Aquí se debe asignar la animación del protagonista según la acción
	# TODO: action_sprite.play(need)
	
	# Por ahora uso esta
	action_sprite.play("talk")
	visible = true
	modulate.a = 0.0
	
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, FADE_TIME)
	tween.tween_interval(SHOW_TIME)
	tween.tween_property(self, "modulate:a", 0.0, FADE_TIME)
	tween.tween_callback(func() -> void: visible = false)
