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
var risky_extensions := [".exe", ".bat", ".js", ".vbs"]

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

var risky_source := ["email"]

var modified := [10, 13, 27, 50, 32, 3, 63,55]

var is_hidden := [false, true]

var max_risky := 3        # max risky files per level
var total_files := 7      # total Filetizens per level
var spawned_files := []   # track spawned metadata to control risky count


func _ready():
	spawned_files.clear()

func setup_day_config():
	var day = GameState.day
	
	if day <= 2:
		max_risky = 3
		total_files = 7
	elif day <= 4:
		max_risky = 4
		total_files = 9
	else:
		max_risky = 6
		total_files = 10
		
func get_rule_level_from_day(day: int) -> int:
	if day <= 2:
		return 1
	elif day <= 4:
		return 2
	else:
		return 3

func generate_metadata() -> FileMetadata:
	setup_day_config()
	
	var data := FileMetadata.new()
	var engine := HeuristicEngine.new()
	var level = get_rule_level_from_day(GameState.day)
	var rules_for_level = RuleBase.new().get_rules(level)

	# Count risky files remaining
	var risky_remaining = max_risky - spawned_files.count(func(f): return f.risk_score > 1)

	# Decide if this file should be risky
	var make_risky = false
	if risky_remaining > 0 and (total_files - spawned_files.size()) <= risky_remaining:
		make_risky = true
	elif risky_remaining > 0:
		make_risky = randf() < 0.5

	# Basic fields
	data.filename = filename_pool.pick_random()
	data.signature_valid = true
	data.requires_admin = false
	data.is_compressed = false

	# Decide risky vs safe
	if make_risky:

		if GameState.day >= 5:
			# LEVEL 3 RISKY
			if randf() < 0.4:
				data.extension = extension_pool_safe.pick_random()
			else:
				data.extension = risky_extensions.pick_random()

			data.size_mb = randf_range(40, 80)
			data.publisher = publisher_pool.pick_random()
			data.signature_valid = randf() < 0.5
			data.requires_admin = randf() < 0.6
			data.is_compressed = randf() < 0.4

		else:
			# LEVEL 1–2 RISKY
			data.extension = risky_extensions.pick_random() if randf() < 0.5 else extension_pool_safe.pick_random()
			data.size_mb = randf_range(51, 70) if randf() < 0.5 else randf_range(10, 50)
			data.publisher = "unknown" if randf() < 0.5 else publisher_pool.pick_random()

	else:
		# ✅ SAFE FILE LOGIC (ALL LEVELS)
		data.extension = extension_pool_safe.pick_random()
		data.size_mb = randf_range(5, 40)
		data.publisher = publisher_pool.pick_random()
		data.signature_valid = true
		data.requires_admin = false
		data.is_compressed = false

# Source, hidden, modified
	if GameState.day >= 5:
		
		# Level 3 more suspicious patterns
		data.source = "email" if randf() < 0.5 else source_pool.pick_random()
		data.hidden = randf() < 0.4
		data.modified_hours_ago = randi_range(1, 24)
		
		# Increase chance of random filenames
		if randf() < 0.4:
			data.filename = "xJ9aK2pL" + str(randi())
			
	elif GameState.day >= 3:
		data.source = "email" if randf() < 0.6 else source_pool.pick_random()
		data.hidden = is_hidden.pick_random()
		data.modified_hours_ago = modified.pick_random()
		
	else:
		data.source = source_pool.pick_random()
		data.hidden = false
		data.modified_hours_ago = randi_range(50, 1200)


	# Evaluate risk score
	var result = engine.evaluate(data, rules_for_level)
	data.risk_score = result.score
	data.issues = result.issues

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
