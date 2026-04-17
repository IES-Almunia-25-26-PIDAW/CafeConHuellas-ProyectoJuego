extends Control

# AlbumScreen: Pantalla del álbum donde se muestran todas las ilustraciones/cgs del juego
# Muestra el contenido de las desbloqueadas y una silueta para las bloqueadas

# Estructura esperada en DataLoader (cgs.json o similar):
#   {
#     "cg_jasmine_01": {
#       "title":       "Una tarde en el café",
#       "character":   "jasmine",
#       "description": "...",
#       "texture":     "res://assets/cgs/cg_jasmine_01.png",
#       "thumbnail":   "res://assets/cgs/thumbs/cg_jasmine_01_thumb.png"
#     },
#     ...
#   }

@export var grid_container: GridContainer
# Textura que se muestra en lugar de la imagen cuando está bloqueada
@export var locked_texture: Texture2D

# Función ready
func _ready() -> void:
	if grid_container == null:
		push_error("AlbumScreen: grid_container no asignado en el inspector.")
		return
	_populate_grid()

# Construye el grid con una tarjeta por cada ilustración/cg definida en DataLoader
func _populate_grid() -> void:
	var all_cgs: Dictionary = DataLoader.get_all_cgs()
	
	for cg_id in all_cgs.keys():
		var is_unlocked: bool = GlobalSave.has_image(cg_id)
		var card := _create_card(cg_id, all_cgs[cg_id], is_unlocked)
		grid_container.add_child(card)

# Crea una tarjeta para una CG (PanelContainer con Sprite o imagen bloqueada)
# Puedes sustituir esto por la instancia de una escena .tscn si prefieres tener (TODO: creo que haré esto pero por ahora pongo el codigo de ej)
# el diseño visual en el editor.
func _create_card(cg_id: String, data: Dictionary, is_unlocked: bool) -> PanelContainer:
	var card := PanelContainer.new()

	var vbox := VBoxContainer.new()
	card.add_child(vbox)

	# Imagen (thumbnail si desbloqueada, locked_texture si no)
	var texture_rect := TextureRect.new()
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	texture_rect.custom_minimum_size = Vector2(160, 120)

	if is_unlocked:
		var thumb_path: String = data.get("thumbnail", data.get("texture", ""))
		var tex: Texture2D = load(thumb_path) if thumb_path != "" else null
		if tex:
			texture_rect.texture = tex
	else:
		texture_rect.texture = locked_texture

	vbox.add_child(texture_rect)

	# Título (solo si está desbloqueada)
	var label := Label.new()
	label.text            = data.get("title", "???") if is_unlocked else "???"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode   = TextServer.AUTOWRAP_WORD
	vbox.add_child(label)

	# Al hacer clic en una tarjeta desbloqueada, muestra la imagen a pantalla completa
	if is_unlocked:
		card.gui_input.connect(func(event: InputEvent) -> void:
			if event is InputEventMouseButton and event.pressed:
				_show_fullscreen(cg_id, data)
		)

	return card

#TODO
# Muestra la CG a pantalla completa. Personaliza esta función según tu UI.
func _show_fullscreen(cg_id: String, data: Dictionary) -> void:
	# Aquí puedes instanciar una escena de visor de CG, emitir una señal,
	# o cambiar a otra pantalla pasando el cg_id como parámetro.
	# Por ejemplo, si tienes un autoload UIManager:
	# UIManager.show_cg_viewer(cg_id)
	pass
