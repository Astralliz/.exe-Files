class_name TutorialDialogueBox
extends Control

@onready var text_box: RichTextLabel = $TextBox
@onready var close_button: Button = $CloseButton
@onready var color_rect: ColorRect = $ColorRect

signal closed

func _ready():
	visible = false
	close_button.pressed.connect(hide_dialogue)
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP

func show_dialogue(message: String):
	text_box.text = message
	visible = true
	color_rect.modulate.a = 0.0
	
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 0.6, 0.2)

func hide_dialogue():
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 0.0, 0.2)
	tween.finished.connect(func():
		visible = false
		emit_signal("closed")
	)
