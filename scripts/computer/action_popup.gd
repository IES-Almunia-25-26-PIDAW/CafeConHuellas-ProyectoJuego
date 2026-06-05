## Popup que aparece al atender la necesidad de una mascota.
## Muestra una animación del protagonista realizando la acción y un mensaje descriptivo.
## Se muestra con fade, espera SHOW_TIME segundos y desaparece con fade.
extends Control


# ===== REFERENCIAS A NODOS =====

@onready var popup_panel: PanelContainer = %PopupPanel
@onready var action_sprite: AnimatedSprite2D = %ActionSprite
@onready var action_label: RichTextLabel = %ActionLabel


# ===== CONSTANTES =====

# Labels posibles dependiendo de la acción que se realice.
const ACTION_LABELS: Dictionary = {
	"food": "¡Le has dado de comer!",
	"bath": "¡Le has bañado!",
	"love": "¡Le has dado cariño!"
}

const SHOW_TIME: float = 2.0
const FADE_TIME: float = 0.3


# ===== VARIABLES =====
var _current_pet_id: String = ""


# ===== CICLO DE VIDA =====

func _ready() -> void:
	visible = false


# ===== PUBLIC API =====

## Cambia las animaciones para la mascota indicada.
func set_pet(animal_id: String) -> void:
	if animal_id == _current_pet_id:
		return
	
	_current_pet_id = animal_id
	
	var frames_path := "res://assets/sprites/animals/%s/%s_sprites.tres" % [animal_id, animal_id]
	
	if ResourceLoader.exists(frames_path):
		action_sprite.sprite_frames = load(frames_path)
	else:
		push_warning("No existen SpriteFrames para %s" % animal_id)


## Muestra el popup con la animación y mensaje correspondientes a la necesidad atendida.
## [param need] Tipo de necesidad: "food", "bath" o "love".
func play_action(need: String) -> void:
	action_label.text = ACTION_LABELS.get(need, "")
	
	if action_sprite.sprite_frames and action_sprite.sprite_frames.has_animation(need):
		action_sprite.play(need)
	
	visible = true
	modulate.a = 0.0
	
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, FADE_TIME)
	tween.tween_interval(SHOW_TIME)
	tween.tween_property(self, "modulate:a", 0.0, FADE_TIME)
	tween.tween_callback(func() -> void: visible = false)
