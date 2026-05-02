extends PathFollow2D

var speed = 0.5
var _collected := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# The scene currently uses a StaticBody2D, which doesn't emit body_entered.
	# Add a lightweight Area2D trigger at runtime so we can detect pickup.
	var static_body := get_node_or_null("StaticBody2D")
	if static_body == null:
		return

	var collision_shape: CollisionShape2D = static_body.get_node_or_null("CollisionShape2D")
	if collision_shape == null or collision_shape.shape == null:
		return

	var area := Area2D.new()
	area.name = "PickupArea"
	area.monitoring = true
	area.monitorable = true
	add_child(area)

	var area_shape := CollisionShape2D.new()
	area_shape.name = "CollisionShape2D"
	area_shape.shape = collision_shape.shape
	area_shape.position = collision_shape.position
	area.add_child(area_shape)

	if not area.body_entered.is_connected(_on_pickup_area_body_entered):
		area.body_entered.connect(_on_pickup_area_body_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	progress_ratio += delta * speed

func _on_pickup_area_body_entered(body: Node) -> void:
	if _collected:
		return
	if not (body is CharacterBody2D):
		return
	_collected = true

	get_tree().call_group("key_listeners", "on_key_collected")
	queue_free()
