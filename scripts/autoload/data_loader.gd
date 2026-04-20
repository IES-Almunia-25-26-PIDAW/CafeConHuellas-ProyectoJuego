extends Node

# DataLoader: Carga todos los datos estáticos del juego al inicio desde archivos JSON
# Estos datos NUNCA se modifican durante la partida, solo se consultan
# Es un autoload singleton por lo que los datos están disponibles en cualquier parte del juego

# ===== ARCHIVOS Y RUTA =====

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

# ALMACENAMIENTO INTERNO: Cada diccionario mapea un ID a sus datos
var _animals: Dictionary = {}
var _characters: Dictionary = {}
var _clues: Dictionary = {}
var _emails: Dictionary = {}
var _recipes: Dictionary = {}
var _ingredients: Dictionary = {}
var _cgs: Dictionary = {}


# ===== INICIALIZACIÓN =====

func _ready() -> void:
	_load_all()

# Carga todos los archivos, se llama una vez al inicio del juego
func _load_all() -> void:
	_animals = _load_file(PATHS["animals"])
	_characters = _load_file(PATHS["characters"])
	_clues = _load_file(PATHS["clues"])
	_emails = _load_file(PATHS["emails"])
	_recipes = _load_file(PATHS["recipes"])
	_ingredients = _load_file(PATHS["ingredients"])
	_cgs = _load_file(PATHS["cgs"])

# Abre y parsea un archivo JSON, devolviendo un diccionario con los datos obtenidos
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
# En este apartado van todas las funciones que devuelven una copia del dato pedido o requerido
# Usa el helper para recoger los datos: Si el ID no existe, se devuelve un diccionario vacío y un warning

# --- Animales ---

func get_animal(id: String) -> Dictionary:
	return _get_entry(_animals, id, "animal")

func get_all_animals() -> Dictionary:
	return _animals.duplicate(true)

# --- Personajes ---

func get_character(id: String) -> Dictionary:
	return _get_entry(_characters, id, "character")

func get_all_characters() -> Dictionary:
	return _characters.duplicate(true)

# --- Pistas ---

func get_clue(id: String) -> Dictionary:
	return _get_entry(_clues, id, "clue")

func get_all_clues() -> Dictionary:
	return _clues.duplicate(true)

# --- Emails ---

func get_email(id: String) -> Dictionary:
	return _get_entry(_emails, id, "email")

func get_all_emails() -> Dictionary:
	return _emails.duplicate(true)

# --- Recetas ---

func get_recipe(id: String) -> Dictionary:
	return _get_entry(_recipes, id, "recipe")

func get_all_recipes() -> Dictionary:
	return _recipes.duplicate(true)

# --- Ingredientes ---

func get_ingredient(id: String) -> Dictionary:
	return _get_entry(_ingredients, id, "ingredient")

func get_all_ingredients() -> Dictionary:
	return _ingredients.duplicate(true)

# --- CGs ---

func get_cg(id: String) -> Dictionary:
	return _get_entry(_cgs, id, "cg")

func get_all_cgs() -> Dictionary:
	return _cgs.duplicate(true)


# ===== HELPER INTERNO =====

# Busca una entrada en un diccionario de datos por su ID, centraliza su manejo y devuelve warnings descriptivos
func _get_entry(dataset: Dictionary, id: String, type_name: String) -> Dictionary:
	if not dataset.has(id):
		push_warning("DataLoader: %s con ID '%s' no encontrado." % [type_name, id])
		return {}
	return dataset[id].duplicate(true)
	
