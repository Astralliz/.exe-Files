extends CanvasLayer

@onready var progress_bar = $ProgressBar
@onready var label = $Label

var _target_path = ""
var _loading := false

func _ready():
	visible = false

func load_scene(path: String):
	visible = true
	progress_bar.value = 0
	_target_path = path
	_loading = true

	ResourceLoader.load_threaded_request(path)

func _process(delta):
	if not _loading:
		return

	var progress := []
	var status = ResourceLoader.load_threaded_get_status(_target_path, progress)

	if progress.size() > 0:
		progress_bar.value = progress[0] * 100

	match status:
		ResourceLoader.THREAD_LOAD_LOADED:
			var scene = ResourceLoader.load_threaded_get(_target_path)
			get_tree().change_scene_to_packed(scene)
			_loading = false
			visible = false

		ResourceLoader.THREAD_LOAD_FAILED:
			print("Failed to load: ", _target_path)
			_loading = false
			visible = false
