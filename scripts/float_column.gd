# float_column.gd
extends Node2D

@export var float_gravity_scale: float = 0.08
@export var max_rise_speed: float = 500.0
@export var max_fall_speed: float = 40.0
@export var rise_force: float = -200.0
@export var oscillation_strength: float = 0.5
@export var is_downwards: bool = false

func _ready() -> void:
    $Area2D.float_gravity_scale = float_gravity_scale
    $Area2D.max_rise_speed = max_rise_speed
    $Area2D.rise_force = rise_force
    $Area2D.oscillation_strength = oscillation_strength
    $Area2D.is_downwards = is_downwards