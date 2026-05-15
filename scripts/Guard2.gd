extends CharacterBody2D
class_name Guard2

@onready var animated_sprite: AnimatedSprite2D = $GuardAnimatedSprite
@onready var sight_ray: RayCast2D = $SightRay
@onready var floor_check: RayCast2D = $FloorCheck
@onready var wall_check: RayCast2D = $WallCheck
@onready var back_ray: RayCast2D = $Back/BackSight
@onready var sight_visual: Line2D = $SightRay/SightVisual
@onready var muzzle: Marker2D = $Muzzle

var facing := 1.0

func _physics_process(_delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * _delta

	move_and_slide()

	if velocity.x != 0:
		facing = sign(velocity.x)

	animated_sprite.play("idle")
	animated_sprite.flip_h = facing < 0

	floor_check.position.x = abs(floor_check.position.x) * facing

	sight_ray.position.x = abs(sight_ray.position.x) * facing
	sight_ray.target_position.x = abs(sight_ray.target_position.x) * facing

	wall_check.target_position.x = abs(wall_check.target_position.x) * facing
	wall_check.position.x = abs(wall_check.position.x) * facing

	muzzle.position.x = abs(muzzle.position.x) * facing
	back_ray.position.x = -abs(back_ray.position.x) * facing
	back_ray.target_position.x = -abs(back_ray.target_position.x) * facing

	_update_sight_visual()
func face_toward(target_x: float) -> void:
	facing = 1.0 if target_x > global_position.x else -1.0
	
func _update_sight_visual() -> void:
	sight_visual.clear_points()
	sight_visual.add_point(Vector2.ZERO)

	if sight_ray.is_colliding():
		var local_hit = sight_ray.to_local(sight_ray.get_collision_point())
		sight_visual.add_point(local_hit)
		sight_visual.default_color = Color.RED
	else:
		sight_visual.add_point(sight_ray.target_position)
		sight_visual.default_color = Color.GREEN
