extends Node

@onready var notification: Label = $"../Notification"

var bought = 5
var price = 20

# Function to show notification and auto-hide after 1 second
func _show_notification(text: String) -> void:
	notification.text = text
	await get_tree().create_timer(1.0).timeout
	notification.text = ""
	
func _on_buy_filters_pressed() -> void:
	if Player_Data.get_bug_bounty() < 5:
		_show_notification("Insufficient Bug Bounty Balance")
	else:
		Player_Data.add_filter(bought)
		Player_Data.spend_bug_bounty(price)
		_show_notification("Successfully bought")

func _on_buy_evaluates_pressed() -> void:
	if Player_Data.get_bug_bounty() < 5:
		_show_notification("Insufficient Bug Bounty Balance")
	else:
		Player_Data.add_evaluates(bought)
		Player_Data.spend_bug_bounty(price)
		_show_notification("Successfully bought")
