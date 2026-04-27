extends PanelContainer

# ClueCard: Card de cada pista encontrada por el jugador colocada en el grid

@onready var clue_icon: TextureRect = %ClueIcon
@onready var title_label: RichTextLabel = %TitleLabel
@onready var description_label: RichTextLabel = %DescriptionLabel

# Icono por defecto si la pista no tiene uno
@export var default_icon: Texture2D


func setup(clue_id: String, clue_data: Dictionary) -> void:
	title_label.text = clue_data.get("title", clue_id)
	description_label.text  = clue_data.get("description", "")

	# Icono de la pista
	var icon_path: String = clue_data.get("icon", "")
	if icon_path != "" and ResourceLoader.exists(icon_path):
		clue_icon.texture = load(icon_path)
	elif default_icon:
		clue_icon.texture = default_icon
	else:
		clue_icon.visible = false
