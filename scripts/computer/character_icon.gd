extends PanelContainer

# CharacterIcon: Icono clickable de un personaje al que al darle se mostrará su información completa

# Emite esta señal cuando se le hace click
signal icon_clicked

@onready var icon_rect: TextureRect = %Icon

@export var default_icon: Texture2D

var _char_id: String = ""
var _char_data: Dictionary = {}


# Coloca el icono con el icono indicado en los datos del pj
func setup(char_id: String, char_data: Dictionary) -> void:
	_char_id = char_id
	_char_data = char_data
	
	var icon_path: String = char_data.get("icon", "")
	if icon_path != "" and ResourceLoader.exists(icon_path):
		icon_rect.texture = load(icon_path)
	else:
		icon_rect.texture = default_icon
		
# Función que se realiza cuando se hace click
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		icon_clicked.emit()
