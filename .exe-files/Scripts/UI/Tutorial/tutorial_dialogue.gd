class_name TutorialDialogueBox
extends Control

@onready var text_box: RichTextLabel = $TextBox
@onready var close_button: Button = $NextButton
@onready var color_rect: ColorRect = $ColorRect

# ========================
# SIGNALS
# ========================
signal closed

# ========================
# VARIABLES
# ========================
var typing_speed := 0.02
var is_typing := false
var full_text := ""

# ========================
# LIFECYCLE
# ========================
func _ready():
	visible = false
	close_button.pressed.connect(_on_next_button_pressed)
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP

# ========================
# DIALOGUE DISPLAY
# ========================
func show_dialogue(message: String):
	"""Show dialogue with typing animation"""
	full_text = message
	text_box.text = message
	text_box.visible_characters = 0
	visible = true
	is_typing = true
	color_rect.modulate.a = 0.0
	
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 0.6, 0.2)
	start_typing()

func start_typing():
	"""Animate text appearing character by character"""
	for i in full_text.length():
		text_box.visible_characters = i + 1
		await get_tree().create_timer(typing_speed).timeout
	
	is_typing = false

func hide_dialogue():
	"""Hide dialogue with fade animation"""
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 0.0, 0.2)
	tween.finished.connect(func():
		visible = false
		# ✅ EMIT THE SIGNAL when dialogue closes
		closed.emit()
	)

# ========================
# BUTTON HANDLER
# ========================
func _on_next_button_pressed() -> void:
	"""Handle next button click"""
	if is_typing:
		# Skip typing instantly
		text_box.visible_characters = full_text.length()
		is_typing = false
	else:
		hide_dialogue()
