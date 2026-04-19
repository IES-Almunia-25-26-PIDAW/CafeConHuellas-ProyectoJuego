extends Control

# CGViewer: Visor de CG a pantalla completa
# Está en AlbumScreen oculto por defecto y se activa cuando el usuario le da click a una ilustración

# Señal que se emite cuando el viewer se cierra
signal viewer_closed

@export var cg_texture: TextureRect
@export var cg_title: RichTextLabel
@export var cg_description: RichTextLabel
@onready var close_button: Button = %CloseButton

# Oculta al principio el visor
func _ready() -> void:
	visible = false
	close_button.pressed.connect(_on_close)

# Muestra el visor con los datos de una ilustración concreta, se llama desde AlbumScreen al hacer click en una tarjeta
func show_cg(cg_id: String, cg_data: Dictionary) -> void:
	# Busca y carga la textura si la encuentra
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

# Captura un input que no ha sido consumido por otros nodos
func _unhandled_input(event: InputEvent) -> void:
	# Si el visor está abierto y se le da al botón de cerrar, se cierra el visor
	if visible and event.is_action_pressed("ui_cancel"):
		_on_close()

# Función que vuelve oculto el visor y emite la señal
func _on_close() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_callback(func() -> void:
		visible = false
		modulate.a = 1.0  # resetear para la próxima apertura
		viewer_closed.emit()
	)
