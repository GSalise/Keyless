extends State
class_name Guard2Chase
 
@export var enemy: Guard2
@export var shoot_range := 200.0
@export var lose_sight_timeout := 2.0
 
var _lose_sight_timer := 0.0
 
func Enter() -> void:
	_lose_sight_timer = 0.0
 
func Physics_Update(delta: float) -> void:
	enemy.velocity.x = 0
 
	var spotted := false
 
	if enemy.sight_ray.is_colliding() and enemy.sight_ray.get_collider().is_in_group("player"):
		spotted = true
	elif enemy.back_ray.is_colliding() and enemy.back_ray.get_collider().is_in_group("player"):
		enemy.facing *= -1
		spotted = true
 
	if spotted:
		_lose_sight_timer = 0.0
		Transitioned.emit(self, "Guard2Shoot")
	else:
		_lose_sight_timer += delta
		if _lose_sight_timer >= lose_sight_timeout:
			Transitioned.emit(self, "Guard2Idle")
 
