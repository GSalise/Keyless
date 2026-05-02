extends CharacterBody2D
class_name Guard

@onready var animated_sprite = $GuardAnimatedSprite


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	move_and_slide()

	if velocity.length() > 0:
		animated_sprite.play("move")
	else:
		animated_sprite.play("idle")

	if velocity.x > 0:
		animated_sprite.flip_h = false
	else:
		animated_sprite.flip_h = true
