extends CanvasLayer

@onready var progress_bar = $ProgressBar
@onready var label = $Label
@onready var spinning_icon: TextureRect = $TextureRect

var _target_path = ""
var _loading := false

var _display_progress := 0.0
var _actual_progress := 0.0

var _tween: Tween

# =========================
# SPIN SYSTEM (INDEPENDENT)
# =========================
var _spin_speed := 4.0  # radians per second (~1 full spin ~1.5s)
var _spinning := false

# =========================
# CUSTOM BEHAVIOR
# =========================
var _custom_text: String = ""
var _min_load_time: float = 0.0
var _elapsed_time: float = 0.0
var _use_timer_mode := false


func _ready():
	visible = false
	progress_bar.value = 0
	progress_bar.max_value = 100

	# Wait for layout so size is correct
	await get_tree().process_frame
	
	# ✅ Center pivot → true spin in place
	spinning_icon.pivot_offset = spinning_icon.size / 2.0
	spinning_icon.rotation = 0.0


# =========================
# LOAD FUNCTION
# =========================
func load_scene(path: String, text: String = "", min_time: float = 0.0):
	visible = true
	progress_bar.value = 0

	_display_progress = 0.0
	_actual_progress = 0.0

	_target_path = path
	_loading = true

	_custom_text = text
	_min_load_time = min_time
	_elapsed_time = 0.0
	_use_timer_mode = (text != "" or min_time > 0.0)

	if _tween:
		_tween.kill()

	_start_spinning()

	await get_tree().create_timer(0.1).timeout
	ResourceLoader.load_threaded_request(path)


# =========================
# SPIN CONTROL
# =========================
func _start_spinning():
	_spinning = true


func _stop_spinning():
	_spinning = false
	spinning_icon.rotation = 0.0


# =========================
# PROCESS LOOP
# =========================
func _process(delta):
	# 🔥 INDEPENDENT SPIN (ALWAYS SMOOTH)
	if _spinning:
		spinning_icon.rotation += _spin_speed * delta
		spinning_icon.rotation = fmod(spinning_icon.rotation, TAU)

	if not _loading:
		return

	_elapsed_time += delta

	var progress := []
	var status = ResourceLoader.load_threaded_get_status(_target_path, progress)

	# Update actual progress
	if progress.size() > 0:
		_actual_progress = progress[0] * 100

	# Smooth progress
	_display_progress = lerp(_display_progress, _actual_progress, delta * 5.0)
	progress_bar.value = _display_progress

	# =========================
	# LABEL TEXT
	# =========================
	if _custom_text != "":
		label.text = _custom_text
	else:
		label.text = "%d%%" % int(_display_progress)

	# =========================
	# ICON FOLLOW LABEL
	# =========================
	_update_icon_position()

	match status:
		ResourceLoader.THREAD_LOAD_LOADED:

			# Wait minimum time if needed
			if _use_timer_mode and _elapsed_time < _min_load_time:
				return

			if _display_progress < 99.0:
				_animate_to_completion()
			else:
				_finish_loading()

		ResourceLoader.THREAD_LOAD_FAILED:
			print("Failed to load: ", _target_path)
			_loading = false
			visible = false
			_stop_spinning()


# =========================
# ICON POSITIONING
# =========================
func _update_icon_position():
	if label.text == "":
		return

	# Local positioning (prevents orbit bug)
	var label_end_x = label.position.x + label.size.x
	var label_center_y = label.position.y + (label.size.y / 2.0)

	spinning_icon.position = Vector2(
		label_end_x + 10,
		label_center_y - spinning_icon.size.y / 2.0
	)


# =========================
# FINISH ANIMATION
# =========================
func _animate_to_completion():
	if _tween:
		_tween.kill()

	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_CUBIC)
	_tween.set_ease(Tween.EASE_OUT)

	_tween.tween_property(self, "_display_progress", 100.0, 0.3)

	await _tween.finished
	_finish_loading()


# =========================
# FINAL STEP
# =========================
func _finish_loading():
	_stop_spinning()

	var scene = ResourceLoader.load_threaded_get(_target_path)
	get_tree().change_scene_to_packed(scene)

	_loading = false
	visible = false
