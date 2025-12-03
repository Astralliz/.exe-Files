extends Node

@onready var amount: Label = $Amount

func _ready() -> void:
	Player_Data.connect("bug_bounty_changed", Callable(self, "update_amount"))
	update_amount()


func update_amount(new_amount: int = -1) -> void:
	if new_amount >= 0:
		amount.text = str(new_amount)
	else:
		amount.text = str(Player_Data.get_bug_bounty())
