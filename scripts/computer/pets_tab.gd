extends Control

# PetsTab: Tab de mascotas que el jugador tiene actualmente y sus cuidados
# Muestra una card por cada mascota que tiene el jugador

# Emite esta señal cuando todas las mascotas tienen sus necesidades cubiertas
signal all_pets_happy
# Señal que conecta la señal de pet_card y su acción
signal show_action_popup(need: String)

const PetCard: PackedScene = preload("res://scenes/computer/pet_card.tscn")

@onready var cards_container: GridContainer = %CardsContainer

# Rellenamos el grid con las mascotas que tenemos
func _ready() -> void:
	#populate()
	pass

func populate() -> void:
	# DEBUG:
	print("PetsTab populate, animals: ", GameState.animals_athome)
	
	for child in cards_container.get_children():
		child.queue_free()
	
	for animal_id in GameState.animals_athome:
		var animal_data: Dictionary = DataLoader.get_animal(animal_id)
		if animal_data.is_empty():
			continue
		
		var card: Control = PetCard.instantiate()
		cards_container.add_child(card)
		card.setup(animal_id, animal_data)
		card.need_fulfilled.connect(_on_need_fulfilled)
		
		# Conecta la señal del popup
		card.action_requested.connect(func(need: String):
			show_action_popup.emit(need)
		)
	
	_check_all_happy()

# Se llama cada vez que una mascota tiene una necesidad cubierta
func _on_need_fulfilled() -> void:
	_check_all_happy()

# Revisa que todas las mascotas estén felices
func _check_all_happy() -> void:
	# Si no hay mascotas en casa, el botón se activa directamente
	if GameState.animals_athome.is_empty():
		all_pets_happy.emit()
		return
	
	for card in cards_container.get_children():
		if not card.is_happy():
			return
	# Cuando todas estén felices, se emite la señal
	all_pets_happy.emit()

# Elimina la card de una mascota que ha sido adoptada
func remove_pet_card(animal_id: String) -> void:
	for card in cards_container.get_children():
		if card.get_animal_id() == animal_id:
			card.queue_free()
			break
	_check_all_happy()
