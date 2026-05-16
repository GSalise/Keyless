extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if not (body is CharacterBody2D):
		return
	var levels := get_tree().get_nodes_in_group("level")
	if levels.is_empty():
		return
	var level := levels[0]
	if level.has_method("on_door_entered"):
		level.call("on_door_entered", body)
