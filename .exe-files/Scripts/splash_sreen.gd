extends CanvasLayer

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var spinning_icon: TextureRect = $TextureRect

var duration := 2.0
var elapsed := 0.0

var _tween: Tween
var _progress := 0.0

# ✅ SPIN SYSTEM
var _spin_speed := 4.0
var _spinning := false


func _ready():
	visible = true
	progress_bar.value = 0
	progress_bar.max_value = 100

	# ✅ Wait for layout → ensures correct pivot
	await get_tree().process_frame
	spinning_icon.pivot_offset = spinning_icon.size / 2.0
	spinning_icon.rotation = 0.0

	_start_spinning()
	_start_splash()


# =========================
# SPLASH FLOW
# =========================
func _start_splash():
	await get_tree().create_timer(0.1).timeout

	# Smooth fake loading
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(self, "_progress", 100.0, duration)

	await _tween.finished

	_go_to_menu()


# =========================
# PROCESS LOOP
# =========================
func _process(delta):
	elapsed += delta

	# ✅ INDEPENDENT SPIN (ALWAYS SMOOTH)
	if _spinning:
		spinning_icon.rotation += _spin_speed * delta
		spinning_icon.rotation = fmod(spinning_icon.rotation, TAU)

	# Update progress bar
	progress_bar.value = _progress


# =========================
# SPIN CONTROL
# =========================
func _start_spinning():
	_spinning = true


func _stop_spinning():
	_spinning = false
	spinning_icon.rotation = 0.0


# =========================
# SCENE CHANGE
# =========================
func _go_to_menu():
	_stop_spinning()
	get_tree().change_scene_to_file("res://Scenes/Menu Scenes/main_menu.tscn")
