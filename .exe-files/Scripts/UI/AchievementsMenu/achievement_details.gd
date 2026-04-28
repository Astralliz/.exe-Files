extends Control

@onready var description: RichTextLabel = $Panel/Description
@onready var close_button: Button = $Panel/CloseButton
@onready var color_rect: ColorRect = $ColorRect

func _ready():
	close_button.pressed.connect(_close)

	# Tap outside panel (ColorRect)
	color_rect.gui_input.connect(_on_background_input)

func set_description(text: String):
	description.text = text

func _on_background_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		_close()

	elif event is InputEventScreenTouch and event.pressed:
		_close()

func _close():
	# Instead of deleting, just hide OR delete depending on design
	queue_free()

func _on_color_rect_gui_input(event: InputEvent) -> void:
	pass # Replace with function body.
