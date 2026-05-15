# float_zone.gd
extends Area2D

# Tweak these to feel right
@export var float_gravity_scale: float = 0.08     # 8% of normal gravity (slow fall)
@export var max_rise_speed: float = 500.0
@export var max_fall_speed: float = 40.0          # terminal velocity while floating
@export var rise_force: float = -200.0            # upward push applied each frame
@export var oscillation_strength: float = 0.5     # how much it bobs up/down (0 = none)
@export var is_downwards := true

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.has_method("enter_float_zone"):
		body.enter_float_zone(self)

func _on_body_exited(body: Node) -> void:
	if body.has_method("exit_float_zone"):
		body.exit_float_zone()
