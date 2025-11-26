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

var extension_pool := [
	".txt", ".pdf", ".exe", ".png", ".jpg", ".zip",
	".mp3", ".mp4", ".docx"
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

func generate_metadata() -> FileMetadata:
	var data := FileMetadata.new()

	data.filename = filename_pool.pick_random()
	data.extension = extension_pool.pick_random()

	# random size between 0.1 MB and 1200 MB
	data.size_mb = randf_range(0.1, 1200.0)

	data.publisher = publisher_pool.pick_random()
	data.source = source_pool.pick_random()

	# modified between 0 to 1200 hours ago
	data.modified_hours_ago = randi_range(0, 1200)

	# random boolean flags
	data.hidden = randf() < 0.1           # 10% chance hidden
	data.signature_valid = randf() > 0.2  # 80% chance valid
	data.requires_admin = randf() < 0.15  # 15% chance admin needed

	# claimed type: heuristic depending on extension
	data.claimed_type = determine_claimed_type(data.extension)

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
