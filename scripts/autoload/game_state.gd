extends Node

# GameState: Se encarga de guardar todas las propiedades necesarias en las savefiles

# ============================================================
# DATOS DEL JUGADOR
# ============================================================

# Nombre del jugador
var player_name: String = "Hunter"
# Pronombres del jugador (0 - male, 1 - female, 2 - non-binary)
var player_pronouns: int = 0
# Nombre de la cafetería elegido por el jugador
var cafe_name: String = "PawCafé"

# Número del día en el que se encuentra la historia
var day: int = 1
# Archivo JSON por el cual va la historia actualmente
var chapter_id: String = "chapter_1"
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
var relationship_secretgirl: int = 0

# Si se encuentra en la ruta Jasmine
var route_jasmine: bool = false
# Si se encuentra en la ruta Ronald
var route_ronald: bool = false
# Si se encuentra en la ruta Nilam
var route_nilam: bool = false
# Si se encuentra en la ruta lachicasecretamuejej
var route_secretgirl: bool = false

# Posteriormente: (también se pueden usar diccionarios pero no se en q contexto usarlos jejejj)
#Hay que agregar las mascotas que se tienen en un array quizas?
#Mascotas que han sido adoptadas, un array con buena puntuacion y otro array con mala

# ============================================================
# ANIMALES
# ============================================================

# Animales recogidos por el jugador (IDs: "mochi", "luna", "canela", "nube")
var animals_collected: Array[String] = []

# Estado de cuidado de cada animal recogido
# Formato: {"noni": {"fed": false, "healed": false, "petted": false}}
var animals_care: Dictionary = {}

# Animales adoptados (buena o mala decisión)
var animals_adopted_good: Array[String] = []
var animals_adopted_bad: Array[String] = []

# Emails de adopción respondidos: {"email_1": "accepted", "email_2": "rejected"}
var adoption_decisions: Dictionary = {}

# ============================================================
# PEDIDOS
# ============================================================

# Historial de pedidos completados
# Cada entrada: {"day": 1, "character_id": "alcalde", "recipes": ["cafe_solo"]}
var orders_history: Array[Dictionary] = []

# ============================================================
# PROGRESO DEL DÍA
# ============================================================

var day_work_done: bool = false
var day_animals_checked: bool = false
var day_night_done: bool = false


# Valores por defecto que se usarán al iniciar un nuevo juego
const DEFAULTS: Dictionary = {
	"player_name": "Hunter",
	"player_pronouns": 0,
	"cafe_name": "PawCafé",
	"day": 1,
	"chapter_id": "chapter_1",
	"dialogue_index": 0,
	"relationship_jasmine": 0,
	"relationship_ronald": 0,
	"relationship_nilam": 0,
	"relationship_secretgirl": 0,
	"route_jasmine": false,
	"route_ronald": false,
	"route_nilam": false,
	"route_secretgirl": false,
	"day_work_done": false,
	"day_animals_checked": false,
	"day_night_done": false
}

# Función que resetea todos los valores a los por defecto para empezar una nueva savefile
func reset() -> void:
	player_name = DEFAULTS["player_name"]
	player_pronouns = DEFAULTS["player_pronouns"]
	cafe_name = DEFAULTS["cafe_name"]

	day = DEFAULTS["day"]
	chapter_id = DEFAULTS["chapter_id"]
	dialogue_index = DEFAULTS["dialogue_index"]

	characters_met = []
	choices_made = []
	clues_found = []

	relationship_jasmine = DEFAULTS["relationship_jasmine"]
	relationship_ronald = DEFAULTS["relationship_ronald"]
	relationship_nilam = DEFAULTS["relationship_nilam"]
	relationship_secretgirl = DEFAULTS["relationship_secretgirl"]

	route_jasmine = DEFAULTS["route_jasmine"]
	route_ronald = DEFAULTS["route_ronald"]
	route_nilam = DEFAULTS["route_nilam"]
	route_secretgirl = DEFAULTS["route_secretgirl"]
	animals_collected = []
	animals_care = {}
	animals_adopted_good = []
	animals_adopted_bad = []
	adoption_decisions = {}
	orders_history = []
	day_work_done = false
	day_animals_checked = false
	day_night_done = false

# Convierte el estado a datos guardables (diccionario)
func to_dict() -> Dictionary:
	return {
		"save_version": 1,
		"timestamp": Time.get_datetime_string_from_system(),
		
		"player_name": player_name,
		"player_pronouns": player_pronouns,
		"cafe_name": cafe_name,
		
		"day": day,
		"chapter_id": chapter_id,
		"dialogue_index": dialogue_index,
		
		"characters_met": characters_met.duplicate(), # Debe ser duplicate() para no compartir la referencia ni modificar la save sin querer
		"choices_made": choices_made.duplicate(),
		"clues_found": clues_found.duplicate(),

		"relationship_jasmine": relationship_jasmine,
		"relationship_ronald": relationship_ronald,
		"relationship_nilam": relationship_nilam,
		"relationship_secretgirl": relationship_secretgirl,

		"route_jasmine": route_jasmine,
		"route_ronald": route_ronald,
		"route_nilam": route_nilam,
		"route_secretgirl": route_secretgirl,
		
		"animals_collected": animals_collected.duplicate(),
		"animals_care": animals_care.duplicate(true),
		"animals_adopted_good": animals_adopted_good.duplicate(),
		"animals_adopted_bad": animals_adopted_bad.duplicate(),
		"adoption_decisions": adoption_decisions.duplicate(),
		"orders_history": orders_history.duplicate(true),
		"day_work_done": day_work_done,
		"day_animals_checked": day_animals_checked,
		"day_night_done": day_night_done,
	}

