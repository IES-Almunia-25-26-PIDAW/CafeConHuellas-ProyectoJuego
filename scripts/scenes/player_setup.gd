extends Control

# PlayerSetup: Pantalla de configuración inicial del jugador
# Rellena el nombre, pronombres y nombre de la cafetería en el GameState antes de comenzar

@onready var name_input: LineEdit = %NameInput
@onready var cafe_input: LineEdit = %CafeInput
@onready var btn_male: Button = %BtnMale
@onready var btn_female: Button = %BtnFemale
@onready var btn_nonbinary: Button = %BtnNonbinary
@onready var btn_start: Button = %StartButton

# Pronombre seleccionado actualmente (0 male, 1 female, 2 nonbinary)
var _selected_pronouns: int = 0


func _ready() -> void:
	SceneManager.transition_in()
	
	# Resetea GameState al entrar en PlayerSetup, asegurando que es una nueva partida
	GameState.reset()
	
	# Valores por defecto visibles en los campos
	name_input.text = GameState.player_name
	cafe_input.text = GameState.cafe_name
	
	# Conexión de los botones
	btn_male.pressed.connect(_on_pronoun_selected.bind(0))
	btn_female.pressed.connect(_on_pronoun_selected.bind(1))
	btn_nonbinary.pressed.connect(_on_pronoun_selected.bind(2))
	btn_start.pressed.connect(_on_start_pressed)
	
	# Marcar el pronombre visualmente
	_update_pronoun_visuals()

# Cambia el pronombre seleccionado
func _on_pronoun_selected(pronoun: int) -> void:
	_selected_pronouns = pronoun
	_update_pronoun_visuals()

# Cambia la visual del botón del pronombre
func _update_pronoun_visuals() -> void:
	btn_male.modulate = Color.WHITE if _selected_pronouns == 0 else Color(0.6, 0.6, 0.6, 1.0)
	btn_female.modulate = Color.WHITE if _selected_pronouns == 1 else Color(0.6, 0.6, 0.6, 1.0)
	btn_nonbinary.modulate = Color.WHITE if _selected_pronouns == 2 else Color(0.6, 0.6, 0.6, 1.0)

# Botón de iniciar el juego, guarda todos los valores en el gamestate y comienza la historia
func _on_start_pressed() -> void:
	# Validaciones para que los input no puedan estar vacíos
	var player_name: String = name_input.text.strip_edges()
	var cafe_name: String = cafe_input.text.strip_edges()
	
	# Escribir los datos en gamestate
	GameState.player_name = player_name if player_name != "" else "Hunter"
	GameState.cafe_name = cafe_name if cafe_name != "" else "PawCafé"
	GameState.player_pronouns = _selected_pronouns
	
	# Empezar en el capítulo indicado y día
	GameState.chapter_id = "story"
	GameState.day = 1
	
	# Parámetros de cambiar escena
	SceneManager.pending_video_next_scene = "res://scenes/cafe_client_zone.tscn"
	SceneManager.pending_video_show_day = true 
	
	# Transición al video de inicio y luego al juego
	SceneManager.transition_out_completed.connect(
		func(): SceneManager.change_scene("res://scenes/video_transition.tscn"), CONNECT_ONE_SHOT)
	SceneManager.transition_out()
