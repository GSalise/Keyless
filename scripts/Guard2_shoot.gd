extends State
class_name Guard2Shoot
 
@export var enemy: Guard2
@export var shoot_range := 200.0
@export var shoot_cooldown := 1.5
@export var bullet_damage := 1
@export var bullet_speed := 400.0
@export var lose_sight_timeout := 2.0
 
var _cooldown_timer := 0.0
var _lose_sight_timer := 0.0
 
func Enter() -> void:
	enemy.velocity.x = 0
	_cooldown_timer = 0.0
	_lose_sight_timer = 0.0
 
func Physics_Update(delta: float) -> void:
	var player = enemy.get_tree().get_first_node_in_group("player")
 
	var front_sees = enemy.sight_ray.is_colliding() and enemy.sight_ray.get_collider().is_in_group("player")
	var back_sees = enemy.back_ray.is_colliding() and enemy.back_ray.get_collider().is_in_group("player")
 
	if front_sees:
		_lose_sight_timer = 0.0
	elif back_sees:
		# Face toward the player properly
		if player:
			enemy.face_toward(player.global_position.x)
		_lose_sight_timer = 0.0
	else:
		_lose_sight_timer += delta
 
	if _lose_sight_timer >= lose_sight_timeout:
		Transitioned.emit(self, "Guard2Idle")
		return
 
	if player == null:
		return
 
	var dist = enemy.global_position.distance_to(player.global_position)
	if dist > shoot_range:
		Transitioned.emit(self, "Guard2Chase")
		return
 
	enemy.velocity.x = 0
 
	_cooldown_timer -= delta
	if _cooldown_timer <= 0.0:
		_cooldown_timer = shoot_cooldown
		_fire(player)
 
func _fire(player: Node2D) -> void:
	var area := Area2D.new()
	area.set_script(load("res://scripts/bullet.gd"))
	area.collision_layer = 4
	area.collision_mask = 1
	area.monitoring = true
	area.monitorable = false
 
	var rect := ColorRect.new()
	rect.color = Color(1.0, 0.85, 0.1)
	rect.size = Vector2(10, 4)
	rect.position = Vector2(-5, -2)
	area.add_child(rect)
 
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(10, 4)
	col.shape = shape
	area.add_child(col)
 
	area.global_position = enemy.muzzle.global_position
	enemy.get_tree().current_scene.add_child(area)
 
	area.direction = Vector2(enemy.facing, 0)
	area.damage = bullet_damage
	area.speed = bullet_speed
 
