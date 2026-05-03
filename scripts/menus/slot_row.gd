extends PanelContainer

# SlotRow: Una instancia de un slot de guardado/cargado

signal slot_selected(slot: int)

@onready var slot_label: RichTextLabel = %SlotLabel
@onready var info_label: RichTextLabel = %InfoLabel
@onready var action_button: Button = %ActionButton

var _slot: int = 0


func setup(slot: int, mode: String) -> void:
	_slot = slot
	slot_label.text = "Slot %d" % (slot+1) # Número del slot a mostrar
	# El botón muestra la acción a realizar
	action_button.text = "Guardar" if mode == "save" else "Cargar"
	
	# Busca la información del slot
	var info: Dictionary = SaveManager.get_save_info(slot)
	if info.is_empty():
		# Si está vacía muestra en el label de info un texto de vacío
		info_label.text = "—  Vacío  —"
		# En modo cargar, no se puede cargar uno vacío
		if mode == "load":
			action_button.disabled = true
	else:
		# Si hay datos mostramos la información
		info_label.text = "Día %s  •  %s" % [int(info.get("day", "0")), _format_timestamp(info.get("timestamp", ""))]
	
	# Si se hace click sobre el botón, se envía la señal
	action_button.pressed.connect(func() -> void: slot_selected.emit(_slot))
	
	action_button.pressed.connect(UiSoundManager.play_menu_click)

# Formato de fecha "año-mes-día | hora:minutos"
func _format_timestamp(raw: String) -> String:
	if raw == "":
		return ""
	var parts: Array = raw.split("T")
	if parts.size() < 2:
		return raw
	var date: String = parts[0] # "año-mes-día"
	var time_parts: Array = parts[1].split(":")
	var time_short: String = "%s:%s" % [time_parts[0], time_parts[1]]  # "hora:minutos"
	return "%s | %s" % [date, time_short]
