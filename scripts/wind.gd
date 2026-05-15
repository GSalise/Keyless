extends Node2D

## Level-placed wind VFX — uses AnimatedSprite2D configured in wind.tscn.

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

var _active := false


func _ready() -> void:
	visible = false
	_sprite.visible = false
	_sprite.stop()


func set_floating(active: bool, is_rising: bool, _vertical_speed: float = 0.0) -> void:
	_active = active
	visible = active
	_sprite.visible = active

	if not active:
		_sprite.stop()
		return

	_sprite.flip_v = not is_rising

	if not _sprite.is_playing():
		_sprite.play(&"wind")
