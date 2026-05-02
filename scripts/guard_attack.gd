extends State
class_name GuardAttack

@export var enemy: Guard
@export var attack_range := 30.0
@export var attack_cooldown := 1.0

var fist: Area2D
var cooldown_timer := 0.0

func Enter():
	fist = enemy.get_node("PunchCollision")
	enemy.punch_sprite.visible = true
	fist.monitoring = true
	cooldown_timer = 0.0  # ← was attack_cooldown, now hits immediately on enter
	enemy.velocity.x = 0

func Exit():
	enemy.punch_sprite.visible = false
	fist.monitoring = false
	

func Physics_Update(delta: float) -> void:
	cooldown_timer -= delta

	var player = enemy.get_tree().get_first_node_in_group("player")

	if cooldown_timer <= 0:
		if player and enemy.global_position.distance_to(player.global_position) <= attack_range:
			# check if player is inside the fist area
			var bodies = fist.get_overlapping_bodies()
			if player in bodies:
				print("player hit")
				player.take_damage(1)
				cooldown_timer = attack_cooldown
		else:
			Transitioned.emit(self, "GuardChase")
