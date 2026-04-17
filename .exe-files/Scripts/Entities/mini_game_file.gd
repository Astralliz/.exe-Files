extends Node2D
class_name MiniGameFile

signal file_clicked(file_no: int)

@onready var file_sprite: Sprite2D = $File
@onready var document_area: Area2D = $DocumentArea2D
@onready var interact_area: Area2D = $InteractArea2D
@onready var file_no_label: Label = $FileNo

var file_no: int

var is_dragging := false
var drag_offset := Vector2.ZERO
var click_start_pos := Vector2.ZERO
var drag_threshold := 10.0

func _ready() -> void:
	document_area.input_event.connect(_on_document_input)
	interact_area.input_event.connect(_on_interact_input)
	

# ══════════════════════════════════════════════════════════════
# TAP DETECTOR
# ══════════════════════════════════════════════════════════════
func _on_interact_input(viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed:
		click_start_pos = get_global_mouse_position()

func _on_interact_input_release() -> void:
	print("File clicked:", file_no)
	file_clicked.emit(file_no)

func _unhandled_input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:

			if event.pressed:
				click_start_pos = get_global_mouse_position()

			else:
				if not is_dragging:
					_on_file_clicked()

func _on_file_clicked() -> void:
	print("File clicked:", file_no)
	file_clicked.emit(file_no)

# ══════════════════════════════════════════════════════════════
# DRAG SYSTEM
# ══════════════════════════════════════════════════════════════
func _on_document_input(viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:

		if event.pressed:
			is_dragging = true
			drag_offset = global_position - get_global_mouse_position()

		else:
			is_dragging = false

func _process(delta: float) -> void:
	if is_dragging:
		var new_pos = get_global_mouse_position() + drag_offset
		global_position = new_pos
