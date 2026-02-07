extends Control

@onready var yes_button: Button = $Panel/VBoxContainer/HBoxContainer/Yes
@onready var cancel_button: Button = $Panel/VBoxContainer/HBoxContainer/Cancel
@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	# Connect buttons
	yes_button.pressed.connect(_on_yes_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	color_rect.gui_input.connect(_on_color_rect_gui_input)

func _on_yes_pressed() -> void:
	# Reset all player data
	Player_Data.reset_data()
	print("Player data cleared!")
	queue_free()  # Close the dialog

func _on_cancel_pressed() -> void:
	queue_free()  # Just close the dialog

func _on_color_rect_gui_input(event: InputEvent) -> void:
	# Clicking outside closes the dialog
	if event is InputEventMouseButton and event.pressed:
		queue_free()
