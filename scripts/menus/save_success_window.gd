## Ventana que confirma al jugador que la partida se ha guardado correctamente.
## Se abre desde PauseMenu tras un guardado exitoso.
extends Control

# ===== SEÑALES =====

## Se emite cuando el jugador pulsa continuar.
signal closed


# ===== REFERENCIAS A NODOS =====

@onready var backdrop: ColorRect = %Backdrop
@onready var continue_btn: Button = %ContinueButton


# ===== CICLO DE VIDA =====

func _ready() -> void:
	visible = false
	continue_btn.pressed.connect(_on_continue)
	continue_btn.pressed.connect(UiSoundManager.play_menu_click)


# ===== PUBLIC API =====

## Muestra la ventana con su backdrop.
func show_success() -> void:
	backdrop.visible = true
	visible = true


# ===== INTERACCIONES =====

# Oculta la ventana y emite closed para que PauseMenu continúe.
func _on_continue() -> void:
	backdrop.visible = false
	visible = false
	closed.emit()
