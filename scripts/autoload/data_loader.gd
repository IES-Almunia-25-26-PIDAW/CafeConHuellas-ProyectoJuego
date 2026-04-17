extends Node

var characters: Dictionary = {}
var animals: Dictionary = {}
var locations: Dictionary = {}
var day_schedule: Dictionary = {}
var endings: Dictionary = {}

const DATA_PATH := "res://resources/data/"

func _ready() -> void:
	characters = _load_json("characters.json")
	animals = _load_json("animals.json")
	locations = _load_json("locations.json")
	day_schedule = _load_json("day_schedule.json")
	endings = _load_json("endings.json")
	print("DataLoader: Datos cargados correctamente.")

func _load_json(filename: String) -> Dictionary:
	var path: String = DATA_PATH + filename
	if not FileAccess.file_exists(path):
		push_error("DataLoader: No se encontró el archivo: " + path)
		return {}
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("DataLoader: Error al abrir: " + path)
		return {}
	var content: String = file.get_as_text()
	var data: Variant = JSON.parse_string(content)
	if data == null or not data is Dictionary:
		push_error("DataLoader: Error al parsear: " + path)
		return {}
	return data

func get_character(character_id: String) -> Dictionary:
	return characters.get(character_id, {})

func get_character_name(character_id: String) -> String:
	var data: Dictionary = get_character(character_id)
	return data.get("name", character_id)

func get_today_characters(day_number: int) -> Array:
	var day_str: String = str(day_number)
	if not day_schedule.has(day_str):
		return []
	var schedule: Array = day_schedule[day_str]
	var result: Array = []
	for entry in schedule:
		var char_id: String = entry["character_id"]
		var char_data: Dictionary = get_character(char_id).duplicate()
		char_data["_id"] = char_id
		char_data["visit_order"] = entry["visit_order"]
		result.append(char_data)
	return result

func get_animal(animal_id: String) -> Dictionary:
	return animals.get(animal_id, {})

func get_animal_for_day(day_number: int) -> Dictionary:
	for animal_id in animals:
		var animal: Dictionary = animals[animal_id]
		if animal.get("appears_on_day", -1) == day_number:
			var result: Dictionary = animal.duplicate()
			result["_id"] = animal_id
			return result
	return {}

func get_location(location_id: String) -> Dictionary:
	return locations.get(location_id, {})

func get_ending(ending_id: String) -> Dictionary:
	return endings.get(ending_id, {})

func get_friendship_characters() -> Array:
	var result: Array = []
	for char_id in characters:
		if characters[char_id].get("has_friendship_route", false):
			var data: Dictionary = characters[char_id].duplicate()
			data["_id"] = char_id
			result.append(data)
	return result
