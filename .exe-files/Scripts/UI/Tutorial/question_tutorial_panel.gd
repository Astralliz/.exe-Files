class_name QuestionTutorialPanel
extends Control

# ========================
# ONREADY REFERENCES
# ========================
@onready var frame: TextureRect = $frame
@onready var text_box: RichTextLabel = $frame/TextBox
@onready var next_button: Button = $frame/NextButton
@onready var arrow_left: Panel = $ArrowLeft
@onready var panel: Panel = $Panel
@onready var panel2: Panel = $Panel2
@onready var panel3: Panel = $Panel3

# ========================
# SIGNALS
# ========================
signal panel_closed

# ========================
# TUTORIAL STEPS
# ========================
const TUTORIAL_STEPS: Array[Dictionary] = [
	{
		"text": "Tap here to open the question panel. Then tap any question to ask the Filetizen for more information.",
		"arrow": "left",
		"action": "wait_for_question",
	},
]

# ========================
# STATE
# ========================
var current_step: int = 0
var typing_speed: float = 0.02
var is_typing: bool = false
var full_text: String = ""
var arrow_tween: Tween = null
var waiting_for_panel_open := false
var waiting_for_question := false

# ========================
# LIFECYCLE
# ========================
func _ready() -> void:
	next_button.pressed.connect(_on_next_button_pressed)
	arrow_left.modulate.a = 0.0
	
	z_index = 999
	
	# Hide frame initially
	text_box.visible = false
	next_button.visible = false
	
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
	
	# Show frame and button
	frame.visible = true
	text_box.visible = true
	next_button.visible = true
	
	# Show the arrow
	_show_arrow(step_data["arrow"])
	
	# Reset
	waiting_for_question = false

	# Handle actions
	if step_data.has("action"):

		match step_data["action"]:

			"wait_for_question":

				waiting_for_question = true

				# Hide next button
				next_button.visible = false
	
	# Display the text with typing animation
	full_text = step_data["text"]
	text_box.text = full_text
	text_box.visible_characters = 0
	
	is_typing = true
	start_typing()

func notify_question_asked() -> void:

	if not waiting_for_question:
		return

	print("Tutorial detected question asked")

	waiting_for_question = false

	next_button.visible = true

	_finish_panel()

func notify_panel_opened() -> void:

	if not waiting_for_panel_open:
		return

	print("Tutorial detected sliding panel opened")

	waiting_for_panel_open = false

	next_button.visible = true

	_finish_panel()

func _show_arrow(arrow_type: String) -> void:
	"""Show and animate the specified arrow"""
	match arrow_type:
		"left":
			arrow_left.modulate.a = 1.0
			_animate_arrow_horizontal(arrow_left)
		"none":
			arrow_left.modulate.a = 0.0

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

# ========================
# BUTTON HANDLER
# ========================
func _on_next_button_pressed() -> void:
	"""Handle next button click"""
	print("Question Panel Next Clicked! Current step: %d, Is typing: %s" % [current_step, is_typing])
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
	panel_closed.emit()
	await get_tree().process_frame
	queue_free()
