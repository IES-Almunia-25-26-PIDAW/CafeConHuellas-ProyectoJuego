## Pantalla del álbum que muestra todas las ilustraciones del juego.
## Las desbloqueadas muestran su imagen y título, las bloqueadas un placeholder.
extends Control


# ===== REFERENCIAS A NODOS =====
@onready var grid_container: GridContainer = %GridContainer
@onready var cg_viewer: Control = %CgViewer 
@onready var back_button: Button = %BackButton
# Contador para el título del álbum (cuantas CGs hay desbloqueadas / total)
@onready var cgs_count_label: RichTextLabel = %CGsCount


# ===== CONSTANTES Y VARIABLES =====

# Preload de la escena de la tarjeta para un mejor rendimiento.
const AlbumCard: PackedScene = preload("res://scenes/album/album_card.tscn")

# Escena a cargar cuando se le da al backbutton.
var scene_to_load: String = ""


# ===== CICLO DE VIDA =====

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	cg_viewer.viewer_closed.connect(_on_viewer_closed)
	
	SceneManager.transition_out_completed.connect(_on_transition_out_completed, CONNECT_ONE_SHOT)
	SceneManager.transition_in()
	
	# Sonido al pulsar el botón de volver al menú principal.
	back_button.pressed.connect(UiSoundManager.play_menu_click)
	
	_populate()


# ===== LÓGICA INTERNA =====

# Limpia el grid y lo rellena con una tarjeta por cada CG definido en DataLoader.
# Usa GlobalSave para determinar cuáles están desbloqueadas.
func _populate() -> void:
	# Limpia tarjetas anteriores si la pantalla se recarga en la misma sesión.
	for child in grid_container.get_children():
		child.queue_free()
	
	var all_cgs: Dictionary = DataLoader.get_all_cgs()
	
	# Ordena los IDs para que siempre aparezcan en el mismo orden.
	var sorted_ids: Array = all_cgs.keys()
	sorted_ids.sort()
	
	var unlocked_count: int = 0
	
	for cg_id in sorted_ids:
		var cg_data: Dictionary = all_cgs[cg_id]
		var is_unlocked: bool = GlobalSave.has_image(cg_id)
		# Para probar
		#var is_unlocked: bool = true.
		
		if is_unlocked:
			unlocked_count += 1
		
		var card: PanelContainer = AlbumCard.instantiate()
		grid_container.add_child(card)
		
		# Configurar la tarjeta después del add_child para que los nodos hijos estén listos.
		card.setup(cg_id, cg_data, is_unlocked)
		card.card_pressed.connect(_on_card_pressed)
	
	# Actualiza el contador del label.
	if cgs_count_label:
		cgs_count_label.text = "%d / %d" % [unlocked_count, sorted_ids.size()]
	
	# Forzar ancho del grid para que se centre correctamente.
	var columns: int = grid_container.columns
	var card_width: int = 300   # ancho de cada card.
	var separation: int = grid_container.get_theme_constant("h_separation")
	var total_width: int = columns * card_width + (columns - 1) * separation
	grid_container.custom_minimum_size.x = total_width


# ===== INTERACCIONES =====

# Se llama cuando el jugador hace click en una tarjeta desbloqueada
# Abre el CgViewer con la ilustración seleccionada.
func _on_card_pressed(cg_id: String, cg_data: Dictionary) -> void:
	cg_viewer.show_cg(cg_id, cg_data)

# Se llama cuando el CgViewer se cierra, se puede agregar lógica de animaciones
func _on_viewer_closed() -> void:
	pass

# Inicia la transición de salida hacia el título.
func _on_back_pressed() -> void:
	scene_to_load = "res://scenes/title_screen.tscn"
	SceneManager.transition_out()

# Cambia a la escena almacenada en scene_to_load.
func _on_transition_out_completed() -> void:
	SceneManager.change_scene(scene_to_load)
