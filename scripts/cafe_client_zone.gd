extends Node2D

@onready var character_sprite = %ClientCharSprite
@onready var dialog_ui = %DialogUI

var dialog_index : int = 0

var dialog_lines : Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Cargamos el diálogo
	dialog_lines = load_dialog("res://resources/story/story.json")
	# Señal de que la animación del texto ha acabado
	dialog_ui.text_animation_done.connect(_on_text_animation_done)
	# Primera línea de texto
	dialog_index = 0
	process_current_line()

func _input(event):
	if event.is_action_pressed("next_line"):
		if dialog_ui.animate_text:
			dialog_ui.skip_text_animation()
		else:
			if dialog_index < len(dialog_lines) - 1:
				dialog_index += 1
				process_current_line()


func process_current_line():
	var line = dialog_lines[dialog_index]
	
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
	
	if line.has("choices"):
		# Muestra las opciones
		dialog_ui.display_choices(line["choices"])
	else:
		# Lee la línea del diálogo
		var character_name = Character.get_enum_from_string(line["speaker"])
		dialog_ui.change_line(character_name, line["text"])
		character_sprite.change_character(character_name)
	
func get_anchor_position(anchor: String):
	# Encuentra el anchor con el nombre correspondiente
	for i in range(dialog_lines.size()):
		if dialog_lines[i].has("anchor") and dialog_lines[i]["anchor"] == anchor:
			return 1
			
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
