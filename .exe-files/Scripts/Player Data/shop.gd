extends Node

@onready var notification: Label = $"../Panel3/Notification"

var bought = 5
var filer_bought = 2
var price = 20

var default_notification_text := ""

# spacing between text and icon
var icon_spacing := 12

func _ready() -> void:
	default_notification_text = notification.text
	


# =========================
# Show temporary notification
# =========================
func _show_notification(text: String) -> void:
	notification.text = text
	
	await get_tree().create_timer(1.0).timeout
	
	notification.text = default_notification_text


func _on_buy_filters_pressed() -> void:
	if Player_Data.get_bug_bounty() < 20:
		_show_notification("Insufficient Bug Bounty Balance")
	else:
		Player_Data.add_filter(filer_bought)
		Player_Data.spend_bug_bounty(price)
		_show_notification("Successfully bought")

func _on_buy_evaluates_pressed() -> void:
	if Player_Data.get_bug_bounty() < 20:
		_show_notification("Insufficient Bug Bounty Balance")
	else:
		Player_Data.add_evaluates(bought)
		Player_Data.spend_bug_bounty(price)
		_show_notification("Successfully bought")
