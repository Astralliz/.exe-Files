class_name DialogueDatabase
extends Resource

var correct_feedback := [
	"[CORRECT] Great job! Your inspection is correct.",
	"[CORRECT] Well done. You spotted everything properly.",
	"[CORRECT] Nice work! That filetizen is clean."
]

var wrong_feedback := [
	"[FAIL] That's not quite right. Let's review the details.",
	"[FAIL] You missed something important during your inspection.",
	"[FAIL] That decision was incorrect. Look closely next time."
]

var false_negative_feedback := [
	"[FALSE NEGATIVE] This file was actually clean! Be careful not to reject safe files.",
	"[FALSE NEGATIVE] Oops! You declined a safe filetizen. Accuracy matters.",
	"[FALSE NEGATIVE] That file was fine—trust your inspections next time."
]

func get_random_correct() -> String:
	return correct_feedback.pick_random()

func get_random_wrong() -> String:
	return wrong_feedback.pick_random()

func get_random_false_negative() -> String:
	return false_negative_feedback.pick_random()

func build_wrong_details(metadata_issues: Array) -> String:
	var text := "Issues detected:\n"
	for issue in metadata_issues:
		text += "- %s\n" % issue
	return text
