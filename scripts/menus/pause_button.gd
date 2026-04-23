extends Node

# PauseButton: Abre y cierra el menú de PauseMenu
# Se encuentra en las escenas de juego y siempre es visible durante el gameplay

@export var pause_menu_scene: PackedScene

# Instancia del menú
var _pause_menu_instance = null
# Estado de si está abierto o no
var _is_open: bool = false

# Referencia al nodo visual
@export var button_visual: Control

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		# Comprueba si el click está dentro del área visual del botón
		if button_visual and button_visual.get_global_rect().has_point(event.position):
			get_viewport().set_input_as_handled()
			if _is_open:
				_close_menu()
			else:
				_open_menu()

func _open_menu() -> void:
	if _pause_menu_instance == null:
		_pause_menu_instance = pause_menu_scene.instantiate()
		get_tree().root.add_child(_pause_menu_instance)
		_pause_menu_instance.menu_closed.connect(_on_menu_closed)
	_pause_menu_instance.show()
	_is_open = true
	get_tree().paused = true
	
	# Sonido al abrir el menú de pausa
	UiSoundManager.play_menu_click()

func _close_menu() -> void:
	if _pause_menu_instance:
		_pause_menu_instance.close()
		
	# Sonido al cerrar el menú de pausa
	# Lo llamamos directamente desde código por eso le ponemos ()
	UiSoundManager.play_menu_click()

func _on_menu_closed() -> void:
	_is_open = false
	get_tree().paused = false
