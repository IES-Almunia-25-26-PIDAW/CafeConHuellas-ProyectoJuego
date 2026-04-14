extends Node2D

@onready var new_game_button: Button = %NewGameButton
@onready var continue_button: Button = %ContinueButton
@onready var album_button: Button = %AlbumButton
@onready var exit_button: Button = %ExitButton

func _ready():
	new_game_button.pressed.connect(_on_new_game_button_pressed)
	# A tratar luego
	#continue_button.pressed.connect(_on_continue_button_pressed)
	#album_button.pressed.connect(_on_album_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)
	
	# CONNECT_ONE_SHOT solo lo llama una vez y se disconecta después de emitirse?
	SceneManager.transition_out_completed.connect(_on_transition_out_completed, CONNECT_ONE_SHOT)

func _on_new_game_button_pressed():
	SceneManager.transition_out()

func _on_transition_out_completed():
	# Por ahora es esta escena pero será la que de inicio al juego
	SceneManager.change_scene("res://scenes/cafe_client_zone.tscn")

func _on_exit_button_pressed():
	get_tree().quit()
