# ==============================
# DECISION TREE ANALYZER (ENHANCED)
# Converts Python DecisionTreeClassifier logic to GDScript
# Supports 3 difficulty levels with progressive feature complexity
# Input: File metadata dictionary (varies by level)
# Output: Attack type prediction (malware, phishing, injection, trojan)
# ==============================
class_name DecisionTreeAnalyzer

# ==============================
# DIFFICULTY LEVELS
# ==============================
enum DifficultyLevel {
	LEVEL_1 = 1,  # Basic: filename, extension, size, publisher, source
	LEVEL_2 = 2,  # Intermediate: + modified_hours_ago, hidden
	LEVEL_3 = 3   # Advanced: + signature_valid, requires_admin, is_compressed
}

# ==============================
# RISKY INDICATORS
# ==============================
const RISKY_EXTENSIONS = [".exe", ".bat", ".js", ".ps1", ".vbs"]
const INJECTION_EXTENSIONS = [".bat", ".ps1"]
const MALWARE_EXTENSIONS = [".exe", ".js", ".vbs"]
const SAFE_EXTENSIONS = [".txt", ".pdf", ".png", ".jpg", ".mp3", ".mp4", ".docx"]

# ==============================
# THRESHOLD CONSTANTS
# ==============================
const MODIFIED_RECENTLY_HOURS = 24  # Files modified within 24 hours are suspicious
const LARGE_FILE_SIZE_MB = 50       # Files larger than 50MB are suspicious
const VALID_SIGNATURE_SAFETY_BOOST = -2.0  # Reduces risk score
const ADMIN_REQUIREMENT_RISK = 3.0  # Increases risk score
const COMPRESSED_FILE_RISK = 2.0    # Increases risk score

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

## Get the difficulty level based on day number
func get_difficulty_level_from_day(day: int) -> int:
	if day <= 2:
		return DifficultyLevel.LEVEL_1
	elif day <= 4:
		return DifficultyLevel.LEVEL_2
	else:
		return DifficultyLevel.LEVEL_3

## Calculate risk score based on metadata and difficulty level
func calculate_risk_score(metadata: Dictionary, difficulty_level: int = 1) -> float:
	var risk_score = 0.0
	
	var extension = metadata.get("extension", "")
	var publisher = metadata.get("publisher", "")
	var source = metadata.get("source", "")
	var filename = metadata.get("filename", "")
	var size = metadata.get("size", 0.0)
	
	# ==============================
	# LEVEL 1: BASE RISK FACTORS
	# ==============================
	
	# Risky extension check
	if extension in RISKY_EXTENSIONS:
		risk_score += 5.0
	
	# Unknown publisher is highly suspicious
	if publisher == "unknown":
		risk_score += 3.0
	
	# Suspicious source (downloads, cache)
	if source in ["Downloads", "Browser Cache"]:
		risk_score += 2.0
	
	# Email attachments are inherently suspicious
	if source == "Email Attachment":
		risk_score += 1.5
	
	# Random filename indicates obfuscation
	if is_random_filename(filename):
		risk_score += 2.5
	
	# Large file size is suspicious
	if size > LARGE_FILE_SIZE_MB:
		risk_score += 1.5
	
	# ==============================
	# LEVEL 2: ADDITIONAL INDICATORS
	# ==============================
	
	if difficulty_level >= DifficultyLevel.LEVEL_2:
		var modified_hours_ago = metadata.get("modified_hours_ago", -1)
		var hidden = metadata.get("hidden", false)
		
		# Recently modified files are suspicious
		if modified_hours_ago >= 0 and modified_hours_ago < MODIFIED_RECENTLY_HOURS:
			risk_score += 2.0
		
		# Hidden files are very suspicious
		if hidden:
			risk_score += 3.0
	
	# ==============================
	# LEVEL 3: ADVANCED INDICATORS
	# ==============================
	
	if difficulty_level >= DifficultyLevel.LEVEL_3:
		var signature_valid = metadata.get("signature_valid", false)
		var requires_admin = metadata.get("requires_admin", false)
		var is_compressed = metadata.get("is_compressed", false)
		
		# Valid signature reduces risk
		if signature_valid:
			risk_score += VALID_SIGNATURE_SAFETY_BOOST  # Negative value
		
		# Admin requirement is a major red flag
		if requires_admin:
			risk_score += ADMIN_REQUIREMENT_RISK
		
		# Compressed files can hide malware
		if is_compressed:
			risk_score += COMPRESSED_FILE_RISK
	
	# Ensure score doesn't go below 0
	return maxf(0.0, risk_score)

