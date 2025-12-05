extends Node

@onready var filter_amount: Label = $Filters/Amount
@onready var evaluation_amount: Label = $Evaluate/Amount

func _ready() -> void:
	Player_Data.connect("filter_amount_change", Callable(self, "update_filter_amount"))
	Player_Data.connect("evaluation_amount_change", Callable(self, "update_evaluation_amount"))

	update_filter_amount()
	update_evaluation_amount()

# -------------------------
# Update functions
# -------------------------
func update_filter_amount(new_filter_amount: int = -1) -> void: 
	if new_filter_amount > Player_Data.get_filter_left():
		filter_amount.text = str(new_filter_amount)
	else:
		filter_amount.text = str(Player_Data.get_filter_left())

func update_evaluation_amount(new_evaluation_amount: int = -1) -> void:
	if new_evaluation_amount > Player_Data.get_evaluate_left():
		evaluation_amount.text = str(new_evaluation_amount)
	else:
		evaluation_amount.text = str(Player_Data.get_evaluate_left())
