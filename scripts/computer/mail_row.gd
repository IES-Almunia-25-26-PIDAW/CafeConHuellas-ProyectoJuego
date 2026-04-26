extends PanelContainer

# MailRow: Es la fila de correo donde se puede hacer click para mostrar el correo en grande

signal row_clicked

@onready var sender_label: RichTextLabel = %StatusIcon
@onready var subject_label: RichTextLabel = %SubjectLabel
@onready var status_icon: TextureRect = %SenderLabel

# Texturas del status
@export var icon_unread: Texture2D
@export var icon_read: Texture2D

var _email_id: String = ""
var _email_data: Dictionary = {}

# Setup donde se coloca el icono y los datos del email
func setup(email_id: String, email: Dictionary) -> void:
	_email_id = email_id
	_email_data = email

	sender_label.text = email.get("sender_name", "")
	subject_label.text = email.get("subject", "")
	
	# Estado visual de leído o no leído
	var status: String = GameState.received_emails_status.get(email_id, "not_read")
	_update_status_icon(status)

# Actualiza el icono del status dependiendo de si el email ha sido leido o no
func _update_status_icon(status: String) -> void:
	if status == "not_read":
		status_icon.texture = icon_unread
	else:
		status_icon.texture = icon_read

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Marcamos el email como leído y mandamos la señal de que se ha hecho click en este email
		_update_status_icon("read")
		row_clicked.emit()
