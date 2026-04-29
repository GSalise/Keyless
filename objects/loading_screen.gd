extends CanvasLayer


@onready var progress_bar: ProgressBar = $Center/Card/VBox/ProgressBar
@export var next_scene_path: String = "res://objects/main_menu.tscn"
@export var minimum_show_time: float = 1.25
var progress: Array[float] = []
var _ready_to_enter_next_scene: bool = false
var _time_elapsed: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	ResourceLoader.load_threaded_request(next_scene_path)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_time_elapsed += delta
	var status = ResourceLoader.load_threaded_get_status(next_scene_path, progress)
	
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			var pct := 0.0
			if not progress.is_empty():
				pct = progress[0] * 100.0
			progress_bar.value = pct
		ResourceLoader.THREAD_LOAD_LOADED:
			progress_bar.value = 100.0
			_ready_to_enter_next_scene = true

	if _ready_to_enter_next_scene and _time_elapsed >= minimum_show_time:
		var scene: PackedScene = ResourceLoader.load_threaded_get(next_scene_path)
		get_tree().change_scene_to_packed(scene)
