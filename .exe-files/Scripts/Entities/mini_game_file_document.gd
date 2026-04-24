extends Node2D
class_name MiniGameFileDocument

signal closed(file_no: int)

@onready var file_sprite: Sprite2D = $File

var file_no: int
var metadata

# ─────────────────────────────
# STATE
# ─────────────────────────────
var is_dragging := false
var drag_offset := Vector2.ZERO
var click_start_pos := Vector2.ZERO
var drag_threshold := 10.0

var is_open := false
var is_clicked := false

# ─────────────────────────────
# READY
# ─────────────────────────────
func _ready() -> void:
	print("DOCUMENT READY")

# ─────────────────────────────
# INPUT (CLICK + TAP DETECTION)
# ─────────────────────────────
func _input(event: InputEvent) -> void:
	if not is_open:
		return

	# LEFT CLICK DOWN
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			click_start_pos = get_global_mouse_position()
			drag_offset = global_position - click_start_pos
			is_clicked = true
		else:
			# RELEASE
			var release_pos = get_global_mouse_position()

			# CLICK (not drag) → CLOSE
			if release_pos.distance_to(click_start_pos) < drag_threshold:
				closed.emit(file_no)
				queue_free()
				return

			is_dragging = false
			is_clicked = false

	# DRAG MOVEMENT
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and is_dragging:
			global_position = get_global_mouse_position() + drag_offset

# ─────────────────────────────
# PROCESS (START DRAG LOGIC)
# ─────────────────────────────
func _process(_delta: float) -> void:
	if not is_open:
		return

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var mouse_pos = get_global_mouse_position()

		# start dragging only after threshold
		if not is_dragging and is_clicked:
			if mouse_pos.distance_to(click_start_pos) > drag_threshold:
				is_dragging = true

		if is_dragging:
			global_position = mouse_pos + drag_offset

# ─────────────────────────────
# OPEN STATE (IMPORTANT)
# ─────────────────────────────
func open_document() -> void:
	is_open = true
	z_index = 999

# ─────────────────────────────
# METADATA
# ─────────────────────────────
func set_metadata(data) -> void:
	metadata = data
	
	file_no = metadata.paper_no 
	
	_update_ui()

func _update_ui() -> void:
	var container = $ScrollContainer/VBoxContainer
	container.get_node("FileNo").text = "File No: " + str(file_no)
	container.get_node("FileName").text = "Filename: " + str(metadata.filename)
	container.get_node("Extension").text = "Extension: " + str(metadata.extension)
	container.get_node("Size").text = "Size: " + str(metadata.size)
	container.get_node("Publisher").text = "Publisher: " + str(metadata.publisher)
	container.get_node("Source").text = "Source: " + str(metadata.source)
	if metadata.flags.size() > 0:
		var hint = metadata.flags.pick_random()
		container.get_node("Hint").text = "Hint💡: " + hint
	else:
		container.get_node("Hint").text = "Hint💡: None"

	#var attack_type = container.get_node("AttackType")
	#attack_type.text = "Attack Type: " + str(metadata.actual_label).to_upper()
	#attack_type.add_theme_color_override("font_color", Color.RED)
