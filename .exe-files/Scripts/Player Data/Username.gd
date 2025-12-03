extends Control

@onready var username_input: TextEdit = $Panel/VBoxContainer/Username
@onready var save_button: Button = $Panel/VBoxContainer/Save

func _ready() -> void:
	if Player_Data.data["username"]:
		print("has value")
		# You can show tutorials or first-time setup
		visible = false
	
	save_button.pressed.connect(_on_submit_pressed)
	# Optional: load existing username in development
	username_input.text = Player_Data.data.get("username")

func _on_submit_pressed() -> void:
	var name := username_input.text.strip_edges()
	if name == "":
		print("Please enter a username!")
		return

	# Save to PlayerData (temporary or permanent depending on TEMP_SAVE)
	Player_Data.set_username(name)
	print("Username set to:", Player_Data.data["username"])
	
	visible = false
