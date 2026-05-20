class_name ThresholdPanel
extends Control

# ========================
# REFERENCES
# ========================
@onready var text_box: RichTextLabel = $frame/TextBox
@onready var next_button: Button = $frame/NextButton
@onready var arrow_left: Panel = $ArrowLeft

# ========================
# SIGNALS
# ========================
signal panel_closed

# ========================
# TUTORIAL CONTENT
# ========================
const TUTORIAL_STEPS: PackedStringArray = [
	"This threshold keeps rising as you continue to the next day of your duty."
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

	arrow_left.modulate.a = 1.0
	_start_arrow_animation()

	show_step(0)

# ========================
# STEP DISPLAY
# ========================
func show_step(step: int) -> void:
	if step >= TUTORIAL_STEPS.size():
		_finish_panel()
		return

	current_step = step
	full_text = TUTORIAL_STEPS[step]

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
# ARROW ANIMATION
# ========================
func _start_arrow_animation() -> void:
	arrow_tween = create_tween()
	arrow_tween.set_loops()

	var start_x := arrow_left.position.x
	var move_distance := 20.0
	var duration := 0.8

	arrow_tween.tween_property(
		arrow_left,
		"position:x",
		start_x + move_distance,
		duration
	)

	arrow_tween.tween_property(
		arrow_left,
		"position:x",
		start_x,
		duration
	)

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
	if arrow_tween:
		arrow_tween.kill()

	panel_closed.emit()
	queue_free()
