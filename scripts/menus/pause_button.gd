## Botón que abre y cierra el menú de pausa durante el gameplay.
## Instancia el PauseMenu dinámicamente en el root para que esté por encima de todo.
## Usa _input() en lugar de un Button nativo para tener control total sobre el área de clic.
extends Node


# ===== VARIABLES =====

# Escena del menú de pausa a instanciar.
@export var pause_menu_scene: PackedScene
# Nodo visual que define el área de clic del botón.
@export var button_visual: Control

# Instancia del menú.
var _pause_menu_instance = null
# Estado de si está abierto o no.
var _is_open: bool = false


# ===== CICLO DE VIDA =====

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		# Comprueba si el click está dentro del área visual del botón.
		if button_visual and button_visual.get_global_rect().has_point(event.position):
			get_viewport().set_input_as_handled()
			if _is_open:
				_close_menu()
			else:
				_open_menu()


# ===== LÓGICA INTERNA =====

# Instancia el menú si no existe, lo muestra y pausa el juego.
func _open_menu() -> void:
	if _pause_menu_instance == null:
		_pause_menu_instance = pause_menu_scene.instantiate()
		get_tree().root.add_child(_pause_menu_instance)
		_pause_menu_instance.menu_closed.connect(_on_menu_closed)
	_pause_menu_instance.show()
	_is_open = true
	get_tree().paused = true
	
	# Sonido al abrir el menú de pausa.
	UiSoundManager.play_menu_click()

# Cierra el menú llamando a su método close() para que emita menu_closed correctamente.
func _close_menu() -> void:
	if _pause_menu_instance:
		_pause_menu_instance.close()
		
	# Sonido al cerrar el menú de pausa.
	# Lo llamamos directamente desde código por eso le ponemos ().
	UiSoundManager.play_menu_click()

# Se llama cuando el menú emite menu_closed y reanuda el juego.
func _on_menu_closed() -> void:
	_is_open = false
	get_tree().paused = false
