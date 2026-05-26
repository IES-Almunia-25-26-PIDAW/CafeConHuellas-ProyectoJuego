## Autoload singleton que gestiona las preferencias de configuración del usuario.
## Persiste entre partidas y slots, independientemente del savefile activo.
## Usa ConfigFile en lugar de JSON por ser más apropiado para settings clave-valor.
## [br]
## Nota: Los volúmenes se almacenan en rango 0.0-1.0 y se convierten a dB
## internamente antes de aplicarlos al AudioServer.
extends Node

# ===== CONSTANTES =====

# Directorio base donde se van a guardar las preferencias.
const SETTINGS_PATH: String = "user://settings.cfg"
const SECTION: String = "audio"

# Valores por defecto (rango 0.0 - 1.0).
const DEFAULT_MUSIC_VOLUME: float = 0.8
const DEFAULT_VOICE_VOLUME: float = 1.0
const DEFAULT_SFX_VOLUME: float = 1.0

# Nombre de los buses en el AudioServer de Godot.
const BUS_MUSIC: String = "Music"
const BUS_VOICES: String = "Voices"
const BUS_SFX: String = "SFX"


# ===== VOLÚMENES EN MEMORIA =====

var music_volume: float = DEFAULT_MUSIC_VOLUME
var voice_volume: float = DEFAULT_VOICE_VOLUME
var sfx_volume: float = DEFAULT_SFX_VOLUME


# ===== INICIALIZACIÓN =====

# Carga los settings y los aplica al AudioServer.
func _ready() -> void:
	load_settings()
	_apply_to_audio_server()


# ===== PUBLIC API =====

## Actualiza el volumen de música, lo aplica al AudioServer y guarda los settings.
## [param value] Nuevo volumen, se clampea automáticamente a [0.0, 1.0].
func set_music_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	_set_bus_volume(BUS_MUSIC, music_volume)
	save_settings()

## Actualiza el volumen de voces, lo aplica al AudioServer y guarda los settings.
## [param value] Nuevo volumen, se clampea automáticamente a [0.0, 1.0].
func set_voice_volume(value: float) -> void:
	voice_volume = clampf(value, 0.0, 1.0)
	_set_bus_volume(BUS_VOICES, voice_volume)
	save_settings()

## Actualiza el volumen de efectos de sonido, lo aplica al AudioServer y guarda los settings.
## [param value] Nuevo volumen, se clampea automáticamente a [0.0, 1.0].
func set_sfx_volume(value: float) -> void:
	sfx_volume = clampf(value, 0.0, 1.0)
	_set_bus_volume(BUS_SFX, sfx_volume)
	save_settings()


# ===== GUARDADO Y CARGADO =====

## Guarda los volúmenes actuales en disco.
func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value(SECTION, "music_volume", music_volume)
	config.set_value(SECTION, "voice_volume", voice_volume)
	config.set_value(SECTION, "sfx_volume", sfx_volume)
	
	var err := config.save(SETTINGS_PATH)
	if err != OK:
		push_error("SettingsManager: Error al guardar settings: " + error_string(err))
		
## Carga los volúmenes desde disco. Si el archivo no existe usa los valores por defecto.
func load_settings() -> void:
	var config := ConfigFile.new()
	var err := config.load(SETTINGS_PATH)
	
	# Si el archivo no existe usamos los settings por default.
	if err == ERR_FILE_NOT_FOUND:
		return
	if err != OK:
		push_error("SettingsManager: Error al cargar settings: " + error_string(err))
		return
	
	music_volume = config.get_value(SECTION, "music_volume", DEFAULT_MUSIC_VOLUME)
	voice_volume = config.get_value(SECTION, "voice_volume", DEFAULT_VOICE_VOLUME)
	sfx_volume = config.get_value(SECTION, "sfx_volume", DEFAULT_SFX_VOLUME)


# ===== HELPERS =====

# Aplica los volúmenes cargados al AudioServer al iniciar el juego.
func _apply_to_audio_server() -> void:
	_set_bus_volume(BUS_MUSIC,  music_volume)
	_set_bus_volume(BUS_VOICES, voice_volume)
	_set_bus_volume(BUS_SFX, sfx_volume)

# Convierte los valores 0.0-1.0 a dB y los aplica al bus indicado (0 es el máximo y -80 silencio).
# Si el valor es 0.0 mutea el bus directamente para evitar ruido residual.
func _set_bus_volume(bus_name: String, linear_value: float) -> void:
	var bus_idx := AudioServer.get_bus_index(bus_name)
	if bus_idx == -1:
		push_warning("SettingsManager: Bus de audio no encontrado: " + bus_name)
		return
	
	if linear_value <= 0.0:
		AudioServer.set_bus_mute(bus_idx, true)
	else:
		AudioServer.set_bus_mute(bus_idx, false)
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(linear_value))
