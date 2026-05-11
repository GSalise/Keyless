extends HBoxContainer

@onready var KeyGuiScene := preload("res://objects/ui/inventory/keys_gui.tscn")

func set_key_count(count: int) -> void:
	for child in get_children():
		child.queue_free()
	for _i in range(count):
		var key_gui := KeyGuiScene.instantiate()
		add_child(key_gui)
