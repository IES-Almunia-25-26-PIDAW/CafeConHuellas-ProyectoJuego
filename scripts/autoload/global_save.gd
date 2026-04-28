extends Node

# GlobalSave: Se encarga de guardar datos persistewntes que son independientes del guardado de partidas y slots
# Estos datos son acumulativos y una vez desbloqueados nunca se pierden
# Gestiona los siguientes datos:
#	--> images_unlocked: IDs de las ilustraciones que el jugador ha conseguido jugando la historia
#	--> endings_unlocked: Indica los finales que el jugador ha conseguido (bool)
# Estos datos se almacenan en el disco cada vez que se desbloquea algo nuevo

# PARA DESBLOQUEAR FINALES/IMÁGENES DESDE LA HISTORIA:
# Al mostrar una CG durante un diálogo:
#GlobalSave.unlock_image("cg_jasmine_01")

# Al llegar a un final:
#GlobalSave.unlock_ending("ending_jasmine_good")

signal image_unlocked(image_id: String)
signal ending_unlocked(ending_id: String)

const SAVE_PATH: String = "user://saves/global_save.json"
const CURRENT_VERSION: int = 1

# Datos en memoria
var _images_unlocked: Array[String] = []
var _endings_unlocked: Dictionary = {} # Se almacenan con el nombre del ending y true/false
# Desbloquea interacciones especiales con Hannah y otros personajes
var hannah_unlocked: bool = false

# Finales que cuentan para desbloquear a Hannah, los cuales son todos menos el suyo
const HANNAH_REQUIRED_ENDINGS: Array[String] = [
	"ending_bad",
	"ending_hunter",
	"ending_jasmine",
	"ending_ronald",
	"ending_nilam"
]


# ===== INICIALIZACIÓN =====

func _ready() -> void:
	_load()


# ===== PUBLIC API - DESBLOQUEO DE IMÁGENES/FINALES =====

# Desbloquea una imagen si no estaba ya desbloqueada. Se guarda automáticamente y emite la señal
func unlock_image(image_id: String) -> void:
	if _images_unlocked.has(image_id):
		return
	_images_unlocked.append(image_id)
	_save()
	image_unlocked.emit(image_id)

# Desbloquea un final si no estaba ya desbloqueado. Se guarda automáticamente y emite la señal
func unlock_ending(ending_id: String) -> void:
	if _endings_unlocked.get(ending_id, false):
		return
	_endings_unlocked[ending_id] = true
	_save()
	ending_unlocked.emit(ending_id)
	# Comprobar si hannah se desbloquea tras ese final
	_check_hannah_unlock()


# ===== PUBLIC API - CONSULTAS =====

func has_image(image_id: String) -> bool:
	return _images_unlocked.has(image_id)

func has_ending(ending_id: String) -> bool:
	return _endings_unlocked.get(ending_id, false)

# Devuelve una copia del array para evitar modificaciones externas accidentales
func get_all_images() -> Array[String]:
	return _images_unlocked.duplicate()

# Devuelve una copia del diccionario de finales
func get_unlocked_endings() -> Dictionary:
	return _endings_unlocked.duplicate()

# Comprueba si hannah se ha desbloqueado
func _check_hannah_unlock() -> void:
	# Comprueba primero si ya estaba desbloqueada, si es así no hace nada
	if hannah_unlocked:
		return 
	
	var completed_count: int = 0
	for ending_id in HANNAH_REQUIRED_ENDINGS:
		if _endings_unlocked.get(ending_id, false):
			completed_count += 1
	
	if completed_count >= 5:
		hannah_unlocked = true
		_save()


# ===== GUARDADO Y CARGADO DE LOS DATOS =====

func _save() -> void:
	var data: Dictionary = {
		"save_version": CURRENT_VERSION,
		"images_unlocked": _images_unlocked.duplicate(),
		"endings_unlocked": _endings_unlocked.duplicate(),
		"hannah_unlocked": hannah_unlocked
	}
	
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("GlobalSave: No se pudo abrir el archivo para escritura: " + error_string(FileAccess.get_open_error()))
		return
	file.store_string(JSON.stringify(data, "  "))


func _load() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		# Es para la primera vez que se ejecuta el juego, ya que no habrá archivo
		return
	
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("GlobalSave: No se pudo abrir el archivo para lectura: " + error_string(FileAccess.get_open_error()))
		return
	
	var data = JSON.parse_string(file.get_as_text())
	if data == null or not data is Dictionary:
		push_error("GlobalSave: Error al parsear global_save.json.")
		return
	
	# Si es una versión antigua, migrar antes de aplicar
	if data.get("save_version", 1) < CURRENT_VERSION:
		data = _migrate(data)
	
	# Cargar imágenes
	# assign() vacía el array actual y copia los valores
	_images_unlocked.assign(data.get("images_unlocked", []))
	
	# Cargar finales
	var endings = data.get("endings_unlocked", {})
	if endings is Dictionary:
		_endings_unlocked = endings.duplicate()
		
	# Cargar si hannah está desbloqueada, comprobándolo
	hannah_unlocked = data.get("hannah_unlocked", false) 
	_check_hannah_unlock()


# ===== MIGRACIÓN =====

# Patrón de migración: añadir un bloque "if version < X" por cada cambio
func _migrate(data: Dictionary) -> Dictionary:
	# var version: int = data.get("save_version", 1)
	# if version < 2:
	#     data["save_version"] = 2
	return data
