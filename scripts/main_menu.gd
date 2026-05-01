extends Control

func _setup_button_fx(btn: BaseButton) -> void:
	btn.pivot_offset = btn.size / 2.0
	btn.mouse_entered.connect(func():
		var t := create_tween()
		t.tween_property(btn, "scale", Vector2(1.04, 1.04), 0.10).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	)
	btn.mouse_exited.connect(func():
		var t := create_tween()
		t.tween_property(btn, "scale", Vector2.ONE, 0.10).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	)
	btn.button_down.connect(func():
		var t := create_tween()
		t.tween_property(btn, "scale", Vector2(0.98, 0.98), 0.06).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	)
	btn.button_up.connect(func():
		var target := Vector2.ONE
		if btn.is_hovered():
			target = Vector2(1.04, 1.04)
		var t := create_tween()
		t.tween_property(btn, "scale", target, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	_setup_button_fx($VBoxContainer/Start)
	_setup_button_fx($VBoxContainer/Exit)


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/prison_lvl_1.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
