class_name Checklist
extends Node2D

signal insufficient_resource(resource_type: String)

@onready var document_area_2d: Area2D = $DocumentArea2D
@onready var interact_area_2d: Area2D = $InteractArea2D
@onready var list: Sprite2D = $Sprite2D
@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var vbox_container: VBoxContainer = $ScrollContainer/VBoxContainer

#Checkboxes
#--------------
#level 1
#-------------
@onready var file_name: CheckBox = $ScrollContainer/VBoxContainer/FileName
@onready var exe_type: CheckBox = $ScrollContainer/VBoxContainer/Exe
@onready var script_type: CheckBox = $ScrollContainer/VBoxContainer/TypeScript
@onready var dropper_type: CheckBox = $ScrollContainer/VBoxContainer/Dropper
@onready var size: CheckBox = $ScrollContainer/VBoxContainer/Size
@onready var publisher: CheckBox = $ScrollContainer/VBoxContainer/Publisher
@onready var source: CheckBox = $ScrollContainer/VBoxContainer/SourceUnknown
#--------------
#level 2 added
#-------------
@onready var source_email: CheckBox = $ScrollContainer/VBoxContainer/SourceEmail
@onready var modified: CheckBox = $ScrollContainer/VBoxContainer/Modification
@onready var is_hidden: CheckBox = $ScrollContainer/VBoxContainer/IsHidden
#--------------
#level 3 added
#-------------
@onready var random_name: CheckBox = $ScrollContainer/VBoxContainer/RandomName
@onready var signature: CheckBox = $ScrollContainer/VBoxContainer/Signature
@onready var admin: CheckBox = $ScrollContainer/VBoxContainer/Admin
@onready var compressed: CheckBox = $ScrollContainer/VBoxContainer/Compressed

# results 
@onready var evaluate: Button = $ScrollContainer/VBoxContainer/Evaluate
@onready var result: Label = $ScrollContainer/VBoxContainer/Result
@onready var suggestion: Label = $ScrollContainer/VBoxContainer/Suggestions
@onready var suggestion2: Label = $ScrollContainer/VBoxContainer/Suggestions2

#audio
@onready var pickup_sound = $Audio_Pickup

var tex_closed := preload("res://Assets/Sprites/paper_down_ask.png")
var tex_open := preload("res://Assets/Sprites/large-paper.png")
var _state := 0
var is_dragging := false
var drag_offset = Vector2.ZERO

const CLOSED_SCALE := Vector2(0.3, 0.3)
const OPEN_SCALE := Vector2(1.2, 1.2)
var CLOSED_POS := Vector2(700,850)
var OPEN_POS := Vector2(710,520)

var day = GameState.day

# ──────────────────────────────────────────
#   LEVEL RULES (scores per condition per level)
# ──────────────────────────────────────────
const LEVEL_RULES := {
	1: {
		"size_large":        0.4,
		"ext_exe":           0.7,
		"ext_script":        0.4,
		"ext_dropper":       0.5,
		"unknown_publisher": 0.6,
		"src_unknown":       0.4,
		"type_mismatch":     0.2,
	},
	2: {
		"size_large":        0.4,
		"ext_exe":           0.6,
		"ext_script":        0.4,
		"ext_dropper":       0.5,
		"unknown_publisher": 0.6,
		"recent_modified":   0.3,
		"src_email":         0.4,
		"src_unknown":       0.5,
		"is_hidden":         0.6,
		"type_mismatch":     0.2,
	},
	3: {
		"size_large":        0.4,
		"ext_exe":           0.7,
		"ext_script":        0.5,
		"ext_dropper":       0.6,
		"unknown_publisher": 0.6,
		"recent_modified":   0.4,
		"src_email":         0.5,
		"src_unknown":       0.5,
		"is_hidden":         0.5,
		"random_filename":   0.4,
		"invalid_signature": 0.8,
		"needs_admin":       0.8,
		"type_mismatch":     0.2,
		"compressed_exec":   0.5,
	}
}

# Maps each checkbox node → its condition key
# Checkbox visibility per level:
#   Level 1: size, exe, script, dropper, publisher, source (src_unknown)
#   Level 2: + source_email, modified, is_hidden
#   Level 3: + random_name, signature, admin, compressed
const CHECKBOX_CONDITIONS := {
	"size":        "size_large",
	"exe_type":    "ext_exe",
	"script_type": "ext_script",
	"dropper_type":"ext_dropper",
	"publisher":   "unknown_publisher",
	"source":      "src_unknown",
	"source_email":"src_email",
	"modified":    "recent_modified",
	"is_hidden":   "is_hidden",
	"random_name": "random_filename",
	"signature":   "invalid_signature",
	"admin":       "needs_admin",
	"compressed":  "compressed_exec",
}

# Which checkboxes unlock at each level (cumulative)
const LEVEL_VISIBLE_CHECKBOXES := {
	1: ["size", "exe_type", "script_type", "dropper_type", "publisher", "source"],
	2: ["source_email", "modified", "is_hidden"],
	3: ["random_name", "signature", "admin", "compressed"],
}

