extends Node2D

@onready var background = %Background
@onready var character_sprite = %ClientCharSprite
@onready var dialog_ui = %DialogUI

# Estas dos variables son lo que se actualizará cuando se cambie de escena
var transition_effect: String = "fade"
var dialog_file: String = "res://resources/story/story.json"

var dialog_index : int = 0
var dialog_lines : Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Cargamos el diálogo
	dialog_lines = load_dialog(dialog_file)
	# Señal de que la animación del texto ha acabado
	dialog_ui.text_animation_done.connect(_on_text_animation_done)
	# Señal de la opción escogida en el diálogo
	dialog_ui.choice_selected.connect(_on_choice_selected)
	
	SceneManager.transition_out_completed.connect(_on_transition_out_completed)
	SceneManager.transition_in_completed.connect(_on_transition_in_completed)
	
	# Primera línea de texto
	dialog_index = 0
	SceneManager.transition_in()

func _input(event):
	var line = dialog_lines[dialog_index]
	var has_choices = line.has("choices")
	
	if event.is_action_pressed("next_line") and not has_choices:
		if dialog_ui.animate_text:
			dialog_ui.skip_text_animation()
		else:
			if dialog_index < len(dialog_lines) - 1:
				dialog_index += 1
				process_current_line()


func process_current_line():
	if dialog_index >= dialog_lines.size() or dialog_index < 0:
		printerr("Error: dialog_index out of bounds: ", dialog_index)
		return
		
	# Extrae la línea actual
	var line = dialog_lines[dialog_index]
	
	# Mira si es el final de la escena
	if line.has("next_scene"):
		var next_scene = line["next_scene"]
		dialog_file = "res://resources/story/" + next_scene + ".json" if !next_scene.is_empty() else ""
		transition_effect = line.get("transition", "fade") # Si no se especifica una transición se usa fade
		SceneManager.transition_out(transition_effect)
		return
	
	# Mira si tiene una ubicación (location) y necesita cambiarla
	if line.has("location"):
		# Cambia el fondo
		var background_file = "res://assets/images/" + line["location"] + ".png"
		background.texture = load(background_file)
		# TODO: para la música se hace lo mismo que aquí
		# Va a la siguiente línea
		# Si la línea tiene música, la reproducimos
		if line.has("music"):
			MusicManager.play(line["music"])
		dialog_index += 1
		process_current_line()
		return
	
	# Mira si es un goto
	if line.has("goto"):
		dialog_index = get_anchor_position(line["goto"])
		process_current_line()
		return
		
	# Mira si es un anchor (no se muestra nada)
	if line.has("anchor"):
		dialog_index += 1
		process_current_line()
		return
	
	# Actualiza la expresión/animación del personaje de forma correcta. Vuelve a la default del personaje si no hay "show_character"
	if line.has("show_character"):
		var character_name = Character.get_enum_from_string(line["show_character"])
		character_sprite.change_character(character_name, false, line.get("expression", ""))
	elif line.has("speaker"):
		var character_name = Character.get_enum_from_string(line["speaker"])
		character_sprite.change_character(character_name, true, line.get("expression", ""))
	
	if line.has("choices"):
		# Muestra las opciones
		dialog_ui.display_choices(line["choices"])
	elif line.has("text"):
		# Lee la línea del diálogo
		var speaker_name = Character.get_enum_from_string(line["speaker"])
		dialog_ui.change_line(speaker_name, line["text"])
	else:
		# No hay elección ni línea de diálogo
		dialog_index += 1
		process_current_line()
		return
	
func get_anchor_position(anchor: String):
	# Encuentra el anchor con el nombre correspondiente
	for i in range(dialog_lines.size()):
		if dialog_lines[i].has("anchor") and dialog_lines[i]["anchor"] == anchor:
			return i
			
	# Si llegamos a este error es que no se ha encontrado el anchor
	printerr("Error: No se ha encontrado el anchor: ", anchor)
	return null

# Función para cargar el diálogo del JSON
func load_dialog(file_path):
	# Revisa si existe
	if not FileAccess.file_exists(file_path):
		printerr("Error: El archivo no existe: ", file_path)
		return null
		
	# Abre el archivo, si hay algún error lo devuelve
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		printerr("Error: Error al abrir el archivo: ", file_path)
		return null
	
	# Lee el contenido del archivo como texto
	var content = file.get_as_text()
	
	# Como está en JSON, se tranforma a un array de strings y se devuelve
	var json_content = JSON.parse_string(content)
	
	# Revisa si el parseo se realizó correctamente
	if json_content == null:
		printerr("Error: Fallo al parsear el JSON del archivo: ", file_path)
		return null
	
	return json_content

func _on_text_animation_done():
	character_sprite.play_idle_animation()

func _on_choice_selected(anchor: String):
	dialog_index = get_anchor_position(anchor)
	process_current_line()

func _on_transition_out_completed():
	# Carga el nuevo diálogo
	if !dialog_file.is_empty():
		dialog_lines = load_dialog(dialog_file)
		dialog_index = 0
		var first_line = dialog_lines[dialog_index]
		if first_line.has("location"):
			background.texture = load("res://assets/images/" + first_line["location"] + ".png")
			# para la música también se agregaría aquí ya que se pone en la primera línea
			if first_line.has("music"):
				MusicManager.play(first_line["music"])
			dialog_index += 1
		SceneManager.transition_in(transition_effect)
	else:
		print("End")

func _on_transition_in_completed():
	# Comienza a procesar el diálogo
	process_current_line()
