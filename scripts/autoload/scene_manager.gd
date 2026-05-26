## Autoload singleton que gestiona las transiciones entre escenas y el cursor personalizado.
## Crea dinámicamente un ColorRect negro en un CanvasLayer de alta prioridad para las animaciones.
## [br]
## Flujo típico de cambio de escena:
##   SceneManager.transition_out_completed.connect(func(): SceneManager.change_scene("res://..."), CONNECT_ONE_SHOT)
##   SceneManager.transition_out()
extends Node2D


# ===== SEÑALES =====

## Se emite cuando la animación de salida termina y la pantalla está completamente cubierta.
signal transition_out_completed
## Se emite cuando la animación de entrada termina y la pantalla es completamente visible.
signal transition_in_completed


# ===== CONFIGURACIÓN =====

# Duración en segundos de cada transición.
var transition_time: float = 0.5


# ===== ESTADO INTERNO =====

# CanvasLayer de alta prioridad que contiene el rect de transición.
var transition_layer: CanvasLayer
# ColorRect negro que cubre la pantalla durante las transiciones.
var transition_rect: ColorRect


# Escena siguiente pendiente cuando se usa transición con vídeo.
var pending_video_next_scene: String = ""
var pending_video_show_day: bool = true


# ===== INICIALIZACIÓN =====

func _ready() -> void:
	# Configura el cursor personalizado al arrancar el juego.
	_setup_custom_cursor()
	transition_layer = CanvasLayer.new()
	# Layer 100 garantiza que esté por encima de todos los elementos de la escena.
	transition_layer.layer = 100 
	transition_rect = ColorRect.new()
	transition_rect.color = Color.BLACK
	# Anclar a 1.0 hace que el ColorRect ocupe toda la pantalla independientemente de la resolución.
	transition_rect.anchor_right = 1.0
	transition_rect.anchor_bottom = 1.0
	# Se esconde por ahora para mostrarlo solo cuando se haga la animación de transición.
	transition_rect.visible = false
	transition_layer.add_child(transition_rect)
	# Se usa call_deferred() en caso de que el root esté ocupado cargando la escena.
	get_tree().root.add_child.call_deferred(transition_layer)


# ===== PUBLIC API =====

## Inicia la animación de salida (cubre la pantalla).
## Emite transition_out_completed cuando termina.
## [param effect] Efecto a usar: "fade" (por defecto) o "slide".
func transition_out(effect: String = "fade") -> void:
	match effect:
		"fade":
			_fade_out()
		"slide":
			_slide_out()
		_:
			_fade_out()

## Inicia la animación de entrada (descubre la pantalla).
## Emite transition_in_completed cuando termina.
## [param effect] Efecto a usar: "fade" (por defecto) o "slide".
func transition_in(effect: String = "fade") -> void:
	match effect:
		"fade":
			_fade_in()
		"slide":
			_slide_in()
		_:
			_fade_in()

## Cambia a la escena indicada usando el sistema nativo de Godot.
## Llamar siempre desde transition_out_completed para que la pantalla esté cubierta.
func change_scene(path: String) -> void:
	get_tree().change_scene_to_file(path)

# ===== EFECTOS DE TRANSICIÓN =====

func _fade_out() -> void:
	transition_rect.position = Vector2.ZERO
	transition_rect.modulate.a = 0
	transition_rect.z_index = 999
	transition_rect.visible = true
	
	var tween = create_tween()
	tween.tween_property(transition_rect, "modulate:a", 1.0, transition_time)
	tween.tween_callback(func(): transition_out_completed.emit())

func _fade_in() -> void:
	transition_rect.position = Vector2.ZERO
	transition_rect.modulate.a = 1
	transition_rect.z_index = 999
	transition_rect.visible = true
	
	var tween = create_tween()
	tween.tween_property(transition_rect, "modulate:a", 0.0, transition_time)
	tween.tween_callback(func():
		transition_rect.visible = false
		transition_in_completed.emit()
	)

func _slide_out() -> void:
	transition_rect.modulate.a = 1
	transition_rect.z_index = 999
	transition_rect.visible = true
	
	# Agrega la posición inicial a la izquierda de la pantalla.
	var viewport_size = get_viewport_rect().size
	transition_rect.position.x = viewport_size.x
	transition_rect.position.y = 0
	
	var tween = create_tween()
	tween.tween_property(transition_rect, "position:x", 0, transition_time)
	tween.tween_callback(func(): transition_out_completed.emit())

func _slide_in() -> void:
	transition_rect.modulate.a = 1
	transition_rect.z_index = 999
	transition_rect.visible = true
	
	# Agrega la posición inicial a la derecha de la pantalla.
	var viewport_size = get_viewport_rect().size
	transition_rect.position.x = 0
	transition_rect.position.y = 0
	
	var tween = create_tween()
	tween.tween_property(transition_rect, "position:x", -viewport_size.x, transition_time)
	tween.tween_callback(func():
		transition_rect.visible = false
		transition_in_completed.emit()
	)


# ===== CURSOR =====

# Configura el cursor personalizado del juego.
# Vector2(0, 0) indica que el punto del clic está en la esquina superior izquierda del PNG.
func _setup_custom_cursor() -> void:
	var cursor: Texture2D = load("res://assets/images/ui/cursor.png")
	Input.set_custom_mouse_cursor(cursor, Input.CURSOR_ARROW, Vector2(0, 0))
