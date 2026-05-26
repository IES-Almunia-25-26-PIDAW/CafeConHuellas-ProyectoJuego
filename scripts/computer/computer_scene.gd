## Escena del ordenador donde el jugador gestiona sus mascotas, correos y pistas.
## El jugador debe atender a todas las mascotas antes de poder apagar el ordenador y continuar.
## Contiene tres pestañas: Mascotas, Correo y Pistas.
extends Node2D


# ===== SEÑALES =====

## Se emite cuando el jugador apaga el ordenador y la transición de salida comienza.
signal computer_shutdown


# ===== REFERENCIAS A NODOS =====

@onready var pets_btn: Button = %PetsBtn
@onready var mail_btn: Button = %MailBtn
@onready var clues_btn: Button = %CluesBtn

@onready var pets_tab: Control = %PetsTab
@onready var mail_tab: Control = %MailTab
@onready var clues_tab: Control = %CluesTab

@onready var shutdown_btn: TextureButton = %ShutdownButton

@onready var cafe_lbl: Label = %CafeLbl
@onready var status_lbl: Label = %StatusLabel

@onready var mail_viewer: Control = %MailViewer


# ===== VARIABLES =====

# La escena a la que volver al apagar el ordenador.
@export var next_scene: String = "res://scenes/cafe_client_zone.tscn"

# ActionPopup
const ActionPopup: PackedScene = preload("res://scenes/computer/action_popup.tscn")
var _action_popup_instance: Control = null


# ===== CICLO DE VIDA =====

func _ready() -> void:
	# TODO: BORRAR, para datos de prueba
	_setup_test_data()
	
	
	MusicManager.play("npc_theme_bajo")
	SceneManager.transition_in()
	
	# Conexión de los botones con sus métodos.
	pets_btn.pressed.connect(_on_tab_pressed.bind("pets"))
	mail_btn.pressed.connect(_on_tab_pressed.bind("mail"))
	clues_btn.pressed.connect(_on_tab_pressed.bind("clues"))
	shutdown_btn.pressed.connect(_on_shutdown_pressed)
	# El botón de apagar empieza desactivado hasta que todas las mascotas estén atendidas.
	shutdown_btn.disabled = true
	
	# Sonido de clic para los botones de navegación de tabs y apagado.
	pets_btn.pressed.connect(UiSoundManager.play_pc_click)
	mail_btn.pressed.connect(UiSoundManager.play_pc_click)
	clues_btn.pressed.connect(UiSoundManager.play_pc_click)
	shutdown_btn.pressed.connect(UiSoundManager.play_pc_click)
	
	# -- Mascotas
	# Conexión de la señal del tab de mascotas para saber cuando están atendidas.
	pets_tab.all_pets_happy.connect(_on_all_pets_happy)
	# Conectar la señal del popup.
	pets_tab.show_action_popup.connect(func(need: String):
		_action_popup_instance.play_action(need)
	)
	
	# -- Correo
	# Gestionar adopciones.
	mail_tab.open_mail_requested.connect(_on_open_mail_requested)
	mail_tab.adoption_processed.connect(func(animal_id: String):
		pets_tab.remove_pet_card(animal_id)
		_update_status_labels()
	)
	# MailViewer
	mail_viewer.hide()
	mail_viewer.decision_made.connect(_on_mail_decision_made)
	mail_viewer.viewer_closed.connect(func():
		mail_viewer.hide()
		mail_tab.refresh()
	)
	
	# ActionPopup se instancia en código y se añade al UiCanvas para que esté por encima de todo.
	_action_popup_instance = ActionPopup.instantiate()
	$UiCanvas.add_child(_action_popup_instance)
	
	# Instanciar datos y labels.
	pets_tab.populate()
	clues_tab.populate()
	_update_status_labels()
	
	# Tab por defecto.
	_on_tab_pressed("pets")


# ===== LÓGICA INTERNA =====

# TODO: BORRAR, de prueba
func _setup_test_data() -> void:
	# Dos mascotas en casa
	GameState.animals_athome = ["mochi", "luna", "canela", "nube", "mochi", "luna"]
	
	# Dos correos recibidos hoy (day = 1), sin leer
	GameState.day = 1
	GameState.received_emails_status = {
		"email_nube": "not_read",
		"email_mochi": "not_read"
	}
	
	# Dos personajes conocidos — los IDs deben coincidir con los del JSON.
	GameState.characters_met = ["alcalde", "jasmine"]
	
	# Dos pistas encontradas — los IDs deben coincidir con los del JSON.
	GameState.clues_found = ["clue_01", "clue_02", "pista_animales", "pista_pastor","pista_ruidos", "pista_jaulas", "pista_secta"]

# Muestra la pestaña seleccionada y actualiza el color de los botones de navegación.
# Recarga el correo cada vez que se abre para reflejar adopciones recientes.
func _on_tab_pressed(tab: String) -> void:
	pets_tab.visible = tab == "pets"
	mail_tab.visible = tab == "mail"
	clues_tab.visible = tab == "clues"
	
	pets_btn.modulate = Color.WHITE if tab == "pets" else Color(0.671, 0.756, 0.829, 1.0)
	mail_btn.modulate = Color.WHITE if tab == "mail" else Color(0.671, 0.756, 0.829, 1.0)
	clues_btn.modulate = Color.WHITE if tab == "clues" else Color(0.671, 0.756, 0.829, 1.0)
	
	# Recargamos el mail cada vez que se abre para los cambios según las adopciones recientes.
	if tab == "mail":
		mail_tab.refresh()

# Activa el botón de apagado cuando todas las mascotas están atendidas.
func _on_all_pets_happy() -> void:
	shutdown_btn.disabled = false

# Abre el MailViewer con el email seleccionado.
func _on_open_mail_requested(email_id: String, email: Dictionary) -> void:
	mail_viewer.show_email(email_id, email)
	mail_viewer.show()

# Procesa la decisión de adopción: oculta el viewer y actualiza el estado.
func _on_mail_decision_made(email_id: String, accepted: bool) -> void:
	mail_viewer.hide()
	mail_tab.refresh()
	if accepted:
		var email: Dictionary = DataLoader.get_all_emails().get(email_id, {})
		var animal_id: String = email.get("animal_id", "")
		if animal_id != "":
			pets_tab.remove_pet_card(animal_id)
			_update_status_labels()

# Actualiza los labels con el nombre de la cafetería y el número de mascotas en casa.
func _update_status_labels() -> void:
	cafe_lbl.text = GameState.cafe_name + " App"
	status_lbl.text = "Día %d  •  %d mascota/s en casa" % [GameState.day, GameState.animals_athome.size()]

# Inicia la transición de salida hacia next_scene.
func _on_shutdown_pressed() -> void:
	SceneManager.transition_out_completed.connect(
		func(): SceneManager.change_scene(next_scene), CONNECT_ONE_SHOT)
	SceneManager.transition_out()
