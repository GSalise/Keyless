extends CharacterBody2D


const SPEED = 250.0
const JUMP_VELOCITY = -350.0

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	
	# sprite flipping
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	# sprite animations
	if direction == 0:
		animated_sprite.play("idle")
	else:
		animated_sprite.play("move")
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func _die() -> void:
	get_tree().reload_current_scene()


func _on_area_2d_body_entered(_body: CharacterBody2D) -> void:
	_die()
