## Autoload singleton que carga y centraliza todos los datos estáticos del juego.
## Los datos se leen desde archivos JSON al inicio y nunca se modifican durante la partida.
## Cualquier script puede consultar datos llamando a sus funciones públicas (get_recipe, get_animal, etc.)
## [br]
## Nota: Los datos se cargan de forma síncrona en _ready(). Si en el futuro
## los archivos creciesen mucho, considerar carga asíncrona con ResourceLoader.

extends Node

# ===== RUTAS Y ARCHIVOS =====

const DATA_DIR: String = "res://resources/data/"

# Diccionarios donde se guardarán los datos de cada JSON al cargarlos, se llenan en ready()
const PATHS: Dictionary = {
	"animals": DATA_DIR + "animals.json",
	"characters": DATA_DIR + "characters.json",
	"clues": DATA_DIR + "clues.json",
	"emails": DATA_DIR + "emails.json",
	"recipes": DATA_DIR + "recipes.json",
	"ingredients": DATA_DIR + "ingredients.json",
	"cgs": DATA_DIR + "cgs.json",
}

# ===== ALMACENAMIENTO INTERNO =====
# Cada diccionario mapea un ID (String) a sus datos (Dictionary).
# Se acceden solo a través de la Public API, nunca directamente desde fuera.

var _animals: Dictionary = {}
var _characters: Dictionary = {}
var _clues: Dictionary = {}
var _emails: Dictionary = {}
var _recipes: Dictionary = {}
var _ingredients: Dictionary = {}
var _cgs: Dictionary = {}

# Asegura de que los datos estén cargados y listos
var _loaded: bool = false

# ===== INICIALIZACIÓN =====

func _ready() -> void:
	_load_all()
	_loaded = true

## Garantiza que los datos estén cargados antes de cualquier consulta.
## Se llama al inicio de cada función pública como medida de seguridad.
func ensure_loaded() -> void:
	if not _loaded:
		_load_all()
		_loaded = true

# Carga todos los archivos JSON. Se llama una única vez al inicio del juego.
func _load_all() -> void:
	_animals = _load_file(PATHS["animals"])
	_characters = _load_file(PATHS["characters"])
	_clues = _load_file(PATHS["clues"])
	_emails = _load_file(PATHS["emails"])
	_recipes = _load_file(PATHS["recipes"])
	_ingredients = _load_file(PATHS["ingredients"])
	_cgs = _load_file(PATHS["cgs"])
	
	# DEBUG:
	print("DataLoader: animals cargados: ", _animals.size())
	print("DataLoader: characters cargados: ", _characters.size())
	print("DataLoader: clues cargados: ", _clues.size())
	print("DataLoader: emails cargados: ", _emails.size())
	print("DataLoader: recipes cargados: ", _recipes.size())
	print("DataLoader: ingredients cargados: ", _ingredients.size())
	print("DataLoader: cgs cargados: ", _cgs.size())

# Abre y parsea un archivo JSON, devolviendo un diccionario con los datos obtenidos. 
# Devuelve un diccionario vacío si falla.
func _load_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("DataLoader: Archivo no encontrado: " + path)
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("DataLoader: Error al abrir el archivo: " + path)
		return {}

	var data = JSON.parse_string(file.get_as_text())
	if data == null or not data is Dictionary:
		push_error("DataLoader: Error al parsear JSON en: " + path)
		return {}

	return data
	

# ===== PUBLIC API =====
# Devuelven siempre una copia del dato para evitar modificaciones accidentales.
# Si el ID no existe, devuelven un diccionario vacío y lanzan un warning.

# --- Animales ---

## Devuelve los datos de un animal por su ID.
func get_animal(id: String) -> Dictionary:
	ensure_loaded()
	return _get_entry(_animals, id, "animal")

## Devuelve todos los animales.
func get_all_animals() -> Dictionary:
	ensure_loaded()
	return _animals.duplicate(true)

# --- Personajes ---

## Devuelve los datos de un personaje por su ID.
func get_character(id: String) -> Dictionary:
	ensure_loaded()
	return _get_entry(_characters, id, "character")

## Devuelve todos los personajes.
func get_all_characters() -> Dictionary:
	ensure_loaded()
	return _characters.duplicate(true)

# --- Pistas ---

## Devuelve los datos de una pista por su ID.
func get_clue(id: String) -> Dictionary:
	ensure_loaded()
	return _get_entry(_clues, id, "clue")

## Devuelve todas las pistas.
func get_all_clues() -> Dictionary:
	ensure_loaded()
	return _clues.duplicate(true)

# --- Emails ---

## Devuelve los datos de un email por su ID.
func get_email(id: String) -> Dictionary:
	ensure_loaded()
	return _get_entry(_emails, id, "email")

## Devuelve todos los emails.
func get_all_emails() -> Dictionary:
	ensure_loaded()
	return _emails.duplicate(true)

# --- Recetas ---

## Devuelve los datos de una receta por su ID.
func get_recipe(id: String) -> Dictionary:
	ensure_loaded()
	return _get_entry(_recipes, id, "recipe")

## Devuelve todas las recetas.
func get_all_recipes() -> Dictionary:
	ensure_loaded()
	return _recipes.duplicate(true)

# --- Ingredientes ---

## Devuelve los datos de un ingrediente por su ID.
func get_ingredient(id: String) -> Dictionary:
	ensure_loaded()
	return _get_entry(_ingredients, id, "ingredient")

## Devuelve todos los ingredientes.
func get_all_ingredients() -> Dictionary:
	ensure_loaded()
	return _ingredients.duplicate(true)

# --- CGs ---

## Devuelve los datos de un CG por su ID.
func get_cg(id: String) -> Dictionary:
	ensure_loaded()
	return _get_entry(_cgs, id, "cg")

## Devuelve todos los CGs.
func get_all_cgs() -> Dictionary:
	ensure_loaded()
	return _cgs.duplicate(true)


# ===== HELPER INTERNO =====

# Busca una entrada en un diccionario de datos por su ID, centraliza su manejo y devuelve warnings descriptivos.
func _get_entry(dataset: Dictionary, id: String, type_name: String) -> Dictionary:
	if not dataset.has(id):
		push_warning("DataLoader: %s con ID '%s' no encontrado." % [type_name, id])
		return {}
	return dataset[id].duplicate(true)
	
