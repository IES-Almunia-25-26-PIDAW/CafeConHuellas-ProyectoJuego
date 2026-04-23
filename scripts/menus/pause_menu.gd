extends CanvasLayer

# PauseMenu: Menú de pausa que dispone de las opciones para guardar, cargar, opciones y volver al menú principal

signal menu_closed

@onready var save_btn: Button = %SaveButton
@onready var load_btn: Button = %LoadButton
@onready var options_btn: Button = %OptionsButton
@onready var quit_btn: Button = %QuitButton
@onready var options_window: PanelContainer = %OptionsWindow
@onready var confirm_window: PanelContainer = %ConfirmWindow
@onready var backdrop: Control = %BackdropControl

# Texto que verá el jugador cuando quiera volver al menú en ConfirmWindow
const QUIT_MESSAGE: String = "Volverás al menú principal.\nTodo progreso no guardado se perderá.\n¿Continuar?"


func _ready() -> void:
	# El menú funciona mientras el árbol está pausado
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	# TODO: Guardar y Cargar deshabilitados -> aun no esta hecha la logica
	save_btn.disabled = true
	load_btn.disabled = true
	
	options_btn.pressed.connect(_on_options_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	backdrop.gui_input.connect(_on_backdrop_input)
	
	options_window.window_closed.connect(_on_options_closed)
	confirm_window.confirmed.connect(_on_quit_confirmed)

	# Ventanas ocultas por defecto
	options_window.hide()
	confirm_window.hide()
	
	# Conectamos el sonido de clic a los botones activos del menú de pausa
	# save_btn y load_btn se descomentarán cuando esté implementada su lógica
	# save_btn.pressed.connect(UiSoundManager.play_menu_click)
	# load_btn.pressed.connect(UiSoundManager.play_menu_click)
	options_btn.pressed.connect(UiSoundManager.play_menu_click)
	quit_btn.pressed.connect(UiSoundManager.play_menu_click)

# Backdrop:
func _on_backdrop_input(event: InputEvent) -> void:
	# Cierra el menú si el jugador hace clic fuera del panel solo si no hay subventanas abiertas
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not options_window.visible and not confirm_window.visible:
			close()

# Options:
func _on_options_pressed() -> void:
	confirm_window.hide() # Por si estaba abierto para que no se solapen
	options_window.show()

func _on_options_closed() -> void:
	pass  # Se puede agregar lógica aquí

# Quit:
func _on_quit_pressed() -> void:
	options_window.hide()  # Por si estaba abierto para que no se solapen
	confirm_window.setup(QUIT_MESSAGE) # Agrega el mensaje al label
	confirm_window.show()

func _on_quit_confirmed() -> void:
	get_tree().paused = false  # reanudar antes de cambiar de escena
	# Limpiar el menú y música antes de cambiar la escena
	options_window.hide()
	confirm_window.hide()
	hide()
	MusicManager.stop()
	# Mismo patrón que TitleScreen y AlbumScreen
	SceneManager.transition_out_completed.connect(_on_transition_out_completed, CONNECT_ONE_SHOT)
	SceneManager.transition_out()

func _on_transition_out_completed() -> void:
	SceneManager.change_scene("res://scenes/title_screen.tscn")

# Función que cierra el menú de pause completo (PauseButton)
func close() -> void:
	options_window.hide()
	confirm_window.hide()
	hide()
	menu_closed.emit()
