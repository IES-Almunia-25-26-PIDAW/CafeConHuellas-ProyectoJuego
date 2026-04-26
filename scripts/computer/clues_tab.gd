extends Control

# CluesTab: Tab donde se puede ver la información de los personajes que el jugador conoce y las pistas obtenidas

const CharacterIcon: PackedScene = preload("res://scenes/computer/character_icon.tscn")
const ClueCard: PackedScene = preload("res://scenes/computer/clue_card.tscn")

@onready var character_grid: GridContainer = %CharactersGrid
@onready var clues_grid: VBoxContainer = %CluesGrid
@onready var character_details: Control = %CharacterDetail
 

func _ready() -> void:
	character_details.hide()
	_populate_characters()
	_populate_clues()

# Agrega los personajes conocidos al grid
func _populate_characters() -> void:
	for child in character_grid.get_children():
		child.queue_free()
	
	var all_characters: Dictionary = DataLoader.get_all_characters()
	
	# Ordenamos por el campo id del JSON
	var sorted_ids: Array = all_characters.keys()
	sorted_ids.sort_custom(func(a, b):
		return all_characters[a].get("id", 0) < all_characters[b].get("id", 0)
	)
	
	for char_id in sorted_ids:
		# Solo mostramos los personajes que el jugador ha conocido
		if not GameState.characters_met.has(char_id):
			continue
		
		var char_data: Dictionary = all_characters[char_id]
		var icon: Control = CharacterIcon.instantiate()
		character_grid.add_child(icon)
		icon.setup(char_id, char_data)
		icon.icon_clicked.connect(_on_character_clicked.bind(char_id, char_data))

# Agrega las pistas obtenidas al grid
func _populate_clues() -> void:
	for child in clues_grid.get_children():
		child.queue_free()
	
	var has_clues: bool = false
	
	# Cogemos las pistas que ha encontrado el jugador y las agregamos con ClueCard
	for clue_id in GameState.clues_found:
		var clue: Dictionary = DataLoader.get_clue(clue_id)
		if clue.is_empty():
			continue
		
		has_clues = true
		var card: PanelContainer = ClueCard.instantiate()
		clues_grid.add_child(card)
		card.setup(clue_id, clue)

# Se llama cuando se hace click en el icono de un personaje para mostrar sus detalles
func _on_character_clicked(char_id: String, char_data: Dictionary) -> void:
	character_details.show_character(char_id, char_data)
	character_details.show()
