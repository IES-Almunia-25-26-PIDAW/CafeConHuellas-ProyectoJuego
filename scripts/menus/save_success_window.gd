extends PanelContainer

# SaveSuccessWindow: Ventana que confirma que los datos se han guardado correctamente

signal continue_pressed

@onready var continue_btn: Button = %ContinueButton


func _ready() -> void:
	continue_btn.pressed.connect(_on_continue)
	continue_btn.pressed.connect(UiSoundManager.play_menu_click)

func _on_continue() -> void:
	continue_pressed.emit()
	hide()
