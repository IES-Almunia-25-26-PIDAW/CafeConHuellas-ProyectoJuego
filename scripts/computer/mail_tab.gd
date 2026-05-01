extends Control

# MailTab: Tab del correo donde se pueden ver los correos diarios que tratan sobre las mascotas del jugador
# Al hacer click en un correo se abre MailViewer para visualizarlo y tomar una decisión

signal adoption_processed(animal_id: String)
signal open_mail_requested(email_id: String, email: Dictionary)

const MailRow: PackedScene = preload("res://scenes/computer/mail_row.tscn")

@onready var mail_list:   VBoxContainer = %MailList
@onready var empty_label: RichTextLabel = %EmptyLabel


func _ready() -> void:
	refresh()

# Recarga la lista, se llama también desde computer_scene al cambiar a este tab
func refresh() -> void:
	for child in mail_list.get_children():
		child.queue_free()
	
	# Se obtienen todos los emails
	var all_emails: Dictionary = DataLoader.get_all_emails()
	var today: int = GameState.day
	var has_any: bool = false
	
	# Se filtran los emails para que solo se muestren según las siguientes condiciones
	for email_id in all_emails:
		var email: Dictionary = all_emails[email_id]
		
		# Solo los correos del día de hoy
		if email.get("day", -1) != today:
			continue
		
		# Solo correos sobre las mascotas que tengamos
		var animal_id: String = email.get("animal_id", "")
		if not GameState.animals_athome.has(animal_id):
			continue
		
		# Solo correos no leídos o leídos (quitamos los que ya hemos respondido)
		var status: String = GameState.received_emails_status.get(email_id, "not_read")
		if status in ["accepted_good", "accepted_bad", "declined"]:
			continue
		
		var row: Control = MailRow.instantiate()
		mail_list.add_child(row)
		row.setup(email_id, email)
		row.row_clicked.connect(func(): open_mail_requested.emit(email_id, email))
		has_any = true
	
	# Hacemos el label visible si no hay ningún correo
	empty_label.visible = not has_any
