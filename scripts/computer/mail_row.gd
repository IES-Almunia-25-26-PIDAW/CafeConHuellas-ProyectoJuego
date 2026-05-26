## Fila del listado de correos en la pestaña de correo del PC.
## Al hacer clic emite row_clicked para que MailTab abra el MailViewer con este correo.
extends PanelContainer


# ===== SEÑALES =====

## Se emite cuando el jugador hace clic en la fila.
signal row_clicked


# ===== REFERENCIAS A NODOS =====

@onready var sender_label: RichTextLabel = %SenderLabel
@onready var subject_label: RichTextLabel = %SubjectLabel
@onready var status_icon: TextureRect = %StatusIcon

@onready var click_area: Button = %ClickArea


# ===== VARIABLES =====

# Texturas para el icono de estado leído/no leído.
@export var icon_unread: Texture2D
@export var icon_read: Texture2D

var _email_id: String = ""
var _email_data: Dictionary = {}


# ===== PUBLIC API =====

## Configura la fila con los datos del email indicado.
## [param email_id] ID del email.
## [param email] Diccionario con los datos del email (de DataLoader.get_email()).
func setup(email_id: String, email: Dictionary) -> void:
	_email_id = email_id
	_email_data = email

	sender_label.text = email.get("sender_name", "")
	subject_label.text = email.get("subject", "")
	
	# Estado visual de leído o no leído.
	var status: String = GameState.received_emails_status.get(email_id, "not_read")
	_update_status_icon(status)
	
	click_area.pressed.connect(_on_clicked)


# ===== LÓGICA INTERNA =====

# Actualiza el icono del status dependiendo de si el email ha sido leido o no.
func _update_status_icon(status: String) -> void:
	if status_icon == null:
		return
	if status == "not_read" and icon_unread:
		status_icon.texture = icon_unread
	elif icon_read:
		status_icon.texture = icon_read

func _on_clicked() -> void:
	_update_status_icon("read")
	# Sonido al abrir un correo.
	UiSoundManager.play_pc_click()
	row_clicked.emit()
