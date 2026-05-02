extends CharacterBody2D
class_name Guard

@onready var animated_sprite: AnimatedSprite2D = $GuardAnimatedSprite
@onready var sight_ray: RayCast2D = $SightRay
@onready var floor_check: RayCast2D = $FloorCheck
@onready var wall_check: RayCast2D = $WallCheck
@onready var punch: Area2D = $PunchCollision
@onready var punch_sprite: Sprite2D = $PunchCollision/PunchSprite
@onready var sight_visual: Line2D = $SightRay/SightVisual


# Guard.gd
var facing := 1.0  # 1 = right, -1 = left

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()

	if velocity.x != 0:
		facing = sign(velocity.x)  # only update when actually moving

	animated_sprite.play("move" if velocity.length() > 0 else "idle")
	# print("floor_check pos: ", floor_check.global_position, " target: ", floor_check.target_position, " colliding: ", floor_check.is_colliding())
	animated_sprite.flip_h = facing < 0
	punch_sprite.flip_h = facing < 0
	punch.position.x = abs(punch.position.x) * facing

	floor_check.position.x = abs(floor_check.position.x) * facing
	floor_check.target_position.x = abs(floor_check.target_position.x) * facing

	sight_ray.position.x = abs(sight_ray.position.x) * facing
	sight_ray.target_position.x = abs(sight_ray.target_position.x) * facing

	wall_check.target_position.x = abs(wall_check.target_position.x) * facing
	wall_check.position.x = abs(wall_check.position.x) * facing
	
	_update_sight_visual()

func _update_sight_visual() -> void:
	sight_visual.clear_points()
	sight_visual.add_point(Vector2.ZERO)  # origin (local to SightRay)
	
	if sight_ray.is_colliding():
		# Convert global hit point → local space of sight_ray
		var local_hit = sight_ray.to_local(sight_ray.get_collision_point())
		sight_visual.add_point(local_hit)
		sight_visual.default_color = Color.RED
	else:
		sight_visual.add_point(sight_ray.target_position)
		sight_visual.default_color = Color.GREEN
