extends CharacterBody2D

const SPEED = 250.0
const JUMP_VELOCITY = -350.0
const STEALTH_SPEED = 100.0
const STEALTH_DURATION = 5.0

@onready var animated_sprite = $AnimatedSprite2D

signal started_running
signal stopped_running
signal jumped
signal health_changed(current_health: int, max_health: int)
signal died(reason: StringName)
signal stealth_changed(active: bool)
signal float_zone_entered(zone: Node)
signal float_zone_exited()

const FLOAT_AREA_SCRIPT := preload("res://scripts/floatArea.gd")

@export var maxHealth: int = 3
@export var fall_damage_distance: float = 350.0
var currentHealth: int = maxHealth

var _was_running: bool = false
var _fall_start_y: float = 0.0
var _is_dead: bool = false

# --- Stealth State ---
var _is_stealthed: bool = false
var _stealth_timer: float = 0.0

# --- Float Zone State ---
var _in_float_zone: bool = false
var _float_zone_ref: Node = null
var _float_time: float = 0.0  # tracks time for oscillation

var _damage_cooldown: float = 0.0

func _ready() -> void:
	currentHealth = maxHealth
	_fall_start_y = global_position.y
	health_changed.emit(currentHealth, maxHealth)


func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	if _damage_cooldown > 0.0:
		_damage_cooldown -= delta

	# Stealth toggle
	if Input.is_action_just_pressed("stealth") and not _is_stealthed:
		_is_stealthed = true
		_stealth_timer = STEALTH_DURATION
		set_collision_layer_value(1, false)  # hide from raycasts
		animated_sprite.modulate = Color(0.72, 0.72, 0.72, 1.0)
		stealth_changed.emit(true)

	# Stealth countdown
	if _is_stealthed:
		_stealth_timer -= delta
		print("Stealth remaining: %.1f" % _stealth_timer)
		if _stealth_timer <= 0.0:
			_end_stealth()

	var was_on_floor := is_on_floor()
	var current_speed := STEALTH_SPEED if _is_stealthed else SPEED

	# Add the gravity.
	if _in_float_zone:
		_float_time += delta

		var zone := _float_zone_ref
		var is_downwards: bool = bool(zone.get("is_downwards"))
		var gravity_scale: float = float(zone.get("float_gravity_scale"))
		var max_fall: float = float(zone.get("max_fall_speed"))
		var max_rise: float = float(zone.get("max_rise_speed"))
		var rise_force: float = float(zone.get("rise_force"))
		var oscillation: float = float(zone.get("oscillation_strength"))

		if is_downwards:
			var gravity_vec = get_gravity() * gravity_scale
			velocity += gravity_vec * delta
			velocity.y = min(velocity.y, max_fall)
		else:
			var gravity_vec = get_gravity() * gravity_scale
			velocity += gravity_vec * delta
			velocity.y += rise_force * delta
			velocity.y = max(velocity.y, -max_rise)

		var bob = sin(_float_time * 1.5) * oscillation
		velocity.y += bob
	elif not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump — disabled during stealth.
	if Input.is_action_just_pressed("jump") and is_on_floor() and not _is_stealthed and not _in_float_zone:
		jumped.emit()
		velocity.y = JUMP_VELOCITY

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
		velocity.x = direction * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)

	var is_running_now := is_on_floor() and absf(velocity.x) > 0.1
	if is_running_now and not _was_running:
		started_running.emit()
	elif (not is_running_now) and _was_running:
		stopped_running.emit()
	_was_running = is_running_now

	if was_on_floor and velocity.y >= 0.0:
		_fall_start_y = global_position.y

	move_and_slide()

	# Take damage from platforms
	if get_slide_collision_count() > 0:
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if collision.get_collider().name == "DamagePlatforms" and _damage_cooldown <= 0.0:
				print("taking damage")
				take_damage(1)
				velocity.y = JUMP_VELOCITY * 0.6
				_damage_cooldown = 1.0  # 1 second before damage can trigger again

func _end_stealth() -> void:
	_is_stealthed = false
	_stealth_timer = 0.0
	set_collision_layer_value(1, true)  # restore visibility to raycasts
	print("Stealth ended")
	animated_sprite.modulate = Color(1, 1, 1, 1)
	stealth_changed.emit(false)

# ... rest of your functions unchanged
func _request_death(reason: StringName) -> void:
	if _is_dead:
		return
	_is_dead = true
	velocity = Vector2.ZERO
	set_physics_process(false)
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

func enter_float_zone(zone: Node) -> void:
	if zone == self or zone.get_script() != FLOAT_AREA_SCRIPT:
		return
	_in_float_zone = true
	_float_zone_ref = zone
	_float_time = 0.0
	if velocity.y > 50.0:
		velocity.y = 50.0
	float_zone_entered.emit(zone)

func exit_float_zone() -> void:
	_in_float_zone = false
	_float_zone_ref = null
	_float_time = 0.0
	float_zone_exited.emit()
