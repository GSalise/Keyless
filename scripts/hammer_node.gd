extends Node2D

@export var start_frame: int = 0
@export var anim_speed: float = 1.0

@onready var anim = $AnimatedSprite2D
@onready var collision = $AnimatedSprite2D/Area2D/CollisionShape2D

func _ready():
	anim.play("default")
	anim.frame = start_frame
	anim.speed_scale = anim_speed
	anim.frame_changed.connect(_on_frame_changed)
	collision.disabled = true

func _on_frame_changed():
	collision.disabled = anim.frame not in [2, 3, 4, 5]

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("request_death"):
		body.request_death(&"hammer")
 
