## Escena principal de diálogo donde transcurre la historia del juego.
## Procesa las líneas del JSON de diálogo una a una y gestiona todos los comandos:
## ubicaciones, música, personajes, elecciones, rutas, pistas, mascotas, órdenes y transiciones.
extends Node2D


# ===== REFERENCIAS A NODOS =====

@onready var background = %Background
@onready var character_sprite = %ClientCharSprite
@onready var dialog_ui = %DialogUI
@onready var counter_layer: CanvasLayer = %CounterCanvas
@onready var sfx_player: AudioStreamPlayer = %SFXPlayer


# ===== ESTADO INTERNO =====

# Efecto de transición a usar al cambiar de escena.
var transition_effect: String = "fade"
# Ruta al archivo JSON de diálogo activo.
var dialog_file: String = ""

var dialog_index : int = 0
var dialog_lines : Array = []


# ===== CICLO DE VIDA =====

func _ready() -> void:
	# Aseguramos que el juego no esté pausado al entrar.
	get_tree().paused = false
	
	dialog_file = "res://resources/story/" + GameState.chapter_id + ".json"
	# Cargamos el diálogo.
	dialog_lines = load_dialog(dialog_file)
	# Señal de que la animación del texto ha acabado.
	dialog_ui.text_animation_done.connect(_on_text_animation_done)
	# Señal de la opción escogida en el diálogo.
	dialog_ui.choice_selected.connect(_on_choice_selected)
	
	SceneManager.transition_out_completed.connect(_on_transition_out_completed)
	SceneManager.transition_in_completed.connect(_on_transition_in_completed)
	
	# Restaurar el índice guardado si venimos de una carga.
	dialog_index = GameState.dialogue_index
	# Restaurar el fondo y música correctos.
	if dialog_index > 0:
		_restore_scene_state()
	
	dialog_ui.modulate.a = 0.0
	SceneManager.transition_in()


# Avanza la línea al pulsar "next_line", o salta la animación de texto si está en curso.
# No procesa input si el juego está pausado o la línea actual tiene elecciones.
func _input(event) -> void:
	# No procesar input del diálogo si el juego está pausado.
	if get_tree().paused:
		return
		
	# Protección: si no hay líneas cargadas o el índice está fuera de rango se ignora
	if dialog_lines == null or dialog_index >= dialog_lines.size():
		return
	
	var line = dialog_lines[dialog_index]
	var has_choices = line.has("choices")
	
	if event.is_action_pressed("next_line") and not has_choices:
		if dialog_ui.animate_text:
			dialog_ui.skip_text_animation()
		else:
			if dialog_index < len(dialog_lines) - 1:
				dialog_index += 1
				GameState.dialogue_index = dialog_index
				process_current_line()


# ===== PROCESADO DE DIÁLOGO =====

