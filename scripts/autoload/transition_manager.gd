extends CanvasLayer

# TransitionManager: Gestiona las transiciones entre escenas con fade.
# Es un autoload singleton disponible en cualquier parte del juego.

# ===== REFERENCIAS A NODOS =====

@onready var color_rect: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# ===== PUBLIC API =====

# Cambia de escena con una transición de fade
# Se llama desde cualquier parte del juego en vez de change_scene_to_file directamente
func change_scene(path: String) -> void:
	# Fade a negro
	animation_player.play("fade_out")
	await animation_player.animation_finished
	# Cambiamos la escena
	get_tree().change_scene_to_file(path)
	# Fade desde negro
	animation_player.play("fade_in")
