extends Control

# RouteSelection: Se instancia cuando se indica en el guión, permite elegir una ruta de personaje

signal route_chosen(route_name: String)

# Debes tener al menos 10 de amistad con los personajes para que aparezca su ruta como elegible
const ROUTE_FRIENDSHIP: int = 10
# Personajes con ruta disponible
const ROUTE_CHARACTERS: Array[String] = ["jasmine", "ronald", "nilam", "hannah"]

@onready var routes_container: HBoxContainer = %RoutesContainer


func _ready() -> void:
	_populate_routes()

# Rellena el contenedor con las rutas elegibles
func _populate_routes() -> void:
	var any_eligible: bool = false

	for char_name in ROUTE_CHARACTERS:
		# Recoge el valor de puntos de la ruta, si no se queda en 0
		var route_value: int = GameState.get("relationship_" + char_name)
		var points: int = route_value if route_value != null else 0
		if points < ROUTE_FRIENDSHIP:
			continue
		
		# Si llega aquí es que hay una ruta elegible
		any_eligible = true
		
		# Crea un botón por cada ruta
		var btn := Button.new()
		btn.text = char_name.capitalize()
		btn.pressed.connect(_on_route_chosen.bind(char_name))
		routes_container.add_child(btn)
		
	# Botón de no elegir ruta
	var btn_none := Button.new()
	btn_none.text = "Prefiero centrarme en mí"
	btn_none.pressed.connect(_on_no_route_chosen)
	routes_container.get_parent().add_child(btn_none)

# Se llega cuando se ha elegido una ruta
func _on_route_chosen(char_name: String) -> void:
	# Desactiva todas las rutas primero
	for route in ROUTE_CHARACTERS:
		GameState.set("route_" + route, false)
	
	# Y activa solo la elegida
	GameState.set("route_" + char_name, true)
	route_chosen.emit(char_name)
	queue_free()

# Si no se elige ninguna ruta se desactivan todas
func _on_no_route_chosen() -> void:
	# Desactivar todas las rutas
	for route in ROUTE_CHARACTERS:
		GameState.set("route_" + route, false)
	route_chosen.emit("")  # string vacío para indicar que no se eligió ninguna
	queue_free()
