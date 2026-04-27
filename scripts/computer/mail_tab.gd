extends Control

# MailTab: Tab del correo donde se pueden ver los correos diarios que tratan sobre las mascotas del jugador
# Al hacer click en un correo se abre MailViewer para visualizarlo y tomar una decisión

signal adoption_processed

const MailRow: PackedScene = preload("res://scenes/computer/mail_row.tscn")

@onready var mail_list:   VBoxContainer = %MailList
@onready var mail_viewer: Control = %MailViewer
@onready var empty_label: RichTextLabel = %EmptyLabel


func _ready() -> void:
	mail_viewer.hide()
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
		row.row_clicked.connect(_on_row_clicked.bind(email_id, email))
		has_any = true
	
	# Hacemos el label visible si no hay ningún correo
	empty_label.visible = not has_any

# Se muestra el email del que el jugador ha hecho click
func _on_row_clicked(email_id: String, email: Dictionary) -> void:
	mail_viewer.show_email(email_id, email)
	mail_viewer.show()
	# Se escucha la decisión
	if not mail_viewer.decision_made.is_connected(_on_decision_made):
		mail_viewer.decision_made.connect(_on_decision_made)
	
	# Para el cierre sin decisión
	if not mail_viewer.viewer_closed.is_connected(_on_viewer_closed):
		mail_viewer.viewer_closed.connect(_on_viewer_closed)

# Cuando se haga una decisión, se esconde la ventana de MailViewer y se refresca para actualizar los cambios
func _on_decision_made(_email_id: String, _accepted: bool) -> void:
	mail_viewer.hide()
	refresh()  # Actualizamos la lista tras la decisión
	adoption_processed.emit()

# Al cerrar sin decidir solo refrescamos el icono de leído
func _on_viewer_closed() -> void:
	refresh()
