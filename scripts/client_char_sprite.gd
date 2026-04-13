extends Node2D

@onready var animated_sprite = $AnimatedSprite

# Called when the node enters the scene tree for the first time.
func _ready():
	# Resetea lo que se muestra en pantalla
	self.modulate.a = 0

func change_character(character_name : Character.Name, is_talking : bool, expression: String):
	var sprite_frames = Character.CHARACTER_DETAILS[character_name]["sprite_frames"]
	var stance = "talk" if is_talking else "idle"
	# Si la expresión existe toma la animación con el mismo nombre, si no, toma la instancia y animación por defecto
	var animation_name = expression + "-" + stance if expression else stance
	
	# Si el personaje tiene sprite_frames, actualiza animated_sprite y comienza la animación
	if sprite_frames:
		animated_sprite.sprite_frames = sprite_frames
		# Revisa si la animación a la expresión asociada existe
		# Si no, usa la animación por defecto (stance)
		if animated_sprite.sprite_frames.has_animation(animation_name):
			animated_sprite.play(animation_name)
		else:
			animated_sprite.play(stance)
	else:
		# Cambia a la animación idle del personaje que se está mostrando en pantalla
		play_idle_animation()
	
	# Revisa si no se está mostrando nada
	if self.modulate.a == 0:
		create_tween().tween_property(self, "modulate:a", 1.0, 0.3)

func play_idle_animation():
	var last_animation = animated_sprite.animation
	if last_animation and not last_animation.ends_with("-idle"):
		# Si una expresión se muestra, intenta mostrar la animación idle correspondiente
		# Si existe, se muestra. Si no, se muestra la por defecto.
		var idle_expression = last_animation.replace("talk", "idle")
		if animated_sprite.sprite_frames.has_animation(idle_expression):
			animated_sprite.play(idle_expression)
		else:
			animated_sprite.play("idle")
