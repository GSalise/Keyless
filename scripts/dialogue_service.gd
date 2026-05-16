extends Node

const DIALOGUE_RESOURCE := preload("res://objects/ui/dialogue/dialogue.dialogue")
const BALLOON_SCENE := preload("res://objects/ui/dialogue/keyless_balloon.tscn")

signal dialogue_finished(title: String)

var is_active := false

var _played: Dictionary = {}
var _current_title := ""
var _player: CharacterBody2D
var _was_tree_paused := false


func _ready() -> void:
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)


func has_played(title: String) -> bool:
	return _played.get(title, false)


func play(title: String, player: CharacterBody2D = null, force: bool = false) -> bool:
	if is_active:
		return false
	if title.is_empty():
		return false
	if not force and has_played(title):
		return false

	_played[title] = true
	_current_title = title
	_player = player
	is_active = true

	if _player:
		_freeze_player(true)

	_was_tree_paused = get_tree().paused
	get_tree().paused = true

	var states: Array = [self]
	if _player:
		states.append(_player)

	DialogueManager.show_dialogue_balloon_scene(BALLOON_SCENE, DIALOGUE_RESOURCE, title, states)
	return true


func play_and_wait(title: String, player: CharacterBody2D = null, force: bool = false) -> void:
	if not play(title, player, force):
		return
	await dialogue_finished


func _on_dialogue_ended(_resource: DialogueResource) -> void:
	var finished_title := _current_title
	is_active = false
	_current_title = ""

	get_tree().paused = _was_tree_paused

	if _player:
		_freeze_player(false)
		_player = null

	dialogue_finished.emit(finished_title)


func _freeze_player(frozen: bool) -> void:
	if _player == null:
		return
	if frozen:
		_player.velocity = Vector2.ZERO
		_player.set_physics_process(false)
		_player.set_process_input(false)
	else:
		_player.set_physics_process(true)
		_player.set_process_input(true)
