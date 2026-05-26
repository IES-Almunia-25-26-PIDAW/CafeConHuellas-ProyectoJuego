## Ventana de opciones de audio que guarda los cambios en tiempo real via SettingsManager.
## Los sliders se inicializan con los valores guardados al abrir la ventana.
extends Control


# ===== SEÑALES =====

## Se emite cuando el jugador cierra la ventana de opciones.
signal window_closed


# ===== REFERENCIAS A NODOS =====

@onready var backdrop: ColorRect = %Backdrop
@onready var music_slider: HSlider = %MusicSlider
@onready var voice_slider: HSlider = %VoicesSlider
@onready var sfx_slider: HSlider = %SFXSlider
@onready var music_label: RichTextLabel = %MusicValueLabel
@onready var voice_label: RichTextLabel = %VoicesValueLabel
@onready var sfx_label: RichTextLabel = %SFXValueLabel
@onready var close_btn: Button = %CloseButton


# ===== CICLO DE VIDA =====

func _ready() -> void:
	# Incializa los sliders con los valores guardados en SettingsManager.
	music_slider.value = SettingsManager.music_volume
	voice_slider.value = SettingsManager.voice_volume
	sfx_slider.value = SettingsManager.sfx_volume
	
	_update_value_label(music_label, SettingsManager.music_volume)
	_update_value_label(voice_label, SettingsManager.voice_volume)
	_update_value_label(sfx_label, SettingsManager.sfx_volume) 
	
	# Cuando el jugador mueve algún slider se llama al método correspondiente.
	music_slider.value_changed.connect(_on_music_slider_changed)
	voice_slider.value_changed.connect(_on_voice_slider_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)  
	# Al pulsar el botón de cerrar se llama al método para cerrar la ventana.
	close_btn.pressed.connect(_on_close)
	
	# Sonido al cerrar el popup de opciones.
	close_btn.pressed.connect(UiSoundManager.play_menu_click)


# ===== PUBLIC API =====

## Muestra la ventana con su backdrop.
func show_window() -> void:
	backdrop.visible = true
	show()


# ===== INTERACCIONES =====

# Actualiza el volumen de música en SettingsManager y refresca el label.
func _on_music_slider_changed(value: float) -> void:
	SettingsManager.set_music_volume(value)
	_update_value_label(music_label, value)

# Actualiza el volumen de voces en SettingsManager y refresca el label.
func _on_voice_slider_changed(value: float) -> void:
	SettingsManager.set_voice_volume(value)
	_update_value_label(voice_label, value)

# Actualiza el volumen de efectos en SettingsManager y refresca el label.
func _on_sfx_slider_changed(value: float) -> void:
	SettingsManager.set_sfx_volume(value)
	_update_value_label(sfx_label, value)

# Actualiza el label mostrando el valor del slider como porcentaje.
func _update_value_label(label: RichTextLabel, value: float) -> void:
	label.text = "%d%%" % roundi(value * 100)

# Oculta el backdrop, emite window_closed y cierra la ventana.
func _on_close() -> void:
	backdrop.visible = false
	window_closed.emit()
	hide()
