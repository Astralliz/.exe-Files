extends Node2D



# -------------------------------------------------
# PAPER NODES (TextureRect)
# -------------------------------------------------
@onready var _paper : TextureRect = $File_Document
@onready var _list : TextureRect = $Check_List

# Metadata labels inside VBoxContainer
@onready var vbox : VBoxContainer = _paper.get_node("VBoxContainer")
@onready var lbl_filename : Label = vbox.get_node("Label_Filename")
@onready var lbl_extension : Label = vbox.get_node("Label_Extension")
@onready var lbl_size : Label = vbox.get_node("Label_Size")
@onready var lbl_publisher : Label = vbox.get_node("Label_Publisher")
@onready var lbl_source : Label = vbox.get_node("Label_Source")

# -------------------------------------------------
# UI NODES
# -------------------------------------------------
@onready var container : VBoxContainer = _list.get_node("container")
@onready var cb_file_name  : CheckBox = $Check_List/VBoxContainer/FileName
@onready var cb_invalid_signature : CheckBox = $Check_List/VBoxContainer/Extension
@onready var cb_src_email : CheckBox = $Check_List/VBoxContainer/FileSize
@onready var cb_size_large : CheckBox = $Check_List/VBoxContainer/Publisher
@onready var cb_size_large2 : CheckBox = $Check_List/VBoxContainer/Source

@onready var btn_evaluate : Button = $Check_List/VBoxContainer/EvaluateButton

@onready var result_label : Label = $Check_List/VBoxContainer/ResultLabel

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

# -------------------------
# LIST NODE VARIABLES
# -------------------------
var _list_state := 0  # 0 = closed, 1 = open

var _list_closed_texture := preload("res://Assets/Sprites/paper_down_ask.png")
var _list_open_texture := preload("res://Assets/Sprites/large-paper.png")

const LIST_CLOSED_SCALE := Vector2(0.4, 0.4)
const LIST_OPEN_SCALE := Vector2(0.35, 0.5)

var _list_closed_pos := Vector2(100, 300)
var _list_open_pos := Vector2(100, 120)

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
	_paper.position = _paper_fall_start_pos 
	_paper.z_index = 0

	update_font_size_for_state(_state)
	
	_resize_checkboxes(Vector2(132, 132))  # makes the checkbox square bigger

	_spawn_paper_animation()
	_paper.gui_input.connect(_on_paper_clicked)

	# Initialize _list
	if _list:
		_list.texture = _list_closed_texture
		_list.scale = LIST_CLOSED_SCALE
		_list.position = _list_closed_pos
		_list.z_index = 5
		container.visible = false
		_list.gui_input.connect(_on_list_clicked)

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
	tween.tween_property(_paper, "position", _paper_fall_end_pos, 1.0)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)\
		.set_delay(0.2)

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

# -------------------------------------------------
# LIST ANIMATION AND CLICK HANDLER
# -------------------------------------------------
func _on_list_clicked(event):
	if event is InputEventMouseButton and event.pressed:
		_handle_list_behavior()

func _handle_list_behavior():
	if not _list:
		return

	if _list_state == 0:
		_list.texture = _list_open_texture
		_list.position = _list_open_pos
		_list.scale = LIST_OPEN_SCALE
		container.visible = true
		_list_state = 1
	else:
		_list.texture = _list_closed_texture
		_list.position = _list_closed_pos
		_list.scale = LIST_CLOSED_SCALE
		container.visible = false
		_list_state = 0
# Example: change the size of checkboxes
func _resize_checkboxes(size: Vector2) -> void:
	var checkboxes = [cb_file_name, cb_invalid_signature, cb_src_email, cb_size_large, cb_size_large2]
	for cb in checkboxes:
		if cb:
			# Minimum size of the checkbox square
			cb.add_theme_constant_override("check_min_size", int(size.x))
			# Optional: scale the icon
			cb.add_theme_constant_override("icon_scale", size.x / 16.0) # 16 = default size
# -------------------------------------------------
# UPDATE LABEL TEXT
# -------------------------------------------------
func _update_paper_labels(data: FileMetadata) -> void:
	lbl_filename.text = "Filename: %s" % data.filename
	lbl_extension.text = "Extension: %s" % data.extension
	lbl_size.text = "Size: %.2f MB" % data.size_mb
	lbl_publisher.text = "Publisher: %s" % data.publisher
	lbl_source.text = "Source: %s" % data.source
