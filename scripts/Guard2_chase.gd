extends State
class_name Guard2Chase
 
@export var enemy: Guard2
@export var shoot_range := 200.0       # stop and shoot when within this distance
@export var chase_speed := 80.0
@export var lose_sight_timeout := 2.0  # seconds without line-of-sight → back to Idle
 
var _lose_sight_timer := 0.0
 
func Enter() -> void:
	_lose_sight_timer = 0.0
 
func Physics_Update(delta: float) -> void:
	var player = enemy.get_tree().get_first_node_in_group("player")
 
	# Track line-of-sight
	if enemy.sight_ray.is_colliding() and enemy.sight_ray.get_collider().is_in_group("player"):
		_lose_sight_timer = 0.0
	else:
		_lose_sight_timer += delta
 
	if _lose_sight_timer >= lose_sight_timeout:
		Transitioned.emit(self, "Guard2Idle")
		return
 
	if player == null:
		return
 
	# Don't chase over a cliff
	if not enemy.floor_check.is_colliding():
		enemy.velocity.x = 0
		return
 
	var dist = enemy.global_position.distance_to(player.global_position)
 
	if dist <= shoot_range:
		Transitioned.emit(self, "Guard2Shoot")
		return
 
	var dir = player.global_position - enemy.global_position
	enemy.velocity.x = sign(dir.x) * chase_speed
 
