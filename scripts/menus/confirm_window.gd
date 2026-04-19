extends PanelContainer

# ConfirmWindow: Ventana de confirmación que muestra un mensaje, "Confirmar" y "Cancelar"

signal confirmed
signal cancelled

@onready var message_label: RichTextLabel = %MessageLabel
@onready var confirm_btn: Button = %ConfirmButton
@onready var cancel_btn: Button = %CancelButton

func _ready() -> void:
	# Conecta los botones cuando se les hace click con su método
	confirm_btn.pressed.connect(_on_confirm)
	cancel_btn.pressed.connect(_on_cancel)

# Configura el mensaje antes de mostrar la ventana
func setup(message: String) -> void:
	message_label.text = message

# Los métodos envían la señal de la opción presionada y ocultan la ventana
func _on_confirm() -> void:
	confirmed.emit()
	hide()

func _on_cancel() -> void:
	cancelled.emit()
	hide()
