extends Node

func _ready():
	print("\n=== HEURISTICS TEST START ===")

	# Load classes
	var engine := HeuristicEngine.new()
	var rules := RuleBase.new()
	var file := FileMetadata.new()

	# Create dummy test data
	file.filename = "setup_payload123.exe"
	file.extension = "exe"
	file.size_mb = 70
	file.publisher = "unknown"
	file.source = "email"
	file.modified_hours_ago = 2
	file.hidden = false
	file.signature_valid = false
	file.requires_admin = true
	file.claimed_type = "exe"

	# Evaluate the file based on heuristics
	var score = engine.evaluate(file, rules)

	print("FILENAME: ", file.filename)
	print("EXTENSION: ", file.extension)
	print("HEURISTIC SCORE = ", score)

	if score >= 3:
		print("⚠️ THREAT LEVEL: HIGH (likely malicious!)")
	elif score >= 1.5:
		print("⚠️ THREAT LEVEL: MEDIUM (suspicious)")
	else:
		print("✓ THREAT LEVEL: LOW (likely safe)")
