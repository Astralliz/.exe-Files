class_name MetadataGenerator
extends Node

var filename_pool := [
	"test",
	"document1",
	"receipt",
	"photo_2025",
	"final_version",
	"backup_file",
	"notes",
	"profile_pic",
	"invoice",
	"report",
	"asdasg1341342362613e1eads4134123sd"
]

var extension_pool_safe := [".txt", ".pdf", ".png", ".jpg", ".mp3", ".mp4", ".docx"]
var risky_extensions := [
	".exe", ".bat", ".js", ".vbs"
]

var publisher_pool := [
	"unknown",
	"ACME Software",
	"OpenSoft Labs",
	"Blue Horizon",
	"ByteForge",
	"NovaApps"
]

var source_pool := [
	"Downloads",
	"Email Attachment",
	"USB Device",
	"External Drive",
	"Browser Cache",
	"unknown"
]

var max_risky := 3        # max risky files per level
var total_files := 7      # total Filetizens per level
var spawned_files := []   # track spawned metadata to control risky count

func _ready():
	spawned_files.clear()

func generate_metadata() -> FileMetadata:
	var data := FileMetadata.new()
	var engine := HeuristicEngine.new()
	var rules_for_level = RuleBase.new().get_rules(1)  # level 1 rules

	# Count how many risky files remain to spawn
	var risky_remaining = max_risky - spawned_files.count(func(f): return f.risk_score > 1)

	# Decide if this file should be risky
	var make_risky = false
	if risky_remaining > 0 and (total_files - spawned_files.size()) <= risky_remaining:
		# Force risky if needed to reach max_risky
		make_risky = true
	elif risky_remaining > 0:
		make_risky = randf() < 0.5

	if make_risky:
		# Combine multiple factors to ensure score >1
		data.extension = risky_extensions.pick_random() if randf() < 0.5 else extension_pool_safe.pick_random()
		data.size_mb = randf_range(51, 70) if randf() < 0.5 else randf_range(10, 50)
		data.source = "unknown" if randf() < 0.5 else source_pool.pick_random()
		data.publisher = "unknown" if randf() < 0.5 else publisher_pool.pick_random()
	else:
		# Safe Filetizen, ensure score <=1
		data.extension = extension_pool_safe.pick_random()
		data.size_mb = randf_range(10, 50)
		data.source = source_pool.pick_random()
		data.publisher = publisher_pool.pick_random()

	# Fill other fields
	data.filename = filename_pool.pick_random()
	data.hidden = false
	data.signature_valid = true
	data.requires_admin = false
	data.modified_hours_ago = randi_range(50, 1200)
	data.claimed_type = determine_claimed_type(data.extension)

	# Evaluate risk score after assignment
	data.risk_score = engine.evaluate(data, rules_for_level)

	# Save for tracking
	spawned_files.append(data)

	return data

func determine_claimed_type(ext: String) -> String:
	match ext:
		".txt": return "Text Document"
		".pdf": return "PDF Document"
		".exe": return "Executable Program"
		".png", ".jpg": return "Image"
		".mp3": return "Audio"
		".mp4": return "Video"
		".zip": return "Archive"
		".docx": return "Word Document"
		_:
			return "Unknown File"
