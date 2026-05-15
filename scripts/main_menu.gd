extends Control

@onready var main_buttons: VBoxContainer = $MainButtons
@onready var options: Panel = $Options
@onready var btn_start: BaseButton = $MainButtons/StartGame
@onready var btn_settings: BaseButton = $MainButtons/Settings
@onready var btn_exit: BaseButton = $MainButtons/Exit
@onready var btn_back: BaseButton = $Options/Back
@onready var music_slider: HSlider = $Options/SettingsVBox/MusicSlider
@onready var sfx_slider: HSlider = $Options/SettingsVBox/SfxSlider

const MUSIC_BUS_NAME := "Music"
const SFX_BUS_NAME := "SFX"

func _setup_button_fx(btn: BaseButton) -> void:
	if btn == null:
		return
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
	get_tree().paused = false
	main_buttons.visible = true
	options.visible = false
	await get_tree().process_frame
	_setup_button_fx(btn_start)
	_setup_button_fx(btn_settings)
	_setup_button_fx(btn_exit)
	_setup_button_fx(btn_back)
	_sync_sliders_from_audio()


# func _on_start_pressed() -> void:
# 	get_tree().paused = false
# 	get_tree().change_scene_to_file("res://scenes/level2.tscn")

# Go to Testing Scene 
func _on_start_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/testing_area_scene.tscn")


func _on_settings_pressed() -> void:
	main_buttons.visible = false
	options.visible = true

func _on_exit_pressed() -> void:
	get_tree().quit()



func _on_back_options_pressed() -> void:
	options.visible = false
	main_buttons.visible = true


func _on_music_slider_value_changed(value: float) -> void:
	_set_bus_volume(MUSIC_BUS_NAME, value)


func _on_sfx_slider_value_changed(value: float) -> void:
	_set_bus_volume(SFX_BUS_NAME, value)


func _sync_sliders_from_audio() -> void:
	music_slider.value = _get_bus_volume_linear(MUSIC_BUS_NAME)
	sfx_slider.value = _get_bus_volume_linear(SFX_BUS_NAME)


func _get_bus_volume_linear(bus_name: String) -> float:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		bus_index = 0
	return db_to_linear(AudioServer.get_bus_volume_db(bus_index))


func _set_bus_volume(bus_name: String, linear_value: float) -> void:
	var clamped := clampf(linear_value, 0.0, 1.0)
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		bus_index = 0
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(maxf(clamped, 0.001)))
