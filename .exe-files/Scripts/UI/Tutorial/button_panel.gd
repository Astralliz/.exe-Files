class_name ButtonPanel
extends Control

# ========================
# ONREADY REFERENCES
# ========================
@onready var frame: TextureRect = $frame
@onready var text_box: RichTextLabel = $frame/TextBox
@onready var next_button: Button = $frame/NextButton
@onready var label: Label = $frame/Label
@onready var mentor: Sprite2D = $Sprite2D
@onready var frame2: TextureRect = $frame2
@onready var text_box2: RichTextLabel = $frame2/TextBox
@onready var next_button2: Button = $frame2/NextButton
@onready var label2: Label = $frame2/Label
@onready var mentor2: Sprite2D = $Sprite2D2
@onready var arrow_left: Panel = $ArrowLeft
@onready var arrow_up: Panel = $ArrowUp
@onready var panel: Panel = $Panel
@onready var panel2: Panel = $Panel2
@onready var panel3: Panel = $Panel3
@onready var panel4: Panel = $Panel4
@onready var panel5: Panel = $Panel5

# ========================
# SIGNALS
# ========================
signal panel_closed

# ========================
# TUTORIAL STEPS
# ========================
const TUTORIAL_STEPS: Array[Dictionary] = [
	{
		"text": "This is the button for Approving and Declining a Filetizen. Use these to make your verdict on whether to let them access the system.",
		"arrow": "left",
		"frame": "frame",
	},
	{
		"text": "This is the Bug Bounty display. Every correct decision adds a bounty: +1 for a correct Approve, +2 for a correct Decline. Wrong decisions don't add any bounty.",
		"arrow": "up",
		"frame": "frame",
	},
	{
		"text": "Tap Approve to let the Filetizen into the system.",
		"arrow": "none",
		"frame": "frame2",
	},
]

# ========================
# STATE
# ========================
var current_step: int = 0
var typing_speed: float = 0.02
var is_typing: bool = false
var full_text: String = ""
var current_tween: Tween = null
var arrow_tween: Tween = null
var current_frame: String = "frame"

# ========================
# LIFECYCLE
# ========================
func _ready() -> void:
	next_button.pressed.connect(_on_next_button_pressed)
	next_button2.pressed.connect(_on_next_button_pressed)
	arrow_left.modulate.a = 0.0
	arrow_up.modulate.a = 0.0
	
	z_index = 999
	
	# Hide both frames initially - they'll be shown when needed
	text_box.visible = false
	next_button.visible = false
	text_box2.visible = false
	next_button2.visible = false
	
	# Start the first step
	show_step(0)

# ========================
# STEP MANAGEMENT
# ========================
func show_step(step: int) -> void:
	"""Display a tutorial step with its text and arrow animation"""
	if step >= TUTORIAL_STEPS.size():
		_finish_panel()
		return
	
	current_step = step
	var step_data = TUTORIAL_STEPS[step]
	
	# Stop any active animations
	_stop_all_animations()
	
	# Determine which frame to use
	current_frame = step_data.get("frame", "frame")
	_setup_frame(current_frame)
	
	# Handle special actions
	if step_data.has("action"):
		match step_data["action"]:
			"hide_panels":
				_hide_panels()
	
	# Show the appropriate arrow
	_show_arrow(step_data["arrow"])
	
	# Display the text with typing animation
	full_text = step_data["text"]
	
	if current_frame == "frame":
		text_box.text = full_text
		text_box.visible_characters = 0
	else:
		text_box2.text = full_text
		text_box2.visible_characters = 0
	
	is_typing = true
	start_typing()

func _setup_frame(frame_name: String) -> void:
	"""Setup which frame is visible and active"""
	if frame_name == "frame":
		frame.visible = true
		text_box.visible = true
		next_button.visible = true
		label.visible = true
		mentor.visible = true
		frame2.visible = false
		text_box2.visible = false
		next_button2.visible = false
		label2.visible = false
		mentor2.visible = false
	else:
		frame.visible = false
		text_box.visible = false
		next_button.visible = false
		label.visible = false
		mentor.visible = false
		frame2.visible = true
		text_box2.visible = true
		next_button2.visible = true
		label2.visible = true
		mentor2.visible = true
		_hide_panels()

func _show_arrow(arrow_type: String) -> void:
	"""Show and animate the specified arrow"""
	match arrow_type:
		"left":
			arrow_left.modulate.a = 1.0
			arrow_up.modulate.a = 0.0
			_animate_arrow_horizontal(arrow_left)
		"up":
			arrow_up.modulate.a = 1.0
			arrow_left.modulate.a = 0.0
			_animate_arrow_vertical(arrow_up)
		"none":
			arrow_left.modulate.a = 0.0
			arrow_up.modulate.a = 0.0

# ========================
# TEXT ANIMATION
# ========================
func start_typing() -> void:
	"""Animate text appearing character by character"""
	for i in full_text.length():
		if not is_typing:  # Check if animation was cancelled
			break
		
		if current_frame == "frame":
			text_box.visible_characters = i + 1
		else:
			text_box2.visible_characters = i + 1
		
		await get_tree().create_timer(typing_speed, false).timeout
	
	is_typing = false

func skip_typing() -> void:
	"""Skip typing animation and show full text immediately"""
	if is_typing:
		if current_frame == "frame":
			text_box.visible_characters = full_text.length()
		else:
			text_box2.visible_characters = full_text.length()
		is_typing = false

# ========================
# ARROW ANIMATIONS
# ========================
func _animate_arrow_horizontal(arrow: Panel) -> void:
	"""Animate arrow moving left and right"""
	arrow_tween = create_tween()
	arrow_tween.set_loops()
	
	var start_pos = arrow.position.x
	var move_distance = 20.0
	var duration = 0.8
	
	arrow_tween.tween_property(arrow, "position:x", start_pos + move_distance, duration)
	arrow_tween.tween_property(arrow, "position:x", start_pos - move_distance, duration)

func _animate_arrow_vertical(arrow: Panel) -> void:
	"""Animate arrow moving up and down"""
	arrow_tween = create_tween()
	arrow_tween.set_loops()
	
	var start_pos = arrow.position.y
	var move_distance = 20.0
	var duration = 0.8
	
	arrow_tween.tween_property(arrow, "position:y", start_pos + move_distance, duration)
	arrow_tween.tween_property(arrow, "position:y", start_pos - move_distance, duration)

func _hide_panels() -> void:
	"""Hide all the informational panels (Panel, Panel2, Panel3, Panel4, Panel5)"""
	panel.visible = false
	panel2.visible = false
	panel3.visible = false
	panel4.visible = false
	panel5.visible = false

# ========================
# BUTTON HANDLER
# ========================
func _on_next_button_pressed() -> void:
	"""Handle next button click"""
	print("Button Clicked! Current step: %d, Is typing: %s" % [current_step, is_typing])
	if is_typing:
		# Skip typing and show full text
		skip_typing()
	else:
		# Move to next step
		show_step(current_step + 1)

# ========================
# CLEANUP
# ========================
func _stop_all_animations() -> void:
	"""Stop typing and arrow animations"""
	skip_typing()
	
	if arrow_tween:
		arrow_tween.kill()
		arrow_tween = null

func _finish_panel() -> void:
	"""Panel is complete, emit signal to move to next tutorial part"""
	_stop_all_animations()
	arrow_left.modulate.a = 0.0
	arrow_up.modulate.a = 0.0
	panel_closed.emit()
	await get_tree().process_frame
	queue_free()
