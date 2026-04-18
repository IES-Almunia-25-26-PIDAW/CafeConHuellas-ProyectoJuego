extends Control

# Cuando el texto termina de reproducirse, la animación de hablar también
signal text_animation_done
# Señal que indica la elección escogida
signal choice_selected

# Precargar la elección del jugador
const ChoiceButtonScene = preload("res://scenes/player_choice.tscn")

@onready var dialog_line = %DialogLine
@onready var speaker_name = %SpeakerName
@onready var choice_list = %ChoiceList
@onready var voice_player = $VoicePlayer # Nodo de audio que reproduce la voz del personaje

const ANIMATION_SPEED : int = 30

# Caracteres que no disparan sonido de voz (espacios, puntuación)
const SILENT_CHARS: String = " .,!?-\n"

var animate_text : bool = false
var current_visible_characters : int = 0
var current_character_details : Dictionary
# Stream de audio de la voz del personaje actual
var current_voice: AudioStream = null
# Pitch (tono) de la voz del personaje actual
var current_pitch: float = 1.0
# Bus de audio del personaje actual
var current_bus: String = "Voices"

# Called when the node enters the scene tree for the first time.
func _ready():
	# Resetea lo que se muestra en pantalla
	choice_list.hide()
	dialog_line.text = ""
	speaker_name.text = ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if animate_text:
		if dialog_line.visible_ratio < 1:
			dialog_line.visible_ratio += (1.0/dialog_line.text.length()) * (ANIMATION_SPEED * delta)
			if dialog_line.visible_characters > current_visible_characters:
				current_visible_characters = dialog_line.visible_characters
				var current_char = dialog_line.text[current_visible_characters - 1]
				# Intenta reproducir el sonido de voz para el carácter actual
				_try_play_voice(current_char)
				if current_visible_characters < dialog_line.text.length():
						var next_char = dialog_line.text[current_visible_characters]
		else:
			animate_text = false
			text_animation_done.emit()

func change_line(character_name: Character.Name, line: String):
	current_character_details = Character.CHARACTER_DETAILS[character_name]
	speaker_name.text = current_character_details["name"]
	# Carga la voz del personaje si tiene una definida
	# Si no tiene voz (como Hunter), current_voice será null y no sonará nada
	var voice_path: String = current_character_details.get("voice", "")
	if voice_path != "":
		current_voice = load(voice_path)
	else:
		current_voice = null
	# Carga el pitch del personaje, si no tiene usa 1.0 como valor por defecto
	current_pitch = current_character_details.get("voice_pitch", 1.0)
	# Cambia el bus del VoicePlayer al del personaje actual
	# Si no tiene bus definido usa "Voices" por defecto
	current_bus = current_character_details.get("voice_bus", "Voices")
	voice_player.bus = current_bus
	current_visible_characters = 0
	dialog_line.text = line
	dialog_line.visible_characters = 0
	animate_text = true

func display_choices(choices: Array):
	# Limpiar las elecciones existentes
	for child in choice_list.get_children():
		child.queue_free()
		
	# Creamos un nuevo botón por cada elección
	for choice in choices:
		var choice_button = ChoiceButtonScene.instantiate()
		choice_button.text = choice["text"]
		# Agregamos la señal al botón
		choice_button.pressed.connect(_on_choice_button_pressed.bind(choice["goto"]))
		# Añadimos el botón al ChoiceList
		choice_list.add_child(choice_button)
	
	# Muestra la lista de elecciones
	choice_list.show()

func skip_text_animation():
	dialog_line.visible_ratio = 1
	animate_text = false  # Para el proceso de animación inmediatamente
	voice_player.stop()   # Silencia la voz al saltar el texto

# Reproduce el sonido de voz del personaje actual carácter a carácter
# Añade una pequeña variación aleatoria al pitch para que no suene robótico
func _try_play_voice(current_char: String) -> void:
	# No suena en espacios ni puntuación
	if SILENT_CHARS.contains(current_char):
		return
	# Si el personaje no tiene voz asignada no hace nada
	if current_voice == null:
		return
	voice_player.stream = current_voice
	# Variación aleatoria de +-0.04 para sonar más natural
	voice_player.pitch_scale = current_pitch + randf_range(-0.04, 0.04)
	voice_player.play()
	
func _on_choice_button_pressed(anchor: String):
	choice_selected.emit(anchor)
	choice_list.hide()