# Procesa la línea actual del JSON según su tipo de comando.
# Los comandos sin texto (location, goto, anchor, etc.) avanzan automáticamente al siguiente.
func process_current_line() -> void:
	if dialog_index >= dialog_lines.size() or dialog_index < 0:
		printerr("Error: dialog_index out of bounds: ", dialog_index)
		return
		
	# Extrae la línea actual.
	var line = dialog_lines[dialog_index]
	
	# -- Inicio del día: Video entrada + escena a la que ir.
	if line.has("video_day_start"):
		GameState.day = int(line.get("day", GameState.day))
		var chapter: String = line["video_day_start"]
		GameState.chapter_id = chapter
		#GameState.dialogue_index = 0 - si es un nuevo capítulo el índice se pone a 0
		_play_video_transition("res://scenes/cafe_client_zone.tscn", true, "open")
		return
	
	# -- Fin del día: Vídeo de salida + escena a la que ir.
	if line.has("video_day_end"):
		_play_video_transition("res://scenes/cafe_client_zone.tscn", false, "closed")
		return
	
	# -- Guardar el capítulo siguiente para después del ordenador.
	if line.has("next_chapter"):
		GameState.chapter_id = line["next_chapter"]
		GameState.dialogue_index = 0 # resetear el index siempre al cambiar el capítulo
		dialog_index += 1
		process_current_line()
		return
	
	# -- Cambio de escena.
	if line.has("next_scene"):
		var next_scene = line["next_scene"]
		dialog_file = "res://resources/story/" + next_scene + ".json" if !next_scene.is_empty() else ""
		transition_effect = line.get("transition", "fade") # Si no se especifica una transición se usa fade
		SceneManager.transition_out(transition_effect)
		return
	
	# -- Cambio de ubicación + música.
	if line.has("location"):
		# Cambia el fondo.
		var background_file = "res://assets/images/" + line["location"] + ".png"
		background.texture = load(background_file)
		dialog_index += 1
		process_current_line()
		return
	
	# -- Mostrador a mostrar cuando se encuentra en la cafetería
	if line.has("counter"):
		counter_layer.visible = line["counter"] == "yes"
		dialog_index += 1
		process_current_line()
		return
		
	# -- Música a reproducir
	if line.has("music"):
		MusicManager.play(line["music"])
		dialog_index += 1
		process_current_line()
		return
	
	# -- Sonido a reproducir
	if line.has("sound"):
		var sound_path: String = "res://assets/audio/sfx/" + line["sound"] + ".ogg"
		if ResourceLoader.exists(sound_path):
			sfx_player.stream = load(sound_path)
			sfx_player.play()
		dialog_index += 1
		process_current_line()
		return
	
	# -- Goto.
	if line.has("goto"):
		dialog_index = get_anchor_position(line["goto"])
		process_current_line()
		return
		
	# -- Anchor
	if line.has("anchor"):
		dialog_index += 1
		process_current_line()
		return
	
	# -- Goto condicional por ruta (salta al anchor solo si el jugador está en esa ruta).
	if line.has("if_route"):
		var route_name: String = line["if_route"]
		var in_route: bool = GameState.get("route_" + route_name)
		if in_route:
			dialog_index = get_anchor_position(line["goto"])
		else:
			dialog_index += 1
		process_current_line()
		return
		
	# -- Ocultar al sprite del personaje de la escena.
	if line.has("hide_character"):
		var tween = create_tween()
		tween.tween_property(character_sprite, "modulate:a", 0.0, 0.3)
		await tween.finished
		
		dialog_index += 1
		process_current_line()
		return
	
	# -- Conocer a un personaje.
	if line.has("meet_character"):
		var char_id: String = line["meet_character"]
		if not GameState.characters_met.has(char_id):
			GameState.characters_met.append(char_id)
		dialog_index += 1
		process_current_line()
		return
		
	# -- Añadir puntos de relación.
	if line.has("add_relationship"):
		var rel_data: Dictionary = line["add_relationship"]
		var char_name: String = rel_data.get("character", "")
		var amount: int = int(rel_data.get("amount", 0))
		var key: String = "relationship_" + char_name
		if char_name != "" and key in GameState:
			GameState.set(key, GameState.get(key) + amount)
		dialog_index += 1
		process_current_line()
		return
	
	# -- Elección de la ruta a tomar.
	if line.has("choose_route"):
		var route_ui := preload("res://scenes/route_selection.tscn").instantiate()
		get_tree().current_scene.add_child(route_ui)
		route_ui.route_chosen.connect(_on_route_chosen, CONNECT_ONE_SHOT)
		# El diálogo se detiene hasta que el jugador elija.
		return
	
	# -- Variable por si Hannah está desbloqueada.
	if line.has("if_hannah_unlocked"):
		if GlobalSave.hannah_unlocked:
			dialog_index = get_anchor_position(line["goto"])
		else:
			dialog_index += 1
		process_current_line()
		return
	
	# -- Añadir pista.
	if line.has("add_clue"):
		var clue_id: String = line["add_clue"]
		if not GameState.clues_found.has(clue_id):
			GameState.clues_found.append(clue_id)
		dialog_index += 1
		process_current_line()
		return
	
	# -- Añadir mascota.
	if line.has("add_pet"):
		var pet_id: String = line["add_pet"]
		if GameState.animals_athome.size() < 6 and not GameState.animals_athome.has(pet_id):
			GameState.animals_athome.append(pet_id)
		dialog_index += 1
		process_current_line()
		return
	
	# -- Cambio de día.
	if line.has("change_day"):
		GameState.day = int(line["change_day"])
		dialog_index += 1
		process_current_line()
		return
	
	# -- Guardar una variable temporal de elección para usarla después de un start_order.
	if line.has("set_var"):
		GameState.set(line["set_var"]["key"], line["set_var"]["value"])
		dialog_index += 1
		process_current_line()
		return

	# -- Goto condicional por variable temporal (bifurca el diálogo según last_choice u otras vars).
	if line.has("if_var"):
		var key = line["if_var"]["key"]
		var value = line["if_var"]["value"]
		if GameState.get(key) == value:
			dialog_index = get_anchor_position(line["goto"])
		else:
			dialog_index += 1
		process_current_line()
		return
	
	# -- Iniciar una orden y enviar al jugador a la cocina.
	if line.has("start_order"):
		GameState.current_order_recipe_ids.assign(line["start_order"])
		# Guardamos el JSON al que volver después de completar la orden.
		var return_scene: String = line.get("next_scene_after_order", "")
		if return_scene != "":
			# Lo guardamos en GameState para que sepa a donde volver desde la cocina.
			GameState.chapter_id = return_scene
			# Y ponemos el index a 0 para que comience desde el inicio del nuevo json
			GameState.dialogue_index = 0
		SceneManager.transition_out_completed.connect(
			func(): SceneManager.change_scene("res://scenes/kitchen/cafe_kitchen_scene.tscn"),
			CONNECT_ONE_SHOT
		)
		SceneManager.transition_out()
		return
	
	# -- Texto con pronombres.
	# Si existe "pronouns", usa el texto correcto según los pronombres del GameState.
	if line.has("pronouns"):
		var pronoun_texts: Dictionary = line["pronouns"]
		var resolved_text: String = ""
		match GameState.player_pronouns:
			0: resolved_text = pronoun_texts.get("male", "")
			1: resolved_text = pronoun_texts.get("female", "")
			2: resolved_text = pronoun_texts.get("nonbinary", "")
		# Inyectamos el texto resuelto como si fuera una línea normal.
		var resolved_line: Dictionary = line.duplicate()
		resolved_line["text"] = resolved_text
		_process_dialogue_line(resolved_line)
		return
	
	# -- Personaje y expresión
	# Actualiza la expresión/animación del personaje de forma correcta. Vuelve a la default del personaje si no hay "show_character"
	if line.has("show_character"):
		var character_name = Character.get_enum_from_string(line["show_character"])
		character_sprite.change_character(character_name, false, line.get("expression", ""))
	elif line.has("speaker"):
		var character_name = Character.get_enum_from_string(line["speaker"])
		# Hunter no tiene sprite visual
		if character_name != Character.Name.HUNTER:
			character_sprite.change_character(character_name, true, line.get("expression", ""))
	
	# -- Elecciones o texto
	if line.has("choices"):
		# Muestra las opciones.
		dialog_ui.display_choices(line["choices"])
	elif line.has("text"):
		# Lee la línea del diálogo.
		var speaker_name = Character.get_enum_from_string(line["speaker"])
		var resolved_text: String = _resolve_text(line["text"])
		dialog_ui.change_line(speaker_name, resolved_text)
	else:
		# No hay elección ni línea de diálogo.
		dialog_index += 1
		process_current_line()


