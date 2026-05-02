extends State
class_name GuardIdle

@export var enemy: Guard
@export var move_speed := 80.0
@export var patrol_distance := 200.0
@export var attack_range := 80.0  # should match GuardAttack's range

var start_x: float
var direction := 1.0

func Enter():
	start_x = enemy.global_position.x

func Physics_Update(_delta: float) -> void:
	enemy.velocity.x = move_speed * direction
	
	if enemy.global_position.x > start_x + patrol_distance:
		direction = -1.0
	elif enemy.global_position.x < start_x - patrol_distance:
		direction = 1.0

	# Check for player in range
	var player = enemy.get_tree().get_first_node_in_group("player")
	if player and enemy.global_position.distance_to(player.global_position) <= attack_range:
		Transitioned.emit(self, "GuardAttack")
