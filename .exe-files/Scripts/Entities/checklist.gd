class_name Checklist
extends Node2D

@onready var document_area_2d: Area2D = $DocumentArea2D
@onready var interact_area_2d: Area2D = $InteractArea2D
@onready var list: Sprite2D = $Sprite2D
@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var vbox_container: VBoxContainer = $ScrollContainer/VBoxContainer
@onready var file_name: CheckBox = $ScrollContainer/VBoxContainer/FileName
@onready var extension: CheckBox = $ScrollContainer/VBoxContainer/Extension
@onready var dangerous_extension: CheckBox = $ScrollContainer/VBoxContainer/Dangerous_Extension
@onready var size: CheckBox = $ScrollContainer/VBoxContainer/Size
@onready var publisher: CheckBox = $ScrollContainer/VBoxContainer/Publisher
@onready var source: CheckBox = $ScrollContainer/VBoxContainer/Source
@onready var evaluate: Button = $ScrollContainer/VBoxContainer/Evaluate
@onready var result: Label = $ScrollContainer/VBoxContainer/Result
@onready var suggestion: Label = $ScrollContainer/VBoxContainer/Suggestions
@onready var suggestion2: Label = $ScrollContainer/VBoxContainer/Suggestions2
@onready var pickup_sound = $Audio_Pickup

var tex_closed := preload("res://Assets/Sprites/paper_down_ask.png")
var tex_open := preload("res://Assets/Sprites/large-paper.png")
var _state := 0
var is_dragging := false
var drag_offset = Vector2.ZERO

const CLOSED_SCALE := Vector2(0.3, 0.3)
const OPEN_SCALE := Vector2(1.2, 1.2)
var CLOSED_POS := Vector2(310, 510)
var OPEN_POS := Vector2(310, 420)

func _ready() -> void:
	_init_appearance()
	
	interact_area_2d.input_event.connect(_on_interact_area_input)
	document_area_2d.input_event.connect(_on_document_area_input)
	
	vbox_container.visible = false
	evaluate.pressed.connect(_on_evaluate_pressed)

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
		return  # dragging only works when open
	# STOP DRAGGING
	if Input.is_action_just_released("click"):
		is_dragging = false
	# DRAGGING
	if is_dragging and Input.is_action_pressed("click"):
		var new_pos = get_global_mouse_position() + drag_offset
		global_position = _clamp_to_screen(new_pos)

func _clamp_to_screen(pos: Vector2) -> Vector2:
	var screen := get_viewport().get_visible_rect()
	# The paper’s size comes from scale × texture size
	var tex_size = list.texture.get_size() * scale
	# Make sure it doesn't exit screen bounds
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
#   PURE PLAYER-DECISION CHECKLIST SYSTEM
# ──────────────────────────────────────────

func _compute_score() -> float:
	var score := 0.0

	# If player checks → GOOD → add 0
	# If player does not check → BAD → add risk score

	if !file_name.button_pressed:
		score += 0.2       # filename mismatch risk
	
	if dangerous_extension.button_pressed: 
		score += 1
	
	if !extension.button_pressed:
		score += .2       # file extension mismatch

	if size.button_pressed:
		score += 0.8     # size risk

	if !publisher.button_pressed:
		score += 0.7       # unknown publisher

	if !source.button_pressed:
		score += 0.5       # suspicious source

	return score


func _on_evaluate_pressed():
	var s := _compute_score()
	
	var text := "Score: " + str(s) + "\n"
	var app_sugg := ""
	var dec_sugg := "/n"

	# Reset labels first
	suggestion.visible = false
	suggestion2.visible = false

	if s <= 1:
		text += "SAFE ✓"
		app_sugg = "Approve the file."
		suggestion.text = app_sugg
		suggestion.visible = true

	elif s <= 2:
		text += "MEDIUM RISK ⚠"
		dec_sugg = "Better decline."
		suggestion2.text = dec_sugg 
		suggestion2.visible = true

	else:
		text += "HIGH RISK ✖\nThreat detected!"
		dec_sugg = "Decline immediately."
		suggestion2.text = dec_sugg
		suggestion2.visible = true

	result.text = text
