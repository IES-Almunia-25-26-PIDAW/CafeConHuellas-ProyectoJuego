extends PanelContainer

# OptionsWindow: Ventana de opciones que guarda los cambios con SettingsManager

signal window_closed

@onready var music_slider: HSlider = %MusicSlider
@onready var voice_slider: HSlider = %VoicesSlider
@onready var music_label: RichTextLabel = %MusicValueLabel
@onready var voice_label: RichTextLabel = %VoicesValueLabel
@onready var close_btn: Button = %CloseButton


func _ready() -> void:
	# Incializa los sliders con los valores guardados en SettingsManager
	music_slider.value = SettingsManager.music_volume
	voice_slider.value = SettingsManager.voice_volume
	_update_value_label(music_label, SettingsManager.music_volume)
	_update_value_label(voice_label, SettingsManager.voice_volume)
	
	# Cuando el jugador mueve algún slider se llama al método correspondiente
	music_slider.value_changed.connect(_on_music_slider_changed)
	voice_slider.value_changed.connect(_on_voice_slider_changed)
	# Al pulsar el botón de cerrar se llama al método para cerrar la ventana
	close_btn.pressed.connect(_on_close)

# Cuando se cambia el volumen de la música se pasa el nuevo valor al SettingsManager para que se guarde
func _on_music_slider_changed(value: float) -> void:
	SettingsManager.set_music_volume(value)
	_update_value_label(music_label, value)

# Cuando se cambia el volumen de las voces se pasa el nuevo valor al SettingsManager para que se guarde
func _on_voice_slider_changed(value: float) -> void:
	SettingsManager.set_voice_volume(value)
	_update_value_label(voice_label, value)

# Se actualiza el label
func _update_value_label(label: RichTextLabel, value: float) -> void:
	label.text = "%d%%" % roundi(value * 100)

# Cierra la ventana
func _on_close() -> void:
	window_closed.emit()
	hide()
