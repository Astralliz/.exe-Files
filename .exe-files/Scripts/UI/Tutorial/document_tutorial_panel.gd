class_name DocumentTutorialPanel
extends Control

# ========================
# ONREADY REFERENCES
# ========================
@onready var text_box: RichTextLabel = $frame/TextBox
@onready var next_button: Button = $frame/NextButton
@onready var arrow_right: Panel = $ArrowRight
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
		"text": "This is the Identification Panel. It holds everything you need to inspect a Filetizen.",
		"arrow": "none",
	},
	{
		"text": "This is the Filetizen — the one trying to gain system access. It's your job to Approve or Decline their request based on the evidence.",
		"arrow": "right",
	},
	{
		"text": "This is the metadata document that the Filetizen is carrying. It contains all the information you'll need to make your inspection.",
		"arrow": "up",
	},
	{
		"text": "Tap the file document to examine it closely and gather information for your decision.",
		"arrow": "up",
	},
	{
		"text": "Every risky metadata has its own score",
		"arrow": "none",
		"action": "hide_panels",
	},
	{
		"text": "Tap the lower part of the document to close the inspection panel and return to making your decision.",
		"arrow": "none",
		"action": "hide_panels",
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

# ========================
# LIFECYCLE
# ========================
func _ready() -> void:
	next_button.pressed.connect(_on_next_button_pressed)
	arrow_right.modulate.a = 0.0
	arrow_up.modulate.a = 0.0
	
	# Set z_index for proper layering
	z_index = 999
	
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
	
	# Handle special actions
	if step_data.has("action"):
		match step_data["action"]:
			"hide_panels":
				_hide_panels()
	
	# Show the appropriate arrow
	_show_arrow(step_data["arrow"])
	
	# Display the text with typing animation
	full_text = step_data["text"]
	text_box.text = full_text
	text_box.visible_characters = 0
	is_typing = true
	
	start_typing()

func _show_arrow(arrow_type: String) -> void:
	"""Show and animate the specified arrow"""
	match arrow_type:
		"right":
			arrow_right.modulate.a = 1.0
			arrow_up.modulate.a = 0.0
			_animate_arrow_horizontal(arrow_right)
		"up":
			arrow_up.modulate.a = 1.0
			arrow_right.modulate.a = 0.0
			_animate_arrow_vertical(arrow_up)
		"none":
			arrow_right.modulate.a = 0.0
			arrow_up.modulate.a = 0.0

# ========================
# TEXT ANIMATION
# ========================
func start_typing() -> void:
	"""Animate text appearing character by character"""
	for i in full_text.length():
		if not is_typing:  # Check if animation was cancelled
			break
		text_box.visible_characters = i + 1
		await get_tree().create_timer(typing_speed, false).timeout
	
	is_typing = false

func skip_typing() -> void:
	"""Skip typing animation and show full text immediately"""
	if is_typing:
		text_box.visible_characters = full_text.length()
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
	arrow_right.modulate.a = 0.0
	arrow_up.modulate.a = 0.0
	panel_closed.emit()
	await get_tree().process_frame  # Wait one frame before freeing
	queue_free()
