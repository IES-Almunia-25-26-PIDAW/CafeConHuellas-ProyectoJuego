## Vista de un correo de adopción donde el jugador puede aceptar o rechazar la solicitud.
## Emite decision_made cuando el jugador toma una decisión, viewer_closed cuando cierra sin decidir.
extends Control


# ===== SEÑALES =====

## Se emite cuando el jugador acepta o rechaza la adopción.
## [param accepted] true si aceptó, false si rechazó.
signal decision_made(email_id: String, accepted: bool)
## Se emite cuando el jugador cierra el viewer sin tomar una decisión.
signal viewer_closed


# ===== REFERENCIAS A NODOS =====

@onready var backdrop: ColorRect = %Backdrop
@onready var btn_close: Button = %BtnClose
@onready var sender_label: RichTextLabel = %SenderLabel
@onready var subject_label: RichTextLabel = %SubjectLabel
@onready var body_label: RichTextLabel = %BodyLabel
@onready var btn_accept: Button = %BtnAccept
@onready var btn_decline: Button = %BtnDecline
@onready var result_popup: Control = %ResultPopup


# ===== ESTADO INTERNO =====

var _current_email_id: String = ""
var _current_email: Dictionary = {}


# ===== CICLO DE VIDA =====

func _ready() -> void:
	btn_accept.pressed.connect(_on_accept)
	btn_decline.pressed.connect(_on_decline)
	btn_close.pressed.connect(_on_close) 
	
	# Sonido de clic para los botones de decisión y cierre.
	btn_accept.pressed.connect(UiSoundManager.play_pc_click)
	btn_decline.pressed.connect(UiSoundManager.play_pc_click)
	btn_close.pressed.connect(UiSoundManager.play_pc_click)
	
	result_popup.result_shown.connect(_on_result_shown)


# ===== PUBLIC API =====

## Rellena el viewer con los datos del email y lo prepara para mostrarse.
## Marca el email como leído si era not_read.
## [param email_id] ID del email.
## [param email] Diccionario con los datos del email (de DataLoader.get_email()).
func show_email(email_id: String, email: Dictionary) -> void:
	_current_email_id = email_id
	_current_email = email
	
	# Rellena los label con la información.
	sender_label.text = email.get("sender_name", "")
	subject_label.text = email.get("subject", "")
	body_label.text = email.get("body", "")
	
	# Marcar como leído solo si era not_read
	var current_status: String = GameState.received_emails_status.get(email_id, "not_read")
	if current_status == "not_read":
		GameState.received_emails_status[email_id] = "read"
	
	# Mostrar backdrop para bloquear todo lo exterior a mailviewer.
	backdrop.visible = true
	result_popup.hide()


# ===== INTERACCIONES =====

# El jugador acepta la adopción: actualiza GameState y muestra el resultado.
func _on_accept() -> void:
	var animal_id: String = _current_email.get("animal_id", "")
	var is_good: bool = _current_email.get("is_good_decision", false)
	
	# Actualizar GameState con los datos de la nueva decisión y quitando a la mascota del array.
	GameState.animals_athome.erase(animal_id)
	if is_good:
		GameState.animals_adopted_good.append(animal_id)
		GameState.received_emails_status[_current_email_id] = "accepted_good"
	else:
		GameState.animals_adopted_bad.append(animal_id)
		GameState.received_emails_status[_current_email_id] = "accepted_bad"
	
	# Ocultar el backdrop del viewer antes de mostrar el resultpopup.
	backdrop.visible = false
	result_popup.show_result(is_good)

# Se llama cuando el result_popup termina de mostrarse.
func _on_result_shown() -> void:
	decision_made.emit(_current_email_id, true)

# El jugador rechaza la adopción: actualiza el estado y cierra el viewer.
func _on_decline() -> void:
	backdrop.visible = false
	GameState.received_emails_status[_current_email_id] = "declined"
	decision_made.emit(_current_email_id, false)

# Cierra el viewer sin tomar decisión, dejando el email como "read".
func _on_close() -> void:
	backdrop.visible = false
	viewer_closed.emit()
	hide()
