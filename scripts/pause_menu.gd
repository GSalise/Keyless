extends Control

func _ready():
	$AnimationPlayer.play("RESET")
	visible = false

func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	await $AnimationPlayer.animation_finished
	visible = false

func pause():
	visible = true
	get_tree().paused = true
	$AnimationPlayer.play("blur")

func testEsc():
	if Input.is_action_just_pressed("escape") and not get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("escape") and get_tree().paused:
		resume()

func _on_resume_pressed() -> void:
	resume()


func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	visible = false
	get_tree().change_scene_to_file("res://objects/ui/main-menu/main_menu.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()

func _process(delta):
	testEsc()