func _ready() -> void:
	_init_appearance()
	interact_area_2d.input_event.connect(_on_interact_area_input)
	document_area_2d.input_event.connect(_on_document_area_input)
	vbox_container.visible = false
	evaluate.pressed.connect(_on_evaluate_pressed)
	_apply_level_visibility()

func _get_current_level() -> int:
	var d = GameState.day
	if d <= 2:
		return 1
	elif d <= 4:
		return 2
	else:
		return 3

func _apply_level_visibility() -> void:
	var level := _get_current_level()
	
	# Collect all checkboxes that should be visible up to current level
	var visible_keys: Array = []
	for lvl in range(1, level + 1):
		visible_keys += LEVEL_VISIBLE_CHECKBOXES[lvl]
	
	# All checkbox node references by key name
	var checkbox_nodes := {
		"size":        size,
		"exe_type":    exe_type,
		"script_type": script_type,
		"dropper_type":dropper_type,
		"publisher":   publisher,
		"source":      source,
		"source_email":source_email,
		"modified":    modified,
		"is_hidden":   is_hidden,
		"random_name": random_name,
		"signature":   signature,
		"admin":       admin,
		"compressed":  compressed,
	}
	
	# Show only checkboxes for current level and below, hide the rest
	for key in checkbox_nodes:
		checkbox_nodes[key].visible = key in visible_keys

func _init_appearance():
	_state = 0
	list.texture = tex_closed
	scale = CLOSED_SCALE
	position = CLOSED_POS
	z_index = 5

func _on_interact_area_input(viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if _state == 1:
				pickup_sound.play()
				_toggle_state()

func _on_document_area_input(viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if _state == 1:
				is_dragging = true
				drag_offset = global_position - get_global_mouse_position()
				return
			if _state == 0:
				pickup_sound.play()
				_toggle_state()

func _input(event: InputEvent) -> void:
	if _state != 1:
		return
	if Input.is_action_just_released("click"):
		is_dragging = false
	if is_dragging and Input.is_action_pressed("click"):
		var new_pos = get_global_mouse_position() + drag_offset
		global_position = _clamp_to_screen(new_pos)

func _clamp_to_screen(pos: Vector2) -> Vector2:
	var screen := get_viewport().get_visible_rect()
	var tex_size = list.texture.get_size() * scale
	var half_w = tex_size.x * 0.5
	var half_h = tex_size.y * 0.5
	pos.x = clamp(pos.x, screen.position.x + half_w, screen.end.x - half_w)
	pos.y = clamp(pos.y, screen.position.y + half_h, screen.end.y - half_h)
	return pos

func _toggle_state():
	match _state:
		0:
			_state = 1
			list.texture = tex_open
			scale = OPEN_SCALE
			position = OPEN_POS
			vbox_container.visible = true
		1:
			_state = 0
			list.texture = tex_closed
			scale = CLOSED_SCALE
			position = CLOSED_POS
			vbox_container.visible = false

# ──────────────────────────────────────────
#   SCORING
# ──────────────────────────────────────────

func _compute_score() -> float:
	var level := _get_current_level()
	var rules: Dictionary = LEVEL_RULES[level]
	var score := 0.0

	# Map each checkbox node to its condition key, then look up score from level rules
	var checkbox_nodes := {
		"size":        size,
		"exe_type":    exe_type,
		"script_type": script_type,
		"dropper_type":dropper_type,
		"publisher":   publisher,
		"source":      source,
		"source_email":source_email,
		"modified":    modified,
		"is_hidden":   is_hidden,
		"random_name": random_name,
		"signature":   signature,
		"admin":       admin,
		"compressed":  compressed,
	}

	for key in checkbox_nodes:
		var checkbox: CheckBox = checkbox_nodes[key]
		var condition: String = CHECKBOX_CONDITIONS[key]
		
		# Only score if this condition exists in the current level's rules
		if not rules.has(condition):
			continue
		
		# Checkbox checked = player flagged it as suspicious → add risk score
		if checkbox.button_pressed:
			score += rules[condition]

	return score


func _on_evaluate_pressed():
	var s := _compute_score()
	
	var text := "Score: " + str(snappedf(s, 0.01)) + "\n"

	suggestion.visible = false
	suggestion2.visible = false

	if Player_Data.data["level"] >= 1:
		if Player_Data.get_evaluate_left() <= 0:
			emit_signal("insufficient_resource", "evaluate")
			return
		Player_Data.use_evaluate()  # Deduct evaluation

	if s <= 1.0:
		text += "SAFE ✓"
		suggestion.text = "Approve the file."
		suggestion.visible = true
	elif s <= 2.0:
		text += "MEDIUM RISK ⚠"
		suggestion2.text = "Better decline."
		suggestion2.visible = true
	else:
		text += "HIGH RISK ✖\nThreat detected!"
		suggestion2.text = "Decline immediately."
		suggestion2.visible = true

	result.text = text
