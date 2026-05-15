extends State
class_name Guard2Shoot
 
@export var enemy: Guard2
@export var shoot_range := 200.0      # if player moves beyond this, chase again
@export var shoot_cooldown := 1.5     # seconds between shots
@export var bullet_damage := 1
@export var bullet_speed := 400.0
@export var lose_sight_timeout := 2.0
 
var _cooldown_timer := 0.0
var _lose_sight_timer := 0.0
 
# Built once on Enter so we're not recreating every shot
var _bullet_scene: PackedScene = null
 
func Enter() -> void:
	enemy.velocity.x = 0  # stand still while shooting
	_cooldown_timer = 0.0  # shoot immediately on entry
	_lose_sight_timer = 0.0
	if _bullet_scene == null:
		_bullet_scene = _build_bullet_scene()
 
func Physics_Update(delta: float) -> void:
	var player = enemy.get_tree().get_first_node_in_group("player")
 
	# Line-of-sight tracking
	if enemy.sight_ray.is_colliding() and enemy.sight_ray.get_collider().is_in_group("player"):
		_lose_sight_timer = 0.0
	else:
		_lose_sight_timer += delta
 
	if _lose_sight_timer >= lose_sight_timeout:
		Transitioned.emit(self, "Guard2Idle")
		return
 
	if player == null:
		return
 
	var dist = enemy.global_position.distance_to(player.global_position)
 
	# Player moved too far away — chase
	if dist > shoot_range:
		Transitioned.emit(self, "Guard2Chase")
		return
 
	# Stay still and face the player
	enemy.velocity.x = 0
 
	# Shooting cooldown
	_cooldown_timer -= delta
	if _cooldown_timer <= 0.0:
		_cooldown_timer = shoot_cooldown
		_fire(player)
 
func _fire(player: Node2D) -> void:
	if _bullet_scene == null:
		return
 
	var bullet = _bullet_scene.instantiate()
	bullet.global_position = enemy.muzzle.global_position
	bullet.direction = (player.global_position - enemy.muzzle.global_position).normalized()
	bullet.damage = bullet_damage
	bullet.speed = bullet_speed
 
	# Spawn in scene root so bullet moves independently of the guard
	enemy.get_tree().current_scene.add_child(bullet)
 
# ---------------------------------------------------------------------------
# Builds a minimal bullet scene in code — no extra .tscn file needed
# ---------------------------------------------------------------------------
func _build_bullet_scene() -> PackedScene:
	var area = Area2D.new()
	area.set_script(load("res://scripts/bullet.gd"))
	# Collision layer 4 = bullet layer (adjust in Project Settings → Layer Names)
	# Collision mask  2 = player layer (must match the player's collision_layer)
	area.collision_layer = 4
	area.collision_mask  = 2
 
	# Visual: small bright-yellow rectangle
	var rect = ColorRect.new()
	rect.color = Color(1.0, 0.85, 0.1)
	rect.size = Vector2(10, 4)
	rect.position = Vector2(-5, -2)  # centred on origin
	area.add_child(rect)
 
	# Collider
	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(10, 4)
	col.shape = shape
	area.add_child(col)
 
	var packed = PackedScene.new()
	packed.pack(area)
	return packed
