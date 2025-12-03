extends Node

@onready var questions_amount: Label = $HBoxContainer/Question/Amount
@onready var evaluation_amount: Label = $HBoxContainer/Evaluate/Amount
@onready var bb_amount: Label = $HBoxContainer/BugBounty/Amount

var current_level: int = 1  # default, can be set from parent scene

func _ready() -> void:
	Player_Data.connect("bug_bounty_changed", Callable(self, "update_bounty_amount"))
	Player_Data.connect("question_amount_change", Callable(self, "update_question_amount"))
	Player_Data.connect("evaluation_amount_change", Callable(self, "update_evaluation_amount"))

	# Initial display
	update_bounty_amount()
	update_question_amount()
	update_evaluation_amount()

# -------------------------
# Update functions
# -------------------------
func update_bounty_amount(new_amount: int = -1) -> void:
	if new_amount >= Player_Data.get_bug_bounty():
		bb_amount.text = str(new_amount)
	else:
		bb_amount.text = str(Player_Data.get_bug_bounty())

func update_question_amount(new_question_amount: int = -1) -> void:
	if current_level == 1:
		questions_amount.text = "♾️"
	else:
		if new_question_amount >= Player_Data.get_questions_left():
			questions_amount.text = str(new_question_amount)
		else:
			questions_amount.text = str(Player_Data.get_questions_left())

func update_evaluation_amount(new_evaluation_amount: int = -1) -> void:
	if current_level == 1:
		evaluation_amount.text = "♾️"
	else:
		if new_evaluation_amount >= Player_Data.get_evaluate_left():
			evaluation_amount.text = str(new_evaluation_amount)
		else:
			evaluation_amount.text = str(Player_Data.get_evaluate_left())

# Optional: helper to set level from parent
func set_level(level: int) -> void:
	current_level = level
	update_question_amount()
	update_evaluation_amount()
