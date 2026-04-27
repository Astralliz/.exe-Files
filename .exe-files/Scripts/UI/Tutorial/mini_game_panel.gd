# res://Scripts/MiniGameTutorialPanels.gd
class_name MiniGameTutorialPanels
extends Control

signal tutorial_completed

@onready var first_panel: Panel = $FirstPanel
@onready var second_panel: Panel = $SecondPanel
@onready var third_panel: Panel = $ThirdPanel
@onready var skip_button: Button = $SkipButton

# Arrow references for third panel
@onready var arrow_down1: Panel = $ThirdPanel/ArrowDown
@onready var arrow_down2: Panel = $ThirdPanel/ArrowDown2
@onready var arrow_down3: Panel = $ThirdPanel/ArrowDown3
@onready var arrow_down4: Panel = $ThirdPanel/ArrowDown4

# References to each panel's components
var first_panel_textbox: RichTextLabel
var first_panel_next_btn: Button

var second_panel_textbox: RichTextLabel
var second_panel_next_btn: Button

var third_panel_textbox: RichTextLabel
var third_panel_next_btn: Button

var current_step: int = 0
var game_reference: MiniGame  # Reference to parent MiniGame

# ========================
# TEXT ANIMATION
# ========================
var typing_speed: float = 0.02
var is_typing: bool = false
var full_text: String = ""
var arrow_tweens: Array[Tween] = []

# Tutorial step data
var steps: Array[Dictionary] = [
	{
		"panel": "first",
		"text": "Here is the Conveyor carrying all documents. Wait till the 1st document reaches the end, then you can open it by tapping the document."
	},
	{
		"panel": "first",
		"text": "Try tapping one of the documents in the conveyor."
	},
	{
		"panel": "second",
		"text": "This is the opened document. Review it and pay attention to the hints that give clues about what type of attack it is."
	},
	{
		"panel": "second",
		"text": "The document is draggable, and you can tap the lower part of it to close it again."
	},
	{
		"panel": "third",
		"text": "Now here are the 4 attack types: Malware, Injection, Phishing, and Trojan."
	},
	{
		"panel": "third",
		"text": "Drag the document and drop it into the correct attack type."
	},
	{
		"panel": "third",
		"text": "Remember: You must open the document, then close it, then you can drag it from the conveyor to the respective attack types."
	},
	{
		"panel": "finish",
		"text": "You're now ready to go, Inspector %s!" # Will be replaced with username
	},
]

func _ready() -> void:
	# ✅ CRITICAL: Allow input to pass through to game underneath
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Cache references to textbox and next button for each panel
	_setup_panel_references()
	
	# Hide all panels initially
	first_panel.visible = false
	second_panel.visible = false
	third_panel.visible = false
	
	# ✅ Ensure skip button can still receive input (it's on top)
	skip_button.mouse_filter = Control.MOUSE_FILTER_STOP
	
	skip_button.pressed.connect(_on_skip_button_pressed)
	
	print("✓ MiniGameTutorialPanels ready - input passthrough enabled")
	
	# Start tutorial
	_show_current_step()

func _setup_panel_references() -> void:
	# Setup FirstPanel - Find Frame/Textbox and NextButton
	var first_frame = first_panel.find_child("frame", true, false)
	if first_frame:
		first_panel_textbox = first_frame.find_child("TextBox", true, false)
		first_panel_next_btn = first_frame.find_child("NextButton", true, false)
		if first_panel_next_btn:
			first_panel_next_btn.pressed.connect(_on_next_button_pressed)
		# ✅ Allow input to pass through blocking panels
		first_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Setup SecondPanel
	var second_frame = second_panel.find_child("frame", true, false)
	if second_frame:
		second_panel_textbox = second_frame.find_child("TextBox", true, false)
		second_panel_next_btn = second_frame.find_child("NextButton", true, false)
		if second_panel_next_btn:
			second_panel_next_btn.pressed.connect(_on_next_button_pressed)
		# ✅ Allow input to pass through blocking panels
		second_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Setup ThirdPanel
	var third_frame = third_panel.find_child("frame", true, false)
	if third_frame:
		third_panel_textbox = third_frame.find_child("TextBox", true, false)
		third_panel_next_btn = third_frame.find_child("NextButton", true, false)
		if third_panel_next_btn:
			third_panel_next_btn.pressed.connect(_on_next_button_pressed)
		# ✅ Allow input to pass through blocking panels
		third_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _show_current_step() -> void:
	if current_step >= steps.size():
		_finish_tutorial()
		return
	
	var step = steps[current_step]
	var panel_name = step["panel"]
	var text = step["text"]
	
	# Replace username placeholder if it's the finish step
	if "%s" in text:
		text = text % Player_Data.data["username"]
	
	# ✅ Stop all animations before showing next step
	_stop_all_animations()
	
	match panel_name:
		"first":
			_show_first_panel(text)
		"second":
			_show_second_panel(text)
		"third":
			_show_third_panel(text)
		"finish":
			_show_finish_message(text)

