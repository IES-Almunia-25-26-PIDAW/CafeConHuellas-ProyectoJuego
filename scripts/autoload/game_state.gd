extends Node

# GameState: Se encarga de guardar todas las propiedades necesarias en las savefiles

# ====== DATOS DEL JUGADOR ======

# Nombre del jugador
var player_name: String = "Hunter"
# Pronombres del jugador (0 - male, 1 - female, 2 - non-binary)
var player_pronouns: int = 0
# Nombre de la cafetería elegido por el jugador
var cafe_name: String = "PawCafé"

# Número del día en el que se encuentra la historia
var day: int = 1
# Escena en la que se encontraba el jugador al guardar
var current_scene: String = "res://scenes/cafe_client_zone.tscn"
# Archivo JSON por el cual va la historia actualmente
var chapter_id: String = "story"
# Línea actual en la que se encuentra la historia
var dialogue_index: int = 0

# Personajes conocidos dentro del juego
var characters_met: Array[String] = []
# Todas las elecciones tomadas por el jugador
var choices_made: Array[String] = []
# Todas las pistas obtenidas por el jugador
var clues_found: Array[String] = []

# Puntuación de la relación actual con Jasmine
var relationship_jasmine: int = 0
# Puntuación de la relación actual con Ronald
var relationship_ronald: int = 0
# Puntuación de la relación actual con Nilam
var relationship_nilam: int = 0
# Puntuación de la relación actual con lachicasecretamuejej
var relationship_hannah: int = 0

# Si se encuentra en la ruta Jasmine
var route_jasmine: bool = false
# Si se encuentra en la ruta Ronald
var route_ronald: bool = false
# Si se encuentra en la ruta Nilam
var route_nilam: bool = false
# Si se encuentra en la ruta lachicasecretamuejej
var route_hannah: bool = false

# Animales actuales que tiene el jugador
var animals_athome: Array[String] = []
# Animales adoptados después de responder un email (buena o mala decisión para al final agregar una puntuación)
var animals_adopted_good: Array[String] = []
var animals_adopted_bad: Array[String] = []
# Emails de adopción de los animales que se han recibido y su estado actual
# Estados: not_read, read, accepted_good, accepted_bad, declined 
var received_emails_status: Dictionary = {}

# Lista de recetas que el cliente ha pedido actualmente (máximo 4, se limpia al completar la orden)
var current_order_recipe_ids: Array[String] = []


# ====== VALORES POR DEFECTO Y RESET DE SAVEFILE ======

# Valores por defecto que se usarán al iniciar un nuevo juego
const DEFAULTS: Dictionary = {
	"player_name": "Hunter",
	"player_pronouns": 0,
	"cafe_name": "PawCafé",
	"day": 1,
	"current_scene": "res://scenes/cafe_client_zone.tscn",
	"chapter_id": "chapter_1",
	"dialogue_index": 0,
	"relationship_jasmine": 0,
	"relationship_ronald": 0,
	"relationship_nilam": 0,
	"relationship_hannah": 0,
	"route_jasmine": false,
	"route_ronald": false,
	"route_nilam": false,
	"route_hannah": false,
}

# Función que resetea todos los valores a los por defecto para empezar una nueva savefile
func reset() -> void:
	player_name = DEFAULTS["player_name"]
	player_pronouns = DEFAULTS["player_pronouns"]
	cafe_name = DEFAULTS["cafe_name"]

	day = DEFAULTS["day"]
	current_scene = DEFAULTS["current_scene"]
	chapter_id = DEFAULTS["chapter_id"]
	dialogue_index = DEFAULTS["dialogue_index"]

	characters_met = []
	choices_made = []
	clues_found = []

	relationship_jasmine = DEFAULTS["relationship_jasmine"]
	relationship_ronald = DEFAULTS["relationship_ronald"]
	relationship_nilam = DEFAULTS["relationship_nilam"]
	relationship_hannah = DEFAULTS["relationship_hannah"]

	route_jasmine = DEFAULTS["route_jasmine"]
	route_ronald = DEFAULTS["route_ronald"]
	route_nilam = DEFAULTS["route_nilam"]
	route_hannah = DEFAULTS["route_hannah"]
	
	animals_athome = []
	animals_adopted_good = []
	animals_adopted_bad = []
	received_emails_status = {}


# ====== FUNCIONES DICT ======

# Convierte el estado a datos guardables (diccionario)
func to_dict() -> Dictionary:
	return {
		"save_version": 1,
		"timestamp": Time.get_datetime_string_from_system(),
		
		"player_name": player_name,
		"player_pronouns": player_pronouns,
		"cafe_name": cafe_name,
		
		"day": day,
		"current_scene": current_scene,
		"chapter_id": chapter_id,
		"dialogue_index": dialogue_index,
		
		"characters_met": characters_met.duplicate(), # Debe ser duplicate() para no compartir la referencia ni modificar la save sin querer
		"choices_made": choices_made.duplicate(),
		"clues_found": clues_found.duplicate(),

		"relationship_jasmine": relationship_jasmine,
		"relationship_ronald": relationship_ronald,
		"relationship_nilam": relationship_nilam,
		"relationship_hannah": relationship_hannah,

		"route_jasmine": route_jasmine,
		"route_ronald": route_ronald,
		"route_nilam": route_nilam,
		"route_hannah": route_hannah,
		
		"animals_athome": animals_athome.duplicate(),
		"animals_adopted_good": animals_adopted_good.duplicate(),
		"animals_adopted_bad": animals_adopted_bad.duplicate(),
		"received_emails_status": received_emails_status.duplicate(),
	}

# Carga los datos en el juego (del diccionario a variables que mete en el juego)
func from_dict(data: Dictionary) -> void:
	player_name = data.get("player_name", DEFAULTS["player_name"])
	player_pronouns = data.get("player_pronouns", DEFAULTS["player_pronouns"])
	cafe_name = data.get("cafe_name", DEFAULTS["cafe_name"])

	day = data.get("day", DEFAULTS["day"])
	current_scene = data.get("current_scene", DEFAULTS["current_scene"])
	chapter_id = data.get("chapter_id", DEFAULTS["chapter_id"])
	dialogue_index = data.get("dialogue_index", DEFAULTS["dialogue_index"])

	characters_met.assign(data.get("characters_met", [])) # Assign vacía el array actual y copia los valores del array pasado
	choices_made.assign(data.get("choices_made", [])) # Si da bugs raros, se puede usar la versión de .duplicate()
	clues_found.assign(data.get("clues_found", []))

	relationship_jasmine = data.get("relationship_jasmine", DEFAULTS["relationship_jasmine"])
	relationship_ronald = data.get("relationship_ronald", DEFAULTS["relationship_ronald"])
	relationship_nilam = data.get("relationship_nilam", DEFAULTS["relationship_nilam"])
	relationship_hannah = data.get("relationship_hannah", DEFAULTS["relationship_hannah"])

	route_jasmine = data.get("route_jasmine", DEFAULTS["route_jasmine"])
	route_ronald = data.get("route_ronald", DEFAULTS["route_ronald"])
	route_nilam = data.get("route_nilam", DEFAULTS["route_nilam"])
	route_hannah = data.get("route_hannah", DEFAULTS["route_hannah"])
	
	animals_athome.assign(data.get("animals_athome", []))
	animals_adopted_good.assign(data.get("animals_adopted_good", []))
	animals_adopted_bad.assign(data.get("animals_adopted_bad", []))
	received_emails_status.assign(data.get("received_emails_status", {}))
