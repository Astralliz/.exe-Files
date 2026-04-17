extends Control
class_name MiniGameFinished

@onready var score_label: Label = $ScrollContainer/Label
@onready var continue_btn: Button = $Continue
signal minigame_finished(success: bool)
var rounds_data: Array

var success_result: bool = false

func set_data(success: bool, score: int, rounds: Array, metrics: Dictionary) -> void:
	rounds_data = rounds

	_build_text(score, metrics)

	if not continue_btn.pressed.is_connected(_on_continue):
		continue_btn.pressed.connect(_on_continue)


func _build_text(score: int, metrics: Dictionary) -> void:
	var text := "=== PERFORMANCE PER CLASS ===\n\n"

	for label in ["malware", "injection", "phishing", "trojan"]:
		var p = metrics[label]["precision"] * 100
		var r = metrics[label]["recall"] * 100

		text += label.to_upper() + "\n"
		text += " Precision: %.2f%%\n" % p
		text += " Recall:    %.2f%%\n" % r

		if p >= 80 and r >= 80:
			text += " ✅ PASSED (≥80%)\n\n"
		else:
			text += " ❌ FAILED (<80%)\n\n"

	var acc = metrics["accuracy"] * 100
	text += "Overall Accuracy: %.2f%%" % acc

	score_label.text = text


func _on_continue():
	emit_signal("minigame_finished", success_result)
	queue_free()
