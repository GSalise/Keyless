extends Control

@onready var panel_container: PanelContainer = $CenterContainer/PanelContainer
@onready var restart_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Restart
@onready var main_menu_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/MainMenu

func _ready() -> void:
	hide_immediate()
	_setup_button_fx(restart_button)
	_setup_button_fx(main_menu_button)

func show_death_menu() -> void:
	if visible:
		return
	visible = true
	get_tree().paused = true
	$AnimationPlayer.play("blur")
	restart_button.grab_focus()

func hide_immediate() -> void:
	get_tree().paused = false
	$AnimationPlayer.stop()
	$AnimationPlayer.play("RESET")
	$AnimationPlayer.seek(0.0, true)
	visible = false

func _setup_button_fx(btn: Button) -> void:
	btn.pivot_offset = btn.size / 2.0
	btn.resized.connect(func() -> void:
		btn.pivot_offset = btn.size / 2.0
	)

	btn.mouse_entered.connect(func() -> void:
		_animate_button_scale(btn, Vector2(1.04, 1.04), 0.10)
	)
	btn.mouse_exited.connect(func() -> void:
		_animate_button_scale(btn, Vector2.ONE, 0.10)
	)
	btn.focus_entered.connect(func() -> void:
		_animate_button_scale(btn, Vector2(1.04, 1.04), 0.10)
	)
	btn.focus_exited.connect(func() -> void:
		_animate_button_scale(btn, Vector2.ONE, 0.10)
	)

func _animate_button_scale(btn: Button, target_scale: Vector2, duration: float) -> void:
	var t := create_tween()
	t.tween_property(btn, "scale", target_scale, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_restart_pressed() -> void:
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	await $AnimationPlayer.animation_finished
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	await $AnimationPlayer.animation_finished
	get_tree().paused = false
	visible = false
	get_tree().change_scene_to_file("res://objects/ui/main-menu/main_menu.tscn")
