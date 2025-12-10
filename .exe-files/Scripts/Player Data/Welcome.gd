extends Control

@onready var welcome_label: Label = $Panel/WelcomeMessage

func _ready() -> void:
	# Access the saved username from your singleton
	var username: String = Player_Data.data.get("username", "Player")
	welcome_label.text = "Welcome, %s!" % username
	if Player_Data.data["new_to_game"] <= 1:
		visible = true
	else:
		visible = false

func _on_continue_btn_pressed() -> void:
	Player_Data.set_new_game_status(2)
	visible = false
