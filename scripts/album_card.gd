extends PanelContainer

# AlbumCard: Tarjeta individual del álbum para mostrar un CG
# Se instancia muchas veces en la AlbumScreen para mostrar todas las CGs definidas

# Señal que se emite cuando se hace click en la tarjeta si está desbloqueada
signal card_pressed(cg_id: String, cg_data: Dictionary)

@onready var thumbnail_rect: TextureRect = %Thumbnail
@onready var title_label: RichTextLabel = %TitleLabel
@onready var lock_overlay: ColorRect = %LockBlackOverlay

# Datos internos de la tarjeta
var _cg_id: String = ""
var _cg_data: Dictionary = {}
var _is_unlocked: bool = false

func _ready():
	# Filtros del mouse para que permita hacer click en la card y propagar la signal a abrir la card presionada
	mouse_filter = Control.MOUSE_FILTER_STOP
	thumbnail_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lock_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

# Configura la tarjeta con los datos de una CG
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

# Configuración de la tarjeta si la CG está desbloqueada
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

# Configuración de la tarjeta si la CG está bloqueada
func _setup_locked() -> void:
	title_label.text = "???"
	lock_overlay.visible = true

# Bloquea la interacción si está locked, si está unlocked y se ha hecho click izquierdo se emite la señal
func _gui_input(event: InputEvent) -> void:
	if not _is_unlocked:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		card_pressed.emit(_cg_id, _cg_data)