## Analyze metadata and return attack type prediction
## Automatically detects difficulty level if not provided
func predict(metadata: Dictionary, difficulty_level: int = -1) -> String:
	# Auto-detect difficulty level if not provided
	if difficulty_level <= 0:
		difficulty_level = detect_difficulty_level(metadata)
	
	var extension = metadata.get("extension", "")
	var publisher = metadata.get("publisher", "")
	var source = metadata.get("source", "")
	var filename = metadata.get("filename", "")
	
	var random_name = 1 if is_random_filename(filename) else 0
	
	# ==============================
	# DECISION TREE LOGIC
	# Progressive complexity based on difficulty level
	# ==============================
	
	# RULE 1: Batch/PowerShell scripts always = injection
	if extension in INJECTION_EXTENSIONS:
		return "injection"
	
	# RULE 2: Executable files with unknown publisher or suspicious source = malware
	if extension in MALWARE_EXTENSIONS:
		if publisher == "unknown" or source in ["Downloads", "Browser Cache"]:
			return "malware"
	
	# RULE 3: Email attachments with random name or unknown publisher = phishing
	if source == "Email Attachment":
		if random_name == 1 or publisher == "unknown":
			return "phishing"
	
	# RULE 4: Safe extensions with unknown publisher AND random name = trojan
	if extension in SAFE_EXTENSIONS:
		if publisher == "unknown" and random_name == 1:
			return "trojan"
	
	# ==============================
	# LEVEL 2+ ENHANCED RULES
	# ==============================
	
	if difficulty_level >= DifficultyLevel.LEVEL_2:
		var hidden = metadata.get("hidden", false)
		var modified_hours_ago = metadata.get("modified_hours_ago", -1)
		
		# Hidden files from unknown sources are phishing attempts
		if hidden and publisher == "unknown":
			return "phishing"
		
		# Recently modified executables are highly suspicious
		if extension in RISKY_EXTENSIONS and modified_hours_ago >= 0 and modified_hours_ago < MODIFIED_RECENTLY_HOURS:
			return "malware"
	
	# ==============================
	# LEVEL 3+ ENHANCED RULES
	# ==============================
	
	if difficulty_level >= DifficultyLevel.LEVEL_3:
		var requires_admin = metadata.get("requires_admin", false)
		var signature_valid = metadata.get("signature_valid", false)
		var is_compressed = metadata.get("is_compressed", false)
		var hidden = metadata.get("hidden", false)
		
		# Admin requirement without valid signature = trojan
		if requires_admin and not signature_valid:
			return "trojan"
		
		# Compressed executable without valid signature = malware
		if extension in MALWARE_EXTENSIONS and is_compressed and not signature_valid:
			return "malware"
		
		# Compressed file from email with hidden attributes = phishing
		if source == "Email Attachment" and is_compressed and hidden:
			return "phishing"
	
	# Default fallback
	return "malware"

## Detect difficulty level from available metadata fields
func detect_difficulty_level(metadata: Dictionary) -> int:
	# Level 3: Has all advanced fields
	if "signature_valid" in metadata and "requires_admin" in metadata and "is_compressed" in metadata:
		return DifficultyLevel.LEVEL_3
	
	# Level 2: Has intermediate fields
	if "modified_hours_ago" in metadata and "hidden" in metadata:
		return DifficultyLevel.LEVEL_2
	
	# Level 1: Only basic fields
	return DifficultyLevel.LEVEL_1

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

