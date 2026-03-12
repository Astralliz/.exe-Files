class_name HeuristicEngine
extends Node

const FileMetadataScript = preload("res://Scripts/Data Models/file_metadata.gd")
const RuleBaseScript = preload("res://Scripts/Algorithm/Rules/rule_base.gd")

const FileMetadata = FileMetadataScript
const RuleBase = RuleBaseScript

func evaluate(file: FileMetadata, rules: Array, answer: Dictionary = {}) -> Dictionary:
	var score = 0.0
	var issues: Array = []

	for rule in rules:
		var triggered := false
		match rule.condition:
			"size_large":
				if file.size_mb > 50:
					score += rule.score
					triggered = true
			"ext_exe":
				if file.extension == ".exe":
					score += rule.score
					triggered = true
			"ext_script":
				if file.extension in [".bat", ".ps1"]:
					score += rule.score
					triggered = true
			"ext_dropper":
				if file.extension in [".js", ".vbs"]:
					score += rule.score
					triggered = true
			"unknown_publisher":
				if file.publisher == "unknown":
					score += rule.score
					triggered = true
			"recent_modified":
				if file.modified_hours_ago <= 24:
					score += rule.score
					triggered = true
			"src_email":
				if file.source in ["email", "Email Attachment"]:
					score += rule.score
					triggered = true
			"src_unknown":
				if file.source == "unknown":
					score += rule.score
					triggered = true
			"is_hidden":
				if file.hidden:
					score += rule.score
					triggered = true
			"random_filename":
				if _is_random_filename(file.filename):
					score += rule.score
					triggered = true
			"invalid_signature":
				if !file.signature_valid:
					score += rule.score
					triggered = true
			"needs_admin":
				if file.requires_admin:
					score += rule.score
					triggered = true
					
			 #Only apply if answer is passed in
			"type_mismatch":
				if answer.has("extension") and answer["extension"] != file.extension:
					score += rule.score
					triggered = true
		if triggered:
			issues.append(rule.condition)
	return {
		"score": score,
		"issues": issues
	}

func evaluate_type_mismatch(file: FileMetadata, answer: Dictionary, rules: Array) -> float:
	var score = 0.0
	for rule in rules:
		if rule.condition == "type_mismatch":
			if answer.has("extension") and answer["extension"] != file.extension:
				score += rule.score
	return score

func _is_random_filename(name: String) -> bool:
	# If filename has many numbers or mixed-case random letters
	var pattern = r"[A-Za-z0-9]{8,}"
	return name.match(pattern)
