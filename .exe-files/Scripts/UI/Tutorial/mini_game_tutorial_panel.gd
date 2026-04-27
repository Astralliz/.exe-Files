# res://Scripts/MiniGameTutorialPanel.gd
class_name MiniGameTutorialPanel
extends Control

signal tutorial_finished

@onready var textbox: RichTextLabel = $TextBox
@onready var next_button: Button = $NextButton
@onready var skip_button: Button = $SkipButton

var current_step: int = 0
var tutorial_texts: Array[String] = [
	"This is the Mini Game! It appears when you approve a dangerous file to give you a chance to continue—no Game Over!",
	"But remember, you can only play this once per day (real-world date) for each level.",
	"Let me guide you through this Mini Game.",
]

# ========================
# TEXT ANIMATION
# ========================
var typing_speed: float = 0.02
var is_typing: bool = false
var full_text: String = ""

func _ready() -> void:
	# ✅ Ensure this tutorial panel is visible and on top
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0
	z_index = 1000  # Make sure it's on top
	
	# ✅ Ensure all children are visible
	if textbox:
		textbox.visible = true
	if next_button:
		next_button.visible = true
	if skip_button:
		skip_button.visible = true
	
	next_button.pressed.connect(_on_next_button_pressed)
	skip_button.pressed.connect(_on_skip_button_pressed)
	
	print("✓ MiniGameTutorialPanel ready")
	
	# Start the tutorial
	_show_current_step()

func _show_current_step() -> void:
	if current_step < tutorial_texts.size():
		full_text = tutorial_texts[current_step]
		textbox.text = full_text
		textbox.visible_characters = 0
		
		is_typing = true
		start_typing()
		
		next_button.visible = true
		skip_button.visible = true
		print("Step %d: %s" % [current_step + 1, full_text.left(50)])
	else:
		_finish_tutorial()

# ========================
# TEXT ANIMATION
# ========================
func start_typing() -> void:
	"""Animate text appearing character by character"""
	for i in full_text.length():
		if not is_typing:  # Check if animation was cancelled
			break
		textbox.visible_characters = i + 1
		await get_tree().create_timer(typing_speed, false).timeout
	
	is_typing = false

func skip_typing() -> void:
	"""Skip typing animation and show full text immediately"""
	if is_typing:
		textbox.visible_characters = full_text.length()
		is_typing = false

func _on_next_button_pressed() -> void:
	if is_typing:
		# Skip typing and show full text
		skip_typing()
	else:
		# Move to next step
		current_step += 1
		_show_current_step()

func _on_skip_button_pressed() -> void:
	_finish_tutorial()

func _finish_tutorial() -> void:
	skip_typing()
	print("✓ Tutorial panel finished")
	tutorial_finished.emit()
	queue_free()
