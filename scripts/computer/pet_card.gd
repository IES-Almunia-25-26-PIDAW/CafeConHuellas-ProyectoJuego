extends PanelContainer

# PetCard: Card de una mascota que muestra su información y botones de necesidades
# Las necesidades se activan aleatoriamente al instanciar la card

signal need_fulfilled

@onready var photo_pet: TextureRect = %PetPhoto
@onready var name_label: RichTextLabel = %PetName
@onready var gender_icon: TextureRect = %GenderIcon
@onready var btn_food: TextureButton = %BtnFood
@onready var btn_bath: TextureButton = %BtnBath
@onready var btn_love: TextureButton = %BtnLove
@onready var action_popup: Control = %ActionPopup

# Texturas de género
@export var icon_male: Texture2D
@export var icon_female: Texture2D

# Necesidades activas de la mascota individual
var _needs: Dictionary = {"food": false, "bath": false, "love": false}
var _fulfilled: Dictionary = {"food": false, "bath": false, "love": false}
var _animal_id: String = ""


func setup(animal_id: String, data: Dictionary) -> void:
	_animal_id = animal_id
	
	# Foto
	var photo_path: String = data.get("photo", "")
	if photo_path != "" and ResourceLoader.exists(photo_path):
		photo_pet.texture = load(photo_path)
	
	# Nombre
	name_label.text = data.get("name", animal_id)
	
	# Género
	var gender: String = data.get("gender", "")
	if gender == "male" and icon_male:
		gender_icon.texture = icon_male
	elif gender == "female" and icon_female:
		gender_icon.texture = icon_female
	
	# Necesidades aleatorias, al menos una siempre activa para que haya algo que hacer
	_needs["food"] = randf() > 0.4
	_needs["bath"] = randf() > 0.4
	_needs["love"] = randf() > 0.4
	if not _needs["food"] and not _needs["bath"] and not _needs["love"]:
		_needs["food"] = true
	
	_update_buttons()
	
	btn_food.pressed.connect(_on_btn_pressed.bind("food"))
	btn_bath.pressed.connect(_on_btn_pressed.bind("bath"))
	btn_love.pressed.connect(_on_btn_pressed.bind("love"))

# Manejar el estado de los botones para activarlos o desactivarlos
func _update_buttons() -> void:
	# Los botones se desactivan si la mascota tiene no esa necesidad o está cubierta
	btn_food.disabled = !_needs["food"] or _fulfilled["food"]
	btn_bath.disabled = !_needs["bath"] or _fulfilled["bath"]
	btn_love.disabled = !_needs["love"] or _fulfilled["love"]

func _on_btn_pressed(need: String) -> void:
	if not _needs[need] or _fulfilled[need]:
		return
	
	_fulfilled[need] = true
	_update_buttons()
	action_popup.play_action(need)
	need_fulfilled.emit()

# Devuelve true si todas las necesidades de la mascota están cubiertas
func is_happy() -> bool:
	for need in _needs:
		if _needs[need] and not _fulfilled[need]:
			return false
	return true
