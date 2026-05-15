extends Node2D

@export var launch_force: float = -700.0

func _ready() -> void:
	$Sprite2D/Area2D.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.velocity.y = launch_force
