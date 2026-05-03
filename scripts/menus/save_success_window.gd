extends Control

# SaveSuccessWindow: Ventana que confirma que los datos se han guardado correctamente

signal closed

@onready var backdrop: ColorRect = %Backdrop
@onready var continue_btn: Button = %ContinueButton


func _ready() -> void:
	visible = false
	continue_btn.pressed.connect(_on_continue)
	continue_btn.pressed.connect(UiSoundManager.play_menu_click)

func show_success() -> void:
	backdrop.visible = true
	visible = true

func _on_continue() -> void:
	backdrop.visible = false
	visible = false
	closed.emit()
