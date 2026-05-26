## Popup que muestra el resultado de una decisión de adopción.
## Aparece con fade tras aceptar un correo y se cierra al pulsar continuar.
extends Control


# ===== SEÑALES =====

## Se emite cuando el jugador pulsa continuar tras ver el resultado.
signal result_shown


# ===== REFERENCIAS A NODOS =====

@onready var backdrop: ColorRect = %Backdrop
@onready var result_label: RichTextLabel = %ResultLabel
@onready var btn_continue: Button = %BtnContinue


# ===== CONSTANTES =====

# Para la animación.
const FADE_TIME := 0.3


# ===== ESTADO INTERNO =====

var _tween: Tween


# ===== CICLO DE VIDA =====

func _ready() -> void:
	visible = false
	btn_continue.pressed.connect(_on_continue)
	
	# Sonido al continuar tras el resultado de la adopción.
	btn_continue.pressed.connect(UiSoundManager.play_pc_click)


# ===== PUBLIC API =====

## Muestra el popup con el mensaje correspondiente al resultado de la adopción.
## [param is_good] true si fue una buena decisión, false si no.
func show_result(is_good: bool) -> void:
	backdrop.visible = true
	
	if is_good:
		result_label.text = "¡Buena decisión! La mascota ha encontrado un buen hogar."
	else: 
		result_label.text = "Hmm... Quizá no fue la mejor decisión..."
	
	visible = true
	modulate.a = 0.0
	
	# Animación fade in
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, FADE_TIME)


# ===== INTERACCIONES =====

# Oculta el popup con fade y emite result_shown para que MailViewer continúe.
func _on_continue() -> void:
	backdrop.visible = false
	result_shown.emit()
	
	# Animación fade out.
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 0.0, FADE_TIME)
	_tween.tween_callback(func() -> void: visible = false)
