class_name AnswerGenerator
extends Node2D

# Pools for misleading answers
var fake_names := [
	"system32_fix", "very_legit_file", "update_patch", "secret_payload",
	"doc_final_FINAL", "winupdate_1134", "data_recovery_tool"
]

var fake_extensions := [
	".sys", ".dll", ".tmp", ".dat", ".pdf", ".docs"
]

var fake_sources := [
	"???", "Corrupted Entry", "Unknown Device", "No Record"
]

var fake_publishers := [
	"Not Listed", "???", "ShadowSoft", "Unsigned Vendor"
]

var risky_extensions := [".exe", ".bat", ".js", ".vbs"]

func generate_answers(metadata, risk_score: float) -> Dictionary:
	var answers = {
		"filename": metadata.filename,
		"extension": metadata.extension,
		"size": str(round(metadata.size_mb * 100) / 100.0) + " MB",
		"source": metadata.source,
		"publisher": metadata.publisher
	}

	# Low-risk → honest answers
	if risk_score < 1.0:
		return answers

	# Determine max_wrong fields
	var max_wrong = 2
	if metadata.extension in risky_extensions:
		max_wrong = 3  # Force extension change if risky

	# Risky → insert lies
	var keys = ["filename", "extension", "source", "publisher"]
	keys.shuffle()
	var wrong_count = 0

	for key in keys:
		if wrong_count >= max_wrong:
			break

		var changed = false
		match key:
			"filename":
				var fake_val = fake_names.pick_random()
				while fake_val == metadata.filename:
					fake_val = fake_names.pick_random()
				answers[key] = fake_val
				changed = true
			"extension":
				var fake_ext = fake_extensions.pick_random()
				# ensure it's different from metadata.extension
				while fake_ext == metadata.extension:
					fake_ext = fake_extensions.pick_random()
				answers[key] = fake_ext
				changed = true
			"source":
				var fake_val = fake_sources.pick_random()
				while fake_val == metadata.source:
					fake_val = fake_sources.pick_random()
				answers[key] = fake_val
				changed = true
			"publisher":
				var fake_val = fake_publishers.pick_random()
				while fake_val == metadata.publisher:
					fake_val = fake_publishers.pick_random()
				answers[key] = fake_val
				changed = true

		if changed:
			wrong_count += 1

	return answers
