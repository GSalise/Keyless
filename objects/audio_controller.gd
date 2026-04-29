extends Node2D

@export var mute: bool = false

## Optional: point this at your Player node so we can auto-connect.
@export var player_path: NodePath

@onready var run_player: AudioStreamPlayer2D = $Run
@onready var jump_player: AudioStreamPlayer2D = $Jump

var _is_running: bool = false

func _ready() -> void:
	run_player.finished.connect(_on_run_finished)

	if player_path != NodePath():
		var player := get_node_or_null(player_path)
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
