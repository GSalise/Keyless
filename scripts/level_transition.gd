extends CanvasLayer

const DEFAULT_FADE_DURATION := 0.55

var _fade: ColorRect
var _busy := false


func _ready() -> void:
	layer = 120
	process_mode = Node.PROCESS_MODE_ALWAYS
	_fade = ColorRect.new()
	_fade.name = "Fade"
	_fade.color = Color(0.02, 0.02, 0.03, 1)
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.modulate = Color(1, 1, 1, 0)
	_fade.visible = false
	add_child(_fade)


func is_busy() -> bool:
	return _busy


func change_scene(scene_path: String, fade_duration: float = DEFAULT_FADE_DURATION) -> void:
	if _busy or scene_path.is_empty():
		return
	_busy = true
	await fade_out(fade_duration)
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	await fade_in(fade_duration)
	_busy = false


func fade_out(duration: float = DEFAULT_FADE_DURATION) -> void:
	_fade.visible = true
	_fade.modulate.a = 0.0
	var tween := _make_tween()
	tween.tween_property(_fade, "modulate:a", 1.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await tween.finished


func fade_in(duration: float = DEFAULT_FADE_DURATION) -> void:
	_fade.modulate.a = 1.0
	_fade.visible = true
	var tween := _make_tween()
	tween.tween_property(_fade, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween.finished
	_fade.visible = false


func _make_tween() -> Tween:
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	return tween
