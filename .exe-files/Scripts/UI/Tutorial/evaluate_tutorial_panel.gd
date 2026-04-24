class_name EvaluateTutorialPanel
extends Control

# ========================
# ONREADY REFERENCES
# ========================
@onready var mentor: Sprite2D = $Sprite2D
@onready var mentor2: Sprite2D = $Sprite2D2
@onready var frame: TextureRect = $frame
@onready var text_box: RichTextLabel = $frame/TextBox
@onready var next_button: Button = $frame/NextButton
@onready var frame2: TextureRect = $frame2
@onready var text_box2: RichTextLabel = $frame2/TextBox
@onready var next_button2: Button = $frame2/NextButton
@onready var arrow_up: Panel = $ArrowUp
@onready var arrow_right: Panel = $ArrowRight
@onready var panel: Panel = $Panel
@onready var panel2: Panel = $Panel2
@onready var panel3: Panel = $Panel3
@onready var panel4: Panel = $Panel4
@onready var panel5: Panel = $Panel5
@onready var panel6: Panel = $Panel6

# ========================
# SIGNALS
# ========================
signal panel_closed

# ========================
# TUTORIAL STEPS
# ========================
const TUTORIAL_STEPS: Array[Dictionary] = [
	{
		"text": "This is the Evaluate resources counter. It displays how many times you can use the evaluate function. You start with a limited amount.",
		"arrow": "up",
		"frame": "frame",
	},
	{
		"text": "If already at 0, you can buy more at the shop in the main menu using your Bug Bounty.",
		"arrow": "up",
		"frame": "frame",
	},
	{
		"text": "This is the Evaluate checkbox. You can open it to help you evaluate the metadata of the Filetizen.",
		"arrow": "right",
		"frame": "frame",
	},
	{
		"text": "You can compare the questions in the checkbox with the metadata. If it meets the question, checkmark it. If not, leave it blank.",
		"arrow": "none",
		"frame": "frame2",
	},
	{
		"text": "You can also use the questions and compare them in the metadata. Evaluate and checkmark every condition it meets.",
		"arrow": "none",
		"frame": "frame2",
	},
	{
		"text": "After clicking Evaluate, you will see the Safety Score. Below or equal to 1 is safe. You'll also see suggestions whether to accept or decline.",
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
var current_frame: String = "frame"
var arrow_tween: Tween = null

# ========================
# LIFECYCLE
# ========================
func _ready() -> void:
	next_button.pressed.connect(_on_next_button_pressed)
	next_button2.pressed.connect(_on_next_button_pressed)
	arrow_up.modulate.a = 0.0
	arrow_right.modulate.a = 0.0
	
	z_index = 999
	
	# Hide frame2 and both buttons initially
	frame.visible = false
	text_box.visible = false
	next_button.visible = false
	frame2.visible = false
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
		mentor.visible = true
		mentor2.visible = false
		frame2.visible = false
		text_box2.visible = false
		next_button2.visible = false
	else:
		frame.visible = false
		text_box.visible = false
		next_button.visible = false
		mentor.visible = false
		mentor2.visible = true
		frame2.visible = true
		text_box2.visible = true
		next_button2.visible = true
		# Hide all panels when switching to frame2
		_hide_all_panels()

func _show_arrow(arrow_type: String) -> void:
	"""Show and animate the specified arrow"""
	match arrow_type:
		"up":
			arrow_up.modulate.a = 1.0
			arrow_right.modulate.a = 0.0
			_animate_arrow_vertical(arrow_up)
		"right":
			arrow_right.modulate.a = 1.0
			arrow_up.modulate.a = 0.0
			_animate_arrow_horizontal(arrow_right)
		"none":
			arrow_up.modulate.a = 0.0
			arrow_right.modulate.a = 0.0

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
func _animate_arrow_vertical(arrow: Panel) -> void:
	"""Animate arrow moving up and down"""
	arrow_tween = create_tween()
	arrow_tween.set_loops()
	
	var start_pos = arrow.position.y
	var move_distance = 20.0
	var duration = 0.8
	
	arrow_tween.tween_property(arrow, "position:y", start_pos + move_distance, duration)
	arrow_tween.tween_property(arrow, "position:y", start_pos - move_distance, duration)

func _animate_arrow_horizontal(arrow: Panel) -> void:
	"""Animate arrow moving left and right"""
	arrow_tween = create_tween()
	arrow_tween.set_loops()
	
	var start_pos = arrow.position.x
	var move_distance = 20.0
	var duration = 0.8
	
	arrow_tween.tween_property(arrow, "position:x", start_pos + move_distance, duration)
	arrow_tween.tween_property(arrow, "position:x", start_pos - move_distance, duration)

func _hide_all_panels() -> void:
	"""Hide all informational panels"""
	panel.visible = false
	panel2.visible = false
	panel3.visible = false
	panel4.visible = false
	panel5.visible = false
	panel6.visible = false

# ========================
# BUTTON HANDLER
# ========================
func _on_next_button_pressed() -> void:
	"""Handle next button click"""
	print("Evaluate Panel Next Clicked! Current step: %d, Is typing: %s" % [current_step, is_typing])
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
	arrow_up.modulate.a = 0.0
	arrow_right.modulate.a = 0.0
	panel_closed.emit()
	await get_tree().process_frame
	queue_free()
