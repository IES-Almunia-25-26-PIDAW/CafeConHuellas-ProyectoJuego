extends Node

# SaveManager - Clase que permite cargar un singleton que maneja todo el guardado y cargado de datos
# Este SaveManager usa archivos JSON para guardar los datos

# Se emite después de que se guarde correctamente en un slot
signal game_saved(slot: int)
# Se emite después de que se carge correctamente de un slot
signal game_loaded(slot: int)

# Directorio base donde se van a guardar las savefiles
const SAVE_DIR: String ="user://saves/"

# Número de slots disponibles para el jugador
const MAX_SLOTS: int = 3

# Versión actual del formato de guardado
# Se debe incrementar cuando cambia la estructura y añadir lógica en _migrate_save_data() para actualizar saves antiguas
const CURRENT_SAVE_VERSION: int = 1

func _ready() -> void:
	# Hay que asegurarse que el directorio de las savefiles existe cuando el juego comienza
	# make_dir_recursive_absolute crea los directorios si es necesario
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)


# ========= PUBLIC API =========

# Guarda el estado actual del juego en una slot
# Lee todos los datos del GameState autoload y lo escribe en un archivo
func save_game(slot: int) -> void:
	_save_json(slot)
	game_saved.emit(slot)

# Carga el estado del juego de una slot
# Lee el archivo y escribe todos los datos nuevamente en el GameState autoload
# Devuelve true si la carga es correcta y false si falla
func load_game(slot: int) -> bool:
	var success: bool = false
	success = _load_json(slot)
	if success:
		game_loaded.emit(slot)
	return success

# Revisa si una savefile existe en la slot indicada
# Solo revisa la extensión usada (json)
func has_save(slot: int) -> bool:
	return FileAccess.file_exists(_get_path(slot, "json"))

# Obtiene información de una save slot (usada por la UI para mostrar detalles)
# Devuelve un diccionario con "day", "chapter_id" y "timestamp" o "VACÍO" si no hay guardado
func get_save_info(slot: int) -> Dictionary:
	var path := _get_path(slot, "json")
	if FileAccess.file_exists(path):
		var file := FileAccess.open(path, FileAccess.READ)
		if file:
			var data = JSON.parse_string(file.get_as_text())
			if data is Dictionary:
				return {
					"day": data.get("day", ""),
					"chapter_id": data.get("chapter_id", ""),
					"timestamp": data.get("timestamp", "")
				}
	return {}

# Elimina la savefile en una slot
func delete_save(slot: int) -> void:
	for ext in ["json"]:
		var path := _get_path(slot, ext)
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)


# ========= PATH HELPER =========

# Construye el path completo para una slot
# EJ: _get_path(0, "json") => "user://saves/slot_0.json"
func _get_path(slot: int, extension: String) -> String:
	return SAVE_DIR + "slot_%d.%s" % [slot, extension]


# ========= JSON METHOD =========

func _save_json(slot: int) -> void:
	# Guarda el estado del juego como un diccionario
	var data: Dictionary = GameState.to_dict()
	
	# Convierte el diccionario a un JSON string. El segundo argumento es para más legibilidad
	var json_string: String = JSON.stringify(data, "  ")
	
	# Abre el archivo para su escritura. FileAccess.open() devuelve null si falla
	var file := FileAccess.open(_get_path(slot, "json"), FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: Error al abrir el archivo JSON para su escritura: " + error_string(FileAccess.get_open_error()))
		return
	
	# Escribe el string JSON en el archivo. El archivo se cierra automáticamente
	file.store_string(json_string)

func _load_json(slot: int) -> bool:
	var path := _get_path(slot, "json")
	
	# Siempre revisa si el archivo existe antes de intentar abrirlo
	if not FileAccess.file_exists(path):
		push_warning("SaveManager: No se ha encontrado un archivo JSON en " + path)
		return false
	
	# Abre el archivo para su lectura
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("SaveManager: Error al abrir el archivo JSON para su lectura: " + error_string(FileAccess.get_open_error()))
		return false
	
	# Lee el archivo entero como un string y lo parsea a JSON
	var json_string: String = file.get_as_text()
	var data = JSON.parse_string(json_string)
	
	# JSON.parse_string() devuelve null si falla el parseo
	if data == null or not data is Dictionary:
		push_error("SaveManager: Failed to parse JSON save file")
		return false
	
	# JSON no distingue int de float, así que debemos castear todos los datos nuevamente a int
	if data.has("player_pronouns"):
		data["player_pronouns"] = int(data["player_pronouns"])

	if data.has("day"):
		data["day"] = int(data["day"])

	if data.has("dialogue_index"):
		data["dialogue_index"] = int(data["dialogue_index"])

	if data.has("relationship_jasmine"):
		data["relationship_jasmine"] = int(data["relationship_jasmine"])

	if data.has("relationship_ronald"):
		data["relationship_ronald"] = int(data["relationship_ronald"])

	if data.has("relationship_nilam"):
		data["relationship_nilam"] = int(data["relationship_nilam"])

	if data.has("relationship_secretgirl"):
		data["relationship_secretgirl"] = int(data["relationship_secretgirl"])	

	# Si la savefile es de una versión antigua, se debe actualizar antes de aplicarse
	if data.get("save_version", 1) < CURRENT_SAVE_VERSION:
		data = _migrate_save_data(data)

	# Aplica los datos cargados en GameState
	GameState.from_dict(data)
	return true


# ========= MIGRATION =========

# Actualiza el diccionario de una savefile de una versión antigua a CURRENT_SAVE_VERSION
# Solo se llama cuando la savefile cargada es una versión anterior a la actual
# Añade un nuevo 'if version < X' cada vez que cambie el formato!
func _migrate_save_data(data: Dictionary) -> Dictionary:
	var version: int = data.get("save_version", 1)
	
	# EJEMPLO DE COMO SE HARÍA:
	# v1 -> v2: speaker_box_position and speaker_box_color were removed.
	# We just discard them — from_dict() would have ignored them anyway,
	# but erasing them here keeps the data clean.
	#if version < 2:
	#	data.erase("speaker_box_position")
	#	data.erase("speaker_box_color")

	#	data["save_version"] = 2

	return data
