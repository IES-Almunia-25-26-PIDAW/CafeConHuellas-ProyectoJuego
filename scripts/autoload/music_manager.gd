## Autoload singleton que gestiona la reproducción de música del juego.
## Implementa crossfade real entre pistas usando dos AudioStreamPlayer en paralelo.
## Persiste entre cambios de escena y puede llamarse desde cualquier script.
## [br]
## Uso básico:
##   MusicManager.play("cafe_theme")
##   MusicManager.stop()
extends Node

# ===== CONFIGURACIÓN =====

# Ruta base donde se encuentran los archivos de música.
const MUSIC_PATH := "res://assets/audio/music/"
# Duración en segundos de los fades.
const FADE_TIME := 0.5

# ===== ESTADO INTERNO =====

# Dos players para poder hacer crossfade real sin silencio entre pistas.
# active indica cuál de los dos está sonando en este momento (0 o 1).
var players: Array[AudioStreamPlayer] = []
var active: int = 0

# Tween activo guardado para poder cancelarlo si llega una nueva pista antes de que el fade anterior termine.
var current_tween: Tween

# Indica si hay un crossfade en curso.
# Se usa para saber el estado exacto de los players si el tween se interrumpe.
var is_crossfading: bool = false

# Nombre de la pista que está sonando actualmente.
# Se usa para evitar reiniciar una pista que ya está en reproducción.
var current_track: String = ""


# ===== INICIALIZACIÓN =====

func _ready() -> void:
	# Se crean los dos AudioStreamPlayer y se asignan al bus "Music".
	# Usando un bus dedicado, el volumen que ajuste el usuario en los ajustes
	# del juego no interfiere con los tweens de fade de este script.
	for i in 2:
		var p = AudioStreamPlayer.new()
		p.bus = "Music"
		add_child(p)
		players.append(p)
		# Cada player tiene su propio callback de fin de pista para el loop manual.
		# Se pasa el índice para saber cuál de los dos ha terminado.
		p.finished.connect(_on_finished.bind(i))


# ===== PUBLIC API =====

## Reproduce una pista de música por nombre de archivo (sin extensión).
## Si la pista ya está sonando no hace nada.
## [param track_name] Nombre del archivo sin extensión (ej: "cafe_theme").
## [param fade] Si es true hace crossfade suave, si es false cambia de golpe.
func play(track_name: String, fade: bool = true) -> void:
	# Si la pista solicitada ya está sonando no se hace nada.
	if track_name == current_track:
		return

	var path = MUSIC_PATH + track_name + ".ogg"

	# Se comprueba que el archivo existe antes de intentar cargarlo.
	if not ResourceLoader.exists(path):
		push_warning("MusicManager: No se encontró la pista: " + path)
		return

	current_track = track_name

	if fade:
		_crossfade(path)
	else:
		_stop_all()
		players[active].stream = load(path)
		players[active].volume_db = 0.0
		players[active].play()


## Para la música.
## [param fade] Si es true baja el volumen suavemente antes de parar.
func stop(fade: bool = true) -> void:
	if fade:
		var tween = create_tween()
		tween.tween_property(players[active], "volume_db", -40.0, FADE_TIME)
		tween.tween_callback(func():
			_stop_all()
			current_track = ""
		)
	else:
		_stop_all()
		current_track = ""


# ===== LÓGICA INTERNA =====

# Sube el volumen del player inactivo con la nueva pista mientras baja
# el volumen del player activo con la pista anterior, simultáneamente.
func _crossfade(path: String) -> void:
	# Si hay un crossfade en curso se cancela antes de iniciar el nuevo.
	if current_tween:
		current_tween.kill()
		# Si el crossfade anterior no completó su callback, active no se actualizó.
		# Se usa is_crossfading para saber que los players están en estado intermedio
		# y se resetean ambos a un estado limpio y conocido antes de continuar.
		if is_crossfading:
			_stop_all()
			# El player activo vuelve a ser el 0 en estado limpio.
			active = 0
		is_crossfading = false

	var next = 1 - active

	# Se carga la nueva pista en el player inactivo y se arranca en silencio.
	# load() es síncrono. Para pistas ligeras en .ogg esto es suficiente.
	# Si en el futuro las pistas fuesen muy pesadas, habría que cambiar a
	# ResourceLoader.load_threaded_request() para no bloquear el hilo principal.
	players[next].stream = load(path)
	players[next].volume_db = -40.0
	players[next].play()

	# tween_property sube el nuevo player a volumen normal.
	# parallel() hace que el siguiente tween_property corra al mismo tiempo,
	# bajando el player anterior. Así no hay silencio entre las dos pistas.
	is_crossfading = true
	current_tween = create_tween()
	current_tween.tween_property(players[next], "volume_db", 0.0, FADE_TIME)
	current_tween.parallel().tween_property(players[active], "volume_db", -40.0, FADE_TIME)
	current_tween.tween_callback(func():
		players[active].stop()
		# El player que antes era inactivo pasa a ser el activo.
		active = next
		is_crossfading = false
	)


# Para los dos players y resetea su volumen a 0.
func _stop_all() -> void:
	for p in players:
		p.stop()
		p.volume_db = 0.0


# Se llama automáticamente cuando una pista termina.
# Solo reinicia la reproducción si el player que terminó es el activo,
# para evitar que el player inactivo interfiera durante un crossfade.
func _on_finished(index: int) -> void:
	if index == active:
		players[active].play()
