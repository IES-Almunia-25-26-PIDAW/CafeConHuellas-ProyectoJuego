## Panel que muestra las slots de guardado disponibles para guardar o cargar una partida.
## Se abre desde PauseMenu y emite slot_picked con la slot elegida y el modo.
extends Control

# ===== SEÑALES =====

## Se emite cuando el jugador selecciona una slot.
signal slot_picked(slot: int, mode: String)
## Se emite cuando el jugador cierra el panel sin seleccionar ninguna slot.
signal window_closed


# ===== ESCENAS =====

const SlotRow: PackedScene = preload("res://scenes/menus/slot_row.tscn")


# ===== REFERENCIAS A NODOS =====

@onready var backdrop: ColorRect = %Backdrop
@onready var title_label: RichTextLabel = %TitleLabel
@onready var slots_container: VBoxContainer = %SlotsContainer
@onready var close_button: Button = %CloseButton


# ===== ESTADO INTERNO =====

# Modo activo del panel: "save" o "load"
var _mode: String = "save"


# ===== CICLO DE VIDA =====

func _ready() -> void:
	close_button.pressed.connect(func() -> void:
		backdrop.visible = false
		window_closed.emit()
		hide()
	)
	
	close_button.pressed.connect(UiSoundManager.play_menu_click)


# ===== PUBLIC API =====

## Configura y muestra el panel en el modo indicado.
## [param mode] "save" para guardar, "load" para cargar.
func open(mode: String) -> void:
	_mode = mode
	# Cambia el label según el modo.
	title_label.text = "Guardar partida" if mode == "save" else "Cargar partida"
	
	
	for child in slots_container.get_children():
		child.queue_free()
	# Rellena el slots container con las slots.
	for i in SaveManager.MAX_SLOTS:
		var row: PanelContainer = SlotRow.instantiate()
		slots_container.add_child(row)
		row.setup(i, mode)
		row.slot_selected.connect(_on_slot_selected)
	
	backdrop.visible = true
	show()


# ===== INTERACCIONES =====

# Emite slot_picked con la slot seleccionada y cierra el panel.
func _on_slot_selected(slot: int) -> void:
	slot_picked.emit(slot, _mode)
	backdrop.visible = false
	hide()
