extends Node2D

@onready var heartsContainer = $CanvasLayer/hearts_container
@onready var deathMenu = $CanvasLayer/DeathMenu
@onready var player = $CharacterBody2D
@onready var canvas_layer := $CanvasLayer

var _keys_count := 0
var _keys_container: HBoxContainer
var _KeysContainerScene := preload("res://objects/ui/inventory/keys_container.tscn")

const MAIN_MENU_SCENE := "res://scenes/level2.tscn"
const DIALOGUE_TRIGGER_SCENE := preload("res://objects/ui/dialogue/dialogue_trigger.tscn")

const LEVEL1_DIALOGUE_TRIGGERS := {
	"level1_stealth_tutorial": {"position": Vector2(1200, 580), "size": Vector2(500, 220)},
	"level1_scrawled_note": {"position": Vector2(900, 320), "size": Vector2(220, 180)},
	"level1_rival": {"position": Vector2(2200, 520), "size": Vector2(400, 200)},
	"level1_puzzle": {"position": Vector2(3000, 550), "size": Vector2(350, 200)},
	"level1_exit": {"position": Vector2(3550, 580), "size": Vector2(280, 160)},
	"hook_k": {"position": Vector2(616, 150), "size": Vector2(120, 100)},
}

var _screen_shader := preload("res://assets/shaders/screen_blur_dim.gdshader")
var _victory_font := preload("res://assets/font/Gwenchana.ttf")
var _stealth_overlay: ColorRect
var _victory_overlay: Control
var _victory_in_progress := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = false
	deathMenu.hide_immediate()
	heartsContainer.setMaxHearts(player.maxHealth)
	heartsContainer.updateHearts(player.currentHealth)
	add_to_group("key_listeners")
	add_to_group("level")

	_keys_container = _KeysContainerScene.instantiate()
	canvas_layer.add_child(_keys_container)
	(_keys_container as Node).set_key_count(_keys_count)
	_setup_stealth_overlay()
	_setup_victory_overlay()
	if not player.health_changed.is_connected(_on_player_health_changed):
		player.health_changed.connect(_on_player_health_changed)
	if not player.died.is_connected(_on_player_died):
		player.died.connect(_on_player_died)
	if player.has_signal("stealth_changed") and not player.stealth_changed.is_connected(_on_player_stealth_changed):
		player.stealth_changed.connect(_on_player_stealth_changed)
	_setup_dialogue_triggers()
	call_deferred("_start_level_dialogue")

func _setup_dialogue_triggers() -> void:
	var root := Node2D.new()
	root.name = "DialogueTriggers"
	add_child(root)
	for title: String in LEVEL1_DIALOGUE_TRIGGERS:
		var data: Dictionary = LEVEL1_DIALOGUE_TRIGGERS[title]
		var trigger: Area2D = DIALOGUE_TRIGGER_SCENE.instantiate()
		trigger.dialogue_title = title
		trigger.trigger_size = data.get("size", Vector2(160, 120))
		trigger.position = data.get("position", Vector2.ZERO)
		root.add_child(trigger)

func _start_level_dialogue() -> void:
	DialogueService.play("level1_opening", player)

func _on_player_health_changed(current_health: int, _max_health: int) -> void:
	heartsContainer.updateHearts(current_health)

func _on_player_died(_reason: StringName) -> void:
	deathMenu.show_death_menu()

func on_key_collected() -> void:
	_keys_count += 1
	if _keys_container != null:
		(_keys_container as Node).set_key_count(_keys_count)
	DialogueService.play("level1_first_key", player)

func on_door_entered(_body: Node) -> void:
	if _victory_in_progress or DialogueService.is_active:
		return
	if _keys_count <= 0:
		return
	_finish_level1()

func _finish_level1() -> void:
	if not DialogueService.has_played("level1_exit"):
		await DialogueService.play_and_wait("level1_exit", player, true)
	await DialogueService.play_and_wait("level1_transition", player, true)
	_play_victory_sequence()

func _setup_stealth_overlay() -> void:
	_stealth_overlay = ColorRect.new()
	_stealth_overlay.name = "StealthOverlay"
	_stealth_overlay.visible = false
	_stealth_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stealth_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)

	var mat := ShaderMaterial.new()
	mat.shader = _screen_shader
	mat.set_shader_parameter("strength", 1.1)
	mat.set_shader_parameter("dim", 0.18)
	_stealth_overlay.material = mat

	canvas_layer.add_child(_stealth_overlay)

func _setup_victory_overlay() -> void:
	_victory_overlay = Control.new()
	_victory_overlay.name = "VictoryOverlay"
	_victory_overlay.visible = false
	_victory_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_victory_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas_layer.add_child(_victory_overlay)

	var blur := ColorRect.new()
	blur.name = "Blur"
	blur.mouse_filter = Control.MOUSE_FILTER_IGNORE
	blur.set_anchors_preset(Control.PRESET_FULL_RECT)

	var mat := ShaderMaterial.new()
	mat.shader = _screen_shader
	mat.set_shader_parameter("strength", 1.6)
	mat.set_shader_parameter("dim", 0.45)
	blur.material = mat
	_victory_overlay.add_child(blur)

	var label := Label.new()
	label.name = "Title"
	label.text = "Victory"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchor(SIDE_LEFT, 0)
	label.set_anchor(SIDE_TOP, 0)
	label.set_anchor(SIDE_RIGHT, 1)
	label.set_anchor(SIDE_BOTTOM, 1)
	label.offset_left = 0
	label.offset_top = 0
	label.offset_right = 0
	label.offset_bottom = 0
	label.add_theme_font_override("font", _victory_font)
	label.add_theme_font_size_override("font_size", 96)
	label.add_theme_color_override("font_color", Color(1, 0.96, 0.82, 1))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	label.add_theme_constant_override("outline_size", 10)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.55))
	label.add_theme_constant_override("shadow_offset_x", 0)
	label.add_theme_constant_override("shadow_offset_y", 10)
	_victory_overlay.add_child(label)

func _on_player_stealth_changed(active: bool) -> void:
	if _stealth_overlay != null:
		_stealth_overlay.visible = active

func _play_victory_sequence() -> void:
	_victory_in_progress = true

	# Freeze player input/movement so we can show the cinematic.
	if player:
		player.velocity = Vector2.ZERO
		player.set_physics_process(false)
		player.set_process_input(false)

	var audio := player.get_node_or_null("AudioController")
	if audio and audio.has_method("play_victory"):
		audio.call("play_victory")

	if _victory_overlay:
		_victory_overlay.visible = true

	var prev_time_scale := Engine.time_scale
	Engine.time_scale = 0.35

	# Let it breathe for ~1s in slow motion (real time).
	await get_tree().create_timer(1.0, true).timeout

	Engine.time_scale = prev_time_scale
	await LevelTransition.change_scene(MAIN_MENU_SCENE)
