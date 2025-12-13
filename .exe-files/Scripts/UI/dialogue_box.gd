class_name DialogueBox
extends Control

@onready var text_box: RichTextLabel = $TextBox
@onready var close_button: Button = $CloseButton

signal closed

func _ready():
	visible = false
	close_button.pressed.connect(hide_dialogue)

func show_dialogue(message: String):
	text_box.text = message
	visible = true

func hide_dialogue():
	visible = false
	emit_signal("closed")
