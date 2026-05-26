## Menú de pausa con opciones de guardar, cargar, ajustes y volver al menú principal.
## Se instancia dinámicamente desde PauseButton y persiste mientras el juego está pausado.
extends CanvasLayer


# ===== SEÑALES =====

## Se emite cuando el menú se cierra completamente.
signal menu_closed


# ===== REFERENCIAS A NODOS =====

@onready var save_btn: Button = %SaveButton
@onready var load_btn: Button = %LoadButton
@onready var options_btn: Button = %OptionsButton
@onready var quit_btn: Button = %QuitButton
@onready var options_window: Control = %OptionsWindow
@onready var confirm_window: PanelContainer = %ConfirmWindow
@onready var slot_picker: Control = %SlotPickerWindow
@onready var save_success_window: Control = %SaveSuccessWindow
@onready var backdrop: Control = %BackdropControl


# ===== CONSTANTES =====

# Mensaje que ve el jugador al intentar volver al menú principal.
const QUIT_MESSAGE: String = "Volverás al menú principal.\nTodo progreso no guardado se perderá.\n¿Continuar?"


# ===== CICLO DE VIDA =====

func _ready() -> void:
	# process_mode WHEN_PAUSED permite que el menú funcione con el árbol pausado.
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	save_btn.pressed.connect(_on_save_pressed)
	load_btn.pressed.connect(_on_load_pressed)
	options_btn.pressed.connect(_on_options_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	backdrop.gui_input.connect(_on_backdrop_input)
	
	options_window.window_closed.connect(_on_options_closed)
	confirm_window.confirmed.connect(_on_quit_confirmed)
	
	slot_picker.slot_picked.connect(_on_slot_picked)
	slot_picker.window_closed.connect(func() -> void: slot_picker.hide())
	
	save_success_window.closed.connect(_on_save_success_continue)
	
	# Ventanas ocultas por defecto.
	options_window.hide()
	confirm_window.hide()
	slot_picker.hide()
	save_success_window.hide()
	
	# Conectamos el sonido de clic a los botones activos del menú de pausa.
	save_btn.pressed.connect(UiSoundManager.play_menu_click)
	load_btn.pressed.connect(UiSoundManager.play_menu_click)
	options_btn.pressed.connect(UiSoundManager.play_menu_click)
	quit_btn.pressed.connect(UiSoundManager.play_menu_click)


# ===== PUBLIC API =====

## Cierra todas las subventanas, oculta el menú y emite menu_closed.
func close() -> void:
	options_window.hide()
	confirm_window.hide()
	slot_picker.hide()
	save_success_window.hide()
	hide()
	menu_closed.emit()



# ===== INTERACCIONES =====

# Cierra el menú al hacer clic en el backdrop, solo si no hay subventanas abiertas.
func _on_backdrop_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not options_window.visible and not confirm_window.visible and not slot_picker.visible and not save_success_window.visible:
			close()

# Abre el slot picker en modo guardar.
func _on_save_pressed() -> void:
	options_window.hide()
	confirm_window.hide()
	slot_picker.open("save")

# Abre el slot picker en modo cargar.
func _on_load_pressed() -> void:
	options_window.hide()
	confirm_window.hide()
	slot_picker.open("load")

# Procesa la selección de slot: guarda o carga según el modo.
func _on_slot_picked(slot: int, mode: String) -> void:
	if mode == "save":
		# Guarda la escena actual para saber donde cargar.
		GameState.current_scene = get_tree().current_scene.scene_file_path
		SaveManager.save_game(slot)
		slot_picker.hide()
		save_success_window.show_success()
	elif mode == "load":
		get_tree().paused = false
		SaveManager.load_game(slot)
		MusicManager.stop()
		
		# Ocultamos el menú antes de la transición.
		slot_picker.hide()
		options_window.hide()
		confirm_window.hide()
		hide()
		
		# Ir a la escena guardada.
		SceneManager.transition_out_completed.connect(
			func(): SceneManager.change_scene(GameState.current_scene), CONNECT_ONE_SHOT)
		SceneManager.transition_out()

# Cierra el menú tras confirmar el guardado exitoso.
func _on_save_success_continue() -> void:
	close() 

# Abre las opciones ocultando otras subventanas para evitar solapamiento.
func _on_options_pressed() -> void:
	confirm_window.hide() # Por si estaba abierto para que no se solapen
	slot_picker.hide()
	options_window.show()

# Reservado para lógica futura al cerrar las opciones.
func _on_options_closed() -> void:
	pass  # Se puede agregar lógica aquí

# Abre la ventana de confirmación para volver al menú principal.
func _on_quit_pressed() -> void:
	options_window.hide()  # Por si estaba abierto para que no se solapen
	slot_picker.hide()
	confirm_window.setup(QUIT_MESSAGE) # Agrega el mensaje al label
	confirm_window.show()

# Reanuda el juego, limpia el menú y hace la transición al título.
func _on_quit_confirmed() -> void:
	# reanudar antes de cambiar de escena
	get_tree().paused = false  
	# Limpiar el menú y música antes de cambiar la escena
	options_window.hide()
	confirm_window.hide()
	hide()
	MusicManager.stop()
	# Mismo patrón que TitleScreen y AlbumScreen
	SceneManager.transition_out_completed.connect(_on_transition_out_completed, CONNECT_ONE_SHOT)
	SceneManager.transition_out()
	
# Cambia a la escena del título tras completar la transición de salida.
func _on_transition_out_completed() -> void:
	SceneManager.change_scene("res://scenes/title_screen.tscn")
