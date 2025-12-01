extends Control

@onready var welcome_label: Label = $Panel/WelcomeMessage

func _ready() -> void:
	# Access the saved username from your singleton
	var username: String = Player_Data.data.get("username", "Player")
	welcome_label.text = "Welcome, %s!" % username
	if !Player_Data.is_welcome_showed():
		visible = true
	else:
		visible = false


func _on_continue_btn_pressed() -> void:
	Player_Data.set_welcome_showed(true)
	visible = false
