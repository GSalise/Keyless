extends Node2D

@onready var heartsContainer = $CanvasLayer/hearts_container
@onready var deathMenu = $CanvasLayer/DeathMenu
@onready var player = $CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = false
	deathMenu.hide_immediate()
	heartsContainer.setMaxHearts(player.maxHealth)
	heartsContainer.updateHearts(player.currentHealth)
	if not player.health_changed.is_connected(_on_player_health_changed):
		player.health_changed.connect(_on_player_health_changed)
	if not player.died.is_connected(_on_player_died):
		player.died.connect(_on_player_died)

func _on_player_health_changed(current_health: int, _max_health: int) -> void:
	heartsContainer.updateHearts(current_health)

func _on_player_died(_reason: StringName) -> void:
	deathMenu.show_death_menu()
