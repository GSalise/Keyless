extends Area2D
 
var speed: float = 400.0
var direction: Vector2 = Vector2.RIGHT
var damage: int = 1
 
func _ready() -> void:
	# Connect our own body_entered signal
	body_entered.connect(_on_body_entered)
 
	# Auto-destroy after 3 seconds in case it never hits anything
	var timer := Timer.new()
	timer.wait_time = 3.0
	timer.one_shot = true
	timer.timeout.connect(queue_free)
	add_child(timer)
	timer.start()
 
func _physics_process(delta: float) -> void:
	position += direction * speed * delta
 
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.take_damage(damage)
		queue_free()
	elif body is TileMapLayer or body is StaticBody2D:
		# Hit a wall or floor tile
		queue_free()
