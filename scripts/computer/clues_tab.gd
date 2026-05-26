## Pestaña del PC que muestra los personajes conocidos y las pistas obtenidas por el jugador.
## Los personajes se muestran como iconos clickables que abren su ficha de detalle.
## Las pistas se muestran como tarjetas con su información.
extends Control


# ===== ESCENAS =====

const CharacterIcon: PackedScene = preload("res://scenes/computer/character_icon.tscn")
const ClueCard: PackedScene = preload("res://scenes/computer/clue_card.tscn")


# ===== REFERENCIAS A NODOS =====

@onready var character_grid: GridContainer = %CharactersGrid
@onready var clues_grid: VBoxContainer = %CluesGrid
@onready var character_details: Control = %CharacterDetail
 

# ===== CICLO DE VIDA =====

func _ready() -> void:
	character_details.hide()


# ===== PUBLIC API =====

## Rellena la pestaña con los personajes conocidos y pistas encontradas del GameState actual.
## Debe llamarse cada vez que se abre el PC para reflejar el progreso actualizado.
func populate() -> void:
	_populate_characters()
	_populate_clues()


# ===== LÓGICA INTERNA =====

# Limpia y rellena el grid de personajes con los que el jugador ha conocido.
func _populate_characters() -> void:
	# DEBUG
	print("CluesTab: characters_met = ", GameState.characters_met)
	print("CluesTab: clues_found = ", GameState.clues_found)
	
	for child in character_grid.get_children():
		child.queue_free()
	
	var all_characters: Dictionary = DataLoader.get_all_characters()
	
	# Ordenamos por el campo id del JSON para mostrarlos siempre en el mismo orden.
	var sorted_ids: Array = all_characters.keys()
	sorted_ids.sort_custom(func(a, b):
		return all_characters[a].get("id", 0) < all_characters[b].get("id", 0)
	)
	
	for char_id in sorted_ids:
		# Solo mostramos los personajes que el jugador ha conocido.
		if not GameState.characters_met.has(char_id):
			continue
		
		var char_data: Dictionary = all_characters[char_id]
		var icon: Control = CharacterIcon.instantiate()
		character_grid.add_child(icon)
		icon.setup(char_id, char_data)
		icon.icon_clicked.connect(_on_character_clicked.bind(char_id, char_data))

# Limpia y rellena el grid de pistas con las que el jugador ha encontrado.
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

# Muestra el panel de detalle del personaje seleccionado.
func _on_character_clicked(char_id: String, char_data: Dictionary) -> void:
	character_details.show_character(char_id, char_data)
	character_details.show()
