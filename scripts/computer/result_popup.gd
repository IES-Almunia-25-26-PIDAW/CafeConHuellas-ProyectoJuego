extends Control

signal result_shown

@onready var result_label: RichTextLabel = %ResultLabel
@onready var btn_continue: Button = %BtnContinue

# Para la animación
const FADE_TIME := 0.3
var _tween: Tween

func _ready() -> void:
	visible = false
	btn_continue.pressed.connect(_on_continue)

func show_result(is_good: bool) -> void:
	if is_good:
		result_label.text = "¡Buena decisión! La mascota ha encontrado un buen hogar."
	else: 
		result_label.text = "Hmm... Quizá no fue la mejor decisión..."
	
	visible = true
	modulate.a = 0.0
	
	# Animación fade in
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, FADE_TIME)

func _on_continue() -> void:
	result_shown.emit()
	
	# Animación fade out
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 0.0, FADE_TIME)
	_tween.tween_callback(func() -> void: visible = false)
