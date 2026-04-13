extends Node

# Referencia a la base de datos
var db: SQLite

# Ruta donde se guarda la BD del jugador (user:// permite escritura)
const DB_PATH := "user://pawcafe.db"

func _ready():
	db = SQLite.new()
	db.path = DB_PATH
	db.foreign_keys = true  # Activar claves foráneas
	db.open_db()
	_create_tables()
	print("Base de datos PawCafé inicializada correctamente.")

# ============================================================
# CREACIÓN DE TABLAS
# ============================================================

func _create_tables():
	# 1. Partida del jugador
	db.query("CREATE TABLE IF NOT EXISTS game_save (
		id INTEGER PRIMARY KEY DEFAULT 1,
		player_name TEXT NOT NULL,
		pronoun TEXT NOT NULL CHECK (pronoun IN ('Sr', 'Sra', 'Sre')),
		cafe_name TEXT NOT NULL,
		current_day INTEGER NOT NULL DEFAULT 1,
		created_at TEXT DEFAULT (datetime('now')),
		CHECK (current_day BETWEEN 1 AND 15)
	);")

	# 2. Lugares
	db.query("CREATE TABLE IF NOT EXISTS locations (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		name TEXT NOT NULL UNIQUE,
		description TEXT
	);")

	# 3. Personajes
	db.query("CREATE TABLE IF NOT EXISTS characters (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		name TEXT NOT NULL,
		role TEXT NOT NULL,
		age INTEGER,
		birthdate TEXT,
		description TEXT,
		personality TEXT,
		likes TEXT,
		dislikes TEXT,
		has_friendship_route INTEGER NOT NULL DEFAULT 0,
		image_path TEXT
	);")

	# 4. Amistad
	db.query("CREATE TABLE IF NOT EXISTS friendship (
		character_id INTEGER PRIMARY KEY,
		level INTEGER NOT NULL DEFAULT 0,
		FOREIGN KEY (character_id) REFERENCES characters(id)
	);")

	# 5. Recetas
	db.query("CREATE TABLE IF NOT EXISTS recipes (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		name TEXT NOT NULL,
		category TEXT NOT NULL CHECK (category IN ('cafe', 'smoothie', 'tarta', 'galleta')),
		description TEXT,
		preparation_steps TEXT,
		image_path TEXT
	);")

	# 6. Ingredientes
	db.query("CREATE TABLE IF NOT EXISTS recipe_ingredients (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		recipe_id INTEGER NOT NULL,
		ingredient_name TEXT NOT NULL,
		quantity TEXT,
		image_path TEXT,
		FOREIGN KEY (recipe_id) REFERENCES recipes(id)
	);")

	# 7. Pedidos
	db.query("CREATE TABLE IF NOT EXISTS orders (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		day INTEGER NOT NULL,
		character_id INTEGER NOT NULL,
		completed INTEGER NOT NULL DEFAULT 0,
		FOREIGN KEY (character_id) REFERENCES characters(id)
	);")

	# 8. Ítems de pedidos
	db.query("CREATE TABLE IF NOT EXISTS order_items (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		order_id INTEGER NOT NULL,
		recipe_id INTEGER NOT NULL,
		checked INTEGER NOT NULL DEFAULT 0,
		FOREIGN KEY (order_id) REFERENCES orders(id),
		FOREIGN KEY (recipe_id) REFERENCES recipes(id)
	);")

	# 9. Animales
	db.query("CREATE TABLE IF NOT EXISTS animals (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		name TEXT NOT NULL,
		species TEXT NOT NULL,
		gender TEXT NOT NULL CHECK (gender IN ('macho', 'hembra')),
		image_path TEXT,
		appears_on_day INTEGER NOT NULL,
		is_collected INTEGER NOT NULL DEFAULT 0,
		health_ok INTEGER NOT NULL DEFAULT 0,
		food_ok INTEGER NOT NULL DEFAULT 0,
		affection_ok INTEGER NOT NULL DEFAULT 0,
		adopted INTEGER NOT NULL DEFAULT 0
	);")

	# 10. Emails de adopción
	db.query("CREATE TABLE IF NOT EXISTS adoption_emails (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		animal_id INTEGER NOT NULL,
		sender_name TEXT NOT NULL,
		message_text TEXT NOT NULL,
		is_good_adoption INTEGER NOT NULL,
		day_received INTEGER NOT NULL,
		decision TEXT DEFAULT NULL CHECK (decision IN (NULL, 'accepted', 'rejected')),
		image_path TEXT,
		FOREIGN KEY (animal_id) REFERENCES animals(id)
	);")

	# 11. Pistas
	db.query("CREATE TABLE IF NOT EXISTS clues (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		title TEXT NOT NULL,
		description TEXT NOT NULL,
		source_character_id INTEGER,
		available_from_day INTEGER NOT NULL DEFAULT 1,
		FOREIGN KEY (source_character_id) REFERENCES characters(id)
	);")

	# 12. Pistas obtenidas
	db.query("CREATE TABLE IF NOT EXISTS player_clues (
		clue_id INTEGER PRIMARY KEY,
		obtained_on_day INTEGER NOT NULL,
		FOREIGN KEY (clue_id) REFERENCES clues(id)
	);")

	# 13. Escenas de diálogo
	db.query("CREATE TABLE IF NOT EXISTS dialogue_scenes (
		id TEXT PRIMARY KEY,
		day INTEGER NOT NULL,
		character_id INTEGER NOT NULL,
		scene_file TEXT NOT NULL,
		FOREIGN KEY (character_id) REFERENCES characters(id)
	);")

	# 14. Elecciones del jugador
	db.query("CREATE TABLE IF NOT EXISTS player_choices (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		scene_id TEXT NOT NULL,
		choice_id TEXT NOT NULL,
		chosen_option TEXT NOT NULL,
		day INTEGER NOT NULL,
		FOREIGN KEY (scene_id) REFERENCES dialogue_scenes(id)
	);")

	# 15. Personajes por día
	db.query("CREATE TABLE IF NOT EXISTS day_characters (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		day_number INTEGER NOT NULL,
		character_id INTEGER NOT NULL,
		visit_order INTEGER NOT NULL DEFAULT 0,
		FOREIGN KEY (character_id) REFERENCES characters(id)
	);")

	# 16. Progreso del día
	db.query("CREATE TABLE IF NOT EXISTS day_progress (
		day_number INTEGER PRIMARY KEY,
		started INTEGER NOT NULL DEFAULT 0,
		work_completed INTEGER NOT NULL DEFAULT 0,
		animals_checked INTEGER NOT NULL DEFAULT 0,
		night_completed INTEGER NOT NULL DEFAULT 0
	);")

	# 17. Finales
	db.query("CREATE TABLE IF NOT EXISTS endings (
		id TEXT PRIMARY KEY,
		name TEXT NOT NULL,
		description TEXT,
		required_clues_count INTEGER,
		required_character_id INTEGER,
		required_friendship_level INTEGER,
		FOREIGN KEY (required_character_id) REFERENCES characters(id)
	);")

	# Insertar datos iniciales si las tablas están vacías
	_insert_initial_data()