func _show_first_panel(text: String) -> void:
	# Hide all other panels
	second_panel.visible = false
	third_panel.visible = false
	
	# Show first panel
	first_panel.visible = true
	
	if first_panel_textbox:
		full_text = text
		first_panel_textbox.text = full_text
		first_panel_textbox.visible_characters = 0
		is_typing = true
		start_typing()

func _show_second_panel(text: String) -> void:
	# Hide others
	first_panel.visible = false
	third_panel.visible = false
	
	# Show second panel
	second_panel.visible = true
	
	if second_panel_textbox:
		full_text = text
		second_panel_textbox.text = full_text
		second_panel_textbox.visible_characters = 0
		is_typing = true
		start_typing()

func _show_third_panel(text: String) -> void:
	# Hide others
	first_panel.visible = false
	second_panel.visible = false
	
	# Show third panel
	third_panel.visible = true
	
	if third_panel_textbox:
		full_text = text
		third_panel_textbox.text = full_text
		third_panel_textbox.visible_characters = 0
		is_typing = true
		start_typing()
	
	# ✅ Start arrow animations for third panel
	_animate_arrows()

func _show_finish_message(text: String) -> void:
	# Hide all panel overlays
	first_panel.visible = false
	second_panel.visible = false
	third_panel.visible = false
	
	# Show a temporary finish message (you can create a finish panel if needed)
	# For now, we'll just emit the signal after a brief delay
	await get_tree().create_timer(0.5).timeout
	_finish_tutorial()

# ========================
# TEXT ANIMATION
# ========================
func start_typing() -> void:
	"""Animate text appearing character by character"""
	for i in full_text.length():
		if not is_typing:  # Check if animation was cancelled
			break
		
		# Update visible characters for the active textbox
		if first_panel.visible and first_panel_textbox:
			first_panel_textbox.visible_characters = i + 1
		elif second_panel.visible and second_panel_textbox:
			second_panel_textbox.visible_characters = i + 1
		elif third_panel.visible and third_panel_textbox:
			third_panel_textbox.visible_characters = i + 1
		
		await get_tree().create_timer(typing_speed, false).timeout
	
	is_typing = false

func skip_typing() -> void:
	"""Skip typing animation and show full text immediately"""
	if is_typing:
		if first_panel.visible and first_panel_textbox:
			first_panel_textbox.visible_characters = full_text.length()
		elif second_panel.visible and second_panel_textbox:
			second_panel_textbox.visible_characters = full_text.length()
		elif third_panel.visible and third_panel_textbox:
			third_panel_textbox.visible_characters = full_text.length()
		
		is_typing = false

# ========================
# ARROW ANIMATIONS
# ========================
func _animate_arrows() -> void:
	"""Animate all 4 arrows moving up and down"""
	var arrows = [arrow_down1, arrow_down2, arrow_down3, arrow_down4]
	var move_distance = 15.0
	var duration = 0.6
	
	for arrow in arrows:
		if is_instance_valid(arrow):
			_animate_arrow_vertical(arrow, move_distance, duration)
 
func _animate_arrow_vertical(arrow: Panel, move_distance: float, duration: float) -> void:
	"""Animate single arrow moving up and down"""
	if not is_instance_valid(arrow):
		return
	
	var start_pos = arrow.position.y
	var tween = create_tween()
	tween.set_loops()
	
	tween.tween_property(arrow, "position:y", start_pos + move_distance, duration)
	tween.tween_property(arrow, "position:y", start_pos - move_distance, duration)
	
	arrow_tweens.append(tween)

# ========================
# BUTTON HANDLERS
# ========================
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

# ========================
# CLEANUP
# ========================
func _stop_all_animations() -> void:
	"""Stop typing and arrow animations"""
	skip_typing()
	
	# Kill all arrow tweens
	for tween in arrow_tweens:
		if tween:
			tween.kill()
	arrow_tweens.clear()

func _finish_tutorial() -> void:
	_stop_all_animations()
	print("✓ Tutorial completed!")
	tutorial_completed.emit()
	queue_free()

# Optional: Call this to pause the tutorial and show the minigame
func hide_tutorial() -> void:
	visible = false

# Optional: Call this to resume showing the tutorial
func show_tutorial() -> void:
	visible = true
