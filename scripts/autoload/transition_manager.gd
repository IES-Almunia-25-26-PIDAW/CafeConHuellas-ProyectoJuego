## Autoload singleton que gestiona las transiciones de fade entre escenas.
## Usa un AnimationPlayer para los fades en lugar de Tweens, lo que permite
## editar los tiempos y curvas directamente desde el editor de animaciones.
## [br]
## Uso: TransitionManager.change_scene("res://scenes/mi_escena.tscn")
extends CanvasLayer

# ===== REFERENCIAS A NODOS =====

@onready var color_rect: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer


# ===== PUBLIC API =====

## Cambia a la escena indicada con una transición de fade.
## Hace fade a negro, cambia la escena y hace fade desde negro.
func change_scene(path: String) -> void:
	# Fade a negro.
	animation_player.play("fade_out")
	await animation_player.animation_finished
	# Cambiamos la escena.
	get_tree().change_scene_to_file(path)
	# Fade desde negro.
	animation_player.play("fade_in")