# ============================================================
# DATOS INICIALES
# ============================================================

func _insert_initial_data():
	# Solo insertar si no hay datos (evita duplicar al reiniciar)
	db.query("SELECT COUNT(*) AS total FROM locations;")
	if db.query_result[0]["total"] > 0:
		return

	# Lugares
	db.query("INSERT INTO locations (name, description) VALUES
		('Cafetería', 'La cafetería del protagonista, centro del juego'),
		('Ayuntamiento', 'Viejo ayuntamiento en la parte central del pueblo'),
		('Iglesia', 'Iglesia antigua con pocas personas asistiendo a misa'),
		('Tienda', 'Pequeña tienda donde se puede encontrar de todo'),
		('Granja', 'La única granja que sigue en pie, con cultivos, gallinas y vacas'),
		('Biblioteca', 'Biblioteca abandonada con libros antiguos'),
		('Taller', 'Casa de un señor que arregla y consigue herramientas'),
		('Floristería', 'Pequeña floristería con un jardín de flores'),
		('Bosque', 'Profundo y misterioso bosque con una clara y un lago cristalino'),
		('Casa de Hunter', 'La casita del protagonista en el pueblo');")

	# Personajes
	db.query("INSERT INTO characters (id, name, role, age, birthdate, description, personality, likes, dislikes, has_friendship_route, image_path) VALUES
		(1, 'Alcalde', 'alcalde', NULL, NULL, 'Bajito y barrigón, traje que le queda pequeño, sonrisa forzada', 'Simpático falso, chistes malos, territorial y cobarde', 'Las apariencias, hablar de sí mismo, presidir eventos', 'Preguntas incómodas, que le contradigan', 0, NULL),
		(2, 'Pastor', 'pastor', NULL, NULL, 'Alto, delgado, erguido, pelo oscuro, ojos claros e intensos', 'Calmado, encantador, nunca levanta la voz. Fanático', 'El orden, los rituales, el silencio', 'El caos, la incredulidad', 0, NULL),
		(3, 'Vendedor/a', 'tienda', NULL, NULL, 'Estética alternativa, ropa de segunda mano, piercing discreto', 'Fachada pasota, por dentro leal y directo/a', 'Música, podcasts de crimen, café con mucho azúcar', 'La gente falsa, el pueblo', 1, NULL),
		(4, 'Mamá Granjera', 'granjera_mama', NULL, NULL, 'Complexión fuerte, manos callosas, pelo recogido, botas de campo', 'Directa, fiable, orgullo callado', 'El trabajo bien hecho, su hija, los animales', 'Cotilleos, promesas vacías', 0, NULL),
		(5, 'Hija Granjera', 'granjera_hija', NULL, NULL, 'Trenzas, pecas, siempre con tierra encima, ropa colorida', 'Alegre, sin filtro, curiosísima', 'Animales, explorar, escuchar historias', 'Que la ignoren, las mentiras de adultos', 0, NULL),
		(6, 'Bruno', 'taller', NULL, NULL, 'Alto, fornido, barba poblada, moño descuidado, delantal de cuero', 'El más buena gente del pueblo, habla despacio, nunca juzga', 'Arreglar cosas, el silencio productivo, el café de Hunter', 'El drama, tirar cosas que aún sirven', 0, NULL),
		(7, 'Jasmine', 'florista', NULL, NULL, 'Pelo rizado, flores en el pelo, ropa floral y pastel', 'Dulce, cabeza en las nubes. Triste por su gata desaparecida', 'Flores raras, su abuela, su gata', 'Lugares oscuros, el invierno, la frialdad', 1, NULL),
		(8, 'Abuela', 'abuela_florista', NULL, NULL, 'Pequeñita, pelo blanco con horquillas, delantal de flores, gafas', 'La abuela de todo el pueblo, suelta info clave sin darse cuenta', 'Tejer, pajarillos, su nieta, las telenovelas', 'El frío, las prisas, que le recuerden que es mayor', 0, NULL),
		(9, 'Cartero', 'cartero', NULL, NULL, 'Barrigón, nariz colorada, gorra siempre puesta, café en mano', 'Cotilla encantador, cliente fijo, da pistas sin querer', 'Su paseo, el café, contar historias, sentirse útil', 'Que le digan que ya está jubilado, el silencio', 0, NULL),
		(10, 'Sectario', 'sectario', NULL, NULL, 'Discreto, ropa oscura, cara de cansancio, mirada ausente', 'Callado y nervioso, criado en la secta pero algo ha hecho clic', 'Los animales, la música tranquila, el aire libre', 'La violencia, las órdenes sin sentido', 0, NULL),
		(11, 'Solitario', 'solitario', NULL, NULL, 'Delgado, muy arrugado, abrigo viejo, bastón, barba descuidada', 'Borde total al principio, lleva 50 años en el pueblo y lo ha visto todo', 'Su huerto, el silencio, los perros', 'Forasteros, preguntas, el alcalde', 0, NULL),
		(12, 'Bibliotecario', 'bibliotecario', NULL, NULL, 'Delgado, pálido, pelo alborotado, gafas, mochila enorme', 'Callado en general, habla sin parar de lo que le apasiona', 'Historia local, archivos viejos, café solo, los gatos de la cafetería', 'El ruido, que le interrumpan, que la biblioteca siga cerrada', 1, NULL);")

	# Amistad
	db.query("INSERT INTO friendship (character_id, level) VALUES (3, 0), (7, 0), (12, 0);")

	# Finales
	db.query("INSERT INTO endings (id, name, description, required_clues_count, required_character_id, required_friendship_level) VALUES
		('bad', 'Final Malo', 'Hunter no logra descubrir al culpable.', NULL, NULL, NULL),
		('solo', 'Final Bueno - Solitario', 'Hunter descubre el misterio por su cuenta.', NULL, NULL, NULL),
		('florista', 'Final Bueno - Florista', 'Hunter descubre el misterio junto a Jasmine y rescata a su gata.', NULL, 7, NULL),
		('tienda', 'Final Bueno - Vendedor/a', 'Hunter descubre el misterio junto al/la vendedor/a.', NULL, 3, NULL),
		('bibliotecario', 'Final Bueno - Bibliotecario', 'Hunter descubre el misterio junto al bibliotecario.', NULL, 12, NULL);")

	# Progreso de días 1-15
	for day in range(1, 16):
		db.query("INSERT INTO day_progress (day_number) VALUES (" + str(day) + ");")

	# Personajes día 1
	db.query("INSERT INTO day_characters (day_number, character_id, visit_order) VALUES
		(1, 1, 1), (1, 7, 2), (1, 8, 3), (1, 9, 4), (1, 6, 5);")

	# Personajes día 2
	db.query("INSERT INTO day_characters (day_number, character_id, visit_order) VALUES
		(2, 3, 1), (2, 4, 2), (2, 5, 3), (2, 2, 4), (2, 10, 5), (2, 11, 6);")

	# Bibliotecario día 3
	db.query("INSERT INTO day_characters (day_number, character_id, visit_order) VALUES (3, 12, 1);")

	# Animales
	db.query("INSERT INTO animals (name, species, gender, image_path, appears_on_day) VALUES
		('Mochi', 'gato', 'macho', NULL, 1),
		('Luna', 'perro', 'hembra', NULL, 2),
		('Canela', 'gato', 'hembra', NULL, 3),
		('Nube', 'perro', 'macho', NULL, 4);")

	print("Datos iniciales insertados correctamente.")

# ============================================================
# FUNCIONES ÚTILES (las que usaremos desde el resto del juego)
# ============================================================

# --- PARTIDA ---

func create_new_game(player_name: String, pronoun: String, cafe_name: String):
	db.query("DELETE FROM game_save;")
	db.query("INSERT INTO game_save (player_name, pronoun, cafe_name) VALUES ('" + player_name + "', '" + pronoun + "', '" + cafe_name + "');")

func get_save_data() -> Dictionary:
	db.query("SELECT * FROM game_save WHERE id = 1;")
	if db.query_result.size() > 0:
		return db.query_result[0]
	return {}

func get_current_day() -> int:
	var save = get_save_data()
	if save.size() > 0:
		return save["current_day"]
	return 1

func advance_day():
	var current = get_current_day()
	if current < 15:
		db.query("UPDATE game_save SET current_day = " + str(current + 1) + " WHERE id = 1;")

# --- PERSONAJES ---

func get_character(character_id: int) -> Dictionary:
	db.query("SELECT * FROM characters WHERE id = " + str(character_id) + ";")
	if db.query_result.size() > 0:
		return db.query_result[0]
	return {}

func get_today_characters(day: int) -> Array:
	db.query("SELECT c.*, dc.visit_order FROM day_characters dc JOIN characters c ON dc.character_id = c.id WHERE dc.day_number = " + str(day) + " ORDER BY dc.visit_order;")
	return db.query_result.duplicate()

# --- AMISTAD ---

func get_friendship_level(character_id: int) -> int:
	db.query("SELECT level FROM friendship WHERE character_id = " + str(character_id) + ";")
	if db.query_result.size() > 0:
		return db.query_result[0]["level"]
	return 0

func add_friendship(character_id: int, amount: int = 1):
	db.query("UPDATE friendship SET level = level + " + str(amount) + " WHERE character_id = " + str(character_id) + ";")

# --- PEDIDOS ---

func create_order(day: int, character_id: int, recipe_ids: Array) -> int:
	db.query("INSERT INTO orders (day, character_id) VALUES (" + str(day) + ", " + str(character_id) + ");")
	var order_id = db.last_insert_rowid
	for recipe_id in recipe_ids:
		db.query("INSERT INTO order_items (order_id, recipe_id) VALUES (" + str(order_id) + ", " + str(recipe_id) + ");")
	return order_id

func check_order_item(item_id: int):
	db.query("UPDATE order_items SET checked = 1 WHERE id = " + str(item_id) + ";")

func is_order_complete(order_id: int) -> bool:
	db.query("SELECT COUNT(*) AS pending FROM order_items WHERE order_id = " + str(order_id) + " AND checked = 0;")
	return db.query_result[0]["pending"] == 0

func complete_order(order_id: int):
	db.query("UPDATE orders SET completed = 1 WHERE id = " + str(order_id) + ";")

# --- ANIMALES ---

func get_animal_for_day(day: int) -> Dictionary:
	db.query("SELECT * FROM animals WHERE appears_on_day = " + str(day) + ";")
	if db.query_result.size() > 0:
		return db.query_result[0]
	return {}

func collect_animal(animal_id: int):
	db.query("UPDATE animals SET is_collected = 1 WHERE id = " + str(animal_id) + ";")

func feed_animal(animal_id: int):
	db.query("UPDATE animals SET food_ok = 1 WHERE id = " + str(animal_id) + ";")

func heal_animal(animal_id: int):
	db.query("UPDATE animals SET health_ok = 1 WHERE id = " + str(animal_id) + ";")

func pet_animal(animal_id: int):
	db.query("UPDATE animals SET affection_ok = 1 WHERE id = " + str(animal_id) + ";")

func get_my_animals() -> Array:
	db.query("SELECT * FROM animals WHERE is_collected = 1 AND adopted = 0;")
	return db.query_result.duplicate()

func adopt_animal(animal_id: int):
	db.query("UPDATE animals SET adopted = 1 WHERE id = " + str(animal_id) + ";")

# --- PISTAS ---

func add_clue(clue_id: int, day: int):
	db.query("INSERT OR IGNORE INTO player_clues (clue_id, obtained_on_day) VALUES (" + str(clue_id) + ", " + str(day) + ");")

func get_my_clues() -> Array:
	db.query("SELECT cl.*, pc.obtained_on_day FROM player_clues pc JOIN clues cl ON pc.clue_id = cl.id ORDER BY pc.obtained_on_day;")
	return db.query_result.duplicate()

func get_clue_count() -> int:
	db.query("SELECT COUNT(*) AS total FROM player_clues;")
	return db.query_result[0]["total"]

# --- ELECCIONES ---

func save_choice(scene_id: String, choice_id: String, chosen_option: String, day: int):
	db.query("INSERT INTO player_choices (scene_id, choice_id, chosen_option, day) VALUES ('" + scene_id + "', '" + choice_id + "', '" + chosen_option + "', " + str(day) + ");")

# --- EMAILS DE ADOPCIÓN ---

func get_pending_emails() -> Array:
	db.query("SELECT ae.*, a.name AS animal_name, a.species FROM adoption_emails ae JOIN animals a ON ae.animal_id = a.id WHERE ae.decision IS NULL;")
	return db.query_result.duplicate()

func decide_email(email_id: int, accepted: bool):
	var decision = "'accepted'" if accepted else "'rejected'"
	db.query("UPDATE adoption_emails SET decision = " + decision + " WHERE id = " + str(email_id) + ";")
	if accepted:
		db.query("SELECT animal_id FROM adoption_emails WHERE id = " + str(email_id) + ";")
		if db.query_result.size() > 0:
			adopt_animal(db.query_result[0]["animal_id"])

# --- PROGRESO DEL DÍA ---

func start_day(day: int):
	db.query("UPDATE day_progress SET started = 1 WHERE day_number = " + str(day) + ";")

func complete_work(day: int):
	db.query("UPDATE day_progress SET work_completed = 1 WHERE day_number = " + str(day) + ";")

func complete_animals_check(day: int):
	db.query("UPDATE day_progress SET animals_checked = 1 WHERE day_number = " + str(day) + ";")

func complete_night(day: int):
	db.query("UPDATE day_progress SET night_completed = 1 WHERE day_number = " + str(day) + ";")

# --- CERRAR BD ---

func _exit_tree():
	if db:
		db.close_db()
		print("Base de datos cerrada.")
