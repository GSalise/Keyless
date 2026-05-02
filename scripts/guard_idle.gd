extends State
class_name GuardIdle

@export var enemy: Guard
@export var move_speed := 80.0
@export var patrol_distance := 200.0
@export var attack_range := 80.0

var start_x: float
var direction := 1.0
var _at_cliff := false
var _is_wall := false

func Enter():
	start_x = enemy.global_position.x
	_at_cliff = false
	_is_wall = false

func Physics_Update(_delta: float) -> void:

	if not enemy.floor_check.is_colliding():
		if not _at_cliff:
			_at_cliff = true
			direction *= -1
		enemy.velocity.x = move_speed * direction
		return

	_at_cliff = false
	enemy.velocity.x = move_speed * direction

	if enemy.global_position.x > start_x + patrol_distance:
		direction = -1.0
	elif enemy.global_position.x < start_x - patrol_distance:
		direction = 1.0

	if enemy.wall_check.is_colliding():
		if not _is_wall:
			_is_wall = true
			direction *= -1
		enemy.velocity.x = move_speed * direction
		return


	if enemy.sight_ray.is_colliding():
		var hit = enemy.sight_ray.get_collider()
		if hit and hit.is_in_group("player"):
			Transitioned.emit(self, "GuardChase")

	# Player detected
	if enemy.sight_ray.is_colliding():
		var hit = enemy.sight_ray.get_collider()
		if hit and hit.is_in_group("player"):
			Transitioned.emit(self, "GuardChase")
