extends Node2D

@onready var new_game_button: Button = %NewGameButton
@onready var continue_button: Button = %ContinueButton
@onready var settings_button: Button = %SettingsButton
@onready var album_button: Button = %AlbumButton
@onready var exit_button: Button = %ExitButton
@onready var options_window: PanelContainer = %OptionsWindow

# Variable que indica que escena va a cargar
var scene_to_load: String = ""

func _ready():
	SceneManager.transition_in()
	MusicManager.play("Journey")
	
	new_game_button.pressed.connect(_on_new_game_button_pressed)
	# TODO: A tratar luego 
	#continue_button.pressed.connect(_on_continue_button_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	album_button.pressed.connect(_on_album_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)
	
	# Conectamos el sonido de clic a los botones activos del menú principal
	new_game_button.pressed.connect(UiSoundManager.play_menu_click)
	settings_button.pressed.connect(UiSoundManager.play_menu_click)
	album_button.pressed.connect(UiSoundManager.play_menu_click)
	# TODO: Botón de exit comentado porque si queremos que suene tenemos que poner
	# await get_tree().create_timer(0.2).timeout   en _on_exit_button_pressed
	# exit_button.pressed.connect(UiSoundManager.play_menu_click)

	options_window.window_closed.connect(_on_options_closed)
	options_window.hide()
	
	# CONNECT_ONE_SHOT solo lo llama una vez y se desconecta después de emitirse
	SceneManager.transition_out_completed.connect(_on_transition_out_completed, CONNECT_ONE_SHOT)

func _on_new_game_button_pressed():
	MusicManager.stop()
	scene_to_load = "res://scenes/cafe_client_zone.tscn"
	SceneManager.transition_out()


func _on_settings_pressed() -> void:
	options_window.show()

func _on_options_closed() -> void:
	pass  # Se puede añadir logica aquí

func _on_album_button_pressed():
	scene_to_load = "res://scenes/album/album_screen.tscn"
	SceneManager.transition_out()

func _on_transition_out_completed():
	SceneManager.change_scene(scene_to_load)

func _on_exit_button_pressed():
	get_tree().quit()
