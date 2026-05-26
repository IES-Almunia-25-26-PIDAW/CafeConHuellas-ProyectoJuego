## Icono clickable de un personaje en la pestaña de personajes del PC.
## Al hacer clic emite icon_clicked para que la escena padre abra el CharacterDetail.
extends PanelContainer


# ===== SEÑALES =====

## Se emite cuando el jugador hace clic en el icono.
signal icon_clicked


# ===== REFERENCIAS A NODOS =====

@onready var icon_rect: TextureRect = %Icon


# ===== VARIABLES =====

@export var default_icon: Texture2D

var _char_id: String = ""
var _char_data: Dictionary = {}


# ===== PUBLIC API =====

## Configura el icono con los datos del personaje indicado.
## [param char_id] ID del personaje.
## [param char_data] Diccionario con los datos del personaje (de DataLoader.get_character()).
func setup(char_id: String, char_data: Dictionary) -> void:
	_char_id = char_id
	_char_data = char_data
	
	var icon_path: String = char_data.get("icon", "")
	if icon_path != "" and ResourceLoader.exists(icon_path):
		icon_rect.texture = load(icon_path)
	else:
		icon_rect.texture = default_icon


# ===== INTERACCIONES =====

# Función que se realiza cuando se hace click.
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Sonido al hacer click en el icono de un personaje.
		UiSoundManager.play_pc_click()
		icon_clicked.emit()