# Carga los datos en el juego (del diccionario a variables que mete en el juego)
func from_dict(data: Dictionary) -> void:
	player_name = data.get("player_name", DEFAULTS["player_name"])
	player_pronouns = data.get("player_pronouns", DEFAULTS["player_pronouns"])
	cafe_name = data.get("cafe_name", DEFAULTS["cafe_name"])

	day = data.get("day", DEFAULTS["day"])
	chapter_id = data.get("chapter_id", DEFAULTS["chapter_id"])
	dialogue_index = data.get("dialogue_index", DEFAULTS["dialogue_index"])

	characters_met.assign(data.get("characters_met", [])) # Assign vacía el array actual y copia los valores del array pasado
	choices_made.assign(data.get("choices_made", [])) # Si da bugs raros, se puede usar la versión de .duplicate()
	clues_found.assign(data.get("clues_found", []))

	relationship_jasmine = data.get("relationship_jasmine", DEFAULTS["relationship_jasmine"])
	relationship_ronald = data.get("relationship_ronald", DEFAULTS["relationship_ronald"])
	relationship_nilam = data.get("relationship_nilam", DEFAULTS["relationship_nilam"])
	relationship_secretgirl = data.get("relationship_secretgirl", DEFAULTS["relationship_secretgirl"])

	route_jasmine = data.get("route_jasmine", DEFAULTS["route_jasmine"])
	route_ronald = data.get("route_ronald", DEFAULTS["route_ronald"])
	route_nilam = data.get("route_nilam", DEFAULTS["route_nilam"])
	route_secretgirl = data.get("route_secretgirl", DEFAULTS["route_secretgirl"])
	
	# Animales
	var collected_data = data.get("animals_collected", [])
	animals_collected = []
	for item in collected_data:
		animals_collected.append(str(item))

	animals_care = data.get("animals_care", {})

	var good_data = data.get("animals_adopted_good", [])
	animals_adopted_good = []
	for item in good_data:
		animals_adopted_good.append(str(item))

	var bad_data = data.get("animals_adopted_bad", [])
	animals_adopted_bad = []
	for item in bad_data:
		animals_adopted_bad.append(str(item))

	adoption_decisions = data.get("adoption_decisions", {})

	# Pedidos
	var orders_data = data.get("orders_history", [])
	orders_history = []
	for item in orders_data:
		orders_history.append(item)

	# Progreso del día
	day_work_done = data.get("day_work_done", false)
	day_animals_checked = data.get("day_animals_checked", false)
	day_night_done = data.get("day_night_done", false)
	
	


# ============================================================
# FUNCIONES ÚTILES
# ============================================================

# --- AMISTAD ---

func get_friendship_level(character_id: String) -> int:
	match character_id:
		"jasmine": return relationship_jasmine
		"vendedor": return relationship_ronald
		"bibliotecario": return relationship_nilam
		_: return 0

func add_friendship(character_id: String, amount: int = 1) -> void:
	match character_id:
		"jasmine": relationship_jasmine += amount
		"vendedor": relationship_ronald += amount
		"bibliotecario": relationship_nilam += amount

# --- PISTAS ---

func add_clue(clue_id: String) -> void:
	if clue_id not in clues_found:
		clues_found.append(clue_id)

func has_clue(clue_id: String) -> bool:
	return clue_id in clues_found

func get_clue_count() -> int:
	return clues_found.size()

# --- ELECCIONES ---

func save_choice(choice_id: String) -> void:
	if choice_id not in choices_made:
		choices_made.append(choice_id)

# --- ANIMALES ---

func collect_animal(animal_id: String) -> void:
	if animal_id not in animals_collected:
		animals_collected.append(animal_id)
		animals_care[animal_id] = {"fed": false, "healed": false, "petted": false}

func feed_animal(animal_id: String) -> void:
	if animals_care.has(animal_id):
		animals_care[animal_id]["fed"] = true

func heal_animal(animal_id: String) -> void:
	if animals_care.has(animal_id):
		animals_care[animal_id]["healed"] = true

func pet_animal(animal_id: String) -> void:
	if animals_care.has(animal_id):
		animals_care[animal_id]["petted"] = true

func get_my_animals() -> Array[String]:
	var result: Array[String] = []
	for animal_id in animals_collected:
		if animal_id not in animals_adopted_good and animal_id not in animals_adopted_bad:
			result.append(animal_id)
	return result

func is_animal_fully_cared(animal_id: String) -> bool:
	if not animals_care.has(animal_id):
		return false
	var care = animals_care[animal_id]
	return care["fed"] and care["healed"] and care["petted"]

# --- ADOPCIONES ---

func decide_adoption(email_id: String, animal_id: String, accepted: bool, is_good: bool) -> void:
	adoption_decisions[email_id] = "accepted" if accepted else "rejected"
	if accepted:
		if is_good:
			animals_adopted_good.append(animal_id)
		else:
			animals_adopted_bad.append(animal_id)

# --- PERSONAJES ---

func meet_character(character_id: String) -> void:
	if character_id not in characters_met:
		characters_met.append(character_id)

func has_met(character_id: String) -> bool:
	return character_id in characters_met

# --- PROGRESO DEL DÍA ---

func advance_day() -> void:
	if day < 15:
		day += 1
		day_work_done = false
		day_animals_checked = false
		day_night_done = false
		# Resetear el cuidado diario de los animales
		for animal_id in animals_care:
			animals_care[animal_id] = {"fed": false, "healed": false, "petted": false}

func complete_work() -> void:
	day_work_done = true

func complete_animals_check() -> void:
	day_animals_checked = true

func complete_night() -> void:
	day_night_done = true


# Handlers --- Info del Jugador
