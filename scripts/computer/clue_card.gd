## Tarjeta que muestra la información de una pista encontrada por el jugador.
## Se instancia dinámicamente en el grid de pistas de CluesTab.
extends PanelContainer


# ===== REFERENCIAS A NODOS =====

@onready var clue_icon: TextureRect = %ClueIcon
@onready var title_label: RichTextLabel = %TitleLabel
@onready var description_label: RichTextLabel = %DescriptionLabel


# ===== VARIABLES =====

# Icono por defecto si la pista no tiene uno asignado.
@export var default_icon: Texture2D


# ===== PUBLIC API =====

## Rellena la tarjeta con los datos de la pista indicada.
## [param clue_id] ID de la pista, usado como fallback si no hay título en clue_data.
## [param clue_data] Diccionario con los datos de la pista (de DataLoader.get_clue()).
func setup(clue_id: String, clue_data: Dictionary) -> void:
	title_label.text = clue_data.get("title", clue_id)
	description_label.text  = clue_data.get("description", "")

	# Icono de la pista.
	var icon_path: String = clue_data.get("icon", "")
	if icon_path != "" and ResourceLoader.exists(icon_path):
		clue_icon.texture = load(icon_path)
	elif default_icon:
		clue_icon.texture = default_icon
	else:
		# Si no hay icono ni fallback, se oculta el nodo para no dejar espacio vacío
		clue_icon.visible = false
