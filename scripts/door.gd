extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if not (body is CharacterBody2D):
		return
	var levels := get_tree().get_nodes_in_group("level")
	if levels.is_empty():
		return
	var level := levels[0]
	if level.has_method("on_door_entered"):
		level.call("on_door_entered", body)
