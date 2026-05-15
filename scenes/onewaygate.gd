extends StaticBody2D

@export var player: CharacterBody2D

func _physics_process(_delta: float) -> void:
    if player == null:
        return
    var player_is_right = player.global_position.x > global_position.x - 10.0
    $CollisionShape2D.disabled = player_is_right