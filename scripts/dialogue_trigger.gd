extends Area2D

@export var dialogue_title: String = ""
@export var trigger_size: Vector2 = Vector2(160, 120)
@export var one_shot: bool = true

var _triggered := false


func _ready() -> void:
	monitoring = true
	monitorable = false
	collision_layer = 1
	collision_mask = 17

	var shape_node := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = trigger_size
	shape_node.shape = rect
	add_child(shape_node)

	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _triggered and one_shot:
		return
	if not body is CharacterBody2D:
		return
	if not body.is_in_group("player"):
		return
	if dialogue_title.is_empty():
		return

	if DialogueService.play(dialogue_title, body):
		_triggered = true
		if one_shot:
			set_deferred("monitoring", false)
