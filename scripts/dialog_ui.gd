extends Control

# Cuando el texto termina de reproducirse, la animación de hablar también
signal text_animation_done

# Precargar la elección del jugador
const ChoiceButtonScene = preload("res://scenes/player_choice.tscn")

@onready var dialog_line = %DialogLine
@onready var speaker_name = %SpeakerName
@onready var choice_list = %ChoiceList

const ANIMATION_SPEED : int = 30
var animate_text : bool = false
var current_visible_characters : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	# Oculta la lista de elecciones
	choice_list.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if animate_text:
		if dialog_line.visible_ratio < 1:
			dialog_line.visible_ratio += (1.0/dialog_line.text.length()) * (ANIMATION_SPEED * delta)
			current_visible_characters = dialog_line.visible_characters
		else:
			animate_text = false
			text_animation_done.emit()

func change_line(character_name: Character.Name, line: String):
	speaker_name.text = Character.CHARACTER_DETAILS[character_name]["name"]
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
		# Añadimos el botón al ChoiceList
		choice_list.add_child(choice_button)
	
	# Muestra la lista de elecciones
	choice_list.show()

func skip_text_animation():
	dialog_line.visible_ratio = 1
