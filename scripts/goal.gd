extends CharacterBody2D

const movement_speed = 1200.0

@export var Goal: Node = null

func _ready() -> void:
    $NavigationAgent2D.target_position = Goal.global_position


