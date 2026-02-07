extends Control

@onready var username_input: LineEdit = $Panel/VBoxContainer/HBoxContainer/Username
@onready var edit_button: Button = $Panel/VBoxContainer/HBoxContainer/Edit
@onready var save_button: Button = $Panel/VBoxContainer/Save

func _ready() -> void:
	# Load username
	username_input.text = Player_Data.data.get("username", "")
	username_input.editable = false
	
	# Button disabled visually until Edit clicked
	save_button.disabled = true
	
	# Connect signals (works even if disabled)
	save_button.pressed.connect(_on_save_pressed)
	edit_button.pressed.connect(_on_edit_pressed)

func _on_edit_pressed() -> void:
	username_input.editable = true
	username_input.grab_focus()
	save_button.disabled = false  # Enable the Save button now

func _on_save_pressed() -> void:
	print("Save Button Clicked for Edit username")
	var new_username := username_input.text.strip_edges()
	
	if new_username.is_empty():
		return
	if new_username == Player_Data.data["username"]:
		queue_free()
		return

	Player_Data.set_username(new_username)

	# Lock again
	username_input.editable = false
	save_button.disabled = true  # Disable after saving
	queue_free()
	
func _on_color_rect_gui_input(event: InputEvent) -> void: 
	if event is InputEventMouseButton and event.pressed: 
		queue_free()