# ===== HELPERS =====

# Restaura el fondo y música correctos buscando hacia atrás desde el índice actual.
func _restore_scene_state() -> void:
	var found_location: bool = false
	var found_music: bool = false
	var found_counter: bool = false
	
	# Busca hacia atrás desde el índice actual la última línea con location.
	for i in range(dialog_index - 1, -1, -1):
		var line: Dictionary = dialog_lines[i]
		
		# Restaura el fondo
		if not found_location and line.has("location"):
			var background_file = "res://assets/images/" + line["location"] + ".png"
			background.texture = load(background_file)
			found_location = true
		
		# Restaura la música
		if not found_music and line.has("music"):
			MusicManager.play(line["music"])
			found_music = true
		
		# Restaura el mostrador
		if not found_counter and line.has("counter"):
			counter_layer.visible = line["counter"] == "yes"
			found_counter = true
		
		# Parar cuando se hayan encontrado los tres
		if found_location and found_music and found_counter:
			break


# Lanza la transición de vídeo hacia next_scene.
func _play_video_transition(next_scene: String, show_day: bool, animation: String = "open") -> void:
	SceneManager.pending_video_next_scene = next_scene
	SceneManager.pending_video_show_day = show_day
	SceneManager.pending_video_animation = animation
	SceneManager.transition_out_completed.connect(
		func(): SceneManager.change_scene("res://scenes/video_transition.tscn"), CONNECT_ONE_SHOT
	)
	SceneManager.transition_out()

