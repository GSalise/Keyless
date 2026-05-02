extends State
class_name GuardAttack

@export var enemy: Guard
@export var attack_range := 80.0
@export var attack_cooldown := 1.0

var fist_sprite: Sprite2D  # no @onready
var cooldown_timer := 0.0

func Enter():
	fist_sprite = enemy.get_node("PunchSprite")  # resolve here instead
	fist_sprite.visible = true
	cooldown_timer = attack_cooldown
	enemy.velocity.x = 0

func Exit():
	fist_sprite.visible = false  # no .stop() — Sprite2D has no stop()

func Physics_Update(delta: float) -> void:
	fist_sprite.flip_h = enemy.animated_sprite.flip_h
	
	cooldown_timer -= delta

	var player = enemy.get_tree().get_first_node_in_group("player")

	if cooldown_timer <= 0:
		if player and enemy.global_position.distance_to(player.global_position) <= attack_range:
			cooldown_timer = attack_cooldown
		else:
			Transitioned.emit(self, "GuardIdle")
