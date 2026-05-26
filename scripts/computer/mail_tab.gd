## Pestaña del correo en la escena del PC.
## Muestra los correos del día actual sobre las mascotas del jugador.
## Los correos ya respondidos no se muestran para mantener la lista limpia.
extends Control


# ===== SEÑALES =====

## Se emite cuando el jugador acepta o rechaza una adopción desde el MailViewer.
signal adoption_processed(animal_id: String)
## Se emite cuando el jugador hace clic en un correo para abrirlo en el MailViewer.
signal open_mail_requested(email_id: String, email: Dictionary)


# ===== ESCENAS =====

const MailRow: PackedScene = preload("res://scenes/computer/mail_row.tscn")


# ===== REFERENCIAS A NODOS =====

@onready var mail_list:   VBoxContainer = %MailList
@onready var empty_label: RichTextLabel = %EmptyLabel


# ===== CICLO DE VIDA =====

func _ready() -> void:
	refresh()


# ===== PUBLIC API =====

## Recarga la lista de correos según el estado actual del GameState.
## Se llama en _ready() y cada vez que el jugador abre esta pestaña.
func refresh() -> void:
	for child in mail_list.get_children():
		child.queue_free()
	
	# Se obtienen todos los emails.
	var all_emails: Dictionary = DataLoader.get_all_emails()
	var today: int = GameState.day
	var has_any: bool = false
	
	# Se filtran los emails para que solo se muestren según las siguientes condiciones.
	for email_id in all_emails:
		var email: Dictionary = all_emails[email_id]
		
		# Solo los correos del día de hoy.
		if email.get("day", -1) != today:
			continue
		
		# Solo correos sobre las mascotas que tengamos.
		var animal_id: String = email.get("animal_id", "")
		if not GameState.animals_athome.has(animal_id):
			continue
		
		# Solo correos no leídos o leídos (quitamos los que ya hemos respondido).
		var status: String = GameState.received_emails_status.get(email_id, "not_read")
		if status in ["accepted_good", "accepted_bad", "declined"]:
			continue
		
		var row: Control = MailRow.instantiate()
		mail_list.add_child(row)
		row.setup(email_id, email)
		row.row_clicked.connect(func(): open_mail_requested.emit(email_id, email))
		has_any = true
	
	# Si no hay correos pendientes se muestra el label de bandeja vacía.
	empty_label.visible = not has_any
