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
const FONT_SIZE_STATE_1 := 60   # zoomed (state 1)
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

# -------------------------
# Elton / Filetizen variables
# -------------------------
@onready var filetizen = $Filetizen
@onready var spawner_component: SpawnerComponent = $SpawnerComponent
@onready var actors: Node2D = $Actors
@onready var approve_btn: Button = $ApproveBtn
@onready var decline_btn: Button = $DeclineBtn

const HeuristicEngine = preload("res://Scripts/Algorithm/heuristic_engine.gd")
const RuleBase = preload("res://Scripts/Algorithm/Rules/rule_base.gd")

var engine := HeuristicEngine.new()
var rule_base := RuleBase.new()

var moved_out := false

func _ready():
	enable_buttons(false)
	spawn_new_filetizen()
	move_filetizen_to_center()

	_initialize_paper()
	_resize_checkboxes(Vector2(132, 132))  # makes the checkbox square bigger

	# Initialize _list
	if _list:
		_list.texture = _list_closed_texture
		_list.scale = LIST_CLOSED_SCALE
		_list.position = _list_closed_pos
		_list.z_index = 5
		container.visible = false
		_list.gui_input.connect(_on_list_clicked)

# -------------------------
# PAPER INITIALIZATION / RESET
# -------------------------
func _initialize_paper():
	if not is_instance_valid(_paper):
		push_error("File_Document TextureRect not found!")
		return

	# Reset the existing paper properties
	_paper.texture = _paper_original_texture
	_paper.scale = PRINTED_SCALE
	_paper.position = _paper_fall_start_pos
	_paper.z_index = 0

	# Generate new metadata from the current Filetizen
	metadata = filetizen.metadata
	_update_paper_labels(metadata)

	_state = 0
	update_font_size_for_state(_state)

	_spawn_paper_animation()
	_paper.gui_input.connect(_on_paper_clicked)


# -------------------------
# SPAWN / MOVE FILETIZEN
# -------------------------
func spawn_new_filetizen():
	var screen_size = get_viewport().get_visible_rect().size
	var spawn_pos = Vector2(-100, screen_size.y / 2)
	var new_filetizen: Node2D = spawner_component.spawn(spawn_pos, actors)
	filetizen = new_filetizen
	move_filetizen_to_center()

func move_filetizen_to_center():
	var target = get_viewport().get_visible_rect().size / 2.0
	var direction = target - filetizen.position
	filetizen.move_component.move(direction, 250)

func move_approved_filetizen():
	var screen_w = get_viewport().get_visible_rect().size.x
	var direction = Vector2(screen_w + 200, filetizen.position.y) - filetizen.position
	filetizen.move_component.move(direction, 300)

func move_declined_filetizen():
	var screen_w = get_viewport().get_visible_rect().size.x
	var direction = Vector2(screen_w + 200, filetizen.position.y) - filetizen.position
	filetizen.move_component.move(direction, -300)

func _process(delta):
	var target = get_viewport().get_visible_rect().size / 2.0

	if not moved_out and filetizen.position.distance_to(target) < 5.0:
		filetizen.move_component.stop()
		moved_out = true
		var score = engine.evaluate(filetizen.metadata, rule_base)
		filetizen.metadata.risk_score = score
		print("Evaluating Filetizen:")
		print("Filename: ", filetizen.metadata.filename)
		print("Score: ", score)
		enable_buttons(true)

func enable_buttons(state: bool):
	approve_btn.disabled = not state
	decline_btn.disabled = not state

func _on_approve_btn_pressed() -> void:
	handle_player_decision(true)

func _on_decline_btn_pressed() -> void:
	handle_player_decision(false)

func handle_player_decision(player_approved: bool):
	enable_buttons(false)
	var score = filetizen.metadata.risk_score
	var approved = score <= 2.0

	if player_approved == approved:
		print("✔ Correct decision!")
	else:
		print("✘ Incorrect decision!")

	if player_approved:
		move_approved_filetizen()
	else:
		move_declined_filetizen()

	await get_tree().create_timer(4.0).timeout
	moved_out = false
	spawn_new_filetizen()
	move_filetizen_to_center()
	_initialize_paper()  # Reset paper with new Filetizen

# -------------------------
# PAPER ANIMATION
# -------------------------
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
		0:
			_paper.texture = _paper_original_texture
			_paper.scale = ZOOM_SCALE
			_paper.position = _paper_center_pos
			_paper.z_index = 10
			vbox.visible = true
			_state = 1
			update_font_size_for_state(2)

		1:
			_paper.texture = _paper_open_texture
			_paper.scale = PAPER_DOWN_SCALE
			_paper.position = _paper_down_pos
			_paper.z_index = 10
			vbox.visible = false
			_state = 2
			update_font_size_for_state(_state)

		2:
			_paper.texture = _paper_original_texture
			_paper.scale = ZOOM_SCALE_2
			_paper.position = _paper_center_pos_2
			_paper.z_index = 10
			vbox.visible = true
			_state = 1
			update_font_size_for_state(_state)

# -------------------------
# LIST HANDLER
# -------------------------
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

# -------------------------
# RESIZE CHECKBOXES
# -------------------------
func _resize_checkboxes(size: Vector2) -> void:
	var checkboxes = [cb_file_name, cb_invalid_signature, cb_src_email, cb_size_large, cb_size_large2]
	for cb in checkboxes:
		if cb:
			cb.add_theme_constant_override("check_min_size", int(size.x))
			cb.add_theme_constant_override("icon_scale", size.x / 16.0)

# -------------------------
# UPDATE LABELS
# -------------------------
func _update_paper_labels(data: FileMetadata) -> void:
	lbl_filename.text = "Filename: %s" % data.filename
	lbl_extension.text = "Extension: %s" % data.extension
	lbl_size.text = "Size: %.2f MB" % data.size_mb
	lbl_publisher.text = "Publisher: %s" % data.publisher
	lbl_source.text = "Source: %s" % data.source

# -------------------------
# FONT SIZE LOGIC
# -------------------------
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
