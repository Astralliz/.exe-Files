# ==============================
# DECISION TREE ANALYZER
# Converts Python DecisionTreeClassifier logic to GDScript
# Input: File metadata dictionary
# Output: Attack type prediction (malware, phishing, injection, trojan)
# ==============================

class_name DecisionTreeAnalyzer

# ==============================
# RISKY INDICATORS
# ==============================
const RISKY_EXTENSIONS = [".exe", ".bat", ".js", ".ps1", ".vbs"]
const INJECTION_EXTENSIONS = [".bat", ".ps1"]
const MALWARE_EXTENSIONS = [".exe", ".js", ".vbs"]
const SAFE_EXTENSIONS = [".txt", ".pdf", ".png", ".jpg", ".mp3", ".mp4", ".docx"]

# ==============================
# HELPER FUNCTIONS
# ==============================

## Check if filename appears randomly generated (long with numbers)
func is_random_filename(filename: String) -> bool:
	if filename.length() <= 15:
		return false
	
	var has_digit = false
	for char in filename:
		if char.is_valid_int():
			has_digit = true
			break
	
	return has_digit


## Analyze metadata and return attack type prediction
## Input: Only 5 variables - extension, size, publisher, source, filename
func predict(metadata: Dictionary) -> String:
	var extension = metadata.get("extension", "")
	var publisher = metadata.get("publisher", "")
	var source = metadata.get("source", "")
	var filename = metadata.get("filename", "")
	# var size = metadata.get("size", 0)  # Not used in decision tree logic
	
	# Calculate derived features internally (no need to pass them)
	var random_name = 1 if is_random_filename(filename) else 0
	
	# ==============================
	# DECISION TREE LOGIC
	# Based on Python model's decision rules
	# ==============================
	
	# Rule 1: Batch/PowerShell scripts always = injection
	if extension in INJECTION_EXTENSIONS:
		return "injection"
	
	# Rule 2: Executable files with unknown publisher or suspicious source = malware
	if extension in MALWARE_EXTENSIONS:
		if publisher == "unknown" or source in ["Downloads", "Browser Cache"]:
			return "malware"
	
	# Rule 3: Email attachments with random name or unknown publisher = phishing
	if source == "Email Attachment":
		if random_name == 1 or publisher == "unknown":
			return "phishing"
	
	# Rule 4: Safe extensions with unknown publisher AND random name = trojan
	if extension in SAFE_EXTENSIONS:
		if publisher == "unknown" and random_name == 1:
			return "trojan"
	
	# Default fallback
	return "malware"


## Get the minigame scene path based on attack type prediction
func get_minigame_scene_path(attack_type: String) -> String:
	match attack_type:
		"malware":
			return "res://Scenes/Mini Games Scene/malware_attack.tscn"
		"phishing":
			return "res://Scenes/Mini Games Scene/phishing_attack.tscn"
		"injection":
			return "res://Scenes/Mini Games Scene/injection_attack.tscn"
		"trojan":
			return "res://Scenes/Mini Games Scene/trojan_attack.tscn"
		_:
			return "res://Scenes/Mini Games Scene/malware_attack.tscn"


## Debug: Print prediction details
func print_prediction_details(metadata: Dictionary, prediction: String) -> void:
	print("\n=== DECISION TREE PREDICTION ===")
	print("Extension: ", metadata.get("extension", "unknown"))
	print("Size (MB): ", metadata.get("size", "unknown"))
	print("Publisher: ", metadata.get("publisher", "unknown"))
	print("Source: ", metadata.get("source", "unknown"))
	print("Filename: ", metadata.get("filename", "unknown"))
	print("🧠 Prediction: ", prediction)
	print("Minigame Scene: ", get_minigame_scene_path(prediction))
	print("================================\n")
