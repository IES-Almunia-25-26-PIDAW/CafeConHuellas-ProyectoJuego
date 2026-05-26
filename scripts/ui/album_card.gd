## Tarjeta individual del álbum que muestra un CG desbloqueado o un placeholder bloqueado.
## Se instancia dinámicamente en AlbumScreen para cada CG definido en el JSON.
extends PanelContainer

# ===== SEÑALES =====

## Se emite cuando el jugador hace clic en una tarjeta desbloqueada.
signal card_pressed(cg_id: String, cg_data: Dictionary)


# ===== REFERENCIAS A NODOS =====

@onready var thumbnail_rect: TextureRect = %Thumbnail
@onready var title_label: RichTextLabel = %TitleLabel
@onready var lock_overlay: ColorRect = %LockBlackOverlay


# ===== ESTADO INTERNO =====

# Datos internos de la tarjeta.
var _cg_id: String = ""
var _cg_data: Dictionary = {}
var _is_unlocked: bool = false


# ===== CICLO DE VIDA =====

func _ready():
	# Filtros del mouse para que permita hacer click en la card y propagar la signal a abrir la card presionada.
	mouse_filter = Control.MOUSE_FILTER_STOP
	thumbnail_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lock_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE


# ===== PUBLIC API =====

## Configura la tarjeta con los datos del CG indicado.
## [param cg_id] ID del CG.
## [param cg_data] Diccionario con los datos del CG (de DataLoader.get_cg()).
## [param is_unlocked] Si es true muestra la imagen, si no muestra el placeholder bloqueado.
func setup(cg_id: String, cg_data: Dictionary, is_unlocked: bool) -> void:
	_cg_id = cg_id
	_cg_data = cg_data
	_is_unlocked = is_unlocked
	
	if is_unlocked:
		_setup_unlocked(_cg_data)
	else:
		_setup_locked()
		# Para probar
		#_setup_unlocked(_cg_data)


# ===== LÓGICA INTERNA =====

# Carga la thumbnail y muestra el título del CG.
func _setup_unlocked(data: Dictionary) -> void:
	# Carga la Thumbnail, si no existe se queda sin textura
	var thumb_path: String = data.get("thumbnail", "")
	if thumb_path != "":
		var tex: Texture2D = load(thumb_path)
		if tex:
			thumbnail_rect.texture = tex
		else:
			push_warning("AlbumCard: No se pudo cargar la thumbnail: " + thumb_path)
	
	title_label.text = data.get("title", _cg_id)
	lock_overlay.visible = false

# Muestra el placeholder de tarjeta bloqueada.
func _setup_locked() -> void:
	title_label.text = "???"
	lock_overlay.visible = true

# Bloquea la interacción si está locked, si está unlocked y se ha hecho click izquierdo se emite la señal.
func _gui_input(event: InputEvent) -> void:
	if not _is_unlocked:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		card_pressed.emit(_cg_id, _cg_data)
