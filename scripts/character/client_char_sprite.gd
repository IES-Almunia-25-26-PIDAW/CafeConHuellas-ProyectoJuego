## Controla el sprite animado del personaje en la escena de diálogo.
## Gestiona qué animación mostrar según el personaje, si está hablando y su expresión.
## Se hace visible con un fade suave la primera vez que se muestra un personaje.
extends Node2D


# ===== REFERENCIAS A NODOS =====

@onready var animated_sprite = $AnimatedSprite

# ===== CICLO DE VIDA =====

func _ready() -> void:
	# Resetea lo que se muestra en pantalla.
	# Empieza invisible para hacer fade de entrada la primera vez.
	self.modulate.a = 0

# ===== PUBLIC API =====

## Actualiza el sprite al personaje indicado con la expresión y stance correctos.
## Si el personaje no tiene sprites asignados, llama a play_idle_animation().
## [param character_name] ID del personaje (Character.Name).
## [param is_talking] Si es true usa la animación "talk", si no "idle".
## [param expression] Prefijo de expresión (ej: "happy"). Vacío usa solo el stance.
func change_character(character_name : Character.Name, is_talking : bool, expression: String) -> void:
	var sprite_frames = Character.CHARACTER_DETAILS[character_name]["sprite_frames"]
	var stance = "talk" if is_talking else "idle"
	# Si la expresión existe toma la animación con el mismo nombre, si no, toma la instancia y animación por defecto.
	var animation_name = expression + "-" + stance if expression else stance
	
	# Si el personaje tiene sprite_frames, actualiza animated_sprite y comienza la animación.
	if sprite_frames:
		animated_sprite.sprite_frames = sprite_frames
		# Revisa si la animación a la expresión asociada existe.
		# Si no, usa la animación por defecto (stance).
		if animated_sprite.sprite_frames.has_animation(animation_name):
			animated_sprite.play(animation_name)
		else:
			animated_sprite.play(stance)
	else:
		# Cambia a la animación idle del personaje que se está mostrando en pantalla.
		play_idle_animation()
	
	# Revisa si no se está mostrando nada.
	if self.modulate.a == 0:
		create_tween().tween_property(self, "modulate:a", 1.0, 0.3)

## Transiciona a la animación idle correspondiente a la expresión actual.
## Si la expresión idle no existe, usa la animación "idle" por defecto.
func play_idle_animation() -> void:
	var last_animation = animated_sprite.animation
	if last_animation and not last_animation.ends_with("-idle"):
		var idle_expression = last_animation.replace("talk", "idle")
		# Intenta la versión idle de la expresión actual, si no existe usa la por defecto
		if animated_sprite.sprite_frames.has_animation(idle_expression):
			animated_sprite.play(idle_expression)
		else:
			animated_sprite.play("idle")
