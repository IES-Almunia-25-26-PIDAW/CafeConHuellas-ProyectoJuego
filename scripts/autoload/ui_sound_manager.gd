## Autoload singleton que gestiona los efectos de sonido de la interfaz de usuario.
## Usa players temporales para permitir polifonía: los clics rápidos no se cortan entre sí.
## [br]
## Uso:
##   UiSoundManager.play_menu_click()
##   UiSoundManager.play_pc_click()
extends Node

# ===== SONIDOS =====

# Ruta al sonido de clic del menú.
const MENU_CLICK: AudioStream = preload("res://assets/audio/sfx/ui/click_menu2.ogg")

# Ruta al sonido de clic exclusivo de la escena del PC.
const PC_CLICK: AudioStream = preload("res://assets/audio/sfx/ui/click_pc1.ogg")


# ===== INICIALIZACIÓN =====

var _player: AudioStreamPlayer

func _ready() -> void:
	# Creamos el AudioStreamPlayer en código para no necesitar una escena .tscn extra.
	# Lo asignamos al bus "SFX" para que respete el volumen configurado por el jugador en SettingsManager.
	_player = AudioStreamPlayer.new()
	_player.bus = "SFX"
	add_child(_player)




# ===== PUBLIC API =====

## Reproduce el sonido de clic del menú.
## Usado en title_screen.gd y pause_menu.gd.
func play_menu_click() -> void:
	# Creamos un player temporal para permitir polifonía:
	# si el jugador hace clic rápido en varios botones, los sonidos no se cortan entre sí.
	var temp_player := AudioStreamPlayer.new()
	temp_player.stream = MENU_CLICK
	temp_player.bus = "SFX"
	add_child(temp_player)
	temp_player.play()
	# Cuando el sonido termina, el nodo se elimina automáticamente para no acumular memoria.
	temp_player.finished.connect(temp_player.queue_free)


## Reproduce el sonido de clic exclusivo de la escena del PC.
## Usado en computer_scene.gd, pets_tab.gd, mail_tab.gd y action_popup.gd.
## Centralizado aquí para que cambiar el sonido solo requiera modificar este archivo.
func play_pc_click() -> void:
	# Creamos un player temporal para permitir polifonía:
	# si el jugador hace clic rápido en varios botones, los sonidos no se cortan entre sí.
	var temp_player := AudioStreamPlayer.new()
	temp_player.stream = PC_CLICK
	temp_player.bus = "SFX"
	add_child(temp_player)
	temp_player.play()
	# Cuando el sonido termina, el nodo se elimina automáticamente para no acumular memoria.
	temp_player.finished.connect(temp_player.queue_free)
