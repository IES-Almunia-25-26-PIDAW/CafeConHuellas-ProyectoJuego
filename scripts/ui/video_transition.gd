extends CanvasLayer

# VideoTransition: Reproduce un vídeo a pantalla completa y al terminar cambia a la escena de destino

@onready var day_animation: AnimatedSprite2D = %DayAnimation
@onready var day_label: RichTextLabel = %DayLabel

# Estos se asignan desde quien instancia esta escena mediante setup
var _next_scene: String = ""

# Cuántos segundos después de empezar el vídeo aparece el texto
const LABEL_DELAY: float = 0.5
# Cuánto tarda en aparecer y desaparecer
const LABEL_FADE: float = 0.6
# Cuántos segundos se queda visible
const LABEL_SHOW: float = 2.0

# Lee los parámetros de cambio de escena
func _ready() -> void:
	SceneManager.transition_in()
	print("VideoTransition _ready, next_scene: ", SceneManager.pending_video_next_scene)
	print("VideoTransition show_day: ", SceneManager.pending_video_show_day)
	setup(SceneManager.pending_video_next_scene, SceneManager.pending_video_show_day)
	SceneManager.pending_video_next_scene = ""
	SceneManager.pending_video_show_day = true


func setup(next_scene: String, show_day: bool = true) -> void:
	_next_scene = next_scene
	
	# Configurar el label del día
	if show_day:
		day_label.visible = true
		day_label.text = "DÍA %d" % GameState.day
		day_label.modulate.a = 0.0 
		_animate_day_label()
	else:
		day_label.visible = false
	
	# Al terminar la animación cambia de escena
	day_animation.animation_finished.connect(_go_to_next_scene)
	#day_animation.play("day_start")
	# TODO: CAMBIAR AL REAL; por ahora solo esta el de jasmine
	day_animation.play("BORRAR")
	

func _animate_day_label() -> void:
	var tween := create_tween()
	# Espera un momento antes de aparecer
	tween.tween_interval(LABEL_DELAY)
	# Fade in
	tween.tween_property(day_label, "modulate:a", 1.0, LABEL_FADE)
	# Se queda visible
	tween.tween_interval(LABEL_SHOW)
	# Fade out
	tween.tween_property(day_label, "modulate:a", 0.0, LABEL_FADE)

func _go_to_next_scene() -> void:
	SceneManager.transition_out_completed.connect(
		func(): SceneManager.change_scene(_next_scene), CONNECT_ONE_SHOT
	)
	SceneManager.transition_out()
