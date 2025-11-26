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

# Metadata labels inside VBoxContainer
@onready var vbox : VBoxContainer = _paper.get_node("VBoxContainer")
@onready var lbl_filename : Label = vbox.get_node("Label_Filename")
@onready var lbl_extension : Label = vbox.get_node("Label_Extension")
@onready var lbl_size : Label = vbox.get_node("Label_Size")
@onready var lbl_publisher : Label = vbox.get_node("Label_Publisher")
@onready var lbl_source : Label = vbox.get_node("Label_Source")

# Load textures
var _paper_original_texture := preload("res://Assets/Sprites/large-paper.png")
var _paper_open_texture := preload("res://Assets/Sprites/paper_down.png")
var _paper_original_texture_2 := preload("res://Assets/Sprites/large-paper.png")

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

const PRINTED_SCALE = Vector2(0.7, 0.7)
const ZOOM_SCALE = Vector2(1.5, 1.5)
const ZOOM_SCALE_2 = Vector2(0.35, 0.5)
const PAPER_DOWN_SCALE = Vector2(0.4, 0.4)

# -------------------------
# FIXED FONT SIZES FOR STATES
# -------------------------
const FONT_SIZE_STATE_0 := 18   # on desk (state 0)
const FONT_SIZE_STATE_1 := 60    # zoomed (state 1)
const FONT_SIZE_STATE_2 := 16   # paper_down (state 2)

# Metadata generator
var generator := MetadataGenerator.new()
var metadata : FileMetadata

func _ready():
	if _paper == null:
		push_error("File_Document TextureRect not found!")
		return

	# Generate new metadata
	metadata = generator.generate_metadata()
	_update_paper_labels(metadata)

	# Initial state (desk)
	_state = 0
	_paper.texture = _paper_original_texture
	_paper.scale = PRINTED_SCALE
	_paper.position = _paper_fall_end_pos
	_paper.z_index = 0

	update_font_size_for_state(_state)

	_spawn_paper_animation()
	_paper.gui_input.connect(_on_paper_clicked)


# -------------------------------------------------
# FONT SIZE LOGIC (FIXED PER STATE)
# -------------------------------------------------
func update_font_size_for_state(state: int) -> void:
	var labels = [lbl_filename, lbl_extension, lbl_size, lbl_publisher, lbl_source]

	var size_to_use: int

	match state:
		0:
			size_to_use = FONT_SIZE_STATE_0
		1:
			size_to_use = FONT_SIZE_STATE_1
		2:
			size_to_use = FONT_SIZE_STATE_2
		_:
			size_to_use = FONT_SIZE_STATE_0

	for lbl in labels:
		if lbl:
			lbl.add_theme_font_size_override("font_size", size_to_use)
			lbl.queue_redraw()


# -------------------------------------------------
# PAPER ANIMATION
# -------------------------------------------------
func _spawn_paper_animation() -> void:
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
	match _state:

		0: # desk → zoom
			_paper.texture = _paper_original_texture
			_paper.scale = ZOOM_SCALE
			_paper.position = _paper_center_pos
			_paper.z_index = 10

			vbox.visible = true
			_state = 1
			update_font_size_for_state(2)

		1: # zoom → paper_down
			_paper.texture = _paper_open_texture
			_paper.scale = PAPER_DOWN_SCALE
			_paper.position = _paper_down_pos
			_paper.z_index = 10

			vbox.visible = false
			_state = 2
			update_font_size_for_state(_state)

		2: # paper_down → alternate zoom
			_paper.texture = _paper_original_texture
			_paper.scale = ZOOM_SCALE_2
			_paper.position = _paper_center_pos_2
			_paper.z_index = 10

			vbox.visible = true
			_state = 1
			update_font_size_for_state(_state)


# -------------------------------------------------z
# UPDATE LABEL TEXT
# -------------------------------------------------
func _update_paper_labels(data: FileMetadata) -> void:
	lbl_filename.text = "Filename: %s" % data.filename
	lbl_extension.text = "Extension: %s" % data.extension
	lbl_size.text = "Size: %.2f MB" % data.size_mb
	lbl_publisher.text = "Publisher: %s" % data.publisher
	lbl_source.text = "Source: %s" % data.source
