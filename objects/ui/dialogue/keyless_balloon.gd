extends DialogueManagerExampleBalloon

var _story_font := preload("res://assets/font/Gwenchana.ttf")


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	super._ready()
	_apply_font(character_label)
	_apply_font(dialogue_label)


func _apply_font(control: Control) -> void:
	if _story_font:
		control.add_theme_font_override("normal_font", _story_font)
		control.add_theme_font_override("font", _story_font)
	control.add_theme_font_size_override("normal_font_size", 22)
	control.add_theme_color_override("default_color", Color(0.92, 0.9, 0.82, 1))


func apply_dialogue_line() -> void:
	super.apply_dialogue_line()
	if dialogue_line.character in ["—", "..."]:
		character_label.visible = false
	elif dialogue_line.character == "You":
		character_label.text = tr("You", "dialogue")
		character_label.modulate = Color(0.75, 0.82, 0.95, 0.9)
