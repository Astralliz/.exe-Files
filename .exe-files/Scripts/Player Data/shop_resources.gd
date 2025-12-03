extends Node

@onready var questions_amount: Label = $Question/Amount
@onready var evaluation_amount: Label = $Evaluate/Amount

func _ready() -> void:
	Player_Data.connect("question_amount_change", Callable(self, "update_question_amount"))
	Player_Data.connect("evaluation_amount_change", Callable(self, "update_evaluation_amount"))

	update_question_amount()
	update_evaluation_amount()

# -------------------------
# Update functions
# -------------------------
func update_question_amount(new_question_amount: int = -1) -> void: 
	if new_question_amount > Player_Data.get_questions_left():
		questions_amount.text = str(new_question_amount)
	else:
		questions_amount.text = str(Player_Data.get_questions_left())

func update_evaluation_amount(new_evaluation_amount: int = -1) -> void:
	if new_evaluation_amount > Player_Data.get_evaluate_left():
		evaluation_amount.text = str(new_evaluation_amount)
	else:
		evaluation_amount.text = str(Player_Data.get_evaluate_left())
