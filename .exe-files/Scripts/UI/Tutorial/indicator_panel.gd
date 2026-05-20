class_name IndicatorPanel
extends Control

# ========================
# REFERENCES
# ========================
@onready var text_box: RichTextLabel = $frame/TextBox
@onready var next_button: Button = $frame/NextButton

@onready var arrow_up: Panel = $ArrowUp
@onready var arrow_up2: Panel = $ArrowUp2

# ========================
# SIGNALS
# ========================
signal panel_closed

# ========================
# TUTORIAL STEPS
# ========================
const TUTORIAL_STEPS: Array[Dictionary] = [
	{
		"text": "The red indicator on the left side is the mini-game indicator.",
		"arrow": "up_1"
	},
	{
		"text": "It activates when you approve a suspicious Filetizen. Completing the mini-game allows you to continue your duty.",
		"arrow": "up_1"
	},
	{
		"text": "The mini-game can be used once per Duty Day. This limit resets every day at midnight (real-time).",
		"arrow": "up_1"
	},
	{
		"text": "The cyan indicator on the right side tracks how many safe Filetizens you incorrectly declined.",
		"arrow": "up_2"
	},
	{
		"text": "Declining a safe Filetizen counts as a wrong decision and also removes 1 Bug Bounty.",
		"arrow": "up_2"
	},
	{
		"text": "If you wrongly decline 3 safe Filetizens, it's game over. Unlike approving a suspicious Filetizen, no mini-game can save you.",
		"arrow": "up_2"
	}
]

# ========================
# STATE
# ========================
var current_step: int = 0
var typing_speed: float = 0.02

var is_typing: bool = false
var full_text: String = ""

var arrow_tween: Tween

# ========================
# READY
# ========================
func _ready() -> void:
	z_index = 999

	next_button.pressed.connect(_on_next_button_pressed)

	arrow_up.modulate.a = 0.0
	arrow_up2.modulate.a = 0.0

	show_step(0)

# ========================
# STEP DISPLAY
# ========================
func show_step(step: int) -> void:
	if step >= TUTORIAL_STEPS.size():
		_finish_panel()
		return

	current_step = step

	var step_data := TUTORIAL_STEPS[step]

	_stop_arrow_animation()
	_show_arrow(step_data["arrow"])

	full_text = step_data["text"]

	text_box.text = full_text
	text_box.visible_characters = 0

	start_typing()

# ========================
# TYPEWRITER EFFECT
# ========================
func start_typing() -> void:
	is_typing = true

	for i in full_text.length():
		if not is_typing:
			return

		text_box.visible_characters = i + 1

		await get_tree().create_timer(typing_speed).timeout

	is_typing = false

func skip_typing() -> void:
	is_typing = false
	text_box.visible_characters = full_text.length()

# ========================
# ARROW DISPLAY
# ========================
func _show_arrow(arrow_type: String) -> void:
	arrow_up.modulate.a = 0.0
	arrow_up2.modulate.a = 0.0

	match arrow_type:
		"up_1":
			arrow_up.modulate.a = 1.0
			_start_vertical_animation(arrow_up)

		"up_2":
			arrow_up2.modulate.a = 1.0
			_start_vertical_animation(arrow_up2)

# ========================
# ARROW ANIMATION
# ========================
func _start_vertical_animation(arrow: Panel) -> void:
	arrow_tween = create_tween()
	arrow_tween.set_loops()

	var start_y := arrow.position.y
	var move_distance := 20.0
	var duration := 0.8

	arrow_tween.tween_property(
		arrow,
		"position:y",
		start_y - move_distance,
		duration
	)

	arrow_tween.tween_property(
		arrow,
		"position:y",
		start_y,
		duration
	)

func _stop_arrow_animation() -> void:
	if arrow_tween:
		arrow_tween.kill()
		arrow_tween = null

# ========================
# NEXT BUTTON
# ========================
func _on_next_button_pressed() -> void:
	if is_typing:
		skip_typing()
		return

	show_step(current_step + 1)

# ========================
# FINISH
# ========================
func _finish_panel() -> void:
	_stop_arrow_animation()

	arrow_up.modulate.a = 0.0
	arrow_up2.modulate.a = 0.0

	panel_closed.emit()
	queue_free()
