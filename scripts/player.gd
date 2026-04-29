extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var animated_sprite = $AnimatedSprite2D

signal started_running
signal stopped_running
signal jumped

var _was_running: bool = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jumped.emit()
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

	var is_running_now := is_on_floor() and absf(velocity.x) > 0.1
	if is_running_now and not _was_running:
		started_running.emit()
	elif (not is_running_now) and _was_running:
		stopped_running.emit()
	_was_running = is_running_now

	move_and_slide()
