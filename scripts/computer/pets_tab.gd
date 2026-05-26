## Pestaña del PC que muestra las mascotas que el jugador tiene en casa y sus necesidades.
## El jugador debe atender a todas las mascotas para que se active el botón de apagado.
## Emite all_pets_happy cuando todas las necesidades están cubiertas.
extends Control


# ===== SEÑALES =====

## Se emite cuando todas las mascotas tienen sus necesidades cubiertas.
signal all_pets_happy
## Se emite cuando una mascota solicita mostrar el popup de acción.
signal show_action_popup(need: String)


# ===== ESCENAS =====

const PetCard: PackedScene = preload("res://scenes/computer/pet_card.tscn")


# ===== REFERENCIAS A NODOS =====

@onready var cards_container: GridContainer = %CardsContainer


# ===== CICLO DE VIDA =====

func _ready() -> void:
	#populate()
	pass


# ===== PUBLIC API =====

## Limpia y rellena el grid con las mascotas actuales del GameState.
## Debe llamarse desde computer_scene después de inicializar los datos.
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

## Elimina la card de una mascota que ha sido adoptada y comprueba el estado general.
## [param animal_id] ID de la mascota cuya card debe eliminarse.
func remove_pet_card(animal_id: String) -> void:
	for card in cards_container.get_children():
		if card.get_animal_id() == animal_id:
			card.queue_free()
			break
	_check_all_happy()


# ===== LÓGICA INTERNA =====


# Se llama cada vez que una mascota tiene una necesidad cubierta.
func _on_need_fulfilled() -> void:
	_check_all_happy()

# Comprueba si todas las mascotas están felices y emite all_pets_happy si es así.
# Si no hay mascotas en casa, se considera que la condición se cumple directamente.
func _check_all_happy() -> void:
	# Si no hay mascotas en casa, el botón se activa directamente.
	if GameState.animals_athome.is_empty():
		all_pets_happy.emit()
		return
	
	for card in cards_container.get_children():
		if not card.is_happy():
			return
	# Cuando todas estén felices, se emite la señal.
	all_pets_happy.emit()
