extends Control

@onready var username_input: LineEdit = $Panel/VBoxContainer/Username
@onready var save_button: Button = $Panel/VBoxContainer/Save

func _ready() -> void:
	# Show only if username is empty
	if Player_Data.data.get("username", "") != "":
		visible = false
	else:
		visible = true

	save_button.pressed.connect(_on_submit_pressed)

	# Safe load
	username_input.text = Player_Data.data.get("username", "")

func _on_submit_pressed() -> void:
	var name := username_input.text.strip_edges()

	if name == "":
		return

	Player_Data.set_username(name)
	Player_Data.set_new_game_status(1)

	visible = false
