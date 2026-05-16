extends Node2D

@onready var heartsContainer = $CanvasLayer/hearts_container
@onready var deathMenu = $CanvasLayer/DeathMenu
@onready var player: CharacterBody2D = $CharacterBody2D
@onready var canvas_layer := $CanvasLayer

var _keys_count := 0
var _keys_container: HBoxContainer
var _KeysContainerScene := preload("res://objects/ui/inventory/keys_container.tscn")

const LEVEL_3_SCENE := "res://scenes/level_3.tscn"

var _screen_shader := preload("res://assets/shaders/screen_blur_dim.gdshader")
var _stealth_overlay: ColorRect
var _travel_in_progress := false


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
	if not player.health_changed.is_connected(_on_player_health_changed):
		player.health_changed.connect(_on_player_health_changed)
	if not player.died.is_connected(_on_player_died):
		player.died.connect(_on_player_died)
	if player.has_signal("stealth_changed") and not player.stealth_changed.is_connected(_on_player_stealth_changed):
		player.stealth_changed.connect(_on_player_stealth_changed)
	call_deferred("_start_hub_dialogue")


func _start_hub_dialogue() -> void:
	DialogueService.play("level2_level3_transition", player)


func _on_player_health_changed(current_health: int, _max_health: int) -> void:
	heartsContainer.updateHearts(current_health)


func _on_player_died(_reason: StringName) -> void:
	deathMenu.show_death_menu()


func on_key_collected() -> void:
	_keys_count += 1
	if _keys_container != null:
		(_keys_container as Node).set_key_count(_keys_count)


func on_exit_to_level_three(_body: Node) -> void:
	if _travel_in_progress or DialogueService.is_active:
		return
	_travel_in_progress = true
	if player:
		player.velocity = Vector2.ZERO
		player.set_physics_process(false)
		player.set_process_input(false)
	await LevelTransition.change_scene(LEVEL_3_SCENE)


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


func _on_player_stealth_changed(active: bool) -> void:
	if _stealth_overlay != null:
		_stealth_overlay.visible = active
