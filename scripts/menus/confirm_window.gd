## Ventana de confirmación genérica con botones de Confirmar y Cancelar.
## Configurable con cualquier mensaje mediante setup() antes de mostrarla.
extends PanelContainer

# ===== SEÑALES =====

## Se emite cuando el jugador confirma la acción.
signal confirmed
## Se emite cuando el jugador cancela la acción.
signal cancelled


# ===== REFERENCIAS A NODOS =====

@onready var message_label: RichTextLabel = %MessageLabel
@onready var confirm_btn: Button = %ConfirmButton
@onready var cancel_btn: Button = %CancelButton


# ===== CICLO DE VIDA =====

func _ready() -> void:
	# Conecta los botones cuando se les hace click con su método.
	confirm_btn.pressed.connect(_on_confirm)
	cancel_btn.pressed.connect(_on_cancel)
	
	# Sonido al confirmar y cancelar en el popup de salir al menú.
	confirm_btn.pressed.connect(UiSoundManager.play_menu_click)
	cancel_btn.pressed.connect(UiSoundManager.play_menu_click)


# ===== PUBLIC API =====

## Establece el mensaje a mostrar antes de hacer visible la ventana.
func setup(message: String) -> void:
	message_label.text = message


# ===== INTERACCIONES =====

# Emite confirmed y cierra la ventana.
func _on_confirm() -> void:
	confirmed.emit()
	hide()

# Emite cancelled y cierra la ventana.
func _on_cancel() -> void:
	cancelled.emit()
	hide()
