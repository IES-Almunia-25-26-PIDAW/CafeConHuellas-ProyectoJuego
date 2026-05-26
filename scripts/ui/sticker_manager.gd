## Nodo que instancia los stickers desbloqueados en el menú principal.
## Lee los finales conseguidos de GlobalSave y crea un Sprite2D por cada uno.
## [br]
## Uso:
##   1. Añade este script a un nodo Node en tu escena de menú principal.
##   2. En el inspector, asigna sticker_container al Node2D donde aparecerán los stickers.
##   3. Rellena ENDING_STICKERS con los IDs y rutas de los assets definitivos.
extends Node


# USO: (TODO)
#   1. Crea un nodo Node2D en tu escena de menú principal y llámalo "StickerManager".
#   2. Añade este script.
#   3. En el inspector, asigna @export sticker_container al Node2D donde quieras
#      que aparezcan los stickers (puede ser el propio canvas del menú).
#   4. Rellena ENDING_STICKERS con los IDs y rutas de tus assets reales.


# ===== VARIABLES =====
# (TODO) Asígnarlo en el inspector apuntando a un Node2D de la escena.
## Nodo donde se instanciarán los stickers. Asignar en el inspector.
@export var sticker_container: Node2D


# ===== CONSTANTES =====

# Tabla de configuración: indica qué ending activa qué sticker y en qué posición (relativa al sticker_container)
# (TODO) Añade aquí una entrada por cada final que tenga un sticker asociado.
const ENDING_STICKERS: Array[Dictionary] = [
	{
		"ending_id": "ending_bad",
		"texture":   "res://assets/stickers/sticker_bad.png",
		"position":  Vector2(80, 120),
		"scale":     Vector2(1.0, 1.0)
	},
	{
		"ending_id": "ending_hunter",
		"texture":   "res://assets/stickers/sticker_hunter.png",
		"position":  Vector2(80, 120),
		"scale":     Vector2(1.0, 1.0)
	},
	{
		"ending_id": "ending_jasmine",
		"texture":   "res://assets/stickers/sticker_jasmine.png",
		"position":  Vector2(80, 120),
		"scale":     Vector2(1.0, 1.0)
	},
	{
		"ending_id": "ending_ronald",
		"texture":   "res://assets/stickers/sticker_ronald.png",
		"position":  Vector2(80, 120),
		"scale":     Vector2(1.0, 1.0)
	},
	{
		"ending_id": "ending_nilam",
		"texture":   "res://assets/stickers/sticker_nilam.png",
		"position":  Vector2(80, 120),
		"scale":     Vector2(1.0, 1.0)
	},
	{
		"ending_id": "ending_girl",
		"texture":   "res://assets/stickers/sticker_girl.png",
		"position":  Vector2(80, 120),
		"scale":     Vector2(1.0, 1.0)
	}
 ]



# ===== CICLO DE VIDA =====

func _ready() -> void:
	if sticker_container == null:
		push_error("StickerManager: sticker_container no asignado en el inspector.")
		return
	_spawn_unlocked_stickers()


# ===== LÓGICA INTERNA =====

# Recorre todos los stickers configurados y crea un Sprite2D por cada final desbloqueado.
func _spawn_unlocked_stickers() -> void:
	for config in ENDING_STICKERS:
		var ending_id: String = config.get("ending_id", "")
		if ending_id == "" or not GlobalSave.has_ending(ending_id):
			continue
		_create_sticker(config)

# Instancia un Sprite2D con la config especificada y lo añade al sticker_container.
func _create_sticker(config: Dictionary) -> void:
	var sprite := Sprite2D.new()
	
	var tex: Texture2D = load(config["texture"])
	if tex == null:
		push_warning("StickerManager: No se pudo cargar la textura: " + config["texture"])
		return
	
	sprite.texture  = tex
	sprite.position = config.get("position", Vector2.ZERO)
	sprite.scale    = config.get("scale", Vector2.ONE)
	
	sticker_container.add_child(sprite)
