## Card de una mascota que muestra su foto, nombre y botones de necesidades.
## Las necesidades se generan aleatoriamente al instanciar la card, con al menos una siempre activa.
## Se considera "feliz" cuando todas sus necesidades activas están cubiertas.
extends PanelContainer


# ===== SEÑALES =====

## Se emite cuando el jugador cubre una necesidad de la mascota.
signal need_fulfilled
## Se emite cuando el jugador pulsa un botón de necesidad, para mostrar el ActionPopup.
signal action_requested(need: String)


# ===== REFERENCIAS A NODOS =====

@onready var photo_pet: TextureRect = %PetPhoto
@onready var name_label: RichTextLabel = %PetName
@onready var gender_icon: TextureRect = %GenderIcon
@onready var btn_food: TextureButton = %BtnFood
@onready var btn_bath: TextureButton = %BtnBath
@onready var btn_love: TextureButton = %BtnLove


# ===== VARIABLES =====

# Texturas de género.
@export var icon_male: Texture2D
@export var icon_female: Texture2D

# Necesidades activas de la mascota individual.
var _needs: Dictionary = {"food": false, "bath": false, "love": false}
# Necesidades ya cubiertas por el jugador.
var _fulfilled: Dictionary = {"food": false, "bath": false, "love": false}
var _animal_id: String = ""


# ===== PUBLIC API =====

## Devuelve el ID de la mascota que representa esta card.
func get_animal_id() -> String:
	return _animal_id

## Configura la card con los datos de la mascota indicada.
## Genera las necesidades aleatorias y conecta los botones.
## [param animal_id] ID de la mascota.
## [param data] Diccionario con los datos de la mascota (de DataLoader.get_animal()).
func setup(animal_id: String, data: Dictionary) -> void:
	_animal_id = animal_id
	
	# Foto
	var photo_path: String = data.get("image_path", "")
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
	
	# Necesidades aleatorias, al menos una siempre activa para que haya algo que hacer.
	_needs["food"] = randf() > 0.4
	_needs["bath"] = randf() > 0.4
	_needs["love"] = randf() > 0.4
	if not _needs["food"] and not _needs["bath"] and not _needs["love"]:
		_needs["food"] = true
	
	_update_buttons()
	
	btn_food.pressed.connect(_on_btn_pressed.bind("food"))
	btn_bath.pressed.connect(_on_btn_pressed.bind("bath"))
	btn_love.pressed.connect(_on_btn_pressed.bind("love"))
	
	# Sonido de clic para los botones de necesidades de la mascota
	btn_food.pressed.connect(UiSoundManager.play_pc_click)
	btn_bath.pressed.connect(UiSoundManager.play_pc_click)
	btn_love.pressed.connect(UiSoundManager.play_pc_click)

## Devuelve true si todas las necesidades activas de la mascota están cubiertas.
func is_happy() -> bool:
	for need in _needs:
		if _needs[need] and not _fulfilled[need]:
			return false
	return true


# ===== LÓGICA INTERNA =====

# Actualiza el estado disabled de cada botón según las necesidades activas y cubiertas.
func _update_buttons() -> void:
	# Los botones se desactivan si la mascota tiene no esa necesidad o está cubierta
	btn_food.disabled = !_needs["food"] or _fulfilled["food"]
	btn_bath.disabled = !_needs["bath"] or _fulfilled["bath"]
	btn_love.disabled = !_needs["love"] or _fulfilled["love"]

# Marca la necesidad como cubierta y notifica a la card padre.
func _on_btn_pressed(need: String) -> void:
	if not _needs[need] or _fulfilled[need]:
		return
	
	_fulfilled[need] = true
	_update_buttons()
	action_requested.emit(need)
	need_fulfilled.emit()
