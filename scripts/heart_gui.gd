extends Panel
@onready var sprite = $Sprite2D

func set_whole(whole: bool) -> void:
	if whole: sprite.frame = 0
	else: sprite.frame = 2
