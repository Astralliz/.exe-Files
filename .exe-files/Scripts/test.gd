extends Node2D

# -------------------------------------------------
# UI NODES
# -------------------------------------------------
@onready var cb_type_mismatch  : CheckBox = $panel/VBoxContainer/TypeMismatch
@onready var cb_invalid_signature : CheckBox = $panel/VBoxContainer/InvalidSignature
@onready var cb_src_email : CheckBox = $panel/VBoxContainer/SourceEmail
@onready var cb_size_large : CheckBox = $panel/VBoxContainer/SizeLarge

@onready var btn_evaluate : Button = $panel/VBoxContainer/EvaluateButton
@onready var btn_approve : Button = $panel/VBoxContainer/ApproveButton
@onready var btn_reject : Button = $panel/VBoxContainer/RejectButton

@onready var result_label : Label = $panel/VBoxContainer/ResultLabel

# -------------------------------------------------
# PAPER NODE (TextureRect)
# -------------------------------------------------
@onready var _paper : TextureRect = $File_Document

# Load textures
var _paper_original_texture := preload("res://Assets/Sprites/large-paper.png")
var _paper_open_texture := preload("res://Assets/Sprites/paper_down.png")

# STATES:
# 0 = desk / fallen
# 1 = zoomed
# 2 = paper_down texture
var _state := 0

# -------------------------
# PAPER POSITIONS & SCALES
# -------------------------
var _paper_fall_start_pos := Vector2(947, 174)
var _paper_fall_end_pos := Vector2(947, 324)
var _paper_center_pos : Vector2 = Vector2(400, 80)
var _paper_center_pos_2 : Vector2 = Vector2(700, 120)
var _paper_down_pos : Vector2 = Vector2(650, 310)

const PRINTED_SCALE = Vector2(0.7, 0.7)      # initial fallen size
const ZOOM_SCALE = Vector2(1.5, 1.5)  
const ZOOM_SCALE_2 = Vector2(0.35, 0.5)     # zoomed size
const PAPER_DOWN_SCALE = Vector2(0.4, 0.4) # paper_down size

func _ready():
	if _paper == null:
		push_error("File_Document TextureRect not found!")
		return

	# Initial state: desk/fallen (after falling animation)
	_state = 0
	_paper.texture = _paper_original_texture
	_paper.scale = PRINTED_SCALE
	_paper.position = _paper_fall_end_pos   # paper already on desk after fall
	_paper.z_index = 0  # behind printer (panel4)

	_spawn_paper_animation()
	_paper.gui_input.connect(_on_paper_clicked)

func _spawn_paper_animation() -> void:
	# Animate the falling from printer only
	if not is_instance_valid(_paper):
		print("ERROR: File_Document not found.")
		return

	var tween := create_tween()
	tween.tween_property(_paper, "position", _paper_fall_end_pos, 0.3)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

func _on_paper_clicked(event):
	if event is InputEventMouseButton and event.pressed:
		_handle_paper_behavior()

func _handle_paper_behavior():
	# -------------------------
	# State machine (no animation)
	# -------------------------
	match _state:
		0: # desk → zoom
			_paper.texture = _paper_original_texture
			_paper.scale = ZOOM_SCALE
			_paper.position = _paper_center_pos
			_paper.z_index = 10   # in front of printer
			_state = 1

		1: # zoom → paper_down
			_paper.texture = _paper_open_texture
			_paper.scale = PAPER_DOWN_SCALE
			_paper.position = _paper_down_pos
			_paper.z_index = 10   # stay in front
			_state = 2

		2: # paper_down → zoom
			_paper.texture = _paper_original_texture
			_paper.scale = ZOOM_SCALE_2
			_paper.position = _paper_center_pos_2
			_paper.z_index = 10   # stay in front
			_state = 1
