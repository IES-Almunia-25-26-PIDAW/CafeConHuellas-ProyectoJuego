extends Node2D

# ComputerScene: Escena del ordenador donde se pueden gestionar los 3 distintos tabs
# Se deben atender a todas las mascotas para continuar con el juego

signal computer_shutdown

@onready var pets_btn: Button = %PetsBtn
@onready var mail_btn: Button = %MailBtn
@onready var clues_btn: Button = %CluesBtn

@onready var pets_tab: Control = %PetsTab
@onready var mail_tab: Control = %MailTab
@onready var clues_tab: Control = %CluesTab

@onready var shutdown_btn: TextureButton = %ShutdownButton

# La escena a la que volver al apagar el ordenador
@export var next_scene: String = "res://scenes/cafe_client_zone.tscn"


func _ready() -> void:
	SceneManager.transition_in()
	
	# Conexión de los botones con sus métodos
	pets_btn.pressed.connect(_on_tab_pressed.bind("pets"))
	mail_btn.pressed.connect(_on_tab_pressed.bind("mail"))
	clues_btn.pressed.connect(_on_tab_pressed.bind("clues"))
	shutdown_btn.pressed.connect(_on_shutdown_pressed)
	
	# El botón de apagar empieza desactivado hasta que todas las mascotas estén atendias
	shutdown_btn.disabled = true
	
	# Conexión de la señal del tab de mascotas para saber cuando están atendidas
	pets_tab.all_pets_happy.connect(_on_all_pets_happy)
	
	# Abrimos en el tab de mascotas por defecto
	_on_tab_pressed("pets")

func _on_tab_pressed(tab: String) -> void:
	pets_tab.visible = tab == "pets"
	mail_tab.visible = tab == "mail"
	clues_tab.visible = tab == "clues"
	
	pets_btn.modulate = Color.WHITE if tab == "pets" else Color(0.6, 0.6, 0.6, 1.0)
	mail_btn.modulate = Color.WHITE if tab == "mail" else Color(0.6, 0.6, 0.6, 1.0)
	clues_btn.modulate = Color.WHITE if tab == "clues" else Color(0.6, 0.6, 0.6, 1.0)
	
	# Recargamos el mail cada vez que se abre para los cambios según las adopciones recientes
	if tab == "mail":
		mail_tab.refresh()

# Si se atienden a todas las mascotas se activa el botón de apagar
func _on_all_pets_happy() -> void:
	shutdown_btn.disabled = false

# Cambiar de escena cuando se le de click al botón
func _on_shutdown_pressed() -> void:
	SceneManager.transition_out_completed.connect(
		func(): SceneManager.change_scene(next_scene), CONNECT_ONE_SHOT)
	SceneManager.transition_out()