# Sustituye las variables {player_name} y {cafe_name} en el texto por los valores del GameState.
func _resolve_text(text: String) -> String:
	text = text.replace("{player_name}", GameState.player_name)
	text = text.replace("{cafe_name}", GameState.cafe_name)
	return text

# Procesa una línea de diálogo con pronombres ya resueltos.
func _process_dialogue_line(line: Dictionary) -> void:
	if line.has("show_character"):
		var character_name = Character.get_enum_from_string(line["show_character"])
		character_sprite.change_character(character_name, false, line.get("expression", ""))
	elif line.has("speaker"):
		var character_name = Character.get_enum_from_string(line["speaker"])
		# Hunter no tiene sprite visual
		if character_name != Character.Name.HUNTER:
			character_sprite.change_character(character_name, true, line.get("expression", ""))
	
	if line.has("text"):
		var speaker_name = Character.get_enum_from_string(line["speaker"])
		dialog_ui.change_line(speaker_name, _resolve_text(line["text"]))

# Busca y devuelve el índice de un anchor por nombre.
func get_anchor_position(anchor: String):
	# Encuentra el anchor con el nombre correspondiente.
	for i in range(dialog_lines.size()):
		if dialog_lines[i].has("anchor") and dialog_lines[i]["anchor"] == anchor:
			return i
			
	# Si llegamos a este error es que no se ha encontrado el anchor.
	printerr("Error: No se ha encontrado el anchor: ", anchor)
	return null


# Carga y parsea el archivo JSON de diálogo. Devuelve null si falla.
func load_dialog(file_path):
	# Revisa si existe
	if not FileAccess.file_exists(file_path):
		printerr("Error: El archivo no existe: ", file_path)
		return null
		
	# Abre el archivo, si hay algún error lo devuelve.
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		printerr("Error: Error al abrir el archivo: ", file_path)
		return null
	
	# Lee el contenido del archivo como texto.
	var content = file.get_as_text()
	
	# Como está en JSON, se tranforma a un array de strings y se devuelve.
	var json_content = JSON.parse_string(content)
	
	# Revisa si el parseo se realizó correctamente.
	if json_content == null:
		printerr("Error: Fallo al parsear el JSON del archivo: ", file_path)
		return null
	
	return json_content


# ===== SEÑALES =====

# Vuelve al sprite idle cuando la animación de texto termina.
func _on_text_animation_done() -> void:
	character_sprite.play_idle_animation()

# Salta al anchor de la opción elegida y continúa el diálogo.
func _on_choice_selected(anchor: String) -> void:
	dialog_index = get_anchor_position(anchor)
	process_current_line()

# Continúa el diálogo tras elegir una ruta.
func _on_route_chosen(_route_name: String) -> void:
	dialog_index += 1
	process_current_line()

# Carga el nuevo diálogo al completar la transición de salida.
# Si no hay archivo de diálogo, vuelve al menú principal.
func _on_transition_out_completed() -> void:
	# Carga el nuevo diálogo
	if !dialog_file.is_empty():
		dialog_lines = load_dialog(dialog_file)
		dialog_index = 0
		var first_line = dialog_lines[dialog_index]
		if first_line.has("location"):
			background.texture = load("res://assets/images/" + first_line["location"] + ".png")
			# para la música también se agregaría aquí ya que se pone en la primera línea.
			if first_line.has("music"):
				MusicManager.play(first_line["music"])
			dialog_index += 1
		SceneManager.transition_in(transition_effect)
	else:
		# Si no hay nada más de diálogo, devuelve al menú principal.
		MusicManager.stop()
		await get_tree().create_timer(1.5).timeout
		SceneManager.change_scene("res://scenes/title_screen.tscn")
		
# Comienza a procesar el diálogo tras completar la transición de entrada.
func _on_transition_in_completed() -> void:
	# Crea una animación para mostrar la escena
	var tween := create_tween()
	tween.tween_property(dialog_ui, "modulate:a", 1.0, 0.3)
	await tween.finished
	# Comienza a procesar el diálogo.
	process_current_line()
