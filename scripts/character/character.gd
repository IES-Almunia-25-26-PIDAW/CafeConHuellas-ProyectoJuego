## Clase que centraliza toda la información estática de los personajes del juego.
## Define el enum Name con los IDs de cada personaje y el diccionario CHARACTER_DETAILS
## con sus propiedades (nombre, color, voz, sprites).
## [br]
## Uso: Character.NAME.JASMINE, Character.CHARACTER_DETAILS[Character.Name.JASMINE]
class_name Character
extends Node


# ===== ENUM DE PERSONAJES =====

## Identificadores únicos de cada personaje.
## Se usan como claves en CHARACTER_DETAILS y en los archivos de diálogo JSON.
enum Name {
	NARRATOR,
	HUNTER,
	JASMINE,
	NILAM,
	RONALD
}

# ===== DATOS DE PERSONAJES =====

## Diccionario con las propiedades de cada personaje indexadas por Character.Name.
## Incluye: nombre, color del cuadro de diálogo, sprites, bus de voz y tono.
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
	},
	Name.NILAM: {
		"name": "Nilam",
		# TODO: asignarle sprite
		"sprite_frames": null,
		# Bus con EQ grave y seco
		"voice_bus": "VoiceNilam",
		# Ruta al archivo de voz del personaje
		"voice": "res://assets/audio/voices/voice_base.ogg",
		# Tono de voz grave y seco
		"voice_pitch": 0.85,
		# TODO: asignarle color
		"char_color": Color(0, 0, 0, 0)
	}, 
	Name.RONALD: {
		"name": "Ronald",
		# TODO: asignarle sprite
		"sprite_frames": null,
		# Bus de audio con los efectos propios de Ronald
		"voice_bus": "VoiceRonald",
		# Ruta al archivo de voz del personaje
		"voice": "res://assets/audio/voices/voice_base.ogg",
		# Tono de voz de hombre mayor
		"voice_pitch": 0.92,
		# TODO: asignarle color
		"char_color": Color(0, 0, 0, 0)
	}
	
}



# ===== PUBLIC API =====

## Devuelve el valor del enum Name correspondiente a un string.
## Devuelve -1 y lanza un error si el nombre no existe.
## [param string_value] Nombre del personaje (no sensible a mayúsculas).
static func get_enum_from_string(string_value: String) -> int:
	var upper_string = string_value.to_upper()
	if Name.has(upper_string):
		return Name[upper_string]
	else:
		push_error("Invalid Character name: " + string_value)
		return -1
