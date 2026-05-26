## Visor a pantalla completa para mostrar una ilustración del álbum.
## Está oculto por defecto en AlbumScreen y se activa al hacer clic en una tarjeta desbloqueada.
## Se cierra con el botón de cerrar o con la acción "ui_cancel" (Escape).
extends Control


# ===== SEÑALES =====

## Se emite cuando el visor se cierra completamente.
signal viewer_closed


# ===== REFERENCIAS A NODOS =====

@onready var cg_texture: TextureRect = %CGImage
@onready var cg_title: RichTextLabel = %ImageTitle
@onready var cg_description: RichTextLabel = %ImageDescription
@onready var close_button: Button = %CloseButton


# ===== CICLO DE VIDA =====

# Oculta al principio el visor.
func _ready() -> void:
	visible = false
	close_button.pressed.connect(_on_close)
	
	# Filtros del mouse para que permita hacer click en el botón de cerrar y cerrar la vista.
	cg_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cg_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cg_description.mouse_filter = Control.MOUSE_FILTER_IGNORE


# ===== PUBLIC API =====

## Muestra el visor con los datos de la ilustración indicada.
## [param cg_id] ID del CG, usado como fallback si no hay título en cg_data.
## [param cg_data] Diccionario con los datos del CG (de DataLoader.get_cg()).
func show_cg(cg_id: String, cg_data: Dictionary) -> void:
	# Busca y carga la textura si la encuentra.
	var texture_path: String = cg_data.get("texture", "")
	if texture_path != "":
		var texture: Texture2D = load(texture_path)
		if texture:
			cg_texture.texture = texture
		else:
			push_warning("CgViewer: No se pudo cargar la textura: " + texture_path)
	
	# Agrega el título y descripción si los encuentra
	cg_title.text = cg_data.get("title", cg_id)
	cg_description.text = cg_data.get("description", "")
	visible = true


# ===== INTERACCIONES =====

# Captura un input que no ha sido consumido por otros nodos.
func _unhandled_input(event: InputEvent) -> void:
	# Si el visor está abierto y se le da al botón de cerrar, se cierra el visor.
	if visible and event.is_action_pressed("ui_cancel"):
		_on_close()

# Función que vuelve oculto el visor y emite la señal.
func _on_close() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_callback(func() -> void:
		visible = false
		modulate.a = 1.0  # resetear para la próxima apertura.
		viewer_closed.emit()
	)
