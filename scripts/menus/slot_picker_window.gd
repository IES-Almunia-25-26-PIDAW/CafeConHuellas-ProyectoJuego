extends PanelContainer

# SlotPickerWindow: Panel que se abre al querer realizar una acción de guardar/cargar y muestra las slots disponibles

# Emite la slot elegida y el modo save o load
signal slot_picked(slot: int, mode: String)
signal window_closed

const SlotRow: PackedScene = preload("res://scenes/menus/slot_row.tscn")

@onready var title_label: RichTextLabel = %TitleLabel
@onready var slots_container: VBoxContainer = %SlotsContainer
@onready var close_button: Button = %CloseButton

# Modo del menú, save o load
var _mode: String = "save"


func _ready() -> void:
	close_button.pressed.connect(func() -> void:
		window_closed.emit()
		hide()
	)

# Configura y muestra la ventana según el modo en el que se haya abierto
func open(mode: String) -> void:
	_mode = mode
	# Cambia el label según el modo
	title_label.text = "Guardar partida" if mode == "save" else "Cargar partida"
	
	
	for child in slots_container.get_children():
		child.queue_free()
	# Rellena el slots container con las slots
	for i in SaveManager.MAX_SLOTS:
		var row: PanelContainer = SlotRow.instantiate()
		slots_container.add_child(row)
		row.setup(i, mode)
		row.slot_selected.connect(_on_slot_selected)
	
	show()

func _on_slot_selected(slot: int) -> void:
	slot_picked.emit(slot, _mode)
	hide()
