extends Node2D

@export var mute: bool = false

## Optional: point this at your Player node so we can auto-connect.
@export var player_path: NodePath

@onready var run_player: AudioStreamPlayer2D = $Run
@onready var jump_player: AudioStreamPlayer2D = $Jump
@onready var death_player: AudioStreamPlayer2D = $death
@onready var victory_player: AudioStreamPlayer2D = $victory

var _is_running: bool = false

func _ready() -> void:
	run_player.finished.connect(_on_run_finished)
	# Death SFX must play while the game is paused (death menu), so it cannot be PAUSABLE.
	death_player.process_mode = Node.PROCESS_MODE_ALWAYS
	victory_player.process_mode = Node.PROCESS_MODE_ALWAYS

	var player: Node = null
	if player_path != NodePath():
		player = get_node_or_null(player_path)
	if player == null and get_parent() and get_parent().has_signal("jumped"):
		player = get_parent()
	if player == null:
		var players := get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			player = players[0]
	if player:
		_connect_player(player)

func _connect_player(player: Node) -> void:
	# Player is expected to expose these signals.
	if player.has_signal("started_running"):
		player.connect("started_running", _on_player_started_running)
	if player.has_signal("stopped_running"):
		player.connect("stopped_running", _on_player_stopped_running)
	if player.has_signal("jumped"):
		player.connect("jumped", _on_player_jumped)
	if player.has_signal("died"):
		player.connect("died", _on_player_died)

func _on_player_started_running() -> void:
	_is_running = true
	_try_play_run()

func _on_player_stopped_running() -> void:
	_is_running = false
	if run_player.playing:
		run_player.stop()

func _on_player_jumped() -> void:
	if mute:
		return
	if jump_player.playing:
		jump_player.stop()
	jump_player.play()

func _on_player_died(_reason: StringName) -> void:
	_is_running = false
	if run_player.playing:
		run_player.stop()
	if mute:
		return
	if death_player.playing:
		death_player.stop()
	death_player.play()

func _on_run_finished() -> void:
	# Footstep WAVs usually don't loop; replay while still running.
	if _is_running:
		_try_play_run()

func _try_play_run() -> void:
	if mute:
		return
	if not _is_running:
		return
	if run_player.playing:
		return
	run_player.play()

func stop_movement_sfx() -> void:
	_is_running = false
	if run_player.playing:
		run_player.stop()

func play_victory() -> void:
	stop_movement_sfx()
	if mute:
		return
	if victory_player.playing:
		victory_player.stop()
	victory_player.play()