## Debug: Print prediction details with full metadata and risk analysis
func print_prediction_details(metadata: Dictionary, prediction: String, difficulty_level: int = -1) -> void:
	if difficulty_level <= 0:
		difficulty_level = detect_difficulty_level(metadata)
	
	var risk_score = calculate_risk_score(metadata, difficulty_level)
	var level_name = ["UNKNOWN", "LEVEL 1", "LEVEL 2", "LEVEL 3"][difficulty_level]
	
	print("\n" + "=".repeat(40))
	print("🧠 DECISION TREE PREDICTION [%s]" % level_name)
	print("=".repeat(40))
	
	# Basic metadata (all levels)
	print("\n📋 BASIC METADATA:")
	print("  Extension: ", metadata.get("extension", "unknown"))
	print("  Size (MB): ", metadata.get("size", "unknown"))
	print("  Publisher: ", metadata.get("publisher", "unknown"))
	print("  Source: ", metadata.get("source", "unknown"))
	print("  Filename: ", metadata.get("filename", "unknown"))
	
	# Level 2 metadata
	if difficulty_level >= DifficultyLevel.LEVEL_2:
		print("\n📋 LEVEL 2 METADATA:")
		print("  Modified Hours Ago: ", metadata.get("modified_hours_ago", "N/A"))
		print("  Hidden: ", metadata.get("hidden", "N/A"))
	
	# Level 3 metadata
	if difficulty_level >= DifficultyLevel.LEVEL_3:
		print("\n📋 LEVEL 3 METADATA:")
		print("  Signature Valid: ", metadata.get("signature_valid", "N/A"))
		print("  Requires Admin: ", metadata.get("requires_admin", "N/A"))
		print("  Is Compressed: ", metadata.get("is_compressed", "N/A"))
	
	# Risk analysis
	print("\n⚠️ RISK ANALYSIS:")
	print("  Risk Score: %.2f" % risk_score)
	print("  Attack Type: ", prediction)
	print("  Minigame Scene: ", get_minigame_scene_path(prediction))
	
	print("\n" + "=".repeat(40) + "\n")

## Get detailed information about why a decision was made
func get_prediction_reasoning(metadata: Dictionary, difficulty_level: int = -1) -> Dictionary:
	if difficulty_level <= 0:
		difficulty_level = detect_difficulty_level(metadata)
	
	var reasoning = {
		"prediction": predict(metadata, difficulty_level),
		"risk_score": calculate_risk_score(metadata, difficulty_level),
		"difficulty_level": difficulty_level,
		"triggered_rules": []
	}
	
	var extension = metadata.get("extension", "")
	var publisher = metadata.get("publisher", "")
	var source = metadata.get("source", "")
	var filename = metadata.get("filename", "")
	var random_name = 1 if is_random_filename(filename) else 0
	
	# Log which rules were triggered
	if extension in INJECTION_EXTENSIONS:
		reasoning.triggered_rules.append("Injection extension detected")
	
	if extension in MALWARE_EXTENSIONS:
		if publisher == "unknown" or source in ["Downloads", "Browser Cache"]:
			reasoning.triggered_rules.append("Malware extension with unknown publisher or suspicious source")
	
	if source == "Email Attachment":
		if random_name == 1 or publisher == "unknown":
			reasoning.triggered_rules.append("Email attachment with random name or unknown publisher")
	
	if extension in SAFE_EXTENSIONS:
		if publisher == "unknown" and random_name == 1:
			reasoning.triggered_rules.append("Safe extension with unknown publisher AND random name")
	
	# Level 2+ rules
	if difficulty_level >= DifficultyLevel.LEVEL_2:
		var hidden = metadata.get("hidden", false)
		var modified_hours_ago = metadata.get("modified_hours_ago", -1)
		
		if hidden and publisher == "unknown":
			reasoning.triggered_rules.append("Hidden file from unknown publisher")
		
		if extension in RISKY_EXTENSIONS and modified_hours_ago >= 0 and modified_hours_ago < MODIFIED_RECENTLY_HOURS:
			reasoning.triggered_rules.append("Risky extension modified recently")
	
	# Level 3+ rules
	if difficulty_level >= DifficultyLevel.LEVEL_3:
		var requires_admin = metadata.get("requires_admin", false)
		var signature_valid = metadata.get("signature_valid", false)
		var is_compressed = metadata.get("is_compressed", false)
		var hidden = metadata.get("hidden", false)
		
		if requires_admin and not signature_valid:
			reasoning.triggered_rules.append("Requires admin but no valid signature")
		
		if extension in MALWARE_EXTENSIONS and is_compressed and not signature_valid:
			reasoning.triggered_rules.append("Compressed executable without valid signature")
		
		if source == "Email Attachment" and is_compressed and hidden:
			reasoning.triggered_rules.append("Email attachment that is compressed and hidden")
	
	return reasoning
