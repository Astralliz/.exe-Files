# AnswerGenerator.gd
class_name AnswerGenerator
extends Node2D

# =========================
# FAKE POOLS
# =========================
var fake_names := [
	"system32_fix", "very_legit_file", "update_patch",
	"secret_payload", "doc_final_FINAL", "winupdate_1134",
	"data_recovery_tool"
]

var fake_extensions := [".sys", ".dll", ".tmp", ".dat", ".pdf", ".docs"]
var fake_sources := ["???", "Corrupted Entry", "Unknown Device", "No Record"]
var fake_publishers := ["Not Listed", "???", "ShadowSoft", "Unsigned Vendor"]
var risky_extensions := [".exe", ".bat", ".js", ".vbs"]

# =========================
# HELPER FUNCTION FOR LOGICAL LIES
# =========================
func logical_lie(key: String, metadata) -> String:
	match key:
		"filename":
			return metadata.filename + str(randi() % 9)
		"extension":
			if metadata.extension in risky_extensions:
				return ".pdf"
			else:
				return fake_extensions.pick_random()
		"source":
			return "Downloads"
		"publisher":
			return "Microsoft Corporation"
		"size":
			if metadata.size_mb > 50.0:
				return str(round(randf_range(40.0, metadata.size_mb) * 100.0) / 100.0) + " MB"
			else:
				return str(round(randf_range(metadata.size_mb, metadata.size_mb + 20.0) * 100.0) / 100.0) + " MB"
		"modified":
			if metadata.modified_hours_ago < 5:
				return str(randi_range(50, 500)) + " hours ago"
			else:
				return str(randi_range(1, 3)) + " hours ago"
		"hidden":
			return "No" if metadata.hidden else "Yes"
		"signature":
			return "No" if metadata.signature_valid else "Yes"
		"admin":
			return "No" if metadata.requires_admin else "Yes"
		"compressed":
			return "No" if metadata.is_compressed else "Yes"
	return "" # fallback

# =========================
# MAIN FUNCTION
# =========================
func generate_answers(metadata, risk_score: float, day: int) -> Dictionary:

	# -------------------------
	# Determine Level From Day
	# -------------------------
	var level: int = 1
	if day <= 2:
		level = 1
	elif day <= 4:
		level = 2
	else:
		level = 3

	# -------------------------
	# Base Honest Answers
	# -------------------------
	var answers: Dictionary = {
		"filename": metadata.filename,
		"extension": metadata.extension,
		"size": str(round(metadata.size_mb * 100.0) / 100.0) + " MB",
		"source": metadata.source,
		"publisher": metadata.publisher,
		"modified": str(metadata.modified_hours_ago) + " hours ago",
		"hidden": "Yes" if metadata.hidden else "No",
		"signature": "Yes" if metadata.signature_valid else "No",
		"admin": "Yes" if metadata.requires_admin else "No",
		"compressed": "Yes" if metadata.is_compressed else "No"
	}

	# -------------------------
	# Suspicious Threshold
	# -------------------------
	var threshold: float = 1.0
	match level:
		1:
			threshold = 1.0
		2:
			threshold = 1.5
		3:
			threshold = 2.0

	# Safe file → return honest answers
	if risk_score < threshold:
		return answers

	# -------------------------
	# Group Keys for logical lies
	# -------------------------
	var group1 := ["filename", "extension", "source", "publisher", "size"]
	var group2 := ["modified", "hidden", "signature", "admin", "compressed"]

	group1.shuffle()
	group2.shuffle()

	# -------------------------
	# Decide lies per group
	# -------------------------
	var lies_group1 := 2
	var lies_group2 := 2

	# Apply lies in group1
	for i in range(lies_group1):
		var key = group1[i]
		answers[key] = logical_lie(key, metadata)

	# Apply lies in group2
	for i in range(lies_group2):
		var key = group2[i]
		answers[key] = logical_lie(key, metadata)

	return answers
