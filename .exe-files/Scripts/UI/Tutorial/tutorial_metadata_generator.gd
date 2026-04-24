class_name TutorialMetadataGenerator
extends Node

# ========================
# TUTORIAL SCENARIOS
# ========================
# Each step teaches a specific concept
var scenarios := [
	# Step 0: 🟢 COMPLETELY SAFE - All green flags
	{
		"filename": "report",
		"extension": ".pdf",
		"size_mb": 15.0,
		"publisher": "ACME Software",
		"source": "Downloads",
		"signature_valid": true,
		"requires_admin": false,
		"is_compressed": false,
		"hidden": false,
		"modified_hours_ago": 500,
		"lesson": "This file is completely safe. All indicators are trustworthy."
	},
	
	# Step 1: 🔴 DANGEROUS EXTENSION - .bat file
	{
		"filename": "backup_script",
		"extension": ".bat",
		"size_mb": 20.0,
		"publisher": "unknown",
		"source": "email",
		"signature_valid": false,
		"requires_admin": true,
		"is_compressed": false,
		"hidden": false,
		"modified_hours_ago": 2,
		"lesson": ".bat files are executable scripts. Email attachments are risky!"
	},
	
	# Step 2: 🔴 SUSPICIOUS EXTENSION + LARGE SIZE
	{
		"filename": "installer",
		"extension": ".exe",
		"size_mb": 85.0,
		"publisher": "unknown",
		"source": "unknown",
		"signature_valid": false,
		"requires_admin": true,
		"is_compressed": false,
		"hidden": false,
		"modified_hours_ago": 1,
		"lesson": ".exe files combined with unknown publisher = HIGH RISK. Reject it!"
	},
	
	# Step 3: 🟡 SUBTLE RED FLAG - Unknown publisher
	{
		"filename": "notes",
		"extension": ".pdf",
		"size_mb": 10.0,
		"publisher": "unknown",
		"source": "Email Attachment",
		"signature_valid": true,
		"requires_admin": false,
		"is_compressed": false,
		"hidden": false,
		"modified_hours_ago": 100,
		"lesson": "Unknown publisher is suspicious, even for safe file types."
	},
	
	# Step 4: 🔴 MULTIPLE RED FLAGS - Suspicious filename + .js + unknown + no signature
	{
		"filename": "xJ9aK2pL_script",
		"extension": ".js",
		"size_mb": 30.0,
		"publisher": "unknown",
		"source": "unknown",
		"signature_valid": false,
		"requires_admin": false,
		"is_compressed": true,
		"hidden": true,
		"modified_hours_ago": 3,
		"lesson": "Random filenames + script files + multiple red flags = DEFINITELY MALWARE!"
	}
]

# ========================
# GENERATE TUTORIAL METADATA
# ========================
func generate_metadata(step: int) -> FileMetadata:
	"""Generate metadata for a specific tutorial step"""
	
	if step < 0 or step >= scenarios.size():
		push_warning("Invalid tutorial step: %d. Using step 0." % step)
		step = 0
	
	var scenario = scenarios[step]
	var data := FileMetadata.new()
	
	# Assign all properties from scenario
	data.filename = scenario.filename
	data.extension = scenario.extension
	data.size_mb = scenario.size_mb
	data.publisher = scenario.publisher
	data.source = scenario.source
	data.signature_valid = scenario.signature_valid
	data.requires_admin = scenario.requires_admin
	data.is_compressed = scenario.is_compressed
	data.hidden = scenario.hidden
	data.modified_hours_ago = scenario.modified_hours_ago
	
	# Initialize risk score and issues (will be set by caller)
	data.risk_score = 0.0
	data.issues = []
	
	print("\n=== TUTORIAL STEP %d ===" % step)
	print("Lesson: %s" % scenario.lesson)
	print("File: %s%s" % [scenario.filename, scenario.extension])
	print("=" + str(40))
	
	return data

# ========================
# GET TUTORIAL LESSON
# ========================
func get_lesson_for_step(step: int) -> String:
	"""Get the educational message for this step"""
	if step >= 0 and step < scenarios.size():
		return scenarios[step].lesson
	return "Unknown lesson"

# ========================
# GET TUTORIAL SUMMARY
# ========================
func get_tutorial_summary() -> String:
	return """
🎓 TUTORIAL SUMMARY:

Step 1: Safe Files
- Multiple trusted indicators
- Known publisher, safe file type

Step 2: Dangerous Extensions
- .bat, .exe, .js, .ps1 are executable
- Email attachments are inherently risky

Step 3: Large Executables
- Executable + Unknown Source = Danger
- Large file sizes can indicate bundled malware

Step 4: Subtle Red Flags
- Unknown publisher is suspicious
- Can apply even to seemingly safe files

Step 5: Multiple Red Flags
- Suspicious filename + script file + hidden
- Unknown source + missing signature
- When multiple flags align = REJECT
	"""
