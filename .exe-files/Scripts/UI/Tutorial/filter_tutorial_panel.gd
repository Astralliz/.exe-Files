class_name FilterTutorialPanel
extends Control

# ========================
# ONREADY REFERENCES
# ========================
@onready var frame: TextureRect = $frame
@onready var text_box: RichTextLabel = $frame/TextBox
@onready var next_button: Button = $frame/NextButton
@onready var arrow_up: Panel = $ArrowUp
@onready var arrow_right: Panel = $ArrowRight
@onready var panel: Panel = $Panel
@onready var panel2: Panel = $Panel2
@onready var panel3: Panel = $Panel3
@onready var panel4: Panel = $Panel4
@onready var panel5: Panel = $Panel5
@onready var panel6: Panel = $Panel6
@onready var panel7: Panel = $Panel7

# ========================
# SIGNALS
# ========================
signal panel_closed

# ========================
# TUTORIAL STEPS
# ========================
const TUTORIAL_STEPS: Array[Dictionary] = [
	{
		"text": "This is the Filter resources counter. It displays how many times you can use the filter function. You start with a limited amount.",
		"arrow": "right",
	},
	{
		"text": "This is the Filter button. It is used to reveal the real identity of a Filetizen. If they're not safe, it will show a corrupted Filetizen, otherwise it will still look like a decent Filetizen.",
		"arrow": "up",
	},
	{
		"text": "Try it by clicking the Filter button.",
		"arrow": "none",
		"action": "prepare_filter_test",
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

# ========================
# LIFECYCLE
# ========================
func _ready() -> void:
	next_button.pressed.connect(_on_next_button_pressed)

	arrow_up.modulate.a = 0.0
	arrow_right.modulate.a = 0.0

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

	if step >= TUTORIAL_STEPS.size():
		_finish_panel()
		return

	current_step = step
	var step_data = TUTORIAL_STEPS[step]

	_stop_all_animations()

	# Show frame
	frame.visible = true
	text_box.visible = true

	# Show next button normally
	next_button.visible = true

	# Handle special actions
	if step_data.has("action"):

		match step_data["action"]:

			"prepare_filter_test":
				_prepare_filter_test()

	# Show arrow
	_show_arrow(step_data["arrow"])

	# Setup text
	full_text = step_data["text"]

	text_box.text = full_text
	text_box.visible_characters = 0

	is_typing = true

	start_typing()

func _prepare_filter_test() -> void:

	# Hide next button so player MUST use filter
	next_button.visible = false

	# Hide all tutorial highlight panels
	panel.visible = false
	panel2.visible = false
	panel3.visible = false
	panel4.visible = false
	panel5.visible = false
	panel6.visible = false
	panel7.visible = false

	# Hide arrows
	arrow_up.modulate.a = 0.0
	arrow_right.modulate.a = 0.0

func notify_filter_used() -> void:

	print("FILTER TUTORIAL: Filter button used")

	# Only continue if currently on final step
	if current_step == 2:
		show_step(current_step + 1)

func _show_arrow(arrow_type: String) -> void:

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
			arrow_up.modulate.a = 0.0
			arrow_right.modulate.a = 0.0

# ========================
# TEXT ANIMATION
# ========================
func start_typing() -> void:

	for i in full_text.length():

		if not is_typing:
			break

		text_box.visible_characters = i + 1

		await get_tree().create_timer(
			typing_speed,
			false
		).timeout

	is_typing = false

func skip_typing() -> void:

	if is_typing:

		text_box.visible_characters = full_text.length()

		is_typing = false

# ========================
# ARROW ANIMATIONS
# ========================
func _animate_arrow_horizontal(arrow: Panel) -> void:

	arrow_tween = create_tween()

	arrow_tween.set_loops()

	var start_pos = arrow.position.x

	var move_distance = 20.0

	var duration = 0.8

	arrow_tween.tween_property(
		arrow,
		"position:x",
		start_pos + move_distance,
		duration
	)

	arrow_tween.tween_property(
		arrow,
		"position:x",
		start_pos - move_distance,
		duration
	)

func _animate_arrow_vertical(arrow: Panel) -> void:

	arrow_tween = create_tween()

	arrow_tween.set_loops()

	var start_pos = arrow.position.y

	var move_distance = 20.0

	var duration = 0.8

	arrow_tween.tween_property(
		arrow,
		"position:y",
		start_pos + move_distance,
		duration
	)

	arrow_tween.tween_property(
		arrow,
		"position:y",
		start_pos - move_distance,
		duration
	)

# ========================
# BUTTON HANDLER
# ========================
func _on_next_button_pressed() -> void:

	print(
		"Filter Panel Next Clicked! Current step: %d, Is typing: %s"
		% [current_step, is_typing]
	)

	if is_typing:

		skip_typing()

	else:

		show_step(current_step + 1)

# ========================
# CLEANUP
# ========================
func _stop_all_animations() -> void:

	skip_typing()

	if arrow_tween:

		arrow_tween.kill()

		arrow_tween = null

func _finish_panel() -> void:

	_stop_all_animations()

	arrow_up.modulate.a = 0.0
	arrow_right.modulate.a = 0.0

	panel_closed.emit()

	await get_tree().process_frame

	queue_free()
