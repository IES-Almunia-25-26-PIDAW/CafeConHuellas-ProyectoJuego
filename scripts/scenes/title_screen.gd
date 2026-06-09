## Pantalla principal del juego con opciones de nueva partida, continuar, ajustes, álbum y salir.
## Desactiva el botón de continuar si no hay ningún guardado disponible.
extends Node2D

# ===== REFERENCIAS A NODOS =====

@onready var new_game_button: Button = %NewGameButton
@onready var continue_button: Button = %ContinueButton
@onready var settings_button: Button = %SettingsButton
@onready var album_button: Button = %AlbumButton
@onready var exit_button: Button = %ExitButton
@onready var options_window: Control = %OptionsWindow
@onready var slot_picker: Control = %SlotPickerWindow


# ===== ESTADO INTERNO =====

# Escena a cargar al completar la transición de salida.
var scene_to_load: String = ""


# ===== CICLO DE VIDA =====

func _ready():
	SceneManager.transition_in()
	MusicManager.play("Journey")
	
	new_game_button.pressed.connect(_on_new_game_button_pressed)
	continue_button.pressed.connect(_on_continue_button_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	album_button.pressed.connect(_on_album_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)
	
	# Conectamos el sonido de clic a los botones activos del menú principal.
	new_game_button.pressed.connect(UiSoundManager.play_menu_click)
	continue_button.pressed.connect(UiSoundManager.play_menu_click)
	settings_button.pressed.connect(UiSoundManager.play_menu_click)
	album_button.pressed.connect(UiSoundManager.play_menu_click)
	# El botón de salir no tiene sonido porque el juego cierra antes de que se reproduzca.
	# Si se quiere añadir, usar:
	# await get_tree().create_timer(0.2).timeout   en _on_exit_button_pressed
	# exit_button.pressed.connect(UiSoundManager.play_menu_click)
	
	# Ventana Options.
	options_window.window_closed.connect(_on_options_closed)
	options_window.hide()
	
	# Ventana SlotPicket si hay alguna save.
	slot_picker.slot_picked.connect(_on_continue_slot_picked)
	slot_picker.window_closed.connect(func() -> void: slot_picker.hide())
	slot_picker.hide()
	
	# Deshabilitar continuar si no hay ninguna save.
	var has_any_save: bool = false
	for i in SaveManager.MAX_SLOTS:
		if SaveManager.has_save(i):
			has_any_save = true
			break
	continue_button.disabled = not has_any_save
	
	# CONNECT_ONE_SHOT solo lo llama una vez y se desconecta después de emitirse.
	SceneManager.transition_out_completed.connect(_on_transition_out_completed, CONNECT_ONE_SHOT)


# ===== INTERACCIONES =====

# Detiene la música y carga la pantalla de configuración de personaje.
func _on_new_game_button_pressed() -> void:
	MusicManager.stop()
	scene_to_load = "res://scenes/player_setup.tscn"
	SceneManager.transition_out()
	
# Abre el slot picker en modo cargar.
func _on_continue_button_pressed() -> void:
	slot_picker.open("load")

# Carga la partida de la slot seleccionada y va a la escena guardada.
func _on_continue_slot_picked(slot: int, _mode: String) -> void:
	var success: bool = SaveManager.load_game(slot)
	if not success:
		return
	MusicManager.stop()
	scene_to_load = GameState.current_scene
	SceneManager.transition_out()


# Abre la ventana de opciones de audio.
func _on_settings_pressed() -> void:
	options_window.show()

# Reservado para lógica futura al cerrar las opciones.
func _on_options_closed() -> void:
	pass  # Se puede añadir logica aquí

# Carga la pantalla del álbum de ilustraciones.
func _on_album_button_pressed() -> void:
	scene_to_load = "res://scenes/album/album_screen.tscn"
	SceneManager.transition_out()

# Cambia a la escena almacenada en scene_to_load.
func _on_transition_out_completed() -> void:
	print_debug("scene_to_load =", scene_to_load)
	SceneManager.change_scene(scene_to_load)

# Cierra el juego.
func _on_exit_button_pressed() -> void:
	get_tree().quit()
