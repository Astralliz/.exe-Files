extends Node

@onready var filter_amount: Label = $Filters/Amount
@onready var evaluation_amount: Label = $Evaluates/Amount
@onready var bb_amount: Label = $BugBounty/Amount

var current_level: int = 1  # default, can be set from parent scene

func _ready() -> void:
	Player_Data.connect("bug_bounty_changed", Callable(self, "update_bounty_amount"))
	Player_Data.connect("filter_amount_change", Callable(self, "update_filter_amount"))
	Player_Data.connect("evaluation_amount_change", Callable(self, "update_evaluation_amount"))

	# Initial display
	update_bounty_amount()
	update_filter_amount()
	update_evaluation_amount()

# -------------------------
# Update functions
# -------------------------
func update_bounty_amount(new_amount: int = -1) -> void:
	if new_amount >= Player_Data.get_bug_bounty():
		bb_amount.text = str(new_amount)
	else:
		bb_amount.text = str(Player_Data.get_bug_bounty())

func update_filter_amount(new_filter_amount: int = -1) -> void:
	if Player_Data.data["level"] < 1:
		filter_amount.text = "∞"
	else:
		if new_filter_amount >= Player_Data.get_filter_left():
			filter_amount.text = str(new_filter_amount)
		else:
			filter_amount.text = str(Player_Data.get_filter_left())

func update_evaluation_amount(new_evaluation_amount: int = -1) -> void:
	if Player_Data.data["level"] < 1:
		evaluation_amount.text = "∞"
	else:
		if new_evaluation_amount >= Player_Data.get_evaluate_left():
			evaluation_amount.text = str(new_evaluation_amount)
		else:
			evaluation_amount.text = str(Player_Data.get_evaluate_left())

# Optional: helper to set level from parent
func set_level(level: int) -> void:
	current_level = level
	update_filter_amount()
	update_evaluation_amount()
