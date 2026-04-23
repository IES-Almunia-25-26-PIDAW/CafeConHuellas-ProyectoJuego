extends Node

# UiSoundManager: Autoload global que gestiona los SFX de la interfaz de usuario (Menu inicio y menu de configuración)
# Sigue el mismo patrón que MusicManager y SettingsManager.
# Uso desde cualquier script: UiSoundManager.play_menu_click()

# Ruta al sonido de clic del menú
# TODO: hay que modificarla para cuando tengamos el sonido real elegido
const MENU_CLICK: AudioStream = preload("res://assets/audio/sfx/ui/click_menu.ogg")

var _player: AudioStreamPlayer

func _ready() -> void:
	# Creamos el AudioStreamPlayer en código para no necesitar una escena .tscn extra
	# Lo asignamos al bus "SFX" para que respete el volumen configurado por el jugador en SettingsManager
	_player = AudioStreamPlayer.new()
	_player.bus = "SFX"
	add_child(_player)

# Reproduce el sonido de clic del menú.
# Se llama desde title_screen.gd y pause_menu.gd al conectar los botones.
func play_menu_click() -> void:
	# Creamos un player temporal para permitir polifonía:
	# si el jugador hace clic rápido en varios botones, los sonidos no se cortan entre sí
	var temp_player := AudioStreamPlayer.new()
	temp_player.stream = MENU_CLICK
	temp_player.bus = "SFX"
	add_child(temp_player)
	temp_player.play()
	# Cuando el sonido termina, el nodo se elimina automáticamente para no acumular memoria
	temp_player.finished.connect(temp_player.queue_free)
