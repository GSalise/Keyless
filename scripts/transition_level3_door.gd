extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if not (body is CharacterBody2D):
		return
	if not body.is_in_group("player"):
		return
	var levels := get_tree().get_nodes_in_group("level")
	if levels.is_empty():
		return
	var level: Node = levels[0]
	if level.has_method("on_exit_to_level_three"):
		level.call("on_exit_to_level_three", body)
