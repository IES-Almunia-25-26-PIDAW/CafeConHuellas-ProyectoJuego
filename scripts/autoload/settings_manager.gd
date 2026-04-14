extends Node

# SettingsManager - Clase que permite cargar un singleton que maneja todo el guardado y cargado de preferencias de configuración del usuario
# Estas preferencias se aplican sin importar qué savefile carga el usuario

# Directorio base donde se van a guardar las preferencias
const SETTINGS_PATH: String = "user://settings.cfg"

# AJUSTES
# Aquí tengo pensado meter algo como el volumen de la música o algo similar :p

func _ready() -> void:
	load_settings()


# ========= PUBLIC API =========

# Guarda todos los ajustes en el archivo de configuración
func save_settings() -> void:
	# Crea una nueva instancia de ConfigFile
	var config := ConfigFile.new()
	
	# set_value(section, key, value) guarda un valor bajo una sección
	# ConfigFile maneja la serialización automáticamente
	#config.set_value("display", "speaker_box_position", speaker_box_position) (EJ)
	
	# Guarda el archivo de configuración
	var error := config.save(SETTINGS_PATH)
	if error != OK:
		push_error("SettingsManager: Error al guardar los archivos: " + error_string(error))

# Carga los ajustes desde el archivo de configuración. Vuelve a default si el archivo no existe
func load_settings() -> void:
	var config := ConfigFile.new()
	
	# config.load() devuelve un error de código. Si el archivo no existe vuelve a los valores por default
	var error := config.load(SETTINGS_PATH)
	if error != OK:
		# Si el archivo no existe aún se usarán los valores por default
		# Un archivo de configuración se creará la primera vez que save_settings() se llame
		return
	
	# get_value(section, key, default) lee un valor de una configuración
	# El tercer argumento es el fallback por si la key no existe y nos protege si agregamos más ajustes en un futuro
	#speaker_box_position = config.get_value("display", "speaker_box_position", "left") (EJ)
