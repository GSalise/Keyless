extends State
class_name GuardChase

@export var enemy: Guard
@export var attack_range := 30.0
@export var lose_sight_timeout := 2.0   # seconds without seeing player → Idle

var _lose_sight_timer := 0.0

func Enter() -> void:
	print("chase mode")
	_lose_sight_timer = 0.0


func Physics_Update(delta: float) -> void:
	var player = enemy.get_tree().get_first_node_in_group("player")

	if enemy.sight_ray.is_colliding() and enemy.sight_ray.get_collider().is_in_group("player"):
		_lose_sight_timer = 0.0
	else:
		_lose_sight_timer += delta

	if _lose_sight_timer >= lose_sight_timeout:
		# print("BAIL: lost sight")
		Transitioned.emit(self, "GuardIdle")
		return

	if player == null:
		# print("BAIL: no player")
		return

	if not enemy.floor_check.is_colliding():
		# print("BAIL: cliff edge")
		enemy.velocity.x = 0
		return

	if enemy.global_position.distance_to(player.global_position) <= attack_range:
		# print("BAIL: attack range, distance: ", enemy.global_position.distance_to(player.global_position))
		Transitioned.emit(self, "GuardAttack")
		return

	# print("MOVING toward player, dist: ", enemy.global_position.distance_to(player.global_position))
	var dir = player.global_position - enemy.global_position
	enemy.velocity.x = sign(dir.x) * 80.0
