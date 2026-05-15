extends State
 
@export var enemy: Guard2
 
func Enter() -> void:
	pass
 
func Physics_Update(_delta: float) -> void:
	enemy.velocity.x = 0
	if _player_spotted():
		Transitioned.emit(self, "Guard2Shoot")
 
func _player_spotted() -> bool:
	if enemy.sight_ray.is_colliding():
		if enemy.sight_ray.get_collider().is_in_group("player"):
			return true
	if enemy.back_ray.is_colliding():
		if enemy.back_ray.get_collider().is_in_group("player"):
			enemy.face_toward(enemy.back_ray.get_collider().global_position.x)
			return true
	return false
 
