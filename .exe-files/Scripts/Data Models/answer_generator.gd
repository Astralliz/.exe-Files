class_name AnswerGenerator
extends Node2D

# Pools for misleading answers
var fake_names := [
	"system32_fix", "very_legit_file", "update_patch", "secret_payload",
	"doc_final_FINAL", "winupdate_1134", "data_recovery_tool"
]

var fake_extensions := [
	".sys", ".dll", ".tmp", ".dat"
]

var fake_sources := [
	"???", "Corrupted Entry", "Unknown Device", "No Record"
]

var fake_publishers := [
	"Not Listed", "???", "ShadowSoft", "Unsigned Vendor"
]

func generate_answers(metadata, risk_score: float) ->Dictionary:
	var answers = {
		"filename": metadata.filename,
		"extension": metadata.extension,
		"size": str(round(metadata.size_mb * 100) / 100.0) + " MB",
		"source": metadata.source,
		"publisher": metadata.publisher
	}
		# Low-risk → File answers honestly
	if risk_score < 2.0:
		return answers
	
	# Medium/high risk → Insert lies (at least 2)
	var keys = ["filename", "extension", "source", "publisher"]
	keys.shuffle()
	
	var wrong_count = 0
	
	for key in keys:
		if wrong_count >= 2:
			break

		match key:
			"filename":
				answers[key] = fake_names.pick_random()
			"extension":
				answers[key] = fake_extensions.pick_random()
			"source":
				answers[key] = fake_sources.pick_random()
			"publisher":
				answers[key] = fake_publishers.pick_random()
		wrong_count += 1
	
	return answers
