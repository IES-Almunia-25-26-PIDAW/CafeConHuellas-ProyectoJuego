extends Control

# MailViewer: Vista de un correo, donde se puede hacer una decisión
# Emite decision_made con el ud del correo y si la aceptó o no

signal decision_made(email_id: String, accepted: bool)
signal viewer_closed


@onready var btn_close: Button = %BtnClose

@onready var sender_label: RichTextLabel = %SenderLabel
@onready var subject_label: RichTextLabel = %SubjectLabel
@onready var body_label: RichTextLabel = %BodyLabel
@onready var btn_accept: Button = %BtnAccept
@onready var btn_decline: Button = %BtnDecline
@onready var result_popup: Control = %ResultPopup

var _current_email_id: String = ""
var _current_email: Dictionary = {}


func _ready() -> void:
	btn_accept.pressed.connect(_on_accept)
	btn_decline.pressed.connect(_on_decline)
	btn_close.pressed.connect(_on_close) 

func show_email(email_id: String, email: Dictionary) -> void:
	_current_email_id = email_id
	_current_email = email
	
	# Rellena los label con la información
	sender_label.text = email.get("sender_name", "")
	subject_label.text = email.get("subject", "")
	body_label.text = email.get("body", "")
	
	# Marcar como leído solo si era not_read
	var current_status: String = GameState.received_emails_status.get(email_id, "not_read")
	if current_status == "not_read":
		GameState.received_emails_status[email_id] = "read"
	
	btn_accept.disabled = false
	btn_decline.disabled = false
	
# Cuando se acepta la petición de adopción
func _on_accept() -> void:
	btn_accept.disabled = true
	btn_decline.disabled = true
	btn_close.disabled = true
	
	var animal_id: String = _current_email.get("animal_id", "")
	var is_good: bool = _current_email.get("is_good_decision", false)
	
	# Actualizar GameState con los datos de la nueva decisión y quitando a la mascota del array
	GameState.animals_athome.erase(animal_id)
	if is_good:
		GameState.animals_adopted_good.append(animal_id)
		GameState.received_emails_status[_current_email_id] = "accepted_good"
	else:
		GameState.animals_adopted_bad.append(animal_id)
		GameState.received_emails_status[_current_email_id] = "accepted_bad"
	
	result_popup.show_result(is_good)
	await result_popup.result_shown
	decision_made.emit(_current_email_id, true)

# Cuando se rechaza
func _on_decline() -> void:
	btn_accept.disabled  = true
	btn_decline.disabled = true
	GameState.received_emails_status[_current_email_id] = "declined"
	decision_made.emit(_current_email_id, false)

# Cierra la vista, dejando el estado con el estado de "read"
func _on_close() -> void:
	viewer_closed.emit()
	hide()
