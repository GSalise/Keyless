extends CharacterBody2D


const SPEED = 250.0
const JUMP_VELOCITY = -350.0

@onready var animated_sprite = $AnimatedSprite2D

signal started_running
signal stopped_running
signal jumped
signal health_changed(current_health: int, max_health: int)
signal died(reason: StringName)

@export var maxHealth: int = 3
@export var fall_damage_distance: float = 350.0
var currentHealth: int = maxHealth

var _was_running: bool = false
var _fall_start_y: float = 0.0
var _is_dead: bool = false

func _ready() -> void:
	currentHealth = maxHealth
	_fall_start_y = global_position.y
	health_changed.emit(currentHealth, maxHealth)


func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	var was_on_floor := is_on_floor()

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

	if was_on_floor and velocity.y >= 0.0:
		_fall_start_y = global_position.y

	move_and_slide()

	var landed_this_frame := (not was_on_floor) and is_on_floor()
	if landed_this_frame:
		var fallen_distance := global_position.y - _fall_start_y
		if fallen_distance >= fall_damage_distance:
			take_damage(1)

func _request_death(reason: StringName) -> void:
	if _is_dead:
		return

	_is_dead = true
	velocity = Vector2.ZERO
	set_physics_process(false)
	# Defer signal emission so we do not mutate scene/physics state mid-callback.
	call_deferred("_emit_died", reason)

func _emit_died(reason: StringName) -> void:
	died.emit(reason)

func request_death(reason: StringName = &"unknown") -> void:
	_request_death(reason)

func take_damage(amount: int = 1) -> void:
	if amount <= 0:
		return
	if currentHealth <= 0:
		return

	currentHealth = max(0, currentHealth - amount)
	health_changed.emit(currentHealth, maxHealth)

	if currentHealth == 0:
		_request_death(&"health_zero")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body != self:
		return
	_request_death(&"fall_zone")
