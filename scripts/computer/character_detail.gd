## Panel que muestra la información detallada de un personaje.
## Se abre al hacer clic en el icono de un personaje en la pestaña de personajes del PC.
extends PanelContainer


# ===== REFERENCIAS A NODOS =====

@onready var close_btn: Button = %CloseButton
@onready var char_icon: TextureRect = %CharIcon
@onready var name_label: RichTextLabel = %NameLabel
@onready var desc_label: RichTextLabel = %DescLabel
@onready var age_label: RichTextLabel = %AgeLabel
@onready var occupation_label: RichTextLabel = %OccupationLabel
@onready var personality_label: RichTextLabel = %PersonalityLabel
@onready var likes_label: RichTextLabel = %LikesLabel
@onready var dislikes_label: RichTextLabel = %DislikesLabel


# ===== CICLO DE VIDA =====

func _ready() -> void:
	close_btn.pressed.connect(hide)
	
	# Sonido al cerrar el detalle de un personaje.
	close_btn.pressed.connect(UiSoundManager.play_pc_click)


# ===== PUBLIC API =====

## Rellena el panel con los datos del personaje indicado y lo muestra.
## [param char_id] ID del personaje, usado como fallback si no hay nombre en data.
## [param data] Diccionario con los datos del personaje (de DataLoader.get_character()).
func show_character(char_id: String, data: Dictionary) -> void:
	# Icono del personaje.
	var icon_path: String = data.get("icon", "")
	if icon_path != "" and ResourceLoader.exists(icon_path):
		char_icon.texture = load(icon_path)
	
	# Resto de labels.
	name_label.text = data.get("name", char_id)
	desc_label.text = data.get("description", "")
	age_label.text = "Edad: " + data.get("age", "")
	occupation_label.text = "Ocupación: " + data.get("occupation", "")
	personality_label.text = "Personalidad: " + data.get("personality", "")
	likes_label.text = "Le gusta: " + data.get("likes", "")
	dislikes_label.text = "No le gusta: " + data.get("dislikes", "")
