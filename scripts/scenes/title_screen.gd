extends Node2D

@onready var new_game_button: Button = %NewGameButton
@onready var continue_button: Button = %ContinueButton
@onready var album_button: Button = %AlbumButton
@onready var exit_button: Button = %ExitButton

# Variable que indica que escena va a cargar
var scene_to_load: String = ""

func _ready():
	SceneManager.transition_in()
	MusicManager.play("pista_test2") # TODO: Cambiar a una canción "menu_theme" o algo asi
	
	new_game_button.pressed.connect(_on_new_game_button_pressed)
	# TODO: A tratar luego 
	#continue_button.pressed.connect(_on_continue_button_pressed)
	album_button.pressed.connect(_on_album_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)
	
	# Conectamos el sonido de clic a los botones activos del menú principal
	new_game_button.pressed.connect(UiSoundManager.play_menu_click)
	album_button.pressed.connect(UiSoundManager.play_menu_click)
	# TODO: Botón de exit comentado porque si queremos que suene tenemos que poner
	# await get_tree().create_timer(0.2).timeout   en _on_exit_button_pressed
	# exit_button.pressed.connect(UiSoundManager.play_menu_click)

	
	# CONNECT_ONE_SHOT solo lo llama una vez y se desconecta después de emitirse
	SceneManager.transition_out_completed.connect(_on_transition_out_completed, CONNECT_ONE_SHOT)

func _on_new_game_button_pressed():
	MusicManager.stop()
	scene_to_load = "res://scenes/cafe_client_zone.tscn"
	SceneManager.transition_out()

func _on_album_button_pressed():
	scene_to_load = "res://scenes/album/album_screen.tscn"
	SceneManager.transition_out()

func _on_transition_out_completed():
	SceneManager.change_scene(scene_to_load)

func _on_exit_button_pressed():
	get_tree().quit()
