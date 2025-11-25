class_name HeuristicEngine
extends Node
# preload classes (adjust paths to match your project)
const FileMetadataScript = preload("res://Scripts/Data Models/file_metadata.gd")
const RuleBaseScript = preload("res://Scripts/Algorithm/Rules/rule_base.gd")
# If you want type hints, you can alias the names:
const FileMetadata = FileMetadataScript
const RuleBase = RuleBaseScript

func evaluate(file: FileMetadata, rule_base: RuleBase) -> float:
	var score = 0.0

	for rule in rule_base.rules:
		match rule.condition:
			"size_large":
				if file.size_mb > 50:
					score += rule.score

			"ext_exe":
				if file.extension == "exe":
					score += rule.score

			"ext_script":
				if file.extension in ["bat", "cmd"]:
					score += rule.score

			"ext_dropper":
				if file.extension in ["js", "vbs"]:
					score += rule.score

			"name_installer":
				if "setup" in file.filename.to_lower() or "installer" in file.filename.to_lower():
					score += rule.score

			"unknown_publisher":
				if file.publisher == "unknown":
					score += rule.score

			"recent_modified":
				if file.modified_hours_ago <= 24:
					score += rule.score

			"src_email":
				if file.source == "email":
					score += rule.score

			"src_unknown":
				if file.source == "unknown":
					score += rule.score

			"is_hidden":
				if file.hidden:
					score += rule.score

			"random_filename":
				if _is_random_filename(file.filename):
					score += rule.score

			"invalid_signature":
				if !file.signature_valid:
					score += rule.score

			"needs_admin":
				if file.requires_admin:
					score += rule.score

			"type_mismatch":
				if file.claimed_type != file.extension:
					score += rule.score

	return score


func _is_random_filename(name: String) -> bool:
	# If filename has many numbers or mixed-case random letters
	var pattern = r"[A-Za-z0-9]{8,}"
	return name.match(pattern)
