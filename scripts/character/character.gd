class_name Character
extends Node

# Nombres de los personajes
enum Name {
	NARRATOR,
	HUNTER,
	JASMINE
}

# Información de los personajes
const CHARACTER_DETAILS : Dictionary = {
	Name.NARRATOR: {
		"name": "",
		"char_color": Color(0,0,0,0),
		"voice": "",
		"voice_pitch": 1.0,
		"voice_bus": "Voices"
	},
	Name.HUNTER: {
		"name": "Hunter",
		"sprite_frames": null,
		"char_color": Color("4f382de6")
	},
	Name.JASMINE: {
		"name": "Jasmine",
		"sprite_frames": preload("res://assets/sprites/jasmine/jasmine_sprites.tres"),
		# Bus de audio con los efectos propios de Jasmine
		"voice_bus": "VoiceJasmine",
		# Ruta al archivo de voz del personaje
		"voice": "res://assets/audio/voices/voice_base.ogg",
		# Tono de voz, más alto = más agudo
		"voice_pitch": 2,
		"char_color": Color("a8587ce6")
	}
}



# Compara el nombre pasado con el del Enum para saber si existe
static func get_enum_from_string(string_value: String) -> int:
	var upper_string = string_value.to_upper()
	if Name.has(upper_string):
		return Name[upper_string]
	else:
		push_error("Invalid Character name: " + string_value)
		return -1
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
